`timescale 1ns / 1ps

module cpu_top(
    input clk,
    input reset,
    input key_next_n,
    output [7:0] SSEG_CA,
    output [7:0] SSEG_AN
    );

reg clk_div=0;
reg [1:0] count1=0;
//分频
always @(posedge clk) begin
    count1=count1+1;
    if(count1>1) begin
        count1=0;
        clk_div=~clk_div;
    end
end
    

wire [2:0]flag;
wire [7:0]MAR_out;
wire [15:0]ACC_out;
wire [15:0]memory_out;
wire [15:0]MBR_out;
wire [7:0]PC_out;
wire [7:0]IR_out;
wire [15:0]BR_out;
wire [15:0]ALU_out;
wire [15:0]MR;
wire [31:0]CU_out;
reg [15:0] display_data;
reg [15:0] result_buf [0:11];
reg [3:0] display_idx;
reg result_ready;
reg c12_d;
wire key_next_pulse;
integer k;

always @(posedge clk or negedge reset) begin
    if(!reset) begin
        display_data <= 16'd0;
        display_idx  <= 4'd0;
        result_ready <= 1'b0;
        c12_d        <= 1'b0;

        for(k = 0; k < 12; k = k + 1) begin
            result_buf[k] <= 16'd0;
        end
    end
    else begin
        // 记录上一拍的 C12
        c12_d <= CU_out[12];
        // C12 = 1 表示 MEMORY <= MBR
        // 表示一次新的写 RAM 动作
        if(CU_out[12] && !c12_d) begin
            // 求和过程中，每次 STORE A0 时，实时显示当前 sum
            if(MAR_out == 8'hA0 && !result_ready) begin
                display_data <= MBR_out;
            end
            // 写入时同步保存到 result_buf
            if(MAR_out >= 8'hB0 && MAR_out <= 8'hBB) begin
                result_buf[MAR_out[3:0]] <= MBR_out;
                if(MAR_out == 8'hB0) begin
                    display_data <= MBR_out;
                    display_idx  <= 4'd0;
                end
                if(MAR_out == 8'hBB) begin
                    result_ready <= 1'b1;
                    display_idx  <= 4'd0;
                end
            end
        end
        // 所有结果准备好后，每按一次键，显示下一个结果
        if(result_ready && key_next_pulse) begin
            if(display_idx < 4'd11) begin
                display_data <= result_buf[display_idx + 4'd1];
                display_idx  <= display_idx + 4'd1;
            end
            else begin
                display_data <= result_buf[4'd11];
                display_idx  <= 4'd11;
            end
        end
    end
end



key_debounce u_key_next(
    .clk(clk),
    .rst_n(reset),
    .key_n(key_next_n),
    .key_pulse(key_next_pulse)
);

ram u_ram(
    .clk(clk),
    .reset(reset),
    .mbr_in(MBR_out),
    .mar_in(MAR_out),
    .c12(CU_out[12]),
    .ram_out(memory_out)
    );


MAR u_MAR(
    .clk(clk_div),
    .c5(CU_out[5]),//控制信号
    .c10(CU_out[10]),
    .reset(reset),
    .PC_2_MAR(PC_out),//PC导入MAR
    .MBR_2_MAR(MBR_out[7:0]),//MBR输出地址
    .MAR_out(MAR_out)
);

MBR u_MBR(
.acc_in(ACC_out),
.memory_in(memory_out),
.reset(reset),
.c3(CU_out[3]),
.c11(CU_out[11]),
.clk(clk_div),
.mbr_out(MBR_out)
);

PC u_PC(
.clk(clk_div),
.reset(reset),
.c6(CU_out[6]),
.c14(CU_out[14]),
.MBR_in(MBR_out[7:0]),
.PC_out(PC_out)
    );

IR u_IR(
.clk(clk_div),
.reset(reset),
.c4(CU_out[4]),
.MBR_in(MBR_out[15:8]),
.IR_out(IR_out)
    );

//ACC
ACC u_ACC(
.clk(clk_div),
.c8(CU_out[8]),
.c23(CU_out[23]),
.c25(CU_out[25]),
.reset(reset),
.ALU_in(ALU_out),
.MBR_in(MBR_out),
.ACC_out(ACC_out),
.flag0(flag[0]),
.flag2(flag[2])
);

ControlUnit u_CU(
    .clk(clk_div),
    .clk_rom(clk),
    .reset(reset),
    .IR_in(IR_out),
    .c(CU_out),
    .flag(flag),//flag0:正负1乘法完成2操作完成
    .c_out(CU_out)
);

BR u_BR(
    .clk(clk_div),
    .reset(reset),
    .c7(CU_out[7]),
    .MBR_in(MBR_out),
    .BR_out(BR_out)
);

ALU u_ALU(
    .clk(clk_div),
    .reset(reset),
    .c_in(CU_out),
    .ACC_in(ACC_out),
    .BR_in(BR_out),
    .flag1(flag[1]),
    .MR(MR),
    .ALU_out(ALU_out)
);

LED u_LED(
    .clk(clk),
    .rst_n(reset),
    .data(display_data),
    .SSEG_AN(SSEG_AN),
    .SSEG_CA(SSEG_CA)
);

endmodule
