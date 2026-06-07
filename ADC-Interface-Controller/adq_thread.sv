`timescale 1ns / 1ps

module adq_thread (
    input  logic        clk, 
    input  logic        reset,
    input  logic        start,
    input  logic        ready, 
    input  logic        proc_done,
    input  logic [11:0] data0, data1,
    input  logic [9:0]  N,
    input  logic [9:0]  read_addr_in,
    output logic        drv_start,
    output logic [11:0] read_data_out,
    output logic [10:0] sample_count = 0,
    output logic        acq_done
);

    typedef enum logic [2:0] {IDLE, WAIT_TICK, TRIGGER, WAIT_READY, DONE} state_t;    
    state_t state, nextState;
    logic [10:0] num_samples = 0;
    
    logic sample_tick;
    (* ram_style = "distributed" *) logic [11:0] sample_mem[0:1023];
    
    //localparam TC_adq = 10;
    localparam TC_adq = 400;
    
clockDivider #(.TC(TC_adq)) sample_clk_div (
        .clk    (clk),
        .divClk (sample_tick)
);

    assign read_data_out = sample_mem[read_addr_in];

    always_ff @(posedge clk) begin
        if (reset) state <= IDLE;
        else       state <= nextState;
    end

  always_comb begin
        nextState = state;        
        case (state)
            IDLE: begin       
                if(start) nextState = WAIT_TICK;
                else nextState = IDLE;
            end
            WAIT_TICK: begin
                if(sample_tick) nextState = TRIGGER;
                else nextState = WAIT_TICK;
            end
            TRIGGER: if(!ready) nextState = WAIT_READY;
            WAIT_READY: begin
                if(ready) begin
                    if (ready && sample_count == num_samples - 1)
                        nextState = DONE;
                    else
                        nextState = WAIT_TICK;
                    end
                end 
            DONE: begin
                if(proc_done) nextState = IDLE;
                else          nextState = DONE;
            end
        endcase
    end

    assign drv_start = (state == TRIGGER);
    assign acq_done  = (state == DONE);

    always_ff @(posedge clk) begin
        if (reset) begin
            sample_count <= 0;
            num_samples  <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if(start)
                        num_samples <= (N + 11'd8 > 11'd1024) ? 11'd1024 : N + 11'd8;
                        sample_count <= 0;
                end
                WAIT_READY: begin
                    if(ready) begin
                        sample_mem[sample_count] <= data0;
                        sample_count <= sample_count + 1;   
                    end     
                end
                DONE: begin
                    sample_count <= 0;
                end
            endcase
        end
    end

endmodule