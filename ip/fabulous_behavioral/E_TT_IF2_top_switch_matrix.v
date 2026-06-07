 // NumberOfConfigBits: 124
module E_TT_IF2_top_switch_matrix
    #(
        parameter NoConfigBits=124
    )
    (
        input  N_GBUF_END0,
        input  N_GBUF_END1,
        input  N_GBUF_END2,
        input  N_GBUF_END3,
        input  E1END0,
        input  E1END1,
        input  E1END2,
        input  E1END3,
        input  E2MID0,
        input  E2MID1,
        input  E2MID2,
        input  E2MID3,
        input  E2MID4,
        input  E2MID5,
        input  E2MID6,
        input  E2MID7,
        input  E2END0,
        input  E2END1,
        input  E2END2,
        input  E2END3,
        input  E2END4,
        input  E2END5,
        input  E2END6,
        input  E2END7,
        input  EE4END0,
        input  EE4END1,
        input  EE4END2,
        input  EE4END3,
        input  EE4END4,
        input  EE4END5,
        input  EE4END6,
        input  EE4END7,
        input  EE4END8,
        input  EE4END9,
        input  EE4END10,
        input  EE4END11,
        input  EE4END12,
        input  EE4END13,
        input  EE4END14,
        input  EE4END15,
        input  E6END0,
        input  E6END1,
        input  E6END2,
        input  E6END3,
        input  E6END4,
        input  E6END5,
        input  E6END6,
        input  E6END7,
        input  E6END8,
        input  E6END9,
        input  E6END10,
        input  E6END11,
        input  bot2top_UIO_OUT0,
        input  bot2top_UIO_OUT1,
        input  bot2top_UIO_OUT2,
        input  bot2top_UIO_OUT3,
        input  bot2top_UIO_OUT4,
        input  bot2top_UIO_OUT5,
        input  bot2top_UIO_OUT6,
        input  bot2top_UIO_OUT7,
        input  bot2top_UIO_OE0,
        input  bot2top_UIO_OE1,
        input  bot2top_UIO_OE2,
        input  bot2top_UIO_OE3,
        input  bot2top_UIO_OE4,
        input  bot2top_UIO_OE5,
        input  bot2top_UIO_OE6,
        input  bot2top_UIO_OE7,
        output  N_GBUF_BEG0,
        output  N_GBUF_BEG1,
        output  N_GBUF_BEG2,
        output  N_GBUF_BEG3,
        output  W1BEG0,
        output  W1BEG1,
        output  W1BEG2,
        output  W1BEG3,
        output  W2BEG0,
        output  W2BEG1,
        output  W2BEG2,
        output  W2BEG3,
        output  W2BEG4,
        output  W2BEG5,
        output  W2BEG6,
        output  W2BEG7,
        output  W2BEGb0,
        output  W2BEGb1,
        output  W2BEGb2,
        output  W2BEGb3,
        output  W2BEGb4,
        output  W2BEGb5,
        output  W2BEGb6,
        output  W2BEGb7,
        output  WW4BEG0,
        output  WW4BEG1,
        output  WW4BEG2,
        output  WW4BEG3,
        output  WW4BEG4,
        output  WW4BEG5,
        output  WW4BEG6,
        output  WW4BEG7,
        output  WW4BEG8,
        output  WW4BEG9,
        output  WW4BEG10,
        output  WW4BEG11,
        output  WW4BEG12,
        output  WW4BEG13,
        output  WW4BEG14,
        output  WW4BEG15,
        output  W6BEG0,
        output  W6BEG1,
        output  W6BEG2,
        output  W6BEG3,
        output  W6BEG4,
        output  W6BEG5,
        output  W6BEG6,
        output  W6BEG7,
        output  W6BEG8,
        output  W6BEG9,
        output  W6BEG10,
        output  W6BEG11,
        output  top2bot_UIO_IN0,
        output  top2bot_UIO_IN1,
        output  top2bot_UIO_IN2,
        output  top2bot_UIO_IN3,
        output  top2bot_UIO_IN4,
        output  top2bot_UIO_IN5,
        output  top2bot_UIO_IN6,
        output  top2bot_UIO_IN7,
 //global
        input  [NoConfigBits-1:0] ConfigBits,
        input  [NoConfigBits-1:0] ConfigBits_N
);
parameter GND0 = 1'b0;
parameter GND = 1'b0;
parameter VCC0 = 1'b1;
parameter VCC = 1'b1;
parameter VDD0 = 1'b1;
parameter VDD = 1'b1;

wire[4-1:0] W1BEG0_input;
wire[4-1:0] W1BEG1_input;
wire[4-1:0] W1BEG2_input;
wire[4-1:0] W1BEG3_input;
wire[8-1:0] W2BEG0_input;
wire[8-1:0] W2BEG1_input;
wire[8-1:0] W2BEG2_input;
wire[8-1:0] W2BEG3_input;
wire[8-1:0] W2BEG4_input;
wire[8-1:0] W2BEG5_input;
wire[8-1:0] W2BEG6_input;
wire[8-1:0] W2BEG7_input;
wire[8-1:0] W2BEGb0_input;
wire[8-1:0] W2BEGb1_input;
wire[8-1:0] W2BEGb2_input;
wire[8-1:0] W2BEGb3_input;
wire[8-1:0] W2BEGb4_input;
wire[8-1:0] W2BEGb5_input;
wire[8-1:0] W2BEGb6_input;
wire[8-1:0] W2BEGb7_input;
wire[4-1:0] WW4BEG0_input;
wire[4-1:0] WW4BEG1_input;
wire[4-1:0] WW4BEG2_input;
wire[4-1:0] WW4BEG3_input;
wire[4-1:0] WW4BEG4_input;
wire[4-1:0] WW4BEG5_input;
wire[4-1:0] WW4BEG6_input;
wire[4-1:0] WW4BEG7_input;
wire[4-1:0] WW4BEG8_input;
wire[4-1:0] WW4BEG9_input;
wire[4-1:0] WW4BEG10_input;
wire[4-1:0] WW4BEG11_input;
wire[4-1:0] WW4BEG12_input;
wire[4-1:0] WW4BEG13_input;
wire[4-1:0] WW4BEG14_input;
wire[4-1:0] WW4BEG15_input;
wire[2-1:0] W6BEG0_input;
wire[2-1:0] W6BEG1_input;
wire[2-1:0] W6BEG2_input;
wire[2-1:0] W6BEG3_input;
wire[2-1:0] W6BEG4_input;
wire[2-1:0] W6BEG5_input;
wire[2-1:0] W6BEG6_input;
wire[2-1:0] W6BEG7_input;
wire[2-1:0] W6BEG8_input;
wire[2-1:0] W6BEG9_input;
wire[2-1:0] W6BEG10_input;
wire[2-1:0] W6BEG11_input;
wire[8-1:0] top2bot_UIO_IN0_input;
wire[8-1:0] top2bot_UIO_IN1_input;
wire[8-1:0] top2bot_UIO_IN2_input;
wire[8-1:0] top2bot_UIO_IN3_input;
wire[8-1:0] top2bot_UIO_IN4_input;
wire[8-1:0] top2bot_UIO_IN5_input;
wire[8-1:0] top2bot_UIO_IN6_input;
wire[8-1:0] top2bot_UIO_IN7_input;
 //The configuration bits (if any) are just a long shift register
 //This shift register is padded to an even number of flops/latches
 //switch matrix multiplexer N_GBUF_BEG0 MUX-1
