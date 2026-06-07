`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2026 14:17:14
// Design Name: 
// Module Name: BCD_7segmentos
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
module show(
    input logic finish,
    input logic clk,
    input logic clk_enable,
    input logic load,
    output logic show
    );
// variable que indicará cuando cambiar a ON/OFF
logic timer;
// se hace una instancia del modulo ya fabricado para generar la nueva señal que se activa cada 300 ms
// el valor del contador se asigna con el hashtag
clockDivider #(.TC(30000000)) timer_300ms ( 

    .clk(clk), 
    .divClk(timer) // el valor de salida del modulo se va asignar al timer

); 
// FSM
 enum logic [1:0]{S0,S1,S2} S,nextS;
    
    always_ff@(posedge clk) begin
        if(load) S<=S0;
        else S<=nextS;
    end
    
    always_comb begin
    show = 1;
    unique case (S)
    //caso normal donde se muestran los digitos
    S0: begin  
            show=1;  
            if(finish&&!load) nextS=S1;
            else nextS=S0;  
            
        end
    // caso parpadeo ON    
    S1: begin
            show=1;
            if(load) nextS=S0; //si se cargo un valor da lo mismo lo que pase, se va al estado base
            else if (timer) nextS=S2; // si han pasado los 300 ms, se debe ir al parpadeo off
            else nextS=S1;
            
        end
    // caso parpadeo OFF
    S2: begin
            show=0;;
            if(load) nextS=S0;
            else if (timer) nextS=S1;
            else nextS=S2;
            
        end
    default: nextS = S0;
   endcase
  end  
endmodule

// usar logica negativa, es decir, 0 significa encendido y 1 apagado
module BCD_7seg(
    input logic [3:0]BCD,
    input logic show,
    output logic [6:0]seven_seg   
    );
      
    always_comb begin
        if(!show) begin 
        seven_seg = 7'b1111111; // si el valor de show es 0 todo debe estar apagado
    end else begin
        unique case (BCD)
            4'h0: seven_seg = 7'b0000001;
            4'h1: seven_seg = 7'b1001111;
            4'h2: seven_seg = 7'b0010010;
            4'h3: seven_seg = 7'b0000110;
            4'h4: seven_seg = 7'b1001100;
            4'h5: seven_seg = 7'b0100100;
            4'h6: seven_seg = 7'b0100000;
            4'h7: seven_seg = 7'b0001111;
            4'h8: seven_seg = 7'b0000000;
            4'h9: seven_seg = 7'b0001100;
    // caso en que se ingresa un numero mayor que 9 por ej
            default: seven_seg = 7'b1111111;
        endcase 
     end 
  end   
endmodule  