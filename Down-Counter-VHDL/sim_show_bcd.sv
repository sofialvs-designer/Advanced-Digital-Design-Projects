`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.04.2026 09:13:58
// Design Name: 
// Module Name: sim_show_bcd
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
module sim_show_bcd();

    logic clk, load, finish;
    logic show_out;
    logic [3:0] bcd_test;
    logic [6:0] segments;

    show dut_show (
        .clk(clk),
        .finish(finish),
        .load(load),
        .clk_enable(1'b0),
        .show(show_out)
    );

    BCD_7seg dut_decoder (
        .BCD(bcd_test),
        .show(show_out),
        .seven_seg(segments)
    );

    initial begin
        clk = 0;
        forever#5 clk = ~clk;
    end

    initial begin

        load = 0; 
        finish = 0; 
        bcd_test = 4'h5;
        #20;

        load = 1; #10; load = 0;
        #20; 

        finish = 1;
        #20;

        force dut_show.timer = 1; 
        #10;
        release dut_show.timer;

        #50;
        $finish;
    end

endmodule