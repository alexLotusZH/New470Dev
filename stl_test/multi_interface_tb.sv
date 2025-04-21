`timescale 1ns/100ps
`define DEBUG_OUT
`include "standard.svh"

// not working if M N defined in standard.svh
`define MM 5
`define NN 3

module tb;
    logic clk, rst;

   //  ready_valid_if#(Req) dcache_to_mshr [`M-1:0][`N-1:0]();
     
    ready_valid#(Req) p2c_handshake();
    ready_valid_arbiter#(Req) p2c_bus(.left(p2c_handshake.producer), .right(p2c_handshake.consumer));
    // Use arrary in real case, as parameters will be the same in real project scenario
    Producer #(.N(`NN), .Payload(Req)) p(
        .clk(clk),
        .rst(rst),
        .out(p2c_handshake.producer)
    );

    Consumer #(.M(`MM), .Payload(Req)) c(
        .clk(clk),
        .rst(rst),
        .in(p2c_handshake.consumer)
    );

    initial begin
        clk = 0;
        rst = 1;
        #10 rst = 0;
        #100 $finish;


    end

    always #5 clk = ~clk;

endmodule