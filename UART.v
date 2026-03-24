module uart_tx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst_n,      
    input  wire [7:0] data_in,    
    input  wire       tx_start,   
    output reg        tx,         
    output reg        tx_busy     
);

    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    parameter IDLE  = 2'd0, START = 2'd1, DATA  = 2'd2, STOP  = 2'd3;
    

    reg [1:0]                    state;
    reg [$clog2(CLKS_PER_BIT):0] clk_cnt;
    reg [2:0]                    bit_idx;
    reg [7:0]                    tx_data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state   <= IDLE;
            tx      <= 1'b1;   
            tx_busy <= 1'b0;
            clk_cnt <= 0;
            bit_idx <= 0;
            tx_data <= 8'd0;
        end else begin
            case (state)
             	IDLE: begin
                    tx      <= 1'b1;
                    tx_busy <= 1'b0;
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    if (tx_start) begin
                        tx_data <= data_in;
                        tx_busy <= 1'b1;
                        state   <= START;
                    end
                end
                START: begin
                    tx <= 1'b0;
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        state   <= DATA;
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end                
                DATA: begin
                    tx <= tx_data[bit_idx];
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        if (bit_idx == 3'd7) begin
                            bit_idx <= 0;
                            state   <= STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end                
                STOP: begin
                    tx <= 1'b1;
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        tx_busy <= 1'b0;
                        state   <= IDLE;
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
