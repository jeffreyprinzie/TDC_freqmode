`timescale 1ns / 1ps
//Designed by Jeffrey Prinzie
//This module is a UART receiver with 16x oversampling

module UARTrx(reset,sysclk,baud16,rx,RxD_data_out,RxD_fifo_W);

input rx, sysclk,baud16;
output reg [7:0] RxD_data_out; 
output reg RxD_fifo_W;
input reset;
reg [7:0] RxD_data;








reg [1:0] rxSync; //synchronising input shift register

//synchronize clock domains to prevent metastable ff's
always @(posedge sysclk) begin
	if (reset)
		rxSync<=2'b00;
	else
		if(baud16)
			rxSync<={rxSync[0],rx};	
end

//glitch removal at the input
reg [1:0] rx_gl_ctr;  //rx glitch counter
reg RxD; //filterred rx data
always @(posedge sysclk) begin
	if(reset) begin
		rx_gl_ctr<=2'b11;
		RxD<=1;
	end else begin
		if(baud16) begin
			if( rxSync[1] && rx_gl_ctr!=2'b11)
				rx_gl_ctr<=rx_gl_ctr + 1;
			if( !rxSync[1] && rx_gl_ctr!=2'b00)
				rx_gl_ctr<=rx_gl_ctr - 1;

			if( rx_gl_ctr==2'b11)
				RxD<=1;
			if( rx_gl_ctr==2'b00)
				RxD<=0;
		end
	end

end



//bittime generator

reg [3:0] rx_bittimeCounter;
reg [3:0] state;


always @(posedge sysclk) begin

	if(reset)
		rx_bittimeCounter<=0;
	else begin
		if(state==0)
			rx_bittimeCounter <= 0;
		else if(baud16) begin
			rx_bittimeCounter <= rx_bittimeCounter + 1;
		end
	end
end
wire next_bit;
assign next_bit = (rx_bittimeCounter == 7) ? 1 : 0;



always @(posedge sysclk) begin

if(reset || watchdogCtr[11])
	state<=0;
else if(baud16)
case(state)
  4'b0000: if(~RxD) state <= 4'b0011; // start bit found?
  4'b0011: if(next_bit) state <= 4'b1000;
  4'b1000: if(next_bit) state <= 4'b1001; // bit 0
  4'b1001: if(next_bit) state <= 4'b1010; // bit 1
  4'b1010: if(next_bit) state <= 4'b1011; // bit 2
  4'b1011: if(next_bit) state <= 4'b1100; // bit 3
  4'b1100: if(next_bit) state <= 4'b1101; // bit 4
  4'b1101: if(next_bit) state <= 4'b1110; // bit 5
  4'b1110: if(next_bit) state <= 4'b1111; // bit 6
  4'b1111: if(next_bit) state <= 4'b0001; // bit 7
  4'b0001: if(next_bit) state <= 4'b0000; // stop bit
  default: state <= 4'b0000;
endcase
end

reg [11:0] watchdogCtr;

always @(posedge sysclk) begin
if(baud16)
	if(reset || state==0)
		watchdogCtr<=0;
	else
		watchdogCtr<=watchdogCtr+1;
	
end

always @(posedge sysclk) 
	if(baud16 && next_bit && state[3]) 
		if(state==4'b1111) 
				RxD_data_out <= {RxD, RxD_data[7:1]};
		else
				RxD_data <= {RxD, RxD_data[7:1]};
				
always @(posedge sysclk) 
	if(baud16 && next_bit && state==4'b1111)
			RxD_fifo_W<=1;
	else
			RxD_fifo_W<=0;



wire trig1;
assign trig1=(baud16 && next_bit && state==4'b1111) ? 1 : 0;

endmodule
