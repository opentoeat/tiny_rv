module key_debounce(
    input  wire clk,        // 时钟信号
    input  wire rst_n,      // 复位信号，低有效
    input  wire key_in,     // 原始按键信号（低电平有效）
    output reg  key_state  // 消抖后的稳定按键状态（低有效）
);
    parameter N = 20;
    reg [N-1:0] cnt;
    reg key_in_d0, key_in_d1;
    wire key_edge;

    reg key_down;
    reg key_up;
    // 输入同步
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key_in_d0 <= 1'b1;
            key_in_d1 <= 1'b1;
        end else begin
            key_in_d0 <= key_in;
            key_in_d1 <= key_in_d0;
        end
    end

    // 边沿检测
    assign key_edge = (key_in_d1 != key_state);

    // 消抖计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            key_state <= 1'b1;
        end else if (key_edge) begin
            cnt <= cnt + 1'b1;
            if (cnt == {N{1'b1}})
                key_state <= key_in_d1;
        end else begin
            cnt <= 0;
        end
    end

    // 产生消抖后的脉冲信号
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key_down <= 0;
            key_up   <= 0;
        end else begin
            key_down <= (key_state == 1'b1) && (key_in_d1 == 1'b0); // 按下
            key_up   <= (key_state == 1'b0) && (key_in_d1 == 1'b1); // 松开
        end
    end

endmodule