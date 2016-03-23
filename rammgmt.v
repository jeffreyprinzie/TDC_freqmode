`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:09:40 11/16/2015 
// Design Name: 
// Module Name:    rammgmt 
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
module rammgmt(
		dumpMem,
		write_En_datachannel,
		data_datachannel,
		SYSCLK,
		reset,
		dumpdone,
		IPbus_RAM_data,
		IPbus_RAM_address,
		IPbus_RAM_we,
		handshakeFPGA,
		handshakePC
    );
	 
	 input wire dumpMem,write_En_datachannel,SYSCLK,reset,handshakePC;
	 input wire [7:0] data_datachannel ;
	 output wire dumpdone;
	 output wire [31:0] IPbus_RAM_data;
	 output wire [7:0] IPbus_RAM_address;
	 output wire IPbus_RAM_we;
	 output reg handshakeFPGA;
	 
	 reg [1:0] FSMstate,FSMstate_next;
	 
	 localparam IDLE=2'h0;
	 localparam DUMPING=2'h1;
	 localparam DUMPINGTRASH=2'h2;
	 localparam STOPDUMP=2'h3;
	 reg [7:0] ramAddr;
	 
	 assign IPbus_RAM_we = (FSMstate==DUMPING && write_En_datachannel && frameCounter==2'h3 ) ? 1:0;//
	 assign dumpdone = (FSMstate == STOPDUMP ) ? 1:0;
		
	 
	 assign IPbus_RAM_data = {SR[15],SR[14],SR[13],SR[12]};
	 assign IPbus_RAM_address = ramAddr;
	 
	 
	reg [7:0] SR [0:15];
	integer i;
	always @(posedge SYSCLK) begin
		if(write_En_datachannel) begin
			for(i = 15; i > 0; i=i-1) begin
				SR[i] <= SR[i-1];
			end
			SR[0] <= data_datachannel;
		end
	end	
	
	

	
	//handshaking, the PC and FPGA have to be synced for the RAM, otherwise the frame is dropped, however, the same time will be spent in this FSM such that the hit counters will have the correct value
	//  FPGA  PC
	//   0     0   PC and FPGA are sync, so the RAM is ready to write
	//	  1     0   FPGA has written the RAM, no more frames can be written to the RAM, PC can now read
	//	  1     1	PC has read the RAM and updated the SYNC, RAM can again be written
	//	  0     1	FPGA updated the SYC after write, PC now needs to read, no more frames can be written to the RAM
	 
	 always @(FSMstate,FSMstate_next,dumpMem,ramAddr,handshakePC,handshakeFPGA)begin
		case (FSMstate)
			IDLE:
				if(dumpMem)
					if(handshakeFPGA==handshakePC)
						FSMstate_next<=DUMPING; //RAM is free to write
					else
						FSMstate_next<=DUMPINGTRASH; //RAM is not read by the PC, drop this trigger in the trash
				else
					FSMstate_next<=IDLE;
			DUMPING:
				if(ramAddr==8'hff)
					FSMstate_next<=STOPDUMP;
				else
					FSMstate_next<=DUMPING;
			DUMPINGTRASH:
				if(ramAddr==8'hff)
					FSMstate_next<=STOPDUMP;
				else
					FSMstate_next<=DUMPINGTRASH;			
			
			STOPDUMP:
				FSMstate_next<=IDLE;
		
		endcase
	 
	 end
	 
	 reg [1:0] frameCounter;
	 always @(posedge SYSCLK) begin
			if(FSMstate==DUMPING || FSMstate==DUMPINGTRASH) begin
				if(write_En_datachannel)
					frameCounter<=frameCounter+1;
				else
					frameCounter<=frameCounter;
			end else
				frameCounter<=0;	
	 end
	 
	 always @(posedge SYSCLK) begin
			if(FSMstate==DUMPING || FSMstate==DUMPINGTRASH ) begin
				if(write_En_datachannel && frameCounter==2'h3)
					ramAddr<=ramAddr+1;
				else
					ramAddr<=ramAddr;
			end else
				ramAddr<=0;
	 end
	 
	 always @(posedge SYSCLK) begin
		if(reset)
			FSMstate<=IDLE;
		else
			FSMstate<=FSMstate_next;
	 end

	 always @(posedge SYSCLK) begin
		if(reset)
			handshakeFPGA<=0;
		else
			if(FSMstate==DUMPING && FSMstate_next==STOPDUMP)
				handshakeFPGA<=~handshakeFPGA; //update the handshake, new data available, PC should check if the handshake is differnt, read the RAM and update his handshake
			else
				handshakeFPGA<=handshakeFPGA;

	 end

endmodule
