module UART_TX #(
    parameter  CLK_FREQ     = 50000000, // clock 50MHz
    parameter  BAUD_RATE    = 115200    // Baud rate 115200
)
(
    input           clk,            // 50MHz
    input           rst_n,          // reset low
    input           tx_data_en,     // UART enable send data
    input   [7:0]   tx_data,        // UART send data
    output  reg     txd_valid,      // UART valid flag of the send port
    output  reg     txd             // UART send data port
);

localparam BPS_CNT = CLK_FREQ / BAUD_RATE;  // baud rate counting 

reg tx_data_en_d0;      // The first register of a two-beat asynchronous synchronization
reg tx_data_en_d1;      // The second register of a two-beat asynchronous synchronization
reg [15:0] clk_cnt;     // clock counter 
reg [7:0] data_reg;     // data register
reg [3:0] bit_cnt;      // bit counter

wire tx_data_en_flag;   // 发送使能标志位，一旦检测到使能信号的上升沿，就把这个信号拉高

// 发送使能信号的异步两拍同步
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        tx_data_en_d0 <= 1'b0;
        tx_data_en_d1 <= 1'b0;
    end else begin
        tx_data_en_d0 <= tx_data_en;
        tx_data_en_d1 <= tx_data_en_d0;
    end
end

assign tx_data_en_flag = (~tx_data_en_d1) & tx_data_en_d0; // 发送使能标志位，一旦检测到使能信号的上升沿，就把这个信号拉高

// tx_data_en_flag 到达时，把带发送的数据寄存到data_reg中，防止数据改变导致读数错误
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        data_reg <= 8'b0;
        txd_valid <= 1'b0;
    end else begin
        if (tx_data_en_flag) begin
            data_reg <= tx_data;
            txd_valid <= 1'b1;
        end else if((bit_cnt == 4'd9) && (clk_cnt == BPS_CNT - (BPS_CNT/16))) begin
            data_reg <= 8'b0;
            txd_valid <= 1'b0;
        end else begin
            data_reg <= data_reg;
            txd_valid <= txd_valid;
        end
    end
end

// 时钟计数器和发送计数器的计数
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        bit_cnt <= 4'd0;
    end else if (txd_valid) begin
        if (clk_cnt == BPS_CNT - 1'b1) begin
            bit_cnt <= bit_cnt + 1'b1;
        end else begin
            bit_cnt <= bit_cnt;
        end
    end else begin
        bit_cnt <= 4'd0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        clk_cnt <= 16'd0;
    end else if (txd_valid) begin
        if (clk_cnt < BPS_CNT - 1'b1) begin
            clk_cnt <= clk_cnt + 1'b1;
        end else begin
            clk_cnt <= 16'd0;
        end
    end else begin
        clk_cnt <= 16'd0;
    end
end

// 串行数据的赋值过程
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        txd<=1'd1;
    end else if(txd_valid) begin
        case(bit_cnt)
            4'd0:txd <= 1'd0;//起始位
            4'd1:txd <= data_reg[0];
            4'd2:txd <= data_reg[1];
            4'd3:txd <= data_reg[2];
            4'd4:txd <= data_reg[3];
            4'd5:txd <= data_reg[4];
            4'd6:txd <= data_reg[5];
            4'd7:txd <= data_reg[6];
            4'd8:txd <= data_reg[7];
            4'd9:txd <= 1'b1;//停止位
            default:txd <= txd;
        endcase
    end else begin
        txd <= 1'd1;
    end
end

endmodule 