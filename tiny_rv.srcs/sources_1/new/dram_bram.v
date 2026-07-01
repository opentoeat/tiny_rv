`timescale 1ns/1ps
// DRAM_MEM: 简单双口 BRAM（寄存器读），替代原 dist_mem_gen IP
// 读口 dpo 为寄存器输出（地址当拍给入，数据下一拍出）→ 需 CPU load stall 配合
// 预载内容来自 dram_init.mem（由 dram_init.coe 转换）
module DRAM_MEM(
    input        [12:0] a,        // 写地址
    input        [31:0] d,        // 写数据
    input        [12:0] dpra,     // 读地址
    input               clk,
    input               we,
    output reg   [31:0] dpo       // 寄存器读输出
);
    reg [31:0] mem [0:8191];

    initial begin
        $readmemh("dram_init.mem", mem);
    end

    always @(posedge clk) begin
        if (we) mem[a] <= d;
        dpo <= mem[dpra];     // 寄存器读：推断为 Block RAM
    end
endmodule
