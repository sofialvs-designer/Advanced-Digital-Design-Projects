`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 17:31:20
// Design Name: 
// Module Name: sim_fsm2
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

module sim_fsm2();

    logic clk, load, pause_reg, finish;
    logic clk_enable_10Hz; 
    
    logic [3:0] in1;
    logic [3:0] BCD_1;
    logic inc_to_fsm2; 

    logic [3:0] in2;
    logic [3:0] BCD_2;
    logic inc_to_fsm3; 

    FSM_1 fsm_decimas (
        .clk(clk),
        .clk_enable(clk_enable_10Hz),
        .load(load),
        .in(in1),
        .pause_reg(pause_reg),
        .finish(finish),
        .BCD_1(BCD_1),
        .inc_1(inc_to_fsm2) 
    );

    FSM_2 fsm_segundos (
        .clk(clk),
        .clk_enable(inc_to_fsm2&& clk_enable_10Hz), 
        .load(load),
        .in(in2),
        .pause_reg(pause_reg),
        .finish(finish),
        .BCD_2(BCD_2),
        .inc_2(inc_to_fsm3)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

initial begin
    load = 0; pause_reg = 0; finish = 0; clk_enable_10Hz = 0;
    in1 = 4'd1; in2 = 4'd5;
    #20;

    @(posedge clk);
    load <= 1; 
    @(posedge clk);
    load <= 0;
    
    repeat(10) @(posedge clk); 

    @(posedge clk);
    clk_enable_10Hz <= 1;
    @(posedge clk);
    clk_enable_10Hz <= 0; 
    
    repeat(10) @(posedge clk);

    @(posedge clk);
    clk_enable_10Hz <= 1;
    @(posedge clk);
    clk_enable_10Hz <= 0; 

    #200;
    $finish;
end
endmodule