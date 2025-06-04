

`ifndef CONSUMER_MULTI_DE_SVH
`define CONSUMER_MULTI_DE_SVH
`include "vo_if.svh"
module consumer_multi_de #(
    parameter OUT_WIDTH = 8,
    parameter IN_WIDTH = 16,
    parameter PROCESS_WIDTH = 2
) (
    input logic clk,
    input logic rst_n,
    // vo_if.consumer c_if
    input  logic [IN_WIDTH-1: 0]   valid,
    input  logic [IN_WIDTH-1 :0]   [7:0]  payload ,
    input  logic [IN_WIDTH-1 :0]   [7:0]  addr    ,
    output logic [IN_WIDTH-1: 0]  ready
);
    

    logic [OUT_WIDTH-1 :0]  [7:0] addr_reg   , addr_reg_next;
    logic [OUT_WIDTH-1 :0]  [7:0] payload_reg, payload_reg_next;
    logic [OUT_WIDTH-1: 0]  occupied_reg     , occupied_reg_next;
    always_ff @(posedge clk ) begin
        if(~rst_n) begin
            payload_reg <= 0;
            addr_reg    <= 0;
            occupied_reg<= 0;
        end else begin
            payload_reg <= addr_reg_next;
            addr_reg    <= payload_reg_next;
            occupied_reg<= occupied_reg_next;
        end
    end

    logic [OUT_WIDTH-1: 0]  consumer_selected;
    logic [PROCESS_WIDTH-1:0] [OUT_WIDTH-1: 0]  consumer_selected_one_hot;
    logic [PROCESS_WIDTH-1:0] [$clog2(OUT_WIDTH)-1:0] consumer_selected_index;
    logic [IN_WIDTH-1: 0]   producer_selected;
    logic [PROCESS_WIDTH-1:0] [IN_WIDTH-1: 0]   producer_selected_one_hot;
    logic [PROCESS_WIDTH-1:0] [$clog2(IN_WIDTH)-1:0] producer_selected_index;
    psel_gen #(
    .WIDTH(OUT_WIDTH),
    .REQS(PROCESS_WIDTH)
    ) consumer_selector (
        .req(~occupied_reg),
        .gnt(consumer_selected),
        .gnt_bus(consumer_selected_one_hot)
    )

    psel_gen #(
    .WIDTH(IN_WIDTH),
    .REQS(PROCESS_WIDTH)
    ) producer_selector (
        .req(valid),
        .gnt(producer_selected),
        .gnt_bus(producer_selected_one_hot)
    )

    onehot_translater#(
        .DIM1(PROCESS_WIDTH),
        .DIM2(OUT_WIDTH)
    )   consumer_one_hot_decoder (
        .onehot_array(consumer_selected_one_hot),
        .index_array(consumer_selected_index)
    )

    onehot_translater#(
        .DIM1(PROCESS_WIDTH),
        .DIM2(IN_WIDTH)
    )   consumer_one_hot_decoder (
        .onehot_array(producer_selected_one_hot),
        .index_array(producer_selected_index)
    )

    assign ready = producer_selected;

    always_comb begin
        payload_reg_next    = payload_reg;
        addr_reg_next       = addr_reg;
        occupied_reg_next   = occupied_reg;
        for (int i = 0; i<PROCESS_WIDTH; i+=1) begin
            if(|producer_selected_one_hot[i] && |consumer_selected_one_hot[i]) begin
                payload_reg_next[consumer_selected_index[i]] = payload[producer_selected_index[i]];
                addr_reg_next[consumer_selected_index[i]] = addr[producer_selected_index[i]];
                occupied_reg_next[consumer_selected_index[i]] = 1;
            end
        end
    end
endmodule

`endif // CONSUMER_VO_SVH