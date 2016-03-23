`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:44:30 11/07/2015 
// Design Name: 
// Module Name:    dataChannel 
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
module dataChannel(
		 CLK_0,
		 CLK_45,
		 CLK_90,
		 CLK_135,
		 SYSCLK,	
		 hit,   //hit signal
		 RESET, //Reset
		 
		 enableHitskip, //if you want odd frames to be skipped, must be true
		 IPbus_RAM_data, //DPRAM 
		 IPbus_RAM_address,
		 IPbus_RAM_we,
		 handshakePC, //Handshaking to PC
		 handshakeFPGA ,
		 hitCount
		 
    );
	 output reg [31:0] hitCount;
	//output wire [2:0] finetime;
	input wire RESET,hit,enableHitskip,handshakePC;
	input wire CLK_0;
	input wire CLK_45;
	input wire CLK_90;
	input wire CLK_135;
	input wire SYSCLK;
	
   output wire [31:0] IPbus_RAM_data;
	output wire [7:0] IPbus_RAM_address;
	output wire IPbus_RAM_we,handshakeFPGA;
	
	wire read_fifo;
	wire [7:0] TDCfifo_dout;
	
	//assign finetime={1'b0,handshakeFPGA,handshakePC};//FSMstate[2:0];//TDCfifo_dout[2:0];
	
	timegen TDCcore (
		.CLK_0(CLK_0),
		.CLK_45(CLK_45),
		.CLK_90(CLK_90),
		.CLK_135(CLK_135),
		.SYSCLK(SYSCLK), 
		.RESET(RESET),
		.hit_in(hit),
		.fifo_data_available(fifo_data_available),
		.read_fifo(read_fifo),
		.fifo_dout(TDCfifo_dout),
		.enableHitskip(enableHitskip)
	);

	

	
		

	reg [3:0] FSMstate,FSMstate_next;
	localparam IDLE=4'h0;
	localparam PROCESSHIT1=4'h1;
	localparam WAITFORHIT2=4'h2;
	localparam PROCESSHIT2=4'h3;
	localparam WAITFORHIT3=4'h4;
	localparam PROCESSHIT3=4'h5;
	localparam STARTRAMDUMP=4'h6;
	localparam END=4'h7;
	
	reg write_buffer;
	 
	 wire dumpMem;
	 wire dumpdone;

	
	rammgmt ramManager(
		.dumpMem(dumpMem),
		.write_En_datachannel(write_buffer),
		.data_datachannel(TDCfifo_dout),
		.SYSCLK(SYSCLK),
		.reset(RESET),
		.dumpdone(dumpdone),
		.IPbus_RAM_data(IPbus_RAM_data),
		.IPbus_RAM_address(IPbus_RAM_address),
		.IPbus_RAM_we(IPbus_RAM_we),
		.handshakeFPGA(handshakeFPGA),
		.handshakePC(handshakePC)
    );
		
	 
	assign read_fifo = (FSMstate_next == PROCESSHIT1 || FSMstate_next == PROCESSHIT2 || FSMstate_next == PROCESSHIT3 || (FSMstate==STARTRAMDUMP && fifo_data_available)) ? 1 :0; //Read from the FIFO such that data is available in state processtrigger.
	assign dumpMem = (FSMstate == STARTRAMDUMP);
	
	always @(posedge SYSCLK) begin
		write_buffer<=read_fifo; // 1cycle delayed when the data is out of the fifo
	end	
	
	reg [7:0] hit0,hit1;
	
	always @(FSMstate,fifo_data_available,TDCfifo_dout,hit0,hit1,dumpdone) begin
		case(FSMstate)
		IDLE:
			if(fifo_data_available)
				FSMstate_next<=PROCESSHIT1;
			else
				FSMstate_next<=IDLE;
				
		PROCESSHIT1:	
			FSMstate_next<=WAITFORHIT2;
		
		WAITFORHIT2:
			if(fifo_data_available)
				FSMstate_next<=PROCESSHIT2;
			else
				FSMstate_next<=WAITFORHIT2;
		PROCESSHIT2:	
			if(TDCfifo_dout==hit0)
				FSMstate_next<=WAITFORHIT2;
			else
				FSMstate_next<=WAITFORHIT3;	
		WAITFORHIT3:
			if(fifo_data_available)
				FSMstate_next<=PROCESSHIT3;
			else
				FSMstate_next<=WAITFORHIT3;
		PROCESSHIT3:	
			if(TDCfifo_dout==hit0 || TDCfifo_dout==hit1)
				FSMstate_next<=WAITFORHIT3;
			else
				FSMstate_next<=STARTRAMDUMP;
				
		STARTRAMDUMP:
			if(dumpdone)
				FSMstate_next<=END;
			else
				FSMstate_next<=STARTRAMDUMP;
		END:
			
			FSMstate_next<=IDLE;
		default:
			FSMstate_next<=IDLE;
		endcase;
	end
	
	always @(posedge SYSCLK) begin
		if(RESET) begin
			FSMstate<=IDLE;
		end else begin
			FSMstate<=FSMstate_next;

		end
	end
	
	always @(posedge SYSCLK) begin	
		if(FSMstate==PROCESSHIT1)
			hit0<=TDCfifo_dout;
	end
	always @(posedge SYSCLK) begin	
		if(FSMstate==PROCESSHIT2 && FSMstate_next==WAITFORHIT3 )
			hit1<=TDCfifo_dout;
	end

	always @(posedge SYSCLK) begin
		if(RESET) begin
			hitCount<=0;
		end else begin
			if(FSMstate==END)
				hitCount<=hitCount+1;
			else
				hitCount<=hitCount;
		end
	end


endmodule
