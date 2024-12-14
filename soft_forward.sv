module soft_forward #(
    parameter DATA_WIDTH = 32, // Q8.24 format for alpha betta, ignore the Q thing for now
	parameter n = 10,          // length post-IDS          // length pre-IDS
	parameter a = 0     //syndrome
)(
    input logic clk, //TODO: tell sagi about this
    input int N,
    input logic calc_alpha, //signal to start calculation of alpha
    input int  t, //current t, goes from 0 to N and backwards
    input logic signed [31:0] alpha_in[2*n:0][DATA_WIDTH:-n], //all alphas from prev iteration, size is 2N*2N and indices are s' and d'
    input logic [DATA_WIDTH-1:0] strand, //sequence r as a binary input

    output logic signed [31:0]  alpha_out[2*n:0][DATA_WIDTH:-n], // Output alpha values
    output logic done
);
logic flag;
int s, d, s1_tag;
logic signed [31:0] sum;
logic signed [31:0] temp;
logic signed [31:0] gamma_out[1:0][DATA_WIDTH:-n]; //output of gamma signals for s0 and s1

always_ff @( posedge clk, posedge calc_alpha ) begin : calc
    if (calc_alpha) begin //begin running the module - initialize
        flag <= 1'b1;
        done <= 1'b0;
        s <= 0;
        d <= -t; //at each stage can only decrease by one
        for (int i = 0;i<=2*n;i++ ) begin
            for (int j = 0;j<=DATA_WIDTH+n ;j++ ) begin
                alpha_out[i][j-n] <= 32'b0;
            end
        end
    end
    else if (flag)  begin
        if (t==0) begin
            alpha_out[0][0] <= (32'b1<<24);
            done <= 1'b1;
        end
        else begin //actually have calculation

            //calculate all the alpha values - in separate block

            //add the values to the alpha_out array
            alpha_out[s][d] <= temp;


            if (s == 2*n && d==N-t) begin//this is last iteration
                done <= 1'b1;
            end
            else if (d == N-t) begin
                d <= -t;
                s <= s+1;
            end
            else
                d <= d + 1;
        end
    end
end

always_comb begin : update_out
    temp = 0; //alpha_out[s][d];
    s1_tag = (s-t+2*n+1) % (2*n+1); //s0_tag is just s
    //temp = alpha_in[s][d+N];
    
    for (int d_tag=0; d_tag<=2*DATA_WIDTH; ++d_tag) begin
        if (d_tag <= N+n)
            temp += fp_m(gamma_out[0][d_tag-n], alpha_in[s][d_tag-n]) + fp_m(gamma_out[1][d_tag-n], alpha_in[s1_tag][d_tag-n]);
    end
end


genvar d_tag;
generate;
    for (d_tag = 0;d_tag<=2*DATA_WIDTH;d_tag++) begin
        soft_gamma #(
            .DATA_WIDTH(DATA_WIDTH) // pass on the width 
        ) gamma_s0 (
            .N(N),
            .r(strand),        // Sequence r as a binary input
            .t(t),        // Input t (assume 1-based index)
            .d(d),        // Input d
            .d_tag(d_tag-n),    // Input d'
            .b(1'b0),         // Input b (single bit)
            .gamma_out(gamma_out[0][d_tag-n]) // Gamma output as 32-bit fixed-point number
            );
        soft_gamma #(
            .DATA_WIDTH(DATA_WIDTH)
        ) gamma_s1 (
            .N(N),
            .r(strand),        // Sequence r as a binary input
            .t(t),        // Input t (assume 1-based index)
            .d(d),        // Input d
            .d_tag(d_tag-n),    // Input d'
            .b(1'b1),         // Input b (single bit)
            .gamma_out(gamma_out[1][d_tag-n]) // Gamma output as 32-bit fixed-point number
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
