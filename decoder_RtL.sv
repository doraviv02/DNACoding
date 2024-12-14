module decoder_RtL #(
    parameter DATA_WIDTH = 32
)(
    input  logic signed [31:0]    input_data [DATA_WIDTH-1:0],
    output logic   [DATA_WIDTH-1:0] output_bit 
);

    // Convert each logic signed [31:0] input to a logic bit based on sign
    always_comb begin
        for (int i = 0; i < DATA_WIDTH; i++) begin
            output_bit[i] = (input_data[i] > 0) ? 1'b0 : 1'b1;
        end
    end

endmodule
