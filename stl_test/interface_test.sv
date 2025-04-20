`timescale 1ns/100ps

module tb;
    logic clk;
    logic reset;
    ready_valid #(22) rv_if();

    Producer#(logic[15:0], logic[7:0]) producer(
        .clk(clk),
        .reset(reset),
        ._producer(rv_if.producer)
    );

    Consumer#(logic[15:0], logic[7:0]) consumer(
        .clk(clk),
        .reset(reset),
        ._consumer(rv_if.consumer)
    );

    initial begin
        clk = 0;
        reset = 1;
        #10 reset = 0;
        #100 $finish;
    end

    always #5 clk = ~clk;
    // Clock generation



endmodule