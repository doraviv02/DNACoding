/*------------------------------------------------------------------------------
 * File          : IDS_generator.sv
 * Project       : RTL
 * Author        : epdasf
 * Creation date : Oct 9, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

module IDS_generator #(
	parameter logic [31:0]  pi = 31'b01010101, // Q0.8 frac, 01010101 is 1/3
	parameter logic [31:0]  pd = 31'b01010101,
	parameter logic [31:0]  ps = 31'b01010101,
	parameter  n = 10,
	parameter int TIMES = 4,
	parameter DATA_WIDTH = 32 ,
	parameter int ZERO = 0
)(
	input reg [n-1:0] data_in,
	input wire clk,
	input logic rst_n,
	output int n_out ,
	output logic ready ,
	output reg [DATA_WIDTH-1:0] data_out
);

	int i,j;
	reg [DATA_WIDTH-1:0] org;
	reg [DATA_WIDTH-1:0] cor;

	logic [31:0] rpi;
	logic [31:0] rps;
	logic [31:0] rpd;





xorshift_prng #(
	.TIMES      (1),
	// Width of the output random number
	//seed for steps, preferably prime 
	.SEED        (11)
) u_xorshift_prng_i (
	.rst_n       (rst_n),
	// Active low reset
	.clk(clk),
	// Random number output
	.rand_out    (rpi)
);

xorshift_prng #(
	.TIMES      (1),
	// Width of the output random number
	//seed for steps, preferably prime 
	.SEED        (3)
) u_xorshift_prng_d (
	.rst_n       (rst_n),
	// Active low reset
	.clk(clk),
	// Random number output
	.rand_out    (rpd)
);

xorshift_prng #(
	.TIMES      (1),
	// Width of the output random number
	//seed for steps, preferably prime 
	.SEED        (7)
) u_xorshift_prng_s (
	.rst_n       (rst_n),
	// Active low reset
	.clk(clk),
	// Random number output
	.rand_out    (rps)
);
	always_ff @(posedge clk) begin
		if (!rst_n || !(i < n  && j < DATA_WIDTH) || ready ) begin
			cor <= {DATA_WIDTH{1'b0}};
			org <= {{(DATA_WIDTH - n){1'b0}}, data_in};
			j <= 0;
			i <= 0;
			ready <= 0;
		end else if (i < n  && j < DATA_WIDTH) begin 

			if (rpi < pi) begin
				cor[j] <= rps[j];
				j <= j + 1;
			end else begin
				if (rpd <  pd) begin
					i <= i+1;
					if (i == n-1)
						ready <= 1'b1;
				end else if (rps < ps) begin
					cor[j] <= !org[i];
					j <= j + 1;
					i <= i + 1;
					if (i == n-1)
						ready <= 1'b1;
				end else begin
					cor[j] <= org[i];
					j <= j + 1;
					i <= i + 1;
					if (i == n-1)
						ready <= 1'b1;
				end 

			end

		end 
	end

	assign data_out = cor;
	assign n_out = j;
endmodule