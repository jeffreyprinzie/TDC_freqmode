`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:00:43 08/20/2015 
// Design Name: 
// Module Name:    POR 
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
module POR(sysclk,reset
    );
	 input sysclk;
	 output reset;

wire reset;
reg [1:0] PORreset = 2'b00;
assign reset = (PORreset==2'b10) ? 1 : 0;
always @(posedge sysclk)
if(PORreset != 2'b11)
	PORreset<=PORreset+1;
	
endmodule
