`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/07 17:28:25
// Design Name: 
// Module Name: WB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module WB(
input       [1:0]       rwsel,
input       [31:0]      ALU_out,
input       [31:0]      pc4,
input       [31:0]      imm_out,
input       [31:0]      DRAMRd,
output      [31:0]      wd
    );


WB_mux WB_mux(      //逻辑单元
.DRAMRd      (DRAMRd),
.pc4         (pc4),
.ALU_out     (ALU_out),
.imm_out     (imm_out),

.rwsel       (rwsel),  
.out         (wd)
);


endmodule
