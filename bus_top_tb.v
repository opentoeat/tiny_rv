`timescale 1ns/1ps
// bus_top 定向功能仿真：自检 PASS/FAIL（用 task，不用宏）
// 验证：DRAM 读/写(组合)、按键读(组合)、显存写(时序,下一拍)、空闲回 0
module bus_top_tb;
  reg         clk=0, rst_n=0, we=0;
  reg  [31:0] addr=0, wdata=0, in_data=0;
  reg  [3:0]  key_state=0;
  wire [31:0] rdata;
  wire [4:0]  ctrl;
  wire [12:0] ram_addr;
  wire [31:0] ram_data;
  wire [15:0] vga_data;
  wire [18:0] vga_addr;
  wire        vga_we;
  integer     errs=0;

  bus_top dut(
    .clk(clk), .rst_n(rst_n), .we(we), .addr(addr), .wdata(wdata),
    .in_data(in_data), .rdata(rdata), .ctrl(ctrl), .ram_addr(ram_addr),
    .ram_data(ram_data), .vga_data(vga_data), .vga_addr(vga_addr),
    .vga_we(vga_we), .key_state(key_state));

  always #5 clk = ~clk;

  // 32 位检查 task：got===exp 则 PASS，否则 FAIL 并计数
  task chk32;
    input [255:0] nm;
    input [31:0]  got;
    input [31:0]  exp;
    begin
      if (got === exp) $display("PASS %0s", nm);
      else begin
        $display("FAIL %0s got=%h exp=%h", nm, got, exp);
        errs = errs + 1;
      end
    end
  endtask

  reg [31:0] exp_vga_addr;
  initial begin
    #12 rst_n = 1;
    @(posedge clk); #1;

    // 1) 读 DRAM（组合：当拍返回 in_data）
    we=0; addr=32'h0000_ABCC; in_data=32'hDEADBEEF; key_state=4'h0; #1;
    chk32("rd_dram_rdata", rdata, 32'hDEADBEEF);
    chk32("rd_dram_ctrl",  {27'd0,ctrl}, 32'h00000010);

    // 2) 读按键（组合）
    we=0; addr=32'h2000_0000; key_state=4'b1010; #1;
    chk32("rd_key_rdata", rdata, {28'd0,4'b1010});
    chk32("rd_key_ctrl",  {27'd0,ctrl}, 32'h00000004);

    // 3) 写 DRAM（组合：地址/数据/写使能当拍生效）
    we=1; addr=32'h0000_ABCD; wdata=32'hCAFEF00D; #1;
    chk32("wr_dram_addr", {19'd0,ram_addr}, {19'd0,addr[14:2]});
    chk32("wr_dram_data", ram_data, 32'hCAFEF00D);
    chk32("wr_dram_ctrl", {27'd0,ctrl}, 32'h00000001);

    // 4) 写显存（时序：vga_we/vga_data/vga_addr 下一拍才生效）
    we=1; addr=32'h1000_0004; wdata=32'h00009ABC; #1;
    chk32("wr_vga_we_now0", {31'd0,vga_we}, 32'd0);          // 当拍还没打拍
    exp_vga_addr = {13'd0, addr[20:2]};
    @(posedge clk); #1;
    chk32("wr_vga_we_next1",  {31'd0,vga_we},   32'd1);
    chk32("wr_vga_data_next", {16'd0,vga_data}, 32'h00009ABC);
    chk32("wr_vga_addr_next", {13'd0,vga_addr}, exp_vga_addr);

    // 5) 停止写显存，vga_we 下拍应回 0
    we=0; addr=32'h0000_0000; @(posedge clk); #1;
    chk32("wr_vga_we_idle0", {31'd0,vga_we}, 32'd0);

    $display("==== TB DONE: errors=%0d ====", errs);
    if (errs==0) $display("ALL_PASS"); else $display("HAS_FAIL");
    $finish;
  end
endmodule
