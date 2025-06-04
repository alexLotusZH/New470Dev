`include "inf_temp.svh"
module consumer_multi_vo #(
    parameter WIDTH = 8
)(
    input logic clk,
    input logic rst_n,
    inf_temp.consumer c_if [WIDTH-1:0]
);
    

    logic [WIDTH-1 :0]  [7:0] addr_reg   , addr_reg_next;
    logic [WIDTH-1 :0]  [7:0] payload_reg, payload_reg_next;
    logic [WIDTH-1: 0]  occupied_reg     , occupied_reg_next;
    genvar i;
    for(i = 0; i< WIDTH; i++) begin
        assign c_if[i].ready = ~occupied_reg[i];
    end

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

    // always_comb begin
    //     occupied_reg_next   = occupied_reg;
    //     addr_reg_next       = addr_reg;
    //     payload_reg_next    = payload_reg;
    //     for(int k = 0; k< WIDTH; k++) begin
    //         if(c_if[k].valid) begin
    //             occupied_reg_next[k]    = 1;
    //             addr_reg_next[k]        = c_if[k].addr;
    //             payload_reg_next[k]     = c_if[k].payload;
    //         end
    //     end
    // end
    logic [WIDTH-1:0] valid_array;
    logic [WIDTH-1:0][7:0] addr_array;
    logic [WIDTH-1:0][7:0] payload_array;

    genvar gi;
    generate
        for (gi = 0; gi < WIDTH; gi++) begin : gen_consumer
            assign valid_array[gi]   = c_if[gi].valid;
            assign addr_array[gi]    = c_if[gi].addr;
            assign payload_array[gi] = c_if[gi].payload;
        end
    endgenerate
    always_comb begin
        occupied_reg_next   = occupied_reg;
        addr_reg_next       = addr_reg;
        payload_reg_next    = payload_reg;
        for (int k = 0; k < WIDTH; k++) begin
            if (valid_array[k]) begin
                occupied_reg_next[k] = 1;
                addr_reg_next[k]     = addr_array[k];
                payload_reg_next[k]  = payload_array[k];
            end
        end
    end


endmodule
