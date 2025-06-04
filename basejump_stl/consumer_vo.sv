`ifndef CONSUMER_VO_SVH
`define CONSUMER_VO_SVH
`include "vo_if.svh"
module consumer_vo (
    input clk,
    input rst_n,
    // vo_if.consumer c_if
    input  valid,
    input  logic [7:0]  payload,
    input  logic [7:0]  addr,
    output ready
);
    assign ready = 1;

    logic [7:0] addr_reg;
    logic [7:0] payload_reg;

    always_ff @(posedge clk ) begin
        if(~rst_n) begin
            payload_reg <= 0;
            addr_reg    <= 0;
        end else if(valid) begin
            payload_reg <= payload;
            addr_reg    <= addr;
        end
    end
endmodule

`endif // CONSUMER_VO_SVH