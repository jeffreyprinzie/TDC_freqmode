`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:21:27 03/21/2016 
// Design Name: 
// Module Name:    hierWrapper 
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


module hierWrapper(
    output hitskip
    );

wire hitskip;

assign hitskip= top.slaves.TDCchannels.enableHitskip;

endmodule
