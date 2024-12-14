`timescale 1ns/1ps

module TB_decoder_stack;

  // Parameters
  localparam DATA_WIDTH = 32;
  localparam STACK_DEPTH = 16;
  localparam CLK_PERIOD = 10; // 10ns clock period (100MHz)

  // Signals
  logic clk;
  logic rst_n;
  logic push;
  logic pop;
  logic [DATA_WIDTH-1:0] data_in;
  logic [$clog2(DATA_WIDTH+1)-1:0] k_in;
  logic [DATA_WIDTH-1:0] data_out;
  logic [$clog2(DATA_WIDTH+1)-1:0] k_out;
  logic full;
  logic empty;

  // Instantiate the Unit Under Test (UUT)
  decoder_stack #(
    .DATA_WIDTH(DATA_WIDTH),
    .STACK_DEPTH(STACK_DEPTH)
  ) uut (
    .clk(clk),
    .rst_n(rst_n),
    .push(push),
    .pop(pop),
    .data_in(data_in),
    .k_in(k_in),
    .data_out(data_out),
    .k_out(k_out),
    .full(full),
    .empty(empty)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // Test sequence
  initial begin
    // Initialize inputs
    rst_n = 0;
    push = 0;
    pop = 0;
    data_in = 0;
    k_in = 0;

    // Reset the stack
    #(CLK_PERIOD*2) rst_n = 1;

    // Test 1: Push items onto the stack
    for (int i = 0; i < STACK_DEPTH; i++) begin
      @(posedge clk);
      push = 1;
      data_in = i + 1;  // Push values 1 to 16
      k_in = (i % 5) + 1;  // k_in cycles through 1 to 5
      @(posedge clk);
      push = 0;
      check_stack_state($sformatf("Push operation %0d", i+1));
    end

    // Test 2: Try to push when stack is full
    @(posedge clk);
    push = 1;
    data_in = 100;
    k_in = 10;
    @(posedge clk);
    push = 0;
    check_stack_state("Push when full");

    // Test 3: Pop items from the stack
    for (int i = 0; i < STACK_DEPTH; i++) begin
      @(posedge clk);
      pop = 1;
      @(posedge clk);
      pop = 0;
      check_stack_state($sformatf("Pop operation %0d", i+1));
    end

    // Test 4: Try to pop when stack is empty
    @(posedge clk);
    pop = 1;
    @(posedge clk);
    pop = 0;
    check_stack_state("Pop when empty");

    // Test 5: Push and pop alternately
    for (int i = 0; i < 5; i++) begin
      // Push
      @(posedge clk);
      push = 1;
      data_in = (i + 1) * 10;  // Push values 10, 20, 30, 40, 50
      k_in = i + 1;  // k_in values 1 to 5
      @(posedge clk);
      push = 0;
      check_stack_state($sformatf("Alternate push %0d", i+1));

      // Pop
      @(posedge clk);
      pop = 1;
      @(posedge clk);
      pop = 0;
      check_stack_state($sformatf("Alternate pop %0d", i+1));
    end

    // End simulation
    #(CLK_PERIOD*10) $finish;
  end

  // Task to check and display stack state
  task check_stack_state(string operation);
    $display("Time: %0t, Operation: %s", $time, operation);
    $display("  full: %b, empty: %b, data_out: %h, k_out: %d", full, empty, data_out, k_out);
  endtask

endmodule