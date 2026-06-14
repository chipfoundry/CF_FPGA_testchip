from caravel_cocotb.caravel_interfaces import test_configure
from caravel_cocotb.caravel_interfaces import report_test
import cocotb
from cocotb.triggers import ClockCycles
from pathlib import Path
import random
from common.common import get_fabric_handle, initialize_pads, force_power_signals, bitbang_clear_bitstream, parse_pcf, bitbang_upload_bitstream, set_signal, get_signal, release_signal, select_fabric, get_pcf_path, get_bitstream_path

@cocotb.test()
@report_test
async def passthrough(dut):
    caravelEnv = await test_configure(dut, timeout_cycles=5000000)
    cocotb.log.info("=" * 62)
    cocotb.log.info("OPENFRAME TESTCASE: passthrough (Small & Large Fabric)")
    cocotb.log.info("=" * 62)

    proj_root = Path(__file__).resolve().parent.parent.parent.parent.parent
    testname = "passthrough"

    initialize_pads(caravelEnv)
    
    for fabric_type in ["small", "large"]:
        cocotb.log.info(f"--- Testing passthrough on {fabric_type} fabric ---")
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

        num_bits = len(pcf["a"])
        for i in range(5):
            test_val = random.randint(0, (1 << num_bits) - 1)
            set_signal(caravelEnv, "a", test_val, pcf, fabric_type)
            await ClockCycles(caravelEnv.clk, 20)
            out_val = get_signal(caravelEnv, "b", pcf, fabric_type)
            cocotb.log.info(f"  passthrough[{i}]: in={test_val}, out={out_val}")
            assert out_val == test_val, f"passthrough FAIL at step {i}"
        
        release_signal(caravelEnv, "a", pcf, fabric_type)
    cocotb.log.info("TEST PASSED")
