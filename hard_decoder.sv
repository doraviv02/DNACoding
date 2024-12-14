module hard_decoder #(
    parameter DATA_WIDTH = 32
)(
    input logic[31:0] received,
    input logic [31:0] N,
    input logic [31:0] n,
    input logic [31:0] a,
    output logic [127:0] out
);
    logic [31:0] digit_sum;
    logic [31:0] syndrome;
    logic [31:0] diff;
    logic [31:0] x;
    logic [31:0] change_index;
    logic deleted_bit;

    logic [31:0] temp;

    // finding the relevant parameters
    always_comb begin
        digit_sum = 0;
        syndrome = 0;
        for (int i=0; i < DATA_WIDTH; i++) begin
            if (i < N) begin
                digit_sum += received[i];
                syndrome += (i+1)*received[i];
            end
        end
    
        diff = (syndrome> a)?syndrome-a:a-syndrome;
        out = received; // default if input isn't valid
        change_index = -1;
        temp = (n>N)?n-N:N-n;
        if (temp <= 1 && diff <= n+1) begin
            if (N == n+1) begin //bit was inserted
                if (diff > digit_sum) begin // 1 inserted
					change_index = 0;
					x = diff - digit_sum; //the to the left of the x'th 0 in the sequence
					for (int i = 0; i< DATA_WIDTH; i++) begin
						if (i<N && x>0) begin
							if(!received[i]) x--;
							change_index++;
						end
					end
				end
                else if (diff < digit_sum) begin // 0 is inserted
                    change_index = N-1;
                    x = diff; // to the right of the x'th 1 in the sequence FROM THE END 

                    for(int i = DATA_WIDTH-1; i >= 0; i--) begin
                        if (i<N && x>0) begin
                            if (received[i]) x--;
                            change_index--;
                        end
                    end
                end
                else begin // we don't know what was inserted but it is the first digit anyways
                    change_index=0; //removing only first element
                end
                for (int i=0; i<DATA_WIDTH; i++) begin
                    if (i<N) begin
                        out[i] = (i>=change_index)?out[i+1]:out[i];
                    end
                end
            end
            if (N == n-1) begin // bit was deleted
                deleted_bit = 0;
                if (diff>digit_sum) begin // 1 was deleted
                    deleted_bit = 1;
                    change_index = 0;
                    x = diff - (digit_sum + 1); // plus 1 becasue the 1 was deleted
                    for (int i=0; i<DATA_WIDTH; i++) begin
                        if (i<N && x>0) begin
                            if (received[i]) x--;
                            change_index++;
                        end
                    end
                end
                else if (diff == 0) begin //0 deleted, edge case where it was last element
                    change_index = N;
                end
                else if (diff < digit_sum) begin // 0 deleted
                    change_index = N-1; //this is the index where we want to insert so it is not to left of 1th in sequence this time
                    x = diff; // to the left of the x'th 1 in the sequence FROM THE END 
                    for (int i=DATA_WIDTH-1; i>=0; i--) begin
                        if (i<N && x>0) begin
                            if (received[i]) x--;
                            change_index--;
                        end
                    end
                end
                else begin //has to be 0 that was deleted, and it was first element
                    change_index = 0;
                end

                //actually insert the bit
                for (int i=0; i<=DATA_WIDTH; i++) begin
                    if (i<=N) begin
                        if (i == change_index)
                            out[i] = deleted_bit;
                        else
                            out[i] = i>change_index?received[i-1]:received[i];
                    end
                end
            end
            if (N == n) begin //bit was flipped
                out[diff-1] = !out[diff-1];
            end

        end 
    end
endmodule