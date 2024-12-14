/*------------------------------------------------------------------------------
 * File          : vt_encode_u.sv
 * Project       : RTL
 * Author        : epdasf
 * Creation date : Sep 1, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

module vt_encode #(
	parameter k = 5,                // Number of information bits
	parameter n = find_n(k),        // Length of the output codeword
	parameter SYNDROME_VAL = 0      // Desired constant syndrome value
)(
	input wire [k-1:0] data_in,     // Input data (k bits)
	output reg [n-1:0] codeword,    // Output codeword with parity bits
	output reg good_syndrome        // Indicates if the syndrome is correct
);

	// Function to calculate n given k
	function integer find_n(input integer k);
		integer n_guess;
		begin
			n_guess = k;
			while (k > (n_guess - $clog2(n_guess) - 1)) begin
				n_guess = n_guess + 1;
			end
			find_n = n_guess;
		end
	endfunction
	

	integer i;
	integer sum;
	integer parity_sum;
	integer m;
	integer index;
	reg [n-1:0] parity_index;
	integer temp;
	integer j;
	reg [n-1:0] is_parity;
	integer num_data_bits;
	integer last;

	always @(*) begin
		// Initialize codeword and temporary codeword
		codeword = 0;
		temp = 0;
		is_parity = 0;
		sum = 0;
		j = 0;
		last = 0;
		num_data_bits = 0;

		// Determine parity positions
		for (i = 0; i < n; i = i + 1) begin
			if (((i + 1) & i) == 0) begin
				is_parity[i] = 1;
				last = i;
			end	
			else if (j < k) begin
				codeword[i] = data_in[j];
				sum = sum + ((i+1) * codeword[i]);
				j = j+1;
			end
		end
		if (k + $clog2(last + 1)+1 < n ) begin
			is_parity[n-1] = 1;
		end

		/* Place data bits and calculate sum
		for (i = 1; i <= n; i = i + 1) begin
			if (!is_parity[i-1]) begin
				temp_codeword[i-1] = data_in[j];
				sum = sum + (i * temp_codeword[i-1]);
				j = j + 1;
				num_data_bits = num_data_bits + 1;
			end
		end
		*/

		/* Handle remaining positions if any
		if (num_data_bits < k) begin
			for (i = num_data_bits; i < k; i = i + 1) begin
				codeword[i] = data_in[i];
			end
		end*/

		// Determine parity bits
		m = 2 * n + 1;
		index = 0;
		for (i = 0; i < (n+1)/2;i = i+1 ) begin
			if (((m * i + SYNDROME_VAL - sum) >= 0)&&(temp == 0)) begin
				index = i;
				temp = 1;
			end
		end
		parity_sum = m * index + SYNDROME_VAL - sum;

		// Assign parity bits
		for (i = n -1; i >= 0 ; i = i - 1) begin
			if (is_parity[i]) begin
				if (parity_sum >= i+1) begin
					parity_sum = parity_sum - (i+1);
					codeword[i] = 1;
				end else begin
					codeword[i] = 0;
				end
			end
		end

		// Check if the final syndrome matches the desired value
		sum = 0;
		for (i = 0; i < n; i = i + 1) begin
			if (codeword[i]) begin
				sum = sum + ((i + 1));
			end
		end
		good_syndrome = (sum % (2 * n + 1)) == SYNDROME_VAL;
	end

endmodule
