`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:12:57 08/21/2015
// Design Name:   UARTfsm
// Module Name:   C:/Users/Jeffrey/Google Drive/FPGA/FPGA_UARTRX_test/tb_UARTFSM.v
// Project Name:  FPGA_UARTRX_test
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: UARTfsm
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_UARTFSM;

	// Inputs
	reg sysclk;
	reg reset;
	reg dataAvailable;
	reg [7:0] uart_datain;

	// Outputs
	wire tx_fifo_write;
	wire [7:0] dbus_reg;
	wire [7:0] dbus_data_out;
	wire [7:0] dbus_data_in;
	wire dbus_w;
	wire dbus_r;

	// Instantiate the Unit Under Test (UUT)
	UARTfsm uut (
		.sysclk(sysclk), 
		.reset(reset), 
		.tx_fifo_write(tx_fifo_write), 
		.dataAvailable(dataAvailable), 
		.uart_datain(uart_datain), 
		.dbus_reg(dbus_reg), 
		.dbus_data_out(dbus_data_out), 
		.dbus_w(dbus_w), 
		.dbus_r(dbus_r),
		.dbus_data_in(dbus_data_in)
	);
	
	DPREG ramDUT(.sysclk(sysclk),.reset(reset),.uart_dbus_in(dbus_data_out),.uart_dbus_out(dbus_data_in),.uart_reg(dbus_reg),.uart_dbus_w(dbus_w),.uart_dbus_r(dbus_r)
    );

	always
		#5 sysclk =!sysclk;
	initial begin
		// Initialize Inputs
		sysclk = 0;
		reset = 0;
		dataAvailable = 0;
		uart_datain = 0;

		// Wait 100 ns for global reset to finish
      reset = 1; 
		#10;
		reset = 0; 
		
		#100 //command
		uart_datain=1; 
		dataAvailable = 1;
		#10;
		dataAvailable = 0;
		
		#100 //register
		uart_datain=1;
		dataAvailable = 1;
		#10;
		dataAvailable = 0;

		#100 //count
		uart_datain=3;
		dataAvailable = 1;
		#10;
		dataAvailable = 0;
		
		#100 //data0
		uart_datain=1;
		dataAvailable = 1;
		#10;
		dataAvailable = 0;
		
		#100 //data1
		uart_datain=2;
		dataAvailable = 1;
		#10;
		dataAvailable = 0;
	
		#50 //data2
		uart_datain=3;
		dataAvailable = 1;
		#10;
		dataAvailable = 0;
		
		#500;
		
		#100 //command
		uart_datain=2; //write
		dataAvailable = 1;
		#10;
		dataAvailable = 0;
		
		#100 //register
		uart_datain=0;
		dataAvailable = 1;
		#10;
		dataAvailable = 0;

		#100 //count
		uart_datain=4;
		dataAvailable = 1;
		#10;
		dataAvailable = 0;
		
		
		#100;
		
		$finish;
		
	end
      
endmodule

