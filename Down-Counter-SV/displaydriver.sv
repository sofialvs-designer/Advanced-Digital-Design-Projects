
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2022 05:16:24 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module clockDivider(
	input logic clk,
	output divClk
);

parameter TC = 2000;
localparam nBits= $clog2(TC) + 1;  // $clog2 calcula el techo del log2 del argumento
                                   // El " + 1" es para permitir dividir por 2

logic [nBits-1: 0] counter = 0;    // " + 1" garantiza un registro de minimo 2 bits
assign divClk = (counter == TC - 1);
always_ff @(posedge clk)
	if (divClk)
		counter<= 0;
	else
		counter<= counter+ 1;

endmodule: clockDivider





module displayDriver (
	input logic clk,
	input logic[27:0] inSeg,
	output logic[3:0] anodes,
	output logic[6:0] outSeg
);

logic divClk;

// instancia del modulo anterior, que entrega un nuevo reloj a partir de clk original
clockDivider clk_div (
.clk (clk),
.divClk (divClk)
);
    
logic[1:0] displayCnt = 0;  // son 4 displays
logic[7:0] outComp;

always_ff @(posedge clk)
	if(divClk) displayCnt<= displayCnt+ 1;
        
always_comb
	case (displayCnt)
		2'd0: begin
			anodes = 4'b1110; //14
			outSeg= inSeg[6:0];
		end
		2'd1: begin
			anodes= 4'b1101; //13
			outSeg= inSeg[13:7];
		end
		2'd2: begin
			anodes= 4'b1011; //11
			outSeg= inSeg[20:14];
		end
		2'd3: begin
			anodes= 4'b0111; //7
			outSeg= inSeg[27:21];
		end
	endcase

endmodule: displayDriver



