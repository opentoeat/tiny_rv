`timescale 1ns / 1ps

module IF(
input           clk,
input           rst_n,
input [31:0]    pc_ID,
input [31:0]    ALU_out,        //当J型指令的时候就取ALU_out
input [31:0]    imm_out,        //当B型指令的时候就取imm_out
input           branch_sel,      //选择J型还是B型
input           stop_IF,
input           PCsel,          //选择地址信号，由控制模块产生
//input [31:0]    PC,             //输入的地址
output  [31:0]  Instruction,    //从rom中输出的指令
output  [31:0]  PC4,             //pc加4输出
output  [31:0]  pc_out
    );

wire [31:0] branch_pc;      //分支地址
//wire [31:0] current_pc;     //当前地址
wire [31:0] npc;            //下一个地址next_pc 
wire [31:0] pc;             //传入rom中的地址


//assign current_pc   = PC;
assign branch_pc    = branch_sel ? ALU_out : (pc_ID+imm_out);
//assign branch_pc    = pc_ID+imm_out;
assign pc_out       = pc;

NPC IF_NPC(         //这个是组合逻辑
.current_pc(pc),
.branch_pc(branch_pc),
.PCSel(PCsel),
.stop_IF(stop_IF),
.npc(npc), 
.pc4(PC4)
);

PC IF_PC(           //这个是时序逻辑
.clk(clk),
.rst_n(rst_n),
.npc(npc),
.pc(pc)
);

//Instruction_Rom Instruction_Rom (   //存指令的地方
//  .clka(clk),    // input wire clka
//  .wea(1'b0),      // input wire [0 : 0] wea
//  .addra(pc[13:2]),  // input wire [11 : 0] addra
//  .dina(32'd0),    // input wire [31 : 0] dina
//  .douta(Instruction)  // output wire [31 : 0] douta
//);
IROM Instruction_Rom (
  .a(pc[13:2]),      // input wire [11 : 0] a
  .spo(Instruction)  // output wire [31 : 0] spo
);
endmodule
