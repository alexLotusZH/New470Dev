`ifndef PRODUCER_VO_SVH
`define PRODUCER_VO_SVH

`include "vo_if.svh"
module producer_vo(
    input logic clk,
    input logic rst_n,
    // vo_if.producer p_if
    input  ready,
    output valid,
    output logic [7:0]  payload,
    output logic [7:0]  addr
);
    
    assign valid = 1;
    always_ff @( posedge clk ) begin
        if(~ready | ~rst_n) begin
            payload <= 0;
            addr    <= 0;
        end else begin
            payload <= 8'hee;
            addr    <= 8'hdd;
        end
    end
endmodule

`endif // CONSUMER_VO_SVH