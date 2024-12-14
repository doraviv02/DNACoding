`timescale 1ns/1ps

module TB_IDS_generator;

  // Parameters

  localparam K = 5;
  localparam DATA_WIDTH = 32;

  // Signals
  logic [K-1:0] data_in;
  logic clk;
  logic rst_n;
  int n_out;
  logic [DATA_WIDTH-1:0] data_out;

  // Instantiate the Unit Under Test (UUT)

  IDS_generator #(
    .pi            (8'b00000010),
	  .pd            (8'b00000010),
    .ps            (8'b00000010),
    .k             (5),
    .DATA_WIDTH    (32),
    .ZERO          (0)
) u_IDS_generator (
    .data_in       (data_in),
    .clk           (clk),
    .rst_n         (rst_n),
    .n_out         (n_out),
    .data_out      (data_out)
);

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 100 MHz clock
  end

  // Stimulus
  initial begin
    // Initialize inputs
    data_in = 13;
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;

    // Wait for a few clock cycles

    @(posedge clk);
    display_results();

    @(posedge clk);
    display_results();

    @(posedge clk);
    display_results();

    @(posedge clk);
    display_results();

    @(posedge clk);
    display_results();
    
    
    @(posedge clk);
    display_results();
    @(posedge clk);
    display_results();
    @(posedge clk);
    display_results();
    @(posedge clk);
    display_results();
    @(posedge clk);
    display_results();

    // Add more test cases as needed

    // End simulation
    #100 $finish;
  end

  // Task to display results
  task display_results;
    $display("Time: %0t, data_in: %b, n_out: %d, data_out: %b", $time, data_in, n_out, data_out);
    // Add more detailed checks or comparisons here
  endtask


endmodule
