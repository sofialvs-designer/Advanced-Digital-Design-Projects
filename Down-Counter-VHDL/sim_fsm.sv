`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.04.2026 09:22:27
// Design Name: 
// Module Name: sim_fsm
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

module sim_fsm();

logic clk, clk_enable, load, pause_reg, finish;
logic [3:0] BCD_1;
logic [3:0] in;

FSM_1 fsm1 (.BCD_1(BCD_1), .in(in), .load(load), .clk(clk), .clk_enable(clk_enable), .pause_reg(pause_reg), .finish(finish));

initial begin
clk= 0;
forever#5 clk= ~clk;
end

initial begin

    in = 4'b0101; load = 0; pause_reg = 0; finish = 0; clk_enable = 0;

    repeat(2) @(posedge clk);
    load = 1;
    @(posedge clk); 
    load = 0;

    repeat(3) begin 
        @(posedge clk);
        clk_enable = 1; 
        @(posedge clk);
        clk_enable = 0;
    end

    pause_reg = 1;
    
    #100 $finish;
end
endmodule: sim_fsm
