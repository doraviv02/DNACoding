module TB_vt_decode;

// Parameters matching the encoder
parameter k = 5;
parameter n = 10;  // Length of the codeword
parameter SYNDROME_VAL = 0;

// Testbench signals
reg [k-1:0] data_in;
wire [n-1:0] encoded_data;
reg [k-1:0] decoded_data;
wire syn_in;
wire syn_out;

// Instantiate the vt_decode module
vt_decode #(
    .k(k),
    .n(n),
    .SYNDROME_VAL(SYNDROME_VAL)
) uut (
    .data_in(encoded_data),
    .original(decoded_data),
    .good_syndrome(syn_out)
);

vt_encode #(
  .k(k),
  .n(n),
  .SYNDROME_VAL(SYNDROME_VAL)
) uut2 (
  .data_in(data_in),
  .codeword(encoded_data),
  .good_syndrome(syn_in)
);

// Test stimulus
initial begin
    // Initialize signals
    // Test Case 1: Use the same codeword from your encoder testbench
    #10;
    data_in = 5'b11011;  // This should be replaced with actual encoded value
    #10;
    $display("original data = %b,  encoded = %b, decoder %b",data_in, encoded_data, decoded_data );
    #10
    data_in = 5'b10111;  // This should be replaced with actual encoded value
    #10;
    $display("original data = %b,  encoded = %b, decoder %b",data_in, encoded_data, decoded_data );

    // End simulation
    #10;
    $finish;
end
endmodule