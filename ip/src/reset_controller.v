`timescale 1ns / 1ps

module reset_controller #(
    parameter NUM_STAGES = 2
)(
    input clk,
    input resetn_async,
    output resetn,
    output reset
);

reg [NUM_STAGES-1:0] stages;

always @(posedge clk, negedge resetn_async) begin
    if (resetn_async == 1'b0) begin
        stages[0] <= 1'b0;
    end else begin
        stages[0] <= 1'b1;
    end
end

generate
for (genvar i = 1; i < NUM_STAGES; i = i + 1) begin
    always @(posedge clk, negedge resetn_async) begin
        if (resetn_async == 1'b0) begin
            stages[i] <= 1'b0;
        end else begin
            stages[i] <= stages[i-1];
        end
    end
end
endgenerate

assign resetn = stages[NUM_STAGES - 1];
assign reset = ~stages[NUM_STAGES - 1];

endmodule