assign N_GBUF_BEG0 = N_GBUF_END0;

 //switch matrix multiplexer N_GBUF_BEG1 MUX-1
assign N_GBUF_BEG1 = N_GBUF_END1;

 //switch matrix multiplexer N_GBUF_BEG2 MUX-1
assign N_GBUF_BEG2 = N_GBUF_END2;

 //switch matrix multiplexer N_GBUF_BEG3 MUX-1
assign N_GBUF_BEG3 = N_GBUF_END3;

 //switch matrix multiplexer W1BEG0 MUX-4
assign W1BEG0_input = {bot2top_UIO_OUT7,bot2top_UIO_OUT2,E2END0,E1END3};
cus_mux41 inst_cus_mux41_W1BEG0 (
    .A0(W1BEG0_input[0]),
    .A1(W1BEG0_input[1]),
    .A2(W1BEG0_input[2]),
    .A3(W1BEG0_input[3]),
    .S0(ConfigBits[0+0]),
    .S0N(ConfigBits_N[0+0]),
    .S1(ConfigBits[0+1]),
    .S1N(ConfigBits_N[0+1]),
    .X(W1BEG0)
);

 //switch matrix multiplexer W1BEG1 MUX-4
assign W1BEG1_input = {bot2top_UIO_OUT6,bot2top_UIO_OUT3,E2END1,E1END2};
cus_mux41 inst_cus_mux41_W1BEG1 (
    .A0(W1BEG1_input[0]),
    .A1(W1BEG1_input[1]),
    .A2(W1BEG1_input[2]),
    .A3(W1BEG1_input[3]),
    .S0(ConfigBits[2+0]),
    .S0N(ConfigBits_N[2+0]),
    .S1(ConfigBits[2+1]),
    .S1N(ConfigBits_N[2+1]),
    .X(W1BEG1)
);

 //switch matrix multiplexer W1BEG2 MUX-4
assign W1BEG2_input = {bot2top_UIO_OUT5,bot2top_UIO_OUT0,E2END2,E1END1};
cus_mux41 inst_cus_mux41_W1BEG2 (
    .A0(W1BEG2_input[0]),
    .A1(W1BEG2_input[1]),
    .A2(W1BEG2_input[2]),
    .A3(W1BEG2_input[3]),
    .S0(ConfigBits[4+0]),
    .S0N(ConfigBits_N[4+0]),
    .S1(ConfigBits[4+1]),
    .S1N(ConfigBits_N[4+1]),
    .X(W1BEG2)
);

 //switch matrix multiplexer W1BEG3 MUX-4
assign W1BEG3_input = {bot2top_UIO_OUT4,bot2top_UIO_OUT1,E2END3,E1END0};
cus_mux41 inst_cus_mux41_W1BEG3 (
    .A0(W1BEG3_input[0]),
    .A1(W1BEG3_input[1]),
    .A2(W1BEG3_input[2]),
    .A3(W1BEG3_input[3]),
    .S0(ConfigBits[6+0]),
    .S0N(ConfigBits_N[6+0]),
    .S1(ConfigBits[6+1]),
    .S1N(ConfigBits_N[6+1]),
    .X(W1BEG3)
);

 //switch matrix multiplexer W2BEG0 MUX-8
assign W2BEG0_input = {bot2top_UIO_OE7,bot2top_UIO_OE0,bot2top_UIO_OUT3,bot2top_UIO_OUT0,E6END3,EE4END15,EE4END0,E2END7};
cus_mux81 inst_cus_mux81_W2BEG0 (
    .A0(W2BEG0_input[0]),
    .A1(W2BEG0_input[1]),
    .A2(W2BEG0_input[2]),
    .A3(W2BEG0_input[3]),
    .A4(W2BEG0_input[4]),
    .A5(W2BEG0_input[5]),
    .A6(W2BEG0_input[6]),
    .A7(W2BEG0_input[7]),
    .S0(ConfigBits[8+0]),
    .S0N(ConfigBits_N[8+0]),
    .S1(ConfigBits[8+1]),
    .S1N(ConfigBits_N[8+1]),
    .S2(ConfigBits[8+2]),
    .S2N(ConfigBits_N[8+2]),
    .X(W2BEG0)
);

 //switch matrix multiplexer W2BEG1 MUX-8
assign W2BEG1_input = {bot2top_UIO_OE6,bot2top_UIO_OE1,bot2top_UIO_OUT2,bot2top_UIO_OUT1,E6END2,EE4END14,EE4END1,E2END6};
cus_mux81 inst_cus_mux81_W2BEG1 (
    .A0(W2BEG1_input[0]),
    .A1(W2BEG1_input[1]),
    .A2(W2BEG1_input[2]),
    .A3(W2BEG1_input[3]),
    .A4(W2BEG1_input[4]),
    .A5(W2BEG1_input[5]),
    .A6(W2BEG1_input[6]),
    .A7(W2BEG1_input[7]),
    .S0(ConfigBits[11+0]),
    .S0N(ConfigBits_N[11+0]),
    .S1(ConfigBits[11+1]),
    .S1N(ConfigBits_N[11+1]),
    .S2(ConfigBits[11+2]),
    .S2N(ConfigBits_N[11+2]),
    .X(W2BEG1)
);

 //switch matrix multiplexer W2BEG2 MUX-8
