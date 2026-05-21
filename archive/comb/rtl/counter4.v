// counter4.v — 4-bit synchronous up-counter (Verilog-2005 synthesizable)
// 2026-05-22 · chip §B reference example (simple chip family).
//
// Ports:
//   - clk_in   : positive-edge synchronous clock
//   - rst_n    : active-low synchronous reset
//   - en       : enable (count increments only when en=1)
//   - count_out: current 4-bit count
//
// Reference target pipeline: yosys + SKY130 PDK + ABC (κ-43 substrate absorbed).
// Expected post-synth: 4 D-flip-flops + small comb logic (~4-bit adder + mux).

`default_nettype none

module counter4 (
    input  wire       clk_in,
    input  wire       rst_n,
    input  wire       en,
    output reg  [3:0] count_out
);
    always @(posedge clk_in) begin
        if (!rst_n)      count_out <= 4'b0;
        else if (en)     count_out <= count_out + 4'b1;
    end
endmodule

`default_nettype wire
