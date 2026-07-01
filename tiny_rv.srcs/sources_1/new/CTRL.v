`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/23 18:13:56
// Design Name: 
// Module Name: CTRL
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
`include "param.v"

module CTRL(
input   [31:0]      Instruction,
input   [31:0]      MUXA_out,
input   [31:0]      MUXB_out,           //从ID中传入

output wire          PCSel,          //地址选择信号                   未完成
output reg [2:0]    sextope,        //立即数扩展状态                 完成
output reg          regwe,          //控制是否写回寄存器             完成
output reg          Asel,           //pc和rd1的二选一控制信号        完成
output reg          Bsel,           //rd2和立即数的二选一控制信号    完成
output reg [4:0]    ALUop,          //计算模块的控制信号             完成
output reg          DRAMWE,         //dram的写使能                   完成
output reg [1:0]    rwsel,           //写回选择信号                   完成
output reg          branch_sel,       //控制写回ALU_out还是IMM_out    完成
output              u,
output  wire        TYPE_LOAD
    );


 

wire                r, i, s, b, j    ;          //几种不同指令的
wire    [6:0]       opecode             ;
wire    [14:12]     funct3              ;
wire    [31:25]     funct7              ;
reg     [5: 0]      type_reg            ;

assign opecode      = Instruction[6:0]  ;
assign funct3       = Instruction[14:12];
assign funct7       = Instruction[31:25];


