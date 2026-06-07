module W_TT_IF2_bot
    #(
`ifdef EMULATION
        parameter [639:0] Emulate_Bitstream=640'b0,
`endif
        parameter MaxFramesPerCol=20,
        parameter FrameBitsPerRow=32,
        parameter NoConfigBits=141
    )
    (
 //N
        input  [3:0] S_GBUF_FEED_END,        //Port(Name=S_GBUF_FEED_END,IO=INPUT,XOffset=0,YOffset=1,WireCount=4,Side=N)
        output  [3:0] N_GBUF_BEG,        //Port(Name=N_GBUF_BEG,IO=OUTPUT,XOffset=0,YOffset=-1,WireCount=4,Side=N)
        output  [7:0] bot2top_UIO_OUT,        //Port(Name=bot2top_UIO_OUT,IO=OUTPUT,XOffset=0,YOffset=-1,WireCount=8,Side=N)
        output  [7:0] bot2top_UIO_OE,        //Port(Name=bot2top_UIO_OE,IO=OUTPUT,XOffset=0,YOffset=-1,WireCount=8,Side=N)
        input  [7:0] top2bot_UIO_IN,        //Port(Name=top2bot_UIO_IN,IO=INPUT,XOffset=0,YOffset=1,WireCount=8,Side=N)
 //E
        input  [3:0] W1END,        //Port(Name=W1END,IO=INPUT,XOffset=-1,YOffset=0,WireCount=4,Side=E)
        input  [7:0] W2MID,        //Port(Name=W2MID,IO=INPUT,XOffset=-1,YOffset=0,WireCount=8,Side=E)
        input  [7:0] W2END,        //Port(Name=W2END,IO=INPUT,XOffset=-1,YOffset=0,WireCount=8,Side=E)
        input  [15:0] WW4END,        //Port(Name=WW4END,IO=INPUT,XOffset=-4,YOffset=0,WireCount=4,Side=E)
        input  [11:0] W6END,        //Port(Name=W6END,IO=INPUT,XOffset=-6,YOffset=0,WireCount=2,Side=E)
        output  [3:0] E1BEG,        //Port(Name=E1BEG,IO=OUTPUT,XOffset=1,YOffset=0,WireCount=4,Side=E)
        output  [7:0] E2BEG,        //Port(Name=E2BEG,IO=OUTPUT,XOffset=1,YOffset=0,WireCount=8,Side=E)
        output  [7:0] E2BEGb,        //Port(Name=E2BEGb,IO=OUTPUT,XOffset=1,YOffset=0,WireCount=8,Side=E)
        output  [15:0] EE4BEG,        //Port(Name=EE4BEG,IO=OUTPUT,XOffset=4,YOffset=0,WireCount=4,Side=E)
        output  [11:0] E6BEG,        //Port(Name=E6BEG,IO=OUTPUT,XOffset=6,YOffset=0,WireCount=2,Side=E)
 //S
        output  [3:0] S_GBUF_FEED_BEG,        //Port(Name=S_GBUF_FEED_BEG,IO=OUTPUT,XOffset=0,YOffset=1,WireCount=4,Side=S)
        input  [3:0] N_GBUF_END,        //Port(Name=N_GBUF_END,IO=INPUT,XOffset=0,YOffset=-1,WireCount=4,Side=S)
        input  UO_OUT_TT_PROJECT0,
        input  UO_OUT_TT_PROJECT1,
        input  UO_OUT_TT_PROJECT2,
        input  UO_OUT_TT_PROJECT3,
        input  UO_OUT_TT_PROJECT4,
        input  UO_OUT_TT_PROJECT5,
        input  UO_OUT_TT_PROJECT6,
        input  UO_OUT_TT_PROJECT7,
        input  UIO_OUT_TT_PROJECT0,
        input  UIO_OUT_TT_PROJECT1,
        input  UIO_OUT_TT_PROJECT2,
        input  UIO_OUT_TT_PROJECT3,
        input  UIO_OUT_TT_PROJECT4,
        input  UIO_OUT_TT_PROJECT5,
        input  UIO_OUT_TT_PROJECT6,
        input  UIO_OUT_TT_PROJECT7,
        input  UIO_OE_TT_PROJECT0,
        input  UIO_OE_TT_PROJECT1,
        input  UIO_OE_TT_PROJECT2,
        input  UIO_OE_TT_PROJECT3,
        input  UIO_OE_TT_PROJECT4,
        input  UIO_OE_TT_PROJECT5,
        input  UIO_OE_TT_PROJECT6,
        input  UIO_OE_TT_PROJECT7,
        output  UI_IN_TT_PROJECT0,
        output  UI_IN_TT_PROJECT1,
        output  UI_IN_TT_PROJECT2,
        output  UI_IN_TT_PROJECT3,
        output  UI_IN_TT_PROJECT4,
        output  UI_IN_TT_PROJECT5,
        output  UI_IN_TT_PROJECT6,
        output  UI_IN_TT_PROJECT7,
        output  UIO_IN_TT_PROJECT0,
        output  UIO_IN_TT_PROJECT1,
        output  UIO_IN_TT_PROJECT2,
        output  UIO_IN_TT_PROJECT3,
        output  UIO_IN_TT_PROJECT4,
        output  UIO_IN_TT_PROJECT5,
        output  UIO_IN_TT_PROJECT6,
        output  UIO_IN_TT_PROJECT7,
        output  ENA_TT_PROJECT,
        output  CLK_TT_PROJECT,
        output  RST_N_TT_PROJECT,
    //Tile IO ports from BELs
        input  [FrameBitsPerRow-1:0] FrameData, //CONFIG_PORT
        output  [FrameBitsPerRow-1:0] FrameData_O,
        input  [MaxFramesPerCol-1:0] FrameStrobe, //CONFIG_PORT
        output  [MaxFramesPerCol-1:0] FrameStrobe_O
    //global
);
 //signal declarations
 //BEL ports (e.g., slices)
