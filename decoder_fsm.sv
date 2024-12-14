module decoder_fsm #(
	parameter DATA_WIDTH = 32,
	parameter STACK_DEPTH = 16
)(
	input logic clk,
	input logic rst_n,
	input logic load_start,
	//input logic load_done,
	input logic calc_done,
	input logic empty,
	output logic done, // Asserted when all calculations and averaging are complete
	output logic pop,              // Signal to pop data from the stack
	output logic push,
	output logic calc_start        // Signal to start calculation in the calc_module
	
);

	// State definitions for the controller FSM
	typedef enum logic [2:0] {
		IDLE,
		LOAD,
		POP_STACK,
		WAIT_CALC,
		FINISH
	} state_t;
	state_t current_state, next_state;



	// FSM to control the flow
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			current_state <= IDLE;
		else
			current_state <= next_state;
	end

	always_comb begin
		// Default signal values
		pop = 0;
		push = 0;
		calc_start = 0;
		done = 0;

		case (current_state)
			IDLE: begin
				if (load_start) begin
					push = 1;
					next_state = LOAD;
				end else
					next_state = IDLE;
			end
			LOAD: begin
				if(load_start) begin
					push = 1;
					next_state = LOAD;
				end else
					next_state = POP_STACK;
			end
			POP_STACK: begin
				if (!empty) begin
					pop = 1;  
					calc_start = 1;             // Trigger pop from the stack
					next_state = WAIT_CALC;
				end else begin
					next_state = FINISH;    // If stack is empty, finish the process
				end
			end
			WAIT_CALC: begin// Start calculation after popping
				if(empty) begin
					next_state = FINISH;
				end	else if (calc_done) begin
					next_state = POP_STACK; // Continue popping after calculation is done
				end else
					next_state = WAIT_CALC;
			end
			FINISH: begin
				done = 1;                   // Done signal to indicate all calculations finished
				next_state = IDLE;
			end
			default: next_state = IDLE;
		endcase
	end
endmodule
