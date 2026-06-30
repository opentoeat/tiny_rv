module clock_buffer (
    input clk_in,
    output clk_out
);

    // 使用 IBUF 缓冲输入时钟
    IBUF ibuf_inst (
        .I(clk_in),
        .O(clk_out)
    );

endmodule