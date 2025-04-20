`ifndef M_N_ARBITER_SVH
`define M_N_ARBITER_SVH
//`include "../verilog/psel_gen.sv"
`include "inf_temp.svh"

module m_n_arbiter #(
    parameter IN_WIDTH = 16,
    parameter OUT_WIDTH = 8,
    parameter BANDWIDTH = 2
) (
    input logic clk,
    input logic rst_n,
    inf_temp.consumer p_if [IN_WIDTH-1:0],
    inf_temp.producer c_if [OUT_WIDTH-1:0]
);
    // Intermediate signals
    logic [IN_WIDTH-1:0]   p_valid_array;
    logic [IN_WIDTH-1:0][7:0] p_payload_array;
    logic [IN_WIDTH-1:0][7:0] p_addr_array;

    logic [OUT_WIDTH-1:0]  c_valid_array;
    logic [OUT_WIDTH-1:0][7:0] c_payload_array;
    logic [OUT_WIDTH-1:0][7:0] c_addr_array;

    logic [OUT_WIDTH-1:0] consumer_selected;
    logic [BANDWIDTH-1:0][OUT_WIDTH-1:0] consumer_selected_one_hot;
    logic [BANDWIDTH-1:0][$clog2(OUT_WIDTH)-1:0] consumer_selected_index;

    logic [IN_WIDTH-1:0] producer_selected, producer_selected_real;
    logic [BANDWIDTH-1:0][IN_WIDTH-1:0] producer_selected_one_hot;
    logic [BANDWIDTH-1:0][$clog2(IN_WIDTH)-1:0] producer_selected_index;

    logic [OUT_WIDTH-1:0] consumer_bits;
    logic [IN_WIDTH-1:0]  producer_bits;
    // Bind interface signals to intermediate arrays
    genvar g,h;
    generate
        for (g = 0; g < IN_WIDTH; g++) begin
            assign p_valid_array[g]   = p_if[g].valid;
            assign p_payload_array[g] = p_if[g].payload;
            assign p_addr_array[g]    = p_if[g].addr;
            assign p_if[g].ready      = producer_selected_real[g];
        end

        for (h = 0; h < OUT_WIDTH; h++) begin
            assign c_if[h].valid   = c_valid_array[h];
            assign c_if[h].payload = c_payload_array[h];
            assign c_if[h].addr    = c_addr_array[h];
            assign consumer_bits[h]= c_if[h].ready;
        end
    endgenerate

    // Bitmasks for valid consumers/producers


    always_comb begin
        producer_bits = '0;
        for (int i = 0; i < IN_WIDTH; i++) begin
            if (p_valid_array[i]) begin
                producer_bits[i] = 1;
            end
        end
    end

    // always_comb begin
    //     consumer_bits = '0;
    //     for (int i = 0; i < OUT_WIDTH; i++) begin
    //         if (!c_valid_array[i]) begin
    //             consumer_bits[i] = 1; // mark available consumers
    //         end
    //     end
    // end

    // Selection outputs
    

    // Selection logic
    psel_gen #(
        .WIDTH(OUT_WIDTH),
        .REQS(BANDWIDTH)
    ) consumer_selector (
        .req(consumer_bits),
        .gnt(consumer_selected),
        .gnt_bus(consumer_selected_one_hot),
        .empty()
    );

    psel_gen #(
        .WIDTH(IN_WIDTH),
        .REQS(BANDWIDTH)
    ) producer_selector (
        .req(producer_bits),
        .gnt(producer_selected),
        .gnt_bus(producer_selected_one_hot),
        .empty()
    );

    // Decode one-hot to index
    onehot_translater #(
        .DIM1(BANDWIDTH),
        .DIM2(OUT_WIDTH)
    ) consumer_one_hot_decoder (
        .onehot_array(consumer_selected_one_hot),
        .index_array(consumer_selected_index)
    );

    onehot_translater #(
        .DIM1(BANDWIDTH),
        .DIM2(IN_WIDTH)
    ) producer_one_hot_decoder (
        .onehot_array(producer_selected_one_hot),
        .index_array(producer_selected_index)
    );

    // Reset all outputs
    // always_comb begin
    //     c_valid_array   = '0;
    //     c_payload_array = '0;
    //     c_addr_array    = '0;

    //     for (int k = 0; k < BANDWIDTH; k++) begin
    //         if (|producer_selected_one_hot[k] && |consumer_selected_one_hot[k]) begin
    //             int src  = producer_selected_index[k];
    //             int dest = consumer_selected_index[k];

    //             c_valid_array[dest]   = 1;
    //             c_payload_array[dest] = p_payload_array[src];
    //             c_addr_array[dest]    = p_addr_array[src];
    //         end
    //     end
    // end
    always_comb begin
        c_valid_array   = '0;
        c_payload_array = '0;
        c_addr_array    = '0;
        producer_selected_real = producer_selected;
        for (int k = 0; k < BANDWIDTH; k++) begin
            if (|producer_selected_one_hot[k] && |consumer_selected_one_hot[k]) begin
                // Extract values into local temporaries
                logic [$clog2(IN_WIDTH)-1:0] src;
                logic [$clog2(OUT_WIDTH)-1:0] dest;

                src  = producer_selected_index[k];
                dest = consumer_selected_index[k];

                // Manually unroll all destination possibilities
                for (int d = 0; d < OUT_WIDTH; d++) begin
                    if (dest == d) begin
                        c_valid_array[d]   = 1;
                        c_payload_array[d] = p_payload_array[src];
                        c_addr_array[d]    = p_addr_array[src];
                    end
                end
            end else begin
                producer_selected_real[producer_selected_index[k]] = 0;
            end
        end
    end


endmodule

// module m_n_arbiter #(
//     IN_WIDTH = 16,
//     OUT_WIDTH = 8,
//     BANDWIDTH = 2
// ) (
//     input logic clk,
//     input logic rst_n,
//     inf_temp.consumer p_if [IN_WIDTH-1:0],
//     inf_temp.producer c_if [OUT_WIDTH-1:0]
// );
//     logic [OUT_WIDTH-1:0]   consumer_bits;
//     logic [IN_WIDTH-1:0]    producer_bits;

//     always_comb begin
//         producer_bits = 0;
//         for(int i = 0; i< IN_WIDTH; i++) begin
//             if(p_if[i].valid) begin
//                 producer_bits[i] = 1;
//             end
//         end
//     end

//     always_comb begin
//         consumer_bits = 0;
//         for(int i = 0; i< OUT_WIDTH; i++) begin
//             if(c_if[i].valid) begin
//                 consumer_bits[i] = 1;
//             end
//         end
//     end
//     logic [OUT_WIDTH-1: 0]  consumer_selected;
//     logic [BANDWIDTH-1:0] [OUT_WIDTH-1: 0]          consumer_selected_one_hot;
//     logic [BANDWIDTH-1:0] [$clog2(OUT_WIDTH)-1:0]   consumer_selected_index;
//     logic [IN_WIDTH-1: 0]   producer_selected;
//     logic [BANDWIDTH-1:0] [IN_WIDTH-1: 0]           producer_selected_one_hot;
//     logic [BANDWIDTH-1:0] [$clog2(IN_WIDTH)-1:0]    producer_selected_index;
//     psel_gen #(
//     .WIDTH(OUT_WIDTH),
//     .REQS(BANDWIDTH)
//     ) consumer_selector (
//         .req(consumer_bits),
//         .gnt(consumer_selected),
//         .gnt_bus(consumer_selected_one_hot),
//         .empty()
//     );

//     psel_gen #(
//     .WIDTH(IN_WIDTH),
//     .REQS(BANDWIDTH)
//     ) producer_selector (
//         .req(producer_bits),
//         .gnt(producer_selected),
//         .gnt_bus(producer_selected_one_hot),
//         .empty()
//     );

//     onehot_translater#(
//         .DIM1(BANDWIDTH),
//         .DIM2(OUT_WIDTH)
//     )   consumer_one_hot_decoder (
//         .onehot_array(consumer_selected_one_hot),
//         .index_array(consumer_selected_index)
//     );

//     onehot_translater#(
//         .DIM1(BANDWIDTH),
//         .DIM2(IN_WIDTH)
//     )   producer_one_hot_decoder (
//         .onehot_array(producer_selected_one_hot),
//         .index_array(producer_selected_index)
//     );

//     genvar j;
//     for(j = 0; j< OUT_WIDTH; j++) begin
//         always_comb begin

//             for(int k = 0;k < BANDWIDTH; k++) begin
//                 if(|producer_selected_one_hot[k] && |consumer_selected_one_hot[k] && consumer_selected_index == j) begin
//                     c_if[j].valid = 1;
//                     c_if[j].payload = p_if[producer_selected_index[k]].payload;
//                     c_if[j].addr = p_if[producer_selected_index[k]].addr;
//                 end
//             end
//         end
//     end
    
// endmodule

`endif