`ifndef VO_VO_FIFO_SVH
`define VO_VO_FIFO_SVH
`include "cdvd_if.svh"
module vo_vo_fifo(
    input clk,
    input rst_n,
    cdvd_if.fifo fifo_if
);
    localparam DEPTH = 8;
    localparam PTR_WIDTH = 3; // log2(DEPTH)

    // FIFO storage
    logic [7:0] payload_buf [DEPTH-1:0];
    logic [7:0] addr_buf    [DEPTH-1:0];

    logic [PTR_WIDTH-1:0] rd_ptr, wr_ptr;
    logic [3:0] count; // up to 8

    assign fifo_if.valid_2 = (count > 0);
    assign fifo_if.payload_2 = payload_buf[rd_ptr];
    assign fifo_if.addr_2    = addr_buf[rd_ptr];
    assign fifo_if.ready_1   = (count < DEPTH);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            rd_ptr <= 0;
            wr_ptr <= 0;
            count  <= 0;
        end else begin
            // WRITE logic
            if (fifo_if.valid_1 && (count < DEPTH)) begin
                payload_buf[wr_ptr] <= fifo_if.payload_1;
                addr_buf[wr_ptr]    <= fifo_if.addr_1;
                wr_ptr              <= wr_ptr + 1;
                count               <= count + 1;
            end

            // READ logic
            if (fifo_if.ready_2 && (count > 0)) begin
                rd_ptr <= rd_ptr + 1;
                count  <= count - 1;
            end
        end
    end

endmodule

`endif