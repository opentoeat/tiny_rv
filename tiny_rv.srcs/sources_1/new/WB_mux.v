//`timescale 1ns / 1ps
`include "param.v"

module WB_mux(
input       [31:0]  DRAMRd,
input       [31:0]  pc4,
input       [31:0]  ALU_out,
input       [31:0]  imm_out,
input       [1:0]   rwsel,
output   reg   [31:0]  out
);

always @(*) begin
    case (rwsel)
        `WB_ALU_out: out = ALU_out;
        `WB_DRAM_Rd: out = DRAMRd;
        `WB_PC4: out = pc4; 
        `WB_IMM_OUT:out = imm_out;
        default: out = 32'd0;
    endcase
end

endmodule 

