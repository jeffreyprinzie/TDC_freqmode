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
wire rst;
assign rst=0;



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

reg [22:0] commBusyCtr;
always @(posedge clkin) begin
	if (scl==0)// || rx ==0)
		commBusyCtr<=0;
	else
		if(!commBusyCtr[22])
			commBusyCtr<=commBusyCtr+1;
end			
assign commBusy = !commBusyCtr[22]	;



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
