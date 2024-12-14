module xorshift_prng #(
    parameter TIMES = 4,    // number of 32bit rands
    parameter SEED = 4      // seed for steps, preferably prime 
)(
    input  logic rst_n,     // Active low reset
    input  logic clk,
    output logic [31:0] rand_out  // Random number output
);

    // Internal state register
    logic [31:0] state;
    logic [31:0] next_state;
    
    // Array of intermediate values for the generate block
    logic [31:0] temp_arr [SEED+1];
    logic [31:0] temp1_arr [SEED];
    logic [31:0] temp2_arr [SEED];

    // Sequential state update
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= 32'hFFFF_FFFF;  // Non-zero seed value
        end
        else begin
            state <= next_state;
        end
    end

    // Initial XORShift for temp_arr[0]
    always_comb begin
        temp_arr[0] = state;
        temp1_arr[0] = (temp_arr[0] ^ (temp_arr[0] << 13));
        temp2_arr[0] = temp1_arr[0] ^ (temp1_arr[0] >> 17);
        temp_arr[1] = temp2_arr[0] ^ (temp2_arr[0] << 5);
    end

    // Generate block to create SEED iterations of the XORShift
    genvar i;
    generate
        for (i = 1; i < SEED; i++) begin : xorshift_stages
            always_comb begin
                temp1_arr[i] = temp_arr[i] ^ (temp_arr[i] << 13);
                temp2_arr[i] = temp1_arr[i] ^ (temp1_arr[i] >> 17);
                temp_arr[i+1] = temp2_arr[i] ^ (temp2_arr[i] << 5);
            end
        end
    endgenerate

    // Final state assignment
    assign next_state = temp_arr[SEED];
    
    // Output assignment
    assign rand_out = state;

endmodule