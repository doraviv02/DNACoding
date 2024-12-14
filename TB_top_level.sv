module TB_top_level();

    // Parameters
    localparam DATA_WIDTH = 32;
    localparam STACK_DEPTH = 16;
    localparam k = 5;
    localparam a = 4;
    localparam n = 10;  // Using the same function as in top_level

    // Function to calculate n (copied from top_level for testbench use)


    // Signals
    logic clk;
    logic rst_n;
    int num_of_strands;
    logic [k-1:0] data_in;
    logic softie;
    logic [k-1:0] recovered;
    logic good_syndrome;
    logic ready;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // DUT instantiation
    top_level #(
        .DATA_WIDTH(DATA_WIDTH),
        .STACK_DEPTH(STACK_DEPTH),
        .k(k),
        .a(a)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .num_of_strands(num_of_strands),
        .data_in(data_in),
        .softie(softie),
        .recovered(recovered),
        .good_syndrome(good_syndrome),
        .ready(ready)
    );

    // Test stimulus
    initial begin
        // Initialize test
        rst_n = 1'b0;
        num_of_strands = 0;
        data_in = '0;
        softie = 1'b0;

        // Wait for 100ns and then release reset
        #100;
        rst_n = 1'b1;
        
        // Test Case 1: Basic Operation
        @(posedge clk);
        num_of_strands = 5;
        data_in = 5'b0001;
        softie = 1'b1;
        
        // Wait for processing
        wait(ready);
        $display( "in=%b out=%b", data_in, recovered);
        $finish;
    end


    
endmodule
