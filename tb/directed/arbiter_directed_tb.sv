`timescale 1ns/1ps

module arbiter_directed_tb;
    parameter MAX_HOLD = 8;
    parameter AGE_THRESHOLD = 4;
    parameter N = 4;
    
    logic clk;
    logic rst_n;
    logic [N-1:0] req;
    logic scheme;

    logic [N-1:0] gnt;
    logic gnt_valid;

    initial clk = 0;
    always #5 clk = ~clk;
    
    arbiter_top #(
        .MAX_HOLD(MAX_HOLD),
        .AGE_THRESHOLD(AGE_THRESHOLD),
        .N(N)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .req(req),
        .scheme(scheme),
        .gnt(gnt),
        .gnt_valid(gnt_valid)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, arbiter_directed_tb);

        req = '0;
        scheme = 0;
        rst_n = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;
        #1;
        
        // Test 1
        req = 4'b0001;
        @(posedge clk);
        #1;

        if (gnt == 4'b0001)
            $display("PASS: single requestor test");
        else
            $display("FAIL: single requestor test, gnt = %b", gnt);

        // Test 2 
        req   = 4'b0000;
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        #1;
        
        req = 4'b1111;
        @(posedge clk);
        #1;

        if (gnt == 4'b0001)
            $display("PASS: multi requestor test");
        else
            $display("FAIL: multi requestor test, gnt = %b", gnt);
        
        // Test 3 
        req = 4'b0000;
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        #1; 
        
        @(posedge clk);
        #1;
        req = 4'b0001;
        
        repeat (3) begin
            @(posedge clk);
            #1;

            assert (gnt == 4'b0001) else $error("Target failed: Expected gnt=0001, got %b", gnt);
            assert (gnt_valid == 1'b1) else $error("Target failed: Expected gnt_valid=1");
        end

        if (gnt == 4'b0001)
            $display("PASS: hold test");
        else
            $display("FAIL: hold test, gnt = %b", gnt);
        
        // Test 4 
        req = 4'b0000;
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        #1; 

        req = 4'b0001;
        @(posedge clk); #1;
        req = 4'b0000;
        @(posedge clk); #1;
        req = 4'b0010;
        @(posedge clk); #1;
        @(posedge clk); #1;

        if (gnt == 4'b0010)
            $display("PASS: release test");
        else
            $display("FAIL: release test, gnt = %b", gnt);

        // Test 5 
        scheme = 1;
        req = 4'b0000;
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        #1;

        req = 4'b1111;
        @(posedge clk);
        #1;

        for (int i = 0; i < 4; i++) begin
            // check gnt after reassert
            assert(gnt == (4'b1 << i)) else $error("Round-robin failed at index %0d: Expected %4b, got %4b", i, (4'b1 << i), gnt);
        
            // deassert current winner, wait, reassert
            req = req & ~(4'b1 << i);
            @(posedge clk); #1;
            req = 4'b1111;
            @(posedge clk); #1;
        end

        // Test 6
        scheme = 0;
        req = 4'b0000;
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        #1;
        
        req = 4'b0001;
        @(posedge clk);
        #1;

        repeat (MAX_HOLD - 1) begin
            assert (gnt == 4'b0001) else $error("Target failed: Expected gnt=0001, got %b", gnt);
            @(posedge clk); #1;
        end

        @(posedge clk); #1;
        if (gnt == 4'b0000)
            $display("PASS: max hold test");
        else
            $display("FAIL: max hold test, gnt should have cleared, got %b", gnt);
        $finish;
    end

endmodule