`timescale 1ns / 1ps
`include "param.v"

module bus_top(
    input                       clk,            //时序化用：驱动显存写寄存器
    input                       rst_n,
    input                       we,
    input      [32 - 1 : 0]     addr,
    input      [32 - 1 : 0]     wdata,          //写数据
    input      [32 - 1 : 0]     in_data,
    output reg [32 - 1 : 0]     rdata,          //读数据
//设备线
    output reg [5 - 1 : 0]      ctrl,
    //DRAM内存（读/写均组合，CPU 的 load 依赖当拍返回 rdata）
    output reg  [12:0]          ram_addr,
    output reg  [31:0]          ram_data,
    //VGA显存接口（写路径已时序化，打一拍）
    output reg                  vga_data,
    output reg  [18:0]          vga_addr,
    output reg                  vga_we,         //显存写使能（寄存后）
    //按键接口
    input       [3:0]           key_state
);

// =====================================================================
// 组合部分：DRAM 读/写 + 按键读
// 必须当拍完成（CPU load 依赖当拍 rdata）。要时序化读路径，需在 CPU 侧
// 加 load stall（ready 握手），属后续工程。
// 默认值已补全，消除组合 always 中的 latch。
// =====================================================================
always @(*) begin
    rdata    = 32'd0;
    ctrl     = 5'b00000;
    ram_addr = addr[14:2];
    ram_data = wdata;
    if(we) begin
        //0x0_* 与 default 写 DRAM；0x1_* 显存写在时序块处理；0x2_* 按键只读
        if(addr[31:28] == 4'h0 || (addr[31:28] != 4'h1 && addr[31:28] != 4'h2)) begin
            ctrl = 5'b00001;       //DRAM 写使能
        end
    end
    else begin
        if(addr[31:28] == 4'h2) begin
            rdata = {28'd0, key_state};
            ctrl  = 5'b00100;
        end
        else begin                 //读控制
            rdata = in_data;       //DRAM 读
            ctrl  = 5'b10000;
        end
    end
end

// =====================================================================
// 时序部分：显存写路径寄存化
// 写显存 CPU 不读回，打一拍不影响功能，且把 vga_data/vga_addr/vga_we
// 从组合长链中切断。
// =====================================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        vga_data <= 1'b0;
        vga_addr <= 19'd0;
        vga_we   <= 1'b0;
    end
    else begin
        vga_we   <= (we && (addr[31:28] == 4'h1));   //下一拍生效，与数据同步
        vga_data <= wdata[0];
        vga_addr <= addr[20:2];
    end
end

endmodule
