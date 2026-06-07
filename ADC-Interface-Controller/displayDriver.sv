`timescale 1ns / 1ps

module displayDriver (
    input logic clk, divClk,
    input logic[27:0] inSeg,   // Cambiado a 28 bits (4 displays x 7 segmentos)
    output logic[3:0] anodes,
    output logic[6:0] outSeg,  // Cambiado a 7 bits [6:0] para coincidir con la Basys 3
    output logic dp            // Agregamos la salida para el punto decimal físico
);

logic[1:0] displayCnt = 0;

always_ff @(posedge clk) begin
    if(divClk) displayCnt <= displayCnt + 1;
end

always_comb begin
    // Lógica por defecto para el punto decimal (recuerda: activo bajo)
    dp = 1'b1; // Apagado en todos los displays por defecto
    
    unique case (displayCnt)
        2'd0: begin
            anodes = 4'b1110;          // Primer display (derecha)
            outSeg = inSeg[6:0];
        end
        2'd1: begin
            anodes = 4'b1101;          // Segundo display
            outSeg = inSeg[13:7];
        end
        2'd2: begin
            anodes = 4'b1011;          // Tercer display
            outSeg = inSeg[20:14];
        end
        2'd3: begin
            anodes = 4'b0111;          // Cuarto display (Punto decimal de los Voltios!)
            outSeg = inSeg[27:21];
            dp = 1'b0;                 // Forzamos el encendido del punto aquí (ej: 1.234 V)
        end
    endcase
end
endmodule: displayDriver

module binto7seg(
    input logic clk, rst,
    input logic [13:0] result,  
    output logic [6:0] seg, 
    output logic dp,        
    output logic [3:0] an
);
    
    logic clk_slow;
    logic [15:0] bcd_output;
    logic [27:0] seg_output; 
    logic [13:0] result_in_mv; 
    
    //localparam TC_display = 5;
    localparam TC_display = 100000;
    
    // 1. Declarar un cable intermedio con una orden estricta para Vivado:
    // "No uses el bloque DSP matemático, usa lógica normal"
    (* use_dsp = "no" *) logic [23:0] mult_tmp;

    // 2. Realizamos la multiplicación completa sin desbordes
    assign mult_tmp = result * 24'd1000;

    // 3. En vez de usar (>> 12), cortamos los bits manualmente.
    // Tomamos 12 bits útiles (del bit 23 al 12) y rellenamos los 
    // 2 bits superiores con ceros para completar los 14 bits de tu cable.
    assign result_in_mv = {2'b00, mult_tmp[23:12]};

    // 2. Divisor de reloj lento para evitar efecto "ghosting"
    clockDivider #(.TC(TC_display)) clk_div (
        .clk (clk),
        .divClk (clk_slow)
    );
    
    // 3. Conversor BCD con el valor ajustado y a 14 bits
    bin2bcd_multi #(
        .N_DIGITS (4),
        .N_BITS (14)
    ) bin2bcd_multi1 (
        .clk (clk),
        .load (1'b1),
        .rst (rst),
        .bin (result_in_mv),   // <- Entra el valor escalado
        .ready (),
        .bcd (bcd_output)
    );

    // Conectamos cada dígito BCD al módulo decodificador de 7 segmentos de 7 bits
    seven_seg seg1 (
        .clk (clk),
        .in (bcd_output[3:0]),
        .seg (seg_output[6:0])    // Bits 0 a 6
    );

    seven_seg seg2 (
        .clk (clk),
        .in (bcd_output[7:4]),
        .seg (seg_output[13:7])   // Bits 7 a 13
    );

    seven_seg seg3 (
        .clk (clk),
        .in (bcd_output[11:8]),
        .seg (seg_output[20:14])  // Bits 14 a 20
    );

    seven_seg seg4 (
        .clk (clk),
        .in  (bcd_output[15:12]),
        .seg (seg_output[27:21])  // Bits 21 a 27
    );

    // Instanciamos el driver multiplexador actualizado
    displayDriver disp_driver (
        .clk (clk),
        .divClk (clk_slow),
        .inSeg (seg_output),
        .anodes (an),
        .outSeg (seg),            // Sale el bus directo de 7 pines hacia la placa
        .dp (dp)                  // Sale el pin de control del punto hacia la placa
    );

endmodule: binto7seg
