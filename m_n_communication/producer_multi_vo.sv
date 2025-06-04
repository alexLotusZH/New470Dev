
`include "inf_temp.svh"
module producer_multi_vo#(
    parameter WIDTH = 16
)(
    input logic clk,
    input logic rst_n,
    inf_temp.producer p_if [WIDTH-1:0]
);
    logic [WIDTH-1:0] empty, empty_next;
    genvar i;
    for(i = 0; i< WIDTH; i++) begin
        assign p_if[i].valid = ~empty[i];
    end
    
    generate
        for (i = 0; i < WIDTH; i++) begin : assign_payloads
            always_ff @(posedge clk) begin
                if (~rst_n) begin
                    p_if[i].payload <= 0;
                    p_if[i].addr    <= 0;
                end else begin
                    p_if[i].payload <= 8'hee;
                    p_if[i].addr    <= 8'hdd;
                end
            end
        end
    endgenerate

    logic [WIDTH-1:0] ready_array;

    genvar gi;
    generate
        for (gi = 0; gi < WIDTH; gi++) begin : gen_ready_array
            assign ready_array[gi] = p_if[gi].ready;
        end
    endgenerate

    always_comb begin
        empty_next = empty;
        for (int i = 0; i < WIDTH; i++) begin
            if (ready_array[i]) begin
                empty_next[i] = 1;
            end
        end
    end
    // FF for empty register
    always_ff @(posedge clk) begin
        if (~rst_n)
            empty <= '0;
        else
            empty <= empty_next;
    end
endmodule

