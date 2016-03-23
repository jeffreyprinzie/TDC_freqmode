//////////////////////////////////////////////////////////////////////
////                                                              ////
//// registerInterface.v                                          ////
////                                                              ////
//// This file is part of the i2cSlave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
//// You will need to modify this file to implement your 
//// interface.
//// Add your control and status bytes/bits to module inputs and outputs,
//// and also to the I2C read and write process blocks  
////                                                              ////
//// To Do:                                                       ////
//// 
////                                                              ////
//// Author(s):                                                   ////
//// - Steve Fielding, sfielding@base2designs.com                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 Steve Fielding and OPENCORES.ORG          ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
`include "i2c/i2cSlave_define.v" 


module registerInterface (
  clk,
  addr,
  dataIn,
  writeEn,
  dataOut,
  myReg1,
  myReg2,
  myReg3,
  myReg4,
  myReg5,
  myReg6,
  myReg7,
  myReg8,
  myReg9,
  myReg10,
  myReg11,
  myReg12,
  myReg13

);
input clk;
input [7:0] addr;
input [7:0] dataIn;
input writeEn;
output reg [7:0] dataOut;


output reg [7:0] myReg1; //config
output reg [7:0] myReg2;
output reg [7:0] myReg3;
output reg [7:0] myReg4;
output reg [7:0] myReg5;
output reg [7:0] myReg6;
output reg [7:0] myReg7;
output reg [7:0] myReg8;
output reg [7:0] myReg9;
output reg [7:0] myReg10;
output reg [7:0] myReg11;
output reg [7:0] myReg12;
output reg [7:0] myReg13;



// --- I2C Read
always @(addr) begin
  case (addr)
	
    8'h00: dataOut <= 8'h66;  
    8'h01: dataOut <= myReg1;  
    8'h02: dataOut <= myReg2;  
    8'h03: dataOut <= myReg3;  
    8'h04: dataOut <= myReg4;  
    8'h05: dataOut <= myReg5;  
    8'h06: dataOut <= myReg6;  
    8'h07: dataOut <= myReg7;  
    8'h08: dataOut <= myReg8;  
    8'h09: dataOut <= myReg9;  
    8'h0A: dataOut <= myReg10;  
    8'h0B: dataOut <= myReg11;  
    8'h0C: dataOut <= myReg12;  
    8'h0D: dataOut <= myReg13;  
    default: dataOut <= 8'h00;
  endcase
end

// --- I2C Write
always @(posedge clk) begin
  if (writeEn == 1'b1) begin
    case (addr)
      8'h01: myReg1 <= dataIn;
      8'h02: myReg2 <= dataIn;
      8'h03: myReg3 <= dataIn;
		8'h04: myReg4 <= dataIn;
      8'h05: myReg5 <= dataIn;
      8'h06: myReg6 <= dataIn;
		8'h07: myReg7 <= dataIn;
      8'h08: myReg8 <= dataIn;
      8'h09: myReg9 <= dataIn;
		8'h0A: myReg10 <= dataIn;
      8'h0B: myReg11 <= dataIn;
      8'h0C: myReg12 <= dataIn;
		8'h0D: myReg13 <= dataIn;
    endcase
  end
end

endmodule


 
