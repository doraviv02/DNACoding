module counter(
    input logic rst_n,
    input logic clk,
    input logic [31:0] num_of_strands,
    input logic cor_ready,
    output logic load_on
);
    int counter;
    always_ff @(posedge clk or negedge rst_n) begin
		//
        load_on <= 1'b0;
		if (!rst_n) begin
            counter <= 0;    
        end else if  (counter < 5) begin
            counter <= counter + 1;
        end else if (counter < num_of_strands + 5 ) begin
            load_on <= 1'b1;
            if (cor_ready)
            counter <= counter + 1;
        end
	end 

endmodule