`timescale 1ns / 1ps

module logicAnalyser(
		clk, //system clock
		Dout, // 8 bits to output
		trigger,
		reg0,
		reg1,
		reg2,
		reg3,
		reg4,
		reg5,
		reg6,
		reg7

    );
parameter FrameSize=4'd15; //how many clk cycles for one frame

input wire clk;
output reg [7:0] Dout;
input wire [7:0] reg0,reg1,reg2,reg3,reg4,reg5,reg6,reg7;
output reg trigger;

reg [3:0] clkDiv;
reg [2:0] regCtr;
always @(posedge clk) begin
	clkDiv<=clkDiv+1;
	
	
	if(clkDiv==FrameSize) begin
		clkDiv<=0;
		regCtr<=regCtr+1;
		trigger<=0;
		case(regCtr)
			3'h0: begin
						trigger<=1;
						Dout<=reg0;
					end
			3'h1: Dout<=reg1;
			3'h2:	Dout<=reg2;	
			3'h3:	Dout<=reg3;	
			3'h4:	Dout<=reg4;	
			3'h5:	Dout<=reg5;	
			3'h6:	Dout<=reg6;	
			3'h7:	Dout<=reg7;				
		endcase	
		
	end
end

endmodule
