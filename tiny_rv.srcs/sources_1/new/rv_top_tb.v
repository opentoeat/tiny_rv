`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/22 20:02:05
// Design Name: 
// Module Name: rv_top_tb
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


module rv_top_tb();


reg clk;
reg rst_n;

wire    [11:0]      vga_data;
wire                vga_de;
wire                vga_href;
wire                vga_vsync;

always #5 clk = ~clk;

initial begin
    clk = 1'b1;
    rst_n = 1'b0;
    #202
    rst_n = 1'b1;
end


top top(
.clk        (clk),
.rst_n      (rst_n),

.vga_data   (vga_data),
.vga_href   (vga_href),
.vga_de     (vga_de),
.vga_vsync  (vga_vsync)
);


endmodule
