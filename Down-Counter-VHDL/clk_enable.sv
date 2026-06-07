`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.04.2026 13:10:37
// Design Name: 
// Module Name: clk_enable
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

// el modulo clk_div, genera una señal de 10 HZ a partir de 100 MHZ
module clk_div(input logic clk,output logic clk_enable);
    logic [23:0] count=0; //se inicializa la cuenta en 0
    
    always_ff@(posedge clk) begin

       if(count==9999999) begin //en el primer ciclo, como el count es 0(no ha pasado ningun ciclo), se irá al else
          count<=0;
          clk_enable<=1;
       end else begin
          count<=count+1; //la cuenta comienza a incrementar, pero se ve reflejado el cambio en el sgnte ciclo de reloj
          clk_enable<=0; //se inicializa la señal en 0
       end

    end
endmodule

// en este caso la señal de pausa de rentrada está dada por button
module button_driver(input logic clk, button,output logic enable);

logic [19:0] counter;
logic clk_slow;
logic en_sync,en_1,en_2;


assign enable=(~en_2 && en_1);

always_ff @(posedge clk) begin    
    
    
    en_1<=en_sync;
    en_2<=en_1;
    
    if(counter==500001) begin //En este módulo, la nueva señal generada clk_slow, es de 1MHZ
        counter<=0;
        clk_slow<=~clk_slow;
    end
    else begin
        counter<=counter+1;
    end
    
end

always_ff@(posedge clk_slow) begin
    en_sync<=button;  
end

endmodule 

//Módulo de pausa: Recibe como entrada la señal enable, que es salida del módulo button_driver
module pause(
    input logic enable,
    input logic clk,
    output logic pause_reg
    );
    enum logic {S0,S1} S = S0,nextS;
    
    always_ff@(posedge clk) begin
        S<=nextS;
    end
    
//    se quiere que el botn de pausa actue como toggle, es decir, que una vez presionado mantenga su
//    estado hasta que se presione de nuevo, por eso, si está activo el enable, quiere decir que debe
//    irse al estado S1, donde se activa la señal de pausa, una vez se suelta el boton, la señal de 
//    enable vuelve a ser 0, lo cual como no se indica un estado en el que exista ~enable, se mantiene
//    por defecto en el estado que estaba.
    
    always_comb begin
    nextS=S;
    unique case (S)
    S0: begin    
            if(enable) nextS=S1;
            pause_reg=0;
        end
    S1: begin
            if(enable) nextS=S0;
            pause_reg=1;
        end
     endcase
   end  
endmodule


