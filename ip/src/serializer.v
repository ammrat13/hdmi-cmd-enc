`timescale 1ns / 1ps

module serializer(
    input clk_px,
    input clk_5px,
    input reset,

    input [9:0] cmd,
    output cmd_p,
    output cmd_n
);

wire serdes_out;

OBUFDS #(
   .IOSTANDARD("TMDS_33"),
   .SLEW("SLOW")
) outbuf (
   .O(cmd_p),
   .OB(cmd_n),
   .I(serdes_out)
);

wire shift1;
wire shift2;

OSERDESE2 #(
   .DATA_RATE_OQ("DDR"),
   .DATA_WIDTH(10),
   .DATA_RATE_TQ("SDR"),
   .TRISTATE_WIDTH(1),
   .SERDES_MODE("MASTER")
) ser_master (
   .RST(reset),
   .CLK(clk_5px),
   .CLKDIV(clk_px),
   .OCE(1'b1),
   .TCE(1'b0),
   .D1(cmd[0]),
   .D2(cmd[1]),
   .D3(cmd[2]),
   .D4(cmd[3]),
   .D5(cmd[4]),
   .D6(cmd[5]),
   .D7(cmd[6]),
   .D8(cmd[7]),
   .OQ(serdes_out),
   .SHIFTIN1(shift1),
   .SHIFTIN2(shift2)
);

OSERDESE2 #(
   .DATA_RATE_OQ("DDR"),
   .DATA_WIDTH(10),
   .DATA_RATE_TQ("SDR"),
   .TRISTATE_WIDTH(1),
   .SERDES_MODE("SLAVE")
) ser_slave (
   .RST(reset),
   .CLK(clk_5px),
   .CLKDIV(clk_px),
   .OCE(1'b1),
   .TCE(1'b0),
   .D1(1'b0),
   .D2(1'b0),
   .D3(cmd[8]),
   .D4(cmd[9]),
   .D5(1'b0),
   .D6(1'b0),
   .D7(1'b0),
   .D8(1'b0),
   .SHIFTOUT1(shift1),
   .SHIFTOUT2(shift2)
);

endmodule
