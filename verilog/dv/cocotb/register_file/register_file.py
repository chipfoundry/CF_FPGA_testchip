from caravel_cocotb.caravel_interfaces import test_configure
from caravel_cocotb.caravel_interfaces import report_test
import cocotb
from cocotb.triggers import ClockCycles, Timer
from cocotb.types import LogicArray
from pathlib import Path
from common.common import get_fabric_handle, initialize_pads, force_power_signals, bitbang_clear_bitstream, parse_pcf, bitbang_upload_bitstream, set_signal, get_signal, release_signal, select_fabric, get_pcf_path, get_bitstream_path, get_gpio

@cocotb.test()
@report_test
async def register_file(dut):
    caravelEnv = await test_configure(dut, timeout_cycles=5000000)
    cocotb.log.info("=" * 62)
    cocotb.log.info("OPENFRAME TESTCASE: register_file (Large Fabric)")
    cocotb.log.info("=" * 62)

    proj_root = Path(__file__).resolve().parent.parent.parent.parent.parent
    fabric_type = "large"
    testname = "register_file"

    initialize_pads(caravelEnv)
    fabric_handle = get_fabric_handle(caravelEnv, fabric_type)
    if fabric_handle:
        force_power_signals(fabric_handle)

    await select_fabric(caravelEnv, fabric_type)

    pcf_path = get_pcf_path(proj_root, fabric_type, testname)
    bitstream_path = get_bitstream_path(proj_root, fabric_type, testname)

    pcf = parse_pcf(pcf_path)
    
    clk1_gpio = get_gpio("X14Y12/A", fabric_type)
    clk2_gpio = get_gpio("X0Y12/A", fabric_type)
    ena_gpio = get_gpio("X0Y7/A", fabric_type)
    rst_gpio = get_gpio("X0Y7/B", fabric_type)

    # Reset
    set_signal(caravelEnv, "clk1", 0, pcf, fabric_type)
    set_signal(caravelEnv, "clk2", 0, pcf, fabric_type)
    set_signal(caravelEnv, "rst", 1, pcf, fabric_type)
    set_signal(caravelEnv, "ena", 1, pcf, fabric_type)
    await ClockCycles(caravelEnv.clk, 10)

    await bitbang_clear_bitstream(caravelEnv, fabric_type)
    await bitbang_upload_bitstream(caravelEnv, bitstream_path)
    await ClockCycles(caravelEnv.clk, 10)
    
    # Release reset
    set_signal(caravelEnv, "rst", 0, pcf, fabric_type)
    await ClockCycles(caravelEnv.clk, 10)
    
    # Fill the memory with data
    for i in range(32):
        word_val = i & 0xF
        set_signal(caravelEnv, "word_a", word_val, pcf, fabric_type)
        set_signal(caravelEnv, "addr_a", i, pcf, fabric_type)
        
        await ClockCycles(caravelEnv.clk, 1) # Setup time
        set_signal(caravelEnv, "clk1", 1, pcf, fabric_type)
        cocotb.log.info(f"  WRITE [addr_a={i}]: {word_val}")
        await ClockCycles(caravelEnv.clk, 5)
        set_signal(caravelEnv, "clk1", 0, pcf, fabric_type)
        await ClockCycles(caravelEnv.clk, 5)

    await ClockCycles(caravelEnv.clk, 10)
    
    # Read from both read ports
    for i in range(32):
        value = 31 - i
        set_signal(caravelEnv, "addr_b", value, pcf, fabric_type)
        set_signal(caravelEnv, "addr_c", value & 0x3, pcf, fabric_type)
        
        await ClockCycles(caravelEnv.clk, 1) # Setup time
        # Dual-read-cycle on clk2
        set_signal(caravelEnv, "clk2", 1, pcf, fabric_type)
        await ClockCycles(caravelEnv.clk, 10)
        set_signal(caravelEnv, "clk2", 0, pcf, fabric_type)
        await ClockCycles(caravelEnv.clk, 10)

        word_b_val = get_signal(caravelEnv, "word_b", pcf, fabric_type)
        word_c_val = get_signal(caravelEnv, "word_c", pcf, fabric_type)

        cocotb.log.info(f"  READ [addr_b={value}]: expected {value & 0xF}, got {word_b_val}")
        cocotb.log.info(f"  READ [addr_c={value & 0x3}]: expected {value % 0x4}, got {word_c_val}")

        assert word_b_val == value & 0xF, f"register_file FAIL word_b: expected {value & 0xF}, got {word_b_val}"
        assert word_c_val == value % 0x4, f"register_file FAIL word_c: expected {value % 0x4}, got {word_c_val}"

    release_signal(caravelEnv, "word_a", pcf, fabric_type)
    release_signal(caravelEnv, "addr_a", pcf, fabric_type)
    release_signal(caravelEnv, "addr_b", pcf, fabric_type)
    release_signal(caravelEnv, "addr_c", pcf, fabric_type)
    release_signal(caravelEnv, "clk1", pcf, fabric_type)
    release_signal(caravelEnv, "clk2", pcf, fabric_type)
    release_signal(caravelEnv, "ena", pcf, fabric_type)
    release_signal(caravelEnv, "rst", pcf, fabric_type)

    cocotb.log.info("TEST PASSED")
