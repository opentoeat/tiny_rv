`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/02 16:39:41
// Design Name: 
// Module Name: top
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


module top(
input               clk,
input               rst_n,
//外设接口
input   [3:0]       key_in,

output  [11:0]      vga_data,
output              vga_href,
output              vga_de,
output              vga_vsync
);

wire    clk_100m;
clock_buffer clock_buffer (
.clk_in(clk),
.clk_out(clk_100m)
);


wire    clk_50m;
wire    [31:0]      addr;
wire    [31:0]      wdata;
wire    [31:0]      rdata;
wire                we;
wire    [4:0]       ctrl;//假设有五个外设吧
rv_top rv_top(
.clk(clk_50m),
.rst_n(rst_n),      //复位信号
.addr(addr),
.we(we),
.wdata(wdata),
.rdata(rdata)
);

key_debounce key_debounce_0(
.clk      (clk_50m),        // 时钟信号
.rst_n    (rst_n),      // 复位信号，低有效
.key_in   (key_in[0]),     // 原始按键信号（低电平有效）
.key_state(key_state[0])  // 消抖后的稳定按键状态（低有效）
);

key_debounce key_debounce_1(
.clk      (clk_50m),        // 时钟信号
.rst_n    (rst_n),      // 复位信号，低有效
.key_in   (key_in[1]),     // 原始按键信号（低电平有效）
.key_state(key_state[1])  // 消抖后的稳定按键状态（低有效）
);
key_debounce key_debounce_2(
.clk      (clk_50m),        // 时钟信号
.rst_n    (rst_n),      // 复位信号，低有效
.key_in   (key_in[2]),     // 原始按键信号（低电平有效）
.key_state(key_state[2])  // 消抖后的稳定按键状态（低有效）
);
key_debounce key_debounce_3(
.clk      (clk_50m),        // 时钟信号
.rst_n    (rst_n),      // 复位信号，低有效
.key_in   (key_in[3]),     // 原始按键信号（低电平有效）
.key_state(key_state[3])  // 消抖后的稳定按键状态（低有效）
);


wire  [12:0]          ram_addr;
wire  [31:0]          ram_data;

wire                  vga_ram_data;
wire  [18:0]          vga_ram_addr;

wire  [31:0]          in_data;
wire  [3:0]           key_state;
wire                  vga_we;

bus_top bus_top(
.clk               (clk_50m),
.rst_n             (rst_n),  
.we                (we),
.addr              (addr),
.wdata             (wdata),          //写数据
.in_data           (in_data),
.rdata             (rdata),          //读数据
.ctrl              (ctrl),
.ram_addr          (ram_addr),
.ram_data          (ram_data),
.vga_data          (vga_ram_data),
.vga_addr          (vga_ram_addr),
//.key_in            (),
.key_state         (key_state),
.vga_we            (vga_we)
);

wire    clk_25m;

  clk_wiz_0 clk_wiz_0
   (
    // Clock out ports
    .clk_out1(clk_25m),     // output clk_out1
    .clk_out2(clk_50m),     // output clk_out2
   // Clock in ports
    .clk_in1(clk_100m)
    );      // input clk_in1

wire    [18:0]    bram_addr;
wire              bram_data;

Vga_ram Vga_ram (
  .clka             (clk_50m),           
  .ena              (1'b1),         
  .wea              (vga_we),            
  .addra            (vga_ram_addr),  
  .dina             (vga_ram_data),    
  .clkb             (clk_25m),    
  .enb              (1'b1),      
  .addrb            (bram_addr),//{5'd0,bram_addr[18:5]}),                    // input wire [18 : 0] addrb
  .doutb            (bram_data)                     // output wire [15 : 0] doutb
);

//Vga_ram Vga_ram (
//  .clka(clk_25m),    // input wire clka
//  .ena(1'b1),      // input wire ena
//  .addra(bram_addr),  // input wire [18 : 0] addra
//  .douta(bram_data)  // output wire [0 : 0] douta
//);

//assign vga_clk = clk_25m;

vga_bram_rgb565_sync vga_bram_rgb565_sync(
.clk          (clk_25m),          // 25.175MHz VGA时钟
.rst          (rst_n),

.bram_addr    (bram_addr),        // 19位地址线
.bram_data    (bram_data),              // 1bpp 像素（0=黑,1=白）

.hsync        (vga_href),
.vsync        (vga_vsync),
.video_on     (vga_de),
.vga_data     (vga_data)// 16位RGB565输出
);


DRAM_MEM your_instance_name (
  .a(ram_addr),        // input wire [12 : 0] a
  .d(ram_data),        // input wire [31 : 0] d
  .dpra(ram_addr),  // input wire [12 : 0] dpra
  .clk(clk_50m),    // input wire clk
  .we(ctrl[0]),      // input wire we
  .dpo(in_data)    // output wire [31 : 0] dpo
);

endmodule
