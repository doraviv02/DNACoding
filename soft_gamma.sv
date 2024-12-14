module soft_gamma #(
    parameter logic signed [31:0] p_d = 32'b1 << 17, // 1/16 in Q8.24 format
    parameter logic signed [31:0] p_i = 32'b1 << 17, // 1/16 in Q8.24 format
    parameter logic signed [31:0] p_s = 32'b1 << 17, // 1/16 in Q8.24 format
    parameter int DATA_WIDTH
)(
    input int N, // length of sequence N
    input  logic [DATA_WIDTH-1:0] r,        // Sequence r as a binary input
    input  int t,        // Input t (assume 1-based index)
    input  int d,        // Input d
    input  int d_tag,    // Input d'
    input  logic b,         // Input b (single bit)
    output logic signed [31:0] gamma_out // Gamma output as 32-bit fixed-point number
);
    // Internal signals
    logic signed [31:0] p_t;
    logic signed [31:0] gamma_value;
    int l;    // Difference d - d_tag
    int index; // Index of predicted location

    always_comb begin // non-sequenceial calculation
        l = d - d_tag;
        p_t = (32'b1<<24) - p_d - p_i;
        if (l == -1) begin
            gamma_value = p_d; 
        end else if (l >= 0) begin
            index = d + t - 1; 
            if (index >= N || index < 0) begin
                gamma_value = 32'b0; // Out of bounds
            end else if (r[index] != b) begin
                gamma_value = fp_m(fp_p(fp_m(32'b1<<23,p_i),l),fp_m(p_t,p_s) + fp_m(32'b1<<23,fp_m(p_i,p_d)));
            end else begin
                gamma_value = fp_m(fp_p(fp_m(32'b1<<23,p_i),l) ,fp_m(p_t,(32'b1<<24)-p_s) + fp_m(32'b1<<23,fp_m(p_i,p_d)));
                //gamma_value = p_t;// + fp_m(32'b1<<23,fp_m(p_i,p_d));
            end
        end else begin  
            gamma_value = 32'b0;
        end
        gamma_out = gamma_value;
        //gamma_out = gamma_value; //
    end


    // Fixed point power function for unsigned Q8.24 format
    // Calculates x^n where x is Q8.24 and n is a non-negative integer
    function automatic logic signed [31:0] fp_p(
        input logic signed [31:0] x,     // Base in Q8.24 format
        input int n               // Non-negative integer exponent
    );
        logic signed [31:0] result;
        result = 32'b1 << 24;             // Start with 1.0
        
        // Handle special case for x^0 = 1
        if (n == 0) begin
            return 32'b1 << 24;
        end
        
        for (int i = 0; i < DATA_WIDTH ;i++ ) begin
            if (i < n)
                result = fp_m(result, x);
        end
        
        return result;
    endfunction

    /// Fixed point multiplication for unsigned Q8.24 format
     // Total width of each number is 32 bits
    function automatic logic signed [31:0] fp_m(
        input logic signed [31:0] a,  // Unsigned Q8.24 format
        input logic signed [31:0] b   // Unsigned Q8.24 format
    );
        // Intermediate result will be 64 bits
        logic [63:0] mult_result;
        
        // Perform multiplication
        mult_result = a * b;
        
        // Check for overflow (any bits set in positions 63:56)
        if (|mult_result[63:56]) begin
            fp_m = 32'h7FFF_FFFF;  // Saturate to maximum value
        end else begin
            // If no overflow, take bits [55:24] for the Q8.24 result
            fp_m = mult_result[55:24];
        end
    endfunction


endmodule
