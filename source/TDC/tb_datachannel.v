`timescale 100ps / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:18:45 11/09/2015
// Design Name:   dataChannel
// Module Name:   C:/Users/Jeffrey/Google Drive/FPGA/PLL/tb_datachannel.v
// Project Name:  PLL
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: dataChannel
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_datachannel;

	// Inputs
	reg ckref;
	reg hit;
	reg RESET;
	reg resetpll;
	reg enableHitskip;
	// Instantiate the Unit Under Test (UUT)
	
	wire [31:0] IPbus_RAM_data;
	wire [7:0] IPbus_RAM_address;
	wire IPbus_RAM_we;
	
	reg handshakePC;
	wire handshakeFPGA;
	always @(handshakeFPGA)
		#5000 handshakePC<=handshakeFPGA;
		
		
	dataChannel uut (
		.ckref(ckref), 
		.hit(hit), 
		.RESET(RESET), 
		.resetpll(resetpll),
		.enableHitskip(enableHitskip),
		.IPbus_RAM_data(IPbus_RAM_data),
		.IPbus_RAM_address(IPbus_RAM_address),
		.IPbus_RAM_we(IPbus_RAM_we),
		.handshakeFPGA(handshakeFPGA),
		.handshakePC(handshakePC)
	);

	integer phase;
	
	initial begin
		// Initialize Inputs
		phase=0;
		ckref = 0;
		RESET = 0;
		hit=0;
		resetpll=1;
		enableHitskip=1;
		#100 resetpll=0;
		#100 RESET = 1;
		#5000 RESET = 0;
		// Wait 100 ns for global reset to finish
		#1000;
        
		#10000;
		phase=100;
		
		#1000000;
		phase=125;
		#1000000;
		phase=125;
		#1000000;
		phase=125;
		#1000000;
		phase=125;
		#1000000;
		phase=125;

		// Add stimulus here

	end
	
	always @(negedge ckref)
		phase=phase * 0.9;

	always
		#125 ckref = ~ckref;
		
	always @(posedge ckref)
		#(phase) hit=1;
	
	always @(posedge hit)
		#125 hit = 0;
	
      
endmodule

