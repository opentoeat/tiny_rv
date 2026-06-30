`timescale 1ns / 1ps

module Regfile(
input               clk,
input               rst_n,
input   [4:0]       wr,
input   [4:0]       rs1,
input   [4:0]       rs2,
input   [31:0]      wd,         //写回数据，经过alu计算得到的

input               regwe,      //写使能        1为有效 0为无效

output  [31:0]      rd1,
output  [31:0]      rd2
    );

//写使能拉高的时候，激活Regfile[wr] <= wd;

reg [31:0]  Regfile [31:0];     //32个32位的寄存器堆

integer i;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        for(i = 0; i < 32 ; i = i+1)begin
            Regfile[i][31:0] <= 32'd0;
        end
    end
    else if(regwe&&(wr != 5'd0)) begin
        Regfile[$unsigned(wr)] <= wd;
    end 
end

assign rd1 = (rs1==0) ? 32'd0 : Regfile[$unsigned(rs1)];
assign rd2 = (rs2==0) ? 32'd0 : Regfile[$unsigned(rs2)];
//一直实现的

endmodule
