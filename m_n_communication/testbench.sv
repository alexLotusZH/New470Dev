`ifndef TESTBENCH_SVH
`define TESTBENCH_SVH

// typedef logic[7:0] Byte;
module testbench;
    logic clk;
    logic rst_n;
    localparam IN_WIDTH = 16;
    localparam OUT_WIDTH = 8;
    localparam BANDWIDTH = 2;
    inf_temp  in1 [IN_WIDTH-1:0]();
    inf_temp  in2 [OUT_WIDTH-1:0]();
    // logic        valid;
    // logic        ready;
    // logic [7:0]  payload;
    // logic [7:0]  addr;

    // Modport for the producer (output signals)
    producer_multi_vo #(
        .WIDTH(16)
    ) producer (
        .clk(clk),
        .rst_n(rst_n),
        .p_if(in1)
    );

    // Modport for the consumer (input signals)
    consumer_multi_vo #(
        .WIDTH(8)
    ) consumer (
        .clk(clk),
        .rst_n(rst_n),
        .c_if(in2)
    );

    m_n_arbiter #(
        .IN_WIDTH(16),
        .OUT_WIDTH(8),
        .BANDWIDTH(2)
    ) arbit (
        .clk(clk),
        .rst_n(rst_n),
        .p_if(in1),
        .c_if(in2)
    );
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
        $display("consumer has %b occupied bits in it", arbit.consumer_selected);
        $display("producer has %b emptied bits in it", producer.empty);
    end
endmodule

`endif