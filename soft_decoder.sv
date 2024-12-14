module soft_decoder #(
    parameter DATA_WIDTH = 32, // Q8.24 format for alpha betta, ignore the Q thing for now
	//parameter N = 16,          // length post-IDS
	parameter n = 10,          // length pre-IDS
	parameter a = 0     //syndrome
)(
    input logic clk, 
    input int N,
    input logic start, //signal to start calculation
    input logic [DATA_WIDTH-1:0] strand, //sequence r as a binary input
    output logic signed [31:0] likelyhood[n:1],
    output logic done
);

    logic signed [31:0] alpha_in[n-1:0][2*n:0][DATA_WIDTH:-n];
    logic signed [31:0] beta_in[n:1][2*n:0][DATA_WIDTH:-n];
    logic signed [31:0] alpha_out[n-1:0][2*n:0][DATA_WIDTH:-n];
    logic signed [31:0] beta_out[n:1][2*n:0][DATA_WIDTH:-n];

    logic start_matrices, start_likelyhood;
    logic matrices_done;
    
    logic flag;

    always_ff @(posedge clk, posedge start) begin
        // defaults
        start_matrices <= 1'b0;
        start_likelyhood <= 1'b0;

        if (start) begin //can start calculation
            start_matrices <= 1'b1;
            start_likelyhood <= 1'b0;
            flag <= 1'b1;
        end
        else if (flag) begin //means that we started the process
            if (matrices_done) begin //finished matrices, move on to likelyhod
                start_likelyhood <= 1'b1;
                alpha_in <= alpha_out;
                beta_in <= beta_out;
                flag <= 1'b0; // so we only perform this once
            end
        end
    end

    soft_recursion_matrices #(
        .DATA_WIDTH(DATA_WIDTH),
        .n(n),
        .a(a)
    ) recursion_matrices (
        .clk(clk),
        .N(N),
        .start_recursion(start_matrices),
        .strand(strand),
        .alpha(alpha_out),
        .beta(beta_out),
        .done(matrices_done)
    );

    soft_recursion_likelyhood #(
        .DATA_WIDTH(DATA_WIDTH),
        .n(n),
        .a(a)
    ) recursion_likelyhood (
        .clk(clk),
        .N(N),
        .start_recursion(start_likelyhood),
        .strand(strand),
        .alpha(alpha_in),
        .beta(beta_in),
        .sequence_likelyhood(likelyhood),
        .done(done)
    );



endmodule