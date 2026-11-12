# 16-Bit Microprogrammed CPU for Artix-7

A three-person computer organization course project. The CPU uses a 16-bit data path, 256 × 16-bit memory and a 32-bit microinstruction control word. The original project exercised 13 instructions in simulation and displayed the sum from 1 to 100 (5050) on a seven-segment display on Artix-7.

The RTL is split into the accumulator, ALU, data path registers, program counter, microprogram controller and control ROM, RAM, and display logic. The RAM includes the demonstration program. CPU.xdc targets the HX7A75C board configuration with a 50 MHz clock.

| Path | Contents |
| --- | --- |
| rtl/ | Complete CPU and display source |
| constraints/CPU.xdc | Artix-7 pinout and clock constraint |
| sim/cpu_tb.v | Original waveform-oriented testbench |
| create_project.tcl | Recreates the Vivado project from source |

## Open the project

In Vivado 2023.2, run source create_project.tcl from the Vivado Tcl Console after changing to the repository directory. The script creates build/microprogrammed_cpu.xpr for xc7a75tfgg484-2. Launch Behavioral Simulation with cpu_tb as the simulation top. The original bench pauses at $stop. Inspect u_cpu_top and the memory waveforms for execution results.

For board use, select cpu_top as the synthesis top, build the bitstream, and program the matching HX7A75C board. Keep reset active while starting and release it to run. Other boards need their own pin assignments and clock constraints.
