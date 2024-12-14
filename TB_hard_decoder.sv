module TB_hard_decoder;

    logic [16:0] received;
    logic [31:0] N;
    logic [31:0] n;
    logic [31:0] a;
    logic [16:0] out;

    // Instantiate the Unit Under Test (UUT)
    hard_decoder uut (
        .received(received),
        .N(N),
        .n(n),
        .a(a),
        .out(out)
    );


    initial begin
        received = 16'b0101;
        N = 4;
        n = 3;
        a = 2;
        #10;
        received = 16'b0101;
        N = 4;
        n = 3;
        a = 3;
        #10;
        received = 16'b0101;
        N = 4;
        n = 3;
        a = 1;
        #10;
        received = 16'b0101;
        N = 4;
        n = 3;
        a = 4;
        
        #10;
        received = 16'b0101;
        N = 4;
        n = 4;
        a = 3;
        #10;
        received = 16'b0101;
        N = 4;
        n = 4;
        a = 6;
        #10;
        received = 16'b0101;
        N = 4;
        n = 4;
        a = 1;
        #10;
        received = 16'b0101;
        N = 4;
        n = 4;
        a = 8;


        #10;
        received = 16'b0101;
        N = 4;
        n = 5;
        a = 7;
        #10;
        received = 16'b0101;
        N = 4;
        n = 5;
        a = 8;
        #10;
        received = 16'b0101;
        N = 4;
        n = 5;
        a = 9;

        #10
        received = 16'b0101;
        N = 4;
        n = 5;
        a = 6;
        #10
        received = 16'b0101;
        N = 4;
        n = 5;
        a = 5;
        #10
        received = 16'b0101;
        N = 4;
        n = 5;
        a = 4;

        
    end
endmodule