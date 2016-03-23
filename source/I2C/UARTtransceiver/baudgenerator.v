`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:40:27 08/20/2015 
// Design Name: 
// Module Name:    baudgenerator 
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
module baudgenerator(sysclk,reset,baud16
    );
input sysclk,reset;
output  baud16;


parameter ClkFrequency = 100000000; 
parameter Baud = 9600*16;
parameter BaudGeneratorAccWidth = 16;
parameter BaudGeneratorInc = ((Baud<<(BaudGeneratorAccWidth-4))+(ClkFrequency>>5))/(ClkFrequency>>4); 

reg [BaudGeneratorAccWidth:0] BaudGeneratorAcc;
always @(posedge sysclk)
	if(reset)
		BaudGeneratorAcc<=0;
	else
  		BaudGeneratorAcc <= BaudGeneratorAcc[BaudGeneratorAccWidth-1:0] + BaudGeneratorInc;

wire baud16 = BaudGeneratorAcc[BaudGeneratorAccWidth]; 


endmodule
