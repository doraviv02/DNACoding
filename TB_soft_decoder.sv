

module TB_soft_decoder;

  // Parameters
  parameter DATA_WIDTH = 11;
  parameter n = 5;
  parameter a = 3;

  // Inputs
  logic clk;
  int N;
  logic start;
  logic [DATA_WIDTH-1:0] strand;

  // Outputs
  logic signed [31:0] likelyhood[n:1];
  logic done;

  // Instantiate the Unit Under Test (UUT)
  soft_decoder #(
    .DATA_WIDTH(DATA_WIDTH),
    .n(n),
    .a(a)
  ) uut (
    .clk(clk),
    .N(N),
    .start(start),
    .strand(strand),
    .likelyhood(likelyhood),
    .done(done)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Test stimulus
  initial begin
    // Initialize inputs
    clk = 0;
    N = 5;
    start = 0;
    strand = 0;

    // Wait for 100 ns for global reset
    #100;

    // Apply test vectors
    strand = 32'b011; // Example strand value
    start = 1;
    #10;
    start = 0;

    // Wait for done signal
    wait(done);

    // Display results
    $display("Likelyhood values:");
    for (int i = 1; i <= n; i++) begin
      $display("likelyhood[%0d] = %0d", i, likelyhood[i]);
    end

    // End simulation
    #100;
    $finish;
  end

  // Optional: Monitor changes
  initial begin
    $monitor("Time=%0t, start=%b, done=%b", $time, start, done);
  end

endmodule