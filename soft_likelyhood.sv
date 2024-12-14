module soft_likelyhood #(
    parameter DATA_WIDTH = 32, // Q8.24 format for alpha betta, ignore the Q thing for now
	//parameter N = 16,          // length post-IDS
	parameter n = 10,          // length pre-IDS
	parameter a = 0     //syndrome
)(
    input logic clk, 
    input int N,
    input logic start, //signal to start calculation
    input int  t, //current t, goes from 1 to n and backwards
    input logic signed [31:0] alpha[n-1:0][2*n:0][DATA_WIDTH:-n], //all alphas from prev iteration, size is 2N*2N and indices are s' and d'
    input logic signed [31:0] beta[n:1][2*n:0][DATA_WIDTH:-n],
    input logic [DATA_WIDTH-1:0] strand, //sequence r as a binary input
    
    output logic signed [31:0] likelyhood,
    output logic done
);

logic flag;
int s_tag, s1, d_tag;
logic signed [31:0] sum0,sum1, prob0,prob1;

logic signed [31:0] gamma_out[1:0][DATA_WIDTH:-n]; //output of gamma signals for s0 and s1

always_ff @( posedge clk, posedge start ) begin : calc
    if (start) begin //begin running the module - initialize
        flag <= 1'b1;
        s_tag <= 0;
        done <= 1'b0;
        d_tag <= -t+1; //at each stage can only decrease by one. for alpha is t-1
        
        prob0 <= 32'b0;
        prob1 <= 32'b0;
    end
    else if (flag)  begin
        //add the values of current iteration to probability sum
        prob0 <= prob0 + sum0;
        prob1 <= prob1 + sum1;

        if (s_tag == 2*n && d_tag==N-t) begin//this is last iteration
            done <= 1'b1;
            //flag <= 1'b0;//--------------------------------------------
            if(prob1 == 0)
                likelyhood <= (32'sb1<<30); // setting to 64. Just a big number
            else if (prob0 == 0)
                likelyhood <= -(32'sb1<<30); //setting to -64
            else 
                likelyhood <= fp_ln(prob0) - fp_ln(prob1);
        end
        else if (d_tag == N-t) begin
            d_tag <= -t;
            s_tag <= s_tag + 1;
        end
        else
            d_tag <= d_tag + 1;
    end
end

always_comb begin 
    s1 = (s_tag + t) % (2*n+1);
    sum0 = 0;
    sum1 = 0;
    for (int d=0; d<=2*DATA_WIDTH; ++d) begin
        if (d<=N+n) begin
            sum0 += fp_m(alpha[t-1][s_tag][d_tag],fp_m(gamma_out[0][d-n],beta[t][s_tag][d-n]));
            sum1 += fp_m(alpha[t-1][s_tag][d_tag],fp_m(gamma_out[1][d-n],beta[t][s1][d-n]));
        end
    end
end

genvar d;
generate;
    for (d = 0;d<=DATA_WIDTH+n;d++) begin
        soft_gamma #(
            .DATA_WIDTH(DATA_WIDTH) // pass on the width 
        ) gamma_s0 (
            .N(N),
            .r(strand),        // Sequence r as a binary input
            .t(t),        // Input t (assume 1-based index)
            .d(d-n),        // Input d
            .d_tag(d_tag),    // Input d'
            .b(1'b0),         // Input b (single bit)
            .gamma_out(gamma_out[0][d-n]) // Gamma output as 32-bit fixed-point number
            );
        soft_gamma #(
            .DATA_WIDTH(DATA_WIDTH)
        ) gamma_s1 (
            .N(N),
            .r(strand),        // Sequence r as a binary input
            .t(t),        // Input t (assume 1-based index)
            .d(d-n),        // Input d
            .d_tag(d_tag),    // Input d'
            .b(1'b1),         // Input b (single bit)
            .gamma_out(gamma_out[1][d-n]) // Gamma output as 32-bit fixed-point number
        );
    end
endgenerate

// log calculation
function automatic logic signed [31:0] fp_ln(
    input logic signed [31:0] in
); 
    logic signed [31:0] y;
    // we have 3 different funcitons to approximate, check which area
    if (in > (32'sb11<<23)) begin // larger than 1.5, approx arund x=2
        y = in - (32'sb1<<25); // x-2
        fp_ln = (32'sh00_B1_33_A2) + (y>>1)-(fp_p(y,2)>>3)+fp_m(32'sh00_0A_AA_AC,fp_p(y,3));
    end 
    else if ((in < (32'sb11<<22)) && (in > (32'sb111<<19)) ) begin //smaller than 0.75 bigger than 0.21875, approx around x=0.5
        y = in - (32'sb1<<23); // x - 1/2
        fp_ln = (-32'sh00_B1_33_A2)+(y<<1)-(fp_p(y,2)<<1)+fp_m(32'sh02AA_AAAA,fp_p(y,3));
        //fp_ln = in-(32'sb1<<23);
    end
    else if (in < (32'sb111<<19) ) begin //smaller than 0.21875, approx around x = 0.125
        y = in - (32'sb1<<21); // x-1/8
        fp_ln = (-32'sh02_13_B4_F7)+(y<<3)-(fp_p(y,2)<<5)+fp_m(32'shAAAAAAB3,fp_p(y,3)); //setting to -64
    end 
    else begin // in between, approx around x=1
        y = in - (32'sb1<<24); // x-1
        fp_ln = y-fp_m(32'sb1<<24,fp_p(y,2))+fp_m(32'sh00_55_55_55,fp_p(y,3));
    end

endfunction



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
    
    for (int i = 0; i < n ;i++ ) begin
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

    fp_m = mult_result[55:24];
endfunction

endmodule