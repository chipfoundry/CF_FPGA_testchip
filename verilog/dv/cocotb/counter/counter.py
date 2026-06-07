from caravel_cocotb.caravel_interfaces import test_configure
from caravel_cocotb.caravel_interfaces import report_test
import cocotb
from cocotb.triggers import ClockCycles
from pathlib import Path
from common.common import get_fabric_handle, initialize_pads, force_power_signals, bitbang_clear_bitstream, parse_pcf, bitbang_upload_bitstream, get_signal, set_signal, release_signal, select_fabric, get_pcf_path, get_bitstream_path, get_gpio

@cocotb.test()
@report_test
async def counter(dut):
    caravelEnv = await test_configure(dut, timeout_cycles=5000000)
    cocotb.log.info("=" * 62)
    cocotb.log.info("OPENFRAME TESTCASE: counter (Small Fabric)")
    cocotb.log.info("=" * 62)

    proj_root = Path(__file__).resolve().parent.parent.parent.parent.parent
    testname = "counter"

    initialize_pads(caravelEnv)
    
    for fabric_type in ["small", "large"]:
        cocotb.log.info(f"--- Testing counter on {fabric_type} fabric ---")
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

        # Note: These tiles match the generated constraints for small fabric counter.
        # Assert reset, deassert enable
        set_signal(caravelEnv, "rst", 1, pcf, fabric_type)
        set_signal(caravelEnv, "ena", 0, pcf, fabric_type)
        set_signal(caravelEnv, "clk1", 0, pcf, fabric_type)
        for _ in range(5):
            set_signal(caravelEnv, "clk1", 1, pcf, fabric_type)
            await ClockCycles(caravelEnv.clk, 5)
            set_signal(caravelEnv, "clk1", 0, pcf, fabric_type)
            await ClockCycles(caravelEnv.clk, 5)



        ctr = get_signal(caravelEnv, "c", pcf, fabric_type)
        cocotb.log.info(f"  counter after reset: {ctr} (expected 0)")
        assert ctr == 0, "counter reset FAIL"

        # Release reset, enable counting
        set_signal(caravelEnv, "rst", 0, pcf, fabric_type)
        set_signal(caravelEnv, "ena", 1, pcf, fabric_type)
        await ClockCycles(caravelEnv.clk, 10)

        for expected_val in range(1, 6):
            set_signal(caravelEnv, "clk1", 1, pcf, fabric_type)
            await ClockCycles(caravelEnv.clk, 5)
            set_signal(caravelEnv, "clk1", 0, pcf, fabric_type)
            await ClockCycles(caravelEnv.clk, 5)
            ctr = get_signal(caravelEnv, "c", pcf, fabric_type)
            cocotb.log.info(f"  counter step {expected_val}: {ctr}")
            assert ctr == expected_val, f"counter FAIL at step {expected_val}"

        release_signal(caravelEnv, "clk1", pcf, fabric_type)
        release_signal(caravelEnv, "ena", pcf, fabric_type)
        release_signal(caravelEnv, "rst", pcf, fabric_type)
    cocotb.log.info("TEST PASSED")
