`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:49:08 11/30/2015 
// Design Name: 
// Module Name:    TDCslave 
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
module TDCslave(
		input wire ckref,
		input wire RESET,
		input wire hit1,

		//CH1
		output wire [31:0] IPbus_RAM_data1, //DPRAM 
		output wire [7:0]  IPbus_RAM_address1,
		output wire IPbus_RAM_we1,
		input wire handshakePC1,
		output wire handshakeFPGA1,
		output wire [31:0] hitCount1,
		

		
		output wire SYSCLK,
		output wire REFPLL,
		output wire TRIGGER
    );
	 
	 
	wire CLK_0;
	wire CLK_45;
	wire CLK_90;
	wire CLK_135;
	
	
	wire enableHitskip;
	assign enableHitskip=0;
	
	reg [7:0] triggerCounter;
	reg [31:0] hitCount1_tm1;
	
	always @(posedge SYSCLK) begin //runs at 192 MHz
		if( hitCount1_tm1 == hitCount1) begin
			if (triggerCounter != 0) begin
				triggerCounter<=triggerCounter -1;		
			end else begin
				triggerCounter<=0;
			end
		end else begin
			hitCount1_tm1<=hitCount1;
			triggerCounter<=255;
		end
	end
	
	assign TRIGGER = (triggerCounter == 0) ? 0 : 1;
	
	
	PLL PLLgen (
		.CLK_IN1(ckref), 
		.CLK_OUT1(CLK_0), 
		.CLK_OUT2(CLK_45), 
		.CLK_OUT3(CLK_90), 
		.CLK_OUT4(CLK_135), 
		.CLK_OUT5(SYSCLK),
		.CLK_OUT6(REFPLL),
		.RESET(1'b0)
	);
	
	 dataChannel dc1(
		 .CLK_0(CLK_0),
		 .CLK_45(CLK_45),
		 .CLK_90(CLK_90),
		 .CLK_135(CLK_135),
		 .SYSCLK(SYSCLK),	
		 .hit(hit1),   //hit signal
		 .RESET(RESET), //Reset
		 
		 .enableHitskip(enableHitskip), //if you want odd frames to be skipped, must be true
		 .IPbus_RAM_data(IPbus_RAM_data1), //DPRAM 
		 .IPbus_RAM_address(IPbus_RAM_address1),
		 .IPbus_RAM_we(IPbus_RAM_we1),
		 .handshakePC(handshakePC1), //Handshaking to PC
		 .handshakeFPGA(handshakeFPGA1),
		 
		 .hitCount(hitCount1)
    );
	 



endmodule
