`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/02 16:40:05
// Design Name: 
// Module Name: rv_top
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


module rv_top(
input           clk,
input           rst_n,      //复位信号
//数据存储器信号
output [31:0]   addr,
output          we,
output [31:0]   wdata,
input   [31:0]  rdata
);

// assign addr = ALUout_MEM;
// assign wdata = rd2;
// assign we = DRAMWE;
// assign DRAMRd_MEM = rdata;

// rv_top rv_top(
// .clk(clk),
// .rst_n(rst_n),      //复位信号
// .addr(addr),
// .we(we),
// .wdata(wdata),
// .rdata(rdata)
// );
// MEM MEM(
// .rst_n                      (rst_n),
// .clk                        (clk),
// .ALU_out                    (ALUout_MEM),    //计算得到的结果
// .rd2                        (rd2_MEM),        //从寄存器堆传来的
// .DRAMWE                     (DRAMWE_MEM),     //ram的写使能   1为写 0为读

// .DRAMRd                     (DRAMRd_MEM)      //从mem中取出的数据
//     );
/*
注意大小写
*/
// wire            [31:0]          ALU_out;        
// //从EX模块输出  进入IF
// wire                            PCsel;
// //从Ctrl模块输出 进入IF
// wire            [31:0]          Instruction;
// //从IF输出  进入ID
// wire            [31:0]          PC4;
// //从IF输出
// wire            [31:0]          pc_out;
// //从IF输出 进入ID模块
// wire            [31:0]          wd;
// //从WB输出 进入ID
// wire            [2:0]           sextope;
// wire                            regwe;
// wire                            Asel;
// wire                            Bsel;
// //从控制输出 进入ID
// wire            [31:0]          MUXA_out;
// wire            [31:0]          MUXB_out;
// //从ID输出 进入EX
// wire            [4:0]           ALUop;
// //从控制输出进入EX
// wire                            negative;
// wire                            zero;
// //从ex输出 进入控制
// wire            [31:0]          rd2;
// //从EX输出 进入MEM
// wire                            DRAMWE;
// //从控制输出 进入mem
// wire            [31:0]          DRAMRd;
// //从mem输出 进入WB
// wire            [1:0]           rwsel;
// //从ctrl传出 进入WB
// wire                            branch_sel;
// //从控制输出 进入IF
// wire            [31:0]          imm_out;
// //从ID传出 进入IF模块

wire            [31:0]          pc_IF;          //IF阶段的pc值
wire            [31:0]          pc4_IF;         //IF阶段的pc+4值
wire            [31:0]          Instruction_IF; //IF阶段的指令
//ID    
wire            [31:0]          pc_ID;          //ID阶段的pc值
wire            [31:0]          pc4_ID;         //ID阶段的pc+4值
wire            [31:0]          Instruction_ID; //ID阶段的指令

wire                            PCsel_ID;
wire            [2:0]           sextope_ID;
wire                            regwe_ID;
wire                            Asel_ID;
wire                            Bsel_ID;
wire            [4:0]           ALUop_ID;
wire                            DRAMWE_ID;
wire            [1:0]           rwsel_ID;
wire                            branch_sel_ID;
wire                            TYPE_LOAD_ID;

wire            [31:0]          ALUout_ID;
wire            [4:0]           wr_ID;
wire            [31:0]          imm_out_ID;
wire            [31:0]          rd2_ID;
wire            [31:0]          MUXA_out_ID;
wire            [31:0]          MUXB_out_ID;
//EX
wire            [4:0]           ALUop_EX;
wire                            DRAMWE_EX;
wire            [1:0]           rwsel_EX;
//wire                            branch_sel_EX;
wire                            PCsel_EX;
wire            [4:0]           wr_EX;
wire                            regwe_EX;
wire            [31:0]          rd2_EX;
wire            [31:0]          imm_out_EX;
wire            [31:0]          MUXA_out_EX;
wire            [31:0]          MUXB_out_EX;
wire            [31:0]          pc4_EX;
wire            [31:0]          ALUout_EX;
wire                            TYPE_LOAD_EX;

//MEM
wire            [31:0]          ALUout_MEM;
wire            [31:0]          rd2_MEM;
wire                            DRAMWE_MEM;
wire            [1:0]           rwsel_MEM;
wire                            regwe_MEM;
wire            [31:0]          imm_out_MEM;
wire            [31:0]          DRAMRd_MEM;
wire            [31:0]          pc4_MEM;
wire            [31:0]          wd_MEM;
wire            [4:0]           wr_MEM;

//前递
wire            [31:0]          Forwarding_A;
wire            [31:0]          Forwarding_B;
wire                            MUX_A_forwarding;
wire                            MUX_B_forwarding;
wire                            Load_use_risk;
wire                            u_ID;
wire                            u_EX;
wire            [4:0]           ALUop_MEM;
//停顿
wire                            stop_ID;
wire                            stop_IF;
wire                            isRiskCtrl;
wire                            stop_MEM;
wire                            hold_EX;
wire                            load_in_MEM;
assign load_in_MEM = (rwsel_MEM == 2'b01) && regwe_MEM;   // 2'b01 = WB_DRAM_Rd (load)


assign addr = ALUout_MEM;
assign wdata = rd2_MEM;
assign we = DRAMWE_MEM;
assign DRAMRd_MEM = rdata;
IF IF(
.clk                        (clk),
.rst_n                      (rst_n),
.ALU_out                    (ALUout_ID),           //好像不需要它 //跳转阶段啊 jalr需要她
.imm_out                    (imm_out_ID),    
.pc_ID                      (pc_ID),     
.branch_sel                 (branch_sel_ID),
.PCsel                      (PCsel_ID),          //选择地址信号，由控制模块产生
.stop_IF                    (stop_IF),

.Instruction                (Instruction_IF),    //从rom中输出的指令
.PC4                        (pc4_IF),             //pc加4输出
.pc_out                     (pc_IF)
);
/*
注意大小写
*/

IF_ID IF_ID(
.clk                        (clk),
.rst_n                      (rst_n),
.pc4_i                      (pc4_IF),            //pc + 4    到WB
.pc_i                       (pc_IF),             //pc        到EX
.instruction_i              (Instruction_IF),
.stop_IF                    (stop_IF),
.isRiskCtrl                 (isRiskCtrl),

.pc4_o                      (pc4_ID),
.pc_o                       (pc_ID),
.instruction_o              (Instruction_ID)
    );

//ID 阶段   
CTRL CTRL(
// input                       clk             (),
// input                       rst_n           (),
.Instruction                (Instruction_ID),
.MUXA_out                   (MUXA_out_ID),              //此处更改，将分支跳转指令中的比较操作提前到ID模块
.MUXB_out                   (MUXB_out_ID),
//.zero                       (zero),                 //这两个应该计算之后再得到
//.negative                   (negative),             //这两个应该计算之后再得到

.u                          (u_ID),
.PCSel                      (PCsel_ID),          //地址选择信号                   完成
.sextope                    (sextope_ID),        //立即数扩展状态                 完成
.regwe                      (regwe_ID),          //控制是否写回寄存器             完成
.Asel                       (Asel_ID),           //pc和rd1的二选一控制信号        完成
.Bsel                       (Bsel_ID),           //rd2和立即数的二选一控制信号    完成
.ALUop                      (ALUop_ID),          //计算模块的控制信号             完成
.DRAMWE                     (DRAMWE_ID),         //dram的写使能                   完成
.rwsel                      (rwsel_ID),          //写回选择信号                   完成
.branch_sel                 (branch_sel_ID),        //控制是j型还是b型              完成
.TYPE_LOAD                  (TYPE_LOAD_ID)
    );

assign isRiskCtrl = PCsel_ID;

ID ID(
.clk                        (clk),
.rst_n                      (rst_n),
.instruction                (Instruction_ID),
.pc                         (pc_ID),
.sextope                    (sextope_ID),     
.wd                         (wd_MEM),                   //这个应该从WB模块传出
.regwe                      (regwe_MEM),                 //这个也应该是WB模块传出啊       
.Asel                       (Asel_ID),           
.Bsel                       (Bsel_ID),    
.Forwarding_A               (Forwarding_A),
.Forwarding_B               (Forwarding_B),
.MUX_A_forwarding           (MUX_A_forwarding),
.MUX_B_forwarding           (MUX_B_forwarding),       
.wr_i                       (wr_MEM),

.wr_o                       (wr_ID),
.imm_out                    (imm_out_ID),        
.rd2                        (rd2_ID),   
.MUXA_out                   (MUXA_out_ID),
.MUXB_out                   (MUXB_out_ID)
    );

// wire        [31:0]              Forwarding_A;
// wire        [31:0]              Forwarding_B;
// wire                            MUX_A_forwarding;
// wire                            MUX_B_forwarding;
// wire                            Load_use_risk;

assign ALUout_ID = MUXA_out_ID + MUXB_out_ID;
bypass bypass(
.ALUout_EX                  (ALUout_EX),
.DRAMRd_MEM                 (DRAMRd_MEM),
.u_data                     (imm_out_EX),       //imm_out     
.u                          (u_EX),
.ALUout_MEM                 (ALUout_MEM),
.ALUop                      (ALUop_MEM),

.wr_EX                      (wr_EX),
.rs1_ID                     (Instruction_ID[19:15]),
.rs2_ID                     (Instruction_ID[24:20]),
.regwe_EX                   (regwe_EX),       //EX阶段的寄存器堆写使能

.wr_MEM                     (wr_MEM),
.regwe_MEM                  (regwe_MEM),

.rwsel_EX                   (rwsel_EX),

.Forwarding_A               (Forwarding_A),
.Forwarding_B               (Forwarding_B),
.MUX_A_forwarding           (MUX_A_forwarding),
.MUX_B_forwarding           (MUX_B_forwarding),
.Load_use_risk              (Load_use_risk)
    );



EXCEPTION_CTRL EXCEPTION_CTRL(
.clk(clk),
.rst_n(rst_n),
.Load_use_risk(Load_use_risk),      //load-use冒险
.isRiskCtrl(isRiskCtrl),         //控制冒险
.load_in_MEM(load_in_MEM),

.stop_ID(stop_ID),            //ID
.stop_IF(stop_IF),
.stop_MEM(stop_MEM),
.hold_EX(hold_EX)
    );

ID_EX ID_EX(
.clk                        (clk),
.rst_n                      (rst_n),
.wr_i                       (wr_ID),
.regwe_i                    (regwe_ID),
.ALUop_i                    (ALUop_ID),
.DRAMWE_i                   (DRAMWE_ID),
.rwsel_i                    (rwsel_ID),
.branch_sel_i               (branch_sel_ID),
.PCSel_i                    (PCsel_ID),
.MUXA_out_i                 (MUXA_out_ID),
.MUXB_out_i                 (MUXB_out_ID),
.rd2_i                      (rd2_ID),
.imm_out_i                  (imm_out_ID),
.pc4_i                      (pc4_ID),
.u_i                        (u_ID),
.TYPE_LOAD_i                (TYPE_LOAD_ID),
.stop_ID                    (stop_ID),
.hold_EX                     (hold_EX),

.TYPE_LOAD_o                (TYPE_LOAD_EX),
.u_o                        (u_EX),
.wr_o                       (wr_EX),
.regwe_o                    (regwe_EX),
.ALUop_o                    (ALUop_EX),
.DRAMWE_o                   (DRAMWE_EX),
.rwsel_o                    (rwsel_EX),
.branch_sel_o               (branch_sel_EX),
.PCSel_o                    (PCsel_EX),
.rd2_o                      (rd2_EX),
.imm_out_o                  (imm_out_EX),    
.MUXA_out_o                 (MUXA_out_EX),
.MUXB_out_o                 (MUXB_out_EX),
.pc4_o                      (pc4_EX)
    );

/*
注意大小写
*/
EX EX(
.MUXA_out                   (MUXA_out_EX),
.MUXB_out                   (MUXB_out_EX),
.ALUop                      (ALUop_EX),      //控制模块传入的

.ALUout                     (ALUout_EX)     //得到的输出
//.negative                   (negative),   //是否为负数
//.zero                       (zero)//是否为零
    );

EX_MEM EX_MEM(
.clk                        (clk),
.rst_n                      (rst_n),
.ALUout_i                   (ALUout_EX),
.rd2_i                      (rd2_EX),
.DRAMWE_i                   (DRAMWE_EX),
.rwsel_i                    (rwsel_EX),
.imm_out_i                  (imm_out_EX),
.pc4_i                      (pc4_EX),
.regwe_i                    (regwe_EX),
.wr_i                       (wr_EX),
.ALUop_i                    (ALUop_EX),
.stop_MEM                    (stop_MEM),

.ALUop_o                    (ALUop_MEM),
.ALUout_o                   (ALUout_MEM),
.rd2_o                      (rd2_MEM),
.DRAMWE_o                   (DRAMWE_MEM),
.rwsel_o                    (rwsel_MEM),
.imm_out_o                  (imm_out_MEM),
.pc4_o                      (pc4_MEM),
.regwe_o                    (regwe_MEM),
.wr_o                       (wr_MEM)
    );

/*
注意大小写
*/

// MEM MEM(
// .rst_n                      (rst_n),
// .clk                        (clk),
// .ALU_out                    (ALUout_MEM),    //计算得到的结果
// .rd2                        (rd2_MEM),        //从寄存器堆传来的
// .DRAMWE                     (DRAMWE_MEM),     //ram的写使能   1为写 0为读

// .DRAMRd                     (DRAMRd_MEM)      //从mem中取出的数据
//     );
/*
注意大小写
*/
WB WB(
.rwsel                      (rwsel_MEM),

.imm_out                    (imm_out_MEM),
.ALU_out                    (ALUout_MEM),
.pc4                        (pc4_MEM),
.DRAMRd                     (DRAMRd_MEM),

.wd                         (wd_MEM)           //这个是写回的数据，为什么你要加个out呢
    );



endmodule
