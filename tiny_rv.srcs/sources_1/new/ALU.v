`timescale 1ns / 1ps
`include "param.v"

module ALU(
input       [31:0]  MUXA_out,
input       [31:0]  MUXB_out,
input       [4:0]   ALUop,      //控制指令的信号
input       [2:0]   M_op,       //M 扩展子操作（=funct3）
input               clk,        //多周期除法器时钟
input               rst_n,
output              div_busy,   //除法器忙（CPU stall 用）

output reg  [31:0]  ALUout,
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

assign ALU_ADD  = $signed(MUXA_out) + $signed(MUXB_out);
assign ALU_SUB  = $signed(MUXA_out) - $signed(MUXB_out);
assign ALU_SLL  = MUXA_out << MUXB_out[4:0];
assign ALU_SLT  = $signed(MUXA_out) < $signed(MUXB_out);
assign ALU_SLTU = MUXA_out < MUXB_out;          // 无符号比较（全32位）
assign ALU_XOR  = MUXA_out ^ MUXB_out;
assign ALU_SRL  = MUXA_out >> MUXB_out[4:0];
assign ALU_SRA  = $signed(MUXA_out) >>> MUXB_out[4:0];
assign ALU_OR   = MUXA_out | MUXB_out;
assign ALU_AND  = MUXA_out & MUXB_out;

// ===== M 扩展：乘法（DSP 单周期）=====
wire signed [63:0] MUL_SS = $signed(MUXA_out) * $signed(MUXB_out);  // 有符号×有符号
wire        [63:0] MUL_UU = MUXA_out * MUXB_out;                     // 无符号×无符号
wire signed [63:0] MUL_SU = $signed(MUXA_out) * MUXB_out;            // 有符号×无符号 (MULHSU)

// ===== M 扩展：除法（多周期，32 拍）=====
wire        div_is_div = (ALUop==`M_EXT) && M_op[2];   // DIV/DIVU/REM/REMU
wire [31:0] div_result;
div_unit du(
    .clk(clk), .rst_n(rst_n),
    .a(MUXA_out), .b(MUXB_out),
    .start(div_is_div),
    .is_signed(~M_op[0]),   // DIV=100/DIVU=101 → [0]=0/1
    .is_rem(M_op[1]),       // REM=110/REMU=111 → [1]=1
    .result(div_result),
    .busy(div_busy)
);

assign negative = ALUout[31];
assign zero     = &(~ALUout);

always @(*) begin
    case(ALUop)
    //Rtype
        `ADD : ALUout = ALU_ADD;
        `SUB : ALUout = ALU_SUB;
        `SLL : ALUout = ALU_SLL;
        `SLT : ALUout = ALU_SLT;
        `SLTU: ALUout = ALU_SLTU;
        `XOR : ALUout = ALU_XOR;
        `SRL : ALUout = ALU_SRL;
        `SRA : ALUout = ALU_SRA;
        `OR  : ALUout = ALU_OR;
        `AND : ALUout = ALU_AND;
    //Itype
        `ADDI: ALUout = ALU_ADD;
        `ANDI: ALUout = ALU_AND;
        `ORI : ALUout = ALU_OR;
        `SLTI: ALUout = ALU_SLT;
        `XORI: ALUout = ALU_XOR;
        `SUBI: ALUout = ALU_SUB;
        `LW  : ALUout = ALU_ADD;
        `SLLI: ALUout = ALU_SLL;
        `JALR: ALUout = ALU_ADD;
    //Stype
        `SW  : ALUout = ALU_ADD;
    //Btype
        `BEQ : ALUout = ALU_SUB;
        `BNE : ALUout = ALU_SUB;
        `BGE : ALUout = ALU_SUB;
    //Utype
        `LUI : ALUout = 32'd0;
    //J型指令
        `JAL : ALUout = ALU_ADD;
    //M扩展
        `M_EXT: begin
            case(M_op)
                3'b000: ALUout = MUL_SS[31:0];   // MUL
                3'b001: ALUout = MUL_SS[63:32];  // MULH
                3'b010: ALUout = MUL_SU[63:32];  // MULHSU
                3'b011: ALUout = MUL_UU[63:32];  // MULHU
                default: ALUout = div_result;    // DIV/DIVU/REM/REMU（多周期）
            endcase
        end
        default: ALUout = 32'd0;
    endcase
end

endmodule
