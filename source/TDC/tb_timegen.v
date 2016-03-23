`timescale 100ps / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:13:51 11/04/2015
// Design Name:   timegen
// Module Name:   C:/Users/Jeffrey/Google Drive/FPGA/PLL/tb_timegen.v
// Project Name:  PLL
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: timegen
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_timegen;

	// Inputs
	reg ckref;
	reg RESET;
	reg hit;
	reg resetpll;
	reg enableHitskip;
	// Outputs
   wire fifo_data_available;
	wire read_fifo,SYSCLK;
	assign read_fifo=fifo_data_available;
	wire [7:0] fifo_dout;
	

	// Instantiate the Unit Under Test (UUT)
	timegen uut (
		.ckref(ckref), 
		.RESET(RESET),
		.resetpll(resetpll),
		.hit_in(hit),
		.fifo_data_available(fifo_data_available),
		.read_fifo(read_fifo),
		.fifo_dout(fifo_dout),
		.SYSCLK(SYSCLK),
		.enableHitskip(enableHitskip)
	);

	initial begin
		// Initialize Inputs

		ckref = 0;
		RESET = 0;
		hit=0;
		enableHitskip=1;
		resetpll=1;
		#100 resetpll=0;
		#100 RESET = 1;
		#5000 RESET = 0;
		// Wait 100 ns for global reset to finish
		#1000;
        
		// Add stimulus here

	end
	

	always
		#125 ckref = ~ckref;
		
	always
		#124 hit = ~hit;
		

		
      
endmodule

