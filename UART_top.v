module uart_top #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst_n,    
    input  wire [7:0] tx_data,
    input  wire       tx_start,
    output wire       tx,
    output wire       tx_busy,   
    input  wire       rx,
    output wire [7:0] rx_data,
    output wire       rx_done,
    output wire       frame_error
);

    uart_tx #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) u_tx (
        .clk      (clk),
        .rst_n    (rst_n),
        .data_in  (tx_data),
        .tx_start (tx_start),
        .tx       (tx),
        .tx_busy  (tx_busy)
    );

    uart_rx #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) u_rx (
        .clk         (clk),
        .rst_n       (rst_n),
        .rx          (rx),
        .data_out    (rx_data),
        .rx_done     (rx_done),
        .frame_error (frame_error)
    );

endmodule
