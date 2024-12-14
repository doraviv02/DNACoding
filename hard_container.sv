module hard_container #(
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic rst_n,
    input logic calc_start,
    input logic [DATA_WIDTH-1:0] data_in,
    input int N_in,
    input int n_in,
    input int a,
    output logic signed [31:0] data_out [DATA_WIDTH-1:0],
    output logic calc_done
);

    int counter;//time waster
    logic [DATA_WIDTH-1:0] temp_data;
    logic [127:0] temp_out;

    hard_decoder hard (
        .received(data_in),
        .N(N_in),
        .n(n_in),
        .a(a),
        .out(temp_out)
    );

    always_comb begin
        for (int i=0; i <DATA_WIDTH; i++) begin
            data_out[i] = 32'b0;
        end
        for (int i=0; i < DATA_WIDTH ; i++) begin
            if ( i < N_in) begin
                if (temp_out[i]) begin
                    data_out[i] = -(32'b1<<23);
                end else begin
                    data_out[i] = (32'b1<<23);
                end
            end
        end 
    end
    always_ff @(posedge clk or negedge rst_n) begin
        calc_done <= 1'b0;
        if (!rst_n) begin
            counter <= '0;
            temp_data <= '0;
        end else if (calc_start) begin
            counter <= '0;
            temp_data <= data_in;
        end else if (counter < n_in) begin
            counter <= counter + 1;
        end else if (counter == n_in) begin
            calc_done <= 1'b1;
            counter <= '0;
        end
    end


endmodule
