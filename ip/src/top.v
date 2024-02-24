`timescale 1ns / 1ps

module top(
    input clk_px,
    input clk_5px,
    input resetn_async,

    input [31:0] commands_tdata,
    input commands_tvalid,
    output commands_tready,

    output hdmi_pulse_p,
    output hdmi_pulse_n,
    output [2:0] hdmi_data_p,
    output [2:0] hdmi_data_n
);

wire resetn;
wire reset;
reset_controller #(
    .NUM_STAGES(2)
) reset_controller (
    .clk(clk_px),
    .resetn_async(resetn_async),
    .resetn(resetn),
    .reset(reset)
);

localparam HDMI_CMD_NOOP = 10'b1101010100;

reg [9:0] hdmi_pulse;
reg [29:0] hdmi_data;
always @(posedge clk_px) begin
    if (resetn == 1'b0) begin
        hdmi_pulse <= 10'b0000000000;
        hdmi_data <= {3{HDMI_CMD_NOOP}};
    end else begin
        hdmi_pulse <= 10'b1111100000;
        if (commands_tvalid == 1'b1) begin
            hdmi_data <= commands_tdata[29:0];
        end else begin
            hdmi_data <= {3{HDMI_CMD_NOOP}};
        end
    end
end

assign commands_tready = 1'b1;

serializer pulse_ser(
    .clk_px(clk_px),
    .clk_5px(clk_5px),
    .reset(reset),
    .cmd(hdmi_pulse),
    .cmd_p(hdmi_pulse_p),
    .cmd_n(hdmi_pulse_n)
);

generate
for (genvar i = 0; i < 3; i = i + 1) begin
    serializer data_ser(
        .clk_px(clk_px),
        .clk_5px(clk_5px),
        .reset(reset),
        .cmd(hdmi_data[10*i+9:10*i]),
        .cmd_p(hdmi_data_p[i]),
        .cmd_n(hdmi_data_n[i])
    );
end
endgenerate

endmodule
