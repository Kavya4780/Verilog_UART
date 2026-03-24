`timescale 1ns/1ps

module uart_tb;

    parameter CLK_FREQ  = 50_000_000;
    parameter BAUD_RATE = 115200;
    parameter CLK_PERIOD = 1_000_000_000 / CLK_FREQ;  
    reg        clk, rst_n;
    reg  [7:0] tx_data;
    reg        tx_start;
    wire       tx_line;
    wire       tx_busy;
    wire [7:0] rx_data;
    wire       rx_done;
    wire       frame_error;

     uart_top #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) dut (
        .clk         (clk),
        .rst_n       (rst_n),
        .tx_data     (tx_data),
        .tx_start    (tx_start),
        .tx          (tx_line),
        .tx_busy     (tx_busy),
        .rx          (tx_line),  
        .rx_data     (rx_data),
        .rx_done     (rx_done),
        .frame_error (frame_error)
    );

   
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

   
    task send_byte;
        input [7:0] byte_val;
        begin
            @(posedge clk);
            tx_data  = byte_val;
            tx_start = 1'b1;
            @(posedge clk);
            tx_start = 1'b0;

           
            @(posedge rx_done);
            @(posedge clk);

            if (rx_data === byte_val)
                $display("PASS: sent 0x%02X, received 0x%02X", byte_val, rx_data);
            else
                $display("FAIL: sent 0x%02X, received 0x%02X", byte_val, rx_data);

            if (frame_error)
                $display("FRAME ERROR detected");
        end
    endtask

    initial begin
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb);

        rst_n    = 0;
        tx_data  = 8'h00;
        tx_start = 0;

        repeat(5) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        send_byte(8'hA5);
        send_byte(8'h3C);
        send_byte(8'hFF);
        send_byte(8'h00);
        send_byte(8'h55);

        repeat(20) @(posedge clk);
        $display("Simulation complete.");
        $finish;
    end

endmodule


