`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2026 23:29:12
// Design Name: 
// Module Name: FSM_4
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

// FSM minutos
module FSM_4(
    input logic clk, 
    input logic clk_enable, 
    input logic load, 
    input logic [3:0] in, 
    input logic pause_reg, 
    input logic finish,
    output logic [3:0] BCD_4
);

typedef enum logic [3:0] {S0, S1, S2, S3, S4, S5, S6, S7, S8, S9} state_t;
state_t S, NextS;


always_ff @(posedge clk) begin
    if (load) 
        S <= state_t'(in);
    else if (clk_enable && !pause_reg && !finish) 
        S <= NextS;

end

assign BCD_4 = S;

always_comb begin
    unique case(S)
        S9: NextS = S8;
        S8: NextS = S7;
        S7: NextS = S6;
        S6: NextS = S5;
        S5: NextS = S4;
        S4: NextS = S3;
        S3: NextS = S2;
        S2: NextS = S1;
        default: NextS = S0;
    endcase
end

endmodule