assign W2BEG2_input = {bot2top_UIO_OE5,bot2top_UIO_OE2,bot2top_UIO_OUT2,bot2top_UIO_OUT1,E6END1,EE4END13,EE4END2,E2END5};
cus_mux81 inst_cus_mux81_W2BEG2 (
    .A0(W2BEG2_input[0]),
    .A1(W2BEG2_input[1]),
    .A2(W2BEG2_input[2]),
    .A3(W2BEG2_input[3]),
    .A4(W2BEG2_input[4]),
    .A5(W2BEG2_input[5]),
    .A6(W2BEG2_input[6]),
    .A7(W2BEG2_input[7]),
    .S0(ConfigBits[14+0]),
    .S0N(ConfigBits_N[14+0]),
    .S1(ConfigBits[14+1]),
    .S1N(ConfigBits_N[14+1]),
    .S2(ConfigBits[14+2]),
    .S2N(ConfigBits_N[14+2]),
    .X(W2BEG2)
);

 //switch matrix multiplexer W2BEG3 MUX-8
assign W2BEG3_input = {bot2top_UIO_OE4,bot2top_UIO_OE3,bot2top_UIO_OUT3,bot2top_UIO_OUT0,E6END0,EE4END12,EE4END3,E2END4};
cus_mux81 inst_cus_mux81_W2BEG3 (
    .A0(W2BEG3_input[0]),
    .A1(W2BEG3_input[1]),
    .A2(W2BEG3_input[2]),
    .A3(W2BEG3_input[3]),
    .A4(W2BEG3_input[4]),
    .A5(W2BEG3_input[5]),
    .A6(W2BEG3_input[6]),
    .A7(W2BEG3_input[7]),
    .S0(ConfigBits[17+0]),
    .S0N(ConfigBits_N[17+0]),
    .S1(ConfigBits[17+1]),
    .S1N(ConfigBits_N[17+1]),
    .S2(ConfigBits[17+2]),
    .S2N(ConfigBits_N[17+2]),
    .X(W2BEG3)
);

 //switch matrix multiplexer W2BEG4 MUX-8
assign W2BEG4_input = {bot2top_UIO_OE4,bot2top_UIO_OE3,bot2top_UIO_OUT7,bot2top_UIO_OUT4,E6END3,EE4END11,EE4END4,E2END4};
cus_mux81 inst_cus_mux81_W2BEG4 (
    .A0(W2BEG4_input[0]),
    .A1(W2BEG4_input[1]),
    .A2(W2BEG4_input[2]),
    .A3(W2BEG4_input[3]),
    .A4(W2BEG4_input[4]),
    .A5(W2BEG4_input[5]),
    .A6(W2BEG4_input[6]),
    .A7(W2BEG4_input[7]),
    .S0(ConfigBits[20+0]),
    .S0N(ConfigBits_N[20+0]),
    .S1(ConfigBits[20+1]),
    .S1N(ConfigBits_N[20+1]),
    .S2(ConfigBits[20+2]),
    .S2N(ConfigBits_N[20+2]),
    .X(W2BEG4)
);

 //switch matrix multiplexer W2BEG5 MUX-8
assign W2BEG5_input = {bot2top_UIO_OE5,bot2top_UIO_OE2,bot2top_UIO_OUT6,bot2top_UIO_OUT5,E6END2,EE4END10,EE4END5,E2END5};
cus_mux81 inst_cus_mux81_W2BEG5 (
    .A0(W2BEG5_input[0]),
    .A1(W2BEG5_input[1]),
    .A2(W2BEG5_input[2]),
    .A3(W2BEG5_input[3]),
    .A4(W2BEG5_input[4]),
    .A5(W2BEG5_input[5]),
    .A6(W2BEG5_input[6]),
    .A7(W2BEG5_input[7]),
    .S0(ConfigBits[23+0]),
    .S0N(ConfigBits_N[23+0]),
    .S1(ConfigBits[23+1]),
    .S1N(ConfigBits_N[23+1]),
    .S2(ConfigBits[23+2]),
    .S2N(ConfigBits_N[23+2]),
    .X(W2BEG5)
);

 //switch matrix multiplexer W2BEG6 MUX-8
assign W2BEG6_input = {bot2top_UIO_OE6,bot2top_UIO_OE1,bot2top_UIO_OUT6,bot2top_UIO_OUT5,E6END1,EE4END9,EE4END6,E2END5};
cus_mux81 inst_cus_mux81_W2BEG6 (
    .A0(W2BEG6_input[0]),
    .A1(W2BEG6_input[1]),
    .A2(W2BEG6_input[2]),
    .A3(W2BEG6_input[3]),
    .A4(W2BEG6_input[4]),
    .A5(W2BEG6_input[5]),
    .A6(W2BEG6_input[6]),
    .A7(W2BEG6_input[7]),
    .S0(ConfigBits[26+0]),
    .S0N(ConfigBits_N[26+0]),
    .S1(ConfigBits[26+1]),
    .S1N(ConfigBits_N[26+1]),
    .S2(ConfigBits[26+2]),
    .S2N(ConfigBits_N[26+2]),
    .X(W2BEG6)
);

 //switch matrix multiplexer W2BEG7 MUX-8
assign W2BEG7_input = {bot2top_UIO_OE7,bot2top_UIO_OE0,bot2top_UIO_OUT7,bot2top_UIO_OUT4,E6END0,EE4END8,EE4END7,E2END4};
cus_mux81 inst_cus_mux81_W2BEG7 (
    .A0(W2BEG7_input[0]),
    .A1(W2BEG7_input[1]),
    .A2(W2BEG7_input[2]),
    .A3(W2BEG7_input[3]),
    .A4(W2BEG7_input[4]),
    .A5(W2BEG7_input[5]),
    .A6(W2BEG7_input[6]),
    .A7(W2BEG7_input[7]),
    .S0(ConfigBits[29+0]),
    .S0N(ConfigBits_N[29+0]),
    .S1(ConfigBits[29+1]),
    .S1N(ConfigBits_N[29+1]),
    .S2(ConfigBits[29+2]),
    .S2N(ConfigBits_N[29+2]),
    .X(W2BEG7)
);

 //switch matrix multiplexer W2BEGb0 MUX-8
