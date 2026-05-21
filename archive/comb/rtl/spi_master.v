// spi_master.v — SPI master, 4-pin, 8-bit MSB-first (Verilog-2005)
// 2026-05-22 · chip §B reference example (simple chip family).
//
// Mode 0 (CPOL=0, CPHA=0): sclk idles low; MOSI shifted out on falling
// edge of sclk; MISO sampled on rising edge of sclk. sclk = clk_in / 2.
//
// 3-state FSM: IDLE → ACTIVE → DONE → IDLE.
//
// Ports:
//   - clk_in   : positive-edge system clock
//   - rst_n    : active-low synchronous reset
//   - start    : pulse high to begin an 8-bit transfer (sampled in IDLE)
//   - tx_byte  : byte to transmit (MSB shifted first)
//   - rx_byte  : last received byte
//   - busy     : high while transferring
//   - sclk     : SPI clock to slave
//   - mosi     : master-out, slave-in
//   - miso     : master-in, slave-out
//   - ss_n     : active-low slave select
//
// Reference target pipeline: yosys + SKY130 PDK + ABC (κ-43 substrate absorbed).

`default_nettype none

module spi_master (
    input  wire       clk_in,
    input  wire       rst_n,
    input  wire       start,
    input  wire [7:0] tx_byte,
    output reg  [7:0] rx_byte,
    output reg        busy,
    output reg        sclk,
    output reg        mosi,
    input  wire       miso,
    output reg        ss_n
);
    localparam [1:0] S_IDLE   = 2'd0;
    localparam [1:0] S_ACTIVE = 2'd1;
    localparam [1:0] S_DONE   = 2'd2;

    reg [1:0] state;
    reg [7:0] tx_shift;
    reg [7:0] rx_shift;
    reg [3:0] bit_cnt;     // counts 0..15 = 8 bits × 2 phases
    reg       phase;       // 0 = setup (falling sclk), 1 = sample (rising sclk)

    always @(posedge clk_in) begin
        if (!rst_n) begin
            state    <= S_IDLE;
            tx_shift <= 8'b0;
            rx_shift <= 8'b0;
            rx_byte  <= 8'b0;
            bit_cnt  <= 4'b0;
            phase    <= 1'b0;
            busy     <= 1'b0;
            sclk     <= 1'b0;
            mosi     <= 1'b0;
            ss_n     <= 1'b1;
        end else begin
            case (state)
                S_IDLE: begin
                    sclk    <= 1'b0;
                    ss_n    <= 1'b1;
                    busy    <= 1'b0;
                    if (start) begin
                        tx_shift <= tx_byte;
                        rx_shift <= 8'b0;
                        bit_cnt  <= 4'b0;
                        phase    <= 1'b0;
                        ss_n     <= 1'b0;
                        mosi     <= tx_byte[7];
                        busy     <= 1'b1;
                        state    <= S_ACTIVE;
                    end
                end
                S_ACTIVE: begin
                    if (phase == 1'b0) begin
                        // setup: drive MOSI, then raise sclk
                        sclk     <= 1'b1;
                        rx_shift <= {rx_shift[6:0], miso};
                        phase    <= 1'b1;
                    end else begin
                        // sample done; fall sclk, shift tx, count bit
                        sclk     <= 1'b0;
                        phase    <= 1'b0;
                        if (bit_cnt == 4'd7) begin
                            rx_byte <= {rx_shift[6:0], miso};
                            state   <= S_DONE;
                        end else begin
                            tx_shift <= {tx_shift[6:0], 1'b0};
                            mosi     <= tx_shift[6];
                            bit_cnt  <= bit_cnt + 4'b1;
                        end
                    end
                end
                S_DONE: begin
                    ss_n  <= 1'b1;
                    busy  <= 1'b0;
                    state <= S_IDLE;
                end
                default: state <= S_IDLE;
            endcase
        end
    end
endmodule

`default_nettype wire
