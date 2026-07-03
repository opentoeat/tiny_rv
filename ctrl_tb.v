`timescale 1ns/1ps
// 指令级 review：CTRL 控制信号（组合）+ ALU 乘法（组合）+ ALU 除法（多周期时序）
module ctrl_tb;
  reg clk=0, rst_n=0;
  always #5 clk = ~clk;

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
  reg  [2:0]  aMop;
  wire [31:0] aOut;
  wire        aZero, aNeg, div_busy_w;
  ALU dut_alu(.MUXA_out(aA), .MUXB_out(aB), .ALUop(aOp), .M_op(aMop),
              .clk(clk), .rst_n(rst_n), .div_busy(div_busy_w),
              .ALUout(aOut), .zero(aZero), .negative(aNeg));

  integer errs=0;
  task chk32; input [255:0] nm; input [31:0] got; input [31:0] exp;
    begin
      if (got===exp) $display("PASS %0s", nm);
      else begin $display("FAIL %0s got=%h exp=%h", nm, got, exp); errs=errs+1; end
    end
  endtask

  task wait_div;  // 等除法器启动 + 跑完（不动 aOp，保留 div 结果在 ALUout）
    begin
      @(posedge clk);   // 启动拍（state<=CALC NBA）
      #1;               // 等 NBA 生效，busy=1
      while(div_busy_w) @(posedge clk);
      #1;
    end
  endtask

  initial begin
    rst_n=0; aA=0; aB=0; aOp=0; aMop=0; instr=0; cA=0; cB=0;
    #12 rst_n=1;
    @(posedge clk); #1;

    // ===== BLT (B型 funct3=100) =====
    instr = {7'b0000000, 5'd2, 5'd1, 3'b100, 4'b0000, 1'b0, 7'b1100011};
    cA=32'hFFFFFFFB; cB=32'h00000003; #1;
    chk32("blt_taken",     {31'd0,PCSel}, 32'd1);
    cA=32'h00000003; cB=32'hFFFFFFFB; #1;
    chk32("blt_nottaken",  {31'd0,PCSel}, 32'd0);

    // ===== BLTU (funct3=110) =====
    instr = {7'b0000000, 5'd2, 5'd1, 3'b110, 4'b0000, 1'b0, 7'b1100011};
    cA=32'h00000003; cB=32'h00000005; #1;
    chk32("bltu_taken",    {31'd0,PCSel}, 32'd1);
    cA=32'hFFFFFFFF; cB=32'h00000003; #1;
    chk32("bltu_nottaken", {31'd0,PCSel}, 32'd0);

    // ===== SRLI / SRAI =====
    instr = {7'b0000000, 5'd4, 5'd1, 3'b101, 5'd3, 7'b0010011}; #1;
    chk32("srli_aluop", {27'd0,ALUop}, {27'd0,5'b00110});
    instr = {7'b0100000, 5'd4, 5'd1, 3'b101, 5'd3, 7'b0010011}; #1;
    chk32("srai_aluop", {27'd0,ALUop}, {27'd0,5'b00111});

    // ===== AUIPC =====
    instr = {20'h12345, 5'd5, 7'b0010111}; #1;
    chk32("auipc_Asel",  {31'd0,Asel},  32'd1);
    chk32("auipc_rwsel", {30'd0,rwsel}, {30'd0,2'b00});
    chk32("auipc_aluop", {27'd0,ALUop}, {27'd0,5'b00000});

    // ===== ALU 移位 / 比较（组合）=====
    aA=32'h80000000; aB=32'h00000004;
    aOp=5'b00110; #1;  chk32("alu_srl", aOut, 32'h08000000);
    aOp=5'b00111; #1;  chk32("alu_sra", aOut, 32'hF8000000);
    aA=32'hFFFFFFFB; aB=32'h00000003; aOp=5'b00011; #1;
    chk32("alu_slt", aOut, 32'd1);
    aA=32'h00000003; aB=32'h00000100; aOp=5'b00100; #1;
    chk32("alu_sltu", aOut, 32'd1);

    // ===== M 扩展：乘法（组合，DSP）=====
    aA=32'd6; aB=32'd7; aOp=5'b11001; aMop=3'b000; #1;
    chk32("alu_mul", aOut, 32'd42);
    aA=32'hFFFFFFFE; aB=32'hFFFFFFFE; aMop=3'b000; #1;
    chk32("alu_mul_neg", aOut, 32'd4);
    aA=32'h80000000; aB=32'h80000000; aMop=3'b001; #1;
    chk32("alu_mulh", aOut, 32'h40000000);
    aA=32'hFFFFFFFF; aB=32'hFFFFFFFF; aMop=3'b011; #1;
    chk32("alu_mulhu", aOut, 32'hFFFFFFFE);

    // ===== M 扩展：除法（多周期；每个之后 aOp=0 一拍清 launched）=====
    aA=32'd20; aB=32'd6;  aOp=5'b11001; aMop=3'b100; wait_div;  // DIV 20/6=3
    chk32("alu_div", aOut, 32'd3);
    aOp=0; @(posedge clk); #1;
    aA=32'd20; aB=32'd6;  aOp=5'b11001; aMop=3'b110; wait_div;  // REM 20%6=2
    chk32("alu_rem", aOut, 32'd2);
    aOp=0; @(posedge clk); #1;
    aA=32'd100; aB=32'd10; aOp=5'b11001; aMop=3'b101; wait_div; // DIVU 10
    chk32("alu_divu", aOut, 32'd10);
    aOp=0; @(posedge clk); #1;
    aA=32'd100; aB=32'd7;  aOp=5'b11001; aMop=3'b111; wait_div; // REMU 100%7=2
    chk32("alu_remu", aOut, 32'd2);
    aOp=0; @(posedge clk); #1;
    aA=32'd5;  aB=32'd0;  aOp=5'b11001; aMop=3'b100; wait_div;  // DIV 除零→-1
    chk32("alu_div0", aOut, 32'hFFFFFFFF);
    aOp=0; @(posedge clk); #1;
    aA=32'd5;  aB=32'd0;  aOp=5'b11001; aMop=3'b110; wait_div;  // REM 除零→被除数
    chk32("alu_rem0", aOut, 32'd5);

    $display("==== TB DONE: errors=%0d ====", errs);
    if (errs==0) $display("ALL_PASS"); else $display("HAS_FAIL");
    $finish;
  end
endmodule