assign W2BEGb0_input = {bot2top_UIO_OE7,bot2top_UIO_OE0,bot2top_UIO_OUT3,bot2top_UIO_OUT0,E6END4,EE4END8,EE4END7,E2END3};
cus_mux81 inst_cus_mux81_W2BEGb0 (
    .A0(W2BEGb0_input[0]),
    .A1(W2BEGb0_input[1]),
    .A2(W2BEGb0_input[2]),
    .A3(W2BEGb0_input[3]),
    .A4(W2BEGb0_input[4]),
    .A5(W2BEGb0_input[5]),
    .A6(W2BEGb0_input[6]),
    .A7(W2BEGb0_input[7]),
    .S0(ConfigBits[32+0]),
    .S0N(ConfigBits_N[32+0]),
    .S1(ConfigBits[32+1]),
    .S1N(ConfigBits_N[32+1]),
    .S2(ConfigBits[32+2]),
    .S2N(ConfigBits_N[32+2]),
    .X(W2BEGb0)
);

 //switch matrix multiplexer W2BEGb1 MUX-8
assign W2BEGb1_input = {bot2top_UIO_OE6,bot2top_UIO_OE1,bot2top_UIO_OUT2,bot2top_UIO_OUT1,E6END5,EE4END9,EE4END6,E2END2};
cus_mux81 inst_cus_mux81_W2BEGb1 (
    .A0(W2BEGb1_input[0]),
    .A1(W2BEGb1_input[1]),
    .A2(W2BEGb1_input[2]),
    .A3(W2BEGb1_input[3]),
    .A4(W2BEGb1_input[4]),
    .A5(W2BEGb1_input[5]),
    .A6(W2BEGb1_input[6]),
    .A7(W2BEGb1_input[7]),
    .S0(ConfigBits[35+0]),
    .S0N(ConfigBits_N[35+0]),
    .S1(ConfigBits[35+1]),
    .S1N(ConfigBits_N[35+1]),
    .S2(ConfigBits[35+2]),
    .S2N(ConfigBits_N[35+2]),
    .X(W2BEGb1)
);

 //switch matrix multiplexer W2BEGb2 MUX-8
assign W2BEGb2_input = {bot2top_UIO_OE5,bot2top_UIO_OE2,bot2top_UIO_OUT2,bot2top_UIO_OUT1,E6END6,EE4END10,EE4END5,E2END1};
cus_mux81 inst_cus_mux81_W2BEGb2 (
    .A0(W2BEGb2_input[0]),
    .A1(W2BEGb2_input[1]),
    .A2(W2BEGb2_input[2]),
    .A3(W2BEGb2_input[3]),
    .A4(W2BEGb2_input[4]),
    .A5(W2BEGb2_input[5]),
    .A6(W2BEGb2_input[6]),
    .A7(W2BEGb2_input[7]),
    .S0(ConfigBits[38+0]),
    .S0N(ConfigBits_N[38+0]),
    .S1(ConfigBits[38+1]),
    .S1N(ConfigBits_N[38+1]),
    .S2(ConfigBits[38+2]),
    .S2N(ConfigBits_N[38+2]),
    .X(W2BEGb2)
);

 //switch matrix multiplexer W2BEGb3 MUX-8
assign W2BEGb3_input = {bot2top_UIO_OE4,bot2top_UIO_OE3,bot2top_UIO_OUT3,bot2top_UIO_OUT0,E6END7,EE4END11,EE4END4,E2END0};
cus_mux81 inst_cus_mux81_W2BEGb3 (
    .A0(W2BEGb3_input[0]),
    .A1(W2BEGb3_input[1]),
    .A2(W2BEGb3_input[2]),
    .A3(W2BEGb3_input[3]),
    .A4(W2BEGb3_input[4]),
    .A5(W2BEGb3_input[5]),
    .A6(W2BEGb3_input[6]),
    .A7(W2BEGb3_input[7]),
    .S0(ConfigBits[41+0]),
    .S0N(ConfigBits_N[41+0]),
    .S1(ConfigBits[41+1]),
    .S1N(ConfigBits_N[41+1]),
    .S2(ConfigBits[41+2]),
    .S2N(ConfigBits_N[41+2]),
    .X(W2BEGb3)
);

 //switch matrix multiplexer W2BEGb4 MUX-8
assign W2BEGb4_input = {bot2top_UIO_OE4,bot2top_UIO_OE3,bot2top_UIO_OUT7,bot2top_UIO_OUT4,E6END6,EE4END12,EE4END3,E2END3};
cus_mux81 inst_cus_mux81_W2BEGb4 (
    .A0(W2BEGb4_input[0]),
    .A1(W2BEGb4_input[1]),
    .A2(W2BEGb4_input[2]),
    .A3(W2BEGb4_input[3]),
    .A4(W2BEGb4_input[4]),
    .A5(W2BEGb4_input[5]),
    .A6(W2BEGb4_input[6]),
    .A7(W2BEGb4_input[7]),
    .S0(ConfigBits[44+0]),
    .S0N(ConfigBits_N[44+0]),
    .S1(ConfigBits[44+1]),
    .S1N(ConfigBits_N[44+1]),
    .S2(ConfigBits[44+2]),
    .S2N(ConfigBits_N[44+2]),
    .X(W2BEGb4)
);

 //switch matrix multiplexer W2BEGb5 MUX-8
assign W2BEGb5_input = {bot2top_UIO_OE5,bot2top_UIO_OE2,bot2top_UIO_OUT6,bot2top_UIO_OUT5,E6END7,EE4END13,EE4END2,E2END2};
cus_mux81 inst_cus_mux81_W2BEGb5 (
    .A0(W2BEGb5_input[0]),
    .A1(W2BEGb5_input[1]),
    .A2(W2BEGb5_input[2]),
    .A3(W2BEGb5_input[3]),
    .A4(W2BEGb5_input[4]),
    .A5(W2BEGb5_input[5]),
    .A6(W2BEGb5_input[6]),
    .A7(W2BEGb5_input[7]),
    .S0(ConfigBits[47+0]),
    .S0N(ConfigBits_N[47+0]),
    .S1(ConfigBits[47+1]),
    .S1N(ConfigBits_N[47+1]),
    .S2(ConfigBits[47+2]),
    .S2N(ConfigBits_N[47+2]),
    .X(W2BEGb5)
);

 //switch matrix multiplexer W2BEGb6 MUX-8
assign W2BEGb6_input = {bot2top_UIO_OE6,bot2top_UIO_OE1,bot2top_UIO_OUT6,bot2top_UIO_OUT5,E6END8,EE4END14,EE4END1,E2END1};
cus_mux81 inst_cus_mux81_W2BEGb6 (
    .A0(W2BEGb6_input[0]),
    .A1(W2BEGb6_input[1]),
    .A2(W2BEGb6_input[2]),
    .A3(W2BEGb6_input[3]),
    .A4(W2BEGb6_input[4]),
    .A5(W2BEGb6_input[5]),
    .A6(W2BEGb6_input[6]),
    .A7(W2BEGb6_input[7]),
    .S0(ConfigBits[50+0]),
    .S0N(ConfigBits_N[50+0]),
    .S1(ConfigBits[50+1]),
    .S1N(ConfigBits_N[50+1]),
    .S2(ConfigBits[50+2]),
    .S2N(ConfigBits_N[50+2]),
    .X(W2BEGb6)
);

 //switch matrix multiplexer W2BEGb7 MUX-8
