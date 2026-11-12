module LED(
    input clk,
    input rst_n,
    input [15:0] data,
    output reg [7:0] SSEG_AN,
    output reg [7:0] SSEG_CA
);

reg [15:0] div_cnt;
reg [1:0] scan;
reg [3:0] data_1;

reg sign;
reg [15:0] abs_data;
reg [19:0] bcd;
integer i;

// 16位补码转绝对值
always @(*) begin
    sign = data[15];

    if(data[15])
        abs_data = (~data) + 16'd1;
    else
        abs_data = data;
end

// 二进制转 BCD
always @(*) begin
    bcd = 20'd0;

    for(i = 15; i >= 0; i = i - 1) begin
        if(bcd[3:0] >= 5)
            bcd[3:0] = bcd[3:0] + 3;

        if(bcd[7:4] >= 5)
            bcd[7:4] = bcd[7:4] + 3;

        if(bcd[11:8] >= 5)
            bcd[11:8] = bcd[11:8] + 3;

        if(bcd[15:12] >= 5)
            bcd[15:12] = bcd[15:12] + 3;

        if(bcd[19:16] >= 5)
            bcd[19:16] = bcd[19:16] + 3;

        bcd = {bcd[18:0], abs_data[i]};
    end
end

// 扫描分频
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        div_cnt <= 16'd0;
    else if(div_cnt == 16'd49999)
        div_cnt <= 16'd0;
    else
        div_cnt <= div_cnt + 1'b1;
end

// 4位扫描
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        scan <= 2'd0;
    else if(div_cnt == 16'd49999)
        scan <= scan + 1'b1;
end

// 位选：低电平有效
always @(*) begin
    SSEG_AN = 8'b1111_1111;
    data_1  = 4'h0;

    case(scan)
        2'd0: begin
            SSEG_AN = 8'b1111_1110;
            if(sign)
                data_1 = 4'hA;       // A 在下面定义为负号
            else
                data_1 = bcd[15:12]; // 千位
        end

        2'd1: begin
            SSEG_AN = 8'b1111_1101;
            data_1  = bcd[11:8];     // 百位
        end

        2'd2: begin
            SSEG_AN = 8'b1111_1011;
            data_1  = bcd[7:4];      // 十位
        end

        2'd3: begin
            SSEG_AN = 8'b1111_0111;
            data_1  = bcd[3:0];      // 个位
        end

        default: begin
            SSEG_AN = 8'b1111_1111;
            data_1  = 4'h0;
        end
    endcase
end

// 段选：低电平点亮
always @(*) begin
    case(data_1)
        4'd0: SSEG_CA = 8'hc0;
        4'd1: SSEG_CA = 8'hf9;
        4'd2: SSEG_CA = 8'ha4;
        4'd3: SSEG_CA = 8'hb0;
        4'd4: SSEG_CA = 8'h99;
        4'd5: SSEG_CA = 8'h92;
        4'd6: SSEG_CA = 8'h82;
        4'd7: SSEG_CA = 8'hf8;
        4'd8: SSEG_CA = 8'h80;
        4'd9: SSEG_CA = 8'h90;

        4'hA: SSEG_CA = 8'hbf;       // 负号 "-"
        4'hF: SSEG_CA = 8'hff;       // 空白

        default: SSEG_CA = 8'hff;
    endcase
end

endmodule
