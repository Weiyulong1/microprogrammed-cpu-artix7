`timescale 1ns / 1ps

module key_debounce #(
    parameter DEBOUNCE_MAX = 20'd999_999   // 50MHz 下约 20ms
)(
    input clk,
    input rst_n,
    input key_n,          // 按键输入，低电平表示按下
    output reg key_pulse  // 每按下一次，输出一个 clk 周期的高脉冲
);

reg [1:0] key_sync;
reg key_state;
reg [19:0] cnt;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        key_sync  <= 2'b11;
        key_state <= 1'b1;
        cnt       <= 20'd0;
        key_pulse <= 1'b0;
    end
    else begin
        key_sync <= {key_sync[0], key_n};
        key_pulse <= 1'b0;

        if(key_sync[1] == key_state) begin
            cnt <= 20'd0;
        end
        else begin
            if(cnt == DEBOUNCE_MAX) begin
                cnt <= 20'd0;
                key_state <= key_sync[1];
                // 检测到稳定的按下动作
                if(key_sync[1] == 1'b0) begin
                    key_pulse <= 1'b1;
                end
            end
            else begin
                cnt <= cnt + 1'b1;
            end
        end
    end
end

endmodule
