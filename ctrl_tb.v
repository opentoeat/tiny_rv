`timescale 1ns/1ps
// 指令级 review：验证 BLT/BLTU/SRLI/SRAI/AUIPC 的控制信号 + ALU 移位结果
// 字面量取自 param.v：SRL=5'b00110 SRA=5'b00111 ADD=5'b00000 WB_ALU_out=2'b00
module ctrl_tb;
  reg  [31:0] instr, cA, cB;
  wire        PCSel;
  wire [2:0]  sextope;
  wire        regwe, Asel, Bsel, DRAMWE, branch_sel, u, TYPE_LOAD;
  wire [4:0]  ALUop;
  wire [1:0]  rwsel;

  CTRL dut_ctrl(
    .Instruction(instr), .MUXA_out(cA), .MUXB_out(cB),
    .PCSel(PCSel), .sextope(sextope), .regwe(regwe), .Asel(Asel), .Bsel(Bsel),
    .ALUop(ALUop), .DRAMWE(DRAMWE), .rwsel(rwsel), .branch_sel(branch_sel),
    .u(u), .TYPE_LOAD(TYPE_LOAD)
  );

  reg  [31:0] aA, aB;
  reg  [4:0]  aOp;
  wire [31:0] aOut;
  wire        aZero, aNeg;
  ALU dut_alu(.MUXA_out(aA), .MUXB_out(aB), .ALUop(aOp), .ALUout(aOut), .zero(aZero), .negative(aNeg));

  integer errs=0;
  task chk32; input [255:0] nm; input [31:0] got; input [31:0] exp;
    begin
      if (got===exp) $display("PASS %0s", nm);
      else begin $display("FAIL %0s got=%h exp=%h", nm, got, exp); errs=errs+1; end
    end
  endtask

  initial begin
    // ===== BLT (B型 funct3=100, opcode=1100011) =====
    instr = {7'b0000000, 5'd2, 5'd1, 3'b100, 4'b0000, 1'b0, 7'b1100011};
    cA=32'hFFFFFFFB; cB=32'h00000003; #1;   // -5 < 3 → 跳转
    chk32("blt_taken",     {31'd0,PCSel}, 32'd1);
    cA=32'h00000003; cB=32'hFFFFFFFB; #1;   // 3 < -5 → 不跳
    chk32("blt_nottaken",  {31'd0,PCSel}, 32'd0);

    // ===== BLTU (B型 funct3=110) =====
    instr = {7'b0000000, 5'd2, 5'd1, 3'b110, 4'b0000, 1'b0, 7'b1100011};
    cA=32'h00000003; cB=32'h00000005; #1;   // 3 < 5 → 跳转
    chk32("bltu_taken",    {31'd0,PCSel}, 32'd1);
    cA=32'hFFFFFFFF; cB=32'h00000003; #1;   // 无符号 FFFFFFFF < 3 → 不跳
    chk32("bltu_nottaken", {31'd0,PCSel}, 32'd0);

    // ===== SRLI (I型 funct3=101, funct7=0000000) =====
    instr = {7'b0000000, 5'd4, 5'd1, 3'b101, 5'd3, 7'b0010011}; #1;
    chk32("srli_aluop", {27'd0,ALUop}, {27'd0,5'b00110});

    // ===== SRAI (I型 funct3=101, funct7=0100000) =====
    instr = {7'b0100000, 5'd4, 5'd1, 3'b101, 5'd3, 7'b0010011}; #1;
    chk32("srai_aluop", {27'd0,ALUop}, {27'd0,5'b00111});

    // ===== AUIPC (U型 opcode=0010111) =====
    instr = {20'h12345, 5'd5, 7'b0010111}; #1;
    chk32("auipc_Asel",  {31'd0,Asel},  32'd1);
    chk32("auipc_rwsel", {30'd0,rwsel}, {30'd0,2'b00});
    chk32("auipc_aluop", {27'd0,ALUop}, {27'd0,5'b00000});

    // ===== ALU 实际移位：SRL 逻辑右移 / SRA 算术右移 =====
    aA=32'h80000000; aB=32'h00000004;
    aOp=5'b00110; #1;   // SRL: 0x80000000 >> 4 = 0x08000000
    chk32("alu_srl", aOut, 32'h08000000);
    aOp=5'b00111; #1;   // SRA: 0x80000000 >>> 4 = 0xF8000000 (符号位填充)
    chk32("alu_sra", aOut, 32'hF8000000);

    // ===== SLT / SLTU 比较验证 =====
    aA=32'hFFFFFFFB; aB=32'h00000003;
    aOp=5'b00011; #1;   // SLT 有符号: -5 < 3 -> 1
    chk32("alu_slt", aOut, 32'd1);
    aA=32'h00000003; aB=32'h00000100;   // B=256，B[4:0]=0（能区分 bug）
    aOp=5'b00100; #1;   // SLTU 无符号: 3 < 256 -> 1（修复前 bug: 3<0 -> 0）
    chk32("alu_sltu", aOut, 32'd1);

    $display("==== TB DONE: errors=%0d ====", errs);
    if (errs==0) $display("ALL_PASS"); else $display("HAS_FAIL");
    $finish;
  end
endmodule
