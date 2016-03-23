`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:10:40 08/21/2015 
// Design Name: 
// Module Name:    DPREG 
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
module DPREG(sysclk,reset,uart_dbus_in,uart_dbus_out,uart_reg,uart_dbus_w,uart_dbus_r
    );
	
input sysclk,reset,uart_dbus_w,uart_dbus_r;
input [7:0] uart_dbus_in,uart_reg;
output reg [7:0] uart_dbus_out;
reg [7:0] CONF0,CONF1,CONF2,CONF3;

wire [7:0] datain;
assign datain=uart_dbus_in;

always @(posedge sysclk) begin
	if (reset) begin
		CONF0<=0;
		CONF1<=0;
		CONF2<=0;
		CONF3<=0;
	end else begin
		if(uart_dbus_w) begin
			case(uart_reg)
				8'h0:
					CONF0<=datain;
				8'h1:
					CONF1<=datain;
				8'h2:
					CONF2<=datain;
				8'h3:
					CONF3<=datain;		
			endcase
		end
	end
end

always @(uart_dbus_r,uart_reg) begin
	if(uart_dbus_r==1) begin
		case(uart_reg)
			8'h0: uart_dbus_out<=CONF0;
			8'h1: uart_dbus_out<=CONF1;
			8'h2: uart_dbus_out<=CONF2;
			8'h3: uart_dbus_out<=CONF3;
			8'h4: uart_dbus_out<=8'hAA;
			default: uart_dbus_out<=8'h0;
		endcase
	end else
		uart_dbus_out<=8'h0;
end

endmodule
