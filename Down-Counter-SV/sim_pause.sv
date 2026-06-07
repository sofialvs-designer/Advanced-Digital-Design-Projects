`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.04.2026 10:30:47
// Design Name: 
// Module Name: sim_pause
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


module sim_pause();

logic enable, clk, pause_reg;

pause pause(.*);

initial begin

    clk= 0;
    forever#5 clk= ~clk; // se crea la señal base de 100 MHZ
end

// se generan los valores para enable, determina si se pausa o no la señal

 initial begin
    enable = 0;
    repeat(5) @(posedge clk); // Espera inicial de 5 ciclos

    // Simulamos presionar el botón 2 veces
    repeat(2) begin
        enable = 1;           
        @(posedge clk);      
        enable = 0;         
        repeat(10) @(posedge clk); 
    end
    $finish;
end
endmodule: sim_pause