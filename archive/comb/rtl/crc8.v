// crc8.v — CRC-8 CCITT, serial 1-bit-in (Verilog-2005 synthesizable)
// 2026-05-22 · chip §B reference example (simple chip family).
//
// CCITT-8 polynomial x^8 + x^2 + x + 1 (0x07). Bit-serial: feed one data
// bit per clk_in cycle while en=1; current CRC register is exposed on
// crc_out[7:0] (combinational view of the register).
//
// Ports:
//   - clk_in   : positive-edge synchronous clock
//   - rst_n    : active-low synchronous reset (clears CRC to 0x00)
//   - en       : enable (CRC updates with data_in only when en=1)
//   - data_in  : 1-bit serial data
//   - crc_out  : current CRC-8 register value
//
// Reference target pipeline: yosys + SKY130 PDK + ABC (κ-43 substrate absorbed).
// Expected post-synth: 8 D-flip-flops + a few XOR gates per bit position.

`default_nettype none

module crc8 (
    input  wire       clk_in,
    input  wire       rst_n,
    input  wire       en,
    input  wire       data_in,
    output wire [7:0] crc_out
);
    reg [7:0] crc;
    wire fb = crc[7] ^ data_in;

    always @(posedge clk_in) begin
        if (!rst_n) begin
            crc <= 8'b0;
        end else if (en) begin
            // Polynomial 0x07 = x^8 + x^2 + x + 1
            crc[0] <= fb;
            crc[1] <= crc[0] ^ fb;
            crc[2] <= crc[1] ^ fb;
            crc[3] <= crc[2];
            crc[4] <= crc[3];
            crc[5] <= crc[4];
            crc[6] <= crc[5];
            crc[7] <= crc[6];
        end
    end

    assign crc_out = crc;
endmodule

`default_nettype wire
