`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:24:07 08/25/2015 
// Design Name: 
// Module Name:    SerialConfig 
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
module SerialConfig(
		sysclk,
		rst,
		sck,
		sda,
		scapt,
		reset,
		
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

input sysclk,rst;
output reg sck,sda;
output wire scapt,reset;
input wire [7:0]  myReg1,myReg2,myReg3,myReg4,myReg5,myReg6,myReg7,myReg8,myReg9,myReg10,myReg11,myReg12,myReg13;
wire [7:0]  myReg2_r,myReg3_r,myReg4_r,myReg5_r,myReg6_r,myReg7_r,myReg8_r,myReg9_r,myReg10_r,myReg11_r,myReg12_r,myReg13_r;//reversed

genvar i;
for (i=0; i<8; i=i+1) assign myReg2_r[i] = myReg2[7-i];
for (i=0; i<8; i=i+1) assign myReg3_r[i] = myReg3[7-i];
for (i=0; i<8; i=i+1) assign myReg4_r[i] = myReg4[7-i];
for (i=0; i<8; i=i+1) assign myReg5_r[i] = myReg5[7-i];
for (i=0; i<8; i=i+1) assign myReg6_r[i] = myReg6[7-i];
for (i=0; i<8; i=i+1) assign myReg7_r[i] = myReg7[7-i];
for (i=0; i<8; i=i+1) assign myReg8_r[i] = myReg8[7-i];
for (i=0; i<8; i=i+1) assign myReg9_r[i] = myReg9[7-i];
for (i=0; i<8; i=i+1) assign myReg10_r[i] = myReg10[7-i];
for (i=0; i<8; i=i+1) assign myReg11_r[i] = myReg11[7-i];
for (i=0; i<8; i=i+1) assign myReg12_r[i] = myReg12[7-i];
for (i=0; i<8; i=i+1) assign myReg13_r[i] = myReg13[7-i];

reg [3:0] FSMstate,FSMstate_next;
localparam IDLE=4'h0;
localparam PROGRAMSERIAL=4'h1;
localparam SCAPT=4'h2;
localparam SCAPT2=4'h3;
localparam RESETPROG=4'h4;
localparam RESETPROG2=4'h5;
localparam END=4'h6;

reg [92:0] shiftregister,shiftregister_next;
reg [7:0] shiftCtr,shiftCtr_next;

localparam PSVAL=254;
reg [9:0] prescaler;
wire tick;


assign tick_p = (prescaler == PSVAL/2) ? 1 : 0;
assign tick_n = (prescaler == 0) ? 1 : 0;

always @(FSMstate,shiftCtr,shiftregister,myReg1,myReg2,myReg3,myReg4,myReg5,myReg6,myReg7,myReg8,myReg9,myReg10,myReg11,myReg12,myReg13,tick_n,tick_p) begin
	case (FSMstate)
		IDLE:
			if(myReg1==1) begin
				FSMstate_next<=PROGRAMSERIAL;
				shiftregister_next<= {myReg2_r,myReg3_r,myReg4_r,myReg5_r,myReg6_r,myReg7_r,myReg8_r,myReg9_r,myReg10_r,myReg11_r,myReg12_r,myReg13_r[7:3]};
				shiftCtr_next<=0;
			end else if (myReg1==2) begin
				FSMstate_next<=RESETPROG;
				shiftCtr_next<=0;
				shiftregister_next<=0;
			
			end else begin
				FSMstate_next<=IDLE;
				shiftCtr_next<=0;
				shiftregister_next<=0;
			end
				
			
		PROGRAMSERIAL: begin
			if(tick_n) begin
				shiftregister_next <= {1'b0,shiftregister[92:1]};
				shiftCtr_next<=shiftCtr+1;
			end else begin
				shiftregister_next <= shiftregister;
				shiftCtr_next<=shiftCtr;
			end
			
			if(tick_n)
				if(shiftCtr==93)
					FSMstate_next<=SCAPT;
				else
					FSMstate_next<=PROGRAMSERIAL;
			else
					FSMstate_next<=PROGRAMSERIAL;
			end
		
		SCAPT: begin
			if(tick_p)
				FSMstate_next<=SCAPT2;
			else
				FSMstate_next<=SCAPT;
			shiftCtr_next<=0;
			shiftregister_next<=0;
			end
			
		SCAPT2: begin
			if(tick_p)
				FSMstate_next<=END;
			else
				FSMstate_next<=SCAPT2;
			shiftCtr_next<=0;
			shiftregister_next<=0;
			end
			
		RESETPROG: begin
			if(tick_p)
				FSMstate_next<=RESETPROG2;
			else
				FSMstate_next<=RESETPROG;
			
			shiftCtr_next<=0;
			shiftregister_next<=0;
			end

		RESETPROG2: begin
			if(tick_p)
				FSMstate_next<=END;
			else
				FSMstate_next<=RESETPROG2;
			
			shiftCtr_next<=0;
			shiftregister_next<=0;
			
			end
		END: begin
			shiftCtr_next<=0;
			shiftregister_next<=0;
			if(myReg1==0)
				FSMstate_next<=IDLE;
			else
				FSMstate_next<=END;
		end
		default: begin
			FSMstate_next<=IDLE;
			shiftCtr_next<=0;
			shiftregister_next<=0;
			end
	endcase
end

always @(posedge sysclk) begin

	if(rst) begin
			FSMstate <= 0;
			shiftregister <= 0;
			shiftCtr <= 0;
			sck<=0;
			sda<=0;
			prescaler<=0;
	end else begin
	FSMstate <= FSMstate_next;
	shiftregister <= shiftregister_next;
	shiftCtr <= shiftCtr_next;
	
	if((FSMstate==IDLE && FSMstate_next==PROGRAMSERIAL) || (FSMstate==IDLE && FSMstate_next==RESETPROG))
		prescaler<=0;
	else if(prescaler==PSVAL)
		prescaler<=0;
	else
		prescaler<=prescaler+1;
	
	if(FSMstate==PROGRAMSERIAL) begin
		if(tick_p) begin
			sck<=1;
		end else if(tick_n) begin
			sck<=0;
			sda<=shiftregister[0];
		end
	end else begin
		sck<=0;
		sda<=0;
	end
	end
end

assign scapt = (FSMstate == SCAPT2) ? 1 : 0;
assign reset = (FSMstate == RESETPROG || FSMstate == RESETPROG2) ? 1 : 0;


endmodule
