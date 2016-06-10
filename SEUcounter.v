`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:08:20 06/10/2016 
// Design Name: 
// Module Name:    SEUcounter 
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
module SEUcounter(
    input SEUin,
    input clk,
    output reg [31:0] CTRout
    );
	 
	 reg [2:0] glitch_filt;
	 reg SEU_presyn1,SEU_syn,SEU,SEU_d1;
	 //synch the SEU signal since it is not synched with the clock
	 always @(posedge clk) begin
			SEU_presyn1<=SEUin;
			SEU_syn<=SEU_presyn1;
			
			SEU_d1<=SEU;
	 end
	 
	 //SEU glitch filtering
	 always @(posedge clk) begin
		  if(SEU_syn==1) begin
					glitch_filt<=3'b111;
					SEU<=1;
		  end else begin
				if(glitch_filt!=3'b000)
					glitch_filt<=glitch_filt-1;
				else
					SEU<=0;
		  end
	 
	 end
	 
	 always @(posedge clk) begin
		if(SEU==1 & SEU_d1==0)
			CTRout<=CTRout+1;
	 end
	 


endmodule
