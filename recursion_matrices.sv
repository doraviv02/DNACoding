module recursion_matrices #(
    parameter DATA_WIDTH = 32, // Q8.24 format for alpha betta, ignore the Q thing for now
	  parameter N = 16,          // length post-IDS
	  parameter n = 10,          // length pre-IDS
	  parameter a = 0     //syndrome
)(
    input logic clk,
    input logic start_recursion,
    input logic [DATA_WIDTH-1:0] strand, //sequence r as a binary input
    

    output logic signed [31:0] alpha[n-1:0][2*n:0][N:-n],
    output logic signed [31:0] beta[n:1][2*n:0][N:-n],
    output logic done

);

    int T;
    logic start_calc;
    logic signed [31:0] alpha_in[2*n:0][N:-n];
    logic signed [31:0] beta_in[2*n:0][N:-n];
    logic signed [31:0] alpha_out[2*n:0][N:-n];
    logic signed [31:0] beta_out[2*n:0][N:-n];
    logic [1:0] done_calc;

    always_ff @(posedge clk) begin 
        if (start_recursion) begin
            T <= 0;
            start_calc <= 1'b1; //start allow for calculation of both alpha and beta
            done <= 1'b0;
        end 
        else begin
            if (done_calc == 2'b11) begin 
                //both alpha and beta finished. They should finish at the same time; this is just in case.

                //update alpha and beta matrix
                alpha[T] <= alpha_out;
                beta[n-T] <= beta_out;
                
                //set new inputs
                alpha_in <= alpha_out;
                beta_in <= beta_out;


                //start again calculation
                start_calc <=1'b1;

                
                // set next T
                if (T == n-1) //just finished last iteration
                    done <= 1'b1;
                else
                    T <= T + 1;
            end 
            else
                start_calc <= 1'b0;
        end
    end


  soft_forward #(
    .DATA_WIDTH(DATA_WIDTH),
    .N(N),
    .n(n),
    .a(a)
  ) forward (
    .clk(clk),
    .calc_alpha(start_calc),
    .t(T),
    .alpha_in(alpha_in),
    .strand(strand),
    .alpha_out(alpha_out),
    .done(done_calc[0])
  );

  soft_backward #(
    .DATA_WIDTH(DATA_WIDTH),
    .N(N),
    .n(n),
    .a(a)
    ) backward (
    .clk(clk),
    .calc_beta(start_calc),
    .t(n-T),
    .beta_in(beta_in),
    .strand(strand),
    .beta_out(beta_out),
    .done(done_calc[1])
  );



endmodule