// uart_tx.v — UART TX, 8N1, fixed 16-cycle baud divider (Verilog-2005)
// 2026-05-22 · chip §B reference example (simple chip family).
//
// 8-bit data, no parity, 1 stop bit. Each bit lasts BAUD_DIV=16 clk_in
// cycles (oversample-by-16 baud generator). Caller pulses tx_start with
// data on tx_data; busy stays high until the stop bit completes.
//
// 5-state FSM: IDLE → START → DATA → STOP → DONE → IDLE.
//
// Ports:
//   - clk_in   : positive-edge synchronous clock
//   - rst_n    : active-low synchronous reset
//   - tx_start : pulse high to begin a byte transmission (sampled in IDLE)
//   - tx_data  : 8-bit data byte to send (LSB-first on the wire)
//   - tx_out   : serial line (idle = high)
//   - tx_busy  : high while sending
//
// Reference target pipeline: yosys + SKY130 PDK + ABC (κ-43 substrate absorbed).

`default_nettype none

module uart_tx (
    input  wire       clk_in,
    input  wire       rst_n,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx_out,
    output reg        tx_busy
);
    localparam [2:0] S_IDLE  = 3'd0;
    localparam [2:0] S_START = 3'd1;
    localparam [2:0] S_DATA  = 3'd2;
    localparam [2:0] S_STOP  = 3'd3;
    localparam [2:0] S_DONE  = 3'd4;

    localparam [3:0] BAUD_DIV = 4'd15;  // 16 cycles per bit (0..15)

    reg [2:0] state;
    reg [3:0] baud_cnt;
    reg [2:0] bit_idx;
    reg [7:0] shift_reg;

    always @(posedge clk_in) begin
        if (!rst_n) begin
            state     <= S_IDLE;
            baud_cnt  <= 4'b0;
            bit_idx   <= 3'b0;
            shift_reg <= 8'b0;
            tx_out    <= 1'b1;
            tx_busy   <= 1'b0;
        end else begin
            case (state)
                S_IDLE: begin
                    tx_out  <= 1'b1;
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        shift_reg <= tx_data;
                        baud_cnt  <= 4'b0;
                        bit_idx   <= 3'b0;
                        tx_busy   <= 1'b1;
                        tx_out    <= 1'b0;       // start bit
                        state     <= S_START;
                    end
                end
                S_START: begin
                    if (baud_cnt == BAUD_DIV) begin
                        baud_cnt <= 4'b0;
                        tx_out   <= shift_reg[0];
                        state    <= S_DATA;
                    end else begin
                        baud_cnt <= baud_cnt + 4'b1;
                    end
                end
                S_DATA: begin
                    if (baud_cnt == BAUD_DIV) begin
                        baud_cnt <= 4'b0;
                        if (bit_idx == 3'd7) begin
                            tx_out <= 1'b1;       // stop bit
                            state  <= S_STOP;
                        end else begin
                            shift_reg <= {1'b0, shift_reg[7:1]};
                            tx_out    <= shift_reg[1];
                            bit_idx   <= bit_idx + 3'b1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 4'b1;
                    end
                end
                S_STOP: begin
                    if (baud_cnt == BAUD_DIV) begin
                        baud_cnt <= 4'b0;
                        state    <= S_DONE;
                    end else begin
                        baud_cnt <= baud_cnt + 4'b1;
                    end
                end
                S_DONE: begin
                    tx_busy <= 1'b0;
                    state   <= S_IDLE;
                end
                default: state <= S_IDLE;
            endcase
        end
    end
endmodule

`default_nettype wire
