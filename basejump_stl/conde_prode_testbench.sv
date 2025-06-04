`timescale 1ns / 1ps
// `include "vo_if.svh"
`include "consumer_de.sv"
`include "producer_de.sv"

module testbench;
    logic clk;
    logic rst_n;

    cdvd_if bus();

    producer_de producer (
        .clk(clk),
        .rst_n(rst_n),
        // .p_if(bus)
        .valid(bus.valid_1),
        .payload(bus.payload_1),
        .addr(bus.addr_1),
        .ready(bus.ready_1)
    );
    vo_vo_fifo fifo(
        .clk(clk),
        .rst_n(rst_n),
        .fifo_if(bus)
    );
    consumer_de consumer (
        .clk(clk),
        .rst_n(rst_n),
        // .c_if(bus)
        .valid(bus.valid_2),
        .payload(bus.payload_2),
        .addr(bus.addr_2),
        .ready(bus.ready_2)
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