wire UI_IN0;
wire UI_IN1;
wire UI_IN2;
wire UI_IN3;
wire UI_IN4;
wire UI_IN5;
wire UI_IN6;
wire UI_IN7;
wire UIO_IN0;
wire UIO_IN1;
wire UIO_IN2;
wire UIO_IN3;
wire UIO_IN4;
wire UIO_IN5;
wire UIO_IN6;
wire UIO_IN7;
wire ENA;
wire CLK;
wire RST_N;
wire UO_OUT0;
wire UO_OUT1;
wire UO_OUT2;
wire UO_OUT3;
wire UO_OUT4;
wire UO_OUT5;
wire UO_OUT6;
wire UO_OUT7;
wire UIO_OUT0;
wire UIO_OUT1;
wire UIO_OUT2;
wire UIO_OUT3;
wire UIO_OUT4;
wire UIO_OUT5;
wire UIO_OUT6;
wire UIO_OUT7;
wire UIO_OE0;
wire UIO_OE1;
wire UIO_OE2;
wire UIO_OE3;
wire UIO_OE4;
wire UIO_OE5;
wire UIO_OE6;
wire UIO_OE7;
 //Jump wires
 //internal configuration data signal to daisy-chain all BELs (if any and in the order they are listed in the fabric.csv)
wire[NoConfigBits-1:0] ConfigBits;
wire[NoConfigBits-1:0] ConfigBits_N;

 //Connection for outgoing wires
wire[FrameBitsPerRow-1:0] FrameData_i;
wire[FrameBitsPerRow-1:0] FrameData_O_i;
wire[MaxFramesPerCol-1:0] FrameStrobe_i;
wire[MaxFramesPerCol-1:0] FrameStrobe_O_i;

assign FrameData_O_i = FrameData_i;

my_buf data_inbuf_0 (
    .A(FrameData[0]),
    .X(FrameData_i[0])
);

my_buf data_inbuf_1 (
    .A(FrameData[1]),
    .X(FrameData_i[1])
);

my_buf data_inbuf_2 (
    .A(FrameData[2]),
    .X(FrameData_i[2])
);

my_buf data_inbuf_3 (
    .A(FrameData[3]),
    .X(FrameData_i[3])
);

my_buf data_inbuf_4 (
    .A(FrameData[4]),
    .X(FrameData_i[4])
);

my_buf data_inbuf_5 (
    .A(FrameData[5]),
    .X(FrameData_i[5])
);

my_buf data_inbuf_6 (
    .A(FrameData[6]),
    .X(FrameData_i[6])
);

