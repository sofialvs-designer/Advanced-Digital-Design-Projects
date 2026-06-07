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


module clk_enable(input logic clk,reset,pause, output logic clk_enable);
    logic [23:0] count=0;
    
    always_ff@(posedge clk) begin
        if(reset)
            count<=1;
        else
           if(~pause) begin
               if(count==9999999) begin 
                    count<=0;
                    clk_enable<=1;
                end else begin
                    count<=count+1;
                    clk_enable<=0;
                end
          end
          else
            clk_enable<=0;
    end
endmodule

module one_shots(input logic clk, button,output logic enable);

logic [19:0] counter;
logic clk_slow;
logic en_sync,en_1,en_2;


assign enable=(~en_2 && en_1);

always_ff @(posedge clk) begin    
    
    
    en_1<=en_sync;
    en_2<=en_1;
    
    if(counter==500001) begin
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

module load_signal(input logic clk,clk_enable,load,output logic enable);

logic load_reg;
assign enable=load_reg&clk_enable;
always_ff @(posedge clk) begin    
    
    if(load) begin
        load_reg<=1;
    end
    
    if(clk_enable) begin
        load_reg<=0;
    end
    
    

end




endmodule 


module buttonEdgeDetect (input logic button, clk, divClk, output logic edgeDet);

  logic n1=0, n2=0;


  always_ff @(posedge clk) begin  // sincronizador con antirrebote​

    if (divClk)                   // muestreo a frecuencia dividida​

      n1 <= button;               // muestreo​

    n2 <= n1;                     // sincronización​

  end


  assign edgeDet = ~n2 & n1;      // detector de cantos vale 1 durante 1 ciclo de clk​


endmodule : buttonEdgeDetect



