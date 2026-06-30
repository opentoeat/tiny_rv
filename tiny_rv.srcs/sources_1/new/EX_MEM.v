`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/24 16:06:02
// Design Name: 
// Module Name: EX_MEM
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


module EX_MEM(
input                                       clk,
input                                       rst_n,
input       [31:0]                          ALUout_i,
input       [31:0]                          rd2_i,
input                                       DRAMWE_i,
input       [1:0]                           rwsel_i,
input       [31:0]                          imm_out_i,
input       [31:0]                          pc4_i,
input                                       regwe_i,
input       [4:0]                           wr_i,
input       [4:0]                           ALUop_i,

output  reg     [4:0]                       ALUop_o,
output  reg     [4:0]                       wr_o,
output  reg     [31:0]                      ALUout_o,
output  reg     [31:0]                      rd2_o,
output  reg                                 DRAMWE_o,
output  reg     [1:0]                       rwsel_o,
output  reg     [31:0]                      imm_out_o,
output  reg     [31:0]                      pc4_o,
output  reg                                 regwe_o
    );

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        ALUout_o <= 32'd0;
        rd2_o <= 32'd0;
        DRAMWE_o <= 1'b0;
        rwsel_o <= 2'd0;
        imm_out_o <= 32'd0;
        pc4_o <= 32'd0;
        regwe_o <= 1'b0;
        wr_o <= 5'd0;
        ALUop_o <= 5'd0;
    end
    else begin
        ALUout_o <= ALUout_i;
        rd2_o <= rd2_i;
        DRAMWE_o <= DRAMWE_i;
        rwsel_o <= rwsel_i;
        imm_out_o <= imm_out_i;
        pc4_o <= pc4_i;
        regwe_o <= regwe_i;
        wr_o <= wr_i;
        ALUop_o <= ALUop_i;
    end
end


endmodule
