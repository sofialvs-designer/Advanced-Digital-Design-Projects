`timescale 1ns / 1ps

module proc_thread(
    input  logic        clk, reset, acq_done,
    input  logic [9:0]  N,
    input  logic [11:0] read_data,

    output logic [9:0]  read_addr,
    output logic [13:0] val_max, val_min, val_avg, val_rms,
    output logic        proc_done
);
    
    typedef enum logic [3:0] {
        WAIT_ACQ,
        FETCH_DATA,
        WAIT_DATA,
        PROCESS_DATA,
        DIVIDE_AVG,
        CALC_SQRT_INIT,
        CALC_SQRT_ITER,
        DONE
    } state_t;

    state_t state, nextState;
    
    logic [10:0] M;
    logic [10:0] sample_idx;
    logic [2:0] iter_count;

    // Señales matemáticas
    logic [13:0] v_u2_12;
    logic [27:0] v_sq;
    logic [23:0] sum_x;
    logic [37:0] sum_x2;
    logic [25:0] mean_square;
    logic [53:0] mult_mean_sq;

    // LUTs (Memorias)
    logic [15:0] lut_inv_M [0:1024];
    logic [15:0] inv_M_val;
    
    // Inicialización directa en código (Elimina la dependencia del archivo .mem)
    (* rom_style = "distributed" *) logic [13:0] lut_sqrt_seed [0:63] = '{
        14'd16383, 14'd16383, 14'd11585, 14'd9459,  14'd8192,  14'd7327,  14'd6688,  14'd6192,
        14'd5792,  14'd5461,  14'd5181,  14'd4940,  14'd4730,  14'd4544,  14'd4378,  14'd4228,
        14'd4096,  14'd3974,  14'd3862,  14'd3759,  14'd3663,  14'd3575,  14'd3493,  14'd3416,
        14'd3344,  14'd3276,  14'd3213,  14'd3153,  14'd3096,  14'd3042,  14'd2991,  14'd2942,
        14'd2896,  14'd2852,  14'd2809,  14'd2769,  14'd2730,  14'd2693,  14'd2657,  14'd2623,
        14'd2590,  14'd2558,  14'd2527,  14'd2498,  14'd2469,  14'd2442,  14'd2415,  14'd2389,
        14'd2364,  14'd2340,  14'd2316,  14'd2293,  14'd2271,  14'd2250,  14'd2229,  14'd2208,
        14'd2189,  14'd2169,  14'd2150,  14'd2132,  14'd2114,  14'd2097,  14'd2080,  14'd2063
    };
    
    logic [13:0] x_n;
    logic [13:0] seed_val;

    // Inicialización de memorias
    initial begin
        $readmemh("lut_inv_M.mem", lut_inv_M);
    end

    // Cálculo instantáneo (Datapath combinacional limpio)
    always_comb begin
        v_u2_12 = (26'(read_data) * 26'd13520) >> 12;
        v_sq    = 28'(v_u2_12) * 28'(v_u2_12);
        inv_M_val = lut_inv_M[M]; 
        mult_mean_sq = 54'(sum_x2) * 54'(inv_M_val);
        seed_val = lut_sqrt_seed[mean_square[13:8]];
    end

    // Lógica de control FSM (Siguiente Estado)
    always_comb begin
        nextState = state;
        case(state)
            WAIT_ACQ:       if(acq_done) nextState = FETCH_DATA;
            FETCH_DATA:     nextState = WAIT_DATA;
            WAIT_DATA:      nextState = PROCESS_DATA;
            PROCESS_DATA:   begin
                            if(sample_idx >= M - 1) nextState = DIVIDE_AVG; 
                            else nextState = FETCH_DATA;
                            end
            DIVIDE_AVG:     nextState = CALC_SQRT_INIT;
            CALC_SQRT_INIT: nextState = CALC_SQRT_ITER;
            CALC_SQRT_ITER: begin
                            if(iter_count == 3'd3) nextState = DONE;
                            if(iter_count < 3'd3)  nextState = CALC_SQRT_ITER;
                            end
            DONE:           if(!acq_done) nextState = WAIT_ACQ;
            default:        nextState = WAIT_ACQ;
        endcase
    end

    // Bloque secuencial unificado (Un único driver por Flip-Flop)
    always_ff @(posedge clk) begin
        if(reset) begin
            state        <= WAIT_ACQ;
            proc_done    <= 1'b0;
            read_addr    <= '0;
            sample_idx   <= '0;
            iter_count   <= '0;
            val_max      <= 14'd0;
            val_min      <= 14'h3FFF;
            val_avg      <= 14'd0;
            val_rms      <= 14'd0;
            sum_x        <= '0;
            sum_x2       <= '0;
            M            <= '0;
            mean_square  <= '0;
            x_n          <= '0;
        end else begin
            state <= nextState;
            case(state)
                WAIT_ACQ: begin
                    proc_done  <= 1'b0;
                    sample_idx <= '0;
                    read_addr  <= '0;
                    iter_count <= '0;
                    sum_x      <= '0; 
                    sum_x2     <= '0;
                    M          <= (N + 11'd8 > 11'd1024) ? 11'd1024 : (N + 11'd8);
                    // Mantenemos los extremos listos para re-calcular en la ráfaga
                    val_max    <= 14'd0; 
                    val_min    <= 14'h3FFF;
                end
                
                FETCH_DATA: begin
                    read_addr  <= sample_idx[9:0];
                end
                
                PROCESS_DATA: begin
                    if(v_u2_12 < val_min) val_min <= v_u2_12; 
                    if(v_u2_12 > val_max) val_max <= v_u2_12; 
                    sum_x      <= sum_x + (v_u2_12 >> 2);
                    sum_x2     <= sum_x2 + (v_sq >> 4);
                    sample_idx <= sample_idx + 1'b1;
                end
                
                DIVIDE_AVG: begin
                    val_avg     <= (40'(sum_x) * 40'(inv_M_val)) >> 14;
                    mean_square <= mult_mean_sq >> 24; 
                end
                
                CALC_SQRT_INIT: begin
                    // Cargamos semilla inicial para algoritmo iterativo
                    x_n         <= seed_val;
                end
                
                CALC_SQRT_ITER: begin
                    x_n <= ( 28'(x_n >> 1) * (28'd12288 - ( (40'(mean_square) * ((28'(x_n) * 28'(x_n)) >> 12)) >> 12 )) ) >> 12;
                    iter_count <= iter_count + 1'b1;
                end
                
                DONE: begin
                    proc_done <= 1'b1;
                    val_rms   <= (40'(x_n) * 40'(mean_square)) >> 12; 
                end
            endcase
        end
    end
endmodule