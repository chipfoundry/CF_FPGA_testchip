import cocotb
from cocotb.triggers import ClockCycles, Timer
from cocotb.handle import Force, Release
import re
from pathlib import Path

# ===========================================================================
# GPIO PIN MAP
# ===========================================================================
BIDIR_TO_GPIO = {
    0:  0,   1:  1,   2:  2,   3:  3,   4:  4,   5:  5,
    6:  6,   7:  7,   8:  8,   9:  9,  10: 10,
   11: 11,  12: 12,  13: 13,
   14: 15,  15: 16,  16: 17,  17: 18,  18: 19,
   19: 20,  20: 21,  21: 22,  22: 23,  23: 24,
   24: 27,  25: 28,
   26: 33,  27: 34,  28: 35,  29: 36,  30: 37,
   31: 39,  32: 40,  33: 41,  34: 42,  35: 43,
}

GPIO_SPI_CSN  = 31
GPIO_SPI_SCLK = 32
GPIO_SPI_MOSI = 30
GPIO_CFG_DONE = 14
GPIO_FPGA_SEL0 = 25
GPIO_FPGA_SEL1 = 26

SPI_HALF_PERIOD = 3

LOOKUP_SMALL = {
    "X0Y1/A" : 0, "X0Y1/B" : 1, "X0Y2/A" : 2, "X0Y2/B" : 3,
    "X0Y3/A" : 4, "X0Y3/B" : 5, "X0Y4/A" : 6, "X0Y4/B" : 7,
    "X0Y5/A" : 8, "X0Y5/B" : 9, "X0Y6/A" : 10, "X0Y6/B" : 11,
    "X5Y1/A" : 12, "X5Y1/B" : 13, "X5Y2/A" : 14, "X5Y2/B" : 15,
    "X5Y3/A" : 16, "X5Y3/B" : 17, "X5Y4/A" : 18, "X5Y4/B" : 19,
    "X5Y5/A" : 20, "X5Y5/B" : 21, "X5Y6/A" : 22, "X5Y6/B" : 23,
}

LOOKUP_LARGE = {
    "X0Y1/A" : 0, "X0Y1/B" : 1, "X0Y2/A" : 2, "X0Y2/B" : 3,
    "X0Y3/A" : 4, "X0Y3/B" : 5, "X0Y4/A" : 6, "X0Y4/B" : 7,
    "X0Y5/A" : 8, "X0Y5/B" : 9, "X0Y6/A" : 10, "X0Y6/B" : 11,
    "X0Y7/A" : 12, "X0Y7/B" : 13, "X0Y8/A" : 14, "X0Y8/B" : 15,
    "X0Y9/A" : 16, "X0Y9/B" : 17, "X0Y10/A" : 18, "X0Y10/B" : 19,
    "X0Y11/A" : 20, "X0Y11/B" : 21, "X0Y12/A" : 22, "X0Y12/B" : 23,
    "X14Y1/A" : 24, "X14Y2/A" : 25, "X14Y3/A" : 26, "X14Y4/A" : 27,
    "X14Y5/A" : 28, "X14Y6/A" : 29, "X14Y7/A" : 30, "X14Y8/A" : 31,
    "X14Y9/A" : 32, "X14Y10/A" : 33, "X14Y11/A" : 34, "X14Y12/A" : 35,
}

def get_pcf_path(proj_root, fabric_type, testname):
    return proj_root / f"verilog/dv/cocotb/examples/{fabric_type}/{testname}/generated_constraints.pcf"

def get_bitstream_path(proj_root, fabric_type, testname):
    return proj_root / f"verilog/dv/cocotb/examples/{fabric_type}/{testname}/{testname}.bit"

def get_gpio(tile, fabric_type):
    lookup = LOOKUP_SMALL if fabric_type == "small" else LOOKUP_LARGE
    bidir_idx = lookup[tile]
    return BIDIR_TO_GPIO[bidir_idx]