my_buf data_inbuf_7 (
    .A(FrameData[7]),
    .X(FrameData_i[7])
);

my_buf data_inbuf_8 (
    .A(FrameData[8]),
    .X(FrameData_i[8])
);

my_buf data_inbuf_9 (
    .A(FrameData[9]),
    .X(FrameData_i[9])
);

my_buf data_inbuf_10 (
    .A(FrameData[10]),
    .X(FrameData_i[10])
);

my_buf data_inbuf_11 (
    .A(FrameData[11]),
    .X(FrameData_i[11])
);

my_buf data_inbuf_12 (
    .A(FrameData[12]),
    .X(FrameData_i[12])
);

my_buf data_inbuf_13 (
    .A(FrameData[13]),
    .X(FrameData_i[13])
);

my_buf data_inbuf_14 (
    .A(FrameData[14]),
    .X(FrameData_i[14])
);

my_buf data_inbuf_15 (
    .A(FrameData[15]),
    .X(FrameData_i[15])
);

my_buf data_inbuf_16 (
    .A(FrameData[16]),
    .X(FrameData_i[16])
);

my_buf data_inbuf_17 (
    .A(FrameData[17]),
    .X(FrameData_i[17])
);

my_buf data_inbuf_18 (
    .A(FrameData[18]),
    .X(FrameData_i[18])
);

my_buf data_inbuf_19 (
    .A(FrameData[19]),
    .X(FrameData_i[19])
);

my_buf data_inbuf_20 (
    .A(FrameData[20]),
    .X(FrameData_i[20])
);

my_buf data_inbuf_21 (
    .A(FrameData[21]),
    .X(FrameData_i[21])
);

my_buf data_inbuf_22 (
    .A(FrameData[22]),
    .X(FrameData_i[22])
);

my_buf data_inbuf_23 (
    .A(FrameData[23]),
    .X(FrameData_i[23])
);

my_buf data_inbuf_24 (
    .A(FrameData[24]),
    .X(FrameData_i[24])
);

my_buf data_inbuf_25 (
    .A(FrameData[25]),
    .X(FrameData_i[25])
);

my_buf data_inbuf_26 (
    .A(FrameData[26]),
    .X(FrameData_i[26])
);

my_buf data_inbuf_27 (
    .A(FrameData[27]),
    .X(FrameData_i[27])
);

my_buf data_inbuf_28 (
    .A(FrameData[28]),
    .X(FrameData_i[28])
);

my_buf data_inbuf_29 (
    .A(FrameData[29]),
    .X(FrameData_i[29])
);

my_buf data_inbuf_30 (
    .A(FrameData[30]),
    .X(FrameData_i[30])
);

my_buf data_inbuf_31 (
    .A(FrameData[31]),
    .X(FrameData_i[31])
);

my_buf data_outbuf_0 (
    .A(FrameData_O_i[0]),
    .X(FrameData_O[0])
);

my_buf data_outbuf_1 (
    .A(FrameData_O_i[1]),
    .X(FrameData_O[1])
);

my_buf data_outbuf_2 (
    .A(FrameData_O_i[2]),
    .X(FrameData_O[2])
);

my_buf data_outbuf_3 (
    .A(FrameData_O_i[3]),
    .X(FrameData_O[3])
);

my_buf data_outbuf_4 (
    .A(FrameData_O_i[4]),
    .X(FrameData_O[4])
);

my_buf data_outbuf_5 (
    .A(FrameData_O_i[5]),
    .X(FrameData_O[5])
);

my_buf data_outbuf_6 (
    .A(FrameData_O_i[6]),
    .X(FrameData_O[6])
);

my_buf data_outbuf_7 (
    .A(FrameData_O_i[7]),
    .X(FrameData_O[7])
);

my_buf data_outbuf_8 (
    .A(FrameData_O_i[8]),
    .X(FrameData_O[8])
);

my_buf data_outbuf_9 (
    .A(FrameData_O_i[9]),
    .X(FrameData_O[9])
);

my_buf data_outbuf_10 (
    .A(FrameData_O_i[10]),
    .X(FrameData_O[10])
);

my_buf data_outbuf_11 (
    .A(FrameData_O_i[11]),
    .X(FrameData_O[11])
);

my_buf data_outbuf_12 (
    .A(FrameData_O_i[12]),
    .X(FrameData_O[12])
);

