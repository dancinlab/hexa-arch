// pwm8.v — 8-bit PWM controller (Verilog-2005 synthesizable)
// 2026-05-22 · chip §B reference example (simple chip family).
//
// Free-running 8-bit counter compared against duty[7:0]; pwm_out high
// while counter < duty. period = 256 clk_in cycles.
//
// Ports:
//   - clk_in   : positive-edge synchronous clock
//   - rst_n    : active-low synchronous reset
//   - duty     : 8-bit duty cycle (0 = always low; 255 = high 255/256)
//   - pwm_out  : PWM output
//
// Reference target pipeline: yosys + SKY130 PDK + ABC (κ-43 substrate absorbed).
// Expected post-synth: 8 D-flip-flops (counter) + 8-bit comparator + 1 DFF (out).

`default_nettype none

module pwm8 (
    input  wire       clk_in,
    input  wire       rst_n,
    input  wire [7:0] duty,
    output reg        pwm_out
);
    reg [7:0] cnt;

    always @(posedge clk_in) begin
        if (!rst_n) begin
            cnt     <= 8'b0;
            pwm_out <= 1'b0;
        end else begin
            cnt     <= cnt + 8'b1;
            pwm_out <= (cnt < duty) ? 1'b1 : 1'b0;
        end
    end
endmodule

`default_nettype wire
