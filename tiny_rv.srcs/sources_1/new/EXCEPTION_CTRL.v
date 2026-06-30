`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/25 23:29:09
// Design Name: 
// Module Name: EXCEPTION_CTRL
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


module EXCEPTION_CTRL(
input              Load_use_risk,      //load-use冒险
input              isRiskCtrl,         //控制冒险

output              stop_ID,            //ID
output              stop_IF
    );

//IF停顿即指令不变，当loaduse冒险时可用；当控制冒险时由于需要接收新的分支PC，故不成立
assign stop_IF = Load_use_risk;
//ID停顿即令译码内容不变，当load-use型冒险和控制冒险都适用，需要清空当前周期存入的所有信息
assign stop_ID = Load_use_risk;

endmodule
