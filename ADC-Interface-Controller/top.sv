
module top (input logic clk, reset, start, D0_in, D1_in, 
            input logic [1:0] select_display, input logic [9:0] N, 
            output logic SCLK_in, CS_in, output logic [6:0] seg, 
            output logic [3:0] an, output logic dp, led_proc_done, led_acq_done);
 
    logic        divClk;
    logic        ready_in; 
    logic        resetPulse;
    logic        startPulse;
    logic [11:0] data0_in, data1_in;
    logic        drv_start;
    logic [10:0] sample_count;
    logic        acq_done, proc_done;
    
 
    logic [13:0] val_max, val_min, val_avg, val_rms;
    logic [9:0]  read_addr;
    logic [11:0] read_data;
    
    localparam TC_buttons = 2000000;
    //localparam TC_buttons = 5;  
  
    localparam TC_SPI = 50;
    
  clockDivider #(.TC(TC_SPI)) cd1 (.clk(clk), .divClk(divClk));
  
  logic clk_1ms;
  clockDivider #(.TC(TC_buttons)) div_botones (.clk(clk), .divClk(clk_1ms));

  buttonEdgeDetect edet1 (.button(reset), .clk(clk), .divClk(clk_1ms), .edgeDet(resetPulse)); 
  buttonEdgeDetect edet2 (.button(start), .clk(clk), .divClk(clk_1ms), .edgeDet(startPulse));
  
  AD1_drv ad1 (
    .start  (drv_start),
    .reset  (resetPulse),
    .clk    (clk),
    .divClk (divClk),
    .ready  (ready_in),
    .data0  (data0_in),
    .data1  (data1_in),
    .D0     (D0_in),
    .D1     (D1_in),
    .CS     (CS_in),
    .SCLK   (SCLK_in)
  );
  
  adq_thread adq (
    .clk          (clk),
    .reset        (resetPulse),
    .start        (startPulse),
    .ready        (ready_in),
    .proc_done    (proc_done),
    .data0        (data0_in),
    .data1        (data1_in),
    .N            (N),
    .read_addr_in (read_addr),
    .drv_start    (drv_start),
    .read_data_out(read_data),
    .sample_count (sample_count),
    .acq_done     (acq_done)
  );
  
  proc_thread proc (
    .clk       (clk),
    .reset     (resetPulse),
    .acq_done  (acq_done),
    .N         (N),
    .read_data (read_data),
    .read_addr (read_addr),
    .val_max   (val_max),
    .val_min   (val_min),
    .val_avg   (val_avg),
    .val_rms   (val_rms),   
    .proc_done (proc_done)
  );
  
  vis_thread vis (
    .clk            (clk),
    .reset          (reset),
    .start          (startPulse),
    .proc_done      (proc_done),
    .select_display (select_display),
    .mean           (val_avg),
    .rms            (val_rms),
    .min_val        (val_min),
    .max_val        (val_max),
    .seg            (seg),
    .an             (an),
    .dp             (dp)
  );
  
  always_ff @(posedge clk) begin
        if (reset) begin // Usa el botón reset directo para apagar los LEDs
            led_acq_done <= 0;
            led_proc_done <= 0;
        end else begin
            if (acq_done)  led_acq_done <= 1;  // Atrapa el fin de adquisición (LED 0)
            if (proc_done) led_proc_done <= 1; // Atrapa el fin de matemática (LED 1)
        end
    end
 
endmodule : top



