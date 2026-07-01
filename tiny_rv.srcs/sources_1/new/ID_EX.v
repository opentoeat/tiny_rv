`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Xi'an University of Post and Telecommunication
// Engineer: 
// 
// Create Date: 2025/05/24 13:55:46
// Design Name: 
// Module Name: ID_EX
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


module ID_EX(
input                           clk,
input                           rst_n,
input       [31:0]              pc4_i,
//控制信号  
input       [4:0]               ALUop_i,
input                           DRAMWE_i,
input       [1:0]               rwsel_i,
input                           branch_sel_i,
input                           PCSel_i,
input                           regwe_i,
//数据信号
input       [4:0]               wr_i,
input       [31:0]              MUXA_out_i,
input       [31:0]              MUXB_out_i,
input       [31:0]              rd2_i,
input       [31:0]              imm_out_i,
input                           u_i,
input                           TYPE_LOAD_i,

input                           stop_ID,
input                           hold_EX,

output   reg                       TYPE_LOAD_o,
output   reg                       u_o,
output   reg    [4:0]              wr_o,
output   reg    [31:0]             pc4_o,
output   reg    [4:0]              ALUop_o,
output   reg                       DRAMWE_o,
output   reg    [1:0]              rwsel_o,
output   reg                       regwe_o,
output   reg                       branch_sel_o,
output   reg                       PCSel_o,
output   reg    [31:0]             MUXA_out_o,
output   reg    [31:0]             MUXB_out_o,
output   reg    [31:0]             rd2_o,
output   reg    [31:0]             imm_out_o        
    );


always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        ALUop_o <= 5'd0;
        DRAMWE_o <= 1'b0;
        rwsel_o <= 2'd0;
        branch_sel_o <= 1'b0;
        regwe_o <= 1'b0;
        PCSel_o <= 1'b0;
        rd2_o <= 32'd0;
        imm_out_o <= 32'd0;  
        MUXA_out_o <= 32'd0;
        MUXB_out_o <= 32'd0;
        pc4_o <= 32'd0;
        wr_o <= 5'd0;
        u_o <= 1'b0;
        TYPE_LOAD_o <= 1'b0;
    end
    else if(hold_EX)begin
        //冻结：BRAM load stall 期间保持 ID_EX 输出不变
    end
    else if(stop_ID)begin
        ALUop_o <= 5'd0;
        DRAMWE_o <= 1'b0;
        rwsel_o <= 2'd0;
        branch_sel_o <= 1'b0;
        regwe_o <= 1'b0;
        PCSel_o <= 1'b0;
        rd2_o <= 32'd0;
        imm_out_o <= 32'd0;  
        MUXA_out_o <= 32'd0;
        MUXB_out_o <= 32'd0;
        pc4_o <= 32'd0;
        wr_o <= 5'd0;
        u_o <= 1'b0;
        TYPE_LOAD_o <= 1'b0;
    end
    else begin
        TYPE_LOAD_o <= TYPE_LOAD_i;
        u_o <= u_i;
        pc4_o <= pc4_i;
        ALUop_o <= ALUop_i;
        DRAMWE_o <= DRAMWE_i;
        rwsel_o <= rwsel_i;
        branch_sel_o <= branch_sel_i;
        PCSel_o <= PCSel_i;
        rd2_o <= rd2_i;
        imm_out_o <= imm_out_i;  
        MUXA_out_o <= MUXA_out_i;
        MUXB_out_o <= MUXB_out_i;
        regwe_o <= regwe_i;
        wr_o <= wr_i;
    end

end

endmodule
