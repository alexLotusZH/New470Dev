`timescale 1ns / 1ps
// `include "vo_if.svh"
`include "consumer_de.sv"
`include "producer_vo.sv"

module testbench;
    logic clk;
    logic rst_n;

    vo_if bus();

    producer_vo producer (
        .clk(clk),
        .rst_n(rst_n),
        // .p_if(bus)
        .valid(bus.valid),
        .payload(bus.payload),
        .addr(bus.addr),
        .ready(bus.ready)
    );

    consumer_de consumer (
        .clk(clk),
        .rst_n(rst_n),
        // .c_if(bus)
        .valid(bus.valid),
        .payload(bus.payload),
        .addr(bus.addr),
        .ready(bus.ready)
    );
    // Clock/reset stimulus here
    always #5 clk = ~clk;
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, testbench);
        // Initialize
        clk   = 0;
        rst_n = 0;

        // Reset pulse
        #20;
        rst_n = 1;

        // Run for 100ns
        #100;

        $display("Simulation complete.");
        $finish;
    end

    always_ff @( posedge clk ) begin
        $display("consumer has %h and %h addr in it", consumer.payload_reg, consumer.addr_reg);
    end
endmodule