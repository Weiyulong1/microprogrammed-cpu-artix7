`timescale 1ns / 1ps

module MBR(
input [15:0] acc_in,memory_in,
input c3,
input c11,
input clk,
input reset,
output [15:0] mbr_out
);
reg [15:0]mbr_out_reg;
always @(posedge clk)
    if(!reset)
        mbr_out_reg<=0;
    else if(clk==1) begin
      if(c3==1) begin
         mbr_out_reg<=memory_in;
      end
      else if (c11==1) begin
        mbr_out_reg<=acc_in;
       end
    end
assign mbr_out=mbr_out_reg;
endmodule