assign W2BEGb7_input = {bot2top_UIO_OE7,bot2top_UIO_OE0,bot2top_UIO_OUT7,bot2top_UIO_OUT4,E6END9,EE4END15,EE4END0,E2END0};
cus_mux81 inst_cus_mux81_W2BEGb7 (
    .A0(W2BEGb7_input[0]),
    .A1(W2BEGb7_input[1]),
    .A2(W2BEGb7_input[2]),
    .A3(W2BEGb7_input[3]),
    .A4(W2BEGb7_input[4]),
    .A5(W2BEGb7_input[5]),
    .A6(W2BEGb7_input[6]),
    .A7(W2BEGb7_input[7]),
    .S0(ConfigBits[53+0]),
    .S0N(ConfigBits_N[53+0]),
    .S1(ConfigBits[53+1]),
    .S1N(ConfigBits_N[53+1]),
    .S2(ConfigBits[53+2]),
    .S2N(ConfigBits_N[53+2]),
    .X(W2BEGb7)
);

 //switch matrix multiplexer WW4BEG0 MUX-4
assign WW4BEG0_input = {bot2top_UIO_OE4,bot2top_UIO_OUT0,EE4END15,E1END3};
cus_mux41 inst_cus_mux41_WW4BEG0 (
    .A0(WW4BEG0_input[0]),
    .A1(WW4BEG0_input[1]),
    .A2(WW4BEG0_input[2]),
    .A3(WW4BEG0_input[3]),
    .S0(ConfigBits[56+0]),
    .S0N(ConfigBits_N[56+0]),
    .S1(ConfigBits[56+1]),
    .S1N(ConfigBits_N[56+1]),
    .X(WW4BEG0)
);

 //switch matrix multiplexer WW4BEG1 MUX-4
assign WW4BEG1_input = {bot2top_UIO_OE5,bot2top_UIO_OUT1,EE4END14,E1END2};
cus_mux41 inst_cus_mux41_WW4BEG1 (
    .A0(WW4BEG1_input[0]),
    .A1(WW4BEG1_input[1]),
    .A2(WW4BEG1_input[2]),
    .A3(WW4BEG1_input[3]),
    .S0(ConfigBits[58+0]),
    .S0N(ConfigBits_N[58+0]),
    .S1(ConfigBits[58+1]),
    .S1N(ConfigBits_N[58+1]),
    .X(WW4BEG1)
);

 //switch matrix multiplexer WW4BEG2 MUX-4
assign WW4BEG2_input = {bot2top_UIO_OE6,bot2top_UIO_OUT2,EE4END13,E2END0};
cus_mux41 inst_cus_mux41_WW4BEG2 (
    .A0(WW4BEG2_input[0]),
    .A1(WW4BEG2_input[1]),
    .A2(WW4BEG2_input[2]),
    .A3(WW4BEG2_input[3]),
    .S0(ConfigBits[60+0]),
    .S0N(ConfigBits_N[60+0]),
    .S1(ConfigBits[60+1]),
    .S1N(ConfigBits_N[60+1]),
    .X(WW4BEG2)
);

 //switch matrix multiplexer WW4BEG3 MUX-4
assign WW4BEG3_input = {bot2top_UIO_OE7,bot2top_UIO_OUT3,EE4END12,E2END1};
cus_mux41 inst_cus_mux41_WW4BEG3 (
    .A0(WW4BEG3_input[0]),
    .A1(WW4BEG3_input[1]),
    .A2(WW4BEG3_input[2]),
    .A3(WW4BEG3_input[3]),
    .S0(ConfigBits[62+0]),
    .S0N(ConfigBits_N[62+0]),
    .S1(ConfigBits[62+1]),
    .S1N(ConfigBits_N[62+1]),
    .X(WW4BEG3)
);

 //switch matrix multiplexer WW4BEG4 MUX-4
assign WW4BEG4_input = {bot2top_UIO_OE0,bot2top_UIO_OUT4,EE4END11,E2END2};
cus_mux41 inst_cus_mux41_WW4BEG4 (
    .A0(WW4BEG4_input[0]),
    .A1(WW4BEG4_input[1]),
    .A2(WW4BEG4_input[2]),
    .A3(WW4BEG4_input[3]),
    .S0(ConfigBits[64+0]),
    .S0N(ConfigBits_N[64+0]),
    .S1(ConfigBits[64+1]),
    .S1N(ConfigBits_N[64+1]),
    .X(WW4BEG4)
);

 //switch matrix multiplexer WW4BEG5 MUX-4
assign WW4BEG5_input = {bot2top_UIO_OE1,bot2top_UIO_OUT5,EE4END10,E2END3};
cus_mux41 inst_cus_mux41_WW4BEG5 (
    .A0(WW4BEG5_input[0]),
    .A1(WW4BEG5_input[1]),
    .A2(WW4BEG5_input[2]),
    .A3(WW4BEG5_input[3]),
    .S0(ConfigBits[66+0]),
    .S0N(ConfigBits_N[66+0]),
    .S1(ConfigBits[66+1]),
    .S1N(ConfigBits_N[66+1]),
    .X(WW4BEG5)
);

 //switch matrix multiplexer WW4BEG6 MUX-4
assign WW4BEG6_input = {bot2top_UIO_OE2,bot2top_UIO_OUT6,E6END0,EE4END9};
cus_mux41 inst_cus_mux41_WW4BEG6 (
    .A0(WW4BEG6_input[0]),
    .A1(WW4BEG6_input[1]),
    .A2(WW4BEG6_input[2]),
    .A3(WW4BEG6_input[3]),
    .S0(ConfigBits[68+0]),
    .S0N(ConfigBits_N[68+0]),
    .S1(ConfigBits[68+1]),
    .S1N(ConfigBits_N[68+1]),
    .X(WW4BEG6)
);

 //switch matrix multiplexer WW4BEG7 MUX-4
