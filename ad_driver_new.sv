`timescale 1ns / 1ps

// el start de entrada de esta hebra corresponde a la señal que genera la hebra de adquisicion drv_start
module AD1_drv (input logic start, reset, clk, divClk, output logic ready,
                output logic [11:0] data0, data1,
                input logic D0, D1, output logic CS, SCLK);
    // Interfaz con FPGA: clk, divClk, start, ready, data0, data1
    // Interfaz con PMOD AD1: D0, D1, SCLK, CS
    // Frecuencia maxima divClk: 40MHz

    logic [4:0] state=0, nextState;  // registro de estado y transición

    logic clkEn = divClk & ~SCLK;

    always_ff @(posedge clk) begin : SCLK_driver
        if (reset) begin
            SCLK <= 1;
        end
        else if (divClk) begin
            SCLK <= ~SCLK;
        end
    end
    

    always_ff @(posedge clk) begin : state_transition
        if (reset) begin
            state <= 0;
        end
        else if (clkEn) begin
            state <= nextState;
        end
    end
//la señal start es la que proviene de la hebra de adquisicion, definida como drv_start, depende de la señal
//ready, si ready está en 1 y estamos en el estado TRIGGER, indica que el driver puede convertir datos, por
//lo cual pasa al primer estado, son 16 estados en total, en cada uno se captura un bit
    always_comb begin : nextState_func
        if (state == 0) begin
            if (start)
                nextState = 1;
            else
                nextState = 0;
        end
        else if (state < 15)
            nextState = state + 1;
        else
            nextState = 0;
    end

    always_ff @(posedge clk) begin : datapath_shift_registers
        if (clkEn) begin
            if (state >= 1 && state <= 15) begin
                data0 <= {data0[10:0], D0};
                data1 <= {data1[10:0], D1};
            end
        end
    end

    always_comb begin : control_ready //cada vez que se caiga en el estado inicial se debe activar ready
        ready = (state == 0);
    end

    always_comb begin : control_ADC
        if (state >= 1 && state <= 15)
            CS = 0;
        else
            CS = 1;
    end

endmodule

