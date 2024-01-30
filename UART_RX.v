module UART_RX #(
    parameter  CLK_FREQ     = 50000000, // clock 50MHz
    parameter  BAUD_RATE    = 115200    // Baud rate 115200
)
(
    input               clk,                // clock 50MHz
    input               rst_n,              // reset low
    input               rxd,                // UART receiving port
    output  reg         rx_data_valid,      // UART receive data completion flag
    output  reg [7:0]   rx_data             // UART receive data
);

localparam BPS_CNT = CLK_FREQ / BAUD_RATE;  // Baud rate counting

wire start_flag;        // The start flag bit was received

reg [15:0] clk_cnt;     // clock counter
reg [7:0] data_reg;     // Data register
reg [3:0] bit_cnt;      // Data counter
reg rxd_d0;             // The first register of a two-beat asynchronous synchronization
reg rxd_d1;             // The second register of a two-beat asynchronous synchronization
reg rx_flag;            // Receive process marker signal
reg rxd_reg;            // Receive data register

// 两拍异步同步
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        rxd_d0 <= 1'b0;
        rxd_d1 <= 1'b0;
    end else begin
        rxd_d0 <= rxd;
        rxd_d1 <= rxd_d0;
    end
end

//捕获接收端口下降沿(起始位)，得到一个时钟周期的脉冲信号
assign start_flag = (~rxd_d0) & rxd_d1;

// 当脉冲信号start_flag到达时，进入接收过程 
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        rx_flag <= 1'b0;
    end else begin
        if (start_flag) begin
            rx_flag <= 1'b1;
        end else if ((bit_cnt == 4'd9) && (clk_cnt == BPS_CNT - (BPS_CNT/2))) begin
            rx_flag <= 1'b0;
        end else begin
            rx_flag <= rx_flag;
        end
    end
end

// 进入接收过程后，启动系统时钟计数器与接收数据计数器
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        clk_cnt <= 16'd0;
        bit_cnt <= 4'd0;
    end else begin
        if (rx_flag) begin
            if (clk_cnt == BPS_CNT - 1'b1) begin
                clk_cnt <= 16'd0;
                bit_cnt <= bit_cnt + 1'b1;
            end else begin
                clk_cnt <= clk_cnt + 1'b1;
                bit_cnt <= bit_cnt;
            end
        end else begin
            clk_cnt <= 16'd0;
            bit_cnt <= 4'd0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin 
    if(~rst_n) begin
        rxd_reg <= 1'b0;
    end else begin
        rxd_reg <= rxd;
    end
end

// 根据接收数据计数器来寄存uart接收端口数据
always @(posedge clk or negedge rst_n) begin 
    if (~rst_n) begin
        data_reg <= 8'd0;                                     
    end else if(rx_flag) begin                      // system receiving
        if (clk_cnt == BPS_CNT/2) begin             //判断系统时钟计数器计数到数据位中间
            case ( bit_cnt )
                4'd1 :  data_reg[0] <= rxd_reg;     // register LSB
                4'd2 :  data_reg[1] <= rxd_reg;
                4'd3 :  data_reg[2] <= rxd_reg;
                4'd4 :  data_reg[3] <= rxd_reg;
                4'd5 :  data_reg[4] <= rxd_reg;
                4'd6 :  data_reg[5] <= rxd_reg;
                4'd7 :  data_reg[6] <= rxd_reg;
                4'd8 :  data_reg[7] <= rxd_reg;     // register MSB
                default:data_reg <= data_reg;                                 
            endcase
        end else begin
            data_reg <= data_reg;
        end
    end else begin
        data_reg <= 8'd0;
    end
end

//数据接收完毕后给出标志信号并寄存输出接收到的数据
always @(posedge clk or negedge rst_n) begin        
    if (~rst_n) begin
        rx_data <= 8'd0;                               
        rx_data_valid <= 1'b0;
    end else if(bit_cnt == 4'd9) begin      //接收数据计数器计数到停止位时           
        rx_data <= data_reg;                //寄存输出接收到的数据
        rx_data_valid <= 1'b1;              //并将接收完成标志位拉高
    end else begin
        rx_data <= 8'd0;                                   
        rx_data_valid <= 1'b0; 
    end    
end

endmodule 