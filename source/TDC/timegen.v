`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:16:05 11/03/2015 
// Design Name: 
// Module Name:    timegen 
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
module timegen(
		 ckref,
		 hit_in,
		 RESET,
		 resetpll,
		 fifo_data_available,
		 read_fifo,
		 fifo_dout,
		 SYSCLK,
		 enableHitskip
    );
	
	
	input wire ckref,RESET,hit_in,resetpll,read_fifo,enableHitskip;
	output wire fifo_data_available;
	output wire [7:0] fifo_dout;
		
	wire hit,hit_ub;
	reg hit_enable;
	always @(negedge hit_in) begin
		if(RESET)
			hit_enable<=0;
		else
			hit_enable <=  ~hit_enable;
	end

	assign hit_ub = (enableHitskip) ? (hit_in && hit_enable) : hit_in;
	BUFG buffer
   (.O   (hit),
    .I   (hit_ub));
	// Outputs
	wire CLK_0;
	wire CLK_45;
	wire CLK_90;
	wire CLK_135;
	output wire SYSCLK;
	

	reg [2:0] counter_val_CK0;
	reg [2:0] counter_val_CK180;
	
	reg [3:0] hit_registers_L0,hit_registers_L1;
	reg [2:0] counter_val_CK0_L0,counter_val_CK180_L0,counter_val_CK0_L1,counter_val_CK180_L1,coarse_time;
	
	reg hit_syn,hit_syn0;
	
	// Instantiate the Unit Under Test (UUT)
	
	reg [2:0] fine_time_decoded;
	wire [7:0] timing_data;
	assign timing_data={2'h0,coarse_time,fine_time_decoded};
	//assign timing_data={1'h0,coarse_time,hit_registers_L1};
	reg  valid_hit;
	PLL PLLgen (
		.CLK_IN1(ckref), 
		.CLK_OUT1(CLK_0), 
		.CLK_OUT2(CLK_45), 
		.CLK_OUT3(CLK_90), 
		.CLK_OUT4(CLK_135), 
		.CLK_OUT5(SYSCLK),
		.RESET(resetpll)
	);
	
	wire fifo_full,fifo_empty;

	wire wr_en;
	assign wr_en=(FSMstate==WRITEFIFO) ? 1'b1 : 1'b0;
	assign fifo_data_available = ~fifo_empty;
	hitFIFO hit_fifo (
  .clk(SYSCLK), // input clk
  .rst(RESET), // input rst
  .din(timing_data), // input [7 : 0] din
  .wr_en(wr_en), // input wr_en
  .rd_en(read_fifo), // input rd_en
  .dout(fifo_dout), // output [7 : 0] dout
  .empty(fifo_empty) // output empty
);
	
	localparam WAITFORHIT=4'h0;
	localparam DECODE=4'h1;
	localparam WRITEFIFO=4'h2;
	localparam END=4'h3;
	
	
	
	reg [3:0] FSMstate,FSMstate_next;
	
	
	
	//DATA capture
	always @(posedge SYSCLK) begin
		if(RESET) begin
			hit_registers_L1<=0;
			counter_val_CK0_L1 <=0;
			counter_val_CK180_L1 <=0;
		end else begin
			if((FSMstate == WAITFORHIT) && (hit_syn==1)) begin
				hit_registers_L1<=hit_registers_L0;
				counter_val_CK0_L1 <=counter_val_CK0_L0;
				counter_val_CK180_L1 <=counter_val_CK180_L0;
			end 
		end
	end

	//DECODE logic
	
	//DECODE logic Bubble filling


	always @(posedge SYSCLK) begin
		if(RESET) begin
			fine_time_decoded<=0;
			valid_hit<=1;
		end else begin
			if(FSMstate == DECODE) begin
				case (hit_registers_L1)
					4'b0000: begin
									fine_time_decoded<=3'h7;
									coarse_time<=counter_val_CK0_L1;
									valid_hit<=1;
								end
					4'b1000: begin
									fine_time_decoded<=3'h0;
									coarse_time<=counter_val_CK180_L1+3'h1;
									valid_hit<=1;
								end
					4'b1100: begin
									fine_time_decoded<=3'h1;
									coarse_time<=counter_val_CK180_L1+3'h1;
									valid_hit<=1;
								end
					4'b1110: begin
									fine_time_decoded<=3'h2;
									coarse_time<=counter_val_CK180_L1+3'h1;
									valid_hit<=1;
								end
					4'b1111: begin
									fine_time_decoded<=3'h3;
									coarse_time<=counter_val_CK180_L1+3'h1;
									valid_hit<=1;
								end
					4'b0111: begin
									fine_time_decoded<=3'h4;
									coarse_time<=counter_val_CK0_L1;
									valid_hit<=1;
								end
					4'b0011: begin
									fine_time_decoded<=3'h5;
									coarse_time<=counter_val_CK0_L1;
									valid_hit<=1;
								end
					4'b0001: begin
									fine_time_decoded<=3'h6;
									coarse_time<=counter_val_CK0_L1;
									valid_hit<=1;
								end		
					default: begin
									fine_time_decoded<=3'h0;
									valid_hit<=0;
								end
				endcase
			end 
		end
	end
	
	//FSM logic
	always @(FSMstate,hit_syn,valid_hit) begin
		case(FSMstate) 
		WAITFORHIT:
			if(hit_syn==1) begin
				FSMstate_next<=DECODE;
			end else begin
				FSMstate_next<=WAITFORHIT;
			end
		DECODE:
			if(valid_hit)
				FSMstate_next<=WRITEFIFO;
			else
				FSMstate_next<=END;
			
		WRITEFIFO:
			FSMstate_next<=END;
		
		END: //If the hit is not decoded at this time and a new has already passed, the FSM will wait here for the next hit and skip this one.
			if(hit_syn==1) begin
				FSMstate_next<=END;
			end else begin
				FSMstate_next<=WAITFORHIT;
			end
		default: 
			FSMstate_next<=WAITFORHIT;
		endcase
	end
	//fsm reg
	always @(posedge SYSCLK) begin
		if(RESET)
			FSMstate<=0;
		else
			FSMstate<=FSMstate_next;
	end
	
	//hit detect synchronisation
	always @(posedge SYSCLK) begin
		if(RESET) begin
			hit_syn0<=0;
			hit_syn<=0;
		end else begin
			hit_syn0<=hit;
			hit_syn<=hit_syn0;
		end
	end
	
	
	
	//L0 hit registers
	always @(posedge hit or posedge RESET) begin
		if(RESET)
			hit_registers_L0 <=0;
		else
			hit_registers_L0 <= {CLK_0,CLK_45,CLK_90,CLK_135}; //Level 0 hit registers	
	end	
	
	//L0 counter registers
	always @(posedge hit or posedge RESET) begin
		if(RESET) begin
			counter_val_CK0_L0 <=0;
			counter_val_CK180_L0 <=0;
		end else begin //Level 0 counter data
			counter_val_CK0_L0 <=counter_val_CK0;
			counter_val_CK180_L0 <=counter_val_CK180;
		end
	end
	
	
	//Cycle counters

	//this counter counts at CLK0
	always @(posedge CLK_0 or posedge RESET) begin
		if(RESET)
			counter_val_CK0<=0;
		else
				counter_val_CK0<=counter_val_CK0 + 3'h1;
	end
	//This counter counts at CLK180, but it is synchronised with the counter at CLK0. Only the data is copied. This counter is used to metastability purpose.
	always @(negedge CLK_0 or posedge RESET) begin
		if(RESET)
			counter_val_CK180<=0;
		else
			counter_val_CK180<=counter_val_CK0;
	end
		

endmodule
