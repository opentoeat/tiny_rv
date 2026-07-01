`timescale 1ns / 1ps

// 冒险/停顿控制
// BRAM 读延迟：load 进 MEM 时冻结整条流水线 1 拍（IF_ID/ID_EX/EX_MEM 全 hold）
// 用 stalled 标志保证每个 load 只冻一拍；freeze 期间下条指令停在 EX，
// 下一拍 BRAM 数据就绪、MEM 前递对齐。
module EXCEPTION_CTRL(
input               clk,
input               rst_n,
input               Load_use_risk,      //保留（BRAM 下由 freeze 覆盖，不再用于 stall）
input               isRiskCtrl,         //控制冒险（由 IF_ID 的 isRiskCtrl 直接 flush）
input               load_in_MEM,        //load 处于 MEM 阶段（BRAM 读延迟）

output              stop_ID,            //ID_EX bubble（freeze 下不用）
output              stop_IF,            //IF_ID hold
output              stop_MEM,           //EX_MEM hold
output              hold_EX             //ID_EX hold（freeze 用，优先于 stop_ID）
    );

reg stalled;
wire mem_stall = load_in_MEM & ~stalled;     //每个 load 只冻一拍

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        stalled <= 1'b0;
    else if(mem_stall)
        stalled <= 1'b1;
    else
        stalled <= 1'b0;
end

//freeze：冻结 IF_ID(hold)/ID_EX(hold)/EX_MEM(hold)，不 bubble
assign stop_MEM = mem_stall;
assign hold_EX  = mem_stall;
assign stop_IF  = mem_stall;
assign stop_ID  = 1'b0;

endmodule