assign WW4BEG7_input = {bot2top_UIO_OE3,bot2top_UIO_OUT7,E6END4,EE4END8};
cus_mux41 inst_cus_mux41_WW4BEG7 (
    .A0(WW4BEG7_input[0]),
    .A1(WW4BEG7_input[1]),
    .A2(WW4BEG7_input[2]),
    .A3(WW4BEG7_input[3]),
    .S0(ConfigBits[70+0]),
    .S0N(ConfigBits_N[70+0]),
    .S1(ConfigBits[70+1]),
    .S1N(ConfigBits_N[70+1]),
    .X(WW4BEG7)
);

 //switch matrix multiplexer WW4BEG8 MUX-4
assign WW4BEG8_input = {bot2top_UIO_OE4,bot2top_UIO_OUT0,E6END8,EE4END0};
cus_mux41 inst_cus_mux41_WW4BEG8 (
    .A0(WW4BEG8_input[0]),
    .A1(WW4BEG8_input[1]),
    .A2(WW4BEG8_input[2]),
    .A3(WW4BEG8_input[3]),
    .S0(ConfigBits[72+0]),
    .S0N(ConfigBits_N[72+0]),
    .S1(ConfigBits[72+1]),
    .S1N(ConfigBits_N[72+1]),
    .X(WW4BEG8)
);

 //switch matrix multiplexer WW4BEG9 MUX-4
assign WW4BEG9_input = {bot2top_UIO_OE5,bot2top_UIO_OUT1,E6END11,EE4END1};
cus_mux41 inst_cus_mux41_WW4BEG9 (
    .A0(WW4BEG9_input[0]),
    .A1(WW4BEG9_input[1]),
    .A2(WW4BEG9_input[2]),
    .A3(WW4BEG9_input[3]),
    .S0(ConfigBits[74+0]),
    .S0N(ConfigBits_N[74+0]),
    .S1(ConfigBits[74+1]),
    .S1N(ConfigBits_N[74+1]),
    .X(WW4BEG9)
);

 //switch matrix multiplexer WW4BEG10 MUX-4
assign WW4BEG10_input = {bot2top_UIO_OE6,bot2top_UIO_OUT2,EE4END2,E2END4};
cus_mux41 inst_cus_mux41_WW4BEG10 (
    .A0(WW4BEG10_input[0]),
    .A1(WW4BEG10_input[1]),
    .A2(WW4BEG10_input[2]),
    .A3(WW4BEG10_input[3]),
    .S0(ConfigBits[76+0]),
    .S0N(ConfigBits_N[76+0]),
    .S1(ConfigBits[76+1]),
    .S1N(ConfigBits_N[76+1]),
    .X(WW4BEG10)
);

 //switch matrix multiplexer WW4BEG11 MUX-4
assign WW4BEG11_input = {bot2top_UIO_OE7,bot2top_UIO_OUT3,EE4END3,E2END5};
cus_mux41 inst_cus_mux41_WW4BEG11 (
    .A0(WW4BEG11_input[0]),
    .A1(WW4BEG11_input[1]),
    .A2(WW4BEG11_input[2]),
    .A3(WW4BEG11_input[3]),
    .S0(ConfigBits[78+0]),
    .S0N(ConfigBits_N[78+0]),
    .S1(ConfigBits[78+1]),
    .S1N(ConfigBits_N[78+1]),
    .X(WW4BEG11)
);

 //switch matrix multiplexer WW4BEG12 MUX-4
assign WW4BEG12_input = {bot2top_UIO_OE0,bot2top_UIO_OUT4,EE4END4,E2END6};
cus_mux41 inst_cus_mux41_WW4BEG12 (
    .A0(WW4BEG12_input[0]),
    .A1(WW4BEG12_input[1]),
    .A2(WW4BEG12_input[2]),
    .A3(WW4BEG12_input[3]),
    .S0(ConfigBits[80+0]),
    .S0N(ConfigBits_N[80+0]),
    .S1(ConfigBits[80+1]),
    .S1N(ConfigBits_N[80+1]),
    .X(WW4BEG12)
);

 //switch matrix multiplexer WW4BEG13 MUX-4
assign WW4BEG13_input = {bot2top_UIO_OE1,bot2top_UIO_OUT5,EE4END5,E2END7};
cus_mux41 inst_cus_mux41_WW4BEG13 (
    .A0(WW4BEG13_input[0]),
    .A1(WW4BEG13_input[1]),
    .A2(WW4BEG13_input[2]),
    .A3(WW4BEG13_input[3]),
    .S0(ConfigBits[82+0]),
    .S0N(ConfigBits_N[82+0]),
    .S1(ConfigBits[82+1]),
    .S1N(ConfigBits_N[82+1]),
    .X(WW4BEG13)
);

 //switch matrix multiplexer WW4BEG14 MUX-4
assign WW4BEG14_input = {bot2top_UIO_OE2,bot2top_UIO_OUT6,EE4END6,E1END1};
cus_mux41 inst_cus_mux41_WW4BEG14 (
    .A0(WW4BEG14_input[0]),
    .A1(WW4BEG14_input[1]),
    .A2(WW4BEG14_input[2]),
    .A3(WW4BEG14_input[3]),
    .S0(ConfigBits[84+0]),
    .S0N(ConfigBits_N[84+0]),
    .S1(ConfigBits[84+1]),
    .S1N(ConfigBits_N[84+1]),
    .X(WW4BEG14)
);

 //switch matrix multiplexer WW4BEG15 MUX-4
assign WW4BEG15_input = {bot2top_UIO_OE3,bot2top_UIO_OUT7,EE4END7,E1END0};
cus_mux41 inst_cus_mux41_WW4BEG15 (
    .A0(WW4BEG15_input[0]),
    .A1(WW4BEG15_input[1]),
    .A2(WW4BEG15_input[2]),
    .A3(WW4BEG15_input[3]),
    .S0(ConfigBits[86+0]),
    .S0N(ConfigBits_N[86+0]),
    .S1(ConfigBits[86+1]),
    .S1N(ConfigBits_N[86+1]),
    .X(WW4BEG15)
);

 //switch matrix multiplexer W6BEG0 MUX-2
assign W6BEG0_input = {bot2top_UIO_OUT0,EE4END0};
cus_mux21 inst_cus_mux21_W6BEG0 (
    .A0(W6BEG0_input[0]),
    .A1(W6BEG0_input[1]),
    .S(ConfigBits[88+0]),
    .X(W6BEG0)
);

 //switch matrix multiplexer W6BEG1 MUX-2
