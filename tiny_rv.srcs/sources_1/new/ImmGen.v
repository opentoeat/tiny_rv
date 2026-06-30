
`include "param.v"

module ImmGen(
    input   [31:7]  imm,
    input   [2:0]   sextope,
    output  [31:0]  imm_out
);

wire [31:0] imm_I;
wire [31:0] imm_S;
wire [31:0] imm_SB;
wire [31:0] imm_U;
wire [31:0] imm_J;
reg [31:0]  imm_out_r;

assign imm_I = {{20{imm[31]}},imm[31:20]};
//I型指令扩展
assign imm_S = {{20{imm[31]}}, imm[31:25], imm[11:7]};
//S型指令扩展
wire [12:0] sb_imm = {imm[31], imm[7], imm[30:25], imm[11:8], 1'b0};
assign imm_SB = {{19{sb_imm[12]}}, sb_imm}; // 符号扩展为32位
//SB型指令扩展
assign imm_U = {imm[31:12],12'd0};

wire [19:0] imm_raw = {
    imm[31],      // imm[20]（符号位）
    imm[19:12],   // imm[10:1]
    imm[20],      // imm[11]
    imm[30:21]    // imm[19:12]
};
assign imm_J = {{11{imm_raw[19]}}, imm_raw, 1'b0};
//J型指令扩展


always @(*) begin
    case (sextope)
        `I_type_imm:imm_out_r = imm_I;
        `S_type_imm:imm_out_r = imm_S;
        `SB_type_imm:imm_out_r = imm_SB;
        `U_type_imm:imm_out_r = imm_U;
        `J_type_imm:imm_out_r = imm_J;
        default:imm_out_r = 32'd0;
    endcase
end


assign imm_out = imm_out_r;



endmodule