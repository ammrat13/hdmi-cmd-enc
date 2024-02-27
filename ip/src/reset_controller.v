`timescale 1ns / 1ps

// Reset controller for the HDMI Command Encoder
//
// The reset signal for this encoder is intended to be tied to the `locked`
// output of the clock generator. This means the reset signal is active-low and,
// more importantly, asynchronous. Unfortunately, the output serializers expect
// a synchronous reset signal, and in general it's good practice to make resets
// synchronous.
//
// Therefore, this module converts from an active-low asynchronous reset signal
// to synchronous reset signals of both polarities. To do this, it passes the
// input through a chain of flip-flops.
//
// Parameters:
// * NUM_STAGES: The number of stages in the flip-flop synchronizer. Must be at
//   least two.
//
// Ports:
// * clk: The clock to synchronize to
// * resetn_async: The input reset signal, which is active-low and asynchronous
// * resetn: The output active-low synchronous reset signal
// * reset: The output active-high synchronous reset signal
module reset_controller #(
    parameter NUM_STAGES = 2
)(
    input clk,
    input resetn_async,
    output resetn,
    output reset
);

// The chain of flip-flops used for synchronization. The LSB is the newest data,
// and the MSB has gone through the entire chain.
reg [NUM_STAGES-1:0] stages;

// The LSB is zero on reset. Otherwise, it's the value of the reset input, which
// is one if we are not in reset.
always @(posedge clk, negedge resetn_async) begin
    if (resetn_async == 1'b0)
        stages[0] <= 1'b0;
    else
        stages[0] <= 1'b1;
end

// All the other bits reset to zero and take from the previous bit otherwise
generate
for (genvar i = 1; i < NUM_STAGES; i = i + 1) begin
    always @(posedge clk, negedge resetn_async) begin
        if (resetn_async == 1'b0)
            stages[i] <= 1'b0;
        else
            stages[i] <= stages[i-1];
    end
end
endgenerate

// The outputs come from the last stage in the chain
assign resetn = stages[NUM_STAGES - 1];
assign reset = ~stages[NUM_STAGES - 1];

endmodule