assign W6BEG1_input = {bot2top_UIO_OUT1,EE4END1};
cus_mux21 inst_cus_mux21_W6BEG1 (
    .A0(W6BEG1_input[0]),
    .A1(W6BEG1_input[1]),
    .S(ConfigBits[89+0]),
    .X(W6BEG1)
);

 //switch matrix multiplexer W6BEG2 MUX-2
assign W6BEG2_input = {bot2top_UIO_OUT2,EE4END2};
cus_mux21 inst_cus_mux21_W6BEG2 (
    .A0(W6BEG2_input[0]),
    .A1(W6BEG2_input[1]),
    .S(ConfigBits[90+0]),
    .X(W6BEG2)
);

 //switch matrix multiplexer W6BEG3 MUX-2
assign W6BEG3_input = {bot2top_UIO_OUT3,EE4END3};
cus_mux21 inst_cus_mux21_W6BEG3 (
    .A0(W6BEG3_input[0]),
    .A1(W6BEG3_input[1]),
    .S(ConfigBits[91+0]),
    .X(W6BEG3)
);

 //switch matrix multiplexer W6BEG4 MUX-2
assign W6BEG4_input = {bot2top_UIO_OE4,bot2top_UIO_OUT7};
cus_mux21 inst_cus_mux21_W6BEG4 (
    .A0(W6BEG4_input[0]),
    .A1(W6BEG4_input[1]),
    .S(ConfigBits[92+0]),
    .X(W6BEG4)
);

 //switch matrix multiplexer W6BEG5 MUX-2
assign W6BEG5_input = {bot2top_UIO_OE5,bot2top_UIO_OUT6};
cus_mux21 inst_cus_mux21_W6BEG5 (
    .A0(W6BEG5_input[0]),
    .A1(W6BEG5_input[1]),
    .S(ConfigBits[93+0]),
    .X(W6BEG5)
);

 //switch matrix multiplexer W6BEG6 MUX-2
assign W6BEG6_input = {bot2top_UIO_OE6,bot2top_UIO_OUT5};
cus_mux21 inst_cus_mux21_W6BEG6 (
    .A0(W6BEG6_input[0]),
    .A1(W6BEG6_input[1]),
    .S(ConfigBits[94+0]),
    .X(W6BEG6)
);

 //switch matrix multiplexer W6BEG7 MUX-2
assign W6BEG7_input = {bot2top_UIO_OE7,bot2top_UIO_OUT4};
cus_mux21 inst_cus_mux21_W6BEG7 (
    .A0(W6BEG7_input[0]),
    .A1(W6BEG7_input[1]),
    .S(ConfigBits[95+0]),
    .X(W6BEG7)
);

 //switch matrix multiplexer W6BEG8 MUX-2
assign W6BEG8_input = {bot2top_UIO_OE0,E6END0};
cus_mux21 inst_cus_mux21_W6BEG8 (
    .A0(W6BEG8_input[0]),
    .A1(W6BEG8_input[1]),
    .S(ConfigBits[96+0]),
    .X(W6BEG8)
);

 //switch matrix multiplexer W6BEG9 MUX-2
assign W6BEG9_input = {bot2top_UIO_OE1,E6END4};
cus_mux21 inst_cus_mux21_W6BEG9 (
    .A0(W6BEG9_input[0]),
    .A1(W6BEG9_input[1]),
    .S(ConfigBits[97+0]),
    .X(W6BEG9)
);

 //switch matrix multiplexer W6BEG10 MUX-2
assign W6BEG10_input = {bot2top_UIO_OE2,E6END8};
cus_mux21 inst_cus_mux21_W6BEG10 (
    .A0(W6BEG10_input[0]),
    .A1(W6BEG10_input[1]),
    .S(ConfigBits[98+0]),
    .X(W6BEG10)
);

 //switch matrix multiplexer W6BEG11 MUX-2
assign W6BEG11_input = {bot2top_UIO_OE3,E6END11};
cus_mux21 inst_cus_mux21_W6BEG11 (
    .A0(W6BEG11_input[0]),
    .A1(W6BEG11_input[1]),
    .S(ConfigBits[99+0]),
    .X(W6BEG11)
);

 //switch matrix multiplexer top2bot_UIO_IN0 MUX-8
assign top2bot_UIO_IN0_input = {VCC0,GND0,E6END8,EE4END15,EE4END3,E2END0,E2MID4,E1END0};
cus_mux81 inst_cus_mux81_top2bot_UIO_IN0 (
    .A0(top2bot_UIO_IN0_input[0]),
    .A1(top2bot_UIO_IN0_input[1]),
    .A2(top2bot_UIO_IN0_input[2]),
    .A3(top2bot_UIO_IN0_input[3]),
    .A4(top2bot_UIO_IN0_input[4]),
    .A5(top2bot_UIO_IN0_input[5]),
    .A6(top2bot_UIO_IN0_input[6]),
    .A7(top2bot_UIO_IN0_input[7]),
    .S0(ConfigBits[100+0]),
    .S0N(ConfigBits_N[100+0]),
    .S1(ConfigBits[100+1]),
    .S1N(ConfigBits_N[100+1]),
    .S2(ConfigBits[100+2]),
    .S2N(ConfigBits_N[100+2]),
    .X(top2bot_UIO_IN0)
);

 //switch matrix multiplexer top2bot_UIO_IN1 MUX-8
assign top2bot_UIO_IN1_input = {VCC0,GND0,E6END9,EE4END14,EE4END2,E2END1,E2MID5,E1END1};
cus_mux81 inst_cus_mux81_top2bot_UIO_IN1 (
    .A0(top2bot_UIO_IN1_input[0]),
    .A1(top2bot_UIO_IN1_input[1]),
    .A2(top2bot_UIO_IN1_input[2]),
    .A3(top2bot_UIO_IN1_input[3]),
    .A4(top2bot_UIO_IN1_input[4]),
    .A5(top2bot_UIO_IN1_input[5]),
    .A6(top2bot_UIO_IN1_input[6]),
    .A7(top2bot_UIO_IN1_input[7]),
    .S0(ConfigBits[103+0]),
    .S0N(ConfigBits_N[103+0]),
    .S1(ConfigBits[103+1]),
    .S1N(ConfigBits_N[103+1]),
    .S2(ConfigBits[103+2]),
    .S2N(ConfigBits_N[103+2]),
    .X(top2bot_UIO_IN1)
);

 //switch matrix multiplexer top2bot_UIO_IN2 MUX-8