my_buf data_outbuf_13 (
    .A(FrameData_O_i[13]),
    .X(FrameData_O[13])
);

my_buf data_outbuf_14 (
    .A(FrameData_O_i[14]),
    .X(FrameData_O[14])
);

my_buf data_outbuf_15 (
    .A(FrameData_O_i[15]),
    .X(FrameData_O[15])
);

my_buf data_outbuf_16 (
    .A(FrameData_O_i[16]),
    .X(FrameData_O[16])
);

my_buf data_outbuf_17 (
    .A(FrameData_O_i[17]),
    .X(FrameData_O[17])
);

my_buf data_outbuf_18 (
    .A(FrameData_O_i[18]),
    .X(FrameData_O[18])
);

my_buf data_outbuf_19 (
    .A(FrameData_O_i[19]),
    .X(FrameData_O[19])
);

my_buf data_outbuf_20 (
    .A(FrameData_O_i[20]),
    .X(FrameData_O[20])
);

my_buf data_outbuf_21 (
    .A(FrameData_O_i[21]),
    .X(FrameData_O[21])
);

my_buf data_outbuf_22 (
    .A(FrameData_O_i[22]),
    .X(FrameData_O[22])
);

my_buf data_outbuf_23 (
    .A(FrameData_O_i[23]),
    .X(FrameData_O[23])
);

my_buf data_outbuf_24 (
    .A(FrameData_O_i[24]),
    .X(FrameData_O[24])
);

my_buf data_outbuf_25 (
    .A(FrameData_O_i[25]),
    .X(FrameData_O[25])
);

my_buf data_outbuf_26 (
    .A(FrameData_O_i[26]),
    .X(FrameData_O[26])
);

my_buf data_outbuf_27 (
    .A(FrameData_O_i[27]),
    .X(FrameData_O[27])
);

my_buf data_outbuf_28 (
    .A(FrameData_O_i[28]),
    .X(FrameData_O[28])
);

my_buf data_outbuf_29 (
    .A(FrameData_O_i[29]),
    .X(FrameData_O[29])
);

my_buf data_outbuf_30 (
    .A(FrameData_O_i[30]),
    .X(FrameData_O[30])
);

my_buf data_outbuf_31 (
    .A(FrameData_O_i[31]),
    .X(FrameData_O[31])
);

assign FrameStrobe_O_i = FrameStrobe_i;

my_buf strobe_inbuf_0 (
    .A(FrameStrobe[0]),
    .X(FrameStrobe_i[0])
);

my_buf strobe_inbuf_1 (
    .A(FrameStrobe[1]),
    .X(FrameStrobe_i[1])
);

my_buf strobe_inbuf_2 (
    .A(FrameStrobe[2]),
    .X(FrameStrobe_i[2])
);

my_buf strobe_inbuf_3 (
    .A(FrameStrobe[3]),
    .X(FrameStrobe_i[3])
);

my_buf strobe_inbuf_4 (
    .A(FrameStrobe[4]),
    .X(FrameStrobe_i[4])
);

my_buf strobe_inbuf_5 (
    .A(FrameStrobe[5]),
    .X(FrameStrobe_i[5])
);

my_buf strobe_inbuf_6 (
    .A(FrameStrobe[6]),
    .X(FrameStrobe_i[6])
);

my_buf strobe_inbuf_7 (
    .A(FrameStrobe[7]),
    .X(FrameStrobe_i[7])
);

my_buf strobe_inbuf_8 (
    .A(FrameStrobe[8]),
    .X(FrameStrobe_i[8])
);

my_buf strobe_inbuf_9 (
    .A(FrameStrobe[9]),
    .X(FrameStrobe_i[9])
);

my_buf strobe_inbuf_10 (
    .A(FrameStrobe[10]),
    .X(FrameStrobe_i[10])
);

my_buf strobe_inbuf_11 (
    .A(FrameStrobe[11]),
    .X(FrameStrobe_i[11])
);

my_buf strobe_inbuf_12 (
    .A(FrameStrobe[12]),
    .X(FrameStrobe_i[12])
);

my_buf strobe_inbuf_13 (
    .A(FrameStrobe[13]),
    .X(FrameStrobe_i[13])
);

