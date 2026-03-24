module uart_rx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst_n,       
    input  wire       rx,          
    output reg  [7:0] data_out,    
    output reg        rx_done,     
    output reg        frame_error  
);

    localparam CLKS_PER_BIT    = CLK_FREQ / BAUD_RATE;
    localparam HALF_BIT        = CLKS_PER_BIT / 2;

   
    localparam IDLE  = 2'd0, START = 2'd1, DATA  = 2'd2, STOP  = 2'd3;
    
    reg [1:0]                    state;
    reg [$clog2(CLKS_PER_BIT):0] clk_cnt;
    reg [2:0]                    bit_idx;
    reg [7:0]                    rx_shift;

    
    reg rx_sync0, rx_sync1;
    wire rx_s = rx_sync1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync0 <= 1'b1;
            rx_sync1 <= 1'b1;
        end else begin
            rx_sync0 <= rx;
            rx_sync1 <= rx_sync0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            clk_cnt     <= 0;
            bit_idx     <= 0;
            rx_shift    <= 8'd0;
            data_out    <= 8'd0;
            rx_done     <= 1'b0;
            frame_error <= 1'b0;
        end else begin
            rx_done     <= 1'b0;  
            frame_error <= 1'b0;

            case (state)             
                IDLE: begin
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    if (rx_s == 1'b0)     
                        state <= START;
                end                
                START: begin
                    if (clk_cnt == HALF_BIT - 1) begin
                        if (rx_s == 1'b0) begin   
                            clk_cnt <= 0;
                            state   <= DATA;
                        end else begin
                            state   <= IDLE;       
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end                
                DATA: begin
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt              <= 0;
                        rx_shift[bit_idx]    <= rx_s;  
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
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        if (rx_s == 1'b1) begin    
                            data_out    <= rx_shift;
                            rx_done     <= 1'b1;
                        end else begin
                            frame_error <= 1'b1;   
                        end
                        state <= IDLE;
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