assign top2bot_UIO_IN2_input = {VCC0,GND0,E6END10,EE4END13,EE4END1,E2END2,E2MID6,E1END2};
cus_mux81 inst_cus_mux81_top2bot_UIO_IN2 (
    .A0(top2bot_UIO_IN2_input[0]),
    .A1(top2bot_UIO_IN2_input[1]),
    .A2(top2bot_UIO_IN2_input[2]),
    .A3(top2bot_UIO_IN2_input[3]),
    .A4(top2bot_UIO_IN2_input[4]),
    .A5(top2bot_UIO_IN2_input[5]),
    .A6(top2bot_UIO_IN2_input[6]),
    .A7(top2bot_UIO_IN2_input[7]),
    .S0(ConfigBits[106+0]),
    .S0N(ConfigBits_N[106+0]),
    .S1(ConfigBits[106+1]),
    .S1N(ConfigBits_N[106+1]),
    .S2(ConfigBits[106+2]),
    .S2N(ConfigBits_N[106+2]),
    .X(top2bot_UIO_IN2)
);

 //switch matrix multiplexer top2bot_UIO_IN3 MUX-8
assign top2bot_UIO_IN3_input = {VCC0,GND0,E6END11,EE4END12,EE4END0,E2END3,E2MID7,E1END3};
cus_mux81 inst_cus_mux81_top2bot_UIO_IN3 (
    .A0(top2bot_UIO_IN3_input[0]),
    .A1(top2bot_UIO_IN3_input[1]),
    .A2(top2bot_UIO_IN3_input[2]),
    .A3(top2bot_UIO_IN3_input[3]),
    .A4(top2bot_UIO_IN3_input[4]),
    .A5(top2bot_UIO_IN3_input[5]),
    .A6(top2bot_UIO_IN3_input[6]),
    .A7(top2bot_UIO_IN3_input[7]),
    .S0(ConfigBits[109+0]),
    .S0N(ConfigBits_N[109+0]),
    .S1(ConfigBits[109+1]),
    .S1N(ConfigBits_N[109+1]),
    .S2(ConfigBits[109+2]),
    .S2N(ConfigBits_N[109+2]),
    .X(top2bot_UIO_IN3)
);

 //switch matrix multiplexer top2bot_UIO_IN4 MUX-8
assign top2bot_UIO_IN4_input = {VCC0,GND0,E6END0,EE4END11,EE4END7,E2END4,E2MID0,E1END0};
cus_mux81 inst_cus_mux81_top2bot_UIO_IN4 (
    .A0(top2bot_UIO_IN4_input[0]),
    .A1(top2bot_UIO_IN4_input[1]),
    .A2(top2bot_UIO_IN4_input[2]),
    .A3(top2bot_UIO_IN4_input[3]),
    .A4(top2bot_UIO_IN4_input[4]),
    .A5(top2bot_UIO_IN4_input[5]),
    .A6(top2bot_UIO_IN4_input[6]),
    .A7(top2bot_UIO_IN4_input[7]),
    .S0(ConfigBits[112+0]),
    .S0N(ConfigBits_N[112+0]),
    .S1(ConfigBits[112+1]),
    .S1N(ConfigBits_N[112+1]),
    .S2(ConfigBits[112+2]),
    .S2N(ConfigBits_N[112+2]),
    .X(top2bot_UIO_IN4)
);

 //switch matrix multiplexer top2bot_UIO_IN5 MUX-8
assign top2bot_UIO_IN5_input = {VCC0,GND0,E6END1,EE4END10,EE4END6,E2END5,E2MID1,E1END1};
cus_mux81 inst_cus_mux81_top2bot_UIO_IN5 (
    .A0(top2bot_UIO_IN5_input[0]),
    .A1(top2bot_UIO_IN5_input[1]),
    .A2(top2bot_UIO_IN5_input[2]),
    .A3(top2bot_UIO_IN5_input[3]),
    .A4(top2bot_UIO_IN5_input[4]),
    .A5(top2bot_UIO_IN5_input[5]),
    .A6(top2bot_UIO_IN5_input[6]),
    .A7(top2bot_UIO_IN5_input[7]),
    .S0(ConfigBits[115+0]),
    .S0N(ConfigBits_N[115+0]),
    .S1(ConfigBits[115+1]),
    .S1N(ConfigBits_N[115+1]),
    .S2(ConfigBits[115+2]),
    .S2N(ConfigBits_N[115+2]),
    .X(top2bot_UIO_IN5)
);

 //switch matrix multiplexer top2bot_UIO_IN6 MUX-8
assign top2bot_UIO_IN6_input = {VCC0,GND0,E6END2,EE4END9,EE4END5,E2END6,E2MID2,E1END2};
cus_mux81 inst_cus_mux81_top2bot_UIO_IN6 (
    .A0(top2bot_UIO_IN6_input[0]),
    .A1(top2bot_UIO_IN6_input[1]),
    .A2(top2bot_UIO_IN6_input[2]),
    .A3(top2bot_UIO_IN6_input[3]),
    .A4(top2bot_UIO_IN6_input[4]),
    .A5(top2bot_UIO_IN6_input[5]),
    .A6(top2bot_UIO_IN6_input[6]),
    .A7(top2bot_UIO_IN6_input[7]),
    .S0(ConfigBits[118+0]),
    .S0N(ConfigBits_N[118+0]),
    .S1(ConfigBits[118+1]),
    .S1N(ConfigBits_N[118+1]),
    .S2(ConfigBits[118+2]),
    .S2N(ConfigBits_N[118+2]),
    .X(top2bot_UIO_IN6)
);

 //switch matrix multiplexer top2bot_UIO_IN7 MUX-8
assign top2bot_UIO_IN7_input = {VCC0,GND0,E6END3,EE4END8,EE4END4,E2END7,E2MID3,E1END3};
cus_mux81 inst_cus_mux81_top2bot_UIO_IN7 (
    .A0(top2bot_UIO_IN7_input[0]),
    .A1(top2bot_UIO_IN7_input[1]),
    .A2(top2bot_UIO_IN7_input[2]),
    .A3(top2bot_UIO_IN7_input[3]),
    .A4(top2bot_UIO_IN7_input[4]),
    .A5(top2bot_UIO_IN7_input[5]),
    .A6(top2bot_UIO_IN7_input[6]),
    .A7(top2bot_UIO_IN7_input[7]),
    .S0(ConfigBits[121+0]),
    .S0N(ConfigBits_N[121+0]),
    .S1(ConfigBits[121+1]),
    .S1N(ConfigBits_N[121+1]),
    .S2(ConfigBits[121+2]),
    .S2N(ConfigBits_N[121+2]),
    .X(top2bot_UIO_IN7)
);

endmodule