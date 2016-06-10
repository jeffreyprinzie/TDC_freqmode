`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:26:16 06/10/2016
// Design Name:   SEUcounter
// Module Name:   /home/Administrators/jeffrey/xilinx/work_freqmode/tester_SEUcounter.v
// Project Name:  demo_atlys
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SEUcounter
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tester_SEUcounter;

	// Inputs
	reg SEUin;
	reg clk;

	// Outputs
	wire [31:0] CTRout;

	// Instantiate the Unit Under Test (UUT)
	SEUcounter uut (
		.SEUin(SEUin), 
		.clk(clk), 
		.CTRout(CTRout)
	);
	
	always 
		#5 clk=~clk;
	
	initial begin
		// Initialize Inputs
		SEUin = 0;
		clk = 0;
      uut.CTRout=0;
		uut.SEU_presyn1=0;
		uut.SEU_syn=0;
		uut.glitch_filt=0;
		
		// Wait 100 ns for global reset to finish
		#100;
      SEUin=1; 
		#100;		
		SEUin=0;
		#500;
		SEUin=1;
		#30;  
		SEUin=0;
		#30;
		SEUin=1;
		#100;
		SEUin=0;
		#20;
		SEUin=1;
		#100;
		SEUin=0;
		#20;
		// Add stimulus here
		$finish;
	end
      
endmodule