my_buf strobe_inbuf_14 (
    .A(FrameStrobe[14]),
    .X(FrameStrobe_i[14])
);

my_buf strobe_inbuf_15 (
    .A(FrameStrobe[15]),
    .X(FrameStrobe_i[15])
);

my_buf strobe_inbuf_16 (
    .A(FrameStrobe[16]),
    .X(FrameStrobe_i[16])
);

my_buf strobe_inbuf_17 (
    .A(FrameStrobe[17]),
    .X(FrameStrobe_i[17])
);

my_buf strobe_inbuf_18 (
    .A(FrameStrobe[18]),
    .X(FrameStrobe_i[18])
);

my_buf strobe_inbuf_19 (
    .A(FrameStrobe[19]),
    .X(FrameStrobe_i[19])
);

my_buf strobe_outbuf_0 (
    .A(FrameStrobe_O_i[0]),
    .X(FrameStrobe_O[0])
);

my_buf strobe_outbuf_1 (
    .A(FrameStrobe_O_i[1]),
    .X(FrameStrobe_O[1])
);

my_buf strobe_outbuf_2 (
    .A(FrameStrobe_O_i[2]),
    .X(FrameStrobe_O[2])
);

my_buf strobe_outbuf_3 (
    .A(FrameStrobe_O_i[3]),
    .X(FrameStrobe_O[3])
);

my_buf strobe_outbuf_4 (
    .A(FrameStrobe_O_i[4]),
    .X(FrameStrobe_O[4])
);

my_buf strobe_outbuf_5 (
    .A(FrameStrobe_O_i[5]),
    .X(FrameStrobe_O[5])
);

my_buf strobe_outbuf_6 (
    .A(FrameStrobe_O_i[6]),
    .X(FrameStrobe_O[6])
);

my_buf strobe_outbuf_7 (
    .A(FrameStrobe_O_i[7]),
    .X(FrameStrobe_O[7])
);

my_buf strobe_outbuf_8 (
    .A(FrameStrobe_O_i[8]),
    .X(FrameStrobe_O[8])
);

my_buf strobe_outbuf_9 (
    .A(FrameStrobe_O_i[9]),
    .X(FrameStrobe_O[9])
);

my_buf strobe_outbuf_10 (
    .A(FrameStrobe_O_i[10]),
    .X(FrameStrobe_O[10])
);

my_buf strobe_outbuf_11 (
    .A(FrameStrobe_O_i[11]),
    .X(FrameStrobe_O[11])
);

my_buf strobe_outbuf_12 (
    .A(FrameStrobe_O_i[12]),
    .X(FrameStrobe_O[12])
);

my_buf strobe_outbuf_13 (
    .A(FrameStrobe_O_i[13]),
    .X(FrameStrobe_O[13])
);

my_buf strobe_outbuf_14 (
    .A(FrameStrobe_O_i[14]),
    .X(FrameStrobe_O[14])
);

my_buf strobe_outbuf_15 (
    .A(FrameStrobe_O_i[15]),
    .X(FrameStrobe_O[15])
);

my_buf strobe_outbuf_16 (
    .A(FrameStrobe_O_i[16]),
    .X(FrameStrobe_O[16])
);

my_buf strobe_outbuf_17 (
    .A(FrameStrobe_O_i[17]),
    .X(FrameStrobe_O[17])
);

my_buf strobe_outbuf_18 (
    .A(FrameStrobe_O_i[18]),
    .X(FrameStrobe_O[18])
);

my_buf strobe_outbuf_19 (
    .A(FrameStrobe_O_i[19]),
    .X(FrameStrobe_O[19])
);


 //configuration storage latches
W_TT_IF2_bot_ConfigMem
`ifdef EMULATION
    #(
    .Emulate_Bitstream(Emulate_Bitstream)
    )
`endif
    Inst_W_TT_IF2_bot_ConfigMem
    (
    .FrameData(FrameData),
    .FrameStrobe(FrameStrobe),
    .ConfigBits(ConfigBits),
    .ConfigBits_N(ConfigBits_N)
);


 //BEL component instantiations
