module UART_TX_TB();
reg clk;
reg rst_n;
reg tx_data_en;
reg [7:0] tx_data;
wire txd_valid;
wire txd;

UART_TX UART_TX(
    .clk(clk),
    .rst_n(rst_n),
    .tx_data_en(tx_data_en),
    .tx_data(tx_data),
    .txd_valid(txd_valid),
    .txd(txd)
);

localparam CYCLE = 20;

initial begin
	clk = 0;
	forever begin
		#(CYCLE/2);
		clk = 1;
		#(CYCLE/2);
		clk = 0;
	end
end

initial begin 
	rst_n = 0;
	#(2*CYCLE)
	rst_n = 1;
end 

initial begin
    tx_data_en = 0;
    tx_data = 0;
    #(10*CYCLE)
    tx_data_en = 1;
    tx_data = 8'b10010110;
    #(10*CYCLE)
    tx_data_en = 0;

    #(10000*CYCLE)
    tx_data_en = 1;
    tx_data = 8'b01110110;
    #(10*CYCLE)
    tx_data_en = 0;

    #(10000*CYCLE)
    $stop;
end
endmodule 