`define I_type_imm      3'b000
`define S_type_imm      3'b001
`define SB_type_imm      3'b010
`define U_type_imm      3'b011
`define J_type_imm      3'b100

//写回控制信号
`define WB_ALU_out      2'b00
`define WB_DRAM_Rd      2'b01
`define WB_PC4          2'b10
`define WB_IMM_OUT      2'b11

//共计24条指令
//ALU Rtype类型
`define ADD     5'b00000
`define SUB     5'b00001
`define SLL     5'b00010
`define SLT     5'b00011
`define SLTU    5'b00100
`define XOR     5'b00101
`define SRL     5'b00110
`define SRA     5'b00111
`define OR      5'b01000
`define AND     5'b01001
//Itype类型0
`define ADDI    5'b01010
`define ANDI    5'b01011
`define ORI     5'b01100
`define SLTI    5'b01101
`define XORI    5'b01110
`define SUBI    5'b01111
`define LW      5'b10000
`define SLLI    5'b10111
`define JALR    5'b11000
//Stype指令
`define SW      5'b10001
//B型指令
`define BEQ     5'b10010
`define BNE     5'b10011
`define BGE     5'b10100    //有符号大于跳转
//U型指令
`define LUI     5'b10101    //加载长立即数
//J型指令
`define JAL     5'b10110    //jump and link
`define M_EXT    5'b11001    //M扩展（MUL/MULH/MULHSU/MULHU/DIV/DIVU/REM/REMU，由 M_op=funct3 区分）

//总线信号
`define IO_BUSWIDTH_ADDR 32
`define IO_BUSWIDTH_CTRL 4
`define IO_BUSWIDTH_DATA 32
`define IO_INTERFACE_NUM 2

//前递信号
`define ASEL_FORWARDING 1'b1
`define BSEL_FORWARDING 1'b1
