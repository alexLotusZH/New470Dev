// Note: This testbench is heavily commented, feel free to read the comments
// to understand what it is doing, but you don't need to read every comment

// LAB2 TODO: find and edit the 'LAB2 TODO' sections here as described in the lab assignment

module testbench;

    // Module parameters:
    parameter MAX_64BIT_NUM = 64'hFFFF_FFFF_FFFF_FFFF;

    // We need to define inputs and output for the module we wish to test.
    // In general, inputs should be registers (since a register is a physical
    // device that can hold state and can be wired from) and outputs should
    // be wires (since we only need to read the value of the output, we have
    // no desire or need to latch it)
    logic [63:0] A, B;
    logic [63:0] Sum;
    logic Cin;
    logic Cout;

    // Strictly speaking, this is an asynchronous circuit, and thus we do not
    // need a clock. We'll use one to delimit test cases, as it makes looking
    // at the output much easier.
    logic clock;

    // Need a number? It's a testbench, we can do that! Conceptually these are
    // much more like variables from C, and do not necessarily correlate to any
    // physical hardware (thus they can only be used in testbenches)
    integer /*[63:0]*/ i, j, k;

    // Now we declare an instance of the module we'd like to test, in this case
    // the 64-bit full adder. We also wire in the signals declared above.
    full_adder_64bit DUT(
        .A(A),
        .B(B),
        .carry_in(Cin),
        .S(Sum),
        .carry_out(Cout)
    );
    // NOTE: DUT stands for Device Under Test, a common term in industry


    // "tasks" are verilog-speak for functions. These are really useful and help
    // to save on a lot of repeated / duplicated work.
    task exit_on_error;
        input [63:0] A, B, Sum;
        input Cin, Cout;
        begin
            $display("@@@ Incorrect at time %4.0f", $time);
            $display("@@@ Time:%4.0f clock:%b A:%h B:%h CIN:%b SUM:%h COUT:%b", $time, clock, A, B, Cin, Sum, Cout);
            $display("@@@ expected sum=%b", (A+B+Cin) );
            $finish;
        end
    endtask


    // LAB2 TODO: there's something wrong with this task, how should you fix it??
    // hint: (try comparing to full_adder_1bit_test.sv)
    task compare_correct_sum;
        input [63:0] A, B, Sum;
        input Cin, Cout;
        begin
            logic [64:0] ANSWER = A+B+Cin;
            // Check the answer...
            if ( !((Sum == ANSWER[63:0]) && (Cout == ANSWER[64])) ) begin
                exit_on_error( A, B, Sum, Cin, Cout );
            end
            // What doesn't this function test that it probably should?
        end
    endtask


    // Set up the clock
    // CLOCK_PERIOD is defined on the commandline by the makefile
    always begin
        #(`CLOCK_PERIOD/2.0);
        clock = ~clock;
    end


    // Start the "real" testbench here. 'initial' is the beginning of simulated time.
    initial begin
        // Monitors can be really useful, but for larger testbenches, they can dump
        // a huge amount of text to the screen. Conceptually a monitor is a "magic"
        // printf that will print itself any time one of the signals changes.
        // LAB2 TODO: try uncommenting this line and running the testbench...
        // $monitor("Time:%4.0f clock:%b A:%h B:%h CIN:%b SUM:%h COUT:%b", $time, clock, A, B, Cin, Sum, Cout);

        // Recall that verilog has an "unknown" state (x) which every signal
        // starts at. In practice, most internal registers will get set by a
        // reset signal and you will only need to specify testbench signals here
        A   = 64'd0;
        B   = 64'd0;
        Cin = 0;

        // Don't forget to initialize the clock! Otherwise that always block
        // above will just keep inverting "x" to "x".
        clock = 0;

        $display("STARTING TESTBENCH!");

        // Finally, we can get to actually testing things!
        // (Remember you can use non-synthesizable Verilog in testbenches)

        // ---- Test Every Possible Input ---- //
        // Here, we present a method to test every possible input
        @(negedge clock);
        // For every input A, 0..2^64-1
        /*
        for (i = 0; i <= 64'hFFFF_FFFF_FFFF_FFFF; i = i+1) begin
            // For every input B, 0..2^64-1
            for (j = 0; j <= 64'hFFFF_FFFF_FFFF_FFFF ; j = j+1) begin
                // for the carry bit
                for (k = 0; k <= 1; k = k+1) begin
                    // Set the inputs
                    A   = i;
                    B   = j;
                    Cin = k[0];
                    // protip: You could make this more concise via brace concatenation:
                    //         {A, B, Cin} = {i, j, k[0]};
                    $display("MAN");
                    // Since there's no clock, we have to add a delay to allow signals to propagate
                    // And then check the result (aren't tasks great?!)
                    #1 compare_correct_sum(A, B, Sum, Cin, Cout);
                    @(negedge clock);
                end
            end
            // How long will it take for this line to print?
            // How many times does it have to print?
            $display("Finished one inner loop");
            // LAB2 TODO: run the testbench once, then figure out what to do with this section
        end
        */


        // ---- Test Specific Edge Cases ---- //
        // If we wish to test some specific cases instead...

        // LAB2 TODO: add tests to achieve good (if imperfect) coverage.
        //            Don't skimp on edge case tests, these are some of
        //            the most valuable types of tests you can add.
        //            Should test multiple types of things and specific values.
        //            Especially "interesting" inputs or tests that generate
        //            "interesting" outputs (what outputs seem interestng to you?)

        // Test 1
        @(negedge clock);
        A   = 0;
        B   = 0;
        Cin = 0;
        #1 compare_correct_sum(A, B, Sum, Cin, Cout);

        // Test 2
        @(negedge clock);
        A   = 0;
        B   = 0;
        Cin = 1;
        #1 compare_correct_sum(A, B, Sum, Cin, Cout);

        // My tests

        // Test 3
        @(negedge clock);
        A   = 0;
        B   = -1;
        Cin = 0;
        #1 compare_correct_sum(A, B, Sum, Cin, Cout);

        // Test 4
        @(negedge clock);
        A   = 1;
        B   = -1;
        Cin = 0;
        #1 compare_correct_sum(A, B, Sum, Cin, Cout);

        // Test 5
        @(negedge clock);
        A   = 0;
        B   = -1;
        Cin = 0;
        #1 compare_correct_sum(A, B, Sum, Cin, Cout);

        
        // Test 6
        @(negedge clock);
        A   = MAX_64BIT_NUM;
        B   = MAX_64BIT_NUM;
        Cin = 0;
        #1 compare_correct_sum(A, B, Sum, Cin, Cout);


        // ---- Test Random Values ---- //
        // Or, we could throw probability at the problem...
        @(negedge clock);

        for (i=0; i <= 10; i=i+1) begin
            for (j=0; j <= 10; j=j+1) begin
                A = {$random,$random}; // $random is 32-bit, need two concatenated
                B = {$random,$random};
                #1 compare_correct_sum(A, B, Sum, Cin, Cout);
                @(negedge clock);
            end
        end


        // Don't forget to finish the simulation!
        $display("\nENDING TESTBENCH: SUCCESS!");
        $display("@@@ Passed\n");
        $finish;
    end

endmodule
