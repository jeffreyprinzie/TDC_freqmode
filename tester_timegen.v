`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:13:52 11/18/2015 
// Design Name: 
// Module Name:    tester_timegen 
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
module tester_timegen(
	input ckref_P,
	input ckref_N,
	output wire hit_P,
	output wire hit_N,
	//input hit,
	output wire [7:0] TDCfifo_dout
    );


		wire ckref_buff;
		wire fifo_data_available;

		wire hit;
	   assign hit=~ckref_buff;
		
		timegen TDCcore (
		.ckref(ckref_buff), 
		.RESET(1'b0),
		.resetpll(1'b0),
		.hit_in(hit),
		.fifo_data_available(fifo_data_available),
		.read_fifo(fifo_data_available),
		.fifo_dout(TDCfifo_dout),
		.SYSCLK(SYSCLK),
		.enableHitskip(1'b1)
	);
	

	   IBUFGDS input_buffer_ckref
   (.O   (ckref_buff),
    .I   (ckref_P),
	 .IB   (ckref_N));
	 
	 
	 OBUFDS outputmirror
	 (.I(ckref_buff),
		.O(hit_P),
		.OB(hit_N));
		
	
	
	
	
	
endmodule
