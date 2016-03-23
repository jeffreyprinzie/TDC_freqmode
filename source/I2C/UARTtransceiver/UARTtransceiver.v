`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:57:06 08/20/2015 
// Design Name: 
// Module Name:    UARTtransceiver 
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
module UARTtransceiver(sysclk,rx,tx,dbus_data_out,dbus_data_in,dbus_reg,dbus_w);
input sysclk,rx;
output tx;
wire [7:0] RxD_data;
wire [7:0] tx_fifo_data;
wire [7:0] TxD_data;
output wire [7:0] dbus_data_out;
input wire [7:0] dbus_data_in;
output wire [7:0] dbus_reg;
output wire dbus_w;


//POR
wire txstart;

POR UPOR(sysclk,reset);
wire baud16;
baudgenerator UBGEN(sysclk,reset,baud16);
UARTrx URX(reset,sysclk,baud16,rx,RxD_data,RxRdy);
UARTtx UTX(reset,sysclk,baud16,tx,TxD_data,txstart,txbusy);



wire rx_fifo_full,rx_fifo_empty,tx_fifo_full,tx_fifo_empty;


txfifo UTXfifo(
  sysclk,
  reset,
  tx_fifo_data, //fifo input
  tx_fifo_write, //write into fifo
  txstart, //read from fifo
  TxD_data, //fifo output
  tx_fifo_full,
  tx_fifo_empty
);

assign txstart = (txbusy==0 && tx_fifo_empty==0) ? 1 : 0;  //send serial data if the fifo is not empty

	

	wire dbus_r;

	// Instantiate the Unit Under Test (UUT)
	UARTfsm U_UARTFSM (
		.sysclk(sysclk), 
		.reset(reset), 
		.baud16(baud16),
		.tx_fifo_write(tx_fifo_write), 
		.tx_fifo_data(tx_fifo_data),
		.dataAvailable(RxRdy), 
		.uart_datain(RxD_data), 
		.dbus_reg(dbus_reg), 
		.dbus_data_out(dbus_data_out), 
		.dbus_w(dbus_w), 
		.dbus_r(dbus_r),
		.dbus_data_in(dbus_data_in)
	);
	






endmodule