assign TYPE_LOAD   = (opecode[6: 2] == 5'b00000) ? 1'b1 : 1'b0;
assign {r, i, s, b, u, j} = type_reg[5: 0];

//pcsel 地址选择标志
//assign PCSel = ((ALUop == `BNE)&&(~zero))||((ALUop == `BEQ)&&(zero))||((ALUop == `BGE)&&(negative))||((ALUop == `JAL)) ? 1'b1 : 1'b0;
// assign PCSel = ( ( (ALUop == `BNE) && (~zero)   ) ||
//                 ( (ALUop == `BEQ) && (zero)     ) ||
//                 ( (ALUop == `BGE) && (~negative)) ||  // ~negative
//                 (ALUop == `JAL) 
//               ) ? 1'b1 : 1'b0; 
//四条跳转指令，当pcsel拉高的时候选择分支地址
//pcsel
// always@(*)begin
//     if(u)begin
//         PCSel = 1'b0;
//     end
//     else if(b)begin
//         casez (funct3)
//             3'b000: PCSel = ~zero ? 1'b1 : 1'b0;
//             3'b001:PCSel = zero ? 1'b1 : 1'b0;
//             3'b1?1:PCSel = ~negative ? 1'b1 : 1'b0;
//             default:PCSel = 1'b0; 
//         endcase
//     end
//     else if(j)begin
//         PCSel = 1'b1;
//     end
//     else begin
//         PCSel = 1'b0;
//     end
// end


reg     PCSel_r;
assign PCSel = PCSel_r;


always @ (*) begin
     if (b) begin
         casez (funct3)
             3'b000: begin // beq
                 PCSel_r = (MUXA_out == MUXB_out) ? 1'b1 : 1'b0;
             end
             3'b001: begin // bne
                 PCSel_r = (MUXA_out != MUXB_out) ? 1'b1 : 1'b0;
             end
             3'b100: begin // blt 有符号 <
                 PCSel_r = ($signed(MUXA_out) < $signed(MUXB_out)) ? 1'b1 : 1'b0;
             end
             3'b110: begin // bltu 无符号 <
                 PCSel_r = (MUXA_out < MUXB_out) ? 1'b1 : 1'b0;
             end
             3'b1?1: begin // bge / bgeu
                 PCSel_r = (MUXA_out > MUXB_out) ? 1'b1 : 1'b0;
             end
             default: begin
                 PCSel_r = 1'b0;
             end
         endcase
     end
     else if (j||(i && (opecode[6:2] == 5'b11001))) begin // jalr / jal
         PCSel_r = 1'b1;
     end
     else begin
         PCSel_r = 1'b0;
     end
 end
 
//branch_sel jalr跳转立即数加寄存器值  jal和b型指令跳转 立即数加当前地址
always @(*) begin   //除了j以外全是IMM_OUT因为B型指令更多
    if(i && (opecode[6:2] == 5'b11001))begin
        branch_sel <= 1'b1;
    end
    else begin
        branch_sel <= 1'b0;
    end
end

//rwsel 写回选择
always @(*) begin
    if(opecode[6:2] == 5'b00000)begin
        rwsel = `WB_DRAM_Rd;
    end
    else if(j)begin
        rwsel = `WB_PC4;
    end
    else if(r||i)begin
        rwsel = `WB_ALU_out;
    end
    else if(u)begin
        if(opecode == 7'b0010111) rwsel = `WB_ALU_out;  // AUIPC: 写回 PC+imm
        else                       rwsel = `WB_IMM_OUT;  // LUI: 写回 imm
    end
    else begin
        rwsel = `WB_ALU_out;   //默认值，消除 latch（store/branch 无写回，由 regwe 屏蔽）
    end
end

//ALUop
always @(*) begin
    ALUop = `ADD;   //默认值，消除 latch（未覆盖的编码回落到 ADD）
    if(r)begin
        if({funct7[30],funct7[25],funct3} == 5'b00000)begin
            ALUop = `ADD;
        end
        else if({funct7[30],funct7[25],funct3} == 5'b00111)begin
            ALUop = `AND;
        end
        else if({funct7[30],funct7[25],funct3} == 5'b00110)begin
            ALUop = `OR;
        end
        else if({funct7[30],funct7[25],funct3} == 5'b10000)begin
            ALUop = `SUB;
        end
        else if({funct7[30],funct7[25],funct3} == 5'b00010)begin
            ALUop = `SLT;
        end
        else if({funct7[30],funct7[25],funct3} == 5'b00011)begin
            ALUop = `SLTU;
        end
        else if({funct7[30],funct7[25],funct3} == 5'b00100)begin
            ALUop = `XOR;
        end
        else if({funct7[30],funct7[25],funct3} == 5'b00101)begin
            ALUop = `SRL;
        end
        else if({funct7[30],funct7[25],funct3} == 5'b10101)begin
            ALUop = `SRA;
        end
        else if({funct7[30],funct7[25],funct3} == 5'b00001)begin
            ALUop = `SLL;
        end
    end
    else if(i && (opecode[6:2] == 5'b00000))begin
        ALUop = `LW;
    end
    else if(i && (opecode[6:2] == 5'b11001))begin
        ALUop = `JALR;
    end//操作码
    else if(i)begin
        if(funct3 == 3'b000)begin
            ALUop = `ADDI;
        end
        else if(funct3 == 3'b111)begin
            ALUop = `ANDI;
        end
        else if(funct3 == 3'b110)begin
            ALUop = `ORI;
        end
        else if(funct3 == 3'b010)begin
            ALUop = `SLTI;
        end
        else if(funct3 == 3'b100)begin
            ALUop = `XORI;
        end
        else if(funct3 == 3'b001)begin
            ALUop = `SLLI;
        end
        else if(funct3 == 3'b101)begin
            ALUop = funct7[30] ? `SRA : `SRL;   // SRAI : SRLI
        end
    end
    else if(s) begin
        if(funct3 == 3'b010)begin
            ALUop = `SW;
        end
    end
    else if(b)begin
        if(funct3 == 3'b000)begin
            ALUop = `BEQ;
        end
        else if(funct3 == 3'b001)begin
            ALUop = `BNE;
        end
        else if(funct3 == 3'b101)begin
            ALUop = `BGE;
        end
    end
    else if(u)begin
        if(opecode == 7'b0110111)begin
            ALUop = `LUI;
        end
        else if(opecode == 7'b0010111)begin
            ALUop = `ADD;   // AUIPC: PC + imm
        end
    end
    else if(j)begin
        ALUop = `JAL;
    end
end

always @ (*) begin
     case (opecode[6:2])
         5'b01100: begin
             type_reg = 6'b100000; // R 型
         end
         5'b01101: begin
             type_reg = 6'b000010; // U 型      //lui
         end
         5'b00101: begin
             type_reg = 6'b000010; // U 型      //auipc指令，现在先别加
         end
         5'b11011: begin
             type_reg = 6'b000001; // J 型
         end
         5'b01000: begin
             type_reg = 6'b001000; // S 型
         end
         5'b11000: begin
             type_reg = 6'b000100; // B 型
         end
         default: begin
             type_reg = 6'b010000; // I 型
         end
     endcase
 end

//sextope立即数扩展模块，
always@(*)begin
    if(i)begin
        sextope = `I_type_imm;
    end
    else if(s)begin
        sextope = `S_type_imm;
    end
    else if(b)begin
        sextope = `SB_type_imm;
    end
    else if(u)begin
        sextope = `U_type_imm;
    end
    else if(j)begin
        sextope = `J_type_imm;
    end
    else begin
        sextope = 3'd0;
    end
end

//DRAMWE
always @(*) begin
    if(s)begin
        DRAMWE = 1'b1;
    end
    else begin
        DRAMWE = 1'b0;
    end
end

//regwe,寄存器写回标志
always @(*) begin
    if(r||i||s||u||j)begin      //这几种类型写回寄存器，其余不写回
        regwe = 1'b1;
    end
    else begin
        regwe = 1'b0;
    end
end

//Asel,应该反过来
always @(*) begin
    if(j || (opecode == 7'b0010111))begin
        Asel = 1'b1;   //选择pc：JAL 或 AUIPC
    end
    else begin
        Asel = 1'b0;   //选择rd1，`Asel_Rd1
    end
end

//Bsel
always @(*) begin               //jump and link 无条件跳转，需要计算的东西是立即数
    if(i||s||u||j)begin        //需要用立即数的全是0，除了b型指令中立即数被当作分支指令
        Bsel = 1'b0;
    end
    else begin
        Bsel = 1'b1;
    end
end

endmodule
