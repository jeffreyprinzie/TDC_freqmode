`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:22:56 08/21/2015 
// Design Name: 
// Module Name:    UARTfsm 
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
module UARTfsm(sysclk,reset,baud16,tx_fifo_write,tx_fifo_data,dataAvailable,uart_datain,dbus_reg,dbus_data_out,dbus_data_in,dbus_w,dbus_r
    );
input sysclk,reset,dataAvailable,baud16;
input [7:0] uart_datain,dbus_data_in;
output wire tx_fifo_write;
output wire dbus_w,dbus_r;
output wire [7:0] dbus_data_out,tx_fifo_data;
output wire [7:0] dbus_reg;


reg [3:0] FSMstate;
reg [3:0] FSMstate_next;

reg [7:0] REGISTER;
reg [7:0] COUNT;
reg [7:0] COMMAND;
parameter IDLE=4'h0;
parameter GETCOMMAND=4'h1;
parameter GETREGISTER=4'h2;
parameter GETCOUNT=4'h3;
parameter CHECKCOMMAND=4'h4;
parameter RECEIVEBYTES=4'h5;
parameter WAITFORBYTE=4'h6;
parameter WRITEBYTEONBUS=4'h7;
parameter WRITEBYTESTOTXFIFO=4'h8;

reg [7:0] registerIndex;

reg [11:0] watchdogCtr;

//next state combo
always @(reset,FSMstate,registerIndex,dataAvailable,COMMAND,COUNT) begin
	if(reset || watchdogCtr[11]) begin
		FSMstate_next<=IDLE;
	end else begin
		case(FSMstate)
			//state waiting for a command
			IDLE: 
				if(dataAvailable)
					FSMstate_next<=GETCOMMAND;
				else
					FSMstate_next<=IDLE;
			GETCOMMAND:
				if(dataAvailable)
					FSMstate_next<=GETREGISTER;
				else
					FSMstate_next<=GETCOMMAND;
			GETREGISTER:
				if(dataAvailable)
					FSMstate_next<=GETCOUNT;
				else
					FSMstate_next<=GETREGISTER;
			GETCOUNT:
					FSMstate_next<=CHECKCOMMAND;
			CHECKCOMMAND:
				case (COMMAND)
					8'h1: //receive bytes
						FSMstate_next<=RECEIVEBYTES;
					8'h2:
						FSMstate_next<=WRITEBYTESTOTXFIFO;
					default FSMstate_next<=IDLE;
				endcase
			RECEIVEBYTES:
				if(registerIndex<COUNT)
					FSMstate_next<=WAITFORBYTE;
				else
					FSMstate_next<=IDLE;
			WAITFORBYTE:
				if(dataAvailable)
					FSMstate_next<=WRITEBYTEONBUS;
				else
					FSMstate_next<=WAITFORBYTE;
			WRITEBYTEONBUS:
				FSMstate_next<=RECEIVEBYTES;
				
			
			WRITEBYTESTOTXFIFO:
				if((registerIndex+1)<COUNT)
					FSMstate_next<=WRITEBYTESTOTXFIFO;
				else
					FSMstate_next<=IDLE;
					
			default: FSMstate_next<=IDLE;
				
		endcase	
	end
end

always @(posedge sysclk) begin
if(baud16)
	if(reset)
		watchdogCtr<=0;
	else
		if(FSMstate_next == FSMstate && FSMstate != IDLE && FSMstate_next != IDLE) 
			watchdogCtr<=watchdogCtr+1;
		else
			watchdogCtr<=0;
end
always @(posedge sysclk)
	FSMstate<=FSMstate_next;
always @(posedge sysclk) begin
	if(FSMstate_next==GETCOMMAND && dataAvailable)
		COMMAND<=uart_datain;
end
always @(posedge sysclk) begin
	if(FSMstate_next==GETREGISTER && dataAvailable)
		REGISTER<=uart_datain;
end
always @(posedge sysclk) begin
	if(FSMstate_next==GETCOUNT && dataAvailable)
		COUNT<=uart_datain;
		
end

always @(posedge sysclk) begin
	if(FSMstate==IDLE)
		registerIndex<=8'h0;
	else if(FSMstate==WRITEBYTEONBUS || FSMstate==WRITEBYTESTOTXFIFO)
		registerIndex<=registerIndex+1;
end


assign dbus_data_out=(dbus_w==1) ? uart_datain : 0;
assign dbus_w=(FSMstate_next==WRITEBYTEONBUS) ? 1 : 0;

assign dbus_reg=REGISTER+registerIndex;

assign dbus_r = (FSMstate==WRITEBYTESTOTXFIFO) ? 1: 0;
assign tx_fifo_write = dbus_r;

assign tx_fifo_data=(dbus_r==1) ? dbus_data_in : 0;

endmodule
