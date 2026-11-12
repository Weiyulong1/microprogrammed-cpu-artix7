`timescale 1ns / 1ps

module ROM_cu(
    input [7:0] address,
    input clk,
    output [31:0] c_out
    );
    (* rom_style = "block" *) reg [31:0] rom [0:255];
    reg [31:0] c_out_reg = 32'h00000000;
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            rom[i] = 32'h00000002;
        end

        // FETCH: 00h - 03h
        rom[8'h00] = 32'h00000401;
        rom[8'h01] = 32'h00000009;
        rom[8'h02] = 32'h00000011;
        rom[8'h03] = 32'h00000002;

        // LOAD: 08h - 0Ah
        rom[8'h08] = 32'h00000061;
        rom[8'h09] = 32'h00000009;
        rom[8'h0A] = 32'h02000004;

        // STORE: 10h - 12h
        rom[8'h10] = 32'h00000061;
        rom[8'h11] = 32'h00000801;
        rom[8'h12] = 32'h00001004;

        // ADD: 18h - 1Dh
        rom[8'h18] = 32'h00000061;
        rom[8'h19] = 32'h00000009;
        rom[8'h1A] = 32'h00000081;
        rom[8'h1B] = 32'h00600001;
        rom[8'h1C] = 32'h00000201;
        rom[8'h1D] = 32'h00800004;

        // SUB: 20h - 25h
        rom[8'h20] = 32'h00000061;
        rom[8'h21] = 32'h00000009;
        rom[8'h22] = 32'h00000081;
        rom[8'h23] = 32'h00600001;
        rom[8'h24] = 32'h00002001;
        rom[8'h25] = 32'h00800004;

        // AND: 28h - 2Dh
        rom[8'h28] = 32'h00000061;
        rom[8'h29] = 32'h00000009;
        rom[8'h2A] = 32'h00000081;
        rom[8'h2B] = 32'h00600001;
        rom[8'h2C] = 32'h00008001;
        rom[8'h2D] = 32'h00800004;

        // OR: 30h - 35h
        rom[8'h30] = 32'h00000061;
        rom[8'h31] = 32'h00000009;
        rom[8'h32] = 32'h00000081;
        rom[8'h33] = 32'h00600001;
        rom[8'h34] = 32'h00010001;
        rom[8'h35] = 32'h00800004;

        // NOT: 38h - 3Dh
        rom[8'h38] = 32'h00000061;
        rom[8'h39] = 32'h00000009;
        rom[8'h3A] = 32'h02000001;
        rom[8'h3B] = 32'h00400001;
        rom[8'h3C] = 32'h00020001;
        rom[8'h3D] = 32'h00800004;

        // SHR: 40h - 42h
        rom[8'h40] = 32'h00400041;
        rom[8'h41] = 32'h00080001;
        rom[8'h42] = 32'h00800004;

        // SHL: 48h - 4Ah
        rom[8'h48] = 32'h00400041;
        rom[8'h49] = 32'h00040001;
        rom[8'h4A] = 32'h00800004;

        // MPY: 50h - 56h
        rom[8'h50] = 32'h00000061;
        rom[8'h51] = 32'h00000009;
        rom[8'h52] = 32'h00000081;
        rom[8'h53] = 32'h00600001;
        rom[8'h54] = 32'h0C000000;
        rom[8'h55] = 32'h01000001;
        rom[8'h56] = 32'h00800004;

        // JMP: 58h
        rom[8'h58] = 32'h00004004;

        // JMPGEZ: 60h - 62h
        rom[8'h60] = 32'h00100000;
        rom[8'h61] = 32'h00004004;
        rom[8'h62] = 32'h00000044;

        // HALT: 68h
        rom[8'h68] = 32'h00000004;
    end

    always @(posedge clk) begin
        c_out_reg <= rom[address];
    end

    assign c_out = c_out_reg;

endmodule
