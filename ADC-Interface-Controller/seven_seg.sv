`timescale 1ns / 1ps

// este es el modulo que realmente toma el numero en BCD y lo pasa a 7 segmentos
module seven_seg (
	input logic clk,
	input logic [3:0] in,
	output logic [6:0] seg
);

	always_ff @(posedge clk) begin
		case (in)
			4'h0: seg <= 7'b1000000;
			4'h1: seg <= 7'b1111001;
			4'h2: seg <= 7'b0100100;
			4'h3: seg <= 7'b0110000;
			4'h4: seg <= 7'b0011001;
			4'h5: seg <= 7'b0010010;
			4'h6: seg <= 7'b0000010;
			4'h7: seg <= 7'b1111000;
			4'h8: seg <= 7'b0000000;
			4'h9: seg <= 7'b0010000;
		endcase
	end
endmodule

