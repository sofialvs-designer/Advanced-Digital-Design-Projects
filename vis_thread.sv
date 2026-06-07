`timescale 1ns / 1ps

module vis_thread (
    input  logic        clk,
    input  logic        reset,
    input  logic        start,
    input  logic        proc_done,     // congela resultados al terminar procesamiento
    input  logic [1:0]  select_display,// selecciona qué mostrar
    input  logic [13:0] mean,          // U2.12
    input  logic [13:0] rms,           // U2.12
    input  logic [13:0] min_val,       // U2.12
    input  logic [13:0] max_val,       // U2.12
    output logic [6:0]  seg,           // Ajustado a 7 bits para coincidir con binto7seg
    output logic [3:0]  an,
    output logic        dp             // Ahora será controlado por el displayDriver
);

    // resultados congelados al llegar proc_done
    logic [13:0] mean_frozen, rms_frozen, min_frozen, max_frozen;

     always_ff @(posedge clk) begin
        if (reset) begin          // limpiar display en nueva adquisición
            mean_frozen <= 0;
            rms_frozen  <= 0;
            min_frozen  <= 0;
            max_frozen  <= 0;
        end
        if (proc_done) begin    // procesamiento listo, congelar
            mean_frozen <= mean;
            rms_frozen  <= rms;
            min_frozen  <= min_val;
            max_frozen  <= max_val;
        end
    end

    // mux de switches sobre valores congelados
    logic [13:0] resultado_seleccionado;
    always_comb begin
        case(select_display)
            2'b00: resultado_seleccionado = mean_frozen;
            2'b01: resultado_seleccionado = rms_frozen;
            2'b10: resultado_seleccionado = min_frozen;
            2'b11: resultado_seleccionado = max_frozen;
            default: resultado_seleccionado = 14'd0; 
        endcase
    end

    // Instancia binto7seg (Él ya se encarga de multiplicar *1000, hacer el shift y poner el dp)
    binto7seg b7seg (
        .clk       (clk),
        .rst       (reset),
        .result    (resultado_seleccionado), // Pasa el valor U2.12 directo            
        .seg       (seg),
        .dp        (dp),                     // Saca el punto decimal de forma dinámica
        .an        (an)
    );

endmodule