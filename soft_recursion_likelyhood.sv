module soft_recursion_likelyhood #(
    parameter DATA_WIDTH = 32, 
	//parameter N = 16,          // length post-IDS
	parameter n = 10,          // length pre-IDS
	parameter a = 0     //syndrome
)(
    input logic clk,
    input int N,
    input logic start_recursion,
    input logic [DATA_WIDTH-1:0] strand, //sequence r as a binary input
    input logic signed [31:0] alpha[n-1:0][2*n:0][DATA_WIDTH:-n],
    input logic signed [31:0] beta[n:1][2*n:0][DATA_WIDTH:-n],

    output logic signed [31:0] sequence_likelyhood[n:1],
    output logic done
    
);

    int T;
    logic needed;
    logic start_calc;
    logic done_calc; 
    logic signed [31:0] likelyhood_out;

    always_ff @(posedge clk) begin 
        done <= 1'b0;
        if (start_recursion) begin
            T <= 1;
            needed <= 1'b1;
            start_calc <= 1'b1; //start allow for calculation of both alpha and beta
            done <= 1'b0;
        end 
        else begin
            if (done_calc == 1'b1 && !done) begin 
                //both alpha and beta finished. They should finish at the same time; this is just in case.
                

                sequence_likelyhood[T] <= likelyhood_out;


                //start again calculation
                start_calc <= 1'b1;

                
                // set next T
                if (T == n && needed) begin //just finished last iteration
                    done <= 1'b1;
                    needed <= 1'b0;
                end else
                    T <= T + 1;
            end 
            else
                start_calc <= 1'b0;
        end
    end


  soft_likelyhood #(
    .DATA_WIDTH(DATA_WIDTH),
    .n(n),
    .a(a)
  ) likelyhood (
    .clk(clk),
    .N(N),
    .start(start_calc),
    .t(T),
    .alpha(alpha),
    .beta(beta),
    .strand(strand),
    .likelyhood(likelyhood_out),
    .done(done_calc)
  );


endmodule