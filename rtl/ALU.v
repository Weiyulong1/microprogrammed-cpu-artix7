`timescale 1ns / 1ps

module ALU (
    input clk,
    input reset,
    input [31:0]c_in,
    input [15:0]ACC_in,
    input [15:0]BR_in,
    output flag1,
    output [15:0]MR,
    output [15:0]ALU_out
);
reg [15:0]ALU_out_reg;

wire signed [15:0] acc_s = ACC_in;
wire signed [15:0] br_s  = BR_in;
reg  signed [31:0] mult;
//reg [15:0]alu;
reg flag1_reg;
reg [15:0]MR_reg;


always@(posedge clk)
begin
    //alu<=ALU_out_reg;
    if(!reset)
    begin
        ALU_out_reg<=16'h0000;
        MR_reg<=0;
        flag1_reg<=0;
    end
    else begin
        flag1_reg <= 1'b0;
        if(c_in[21]==1)
            ALU_out_reg<=BR_in;
        else if(c_in[22]==1)
            ALU_out_reg<=ACC_in;
        else if(c_in[9]==1)//加法
            ALU_out_reg<=ACC_in+BR_in;
        else if(c_in[13]==1)//减法
            ALU_out_reg<=ACC_in-BR_in;
        else if(c_in[15]==1)//和
            ALU_out_reg<=ACC_in&BR_in;
        else if(c_in[16]==1)//或
            ALU_out_reg<=ACC_in|BR_in;
        else if(c_in[17]==1)
            ALU_out_reg <= ~ACC_in;
        else if(c_in[19]==1)//逻辑右移
            ALU_out_reg<={1'b0,ALU_out_reg[15:1]};
        else if(c_in[18]==1)//逻辑左移
            ALU_out_reg<={ALU_out_reg[14:0],1'b0};
        else if(c_in[24]==1)
        begin
            ALU_out_reg<=mult[15:0];
            MR_reg<=mult[31:16];
        end
        else if(c_in[26]==1)
        begin
        mult <= acc_s * br_s;
        flag1_reg <= 1'b1;
        end
    end
end
assign flag1=flag1_reg;
assign ALU_out=ALU_out_reg;
assign MR=MR_reg;
endmodule
