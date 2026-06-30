`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/24 13:22:49
// Design Name: 
// Module Name: IF_ID
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


module IF_ID(
input                           clk,
input                           rst_n,
input       [31:0]              pc4_i,            //pc + 4    到WB
input       [31:0]              pc_i,             //pc        到EX
input       [31:0]              instruction_i,
input                           stop_IF,
input                           isRiskCtrl,

output  reg    [31:0]           pc4_o,
output  reg    [31:0]           pc_o,
output  reg    [31:0]           instruction_o
    );

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        pc4_o   <= 32'd0;
        pc_o    <= 32'd0;
        instruction_o <= 32'd0;
    end
    else if(isRiskCtrl)begin
        pc4_o   <= 32'd0;
        pc_o    <= 32'd0;
        instruction_o <= 32'd0;
    end
    else if(stop_IF)begin
        pc4_o   <= pc4_o;
        pc_o    <= pc_o;
        instruction_o <= instruction_o;
    end
    else begin
        pc4_o   <= pc4_i;
        pc_o    <= pc_i;
        instruction_o <= instruction_i;
    end
end


endmodule
