`timescale 100ps / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:01:51 11/19/2015
// Design Name:   tester_timegen
// Module Name:   C:/Users/Jeffrey/Google Drive/FPGA/PLL/tb_tester_timegen.v
// Project Name:  PLL
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: tester_timegen
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_tester_timegen;

	// Inputs
	reg ckref;
	reg [2:0] cksel;

	// Outputs
	wire [7:0] TDCfifo_dout;

	// Instantiate the Unit Under Test (UUT)
	tester_timegen uut (
		.ckref(ckref), 
		.cksel(cksel), 
		.TDCfifo_dout(TDCfifo_dout)
	);

	initial begin
		// Initialize Inputs
		ckref = 0;
		cksel = 0;

		// Wait 100 ns for global reset to finish
		#10000;
      cksel = 1;
		#10000;
      cksel = 2;
		#10000;
      cksel = 3;
		#10000;
      cksel = 4;
		#10000;
      cksel = 5;
		#10000;
      cksel = 6;
		// Add stimulus here

	end
      
		
	always
		#100 ckref = ~ckref;
endmodule

