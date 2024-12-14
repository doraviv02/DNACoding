module decoder_stack #(
	parameter DATA_WIDTH = 32,
	parameter STACK_DEPTH = 16
)(
	input logic clk,
	input logic rst_n,
	input logic push,
	input logic pop,
	input logic [DATA_WIDTH-1:0] data_in,
	input int N_in, 
	output logic [DATA_WIDTH-1:0] data_out,
	output int N_out, 
	output logic full,
	output logic empty
);

	// Stack memory
	logic  [STACK_DEPTH-1:0][DATA_WIDTH-1:0] stack_mem ;
	int [STACK_DEPTH-1:0] N_mem ;
	logic int stack_ptr;  // Stack pointer

	// Stack control logic
	assign full = (stack_ptr == STACK_DEPTH);
	assign empty = (stack_ptr == 0);
	assign data_out = stack_mem[stack_ptr-1]; // Output the top of the stack
	assign N_out = N_mem[stack_ptr-1];
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			stack_ptr <= 0;
		end else if (push && !full) begin
			stack_mem[stack_ptr] <= data_in;
			N_mem[stack_ptr] <= N_in;
			stack_ptr <= stack_ptr + 1;
		end else if (pop && !empty) begin
			stack_ptr <= stack_ptr - 1;
		end
	end
endmodule