TT_PROJECT Inst_TT_PROJECT (
    .UI_IN({UI_IN7, UI_IN6, UI_IN5, UI_IN4, UI_IN3, UI_IN2, UI_IN1, UI_IN0}),
    .UO_OUT({UO_OUT7, UO_OUT6, UO_OUT5, UO_OUT4, UO_OUT3, UO_OUT2, UO_OUT1, UO_OUT0}),
    .UIO_IN({UIO_IN7, UIO_IN6, UIO_IN5, UIO_IN4, UIO_IN3, UIO_IN2, UIO_IN1, UIO_IN0}),
    .UIO_OUT({UIO_OUT7, UIO_OUT6, UIO_OUT5, UIO_OUT4, UIO_OUT3, UIO_OUT2, UIO_OUT1, UIO_OUT0}),
    .UIO_OE({UIO_OE7, UIO_OE6, UIO_OE5, UIO_OE4, UIO_OE3, UIO_OE2, UIO_OE1, UIO_OE0}),
    .ENA(ENA),
    .CLK(CLK),
    .RST_N(RST_N),
    .UI_IN_TT_PROJECT({UI_IN_TT_PROJECT7, UI_IN_TT_PROJECT6, UI_IN_TT_PROJECT5, UI_IN_TT_PROJECT4, UI_IN_TT_PROJECT3, UI_IN_TT_PROJECT2, UI_IN_TT_PROJECT1, UI_IN_TT_PROJECT0}),
    .UO_OUT_TT_PROJECT({UO_OUT_TT_PROJECT7, UO_OUT_TT_PROJECT6, UO_OUT_TT_PROJECT5, UO_OUT_TT_PROJECT4, UO_OUT_TT_PROJECT3, UO_OUT_TT_PROJECT2, UO_OUT_TT_PROJECT1, UO_OUT_TT_PROJECT0}),
    .UIO_IN_TT_PROJECT({UIO_IN_TT_PROJECT7, UIO_IN_TT_PROJECT6, UIO_IN_TT_PROJECT5, UIO_IN_TT_PROJECT4, UIO_IN_TT_PROJECT3, UIO_IN_TT_PROJECT2, UIO_IN_TT_PROJECT1, UIO_IN_TT_PROJECT0}),
    .UIO_OUT_TT_PROJECT({UIO_OUT_TT_PROJECT7, UIO_OUT_TT_PROJECT6, UIO_OUT_TT_PROJECT5, UIO_OUT_TT_PROJECT4, UIO_OUT_TT_PROJECT3, UIO_OUT_TT_PROJECT2, UIO_OUT_TT_PROJECT1, UIO_OUT_TT_PROJECT0}),
    .UIO_OE_TT_PROJECT({UIO_OE_TT_PROJECT7, UIO_OE_TT_PROJECT6, UIO_OE_TT_PROJECT5, UIO_OE_TT_PROJECT4, UIO_OE_TT_PROJECT3, UIO_OE_TT_PROJECT2, UIO_OE_TT_PROJECT1, UIO_OE_TT_PROJECT0}),
    .ENA_TT_PROJECT(ENA_TT_PROJECT),
    .CLK_TT_PROJECT(CLK_TT_PROJECT),
    .RST_N_TT_PROJECT(RST_N_TT_PROJECT)
);

