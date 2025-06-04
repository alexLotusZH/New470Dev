`ifndef PRODUCER_DE_SVH
`define PRODUCER_DE_SVH
`include "vo_if.svh"
module producer_de(
    input clk,
    input rst_n,
    // vo_if.producer p_if
    input  ready,
    output valid,
    output logic [7:0]  payload,
    output logic [7:0]  addr
);
    always_ff @( posedge clk ) begin
        if(valid) begin
            payload <= 8'h22;
            addr    <= 8'h44;
        end else begin
            payload <= 8'h00;
            addr    <= 8'h00;
        end
        
    end

    assign valid = rst_n & ready;
endmodule
`endif // CONSUMER_VO_SVH