`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2026 23:16:57
// Design Name: 
// Module Name: FSM_3
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


module FSM_3(
    input logic clk, 
    input logic clk_enable, 
    input logic load, 
    input logic [3:0] in, 
    input logic pause_reg, 
    input logic finish,
    output logic [3:0] BCD_3, 
    output logic inc_3
);

typedef enum logic [3:0] {S0, S1, S2, S3, S4, S5} state_t;
state_t S, NextS;

always_ff @(posedge clk) begin
    if (load) begin
        S <= state_t'(in);
    end
    else if (clk_enable && !pause_reg && !finish) begin
        S <= NextS;
    end
end

assign BCD_3 = S;
assign inc_3 = (S == S0);

always_comb begin
    unique case(S)
        S0: NextS = S5;
        S1: NextS = S0;
        S2: NextS = S1;
        S3: NextS = S2;
        S4: NextS = S3;
        S5: NextS = S4;
        default: NextS = S0;
    endcase
end

endmodule