def parse_pcf(pcf_path):
    signals = {}
    with open(pcf_path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            match = re.match(r"set_io\s+(\w+)(?:\[(\d+)\])?\s+(X\d+Y\d+\/\w+)", line)
            if match:
                sig_name = match.group(1)
                idx = int(match.group(2)) if match.group(2) is not None else 0
                tile = match.group(3)
                if sig_name == "io":
                    continue
                if sig_name not in signals:
                    signals[sig_name] = {}
                signals[sig_name][idx] = tile
    return signals

# ===========================================================================
# GL MODE DETECTION
# ===========================================================================
# In GL simulation, chip_core is flattened into the wrapper. The internal
# bidir_in/bidir_out buses no longer exist as named signals. Instead, we
# use the external GPIO port interface (drive_gpio / monitor_gpio).
# ===========================================================================

_gl_mode = None  # Auto-detected on first use

def _detect_gl_mode(env):
    """Auto-detect whether we're running RTL or GL simulation.
    
    In RTL mode, u_chip_core exists as a sub-hierarchy with bidir_in/bidir_out.
    In GL mode, chip_core is flattened — bidir_in doesn't exist.
    """
    global _gl_mode
    if _gl_mode is not None:
        return _gl_mode
    
    try:
        wrapper = env.dut.uut.user_project
        _ = wrapper.u_chip_core.bidir_in
        _gl_mode = False
        cocotb.log.info("[common] Detected RTL simulation mode (bidir_in bus found)")
    except AttributeError:
        _gl_mode = True
        cocotb.log.info("[common] Detected GL simulation mode (bidir_in bus not found, using GPIO-level I/O)")
    
    return _gl_mode

# ===========================================================================
# RTL-MODE SIGNAL ACCESS (internal wire forcing)
# ===========================================================================

# Global state to maintain the forced 36-bit value (RTL mode only)
_forced_bidir_in_value = 0

def _update_bidir_in_rtl(env):
    """Force the bidir_in bus in RTL mode."""
    global _forced_bidir_in_value
    if hasattr(env, "dut") and hasattr(env.dut, "uut"):
        if hasattr(env.dut.uut, "user_project"):
            env.dut.uut.user_project.u_chip_core.bidir_in.value = Force(_forced_bidir_in_value)
        else:
            env.dut.uut.u_chip_core.bidir_in.value = Force(_forced_bidir_in_value)
    elif hasattr(env, "dut"):
        env.dut.u_chip_core.bidir_in.value = Force(_forced_bidir_in_value)
    else:
        env.uut.u_chip_core.bidir_in.value = Force(_forced_bidir_in_value)

def _set_signal_rtl(env, sig_name, val, signals, fabric_type):
    """Set a signal by forcing the internal bidir_in bus (RTL mode)."""
    global _forced_bidir_in_value
    bits = signals[sig_name]
    lookup = LOOKUP_SMALL if fabric_type == "small" else LOOKUP_LARGE
    for idx in sorted(bits.keys()):
        bidir_idx = lookup[bits[idx]]
        bit_val = (val >> idx) & 1
        if bit_val:
            _forced_bidir_in_value |= (1 << bidir_idx)
        else:
            _forced_bidir_in_value &= ~(1 << bidir_idx)
    _update_bidir_in_rtl(env)

def _get_signal_rtl(env, sig_name, signals, fabric_type):
    """Read a signal from the internal bidir_out bus (RTL mode)."""
    bits = signals[sig_name]
    val = 0
    lookup = LOOKUP_SMALL if fabric_type == "small" else LOOKUP_LARGE
    for idx in sorted(bits.keys()):
        bidir_idx = lookup[bits[idx]]
        bit_val = 0
        if hasattr(env, "dut") and hasattr(env.dut, "uut"):
            if hasattr(env.dut.uut, "user_project"):
                bit_val = int(env.dut.uut.user_project.u_chip_core.bidir_out[bidir_idx].value)
            else:
                bit_val = int(env.dut.uut.u_chip_core.bidir_out[bidir_idx].value)
        elif hasattr(env, "dut"):
            bit_val = int(env.dut.u_chip_core.bidir_out[bidir_idx].value)
        else:
            bit_val = int(env.uut.u_chip_core.bidir_out[bidir_idx].value)
        val |= (bit_val << idx)
    return val

def _release_signal_rtl(env, sig_name, signals, fabric_type):
    """Release the bidir_in force (RTL mode)."""
    if hasattr(env, "dut") and hasattr(env.dut, "uut"):
        if hasattr(env.dut.uut, "user_project"):
            env.dut.uut.user_project.u_chip_core.bidir_in.value = Release()
        else:
            env.dut.uut.u_chip_core.bidir_in.value = Release()
    elif hasattr(env, "dut"):
        env.dut.u_chip_core.bidir_in.value = Release()
    else:
        env.uut.u_chip_core.bidir_in.value = Release()

# ===========================================================================
# GL-MODE SIGNAL ACCESS (external GPIO port interface)
# ===========================================================================
# In GL simulation, we interact with the design exclusively through the
# external GPIO ports (drive_gpio / monitor_gpio), through the same physical 
# interface that the physical chip uses.
# ===========================================================================

def _set_signal_gl(env, sig_name, val, signals, fabric_type):
    """Set a signal by driving external GPIOs (GL mode)."""
    bits = signals[sig_name]
    lookup = LOOKUP_SMALL if fabric_type == "small" else LOOKUP_LARGE
    cocotb.log.info(f"[common] Driving signal '{sig_name}' to value {val} (bin: {bin(val)[2:]})")
    for idx in sorted(bits.keys()):
        bidir_idx = lookup[bits[idx]]
        gpio_num = BIDIR_TO_GPIO[bidir_idx]
        bit_val = (val >> idx) & 1
        cocotb.log.info(f"  -> Bit {idx} mapped to fabric tile '{bits[idx]}' (bidir[{bidir_idx}]). Driving GPIO {gpio_num} = {bit_val}")
        env.drive_gpio(gpio_num, bit_val)

def _get_signal_gl(env, sig_name, signals, fabric_type):
    """Read a signal by monitoring external GPIOs (GL mode)."""
    bits = signals[sig_name]
    val = 0
    lookup = LOOKUP_SMALL if fabric_type == "small" else LOOKUP_LARGE
    cocotb.log.info(f"[common] Reading signal '{sig_name}' from GPIOs...")
    for idx in sorted(bits.keys()):
        bidir_idx = lookup[bits[idx]]
        gpio_num = BIDIR_TO_GPIO[bidir_idx]
        bit_val = env.monitor_gpio(gpio_num)
        cocotb.log.info(f"  <- Bit {idx} mapped to fabric tile '{bits[idx]}' (bidir[{bidir_idx}]). Reading GPIO {gpio_num} = {bit_val}")
        val |= (bit_val << idx)
    cocotb.log.info(f"[common] Signal '{sig_name}' read as {val} (bin: {bin(val)[2:]})")
    return val

def _release_signal_gl(env, sig_name, signals, fabric_type):
    """Release GPIO drivers (GL mode)."""
    bits = signals[sig_name]
    lookup = LOOKUP_SMALL if fabric_type == "small" else LOOKUP_LARGE
    cocotb.log.info(f"[common] Releasing signal '{sig_name}' GPIO drivers...")
    for idx in sorted(bits.keys()):
        bidir_idx = lookup[bits[idx]]
        gpio_num = BIDIR_TO_GPIO[bidir_idx]
        cocotb.log.info(f"  -> Releasing GPIO {gpio_num}")
        env.release_gpio(gpio_num)

# ===========================================================================
# UNIFIED PUBLIC API (auto-dispatches to RTL or GL implementation)
# ===========================================================================

def set_signal(env, sig_name, val, signals, fabric_type):
    """Set a signal value. Auto-dispatches to RTL or GL implementation."""
    if _detect_gl_mode(env):
        _set_signal_gl(env, sig_name, val, signals, fabric_type)
    else:
        _set_signal_rtl(env, sig_name, val, signals, fabric_type)

def get_signal(env, sig_name, signals, fabric_type):
    """Get a signal value. Auto-dispatches to RTL or GL implementation."""
    if _detect_gl_mode(env):
        return _get_signal_gl(env, sig_name, signals, fabric_type)
    else:
        return _get_signal_rtl(env, sig_name, signals, fabric_type)

def release_signal(env, sig_name, signals, fabric_type):
    """Release a signal. Auto-dispatches to RTL or GL implementation."""
    if _detect_gl_mode(env):
        _release_signal_gl(env, sig_name, signals, fabric_type)
    else:
        _release_signal_rtl(env, sig_name, signals, fabric_type)

# Keep the old update_bidir_in name for backward compatibility
def update_bidir_in(env):
    if not _detect_gl_mode(env):
        _update_bidir_in_rtl(env)

async def system_clock_runner(env, gpio_pin=38):
    is_gl = _detect_gl_mode(env)
    cocotb.log.info(f"[common] Starting system clock runner on GPIO {gpio_pin} (GL mode={is_gl})")
    while True:
        if is_gl:
            env.dut.uut.user_project.gpio_in[38].value = 1
        else:
            env.drive_gpio(gpio_pin, 1)
        await Timer(12, units="ns")
        if is_gl:
            env.dut.uut.user_project.gpio_in[38].value = 0
        else:
            env.drive_gpio(gpio_pin, 0)
        await Timer(13, units="ns")

async def select_fabric(env, fabric_type):
    cocotb.log.info(f"[common] Selecting fabric: {fabric_type}")
    if not hasattr(env, "system_clock_started"):
        cocotb.log.info(f"[common] Launching system clock runner thread...")
        cocotb.start_soon(system_clock_runner(env, 38))
        env.system_clock_started = True

    if fabric_type == "small":
        cocotb.log.info(f"[common] Driving FPGA_SEL0 (GPIO {GPIO_FPGA_SEL0}) = 1, FPGA_SEL1 (GPIO {GPIO_FPGA_SEL1}) = 0")
        env.drive_gpio(GPIO_FPGA_SEL0, 1)
        env.drive_gpio(GPIO_FPGA_SEL1, 0)
    elif fabric_type == "medium":
        cocotb.log.info(f"[common] Driving FPGA_SEL0 (GPIO {GPIO_FPGA_SEL0}) = 0, FPGA_SEL1 (GPIO {GPIO_FPGA_SEL1}) = 1")
        env.drive_gpio(GPIO_FPGA_SEL0, 0)
        env.drive_gpio(GPIO_FPGA_SEL1, 1)
    else:  # large
        cocotb.log.info(f"[common] Driving FPGA_SEL0 (GPIO {GPIO_FPGA_SEL0}) = 0, FPGA_SEL1 (GPIO {GPIO_FPGA_SEL1}) = 0")
        env.drive_gpio(GPIO_FPGA_SEL0, 0)
        env.drive_gpio(GPIO_FPGA_SEL1, 0)
    
    cocotb.log.info(f"[common] Waiting 10 clock cycles for selection to settle...")
    await ClockCycles(env.clk, 10)
    cocotb.log.info(f"[common] Executing Caravel reset...")
    await env.reset()
    cocotb.log.info(f"[common] Caravel reset complete.")

def initialize_pads(env):
    """Initialize pads. In RTL mode, force bidir_in to 0. In GL mode, no-op
    (GPIOs are initialized by the harness startup sequence)."""
    global _forced_bidir_in_value
    _forced_bidir_in_value = 0
    cocotb.log.info("[common] initialize_pads() called")
    if not _detect_gl_mode(env):
        cocotb.log.info("[common] RTL mode: zeroing out bidir_in bus")
        _update_bidir_in_rtl(env)
    else:
        cocotb.log.info("[common] GL mode: skipping bidir_in force (using GPIO-level I/O)")
        
        # Freeze the 1-Wire FSM in GL simulation by forcing its synchronized input to 1.
        # This prevents the artificially fast GL ring oscillator from interpreting normal
        # testbench pulses on GPIO 0 as a 480us master reset pulse.
        try:
            user_project = env.dut.uut.user_project
            owire_in_s2 = getattr(user_project, "\\u_owire.u_ip.owire_in_s2 ")
            owire_in_s2.value = Force(1)
            cocotb.log.info("[common] Successfully forced \\u_owire.u_ip.owire_in_s2 to 1")
        except Exception as e:
            cocotb.log.warning(f"[common] Could not force 1-Wire FSM: {e}")

        # Force power signals on caravel_top to avoid 'x' propagation in GL simulation
        try:
            env.dut.vddio_tb.value = Force(1)
            env.dut.vssio_tb.value = Force(0)
            env.dut.vdda_tb.value = Force(1)
            env.dut.vssa_tb.value = Force(0)
            env.dut.vccd_tb.value = Force(1)
            env.dut.vssd_tb.value = Force(0)
            env.dut.vdda1_tb.value = Force(1)
            env.dut.vssa1_tb.value = Force(0)
            env.dut.vdda2_tb.value = Force(1)
            env.dut.vssa2_tb.value = Force(0)
            env.dut.vccd1_tb.value = Force(1)
            env.dut.vssd1_tb.value = Force(0)
            env.dut.vccd2_tb.value = Force(1)
            env.dut.vssd2_tb.value = Force(0)
            cocotb.log.info("[common] GL mode: successfully forced all top-level power signals")
        except AttributeError as e:
            cocotb.log.warning(f"[common] GL mode: could not force top-level power signals: {e}")

async def bitbang_clear_bitstream(env, fabric_type):
    cocotb.log.info(f"--- Clearing eFPGA bitstream for {fabric_type} fabric ---")
    
    num_rows = 8 if fabric_type == "small" else (8 if fabric_type == "medium" else 14)
    num_cols = 6 if fabric_type == "small" else (10 if fabric_type == "medium" else 15)
    
    # Safe GPIO driver to prevent setup/hold/clock-data races in GL simulation
    async def drive_gpio_safe(pin, val):
        if _detect_gl_mode(env):
            await Timer(5, units="ns")
        env.drive_gpio(pin, val)

    # Drive configuration SPI pins
    cocotb.log.info(f"  -> Resetting SPI bus (CSN=1, SCLK=0, MOSI=0)")
    await drive_gpio_safe(GPIO_SPI_CSN, 1)
    await drive_gpio_safe(GPIO_SPI_SCLK, 0)
    await drive_gpio_safe(GPIO_SPI_MOSI, 0)
    await ClockCycles(env.clk, 20)

    # Active CSN
    cocotb.log.info(f"  -> Activating SPI CSN=0")
    await drive_gpio_safe(GPIO_SPI_CSN, 0)
    await ClockCycles(env.clk, 10)

    # Helper to send a 32-bit word
    async def send_word(word):
        for i in range(32):
            bit = (word >> (31 - i)) & 1
            await drive_gpio_safe(GPIO_SPI_MOSI, bit)
            await ClockCycles(env.clk, SPI_HALF_PERIOD)
            await drive_gpio_safe(GPIO_SPI_SCLK, 1)
            await ClockCycles(env.clk, SPI_HALF_PERIOD)
            await drive_gpio_safe(GPIO_SPI_SCLK, 0)
            await ClockCycles(env.clk, SPI_HALF_PERIOD)

    # 1. Send Bitstream Start Header
    cocotb.log.info(f"  -> Sending bitstream header: 0xFAB0FAB1")
    await send_word(0xFAB0FAB1)

    # 2. Loop to clear all columns, frames, and rows
    cocotb.log.info(f"  -> Clearing memory for {num_cols} columns, {num_rows} rows...")
    for column in reversed(range(num_cols)):
        for frame in reversed(range(20)): # MAX_FRAMES_PER_COL is always 20
            header = (column & 0x1F) << 27 | (1 << frame) & 0xFFFFF
            await send_word(header)
            for row in reversed(range(num_rows)):
                await send_word(0x00000000)

    # 3. Send Desync Frame
    desync_header = 1 << 20  # DESYNC_FLAG is 20
    cocotb.log.info(f"  -> Sending desync header: {hex(desync_header)}")
    await send_word(desync_header)

    await ClockCycles(env.clk, 20)
    await drive_gpio_safe(GPIO_SPI_CSN, 1)
    await ClockCycles(env.clk, 20)
    cocotb.log.info("eFPGA bitstream cleared successfully!")

async def bitbang_upload_bitstream(env, bitstream_path):
    cocotb.log.info(f"--- Uploading bitstream: {bitstream_path} ---")

    async def drive_gpio_safe(pin, val):
        if _detect_gl_mode(env):
            await Timer(5, units="ns")
        env.drive_gpio(pin, val)

    cocotb.log.info(f"  -> Initializing SPI bus for upload...")
    await drive_gpio_safe(GPIO_SPI_CSN, 1)
    await drive_gpio_safe(GPIO_SPI_SCLK, 0)
    await drive_gpio_safe(GPIO_SPI_MOSI, 0)
    await ClockCycles(env.clk, 20)

    cocotb.log.info(f"  -> Activating SPI CSN=0")
    await drive_gpio_safe(GPIO_SPI_CSN, 0)
    await ClockCycles(env.clk, 10)

    cocotb.log.info(f"  -> Streaming bitstream words...")
    words_streamed = 0
    with open(bitstream_path, 'rb') as f:
        data = f.read(4)
        while data:
            word = int.from_bytes(data, byteorder='big')
            for i in range(32):
                bit = (word >> (31 - i)) & 1
                await drive_gpio_safe(GPIO_SPI_MOSI, bit)
                await ClockCycles(env.clk, SPI_HALF_PERIOD)
                await drive_gpio_safe(GPIO_SPI_SCLK, 1)
                await ClockCycles(env.clk, SPI_HALF_PERIOD)
                await drive_gpio_safe(GPIO_SPI_SCLK, 0)
                await ClockCycles(env.clk, SPI_HALF_PERIOD)
            words_streamed += 1
            if words_streamed % 1000 == 0:
                cocotb.log.info(f"    ... streamed {words_streamed} words")
            data = f.read(4)

    cocotb.log.info(f"  -> Completed streaming {words_streamed} words. Deactivating CSN...")
    await ClockCycles(env.clk, 20)
    await drive_gpio_safe(GPIO_SPI_CSN, 1)
    await ClockCycles(env.clk, 20)
    cocotb.log.info("Bitstream upload complete!")


def force_power_signals(handle):
    """Recursively walks the design hierarchy and forces all VPWR and VGND signals to 1 and 0.
    
    This works in both RTL and GL modes because the fabric macros remain as
    behavioral blackbox instances — they are not synthesized by OpenLane.
    """
    try:
        for child in handle:
            name = child._name
            if name == "VPWR":
                child.value = 1
            elif name == "VGND":
                child.value = 0
            else:
                force_power_signals(child)
    except TypeError:
        # child is not iterable
        pass
    except Exception as e:
        cocotb.log.warning(f"[common] force_power_signals error: {e}")
        pass

def get_fabric_handle(env, fabric_type):
    """Get a handle to the fabric macro instance. Works in both RTL and GL modes."""
    fabric_name = f"classic_fabric_chipfoundry_{fabric_type}"
    inst_name = f"i_{fabric_name}"
    
    wrapper = env.dut.uut.user_project
    
    if not _detect_gl_mode(env):
        cocotb.log.info(f"[common] Searching for RTL fabric handle: u_chip_core.{inst_name}")
        # RTL: direct hierarchical access
        return getattr(wrapper.u_chip_core, inst_name)
    else:
        # GL: escaped identifier (Yosys flattened chip_core into wrapper)
        escaped_name = f"\\u_chip_core.{inst_name} "
        cocotb.log.info(f"[common] Searching for GL fabric handle: '{escaped_name}'")
        try:
            handle = wrapper._id(escaped_name, extended=False)
            cocotb.log.info(f"  -> Found fabric handle successfully.")
            return handle
        except AttributeError:
            cocotb.log.warning(f"[common] Could not find fabric instance '{escaped_name}' in GL netlist")
            # Try without trailing space (some simulators)
            escaped_name_no_space = f"\\u_chip_core.{inst_name}"
            try:
                handle = wrapper._id(escaped_name_no_space, extended=False)
                cocotb.log.info(f"  -> Found fabric handle successfully (no space suffix).")
                return handle
            except AttributeError:
                cocotb.log.error(f"[common] Fabric instance not found in GL netlist with any naming convention")
                return None

def get_tile_handle(fabric_handle, x, y):
    prefix = f"Tile_X{x}Y{y}_"
    try:
        for attr in dir(fabric_handle):
            if attr.startswith(prefix):
                return getattr(fabric_handle, attr), attr
    except Exception:
        pass
    
    for suffix in ["LUT4x8_ha", "W_IO2", "E_IO2", "W_IO", "E_IO", "DSP_top"]:
        name = f"{prefix}{suffix}"
        if hasattr(fabric_handle, name):
            return getattr(fabric_handle, name), name
    return None, None

def is_defined_signal(sig):
    try:
        v = sig.value
        v_str = str(v).lower()
        return '0' in v_str or '1' in v_str
    except Exception:
        return False

def get_signal_val_str(sig):
    try:
        v = sig.value
        if hasattr(v, "binstr"):
            return v.binstr
        return str(v)
    except Exception as e:
        return f"Error({e})"

def log_all_tiles(env, fabric_handle, fabric_type):
    if fabric_handle is None:
        cocotb.log.warning("[common] log_all_tiles: fabric_handle is None")
        return
        
    cocotb.log.info("=" * 80)
    cocotb.log.info(f"[DEBUG DUMP] Recursive status dump for {fabric_type} fabric tiles")
    cocotb.log.info(f"  dir(fabric_handle): {dir(fabric_handle)}")
    cocotb.log.info("=" * 80)
    
    if fabric_type == "small":
        cols, rows = 6, 8
    elif fabric_type == "medium":
        cols, rows = 10, 8
    else: # large
        cols, rows = 15, 14
        
    for y in range(rows):
        for x in range(cols):
            tile_handle, tile_name = get_tile_handle(fabric_handle, x, y)
            if not tile_handle:
                continue
                
            iobufs = []
            for let in ["A", "B"]:
                for name in [f"Inst_{let}_IOBUF", f"Inst_{let}_IO"]:
                    if hasattr(tile_handle, name):
                        iobufs.append((let, getattr(tile_handle, name)))
                        
            if iobufs:
                cocotb.log.info(f"  Tile X{x}Y{y} ({tile_name}):")
                for let, iobuf in iobufs:
                    try:
                        val_in = get_signal_val_str(iobuf.IN)
                        val_en = get_signal_val_str(iobuf.EN)
                        val_out = get_signal_val_str(iobuf.OUT)
                        val_in_top = get_signal_val_str(iobuf.IN_top)
                        val_en_top = get_signal_val_str(iobuf.EN_top)
                        val_out_top = get_signal_val_str(iobuf.OUT_top)
                        cfg = get_signal_val_str(iobuf.ConfigBits)
                        cocotb.log.info(f"    IOBUF_{let}: IN={val_in}, EN={val_en}, OUT={val_out} | IN_top={val_in_top}, EN_top={val_en_top}, OUT_top={val_out_top} | Config={cfg}")
                    except Exception as e:
                        cocotb.log.info(f"    IOBUF_{let}: Failed to read: {e}")
                        
            slices = []
            for let in ["LA", "LB", "LC", "LD", "LE", "LF", "LG", "LH"]:
                for suffix in ["_FABULOUS_LC", ""]:
                    name = f"Inst_{let}{suffix}"
                    if hasattr(tile_handle, name):
                        slices.append((let, getattr(tile_handle, name)))
                        break
                        
            if slices:
                tile_header_printed = False
                for let, sl in slices:
                    try:
                        cfg_str = get_signal_val_str(sl.ConfigBits)
                        is_active = False
                        if '1' in cfg_str:
                            is_active = True
                        else:
                            for sig in [sl.I, sl.Ci, sl.O, sl.Co]:
                                if is_defined_signal(sig):
                                    is_active = True
                                    break
                                    
                        if is_active:
                            if not tile_header_printed:
                                cocotb.log.info(f"  Tile X{x}Y{y} ({tile_name}):")
                                tile_header_printed = True
                            val_i = get_signal_val_str(sl.I)
                            val_ci = get_signal_val_str(sl.Ci)
                            val_o = get_signal_val_str(sl.O)
                            val_co = get_signal_val_str(sl.Co)
                            cocotb.log.info(f"    Slice {let}: I={val_i}, Ci={val_ci}, O={val_o}, Co={val_co} | Config={cfg_str}")
                    except Exception as e:
                        pass
    cocotb.log.info("=" * 80)

