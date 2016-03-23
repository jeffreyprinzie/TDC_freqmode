`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:03:04 08/22/2015
// Design Name:   UARTtransceiver
// Module Name:   C:/Users/Jeffrey/Google Drive/FPGA/FPGA_UARTRX_test/tb_UARTtransceiver.v
// Project Name:  FPGA_UARTRX_test
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: UARTtransceiver
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_UARTtransceiver;
parameter baudTime = 1000000000/9600;
	// Inputs
	reg sysclk;
	reg rx;

	// Outputs
	wire tx;

	// Instantiate the Unit Under Test (UUT)
	UARTtransceiver uut (
		.sysclk(sysclk), 
		.rx(rx), 
		.tx(tx)
	);

	initial begin
		// Initialize Inputs
		sysclk = 1;
		rx = 1;
		#100

		#(10*baudTime)
		sendByte(1);
		//#(10*baudTime)
		sendByte(0);
		//#(10*baudTime)
		sendByte(4);
		//#(10*baudTime)
		sendByte(1);
		//#(10*baudTime)
		sendByte(2);
		//#(10*baudTime)
		sendByte(3);
		//#(10*baudTime)
		sendByte(4);
		//#(10*baudTime)
		
		
		//#(10*baudTime)
		sendByte(2);
		//#(10*baudTime)
		sendByte(0);
		//#(10*baudTime)
		sendByte(4);
		#(100*baudTime)
		
		$finish;
        
		// Add stimulus here

	end
	

always begin
	#5 sysclk=~sysclk;
end

task sendByte;
input [7:0] data;
begin
#baudTime rx=0;
#baudTime rx=data[0];
#baudTime rx=data[1];
#baudTime rx=data[2];
#baudTime rx=data[3];
#baudTime rx=data[4];
#baudTime rx=data[5];
#baudTime rx=data[6];
#baudTime rx=data[7];
#baudTime rx=1;
end
endtask
      
endmodule

