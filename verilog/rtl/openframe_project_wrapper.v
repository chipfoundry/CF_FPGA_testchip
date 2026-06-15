// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * openframe_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user openframe project.
 *
 * Written by Tim Edwards
 * March 27, 2023
 * Efabless Corporation
 *
 *-------------------------------------------------------------
 */

module openframe_project_wrapper (
`ifdef USE_POWER_PINS
    inout vdda,		// User area 0 3.3V supply
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa,		// User area 0 analog ground
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd,		// Common 1.8V supply
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd,		// Common digital ground
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
    inout vddio,	// Common 3.3V ESD supply
    inout vssio,	// Common ESD ground
`endif

    /* Signals exported from the frame area to the user project */
    /* The user may elect to use any of these inputs.		*/

    input	 porb_h,	// power-on reset, sense inverted, 3.3V domain
    input	 porb_l,	// power-on reset, sense inverted, 1.8V domain
    input	 por_l,		// power-on reset, noninverted, 1.8V domain
    input	 resetb_h,	// master reset, sense inverted, 3.3V domain
    input	 resetb_l,	// master reset, sense inverted, 1.8V domain
    input [31:0] mask_rev,	// 32-bit user ID, 1.8V domain

    /* GPIOs.  There are 44 GPIOs (19 left, 19 right, 6 bottom). */
    /* These must be configured appropriately by the user project. */

    /* Basic bidirectional I/O.  Input gpio_in_h is in the 3.3V domain;  all
     * others are in the 1.8v domain.  OEB is output enable, sense inverted.
     */
    input  [`OPENFRAME_IO_PADS-1:0] gpio_in,
    input  [`OPENFRAME_IO_PADS-1:0] gpio_in_h,
    output [`OPENFRAME_IO_PADS-1:0] gpio_out,
    output [`OPENFRAME_IO_PADS-1:0] gpio_oeb,
    output [`OPENFRAME_IO_PADS-1:0] gpio_inp_dis,	// a.k.a. ieb

    /* Pad configuration.  These signals are usually static values.
     * See the documentation for the sky130_fd_io__gpiov2 cell signals
     * and their use.
     */
    output [`OPENFRAME_IO_PADS-1:0] gpio_ib_mode_sel,
    output [`OPENFRAME_IO_PADS-1:0] gpio_vtrip_sel,
    output [`OPENFRAME_IO_PADS-1:0] gpio_slow_sel,
    output [`OPENFRAME_IO_PADS-1:0] gpio_holdover,
    output [`OPENFRAME_IO_PADS-1:0] gpio_analog_en,
    output [`OPENFRAME_IO_PADS-1:0] gpio_analog_sel,
    output [`OPENFRAME_IO_PADS-1:0] gpio_analog_pol,
    output [`OPENFRAME_IO_PADS-1:0] gpio_dm2,
    output [`OPENFRAME_IO_PADS-1:0] gpio_dm1,
    output [`OPENFRAME_IO_PADS-1:0] gpio_dm0,

    /* These signals correct directly to the pad.  Pads using analog I/O
     * connections should keep the digital input and output buffers turned
     * off.  Both signals connect to the same pad.  The "noesd" signal
     * is a direct connection to the pad;  the other signal connects through
     * a series resistor which gives it minimal ESD protection.  Both signals
     * have basic over- and under-voltage protection at the pad.  These
     * signals may be expected to attenuate heavily above 50MHz.
     */
    inout  [`OPENFRAME_IO_PADS-1:0] analog_io,
    inout  [`OPENFRAME_IO_PADS-1:0] analog_noesd_io,

    /* These signals are constant one and zero in the 1.8V domain, one for
     * each GPIO pad, and can be looped back to the control signals on the
     * same GPIO pad to set a static configuration at power-up.
     */
    input  [`OPENFRAME_IO_PADS-1:0] gpio_loopback_one,
    input  [`OPENFRAME_IO_PADS-1:0] gpio_loopback_zero
);
        // Internal wires
        wire spi_csn, spi_sclk, spi_mosi;
        (* keep *) wire spi_miso;
        wire cfg_done, config_busy;
        wire spi_sclk_o, spi_sclk_en_o, spi_cs_n_o, spi_cs_n_en_o;
        wire spi_mosi_o, spi_mosi_en_o, spi_miso_o, spi_miso_en_o;
        wire [35:0] bidir_in, bidir_out, bidir_oe;
        wire [1:0] fpga_select;  // Routed from GPIO 25-26

        // CF_owire_id_shared wires (1-Wire chip-ID on GPIO[0])
        wire owire_user_in;
        wire owire_ip_busy;

        chip_core #(.NUM_BIDIR_PADS(36)) u_chip_core (
            .clk_i(gpio_in[38]),     // Connected directly to input
            .rst_ni(resetb_l),
            .spi_mode_i(1'b1),           // Passive SPI receiver
            .fpga_select_i(fpga_select), // Dynamic select via GPIO 25-26
            .spi_sclk_i(spi_sclk), 
            .spi_sclk_o(spi_sclk_o), 
            .spi_sclk_en_o(spi_sclk_en_o),
            .spi_cs_n_i(spi_csn), 
            .spi_cs_n_o(spi_cs_n_o), 
            .spi_cs_n_en_o(spi_cs_n_en_o),
            .spi_mosi_i(spi_mosi), 
            .spi_mosi_o(spi_mosi_o), 
            .spi_mosi_en_o(spi_mosi_en_o),
            .spi_miso_i(1'b0), 
            .spi_miso_o(spi_miso), 
            .spi_miso_en_o(spi_miso_en_o),
            .config_busy_o(config_busy), 
            .config_done_o(cfg_done),
            .bidir_in(bidir_in), 
            .bidir_out(bidir_out), 
            .bidir_oe(bidir_oe)
        );

	(* keep *) vccd1_connection vccd1_connection ();
	(* keep *) vssd1_connection vssd1_connection ();

        // CF_gpio_config modes
        // GPIO 0: CF_owire_id_shared (1-Wire chip-ID + fabric bidir[0] open-drain sharing)
        // Fabric pulls low when actively driving a 0; reads wire level via owire_user_in.
        // GPIO 0: CF_owire_id_pad (1-Wire chip-ID dedicated pad)

        CF_owire_id_shared #(
            .FAMILY_CODE        (8'hCF),
            .SERIAL_HIGH        (16'hCF1D)
        ) u_owire (
            .rst_n              (resetb_l),
            .mask_rev           (mask_rev),
            .user_pull_low      (bidir_oe[0] & ~bidir_out[0]),
            .user_in            (owire_user_in),
            .ip_busy            (owire_ip_busy),
            .gpio_in_pin        (gpio_in[0]),
            .gpio_out_pin       (gpio_out[0]),
            .gpio_oeb_pin       (gpio_oeb[0]),
            .gpio_inp_dis_pin   (gpio_inp_dis[0]),
            .gpio_dm2_pin       (gpio_dm2[0]),
            .gpio_dm1_pin       (gpio_dm1[0]),
            .gpio_dm0_pin       (gpio_dm0[0]),
            .gpio_analog_en_pin (gpio_analog_en[0]),
            .gpio_analog_sel_pin(gpio_analog_sel[0]),
            .gpio_analog_pol_pin(gpio_analog_pol[0]),
            .gpio_ib_mode_sel_pin(gpio_ib_mode_sel[0]),
            .gpio_vtrip_sel_pin (gpio_vtrip_sel[0]),
            .gpio_slow_sel_pin  (gpio_slow_sel[0]),
            .gpio_holdover_pin  (gpio_holdover[0])
        );

        // Feed wire level back to fabric bidir[0] input
        assign bidir_in[0] = owire_user_in;
        //  assign bidir_in[0] = gpio_in[0];
        
        // GPIO 1: bidir[1] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_1_config (
          .io_out(bidir_out[1]), .io_in(bidir_in[1]), .io_oeb(~bidir_oe[1]),
          .gpio_zero(gpio_loopback_zero[1]), .gpio_one(gpio_loopback_one[1]),
          .gpio_in(gpio_in[1]), .gpio_dm({gpio_dm2[1], gpio_dm1[1], gpio_dm0[1]}),
          .gpio_inp_dis(gpio_inp_dis[1]), .gpio_oeb_out(gpio_oeb[1]), .gpio_out_val(gpio_out[1]),
          .gpio_analog_en(gpio_analog_en[1]), .gpio_analog_sel(gpio_analog_sel[1]),
          .gpio_analog_pol(gpio_analog_pol[1]), .gpio_ib_mode_sel(gpio_ib_mode_sel[1]),
          .gpio_vtrip_sel(gpio_vtrip_sel[1]), .gpio_slow_sel(gpio_slow_sel[1]),
          .gpio_holdover(gpio_holdover[1])
        );

        // GPIO 2: bidir[2] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_2_config (
          .io_out(bidir_out[2]), .io_in(bidir_in[2]), .io_oeb(~bidir_oe[2]),
          .gpio_zero(gpio_loopback_zero[2]), .gpio_one(gpio_loopback_one[2]),
          .gpio_in(gpio_in[2]), .gpio_dm({gpio_dm2[2], gpio_dm1[2], gpio_dm0[2]}),
          .gpio_inp_dis(gpio_inp_dis[2]), .gpio_oeb_out(gpio_oeb[2]), .gpio_out_val(gpio_out[2]),
          .gpio_analog_en(gpio_analog_en[2]), .gpio_analog_sel(gpio_analog_sel[2]),
          .gpio_analog_pol(gpio_analog_pol[2]), .gpio_ib_mode_sel(gpio_ib_mode_sel[2]),
          .gpio_vtrip_sel(gpio_vtrip_sel[2]), .gpio_slow_sel(gpio_slow_sel[2]),
          .gpio_holdover(gpio_holdover[2])
        );

        // GPIO 3: bidir[3] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_3_config (
          .io_out(bidir_out[3]), .io_in(bidir_in[3]), .io_oeb(~bidir_oe[3]),
          .gpio_zero(gpio_loopback_zero[3]), .gpio_one(gpio_loopback_one[3]),
          .gpio_in(gpio_in[3]), .gpio_dm({gpio_dm2[3], gpio_dm1[3], gpio_dm0[3]}),
          .gpio_inp_dis(gpio_inp_dis[3]), .gpio_oeb_out(gpio_oeb[3]), .gpio_out_val(gpio_out[3]),
          .gpio_analog_en(gpio_analog_en[3]), .gpio_analog_sel(gpio_analog_sel[3]),
          .gpio_analog_pol(gpio_analog_pol[3]), .gpio_ib_mode_sel(gpio_ib_mode_sel[3]),
          .gpio_vtrip_sel(gpio_vtrip_sel[3]), .gpio_slow_sel(gpio_slow_sel[3]),
          .gpio_holdover(gpio_holdover[3])
        );

        // GPIO 4: bidir[4] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_4_config (
          .io_out(bidir_out[4]), .io_in(bidir_in[4]), .io_oeb(~bidir_oe[4]),
          .gpio_zero(gpio_loopback_zero[4]), .gpio_one(gpio_loopback_one[4]),
          .gpio_in(gpio_in[4]), .gpio_dm({gpio_dm2[4], gpio_dm1[4], gpio_dm0[4]}),
          .gpio_inp_dis(gpio_inp_dis[4]), .gpio_oeb_out(gpio_oeb[4]), .gpio_out_val(gpio_out[4]),
          .gpio_analog_en(gpio_analog_en[4]), .gpio_analog_sel(gpio_analog_sel[4]),
          .gpio_analog_pol(gpio_analog_pol[4]), .gpio_ib_mode_sel(gpio_ib_mode_sel[4]),
          .gpio_vtrip_sel(gpio_vtrip_sel[4]), .gpio_slow_sel(gpio_slow_sel[4]),
          .gpio_holdover(gpio_holdover[4])
        );

        // GPIO 5: bidir[5] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_5_config (
          .io_out(bidir_out[5]), .io_in(bidir_in[5]), .io_oeb(~bidir_oe[5]),
          .gpio_zero(gpio_loopback_zero[5]), .gpio_one(gpio_loopback_one[5]),
          .gpio_in(gpio_in[5]), .gpio_dm({gpio_dm2[5], gpio_dm1[5], gpio_dm0[5]}),
          .gpio_inp_dis(gpio_inp_dis[5]), .gpio_oeb_out(gpio_oeb[5]), .gpio_out_val(gpio_out[5]),
          .gpio_analog_en(gpio_analog_en[5]), .gpio_analog_sel(gpio_analog_sel[5]),
          .gpio_analog_pol(gpio_analog_pol[5]), .gpio_ib_mode_sel(gpio_ib_mode_sel[5]),
          .gpio_vtrip_sel(gpio_vtrip_sel[5]), .gpio_slow_sel(gpio_slow_sel[5]),
          .gpio_holdover(gpio_holdover[5])
        );

        // GPIO 6: bidir[6] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_6_config (
          .io_out(bidir_out[6]), .io_in(bidir_in[6]), .io_oeb(~bidir_oe[6]),
          .gpio_zero(gpio_loopback_zero[6]), .gpio_one(gpio_loopback_one[6]),
          .gpio_in(gpio_in[6]), .gpio_dm({gpio_dm2[6], gpio_dm1[6], gpio_dm0[6]}),
          .gpio_inp_dis(gpio_inp_dis[6]), .gpio_oeb_out(gpio_oeb[6]), .gpio_out_val(gpio_out[6]),
          .gpio_analog_en(gpio_analog_en[6]), .gpio_analog_sel(gpio_analog_sel[6]),
          .gpio_analog_pol(gpio_analog_pol[6]), .gpio_ib_mode_sel(gpio_ib_mode_sel[6]),
          .gpio_vtrip_sel(gpio_vtrip_sel[6]), .gpio_slow_sel(gpio_slow_sel[6]),
          .gpio_holdover(gpio_holdover[6])
        );

        // GPIO 7: bidir[7] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_7_config (
          .io_out(bidir_out[7]), .io_in(bidir_in[7]), .io_oeb(~bidir_oe[7]),
          .gpio_zero(gpio_loopback_zero[7]), .gpio_one(gpio_loopback_one[7]),
          .gpio_in(gpio_in[7]), .gpio_dm({gpio_dm2[7], gpio_dm1[7], gpio_dm0[7]}),
          .gpio_inp_dis(gpio_inp_dis[7]), .gpio_oeb_out(gpio_oeb[7]), .gpio_out_val(gpio_out[7]),
          .gpio_analog_en(gpio_analog_en[7]), .gpio_analog_sel(gpio_analog_sel[7]),
          .gpio_analog_pol(gpio_analog_pol[7]), .gpio_ib_mode_sel(gpio_ib_mode_sel[7]),
          .gpio_vtrip_sel(gpio_vtrip_sel[7]), .gpio_slow_sel(gpio_slow_sel[7]),
          .gpio_holdover(gpio_holdover[7])
        );

        // GPIO 8: bidir[8] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_8_config (
          .io_out(bidir_out[8]), .io_in(bidir_in[8]), .io_oeb(~bidir_oe[8]),
          .gpio_zero(gpio_loopback_zero[8]), .gpio_one(gpio_loopback_one[8]),
          .gpio_in(gpio_in[8]), .gpio_dm({gpio_dm2[8], gpio_dm1[8], gpio_dm0[8]}),
          .gpio_inp_dis(gpio_inp_dis[8]), .gpio_oeb_out(gpio_oeb[8]), .gpio_out_val(gpio_out[8]),
          .gpio_analog_en(gpio_analog_en[8]), .gpio_analog_sel(gpio_analog_sel[8]),
          .gpio_analog_pol(gpio_analog_pol[8]), .gpio_ib_mode_sel(gpio_ib_mode_sel[8]),
          .gpio_vtrip_sel(gpio_vtrip_sel[8]), .gpio_slow_sel(gpio_slow_sel[8]),
          .gpio_holdover(gpio_holdover[8])
        );

        // GPIO 9: bidir[9] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_9_config (
          .io_out(bidir_out[9]), .io_in(bidir_in[9]), .io_oeb(~bidir_oe[9]),
          .gpio_zero(gpio_loopback_zero[9]), .gpio_one(gpio_loopback_one[9]),
          .gpio_in(gpio_in[9]), .gpio_dm({gpio_dm2[9], gpio_dm1[9], gpio_dm0[9]}),
          .gpio_inp_dis(gpio_inp_dis[9]), .gpio_oeb_out(gpio_oeb[9]), .gpio_out_val(gpio_out[9]),
          .gpio_analog_en(gpio_analog_en[9]), .gpio_analog_sel(gpio_analog_sel[9]),
          .gpio_analog_pol(gpio_analog_pol[9]), .gpio_ib_mode_sel(gpio_ib_mode_sel[9]),
          .gpio_vtrip_sel(gpio_vtrip_sel[9]), .gpio_slow_sel(gpio_slow_sel[9]),
          .gpio_holdover(gpio_holdover[9])
        );

        // GPIO 10: bidir[10] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_10_config (
          .io_out(bidir_out[10]), .io_in(bidir_in[10]), .io_oeb(~bidir_oe[10]),
          .gpio_zero(gpio_loopback_zero[10]), .gpio_one(gpio_loopback_one[10]),
          .gpio_in(gpio_in[10]), .gpio_dm({gpio_dm2[10], gpio_dm1[10], gpio_dm0[10]}),
          .gpio_inp_dis(gpio_inp_dis[10]), .gpio_oeb_out(gpio_oeb[10]), .gpio_out_val(gpio_out[10]),
          .gpio_analog_en(gpio_analog_en[10]), .gpio_analog_sel(gpio_analog_sel[10]),
          .gpio_analog_pol(gpio_analog_pol[10]), .gpio_ib_mode_sel(gpio_ib_mode_sel[10]),
          .gpio_vtrip_sel(gpio_vtrip_sel[10]), .gpio_slow_sel(gpio_slow_sel[10]),
          .gpio_holdover(gpio_holdover[10])
        );

        // GPIO 11: bidir[11] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_11_config (
          .io_out(bidir_out[11]), .io_in(bidir_in[11]), .io_oeb(~bidir_oe[11]),
          .gpio_zero(gpio_loopback_zero[11]), .gpio_one(gpio_loopback_one[11]),
          .gpio_in(gpio_in[11]), .gpio_dm({gpio_dm2[11], gpio_dm1[11], gpio_dm0[11]}),
          .gpio_inp_dis(gpio_inp_dis[11]), .gpio_oeb_out(gpio_oeb[11]), .gpio_out_val(gpio_out[11]),
          .gpio_analog_en(gpio_analog_en[11]), .gpio_analog_sel(gpio_analog_sel[11]),
          .gpio_analog_pol(gpio_analog_pol[11]), .gpio_ib_mode_sel(gpio_ib_mode_sel[11]),
          .gpio_vtrip_sel(gpio_vtrip_sel[11]), .gpio_slow_sel(gpio_slow_sel[11]),
          .gpio_holdover(gpio_holdover[11])
        );

        // GPIO 12: bidir[12] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_12_config (
          .io_out(bidir_out[12]), .io_in(bidir_in[12]), .io_oeb(~bidir_oe[12]),
          .gpio_zero(gpio_loopback_zero[12]), .gpio_one(gpio_loopback_one[12]),
          .gpio_in(gpio_in[12]), .gpio_dm({gpio_dm2[12], gpio_dm1[12], gpio_dm0[12]}),
          .gpio_inp_dis(gpio_inp_dis[12]), .gpio_oeb_out(gpio_oeb[12]), .gpio_out_val(gpio_out[12]),
          .gpio_analog_en(gpio_analog_en[12]), .gpio_analog_sel(gpio_analog_sel[12]),
          .gpio_analog_pol(gpio_analog_pol[12]), .gpio_ib_mode_sel(gpio_ib_mode_sel[12]),
          .gpio_vtrip_sel(gpio_vtrip_sel[12]), .gpio_slow_sel(gpio_slow_sel[12]),
          .gpio_holdover(gpio_holdover[12])
        );

        // GPIO 13: bidir[13] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_13_config (
          .io_out(bidir_out[13]), .io_in(bidir_in[13]), .io_oeb(~bidir_oe[13]),
          .gpio_zero(gpio_loopback_zero[13]), .gpio_one(gpio_loopback_one[13]),
          .gpio_in(gpio_in[13]), .gpio_dm({gpio_dm2[13], gpio_dm1[13], gpio_dm0[13]}),
          .gpio_inp_dis(gpio_inp_dis[13]), .gpio_oeb_out(gpio_oeb[13]), .gpio_out_val(gpio_out[13]),
          .gpio_analog_en(gpio_analog_en[13]), .gpio_analog_sel(gpio_analog_sel[13]),
          .gpio_analog_pol(gpio_analog_pol[13]), .gpio_ib_mode_sel(gpio_ib_mode_sel[13]),
          .gpio_vtrip_sel(gpio_vtrip_sel[13]), .gpio_slow_sel(gpio_slow_sel[13]),
          .gpio_holdover(gpio_holdover[13])
        );

        // GPIO 14: cfg_done (Mode 4: output)
        CF_gpio_config #(.MODE(3'd4)) gpio_14_config (
          .io_out(cfg_done), .io_in(), .io_oeb(1'b0),
          .gpio_zero(gpio_loopback_zero[14]), .gpio_one(gpio_loopback_one[14]),
          .gpio_in(gpio_in[14]), .gpio_dm({gpio_dm2[14], gpio_dm1[14], gpio_dm0[14]}),
          .gpio_inp_dis(gpio_inp_dis[14]), .gpio_oeb_out(gpio_oeb[14]), .gpio_out_val(gpio_out[14]),
          .gpio_analog_en(gpio_analog_en[14]), .gpio_analog_sel(gpio_analog_sel[14]),
          .gpio_analog_pol(gpio_analog_pol[14]), .gpio_ib_mode_sel(gpio_ib_mode_sel[14]),
          .gpio_vtrip_sel(gpio_vtrip_sel[14]), .gpio_slow_sel(gpio_slow_sel[14]),
          .gpio_holdover(gpio_holdover[14])
        );

        // GPIO 15: bidir[14] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_15_config (
          .io_out(bidir_out[14]), .io_in(bidir_in[14]), .io_oeb(~bidir_oe[14]),
          .gpio_zero(gpio_loopback_zero[15]), .gpio_one(gpio_loopback_one[15]),
          .gpio_in(gpio_in[15]), .gpio_dm({gpio_dm2[15], gpio_dm1[15], gpio_dm0[15]}),
          .gpio_inp_dis(gpio_inp_dis[15]), .gpio_oeb_out(gpio_oeb[15]), .gpio_out_val(gpio_out[15]),
          .gpio_analog_en(gpio_analog_en[15]), .gpio_analog_sel(gpio_analog_sel[15]),
          .gpio_analog_pol(gpio_analog_pol[15]), .gpio_ib_mode_sel(gpio_ib_mode_sel[15]),
          .gpio_vtrip_sel(gpio_vtrip_sel[15]), .gpio_slow_sel(gpio_slow_sel[15]),
          .gpio_holdover(gpio_holdover[15])
        );

        // GPIO 16: bidir[15] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_16_config (
          .io_out(bidir_out[15]), .io_in(bidir_in[15]), .io_oeb(~bidir_oe[15]),
          .gpio_zero(gpio_loopback_zero[16]), .gpio_one(gpio_loopback_one[16]),
          .gpio_in(gpio_in[16]), .gpio_dm({gpio_dm2[16], gpio_dm1[16], gpio_dm0[16]}),
          .gpio_inp_dis(gpio_inp_dis[16]), .gpio_oeb_out(gpio_oeb[16]), .gpio_out_val(gpio_out[16]),
          .gpio_analog_en(gpio_analog_en[16]), .gpio_analog_sel(gpio_analog_sel[16]),
          .gpio_analog_pol(gpio_analog_pol[16]), .gpio_ib_mode_sel(gpio_ib_mode_sel[16]),
          .gpio_vtrip_sel(gpio_vtrip_sel[16]), .gpio_slow_sel(gpio_slow_sel[16]),
          .gpio_holdover(gpio_holdover[16])
        );

        // GPIO 17: bidir[16] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_17_config (
          .io_out(bidir_out[16]), .io_in(bidir_in[16]), .io_oeb(~bidir_oe[16]),
          .gpio_zero(gpio_loopback_zero[17]), .gpio_one(gpio_loopback_one[17]),
          .gpio_in(gpio_in[17]), .gpio_dm({gpio_dm2[17], gpio_dm1[17], gpio_dm0[17]}),
          .gpio_inp_dis(gpio_inp_dis[17]), .gpio_oeb_out(gpio_oeb[17]), .gpio_out_val(gpio_out[17]),
          .gpio_analog_en(gpio_analog_en[17]), .gpio_analog_sel(gpio_analog_sel[17]),
          .gpio_analog_pol(gpio_analog_pol[17]), .gpio_ib_mode_sel(gpio_ib_mode_sel[17]),
          .gpio_vtrip_sel(gpio_vtrip_sel[17]), .gpio_slow_sel(gpio_slow_sel[17]),
          .gpio_holdover(gpio_holdover[17])
        );

        // GPIO 18: bidir[17] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_18_config (
          .io_out(bidir_out[17]), .io_in(bidir_in[17]), .io_oeb(~bidir_oe[17]),
          .gpio_zero(gpio_loopback_zero[18]), .gpio_one(gpio_loopback_one[18]),
          .gpio_in(gpio_in[18]), .gpio_dm({gpio_dm2[18], gpio_dm1[18], gpio_dm0[18]}),
          .gpio_inp_dis(gpio_inp_dis[18]), .gpio_oeb_out(gpio_oeb[18]), .gpio_out_val(gpio_out[18]),
          .gpio_analog_en(gpio_analog_en[18]), .gpio_analog_sel(gpio_analog_sel[18]),
          .gpio_analog_pol(gpio_analog_pol[18]), .gpio_ib_mode_sel(gpio_ib_mode_sel[18]),
          .gpio_vtrip_sel(gpio_vtrip_sel[18]), .gpio_slow_sel(gpio_slow_sel[18]),
          .gpio_holdover(gpio_holdover[18])
        );

        // GPIO 19: bidir[18] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_19_config (
          .io_out(bidir_out[18]), .io_in(bidir_in[18]), .io_oeb(~bidir_oe[18]),
          .gpio_zero(gpio_loopback_zero[19]), .gpio_one(gpio_loopback_one[19]),
          .gpio_in(gpio_in[19]), .gpio_dm({gpio_dm2[19], gpio_dm1[19], gpio_dm0[19]}),
          .gpio_inp_dis(gpio_inp_dis[19]), .gpio_oeb_out(gpio_oeb[19]), .gpio_out_val(gpio_out[19]),
          .gpio_analog_en(gpio_analog_en[19]), .gpio_analog_sel(gpio_analog_sel[19]),
          .gpio_analog_pol(gpio_analog_pol[19]), .gpio_ib_mode_sel(gpio_ib_mode_sel[19]),
          .gpio_vtrip_sel(gpio_vtrip_sel[19]), .gpio_slow_sel(gpio_slow_sel[19]),
          .gpio_holdover(gpio_holdover[19])
        );

        // GPIO 20: bidir[19] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_20_config (
          .io_out(bidir_out[19]), .io_in(bidir_in[19]), .io_oeb(~bidir_oe[19]),
          .gpio_zero(gpio_loopback_zero[20]), .gpio_one(gpio_loopback_one[20]),
          .gpio_in(gpio_in[20]), .gpio_dm({gpio_dm2[20], gpio_dm1[20], gpio_dm0[20]}),
          .gpio_inp_dis(gpio_inp_dis[20]), .gpio_oeb_out(gpio_oeb[20]), .gpio_out_val(gpio_out[20]),
          .gpio_analog_en(gpio_analog_en[20]), .gpio_analog_sel(gpio_analog_sel[20]),
          .gpio_analog_pol(gpio_analog_pol[20]), .gpio_ib_mode_sel(gpio_ib_mode_sel[20]),
          .gpio_vtrip_sel(gpio_vtrip_sel[20]), .gpio_slow_sel(gpio_slow_sel[20]),
          .gpio_holdover(gpio_holdover[20])
        );

        // GPIO 21: bidir[20] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_21_config (
          .io_out(bidir_out[20]), .io_in(bidir_in[20]), .io_oeb(~bidir_oe[20]),
          .gpio_zero(gpio_loopback_zero[21]), .gpio_one(gpio_loopback_one[21]),
          .gpio_in(gpio_in[21]), .gpio_dm({gpio_dm2[21], gpio_dm1[21], gpio_dm0[21]}),
          .gpio_inp_dis(gpio_inp_dis[21]), .gpio_oeb_out(gpio_oeb[21]), .gpio_out_val(gpio_out[21]),
          .gpio_analog_en(gpio_analog_en[21]), .gpio_analog_sel(gpio_analog_sel[21]),
          .gpio_analog_pol(gpio_analog_pol[21]), .gpio_ib_mode_sel(gpio_ib_mode_sel[21]),
          .gpio_vtrip_sel(gpio_vtrip_sel[21]), .gpio_slow_sel(gpio_slow_sel[21]),
          .gpio_holdover(gpio_holdover[21])
        );

        // GPIO 22: bidir[21] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_22_config (
          .io_out(bidir_out[21]), .io_in(bidir_in[21]), .io_oeb(~bidir_oe[21]),
          .gpio_zero(gpio_loopback_zero[22]), .gpio_one(gpio_loopback_one[22]),
          .gpio_in(gpio_in[22]), .gpio_dm({gpio_dm2[22], gpio_dm1[22], gpio_dm0[22]}),
          .gpio_inp_dis(gpio_inp_dis[22]), .gpio_oeb_out(gpio_oeb[22]), .gpio_out_val(gpio_out[22]),
          .gpio_analog_en(gpio_analog_en[22]), .gpio_analog_sel(gpio_analog_sel[22]),
          .gpio_analog_pol(gpio_analog_pol[22]), .gpio_ib_mode_sel(gpio_ib_mode_sel[22]),
          .gpio_vtrip_sel(gpio_vtrip_sel[22]), .gpio_slow_sel(gpio_slow_sel[22]),
          .gpio_holdover(gpio_holdover[22])
        );

        // GPIO 23: bidir[22] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_23_config (
          .io_out(bidir_out[22]), .io_in(bidir_in[22]), .io_oeb(~bidir_oe[22]),
          .gpio_zero(gpio_loopback_zero[23]), .gpio_one(gpio_loopback_one[23]),
          .gpio_in(gpio_in[23]), .gpio_dm({gpio_dm2[23], gpio_dm1[23], gpio_dm0[23]}),
          .gpio_inp_dis(gpio_inp_dis[23]), .gpio_oeb_out(gpio_oeb[23]), .gpio_out_val(gpio_out[23]),
          .gpio_analog_en(gpio_analog_en[23]), .gpio_analog_sel(gpio_analog_sel[23]),
          .gpio_analog_pol(gpio_analog_pol[23]), .gpio_ib_mode_sel(gpio_ib_mode_sel[23]),
          .gpio_vtrip_sel(gpio_vtrip_sel[23]), .gpio_slow_sel(gpio_slow_sel[23]),
          .gpio_holdover(gpio_holdover[23])
        );

        // GPIO 24: bidir[23] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_24_config (
          .io_out(bidir_out[23]), .io_in(bidir_in[23]), .io_oeb(~bidir_oe[23]),
          .gpio_zero(gpio_loopback_zero[24]), .gpio_one(gpio_loopback_one[24]),
          .gpio_in(gpio_in[24]), .gpio_dm({gpio_dm2[24], gpio_dm1[24], gpio_dm0[24]}),
          .gpio_inp_dis(gpio_inp_dis[24]), .gpio_oeb_out(gpio_oeb[24]), .gpio_out_val(gpio_out[24]),
          .gpio_analog_en(gpio_analog_en[24]), .gpio_analog_sel(gpio_analog_sel[24]),
          .gpio_analog_pol(gpio_analog_pol[24]), .gpio_ib_mode_sel(gpio_ib_mode_sel[24]),
          .gpio_vtrip_sel(gpio_vtrip_sel[24]), .gpio_slow_sel(gpio_slow_sel[24]),
          .gpio_holdover(gpio_holdover[24])
        );

        // GPIO 25: fpga_select[0] (Mode 1: input)
        CF_gpio_config #(.MODE(3'd1)) gpio_25_config (
          .io_out(), .io_in(fpga_select[0]), .io_oeb(),
          .gpio_zero(gpio_loopback_zero[25]), .gpio_one(gpio_loopback_one[25]),
          .gpio_in(gpio_in[25]), .gpio_dm({gpio_dm2[25], gpio_dm1[25], gpio_dm0[25]}),
          .gpio_inp_dis(gpio_inp_dis[25]), .gpio_oeb_out(gpio_oeb[25]), .gpio_out_val(gpio_out[25]),
          .gpio_analog_en(gpio_analog_en[25]), .gpio_analog_sel(gpio_analog_sel[25]),
          .gpio_analog_pol(gpio_analog_pol[25]), .gpio_ib_mode_sel(gpio_ib_mode_sel[25]),
          .gpio_vtrip_sel(gpio_vtrip_sel[25]), .gpio_slow_sel(gpio_slow_sel[25]),
          .gpio_holdover(gpio_holdover[25])
        );

        // GPIO 26: fpga_select[1] (Mode 1: input)
        CF_gpio_config #(.MODE(3'd1)) gpio_26_config (
          .io_out(), .io_in(fpga_select[1]), .io_oeb(),
          .gpio_zero(gpio_loopback_zero[26]), .gpio_one(gpio_loopback_one[26]),
          .gpio_in(gpio_in[26]), .gpio_dm({gpio_dm2[26], gpio_dm1[26], gpio_dm0[26]}),
          .gpio_inp_dis(gpio_inp_dis[26]), .gpio_oeb_out(gpio_oeb[26]), .gpio_out_val(gpio_out[26]),
          .gpio_analog_en(gpio_analog_en[26]), .gpio_analog_sel(gpio_analog_sel[26]),
          .gpio_analog_pol(gpio_analog_pol[26]), .gpio_ib_mode_sel(gpio_ib_mode_sel[26]),
          .gpio_vtrip_sel(gpio_vtrip_sel[26]), .gpio_slow_sel(gpio_slow_sel[26]),
          .gpio_holdover(gpio_holdover[26])
        );

        // GPIO 27: bidir[24] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_27_config (
          .io_out(bidir_out[24]), .io_in(bidir_in[24]), .io_oeb(~bidir_oe[24]),
          .gpio_zero(gpio_loopback_zero[27]), .gpio_one(gpio_loopback_one[27]),
          .gpio_in(gpio_in[27]), .gpio_dm({gpio_dm2[27], gpio_dm1[27], gpio_dm0[27]}),
          .gpio_inp_dis(gpio_inp_dis[27]), .gpio_oeb_out(gpio_oeb[27]), .gpio_out_val(gpio_out[27]),
          .gpio_analog_en(gpio_analog_en[27]), .gpio_analog_sel(gpio_analog_sel[27]),
          .gpio_analog_pol(gpio_analog_pol[27]), .gpio_ib_mode_sel(gpio_ib_mode_sel[27]),
          .gpio_vtrip_sel(gpio_vtrip_sel[27]), .gpio_slow_sel(gpio_slow_sel[27]),
          .gpio_holdover(gpio_holdover[27])
        );

        // GPIO 28: bidir[25] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_28_config (
          .io_out(bidir_out[25]), .io_in(bidir_in[25]), .io_oeb(~bidir_oe[25]),
          .gpio_zero(gpio_loopback_zero[28]), .gpio_one(gpio_loopback_one[28]),
          .gpio_in(gpio_in[28]), .gpio_dm({gpio_dm2[28], gpio_dm1[28], gpio_dm0[28]}),
          .gpio_inp_dis(gpio_inp_dis[28]), .gpio_oeb_out(gpio_oeb[28]), .gpio_out_val(gpio_out[28]),
          .gpio_analog_en(gpio_analog_en[28]), .gpio_analog_sel(gpio_analog_sel[28]),
          .gpio_analog_pol(gpio_analog_pol[28]), .gpio_ib_mode_sel(gpio_ib_mode_sel[28]),
          .gpio_vtrip_sel(gpio_vtrip_sel[28]), .gpio_slow_sel(gpio_slow_sel[28]),
          .gpio_holdover(gpio_holdover[28])
        );

        // GPIO 29: spi_miso (Mode 4: output)
        CF_gpio_config #(.MODE(3'd4)) gpio_29_config (
          .io_out(spi_miso), .io_in(), .io_oeb(1'b0),
          .gpio_zero(gpio_loopback_zero[29]), .gpio_one(gpio_loopback_one[29]),
          .gpio_in(gpio_in[29]), .gpio_dm({gpio_dm2[29], gpio_dm1[29], gpio_dm0[29]}),
          .gpio_inp_dis(gpio_inp_dis[29]), .gpio_oeb_out(gpio_oeb[29]), .gpio_out_val(gpio_out[29]),
          .gpio_analog_en(gpio_analog_en[29]), .gpio_analog_sel(gpio_analog_sel[29]),
          .gpio_analog_pol(gpio_analog_pol[29]), .gpio_ib_mode_sel(gpio_ib_mode_sel[29]),
          .gpio_vtrip_sel(gpio_vtrip_sel[29]), .gpio_slow_sel(gpio_slow_sel[29]),
          .gpio_holdover(gpio_holdover[29])
        );

        // GPIO 30: spi_mosi (Mode 1: input)
        CF_gpio_config #(.MODE(3'd1)) gpio_30_config (
          .io_out(), .io_in(spi_mosi), .io_oeb(),
          .gpio_zero(gpio_loopback_zero[30]), .gpio_one(gpio_loopback_one[30]),
          .gpio_in(gpio_in[30]), .gpio_dm({gpio_dm2[30], gpio_dm1[30], gpio_dm0[30]}),
          .gpio_inp_dis(gpio_inp_dis[30]), .gpio_oeb_out(gpio_oeb[30]), .gpio_out_val(gpio_out[30]),
          .gpio_analog_en(gpio_analog_en[30]), .gpio_analog_sel(gpio_analog_sel[30]),
          .gpio_analog_pol(gpio_analog_pol[30]), .gpio_ib_mode_sel(gpio_ib_mode_sel[30]),
          .gpio_vtrip_sel(gpio_vtrip_sel[30]), .gpio_slow_sel(gpio_slow_sel[30]),
          .gpio_holdover(gpio_holdover[30])
        );

        // GPIO 31: spi_csn (Mode 3: input pull-up)
        CF_gpio_config #(.MODE(3'd3)) gpio_31_config (
          .io_out(), .io_in(spi_csn), .io_oeb(),
          .gpio_zero(gpio_loopback_zero[31]), .gpio_one(gpio_loopback_one[31]),
          .gpio_in(gpio_in[31]), .gpio_dm({gpio_dm2[31], gpio_dm1[31], gpio_dm0[31]}),
          .gpio_inp_dis(gpio_inp_dis[31]), .gpio_oeb_out(gpio_oeb[31]), .gpio_out_val(gpio_out[31]),
          .gpio_analog_en(gpio_analog_en[31]), .gpio_analog_sel(gpio_analog_sel[31]),
          .gpio_analog_pol(gpio_analog_pol[31]), .gpio_ib_mode_sel(gpio_ib_mode_sel[31]),
          .gpio_vtrip_sel(gpio_vtrip_sel[31]), .gpio_slow_sel(gpio_slow_sel[31]),
          .gpio_holdover(gpio_holdover[31])
        );

        // GPIO 32: spi_sclk (Mode 1: input)
        CF_gpio_config #(.MODE(3'd1)) gpio_32_config (
          .io_out(), .io_in(spi_sclk), .io_oeb(),
          .gpio_zero(gpio_loopback_zero[32]), .gpio_one(gpio_loopback_one[32]),
          .gpio_in(gpio_in[32]), .gpio_dm({gpio_dm2[32], gpio_dm1[32], gpio_dm0[32]}),
          .gpio_inp_dis(gpio_inp_dis[32]), .gpio_oeb_out(gpio_oeb[32]), .gpio_out_val(gpio_out[32]),
          .gpio_analog_en(gpio_analog_en[32]), .gpio_analog_sel(gpio_analog_sel[32]),
          .gpio_analog_pol(gpio_analog_pol[32]), .gpio_ib_mode_sel(gpio_ib_mode_sel[32]),
          .gpio_vtrip_sel(gpio_vtrip_sel[32]), .gpio_slow_sel(gpio_slow_sel[32]),
          .gpio_holdover(gpio_holdover[32])
        );

        // GPIO 33: bidir[26] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_33_config (
          .io_out(bidir_out[26]), .io_in(bidir_in[26]), .io_oeb(~bidir_oe[26]),
          .gpio_zero(gpio_loopback_zero[33]), .gpio_one(gpio_loopback_one[33]),
          .gpio_in(gpio_in[33]), .gpio_dm({gpio_dm2[33], gpio_dm1[33], gpio_dm0[33]}),
          .gpio_inp_dis(gpio_inp_dis[33]), .gpio_oeb_out(gpio_oeb[33]), .gpio_out_val(gpio_out[33]),
          .gpio_analog_en(gpio_analog_en[33]), .gpio_analog_sel(gpio_analog_sel[33]),
          .gpio_analog_pol(gpio_analog_pol[33]), .gpio_ib_mode_sel(gpio_ib_mode_sel[33]),
          .gpio_vtrip_sel(gpio_vtrip_sel[33]), .gpio_slow_sel(gpio_slow_sel[33]),
          .gpio_holdover(gpio_holdover[33])
        );

        // GPIO 34: bidir[27] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_34_config (
          .io_out(bidir_out[27]), .io_in(bidir_in[27]), .io_oeb(~bidir_oe[27]),
          .gpio_zero(gpio_loopback_zero[34]), .gpio_one(gpio_loopback_one[34]),
          .gpio_in(gpio_in[34]), .gpio_dm({gpio_dm2[34], gpio_dm1[34], gpio_dm0[34]}),
          .gpio_inp_dis(gpio_inp_dis[34]), .gpio_oeb_out(gpio_oeb[34]), .gpio_out_val(gpio_out[34]),
          .gpio_analog_en(gpio_analog_en[34]), .gpio_analog_sel(gpio_analog_sel[34]),
          .gpio_analog_pol(gpio_analog_pol[34]), .gpio_ib_mode_sel(gpio_ib_mode_sel[34]),
          .gpio_vtrip_sel(gpio_vtrip_sel[34]), .gpio_slow_sel(gpio_slow_sel[34]),
          .gpio_holdover(gpio_holdover[34])
        );

        // GPIO 35: bidir[28] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_35_config (
          .io_out(bidir_out[28]), .io_in(bidir_in[28]), .io_oeb(~bidir_oe[28]),
          .gpio_zero(gpio_loopback_zero[35]), .gpio_one(gpio_loopback_one[35]),
          .gpio_in(gpio_in[35]), .gpio_dm({gpio_dm2[35], gpio_dm1[35], gpio_dm0[35]}),
          .gpio_inp_dis(gpio_inp_dis[35]), .gpio_oeb_out(gpio_oeb[35]), .gpio_out_val(gpio_out[35]),
          .gpio_analog_en(gpio_analog_en[35]), .gpio_analog_sel(gpio_analog_sel[35]),
          .gpio_analog_pol(gpio_analog_pol[35]), .gpio_ib_mode_sel(gpio_ib_mode_sel[35]),
          .gpio_vtrip_sel(gpio_vtrip_sel[35]), .gpio_slow_sel(gpio_slow_sel[35]),
          .gpio_holdover(gpio_holdover[35])
        );

        // GPIO 36: bidir[29] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_36_config (
          .io_out(bidir_out[29]), .io_in(bidir_in[29]), .io_oeb(~bidir_oe[29]),
          .gpio_zero(gpio_loopback_zero[36]), .gpio_one(gpio_loopback_one[36]),
          .gpio_in(gpio_in[36]), .gpio_dm({gpio_dm2[36], gpio_dm1[36], gpio_dm0[36]}),
          .gpio_inp_dis(gpio_inp_dis[36]), .gpio_oeb_out(gpio_oeb[36]), .gpio_out_val(gpio_out[36]),
          .gpio_analog_en(gpio_analog_en[36]), .gpio_analog_sel(gpio_analog_sel[36]),
          .gpio_analog_pol(gpio_analog_pol[36]), .gpio_ib_mode_sel(gpio_ib_mode_sel[36]),
          .gpio_vtrip_sel(gpio_vtrip_sel[36]), .gpio_slow_sel(gpio_slow_sel[36]),
          .gpio_holdover(gpio_holdover[36])
        );

        // GPIO 37: bidir[30] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_37_config (
          .io_out(bidir_out[30]), .io_in(bidir_in[30]), .io_oeb(~bidir_oe[30]),
          .gpio_zero(gpio_loopback_zero[37]), .gpio_one(gpio_loopback_one[37]),
          .gpio_in(gpio_in[37]), .gpio_dm({gpio_dm2[37], gpio_dm1[37], gpio_dm0[37]}),
          .gpio_inp_dis(gpio_inp_dis[37]), .gpio_oeb_out(gpio_oeb[37]), .gpio_out_val(gpio_out[37]),
          .gpio_analog_en(gpio_analog_en[37]), .gpio_analog_sel(gpio_analog_sel[37]),
          .gpio_analog_pol(gpio_analog_pol[37]), .gpio_ib_mode_sel(gpio_ib_mode_sel[37]),
          .gpio_vtrip_sel(gpio_vtrip_sel[37]), .gpio_slow_sel(gpio_slow_sel[37]),
          .gpio_holdover(gpio_holdover[37])
        );

        // GPIO 38: clk (Mode 1: input)
        CF_gpio_config #(.MODE(3'd1)) gpio_38_config (
          .io_out(), .io_in(), .io_oeb(), // clk uses gpio_in[38] directly
          .gpio_zero(gpio_loopback_zero[38]), .gpio_one(gpio_loopback_one[38]),
          .gpio_in(gpio_in[38]), .gpio_dm({gpio_dm2[38], gpio_dm1[38], gpio_dm0[38]}),
          .gpio_inp_dis(gpio_inp_dis[38]), .gpio_oeb_out(gpio_oeb[38]), .gpio_out_val(gpio_out[38]),
          .gpio_analog_en(gpio_analog_en[38]), .gpio_analog_sel(gpio_analog_sel[38]),
          .gpio_analog_pol(gpio_analog_pol[38]), .gpio_ib_mode_sel(gpio_ib_mode_sel[38]),
          .gpio_vtrip_sel(gpio_vtrip_sel[38]), .gpio_slow_sel(gpio_slow_sel[38]),
          .gpio_holdover(gpio_holdover[38])
        );

        // GPIO 39: bidir[31] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_39_config (
          .io_out(bidir_out[31]), .io_in(bidir_in[31]), .io_oeb(~bidir_oe[31]),
          .gpio_zero(gpio_loopback_zero[39]), .gpio_one(gpio_loopback_one[39]),
          .gpio_in(gpio_in[39]), .gpio_dm({gpio_dm2[39], gpio_dm1[39], gpio_dm0[39]}),
          .gpio_inp_dis(gpio_inp_dis[39]), .gpio_oeb_out(gpio_oeb[39]), .gpio_out_val(gpio_out[39]),
          .gpio_analog_en(gpio_analog_en[39]), .gpio_analog_sel(gpio_analog_sel[39]),
          .gpio_analog_pol(gpio_analog_pol[39]), .gpio_ib_mode_sel(gpio_ib_mode_sel[39]),
          .gpio_vtrip_sel(gpio_vtrip_sel[39]), .gpio_slow_sel(gpio_slow_sel[39]),
          .gpio_holdover(gpio_holdover[39])
        );

        // GPIO 40: bidir[32] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_40_config (
          .io_out(bidir_out[32]), .io_in(bidir_in[32]), .io_oeb(~bidir_oe[32]),
          .gpio_zero(gpio_loopback_zero[40]), .gpio_one(gpio_loopback_one[40]),
          .gpio_in(gpio_in[40]), .gpio_dm({gpio_dm2[40], gpio_dm1[40], gpio_dm0[40]}),
          .gpio_inp_dis(gpio_inp_dis[40]), .gpio_oeb_out(gpio_oeb[40]), .gpio_out_val(gpio_out[40]),
          .gpio_analog_en(gpio_analog_en[40]), .gpio_analog_sel(gpio_analog_sel[40]),
          .gpio_analog_pol(gpio_analog_pol[40]), .gpio_ib_mode_sel(gpio_ib_mode_sel[40]),
          .gpio_vtrip_sel(gpio_vtrip_sel[40]), .gpio_slow_sel(gpio_slow_sel[40]),
          .gpio_holdover(gpio_holdover[40])
        );

        // GPIO 41: bidir[33] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_41_config (
          .io_out(bidir_out[33]), .io_in(bidir_in[33]), .io_oeb(~bidir_oe[33]),
          .gpio_zero(gpio_loopback_zero[41]), .gpio_one(gpio_loopback_one[41]),
          .gpio_in(gpio_in[41]), .gpio_dm({gpio_dm2[41], gpio_dm1[41], gpio_dm0[41]}),
          .gpio_inp_dis(gpio_inp_dis[41]), .gpio_oeb_out(gpio_oeb[41]), .gpio_out_val(gpio_out[41]),
          .gpio_analog_en(gpio_analog_en[41]), .gpio_analog_sel(gpio_analog_sel[41]),
          .gpio_analog_pol(gpio_analog_pol[41]), .gpio_ib_mode_sel(gpio_ib_mode_sel[41]),
          .gpio_vtrip_sel(gpio_vtrip_sel[41]), .gpio_slow_sel(gpio_slow_sel[41]),
          .gpio_holdover(gpio_holdover[41])
        );

        // GPIO 42: bidir[34] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_42_config (
          .io_out(bidir_out[34]), .io_in(bidir_in[34]), .io_oeb(~bidir_oe[34]),
          .gpio_zero(gpio_loopback_zero[42]), .gpio_one(gpio_loopback_one[42]),
          .gpio_in(gpio_in[42]), .gpio_dm({gpio_dm2[42], gpio_dm1[42], gpio_dm0[42]}),
          .gpio_inp_dis(gpio_inp_dis[42]), .gpio_oeb_out(gpio_oeb[42]), .gpio_out_val(gpio_out[42]),
          .gpio_analog_en(gpio_analog_en[42]), .gpio_analog_sel(gpio_analog_sel[42]),
          .gpio_analog_pol(gpio_analog_pol[42]), .gpio_ib_mode_sel(gpio_ib_mode_sel[42]),
          .gpio_vtrip_sel(gpio_vtrip_sel[42]), .gpio_slow_sel(gpio_slow_sel[42]),
          .gpio_holdover(gpio_holdover[42])
        );

        // GPIO 43: bidir[35] (Mode 5: bidirectional)
        CF_gpio_config #(.MODE(3'd5)) gpio_43_config (
          .io_out(bidir_out[35]), .io_in(bidir_in[35]), .io_oeb(~bidir_oe[35]),
          .gpio_zero(gpio_loopback_zero[43]), .gpio_one(gpio_loopback_one[43]),
          .gpio_in(gpio_in[43]), .gpio_dm({gpio_dm2[43], gpio_dm1[43], gpio_dm0[43]}),
          .gpio_inp_dis(gpio_inp_dis[43]), .gpio_oeb_out(gpio_oeb[43]), .gpio_out_val(gpio_out[43]),
          .gpio_analog_en(gpio_analog_en[43]), .gpio_analog_sel(gpio_analog_sel[43]),
          .gpio_analog_pol(gpio_analog_pol[43]), .gpio_ib_mode_sel(gpio_ib_mode_sel[43]),
          .gpio_vtrip_sel(gpio_vtrip_sel[43]), .gpio_slow_sel(gpio_slow_sel[43]),
          .gpio_holdover(gpio_holdover[43])
        );

endmodule	// openframe_project_wrapper

