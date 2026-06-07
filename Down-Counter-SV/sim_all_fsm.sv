`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 23:27:33
// Design Name: 
// Module Name: sim_all_fsm
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

module sim_all_fsm();

logic clk;
logic pause;
logic load;
logic [15:0] in;

logic [6:0] seg;
logic [3:0] an;

top uut (
    .clk(clk),
    .pause(pause),
    .load(load),
    .in(in),
    .seg(seg),
    .an(an)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
pause = 0;
load = 0;
in = 16'h4321; 

#20;
@(posedge clk);
load = 1;
@(posedge clk);
load = 0;
#20;

    @(posedge clk);
    force uut.clk_enable = 1;
    @(posedge clk);
    release uut.clk_enable; 
    uut.clk_enable = 0;

    @(posedge clk);
    force uut.clk_enable = 1;
    @(posedge clk);
    release uut.clk_enable;
    uut.clk_enable = 0;

    #50;
    pause = 1; #20; pause = 0; 
    #500;
    $finish;
end

endmodule