module top(input logic clk,pause,load,input logic [15:0] in,output logic [6:0] seg,output logic [3:0] an);

// la señal pause que se menciona en las entradas del top, proviene de un boton, y es la que va a button_driver
// an se refiere a los ánodos y seg a los segmentos
logic [3:0] BCD_1, BCD_2, BCD_3, BCD_4;
logic en_2, en_3, en_4;
logic inc_1, inc_2, inc_3;
logic clk_enable;
logic pause_signal; //va a tomar el valor de pause_reg que sale del modulo pausa
logic[27:0] seven_seg; // tiene que unir los pedazos de cada instancia del bcd a 7 seg para pasarselo a display
logic [6:0] seg_1, seg_2, seg_3, seg_4; // son los "pedazos" o nodos que van a guardar cada uno de los seg de salida de bcd_7seg
logic finish;
logic show_sig;
logic pause_reg_out;

// señal finish, cuando los 4 numeros BCD de las FSM lleguen a 0, finish será 1, lo que hace el operador ! es verificar 
// la variable tenga valor 0, mientras que los && verifican que cada una de las expresiones sea 0, para dar un 1 de salida
assign finish = !BCD_1 && !BCD_2 && !BCD_3 && !BCD_4;

// calculo de señales de habilitacion 

assign en_2 = (inc_1 && clk_enable && !pause_reg_out && !finish);
assign en_3 = (inc_2 && en_2 && !pause_reg_out && !finish);
assign en_4 = (inc_3 && en_3 && !pause_reg_out && !finish);

// instancias de módulos pre hechos

// INSTANCIA DISPLAY

// concatenacion resultados instancias de bcd_7seg para obtener numero completo de 28 bits y pasarselo de entrada a display
assign seven_seg = {seg_4, seg_3, seg_2, seg_1};

displayDriver disp(.clk(clk), .inSeg(seven_seg), .anodes(an), .outSeg(seg));

// INSTANCIA DIVISOR FRECUENCIA (ENTREGA 1 MHZ)
clk_div clk_div(.clk(clk), .clk_enable(clk_enable));

// INSTANCIA BUTTON DRIVER RECIBE SEÑAL DEL BOTON Y SE LA DA COMO UNA SEÑAL ENABLE A MODULO PAUSA A TRAVES DE PAUSE_SIGNAL
button_driver pausa(.clk(clk), .button(pause), .enable(pause_signal));
// queremos que pause_signal sea la entrada a modulo pause, entra a través de enable, por otro aldo, la salida de pause 
//esta dada por pause_reg, entonces la conectamos a un nodo para luego pasarsela a las fsm

// instancia modulo pausa
pause inst_pause (.clk(clk), .enable(pause_signal), .pause_reg(pause_reg_out));
 
//INSTANCIACION FSMs
// aca le daria especificamente los bits de la entrada in a las FSM
FSM_1 inst_FSM_1 (.clk(clk), .clk_enable(clk_enable), .load(load), .in(in[3:0]), .pause_reg(pause_reg_out), .finish(finish),
             .BCD_1(BCD_1), .inc_1(inc_1));

FSM_2 inst_FSM_2 (.clk(clk), .clk_enable(en_2), .load(load), .in(in[7:4]), .pause_reg(pause_reg_out), .finish(finish),
             .BCD_2(BCD_2), .inc_2(inc_2));
             
FSM_3 inst_FSM_3 (.clk(clk), .clk_enable(en_3), .load(load), .in(in[11:8]), .pause_reg(pause_reg_out), .finish(finish),
             .BCD_3(BCD_3), .inc_3(inc_3));
             
FSM_4 inst_FSM_4 (.clk(clk), .clk_enable(en_4), .load(load), .in(in[15:12]), .pause_reg(pause_reg_out), .finish(finish),
             .BCD_4(BCD_4));   
 
 // instancia fsm show   
 
 show inst_show (.finish(finish), .clk (clk), .clk_enable(clk_enable), .load(load), .show(show_sig));         
          
// instancia bcd a 7 seg

// aca los que se trata de hacer es pasarle los valores de salida de seven_seg del bcd a 7 seg al nodo (parentesis)
 BCD_7seg decisegundos (.BCD(BCD_1), .show(show_sig), .seven_seg(seg_1));
 BCD_7seg segundos_unidad (.BCD(BCD_2), .show(show_sig), .seven_seg(seg_2));
 BCD_7seg segundos_decena(.BCD(BCD_3), .show(show_sig), .seven_seg(seg_3));
 BCD_7seg minutos (.BCD(BCD_4), .show(show_sig), .seven_seg(seg_4));        
                   
endmodule