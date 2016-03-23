`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:38:28 08/25/2015
// Design Name:   SerialConfig
// Module Name:   C:/Users/Jeffrey/Google Drive/FPGA/LJPLL_FPGA_FIRMWARE/verilog/tb_SerialConfig.v
// Project Name:  LJPLL_FPGA_FIRMWARE
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SerialConfig
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_SerialConfig;

	// Inputs
	reg sysclk;
	reg rst;
	reg [7:0] myReg1;
	reg [7:0] myReg2;
	reg [7:0] myReg3;
	reg [7:0] myReg4;
	reg [7:0] myReg5;
	reg [7:0] myReg6;
	reg [7:0] myReg7;
	reg [7:0] myReg8;
	reg [7:0] myReg9;
	reg [7:0] myReg10;
	reg [7:0] myReg11;
	reg [7:0] myReg12;
	reg [7:0] myReg13;

	// Outputs
	wire sck;
	wire sda;
	wire scapt;
	wire reset;

	// Instantiate the Unit Under Test (UUT)
	SerialConfig uut (
		.sysclk(sysclk), 
		.rst(rst), 
		.sck(sck), 
		.sda(sda), 
		.scapt(scapt), 
		.reset(reset), 
		.myReg1(myReg1), 
		.myReg2(myReg2), 
		.myReg3(myReg3), 
		.myReg4(myReg4), 
		.myReg5(myReg5), 
		.myReg6(myReg6), 
		.myReg7(myReg7), 
		.myReg8(myReg8), 
		.myReg9(myReg9), 
		.myReg10(myReg10), 
		.myReg11(myReg11), 
		.myReg12(myReg12), 
		.myReg13(myReg13)
	);

always begin
	#5 sysclk=~sysclk;
end
	initial begin
		// Initialize Inputs
		sysclk = 1;
		rst = 0;
		myReg1 = 0;
		myReg2 = 1;
		myReg3 = 2;
		myReg4 = 3;
		myReg5 = 4;
		myReg6 = 5;
		myReg7 = 6;
		myReg8 = 7;
		myReg9 = 8;
		myReg10 = 9;
		myReg11 = 10;
		myReg12 = 11;
		myReg13 = 16;

		// Wait 100 ns for global reset to finish
		
      #5 rst = 1; 
		#10 rst = 0;
		#10 myReg1 = 1;
		//#100 myReg1 = 0;
		// Add stimulus here

	end
      
endmodule

