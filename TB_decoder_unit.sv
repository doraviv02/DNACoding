`timescale 1ns/1ps

module TB_decoder_unit;

  // Parameters
  parameter DATA_WIDTH = 32;
  parameter STACK_DEPTH = 16;
  parameter CLK_PERIOD = 0.001; //
  parameter NUM_TEST_CASES = 5;
  parameter int n = 10;
  parameter int a = 11;

  // Signals for decoder_unit
  logic clk;
  logic rst_n;
  logic [DATA_WIDTH-1:0] data_in;
  int N_in;
  logic load_start;
  logic load_done;
  logic [DATA_WIDTH-1:0] bit_out;
  logic ready;

  // Test case storage
  logic [DATA_WIDTH-1:0] test_cases [NUM_TEST_CASES];
  int test_case_n [NUM_TEST_CASES];
  int test_case_N [NUM_TEST_CASES];

  // Instantiate the Unit Under Test (UUT)
  decoder_unit #(
    .DATA_WIDTH(DATA_WIDTH),
    .STACK_DEPTH(STACK_DEPTH),
    .n(n),
    .a(a)
  ) uut (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .N_in(N_in),
    .softie(1'b1),
    .load_start(load_start),
    //.load_done(load_done),
    .bit_out(bit_out),
    .ready(ready)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // Test stimulus
  initial begin
    // Initialize inputs
    rst_n = 0;
    data_in = 0;
    N_in = 0;
    //logic load_start = 0;
    load_start = 0;
    load_done = 0;

    // Reset
    #(CLK_PERIOD*2);
    rst_n = 1;
    #(CLK_PERIOD*2);
    
    // Manually create test cases
    // Original strand: 32'b10101010101010101010101010101010
    test_cases[0] = 10'b1000000001; // No error
    test_case_N[0] = 10;

    test_cases[1] = 11'b10010101000; // Insertion error 
    test_case_N[1] = 11;

    test_cases[2] = 10'b1001101000; // Substitution error 
    test_case_N[2] = 10;

    test_cases[3] = 9'b100101000; // Deletion error 
    test_case_N[3] = 9;

    test_cases[4] = 10'b1001001000; // Substitution error 
    test_case_N[4] = 10;

    // Set common parameter for all test cases
    load_start = 1;
    //load_done = 0;
    // Process each test case
    for (int i = NUM_TEST_CASES-1; i >= 0; i= i-1) begin
      // Load data into the stack
      data_in = test_cases[i];
      N_in = test_case_N[i];
      @(posedge clk);
    end
    //load_done = 1;
    load_start = 0;
    @(posedge clk);
    for (int i = 0; i < NUM_TEST_CASES; i++) begin
      // Load data into the stack
      wait(ready);
      $display(" data_in: %b data out : %b",test_cases[i], bit_out);
    end

      // Add a delay between test cases
      #(CLK_PERIOD*10);
    // End simulation
    #(CLK_PERIOD*10);


    $finish;
  end

  // Optional: Add assertions here
  // For example, check if the output is within expected range
  //assert property (@(posedge clk) ready |-> (avg_L >= -0.5 && avg_L <= 0.5))
  //  else $error("avg_L out of expected range");


endmodule
