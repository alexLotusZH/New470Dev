`ifndef PRODUCER_VO_SVH
`define PRODUCER_VO_SVH

`include "vo_if.svh"
module producer_multi_vo#(
    parameter OUT_WIDTH = 16,
)(
    input logic clk,
    input logic rst_n,
    // vo_if.producer p_if
    input  logic [OUT_WIDTH-1: 0]    ready,
    output logic [OUT_WIDTH-1: 0]    valid,
    output logic [OUT_WIDTH-1: 0]    [7:0]  payload,
    output logic [OUT_WIDTH-1: 0]    [7:0]  addr
);
    
    assign valid = {OUT_WIDTH{1'b1}};
    always_ff @( posedge clk ) begin
        if(~rst_n) begin
            payload <= 0;
            addr    <= 0;
        end else begin
            payload <= {OUT_WIDTH{8'hee}};  // replicate 8'hee OUT_WIDTH times
            addr    <= {OUT_WIDTH{8'hdd}};  // replicate 8'hdd OUT_WIDTH times
        end
    end
endmodule

`endif // CONSUMER_VO_SVH