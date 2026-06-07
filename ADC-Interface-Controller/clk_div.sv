`timescale 1ns / 1ps

module clk_gen #(parameter CLKDIV = 8)
(
	input logic clk_in,
	output logic clk_out
);

logic mmcm2_clk_fb, locked_1;

MMCME2_BASE #(
	.BANDWIDTH("OPTIMIZED"),
	.CLKFBOUT_MULT_F(10.0),
	.CLKFBOUT_PHASE(0.0),
	.CLKIN1_PERIOD(10),
	.CLKOUT0_DIVIDE_F(CLKDIV),
	.CLKOUT0_DUTY_CYCLE(0.5),
	.CLKOUT0_PHASE(0.0),
	.DIVCLK_DIVIDE(1),
	.REF_JITTER1(0.0),
	.STARTUP_WAIT("FALSE")
)
MMCME2_BASE_inst (
	.CLKOUT0 (clk_out),
	.CLKFBOUT (mmcm2_clk_fb),
	.LOCKED (locked_1),
	.CLKIN1 (clk_in),
	.PWRDWN (1'b0),
	.RST (1'b0),
	.CLKFBIN (mmcm2_clk_fb)
);

endmodule
