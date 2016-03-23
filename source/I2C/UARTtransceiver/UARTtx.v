`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:34:54 08/20/2015 
// Design Name: 
// Module Name:    UARTtx 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module UARTtx(reset,sysclk,baud16,TxD,TxD_data,txstart,txbusy
    );

input sysclk,reset,txstart;
input [7:0] TxD_data;
input baud16;
output txbusy,TxD;

reg [3:0] baudctr;

always @(posedge sysclk) begin
	if(reset)
		baudctr<=0;
	else
		if(baud16)
		baudctr<=baudctr+1;
end


wire baud;
wire txbusy;
assign baud = (baudctr==0 && baud16) ? 1 : 0;


reg [3:0] state;

always @(posedge sysclk)
if(reset)
	state<=0;
else
case(state)
  4'b0000: if(txstart) state <= 4'b0010;
  4'b0010: if(baud) state <= 4'b0100; //wait for baud to start (synchronize the start with baud)
  4'b0100: if(baud) state <= 4'b1000; // start
  4'b1000: if(baud) state <= 4'b1001; // bit 0
  4'b1001: if(baud) state <= 4'b1010; // bit 1
  4'b1010: if(baud) state <= 4'b1011; // bit 2
  4'b1011: if(baud) state <= 4'b1100; // bit 3
  4'b1100: if(baud) state <= 4'b1101; // bit 4
  4'b1101: if(baud) state <= 4'b1110; // bit 5
  4'b1110: if(baud) state <= 4'b1111; // bit 6
  4'b1111: if(baud) state <= 4'b0001; // bit 7
  4'b0001: if(baud) state <= 4'b0011; // stop1
  4'b0011: if(baud) state <= 4'b0000; // stop2
  
  default: if(baud) state <= 4'b0000;
endcase

reg muxbit;

always @(state[2:0],TxD_data)
case(state[2:0])
  0: muxbit <= TxD_data[0];
  1: muxbit <= TxD_data[1];
  2: muxbit <= TxD_data[2];
  3: muxbit <= TxD_data[3];
  4: muxbit <= TxD_data[4];
  5: muxbit <= TxD_data[5];
  6: muxbit <= TxD_data[6];
  7: muxbit <= TxD_data[7];
endcase


// combine start, data, and stop bits together
assign TxD = (state<4) | (state[3] & muxbit);

assign txbusy = (state == 4'b0000) ? 0 : 1 ;


endmodule
