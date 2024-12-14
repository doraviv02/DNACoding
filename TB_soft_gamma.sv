`timescale 1ns/1ps

module TB_soft_gamma;

  // Parameters
  localparam real P_D = 1.0/3.0;
  localparam real P_I = 1.0/3.0;
  localparam real P_S = 1.0/3.0;
  localparam int DATA_WIDTH = 32;

  // Signals
  logic [DATA_WIDTH-1:0]  r; 
  int t;
  int d;
  int d_tag;
  logic b;
  real gamma_out;

  // Instantiate the Unit Under Test (UUT)
  soft_gamma #(
    .DATA_WIDTH(DATA_WIDTH)
  ) uut (
    .N(5),
    .r(r),
    .t(t),
    .d(d),
    .d_tag(d_tag),
    .b(b),
    .gamma_out(gamma_out)
  );

  // Helper function to convert real to string with limited precision
  function string real_to_string(real value);
    return $sformatf("%0.6f", value);
  endfunction

  // Helper function to check if gamma_out is within valid range
  function automatic void check_gamma_range();
    if (gamma_out < 0.0 || gamma_out > 1.0) begin
      $error("gamma_out is out of range [0, 1]: %f", gamma_out);
    end
  endfunction

  // Stimulus and checking
  initial begin
    // Test case 1: Basic test
    r = 5'b10101;
    t = 5;
    d = 0;
    d_tag = 0;
    b = 1;
    #10;
    $display("Test Case 1: r=%b, t=%0d, d=%0d, d_tag=%0d, b=%0d, gamma_out=%s", 
             r, t, d, d_tag, b, real_to_string(gamma_out));
    check_gamma_range();

    // Test case 2: d - d_tag = -1
    d = 4;
    d_tag = 5;
    #10;
    $display("Test Case 2: r=%b, t=%0d, d=%0d, d_tag=%0d, b=%0d, gamma_out=%s", 
             r, t, d, d_tag, b, real_to_string(gamma_out));
    check_gamma_range();

    // Test case 3: Out of bounds
    t = 30;
    d = 5;
    d_tag = 3;
    #10;
    $display("Test Case 3: r=%b, t=%0d, d=%0d, d_tag=%0d, b=%0d, gamma_out=%s", 
             r, t, d, d_tag, b, real_to_string(gamma_out));
    check_gamma_range();

    // Test case 4: r[index] != b
    r = 32'b11111111111111110000000000000000;
    t = 2;
    d = 15;
    d_tag = 14;
    b = 0;
    #10;
    $display("Test Case 4: r=%b, t=%0d, d=%0d, d_tag=%0d, b=%0d, gamma_out=%s", 
             r, t, d, d_tag, b, real_to_string(gamma_out));
    check_gamma_range();

    // Test case 5: r[index] == b
    b = 1;
    #10;
    $display("Test Case 5: r=%b, t=%0d, d=%0d, d_tag=%0d, b=%0d, gamma_out=%s", 
             r, t, d, d_tag, b, real_to_string(gamma_out));
    check_gamma_range();

    // End simulation
    #100 $finish;
  end

endmodule