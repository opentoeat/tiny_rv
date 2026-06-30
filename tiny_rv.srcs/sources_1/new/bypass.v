`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/24 22:49:43
// Design Name: 
// Module Name: bypass
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

//这个模块应该在ID阶段
module bypass(
input       [31:0]              ALUout_EX,
input       [31:0]              ALUout_MEM,
input       [31:0]              DRAMRd_MEM,
//EX冒险
input       [4:0]               wr_EX,
input       [4:0]               rs1_ID,
input       [4:0]               rs2_ID,
input                           regwe_EX,       //EX阶段的寄存器堆写使能
input       [31:0]              u_data,
input                           u,
//MEM冒险
input       [4:0]               wr_MEM,
input                           regwe_MEM,
input       [4:0]               ALUop,
//Load-use冒险
input       [1:0]               rwsel_EX,

output      reg    [31:0]       Forwarding_A,
output      reg    [31:0]       Forwarding_B,
output      reg                 MUX_A_forwarding,
output      reg                 MUX_B_forwarding,
output                          Load_use_risk
    );

wire        EX_A_risk;        //exa冒险
wire        EX_B_risk;           //exb冒险
wire        MEM_A_risk;       //MEMA冒险
wire        MEM_B_risk;       //MEMB冒险
//wire        Load_use_risk;  //Load-use冒险
assign EX_risk = ((wr_EX==rs1_ID)||(wr_EX==rs2_ID))&&(wr_EX!=5'd0)&&(regwe_EX);
assign EX_A_risk = (wr_EX==rs1_ID&&wr_EX!=5'd0&&regwe_EX);
assign EX_B_risk = (wr_EX==rs2_ID&&wr_EX!=5'd0&&regwe_EX);


assign MEM_A_risk = (wr_MEM==rs1_ID&&wr_MEM!=5'd0&&regwe_MEM);
assign MEM_B_risk = (wr_MEM==rs2_ID&&wr_MEM!=5'd0&&regwe_MEM);

assign Load_use_risk = EX_risk && (rwsel_EX == `WB_DRAM_Rd);
//assign risk = EX_risk || MEM_risk;



//ex冒险在前，MEM冒险在后
always @(*) begin
    if(EX_A_risk)begin
        MUX_A_forwarding = `ASEL_FORWARDING;
        Forwarding_A = u ? u_data : ALUout_EX;
    end
    else if(MEM_A_risk)begin
        MUX_A_forwarding = `ASEL_FORWARDING;
        Forwarding_A = (ALUop==`LW) ? DRAMRd_MEM : ALUout_MEM;
    end
    else begin
        MUX_A_forwarding = ~(`ASEL_FORWARDING);
        Forwarding_A = 32'd0;
    end
end

always @(*) begin
    if(EX_B_risk)begin
        MUX_B_forwarding = `BSEL_FORWARDING;
        Forwarding_B = u ? u_data : ALUout_EX;
    end
    else if(MEM_B_risk)begin
        MUX_B_forwarding = `BSEL_FORWARDING;
        Forwarding_B = (ALUop==`LW) ? DRAMRd_MEM : ALUout_MEM;
    end
    else begin
        MUX_B_forwarding = ~(`BSEL_FORWARDING);
        Forwarding_B = 32'd0;
    end
end



endmodule
