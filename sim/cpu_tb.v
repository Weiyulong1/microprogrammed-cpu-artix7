`timescale 1ns / 1ps

module cpu_tb();

reg	clk;
reg reset;
reg key_next_n;
wire [7:0] SSEG_CA;
wire [7:0] SSEG_AN;

localparam PERIOD = 10;	//100MHz

initial	
begin
	clk = 0;
	forever	#(PERIOD/2)	
	clk = ~clk;
end
//always #5 clk<=!clk;

cpu_top u_cpu_top(
    .clk(clk),
    .reset(reset),
    .key_next_n(key_next_n),
    .SSEG_CA(SSEG_CA),
    .SSEG_AN(SSEG_AN)
    );

initial
begin
    reset = 0;
    key_next_n = 1'b1;
    # (2*PERIOD)
    reset = 1;
    # 500000
    $stop;
end

endmodule
