
module decoder_unit #( 
	parameter DATA_WIDTH = 32,
	parameter STACK_DEPTH = 16,
	parameter int n = 10,
	parameter int a = 0
)(
	input logic clk,
	input logic rst_n,
	input logic [DATA_WIDTH-1:0] data_in,
	input int N_in,
	input logic load_on, // positive for load, negative for last sample
	input logic load_prep,
	input logic softie, // is SISO
	output logic  [DATA_WIDTH-1:0] bit_out,  // Averaged result output
	output logic ready          // Indicates when averaging is complete
);

	logic [DATA_WIDTH-1:0] current;
	logic signed [31:0]  data_out [n-1:0];
	logic signed [31:0]  data_out_s [n-1:0];
	logic signed [31:0]  data_out_h [DATA_WIDTH-1:0];
	logic calc_done;
	int N_out;

	decoder_stack #(
		.DATA_WIDTH(DATA_WIDTH),
		.STACK_DEPTH(STACK_DEPTH)
	) stack_inst (
		.clk(clk),
		.rst_n(rst_n),
		.push(push && load_prep),
		.pop(pop),
		.data_in(data_in),
		.N_in(N_in),
		.data_out(current), 
		.N_out(N_out),
		.full(full),
		.empty(empty)
	);

	
	hard_container #(
		.DATA_WIDTH(DATA_WIDTH)
	) hard_inst (
		.clk(clk),
		.rst_n(rst_n),
		.calc_start(calc_start),
		.data_in(current),
		.N_in(N_out),
		.n_in(n),
		.a(a),
		.data_out(data_out_h),
		.calc_done(calc_done_h)

	);
	

	soft_decoder #(
		.DATA_WIDTH(DATA_WIDTH),
		.n(n),
		.a(a)
	) soft_inst (
		.clk(clk),
		.N(N_out),
		.start(calc_start),
		.strand(current),
		.likelyhood(data_out_s),
		.done(calc_done_s)
	);




	decoder_fsm #(
		.DATA_WIDTH(DATA_WIDTH),
		.STACK_DEPTH(STACK_DEPTH)
	) siso_fsm (
	.clk(clk),
	.rst_n(rst_n),
	.load_start(load_on), //--------------
	//.load_done(load_done),
	.calc_done(calc_done),
	.empty(empty),
	.done(done), // Asserted when all calculations and averaging are complete
	.pop(pop),              // Signal to pop data from the stack
	.push(push),
	.calc_start(calc_start)	
	);

	logic signed [31:0] sum_L [DATA_WIDTH-1:0];

	decoder_RtL #(
		.DATA_WIDTH(DATA_WIDTH)
	) likelyhood_to_logic (
		.input_data(sum_L),
		.output_bit(bit_out)
	);


	// Internal registers for sum and counting processed values
	//logic signed [31:0] avg_L [DATA_WIDTH-1:0];
	logic signed [31:0] count;
	//logic signed [31:0]  data_out [DATA_WIDTH-1:0];
	logic [$clog2(DATA_WIDTH+1)-1:0] N;

	always_comb begin
		if(softie) begin
			data_out = data_out_s;
			calc_done = calc_done_s;
		end	else begin
			data_out = data_out_h[n-1:0];
			calc_done = calc_done_h;
		end
	end	
	
	always_ff @(posedge clk or negedge rst_n) begin
		//count <= count + 1;
		if (!rst_n) begin
			for (int i = 0; i < DATA_WIDTH -1; i++) begin
				sum_L[i] <= 32'b0;
			end
			count <= 0;
			ready <= 0;
		end else if (calc_done && !calc_start) begin
			for (int i = 0; i < DATA_WIDTH -1; i++) begin
				sum_L[i] <= sum_L[i] + data_out[i] ;  // Accumulate the processed value
			end
			count <= count + 1;
		end else if (done) begin
			ready <= 1;                // Assert ready when averaging is done
		end
	end
endmodule
