/*------------------------------------------------------------------------------
 * File          : TB_vt_encode_u.sv
 * Project       : RTL
 * Author        : epdasf
 * Creation date : Sep 2, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

module TB_vt_encode;

// Parameters for the encoder
parameter k = 5;
parameter n = 10; // Length of the codeword based on your k value
parameter SYNDROME_VAL = 0;

// Testbench signals
reg [k-1:0] data_in;
wire [n-1:0] codeword;
wire good_syndrome;

// Instantiate the vt_encode module
vt_encode #(
  .k(k),
  .n(n),
  .SYNDROME_VAL(SYNDROME_VAL)
) uut (
  .data_in(data_in),
  .codeword(codeword),
  .good_syndrome(good_syndrome)
);

initial begin
	#10
  // Initialize input data with 11011
 	data_in = 5'b11011;
  // Wait for a few time units to let the design process the input
 	#10;
  ///add many more
  // End the simulation
	#10;
 	$finish;
end

endmodule
