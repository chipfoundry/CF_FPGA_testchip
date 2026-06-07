from caravel_cocotb.caravel_interfaces import test_configure
from caravel_cocotb.caravel_interfaces import report_test
import cocotb
from cocotb.triggers import ClockCycles
from pathlib import Path
import random
from common.common import get_fabric_handle, initialize_pads, force_power_signals, bitbang_clear_bitstream, parse_pcf, bitbang_upload_bitstream, set_signal, get_signal, release_signal, select_fabric, get_pcf_path, get_bitstream_path

@cocotb.test()
@report_test
async def macc_8x8_20(dut):
    caravelEnv = await test_configure(dut, timeout_cycles=5000000)
    cocotb.log.info("=" * 62)
    cocotb.log.info("OPENFRAME TESTCASE: macc_8x8_20 (Large Fabric)")
    cocotb.log.info("=" * 62)

    proj_root = Path(__file__).resolve().parent.parent.parent.parent.parent
    fabric_type = "large"
    testname = "macc_8x8_20"

    initialize_pads(caravelEnv)
    
    fabric_handle = get_fabric_handle(caravelEnv, fabric_type)
    if fabric_handle:
        force_power_signals(fabric_handle)

    await select_fabric(caravelEnv, fabric_type)

    pcf_path = get_pcf_path(proj_root, fabric_type, testname)
    bitstream_path = get_bitstream_path(proj_root, fabric_type, testname)

    pcf = parse_pcf(pcf_path)
    await bitbang_clear_bitstream(caravelEnv, fabric_type)
    await bitbang_upload_bitstream(caravelEnv, bitstream_path)
    await ClockCycles(caravelEnv.clk, 100)
    
    # Initialize control pins
    set_signal(caravelEnv, "clk1", 0, pcf, fabric_type)
    set_signal(caravelEnv, "rst", 1, pcf, fabric_type)  # As per original testbench
    set_signal(caravelEnv, "ena", 1, pcf, fabric_type)
    await ClockCycles(caravelEnv.clk, 20)

    na = len(pcf["a"])
    nb = len(pcf["b"])
    
    for i in range(15):
        va = random.randint(0, (1 << na) - 1)
        vb = random.randint(0, (1 << nb) - 1)
        expected = va * vb
        
        # Setup inputs
        set_signal(caravelEnv, "a", va, pcf, fabric_type)
        set_signal(caravelEnv, "b", vb, pcf, fabric_type)
        
        # Setup time padding
        await ClockCycles(caravelEnv.clk, 10)
        
        # Toggle clk1
        set_signal(caravelEnv, "clk1", 1, pcf, fabric_type)
        await ClockCycles(caravelEnv.clk, 10)
        set_signal(caravelEnv, "clk1", 0, pcf, fabric_type)
        await ClockCycles(caravelEnv.clk, 10)
        
        result = get_signal(caravelEnv, "product", pcf, fabric_type)
        cocotb.log.info(f"  macc[{i}]: {va} * {vb} = {result} (expected {expected})")
        assert result == expected, f"macc FAIL at step {i}"
    
    release_signal(caravelEnv, "a", pcf, fabric_type)
    release_signal(caravelEnv, "b", pcf, fabric_type)
    release_signal(caravelEnv, "clk1", pcf, fabric_type)
    release_signal(caravelEnv, "rst", pcf, fabric_type)
    release_signal(caravelEnv, "ena", pcf, fabric_type)
    cocotb.log.info("TEST PASSED")
