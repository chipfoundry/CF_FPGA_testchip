from caravel_cocotb.caravel_interfaces import test_configure
from caravel_cocotb.caravel_interfaces import report_test
import cocotb
from cocotb.triggers import ClockCycles
from pathlib import Path
import random
from common.common import get_fabric_handle, parse_pcf, bitbang_clear_bitstream, bitbang_upload_bitstream, set_signal, get_signal, release_signal, select_fabric, get_pcf_path, get_bitstream_path, GPIO_CFG_DONE, initialize_pads, force_power_signals, log_all_tiles

@cocotb.test()
@report_test
async def addition(dut):
    caravelEnv = await test_configure(dut, timeout_cycles=5000000)
    cocotb.log.info("=" * 62)
    cocotb.log.info("OPENFRAME TESTCASE: addition (Small & Large Fabric)")
    cocotb.log.info("=" * 62)

    proj_root = Path(__file__).resolve().parent.parent.parent.parent.parent
    testname = "addition"

    initialize_pads(caravelEnv)
    
    for fabric_type in ["small", "large"]:
        cocotb.log.info(f"--- Testing {testname} on {fabric_type} fabric ---")
        
        fabric_handle = get_fabric_handle(caravelEnv, fabric_type)
        if fabric_handle is not None:
            force_power_signals(fabric_handle)
    
        cocotb.log.info("[STEP 1] Fabric Selection")
        await select_fabric(caravelEnv, fabric_type)
        cocotb.log.info(f"  Selected fabric: {fabric_type}")

        cocotb.log.info("[STEP 2] PCF File Analysis")
        pcf_path = get_pcf_path(proj_root, fabric_type, testname)
        bitstream_path = get_bitstream_path(proj_root, fabric_type, testname)
        pcf = parse_pcf(pcf_path)
        cocotb.log.info(f"  Total PCF signals: {len(pcf)}")

        cocotb.log.info("[STEP 3] Bitstream Upload")
        cocotb.log.info(f"  Bitstream path: {bitstream_path}")
        await bitbang_clear_bitstream(caravelEnv, fabric_type)
        await bitbang_upload_bitstream(caravelEnv, bitstream_path)
        
        cocotb.log.info("[STEP 4] Wait for Configuration Done")
        cfg_done_val = caravelEnv.monitor_gpio(GPIO_CFG_DONE)
        cocotb.log.info(f"  cfg_done right after upload: {cfg_done_val}")
        
        # Wait some cycles and check again
        await ClockCycles(caravelEnv.clk, 200)
        cfg_done_val = caravelEnv.monitor_gpio(GPIO_CFG_DONE)
        cocotb.log.info(f"  cfg_done after settling: {cfg_done_val}")
        
        if cfg_done_val == 0:
            cocotb.log.error("CONFIGURATION FAILED: cfg_done is still 0!")

        cocotb.log.info("[STEP 5] Drive Test Inputs")
        na = len(pcf["a"])
        nb = len(pcf["b"])
        for i in range(5):
            va = random.randint(0, (1 << na) - 1)
            vb = random.randint(0, (1 << nb) - 1)
            expected = va + vb
        
            cocotb.log.info(f"  Setting a = {va}, b = {vb}")
            set_signal(caravelEnv, "a", va, pcf, fabric_type)
            set_signal(caravelEnv, "b", vb, pcf, fabric_type)
        
            cocotb.log.info("[STEP 6] Wait for Combinatorial Settling")
            await ClockCycles(caravelEnv.clk, 100)
        
            log_all_tiles(caravelEnv, fabric_handle, fabric_type)

            result = get_signal(caravelEnv, "c", pcf, fabric_type)
            
            # Print detailed debug info for bits
            bin_a = bin(va)[2:].zfill(na)
            bin_b = bin(vb)[2:].zfill(nb)
            bin_res = bin(result)[2:].zfill(len(bin(expected)[2:]))
            bin_exp = bin(expected)[2:].zfill(len(bin(expected)[2:]))
            
            cocotb.log.info(f"  addition[{i}]: {va} + {vb} = {result} (expected {expected})")
            cocotb.log.info(f"    Binary inputs: a = {bin_a}, b = {bin_b}")
            cocotb.log.info(f"    Binary result: expected = {bin_exp}, actual = {bin_res}")
            
            if result != expected:
                cocotb.log.error("    MISMATCH DETECTED!")
                for bit_idx in range(len(bin_exp)):
                    actual_bit = bin_res[len(bin_res) - 1 - bit_idx] if bit_idx < len(bin_res) else '0'
                    exp_bit = bin_exp[len(bin_exp) - 1 - bit_idx]
                    if actual_bit != exp_bit:
                        cocotb.log.error(f"      -> Bit {bit_idx} mismatch! Expected {exp_bit}, got {actual_bit}")
            
            assert result == expected, f"addition FAIL at step {i}"
        
        release_signal(caravelEnv, "a", pcf, fabric_type)
        release_signal(caravelEnv, "b", pcf, fabric_type)
    cocotb.log.info("TEST PASSED")
