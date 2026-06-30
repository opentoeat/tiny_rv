`timescale 1ns / 1ps

module ID(
input           clk,
input           rst_n,
input   [31:0]  instruction,
input   [31:0]  pc,
input   [2:0]   sextope,        //扩展立即数控制信�?
input   [31:0]  wd,             //写回数据
input           regwe,          //寄存器堆写使�?
input           Asel,           //选择rd1还是pc
input           Bsel,           //选择rd2还是immout
input   [4:0]   wr_i,
input   [31:0]  Forwarding_A,
input   [31:0]  Forwarding_B,
input           MUX_A_forwarding,
input           MUX_B_forwarding,
output  [31:0]  imm_out,        //传出的立即数
output  [31:0]  rd2,            //传出寄存�?2的�?�，传入MEM中作为写入的数据
output  [31:0]  MUXA_out,
//output  [31:0]  MUXA_out_f,
output  [31:0]  MUXB_out,
output  [4:0]   wr_o
//output  [31:0]  MUXB_out_f
    );

wire    [31:7]  imm;
wire    [4:0]   wr; //写入寄存�?
wire    [4:0]   rs1;//读出寄存�?1
wire    [4:0]   rs2;//读出寄存�?2

assign imm      = instruction[31:7];
assign wr_o       = instruction[11:7];
assign rs1      = instruction[19:15];
assign rs2      = instruction[24:20];


wire    [31:0]  rd1;
//wire    [31:0]  rd2;
wire    [31:0]  rd1_i;
wire    [31:0]  rd2_i;

assign rd1 = MUX_A_forwarding ? Forwarding_A : rd1_i;
assign rd2 = MUX_B_forwarding ? Forwarding_B : rd2_i;

Regfile u_Regfile(
.clk(clk),
.rst_n(rst_n),
.wr(wr_i),
.rs1(rs1),
.rs2(rs2),
.wd(wd),         //写回数据，经过alu计算得到�?

.regwe(regwe),      //写使�?        1为有�? 0为无�?

.rd1(rd1_i),
.rd2(rd2_i)
    );



ImmGen ImmGen(
.imm(imm),
.sextope(sextope),
.imm_out(imm_out)
);

assign MUXA_out = Asel ? pc : rd1;
assign MUXB_out = Bsel ? rd2 : imm_out;

endmodule
