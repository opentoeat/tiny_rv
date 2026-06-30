module vga_bram_rgb565_sync(
    input         clk,         // 25.175MHz VGA时钟
    input         rst,
    // BRAM接口
    output [18:0] bram_addr,   // 19位地址线
    input  [15:0] bram_data,   // 16位RGB565像素数据
    // VGA接口
    output        hsync,
    output        vsync,
    output        video_on,
    output [11:0] vga_data     // 16位RGB565输出
);

    // VGA控制器信号
    wire [9:0] x, y;
    wire hsync_raw, vsync_raw, video_on_raw;

    vga_controller vga_inst(
        .clk(clk),
        .rst(rst),
        .hsync(hsync_raw),
        .vsync(vsync_raw),
        .x(x),
        .y(y),
        .video_on(video_on_raw)
    );

    // BRAM地址，线性映射
    assign bram_addr = video_on_raw ? (y * 640 + x) : 19'd0;

    // 延迟1拍，同步BRAM输出与同步信号
    reg        hsync_d, vsync_d, video_on_d;
    reg [11:0] vga_data_d;

    always @(posedge clk) begin
        hsync_d     <= hsync_raw;
        vsync_d     <= vsync_raw;
        video_on_d  <= video_on_raw;
        vga_data_d  <=  
        { bram_data[15:12],    // R[4:1]
          bram_data[10:7],     // G[5:2]
          bram_data[4:1]       // B[4:1]
        };
    end

    // 输出对齐延迟后信号
    assign hsync    = hsync_d;
    assign vsync    = vsync_d;
    assign video_on = video_on_d;
    assign vga_data = video_on_d ? vga_data_d : 11'd0;

endmodule