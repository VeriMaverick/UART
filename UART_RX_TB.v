`timescale 1ns / 1ns
module UART_RX_TB();
reg clk;
reg rst_n;
reg rxd;
wire rx_data_valid;
wire [7:0] rx_data;

UART_RX UART_RX(
    .clk(clk),
    .rst_n(rst_n),
    .rxd(rxd),
    .rx_data_valid(rx_data_valid),
    .rx_data(rx_data)
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
    rxd = 1;  
    #(4*CYCLE)
    #(434*CYCLE)
    rxd = 0;
    #(434*CYCLE)

    rxd = 1;
    #(434*CYCLE)
    rxd = 0;
    #(434*CYCLE)
    rxd = 0;
    #(434*CYCLE)
    rxd = 1;
    #(434*CYCLE)
    rxd = 0;
    #(434*CYCLE)
    rxd = 1;
    #(434*CYCLE)
    rxd = 1;
    #(434*CYCLE)
    rxd = 0;
    #(434*CYCLE)


    rxd = 1;  
    #(434*CYCLE)
    rxd = 0;
    #(434*CYCLE)

    rxd = 1;
    #(434*CYCLE)
    rxd = 1;
    #(434*CYCLE)
    rxd = 1;
    #(434*CYCLE)
    rxd = 1;
    #(434*CYCLE)
    rxd = 0;
    #(434*CYCLE)
    rxd = 1;
    #(434*CYCLE)
    rxd = 1;
    #(434*CYCLE)
    rxd = 1;
    #(434*CYCLE)


    rxd = 1;  
    #(434*CYCLE)
    rxd = 0;
    #(434*CYCLE)

    rxd = 1;
    #(434*CYCLE)
    rxd = 0;
    #(434*CYCLE)
    rxd = 0;
    #(434*CYCLE)
    rxd = 0;
    #(434*CYCLE)
    rxd = 0;
    #(434*CYCLE)
    rxd = 0;
    #(434*CYCLE)
    rxd = 0;
    #(434*CYCLE)
    rxd = 1;
    #(434*CYCLE)

    #(1000*CYCLE)
    $stop;
end

endmodule