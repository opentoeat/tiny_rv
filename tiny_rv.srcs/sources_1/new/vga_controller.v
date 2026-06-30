module vga_controller(
    input            clk,       // 输入时钟，建议25.175MHz
    input            rst,       // 同步复位
    output reg       hsync,     // 行同步信号
    output reg       vsync,     // 场同步信号
    output reg [9:0] x,         // 当前像素横坐标（0~639）
    output reg [9:0] y,         // 当前像素纵坐标（0~479）
    output           video_on   // 有效显示区域指示
);

// VGA 640x480@60Hz Timing Parameters
parameter H_SYNC = 96;
parameter H_BACK = 48;
parameter H_DISP = 640;
parameter H_FRONT = 16;
parameter H_TOTAL = H_SYNC + H_BACK + H_DISP + H_FRONT;

parameter V_SYNC = 2;
parameter V_BACK = 33;
parameter V_DISP = 480;
parameter V_FRONT = 10;
parameter V_TOTAL = V_SYNC + V_BACK + V_DISP + V_FRONT;

// 行列计数器
reg [9:0] h_cnt;
reg [9:0] v_cnt;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        h_cnt <= 0;
        v_cnt <= 0;
    end else begin
        if (h_cnt == H_TOTAL - 1) begin
            h_cnt <= 0;
            if (v_cnt == V_TOTAL - 1)
                v_cnt <= 0;
            else
                v_cnt <= v_cnt + 1;
        end else begin
            h_cnt <= h_cnt + 1;
        end
    end
end

// 生成同步信号
always @(posedge clk) begin
    hsync <= (h_cnt < H_SYNC) ? 0 : 1;
    vsync <= (v_cnt < V_SYNC) ? 0 : 1;
end

// 生成当前像素坐标
always @(posedge clk) begin
    if (h_cnt >= H_SYNC + H_BACK && h_cnt < H_SYNC + H_BACK + H_DISP)
        x <= h_cnt - (H_SYNC + H_BACK);
    else
        x <= 10'd0;

    if (v_cnt >= V_SYNC + V_BACK && v_cnt < V_SYNC + V_BACK + V_DISP)
        y <= v_cnt - (V_SYNC + V_BACK);
    else
        y <= 10'd0;
end

// 有效显示区域
assign video_on = (h_cnt >= H_SYNC + H_BACK) && (h_cnt < H_SYNC + H_BACK + H_DISP) &&
                  (v_cnt >= V_SYNC + V_BACK) && (v_cnt < V_SYNC + V_BACK + V_DISP);

endmodule