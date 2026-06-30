`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/29 18:14:11
// Design Name: 
// Module Name: EX
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


module EX(
input   [31:0]          MUXA_out,
input   [31:0]          MUXB_out,
input   [4:0]           ALUop,      //控制模块传入的
//input                   Unsigned,   //有无符号数标志

output  [31:0]          ALUout,     //得到的输出
output                  negative,   //是否为负数
output                  zero        //是否为零
    );

ALU ALU(
// input                   .clk        (),        //系统所给时钟信号
// input                   .rst_n      (),      //复位信号
//输入
.MUXA_out   (MUXA_out),     //这两个是ID模块传进来的，每条指令只进行一次运算吧
.MUXB_out   (MUXB_out),
.ALUop      (ALUop),      //控制模块传入的控制信号
//.Unsigned   (Unsigned),             //这个也是控制模块传入的
//输出
.ALUout     (ALUout),      //计算得到的数据
.zero       (zero), //零位输出
.negative   (negative)
    );


endmodule
