module soft_backward #(
    parameter DATA_WIDTH = 32, 
	//parameter N = 16,          // length post-IDS
	parameter n = 10,          // length pre-IDS
	parameter a = 0     //syndrome
)(
    input logic clk, 
    input int N,
    input logic calc_beta, //signal to start calculation of beta
    input int  t, //current t, goes from 0 to N and backwards
    input logic signed [31:0] beta_in[2*n:0][DATA_WIDTH:-n], //all alphas from prev iteration, size is 2n*(N+n) and indices are s' and d'
    input logic [DATA_WIDTH-1:0] strand, //sequence r as a binary input

    output logic signed [31:0]  beta_out[2*n:0][DATA_WIDTH:-n], // Output alpha values for this iteration
    output logic done
);

logic flag;
int s_tag, d_tag, s1;
logic signed [31:0] sum;
logic signed [31:0] temp;
logic signed [31:0] gamma_out[1:0][DATA_WIDTH:-n]; //output of gamma signals for s0 and s1

always_ff @( posedge clk, posedge calc_beta ) begin : calc
    if (calc_beta) begin //begin running the module - initialize
        flag <= 1'b1;
        done <= 1'b0;
        s_tag <= 0;
        d_tag <= -t; //at each stage can only decrease by one
        for (int i = 0;i<=2*n;i++ ) begin
            for (int j = 0;j<=DATA_WIDTH+n ;j++ ) begin
                beta_out[i][j-n] <= 32'b0;
            end
        end
    end
    else if (flag) begin
        if (t==n) begin
            beta_out[a][N-n] <= (32'b1<<24);
            done <= 1'b1;
        end
        else begin //actually have calculation

            //calculate all the beta values - in separate block

            //add the values to the beta_out array
            beta_out[s_tag][d_tag] <= temp;


            if (s_tag == 2*n && d_tag==N-t) begin//this is last iteration
                done <= 1'b1;
            end
            else if (d_tag == N-t) begin
                d_tag <= -t;
                s_tag <= s_tag + 1;
            end
            else
                d_tag <= d_tag + 1;
        end
    end
end


always_comb begin : update_out
    temp = 0;//beta_out[s_tag][d_tag];
    s1 = (s_tag+t+1) % (2*n+1); //s0 is just s_tag. t+1 because from next state
    //temp = alpha_in[s][d+N];
    
    for (int d1=0; d1<=2*DATA_WIDTH; ++d1) begin
        if (d1 <= N+n)
            temp += fp_m(gamma_out[0][d1-n], beta_in[s_tag][d1-n]) + fp_m(gamma_out[1][d1-n], beta_in[s1][d1-n]);
       
    end

end

/*always_comb begin : curr_sum //for finding the sum of all alpha values
    sum = 0;
    for (int s1 = 0; s1<=2*n; s1++) begin
        for (int d1 = -n; d1<N; d1++) begin
            sum += beta_out[s1][d1];
        end
    end
end*/

genvar d;
generate;
    for (d = 0;d<=2*DATA_WIDTH;d++) begin
        soft_gamma #(
            .DATA_WIDTH(DATA_WIDTH) // pass on the width 
        ) gamma_s0 (
            .N(N),
            .r(strand),        // Sequence r as a binary input
            .t(t+1),        // Input t (assume 1-based index)
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
            .t(t+1),        // Input t (assume 1-based index)
            .d(d-n),        // Input d
            .d_tag(d_tag),    // Input d'
            .b(1'b1),         // Input b (single bit)
            .gamma_out(gamma_out[1][d-n]) // Gamma output as 32-bit fixed-point number
        );
    end
endgenerate

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
        fp_m = 32'hFFFF_FFFF;  // Saturate to maximum value
    end else begin
        // If no overflow, take bits [55:24] for the Q8.24 result
        fp_m = mult_result[55:24];
    end
endfunction


endmodule
