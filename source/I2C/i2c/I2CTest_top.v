`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:47:38 05/26/2015 
// Design Name: 
// Module Name:    uartTest_top 
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

`define SEUSIM
module programmer(
	 clkin,

	 sda,
	 scl,
	 //rx,
	 //tx,
	 //enUART,
	 commBusy,
	 p_sck_inv,
	 p_sda_inv,
	 p_scapt_inv,
	 p_reset_inv
    );


input wire clkin;

input scl;
inout sda;
//input wire rx,enUART;
//output wire tx;
output wire commBusy;
output wire p_sda_inv,p_sck_inv,p_scapt_inv,p_reset_inv;

wire p_sda,p_sck,p_scapt,p_reset;
assign p_sda_inv = ! p_sda;
assign p_sck_inv= ! p_sck;
assign p_reset_inv = ! p_reset;
assign p_scapt_inv= ! p_scapt;

wire [7:0]  myReg1,myReg2,myReg3,myReg4,myReg5,myReg6,myReg7,myReg8,myReg9,myReg10,myReg11,myReg12,myReg13;

wire [7:0]  myReg1in,myReg2in,myReg3in,myReg4in,myReg5in,myReg6in,myReg7in,myReg8in,myReg9in,myReg10in,myReg11in,myReg12in,myReg13in;
wire rst;
assign rst=0;


localparam myReg2_s0=254;
localparam myReg3_s0=128;
localparam myReg4_s0=7;
localparam myReg5_s0=0;
localparam myReg6_s0=248;
localparam myReg7_s0=3;
localparam myReg8_s0=192;
localparam myReg9_s0=1;
localparam myReg10_s0=128;
localparam myReg11_s0=15;
localparam myReg12_s0=128;
localparam myReg13_s0=12;

localparam myReg2_s1=254;
localparam myReg3_s1=128;
localparam myReg4_s1=7;
localparam myReg5_s1=0;
localparam myReg6_s1=248;
localparam myReg7_s1=3;
localparam myReg8_s1=192;
localparam myReg9_s1=1;
localparam myReg10_s1=128;
localparam myReg11_s1=15;
localparam myReg12_s1=128;
localparam myReg13_s1=11;

`ifdef SEUSIM
	reg configsel;
	reg [25:0] prescaleCounter;
	wire prescale_tick;
	reg startProgram;
	
	assign prescale_tick = (prescaleCounter==0) ? 1 : 0;
	
	
	always @(posedge clkin) begin
		startProgram=prescale_tick;
		prescaleCounter<=prescaleCounter+1;
	end
	
	always @(posedge clkin ) begin
	if(prescale_tick)
		configsel=~configsel;
	end
	
	assign myReg1in={6'h0,startProgram};
	assign myReg2in=(configsel==1) ? myReg2_s0 : myReg2_s1;
	assign myReg3in=(configsel==1) ? myReg3_s0 : myReg3_s1;
	assign myReg4in=(configsel==1) ? myReg4_s0 : myReg4_s1;
	assign myReg5in=(configsel==1) ? myReg5_s0 : myReg5_s1;
	assign myReg6in=(configsel==1) ? myReg6_s0 : myReg6_s1;
	assign myReg7in=(configsel==1) ? myReg7_s0 : myReg7_s1;
	assign myReg8in=(configsel==1) ? myReg8_s0 : myReg8_s1;
	assign myReg9in=(configsel==1) ? myReg9_s0 : myReg9_s1;
	assign myReg10in=(configsel==1) ? myReg10_s0 : myReg10_s1;
	assign myReg11in=(configsel==1) ? myReg11_s0 : myReg11_s1;
	assign myReg12in=(configsel==1) ? myReg12_s0 : myReg12_s1;
	assign myReg13in=(configsel==1) ? myReg13_s0 : myReg13_s1;
	

`else
	assign myReg1in=myReg1;
	assign myReg1in=myReg2;
	assign myReg1in=myReg3;
	assign myReg1in=myReg4;
	assign myReg1in=myReg5;
	assign myReg1in=myReg6;
	assign myReg1in=myReg7;
	assign myReg1in=myReg8;
	assign myReg1in=myReg9;
	assign myReg1in=myReg10;
	assign myReg1in=myReg11;
	assign myReg1in=myReg12;
	assign myReg1in=myReg13;
`endif


CommunicationController UCOMM(
  clkin,
  rst,
  sda,
  scl,
  //tx,
  //rx,
  //enUART,
  myReg1,
  myReg2,
  myReg3,
  myReg4,
  myReg5,
  myReg6,
  myReg7,
  myReg8,
  myReg9,
  myReg10,
  myReg11,
  myReg12,
  myReg13
);


SerialConfig(
		clkin,
		1'b0,
		p_sck,
		p_sda,
		p_scapt,
		p_reset,
		
		myReg1in,
		myReg2in,
		myReg3in,
		myReg4in,
		myReg5in,
		myReg6in,
		myReg7in,
		myReg8in,
		myReg9in,
		myReg10in,
		myReg11in,
		myReg12in,
		myReg13in
    );

reg [22:0] commBusyCtr;
always @(posedge clkin) begin
	if (scl==0)// || rx ==0)
		commBusyCtr<=0;
	else
		if(!commBusyCtr[22])
			commBusyCtr<=commBusyCtr+1;
end	

`ifndef SEUSIM		
assign commBusy = !commBusyCtr[22]	;
`else
assign commBusy=configsel;
`endif


 /*logicAnalyser LA1(
		clkin, //system clock
		LA_data, // 8 bits to output
		LA_trigger,
		myReg0,
		myReg1,
		myReg2,
		myReg3,
		8'h12,
		8'h34,
		8'h56,
		8'h78

    );

*/

endmodule
