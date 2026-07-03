`timescale 1ns / 1ps

// 冒险/停顿控制
// freeze 来源：① load 进 MEM 时冻结 1 拍（BRAM 读延迟）② 除法器 busy 时冻结多拍
module EXCEPTION_CTRL(
input               clk,
input               rst_n,
input               Load_use_risk,      //保留（freeze 已覆盖）
input               isRiskCtrl,         //控制冒险（IF_ID 直接 flush）
input               load_in_MEM,        //load 处于 MEM（BRAM 读延迟）
input               div_busy,           //多周期除法器运行中

output              stop_ID,            //ID_EX bubble（freeze 下不用）
output              stop_IF,            //IF_ID hold
output              stop_MEM,           //EX_MEM hold
output              hold_EX             //ID_EX hold
    );

reg stalled;
wire mem_stall = load_in_MEM & ~stalled;     //每个 load 只冻一拍
wire freeze    = mem_stall | div_busy;       //load 1拍 / 除法多拍

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)        stalled <= 1'b0;
    else if(mem_stall) stalled <= 1'b1;
    else               stalled <= 1'b0;
end

assign stop_MEM = freeze;
assign hold_EX  = freeze;
assign stop_IF  = freeze;
assign stop_ID  = 1'b0;

endmodule
