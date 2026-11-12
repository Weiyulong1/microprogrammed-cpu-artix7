`timescale 1ns / 1ps

//测试
module MAR (
    input clk,
    input c5,//控制信号
    input c10,
    input reset,
    input [7:0]PC_2_MAR,//PC导入MAR
    input [7:0]MBR_2_MAR,//MBR导入MAR
    output [7:0]MAR_out
);
reg [7:0]MAR_out_reg;
always @(posedge clk )
begin
    if(!reset)
        MAR_out_reg<=8'b00000000;
    else if(c10==1)
        MAR_out_reg<=PC_2_MAR;
    else if(c5==1)
        MAR_out_reg<=MBR_2_MAR;
end
assign MAR_out=MAR_out_reg;
    
endmodule