W_TT_IF2_bot_switch_matrix Inst_W_TT_IF2_bot_switch_matrix (
    .S_GBUF_FEED_END0(S_GBUF_FEED_END[0]),
    .S_GBUF_FEED_END1(S_GBUF_FEED_END[1]),
    .S_GBUF_FEED_END2(S_GBUF_FEED_END[2]),
    .S_GBUF_FEED_END3(S_GBUF_FEED_END[3]),
    .N_GBUF_END0(N_GBUF_END[0]),
    .N_GBUF_END1(N_GBUF_END[1]),
    .N_GBUF_END2(N_GBUF_END[2]),
    .N_GBUF_END3(N_GBUF_END[3]),
    .W1END0(W1END[0]),
    .W1END1(W1END[1]),
    .W1END2(W1END[2]),
    .W1END3(W1END[3]),
    .W2MID0(W2MID[0]),
    .W2MID1(W2MID[1]),
    .W2MID2(W2MID[2]),
    .W2MID3(W2MID[3]),
    .W2MID4(W2MID[4]),
    .W2MID5(W2MID[5]),
    .W2MID6(W2MID[6]),
    .W2MID7(W2MID[7]),
    .W2END0(W2END[0]),
    .W2END1(W2END[1]),
    .W2END2(W2END[2]),
    .W2END3(W2END[3]),
    .W2END4(W2END[4]),
    .W2END5(W2END[5]),
    .W2END6(W2END[6]),
    .W2END7(W2END[7]),
    .WW4END0(WW4END[0]),
    .WW4END1(WW4END[1]),
    .WW4END2(WW4END[2]),
    .WW4END3(WW4END[3]),
    .WW4END4(WW4END[4]),
    .WW4END5(WW4END[5]),
    .WW4END6(WW4END[6]),
    .WW4END7(WW4END[7]),
    .WW4END8(WW4END[8]),
    .WW4END9(WW4END[9]),
    .WW4END10(WW4END[10]),
    .WW4END11(WW4END[11]),
    .WW4END12(WW4END[12]),
    .WW4END13(WW4END[13]),
    .WW4END14(WW4END[14]),
    .WW4END15(WW4END[15]),
    .W6END0(W6END[0]),
    .W6END1(W6END[1]),
    .W6END2(W6END[2]),
    .W6END3(W6END[3]),
    .W6END4(W6END[4]),
    .W6END5(W6END[5]),
    .W6END6(W6END[6]),
    .W6END7(W6END[7]),
    .W6END8(W6END[8]),
    .W6END9(W6END[9]),
    .W6END10(W6END[10]),
    .W6END11(W6END[11]),
    .top2bot_UIO_IN0(top2bot_UIO_IN[0]),
    .top2bot_UIO_IN1(top2bot_UIO_IN[1]),
    .top2bot_UIO_IN2(top2bot_UIO_IN[2]),
    .top2bot_UIO_IN3(top2bot_UIO_IN[3]),
    .top2bot_UIO_IN4(top2bot_UIO_IN[4]),
    .top2bot_UIO_IN5(top2bot_UIO_IN[5]),
    .top2bot_UIO_IN6(top2bot_UIO_IN[6]),
    .top2bot_UIO_IN7(top2bot_UIO_IN[7]),
    .UO_OUT0(UO_OUT0),
    .UO_OUT1(UO_OUT1),
    .UO_OUT2(UO_OUT2),
    .UO_OUT3(UO_OUT3),
    .UO_OUT4(UO_OUT4),
    .UO_OUT5(UO_OUT5),
    .UO_OUT6(UO_OUT6),
    .UO_OUT7(UO_OUT7),
    .UIO_OUT0(UIO_OUT0),
    .UIO_OUT1(UIO_OUT1),
    .UIO_OUT2(UIO_OUT2),
    .UIO_OUT3(UIO_OUT3),
    .UIO_OUT4(UIO_OUT4),
    .UIO_OUT5(UIO_OUT5),
    .UIO_OUT6(UIO_OUT6),
    .UIO_OUT7(UIO_OUT7),
    .UIO_OE0(UIO_OE0),
    .UIO_OE1(UIO_OE1),
    .UIO_OE2(UIO_OE2),
    .UIO_OE3(UIO_OE3),
    .UIO_OE4(UIO_OE4),
    .UIO_OE5(UIO_OE5),
    .UIO_OE6(UIO_OE6),
    .UIO_OE7(UIO_OE7),
    .S_GBUF_FEED_BEG0(S_GBUF_FEED_BEG[0]),
    .S_GBUF_FEED_BEG1(S_GBUF_FEED_BEG[1]),
    .S_GBUF_FEED_BEG2(S_GBUF_FEED_BEG[2]),
    .S_GBUF_FEED_BEG3(S_GBUF_FEED_BEG[3]),
    .N_GBUF_BEG0(N_GBUF_BEG[0]),
    .N_GBUF_BEG1(N_GBUF_BEG[1]),
    .N_GBUF_BEG2(N_GBUF_BEG[2]),
    .N_GBUF_BEG3(N_GBUF_BEG[3]),
    .E1BEG0(E1BEG[0]),
    .E1BEG1(E1BEG[1]),
    .E1BEG2(E1BEG[2]),
    .E1BEG3(E1BEG[3]),
    .E2BEG0(E2BEG[0]),
    .E2BEG1(E2BEG[1]),
    .E2BEG2(E2BEG[2]),
    .E2BEG3(E2BEG[3]),
    .E2BEG4(E2BEG[4]),
    .E2BEG5(E2BEG[5]),
    .E2BEG6(E2BEG[6]),
    .E2BEG7(E2BEG[7]),
    .E2BEGb0(E2BEGb[0]),
    .E2BEGb1(E2BEGb[1]),
    .E2BEGb2(E2BEGb[2]),
    .E2BEGb3(E2BEGb[3]),
    .E2BEGb4(E2BEGb[4]),
    .E2BEGb5(E2BEGb[5]),
    .E2BEGb6(E2BEGb[6]),
    .E2BEGb7(E2BEGb[7]),
    .EE4BEG0(EE4BEG[0]),
    .EE4BEG1(EE4BEG[1]),
    .EE4BEG2(EE4BEG[2]),
    .EE4BEG3(EE4BEG[3]),
    .EE4BEG4(EE4BEG[4]),
    .EE4BEG5(EE4BEG[5]),
    .EE4BEG6(EE4BEG[6]),
    .EE4BEG7(EE4BEG[7]),
    .EE4BEG8(EE4BEG[8]),
    .EE4BEG9(EE4BEG[9]),
    .EE4BEG10(EE4BEG[10]),
    .EE4BEG11(EE4BEG[11]),
    .EE4BEG12(EE4BEG[12]),
    .EE4BEG13(EE4BEG[13]),
    .EE4BEG14(EE4BEG[14]),
    .EE4BEG15(EE4BEG[15]),
    .E6BEG0(E6BEG[0]),
    .E6BEG1(E6BEG[1]),
    .E6BEG2(E6BEG[2]),
    .E6BEG3(E6BEG[3]),
    .E6BEG4(E6BEG[4]),
    .E6BEG5(E6BEG[5]),
    .E6BEG6(E6BEG[6]),
    .E6BEG7(E6BEG[7]),
    .E6BEG8(E6BEG[8]),
    .E6BEG9(E6BEG[9]),
    .E6BEG10(E6BEG[10]),
    .E6BEG11(E6BEG[11]),
    .bot2top_UIO_OUT0(bot2top_UIO_OUT[0]),
    .bot2top_UIO_OUT1(bot2top_UIO_OUT[1]),
    .bot2top_UIO_OUT2(bot2top_UIO_OUT[2]),
    .bot2top_UIO_OUT3(bot2top_UIO_OUT[3]),
    .bot2top_UIO_OUT4(bot2top_UIO_OUT[4]),
    .bot2top_UIO_OUT5(bot2top_UIO_OUT[5]),
    .bot2top_UIO_OUT6(bot2top_UIO_OUT[6]),
    .bot2top_UIO_OUT7(bot2top_UIO_OUT[7]),
    .bot2top_UIO_OE0(bot2top_UIO_OE[0]),
    .bot2top_UIO_OE1(bot2top_UIO_OE[1]),
    .bot2top_UIO_OE2(bot2top_UIO_OE[2]),
    .bot2top_UIO_OE3(bot2top_UIO_OE[3]),
    .bot2top_UIO_OE4(bot2top_UIO_OE[4]),
    .bot2top_UIO_OE5(bot2top_UIO_OE[5]),
    .bot2top_UIO_OE6(bot2top_UIO_OE[6]),
    .bot2top_UIO_OE7(bot2top_UIO_OE[7]),
    .UI_IN0(UI_IN0),
    .UI_IN1(UI_IN1),
    .UI_IN2(UI_IN2),
    .UI_IN3(UI_IN3),
    .UI_IN4(UI_IN4),
    .UI_IN5(UI_IN5),
    .UI_IN6(UI_IN6),
    .UI_IN7(UI_IN7),
    .UIO_IN0(UIO_IN0),
    .UIO_IN1(UIO_IN1),
    .UIO_IN2(UIO_IN2),
    .UIO_IN3(UIO_IN3),
    .UIO_IN4(UIO_IN4),
    .UIO_IN5(UIO_IN5),
    .UIO_IN6(UIO_IN6),
    .UIO_IN7(UIO_IN7),
    .ENA(ENA),
    .CLK(CLK),
    .RST_N(RST_N),
    .ConfigBits(ConfigBits[141-1:0]),
    .ConfigBits_N(ConfigBits_N[141-1:0])
);

endmodule