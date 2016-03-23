`timescale 100ps / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:07:46 11/03/2015
// Design Name:   PLL
// Module Name:   C:/Users/Jeffrey/Google Drive/FPGA/PLL/plltest.v
// Project Name:  PLL
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: PLL
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module plltest;

	// Inputs
	reg CLK_IN1;
	reg RESET;

	// Outputs
	wire CLK_OUT1;
	wire CLK_OUT2;
	wire CLK_OUT3;
	wire CLK_OUT4;
	wire LOCKED;

	// Instantiate the Unit Under Test (UUT)
	PLL uut (
		.CLK_IN1(CLK_IN1), 
		.CLK_OUT1(CLK_OUT1), 
		.CLK_OUT2(CLK_OUT2), 
		.CLK_OUT3(CLK_OUT3), 
		.CLK_OUT4(CLK_OUT4), 
		.RESET(RESET), 
		.LOCKED(LOCKED)
	);

	initial begin
		// Initialize Inputs
		CLK_IN1 = 0;
		RESET = 0;
		#100 RESET = 1;
		#100 RESET = 0;
		// Wait 100 ns for global reset to finish
		#1000;
        
		// Add stimulus here

	end
	
	always
		#125 CLK_IN1 = ~CLK_IN1;
		

      
endmodule

