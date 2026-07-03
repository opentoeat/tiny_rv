`timescale 1ns / 1ps
// 多周期恢复除法器（32 周期）
// 支持 DIV/DIVU/REM/REMU，含 RISC-V 除零/溢出语义
// 启动时锁存 is_rem/is_signed/a[31]（CALC 期间输入可能变）
module div_unit(
    input        clk,
    input        rst_n,
    input  [31:0] a,          // 被除数
    input  [31:0] b,          // 除数
    input        start,       // 启动（IDLE 且未 launched 时有效）
    input        is_signed,   // DIV/REM=1, DIVU/REMU=0
    input        is_rem,      // REM/REMU=1, DIV/DIVU=0
    output reg [31:0] result,
    output       busy
);
    localparam IDLE=2'd0, CALC=2'd1, FINI=2'd2;
    reg [1:0]  state;
    reg [5:0]  cnt;
    reg [31:0] rem, quot, divisor_r;
    reg        sign_q;         // 商符号（有符号）
    reg        launched;       // 启动锁存（防 IDLE 重启）
    reg        is_rem_r, is_signed_r, a_neg_r;   // 启动时锁存

    assign busy = (state != IDLE);

    wire [31:0] abs_a = (is_signed && a[31]) ? (~a + 32'd1) : a;
    wire [31:0] abs_b = (is_signed && b[31]) ? (~b + 32'd1) : b;

    // 恢复除法一步：移位 + 试减
    wire [32:0] shifted = {rem, quot[31]};
    wire [32:0] sub_val = shifted - {1'b0, divisor_r};
    wire        qbit    = ~sub_val[32];                 // 够减=1，不够减=0（恢复）

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE; result <= 32'd0; rem <= 32'd0; quot <= 32'd0;
            divisor_r <= 32'd0; cnt <= 6'd0; sign_q <= 1'b0; launched <= 1'b0;
            is_rem_r <= 1'b0; is_signed_r <= 1'b0; a_neg_r <= 1'b0;
        end
        else case(state)
            IDLE: begin
                if(!start)        launched <= 1'b0;     // start 回 0 解锁
                else if(!launched) begin
                    launched    <= 1'b1;
                    is_rem_r    <= is_rem;              // 锁存
                    is_signed_r <= is_signed;
                    a_neg_r     <= a[31];
                    if(b == 32'd0) begin
                        result <= is_rem ? a : 32'hFFFFFFFF;   // 除零：商-1，余数=被除数
                        state  <= IDLE;   // 直接回 IDLE（不进 FINI，避免被 quot/rem 覆盖）
                    end
                    else if(is_signed && a==32'h80000000 && b==32'hFFFFFFFF) begin
                        result <= is_rem ? 32'd0 : 32'h80000000;  // 溢出
                        state  <= IDLE;
                    end
                    else begin
                        rem       <= 32'd0;
                        quot      <= abs_a;
                        divisor_r <= abs_b;
                        sign_q    <= is_signed && (a[31] ^ b[31]);
                        cnt       <= 6'd0;
                        state     <= CALC;
                    end
                end
            end
            CALC: begin
                rem  <= qbit ? sub_val[31:0] : shifted[31:0];
                quot <= {quot[30:0], qbit};
                cnt  <= cnt + 6'd1;
                if(cnt == 6'd31) state <= FINI;
            end
            FINI: begin
                // 余数符号同被除数；商符号按 sign_q（用锁存值）
                if(is_rem_r)
                    result <= (is_signed_r && a_neg_r) ? (~rem + 32'd1) : rem;
                else
                    result <= sign_q ? (~quot + 32'd1) : quot;
                state <= IDLE;
            end
        endcase
    end
endmodule
