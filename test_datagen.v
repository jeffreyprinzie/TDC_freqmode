`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:46:55 11/25/2015 
// Design Name: 
// Module Name:    test_datagen 
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
module test_datagen(
    input clk,
    input handshakePC,
    output reg handshakeFPGA,
    output wire we,
    output wire [31:0] data,
    output reg [7:0] address,
	 output  [31:0] framecount
    );
	 
	 
	 reg [18:0] ctr;
	 reg trigger;
	 
	reg [31:0] framecount = 0;
	always @(posedge clk) begin
		ctr<=ctr+1;
		if(ctr==0) begin
			trigger<=1;
			framecount<=framecount+1;
		end else begin
			trigger<=0;
			framecount<=framecount;
		end
	
	end
	
	reg [1:0] FSMstate,FSMstate_next;
	localparam IDLE = 2'h0;
	localparam DUMPING = 2'h1;
	localparam END = 2'h2;
	reg [30:0] d;
	assign we = (FSMstate==DUMPING) ? 1 : 0;
	assign data=framecount;

	always @(FSMstate,trigger,handshakePC,handshakeFPGA) begin
		case(FSMstate)
			IDLE:
				if(trigger)
					if(handshakePC==handshakeFPGA)
						FSMstate_next<=DUMPING;
					else
						FSMstate_next<=END;
				else
					FSMstate_next<=IDLE;
			DUMPING:
				if(address==8'hff)
					FSMstate_next<=END;
				else
					FSMstate_next<=DUMPING;
					
			END:
				FSMstate_next<=IDLE;
			default:
				FSMstate_next<=IDLE;
		
		endcase
	
	end
	
	always @(posedge clk) begin
		FSMstate<=FSMstate_next;
		if(FSMstate==DUMPING && FSMstate_next==END)
			handshakeFPGA<=~handshakeFPGA;
		else
			handshakeFPGA<=handshakeFPGA;
	end
	always @(posedge clk) begin
		if(FSMstate==DUMPING)
			address<=address + 8'h01;
		else
			address <= 8'h00;
	end
	

endmodule
