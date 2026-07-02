`timescale 1ns / 1ps
module rv_top_tb();
    reg clk, rst_n;
    wire [11:0] vga_data;
    wire vga_de, vga_href, vga_vsync;

    always #5 clk = ~clk;

    initial begin
        clk = 1'b1;
        rst_n = 1'b0;
        #202 rst_n = 1'b1;
    end

    // 监控 PC 推进 + load 自检：观察 t2(x7) 是否 = 0xA5（store→load 经 BRAM+freeze）
    always @(posedge clk) begin
        if (rst_n) $display("t=%0t PC=%h x7(t2)=%h", $time, top.rv_top.pc_IF, top.rv_top.ID.u_Regfile.Regfile[7]);
    end

    initial begin
        #4000;
        $display("=== sim end ===");
        $finish;
    end

    top top(
        .clk(clk), .rst_n(rst_n),
        .vga_data(vga_data), .vga_href(vga_href), .vga_de(vga_de), .vga_vsync(vga_vsync)
    );
endmodule
