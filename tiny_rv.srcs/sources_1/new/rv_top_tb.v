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

    // 监控 PC 推进：验证 load-freeze 没让 CPU 死锁/跑飞
    always @(posedge clk) begin
        if (rst_n) $display("t=%0t PC=%h", $time, top.rv_top.pc_IF);
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
