`timescale 1ns / 1ps

module ram(
    input clk,
    input reset,              
    input [15:0] mbr_in,
    input [7:0] mar_in,
    input c12,
    output [15:0] ram_out
    );

    (* ram_style = "block" *) reg [15:0] mem [0:255];
    reg [15:0] ram_out_reg = 16'h0000;
    reg wea_reg = 1'b0;

integer init_i;

initial begin
    // 把 RAM 全部清零
    for(init_i = 0; init_i < 256; init_i = init_i + 1) begin
        mem[init_i] = 16'h0000;
    end
    // 复位后初始化区
    mem[8'h00] = 16'h02A8;  // LOAD  A8   ACC = 0
    mem[8'h01] = 16'h01A0;  // STORE A0   sum = 0

    mem[8'h02] = 16'h02A2;  // LOAD  A2   ACC = 1
    mem[8'h03] = 16'h01A1;  // STORE A1   i = 1
    // 主循环：sum = 1 + 2 + ... + 100
    mem[8'h04] = 16'h02A0;  // LOAD  A0   ACC = sum
    mem[8'h05] = 16'h03A1;  // ADD   A1   ACC = sum + i
    mem[8'h06] = 16'h01A0;  // STORE A0   sum = sum + i，同时显示锁存
    
    

    // 延时循环
    
    mem[8'h07] = 16'h0613;  // JMP 13，跳过延时段

    //mem[8'h07] = 16'h02A6;  // LOAD  A6   ACC = outer_init



    mem[8'h08] = 16'h01A4;  // STORE A4   outer_cnt = outer_init
    mem[8'h09] = 16'h02A5;  // LOAD  A5   ACC = inner_init
    mem[8'h0A] = 16'h01A7;  // STORE A7   inner_cnt = inner_init
    mem[8'h0B] = 16'h02A7;  // LOAD  A7   ACC = inner_cnt
    mem[8'h0C] = 16'h04A2;  // SUB   A2   ACC = inner_cnt - 1
    mem[8'h0D] = 16'h01A7;  // STORE A7   inner_cnt = inner_cnt - 1
    mem[8'h0E] = 16'h050B;  // JMPGEZ 0B  if inner_cnt >= 0, continue inner loop
    mem[8'h0F] = 16'h02A4;  // LOAD  A4   ACC = outer_cnt
    mem[8'h10] = 16'h04A2;  // SUB   A2   ACC = outer_cnt - 1
    mem[8'h11] = 16'h01A4;  // STORE A4   outer_cnt = outer_cnt - 1
    mem[8'h12] = 16'h0509;  // JMPGEZ 09  if outer_cnt >= 0, repeat outer loop
    // i = i + 1
    mem[8'h13] = 16'h02A1;  // LOAD  A1   ACC = i
    mem[8'h14] = 16'h03A2;  // ADD   A2   ACC = i + 1
    mem[8'h15] = 16'h01A1;  // STORE A1   i = i + 1
    // 判断 i <= 100
    mem[8'h16] = 16'h02A3;  // LOAD  A3   ACC = 100
    mem[8'h17] = 16'h04A1;  // SUB   A1   ACC = 100 - i
    mem[8'h18] = 16'h0504;  // JMPGEZ 04  if 100 - i >= 0, loop
    // 保存 1+2+...+100 的最终结果
    // B0 = 5050 = 13BA
    mem[8'h19] = 16'h02A0;  // LOAD  A0
    mem[8'h1A] = 16'h01B0;  // STORE B0   B0 = 5050
    // 验证 5 + 6 = 11
    // B1 = 000B
    mem[8'h1B] = 16'h02D0;  // LOAD  D0   ACC = 5
    mem[8'h1C] = 16'h03D1;  // ADD   D1   ACC = 5 + 6
    mem[8'h1D] = 16'h01B1;  // STORE B1
    // 验证 5 - 6 = -1
    // B2 = FFFF
    mem[8'h1E] = 16'h02D0;  // LOAD  D0   ACC = 5
    mem[8'h1F] = 16'h04D1;  // SUB   D1   ACC = 5 - 6
    mem[8'h20] = 16'h01B2;  // STORE B2
    // 验证 5 * 6 = 30
    // B3 = 001E
    mem[8'h21] = 16'h02D0;  // LOAD  D0   ACC = 5
    mem[8'h22] = 16'h08D1;  // MPY   D1   ACC = 5 * 6
    mem[8'h23] = 16'h01B3;  // STORE B3
    // 验证 (-5) * 6 = -30
    // B4 = FFE2
    mem[8'h24] = 16'h02D2;  // LOAD  D2   ACC = -5
    mem[8'h25] = 16'h08D1;  // MPY   D1   ACC = -5 * 6
    mem[8'h26] = 16'h01B4;  // STORE B4
    // 验证 5 * (-6) = -30
    // B5 = FFE2
    mem[8'h27] = 16'h02D0;  // LOAD  D0   ACC = 5
    mem[8'h28] = 16'h08D3;  // MPY   D3   ACC = 5 * (-6)
    mem[8'h29] = 16'h01B5;  // STORE B5
    // 验证 (-5) * (-6) = 30
    // B6 = 001E
    mem[8'h2A] = 16'h02D2;  // LOAD  D2   ACC = -5
    mem[8'h2B] = 16'h08D3;  // MPY   D3   ACC = (-5) * (-6)
    mem[8'h2C] = 16'h01B6;  // STORE B6
    // 验证 5 & 6 = 4
    // B7 = 0004
    mem[8'h2D] = 16'h02D0;  // LOAD  D0   ACC = 5
    mem[8'h2E] = 16'h0AD1;  // AND   D1   ACC = 5 & 6
    mem[8'h2F] = 16'h01B7;  // STORE B7
    // 验证 5 | 6 = 7
    // B8 = 0007
    mem[8'h30] = 16'h02D0;  // LOAD  D0   ACC = 5
    mem[8'h31] = 16'h0BD1;  // OR    D1   ACC = 5 | 6
    mem[8'h32] = 16'h01B8;  // STORE B8
    // 验证 !6 = -7
    // B9 = FFF9
    mem[8'h33] = 16'h0CD1;  // NOT   D1   ACC = ~6
    mem[8'h34] = 16'h01B9;  // STORE B9
    // 验证 6 << 1 = 12
    // BA = 000C
    mem[8'h35] = 16'h02D1;  // LOAD  D1   ACC = 6
    mem[8'h36] = 16'h0E00;  // SHIFTL     ACC = 6 << 1
    mem[8'h37] = 16'h01BA;  // STORE BA
    // 验证 6 >> 1 = 3
    // BB = 0003
    mem[8'h38] = 16'h02D1;  // LOAD  D1   ACC = 6
    mem[8'h39] = 16'h0D00;  // SHIFTR     ACC = 6 >> 1
    mem[8'h3A] = 16'h01BB;  // STORE BB
    // 程序结束
    mem[8'h3B] = 16'h0700;  // HALT
    // 数据区：求和变量、延时变量、常数
    mem[8'hA0] = 16'h0000;  // sum，求和结果，同时作为显示锁存地址
    mem[8'hA1] = 16'h0001;  // i，当前加数
    mem[8'hA2] = 16'h0001;  // 常数 1
    mem[8'hA3] = 16'h0064;  // 常数 100

    mem[8'hA4] = 16'h0000;  // outer_cnt，外层延时计数器
    mem[8'hA5] = 16'h7FFF;  // inner_init，内层延时初值
    mem[8'hA6] = 16'h0001;  // outer_init，外层延时初值
    mem[8'hA7] = 16'h0000;  // inner_cnt，内层延时计数器
    mem[8'hA8] = 16'h0000;  // 常数 0，用于复位后初始化 sum
    // 测试用常数
    mem[8'hD0] = 16'h0005;  // 5
    mem[8'hD1] = 16'h0006;  // 6
    mem[8'hD2] = 16'hFFFB;  // -5，16位补码
    mem[8'hD3] = 16'hFFFA;  // -6，16位补码
    // 结果区 B0~BB
    // 程序运行后，这些地址会被 CPU 写入结果
    mem[8'hB0] = 16'h0000;  // 1+2+...+100
    mem[8'hB1] = 16'h0000;  // 5+6
    mem[8'hB2] = 16'h0000;  // 5-6
    mem[8'hB3] = 16'h0000;  // 5*6
    mem[8'hB4] = 16'h0000;  // (-5)*6
    mem[8'hB5] = 16'h0000;  // 5*(-6)
    mem[8'hB6] = 16'h0000;  // (-5)*(-6)
    mem[8'hB7] = 16'h0000;  // 5&6
    mem[8'hB8] = 16'h0000;  // 5|6
    mem[8'hB9] = 16'h0000;  // !6
    mem[8'hBA] = 16'h0000;  // 6<<1
    mem[8'hBB] = 16'h0000;  // 6>>1
end

    always @(posedge clk) begin
        if (wea_reg) begin
            mem[mar_in] <= mbr_in;
        end else begin
            ram_out_reg <= mem[mar_in];
        end

        wea_reg <= c12;
    end

    assign ram_out = ram_out_reg;

endmodule
