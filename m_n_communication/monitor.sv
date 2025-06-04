module monitor #(
    parameter IN_WIDTH = 16,
    parameter OUT_WIDTH = 8
) (
    input logic clk,
    input logic rst_n,
    // Connect producer modport arrays
    inf_temp.producer p_if [IN_WIDTH-1:0],
    // Connect consumer modport arrays
    inf_temp.consumer c_if [OUT_WIDTH-1:0]
);

    genvar i,j;
    generate
    always_ff @(posedge clk) begin
            if (!rst_n) begin
            // You can initialize logs or state here if needed
            end else begin
                $display("----- Monitor @ time %0t -----", $time);
            end
    end
    for (i = 0; i < IN_WIDTH; i = i +1) begin
        always_ff @(posedge clk) begin
            if (!rst_n) begin
            // You can initialize logs or state here if needed
            end else begin
            //$display("----- Monitor @ time %0t -----", $time);
                $display("Producer[%0d] => valid: %b, payload: 0x%02h, addr: 0x%02h, ready: %b",
                         i, p_if[i].valid, p_if[i].payload, p_if[i].addr, p_if[i].ready);
            end
        end
    end
    for (j = 0; j < OUT_WIDTH; j = j +1) begin
        always_ff @(posedge clk) begin
            if (!rst_n) begin
            // You can initialize logs or state here if needed
            end else begin
                $display("Consumer[%0d] <= valid: %b, payload: 0x%02h, addr: 0x%02h, ready: %b",
                             j, c_if[j].valid, c_if[j].payload, c_if[j].addr, c_if[j].ready);
            end
        end
    end
    endgenerate
endmodule
