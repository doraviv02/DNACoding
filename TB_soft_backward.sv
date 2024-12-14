module TB_soft_backward;

  // Parameters
  parameter DATA_WIDTH = 6;
  parameter n = 5;
  parameter a = 9;

  // Inputs
  logic clk;
  int N;
  logic calc_beta;
  int t;
  logic signed [31:0] beta_in[2*n:0][DATA_WIDTH:-n];
  logic [DATA_WIDTH-1:0] strand;

  // Outputs
  logic signed [31:0] beta_out[2*n:0][DATA_WIDTH:-n];
  logic done;

  // Instantiate the Unit Under Test (UUT)
  soft_backward #(
    .DATA_WIDTH(DATA_WIDTH),
    .n(n),
    .a(a)
  ) uut (
    .clk(clk),
    .N(N),
    .calc_beta(calc_beta),
    .t(t),
    .beta_in(beta_in),
    .strand(strand),
    .beta_out(beta_out),
    .done(done)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Test stimulus
  initial begin

    // Initialize inputs
    for (int i =0; i<= 2*n; i++) begin
      for (int j =0; j<= DATA_WIDTH + n; j++) begin
        beta_in[i][j-n] = 0;
      end 
    end 
    beta_in[9][0] = (32'sb1<<24);
    clk = 0;
    N = 5;
    calc_beta = 0;
    t = n-1;
    strand = 32'b10101; // Example strand value

    // Apply test vectors
    calc_beta = 1;
    #10;
    calc_beta = 0;

    // Wait for done signal
    wait(done);
    #5;
    beta_in = beta_out;

    t = n-1;
    calc_beta = 1;
    #10
    calc_beta = 0;
    wait(done);
    // End simulation
    #100;
    $finish;
  end

  // Optional: Monitor changes
  initial begin
    $monitor("Time=%0t, calc_beta=%b, t=%0d, done=%b", $time, calc_beta, t, done);
  end

endmodule