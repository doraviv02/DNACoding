module top_level #(
	parameter DATA_WIDTH = 32,
	parameter STACK_DEPTH = 16,
	parameter int n = 10,
	parameter int a = 5,
	parameter k = 5    
)(
	input logic clk,
	input logic rst_n,
	input int num_of_strands,
	input wire [k-1:0] data_in,
	input logic softie,
	output reg [k-1:0] recovered,    // Output codeword with parity bits
	output reg good_syndrome,
	output logic ready

);



	reg [n-1:0] coded;

	vt_encode #(
	.k                (k),
	.n                (n),
	.SYNDROME_VAL     (a)
	) u_vt_encode (
	.data_in(data_in),  
	.codeword(coded),
	.good_syndrome()
	);

	int n_cor;
	reg [DATA_WIDTH-1:0] corrupted;

	IDS_generator #(
	.pi            (32'b00000010), // 
	.pd            (32'b00000010),
	.ps            (32'b00000010),
	.n             (n),
	.DATA_WIDTH    (DATA_WIDTH),
	.ZERO          (0)
	) u_IDS_generator (
	.data_in       (coded),
	.clk           (clk),
	.rst_n         (rst_n),
	.ready         (cor_ready),
	.n_out         (n_cor),
	.data_out      (corrupted)
	);


	logic load_on;
	logic  [DATA_WIDTH-1:0] bit_out;
	
	decoder_unit #(
	.DATA_WIDTH     (DATA_WIDTH),
	.STACK_DEPTH    (STACK_DEPTH),
	.n              (n),
	.a              (a)
	) u_decoder_unit (
	.clk            (clk),
	.rst_n          (rst_n),
	.data_in        (corrupted),
	.N_in           (n_cor),
	.load_on        (load_on),
	.load_prep      (cor_ready),
	.softie         (softie),
	.bit_out        (bit_out),
	.ready          (ready)
);

	vt_decode #(
	//.DATA_WIDTH(DATA_WIDTH),
	.k                (k),
	.n                (n),
	.SYNDROME_VAL     (a)
) u_vt_decode (
	.data_in          (bit_out[n-1:0]),
	.recovered         (recovered),
	.good_syndrome    (good_syndrome)
);



	counter counter (
		.clk(clk),
		.rst_n(rst_n),
		.num_of_strands(num_of_strands),
		.cor_ready(cor_ready),
		.load_on(load_on)
	);

endmodule