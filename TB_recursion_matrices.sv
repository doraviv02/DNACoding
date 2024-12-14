
module TB_recursion_matrices;

  // Parameters
  parameter DATA_WIDTH = 6;
  parameter n = 5;
  parameter a = 9;

  // Inputs
  logic clk;
  logic start_recursion;
  logic [DATA_WIDTH-1:0] strand;
  int N;

  // Outputs
  logic signed [31:0] alpha[n-1:0][2*n:0][DATA_WIDTH:-n];
  logic signed [31:0] beta[n:1][2*n:0][DATA_WIDTH:-n];
  logic done;

  // Instantiate the Unit Under Test (UUT)
  soft_recursion_matrices #(
    .DATA_WIDTH(DATA_WIDTH),
    .n(n),
    .a(a)
  ) uut (
    .clk(clk),
    .start_recursion(start_recursion),
    .strand(strand),
    .N(N),
    .alpha(alpha),
    .beta(beta),
    .done(done)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Test stimulus
  initial begin
    // Initialize inputs
    clk = 0;
    start_recursion = 0;
    strand = 0;
    N = 5;

    // Wait for 100 ns for global reset
    #100;

    // Apply test vectors
    strand = 32'b10101; // Example strand value
    start_recursion = 1;
    #10;
    start_recursion = 0;

    // Wait for done signal
    wait(done);

    // Display results (you may want to adjust this based on your needs)
    $display("Alpha and Beta matrices calculated");
    
    // Example: Display first few elements of alpha and beta
    for (int i = 0; i < 3; i++) begin
      for (int j = 0; j < 3; j++) begin
        $display("alpha[%0d][%0d][0] = %0d", i, j, alpha[i][j][0]);
      end
    end
    
    for (int i = 1; i <= 3; i++) begin
      for (int j = 0; j < 3; j++) begin
        $display("beta[%0d][%0d][0] = %0d", i, j, beta[i][j][0]);
      end
    end

    // End simulation
    #100;
    $finish;
  end

  // Optional: Monitor changes
  initial begin
    $monitor("Time=%0t, start_recursion=%b, done=%b", $time, start_recursion, done);
  end

endmodule