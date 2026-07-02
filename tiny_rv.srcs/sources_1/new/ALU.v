`timescale 1ns / 1ps
`include "param.v"

module ALU(
input       [31:0]  MUXA_out,
input       [31:0]  MUXB_out,
input       [4:0]   ALUop,      //控制指令的信号  我能不能自创

output reg  [31:0]  ALUout ,     //计算得到的数据
output              zero,        //零位输出
output              negative
    );

wire    [31:0]  ALU_ADD;
wire    [31:0]  ALU_SUB;
wire    [31:0]  ALU_SLL;
wire    [31:0]  ALU_SLT;
wire    [31:0]  ALU_SLTU;
wire    [31:0]  ALU_XOR;
wire    [31:0]  ALU_SRL;
wire    [31:0]  ALU_SRA;
wire    [31:0]  ALU_OR;
wire    [31:0]  ALU_AND;

//其实可以复用加法器来计算减法，但是没必要，不改了
assign ALU_ADD = $signed(MUXA_out) + $signed(MUXB_out);
assign ALU_SUB = $signed(MUXA_out) - $signed(MUXB_out);
assign ALU_SLL = MUXA_out << MUXB_out[4:0];
assign ALU_SLT = $signed(MUXA_out) < $signed(MUXB_out);
assign ALU_SLTU = MUXA_out < MUXB_out;     // 无符号比较（修复：原误截断 B 到 [4:0]）
assign ALU_XOR = MUXA_out ^ MUXB_out;
assign ALU_SRL = MUXA_out >> MUXB_out[4:0];
assign ALU_SRA =$signed(MUXA_out) >>> MUXB_out[4:0];
assign ALU_OR  = MUXA_out | MUXB_out;
assign ALU_AND = MUXA_out & MUXB_out;

// assign overflow = (ALUop[3:0]  == `ADD) ? (~A[31]&B[31]&C[31])|(A[31]&(~B[31])&(~C[31])) : ((~A[31]&~A[31]&C[31])|(A[31]&B[31]&~C[31]));//(~ALU_control[4]^A[31]^B[31])&(A[31]^(ALU_control[4] ? ALU_SUB : ALU_ADD)&(~ALU_control[4])) : 1'b0;
// //只有在加减运算的时候才会溢出
// assign carry    = (ALUop[3:0]  == `ADD) ? ALU_SUB[31] : ALU_ADD[31] : 1'b0 ;//(ALU_control[2:0]  == 3'b000) ? (ALU_control[3] ? ALU_SUB[31] : ALU_ADD[31]) : 1'b0 ;        //
 assign negative     = ALUout[31] ;       //负数
 assign zero         = &(~ALUout) ;       //按位与
//assign ALU_flag ={overflow,carry,negative,zero};

//lw需要单独的计算通路吗？

always @(*) begin
    case(ALUop)
    //Rtype
        `ADD :ALUout = ALU_ADD;
        `SUB :ALUout = ALU_SUB;
        `SLL :ALUout = ALU_SLL;
        `SLT :ALUout = ALU_SLT;
        `SLTU:ALUout = ALU_SLTU;
        `XOR :ALUout = ALU_XOR;
        `SRL :ALUout = ALU_SRL;
        `SRA :ALUout = ALU_SRA;
        `OR  :ALUout = ALU_OR;
        `AND :ALUout = ALU_AND;
    //Itype
        `ADDI:ALUout = ALU_ADD;
        `ANDI:ALUout = ALU_AND;
        `ORI:ALUout = ALU_OR;
        `SLTI:ALUout = ALU_SLT;
        `XORI:ALUout = ALU_XOR;
        `SUBI:ALUout = ALU_SUB;
        `LW:ALUout = ALU_ADD;           //偏置立即数与寄存器中的值相加
        `SLLI:ALUout = ALU_SLL;
        `JALR:ALUout = ALU_ADD;
    //Stype
        `SW:ALUout = ALU_ADD;           //同LW
    //Btype
        `BEQ:ALUout = ALU_SUB;
        `BNE:ALUout = ALU_SUB;
        `BGE:ALUout = ALU_SUB;          //三个跳转指令都需要将，两个寄存器的值进行相减，然后根据negative和zero进行判断
    //Utype
        `LUI:ALUout = 32'd0;
    //J型指令
        `JAL:ALUout = ALU_ADD;
        default:ALUout = 32'd0;
    endcase
end

endmodule
