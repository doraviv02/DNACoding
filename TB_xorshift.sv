module TB_xorshift();
    // Parameters
    parameter WIDTH = 32;
    parameter SEED = 1;

    // Signals
    logic rst_n;
    logic clk;
    logic [WIDTH-1:0] rand_out;

    // Instantiate the PRNG
xorshift_prng #(
    .TIMES       (4),
    // number of 32bit rands
    // seed for steps, preferably prime 
    .SEED        (SEED)
) u_xorshift_prng (
    .rst_n       (rst_n),
    // Active low reset
    .clk         (clk),
    // Random number output
    .rand_out    (rand_out)
);

  initial begin
    clk = 0;
    forever #(2) clk = ~clk;
  end
    // Test stimulus
    initial begin
        // Test name
        $display("Starting XORShift PRNG Test with zeros input");
        
        // Initialize
        rst_n = 0;

        #10;

        rst_n = 1;
        #10;
        
    
        // Try different SEED iterations
        for (int i = 1; i <= 10; i++) begin
            $display("got %b", rand_out);
                    @(posedge clk);
        end
        
        // Test finished
        $display("Test completed");
        #10;
        $finish;
    end



endmodule