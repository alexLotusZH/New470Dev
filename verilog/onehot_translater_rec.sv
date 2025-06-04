module onehot_translater_rec
#(
    parameter DIM2 = 16,  // Width of output binary representation
    parameter OUTPUT_WIDTH = 4,
    parameter [OUTPUT_WIDTH-1:0] START_BIT = 0
) (
    input [DIM2-1:0] onehot_array,
    output logic [OUTPUT_WIDTH-1:0] index_array
);

    if (DIM2 == 1) begin: base_case
        localparam [OUTPUT_WIDTH-1:0] lidx = START_BIT;
        logic [OUTPUT_WIDTH-1:0] mask;
        assign mask = onehot_array[0] ? {OUTPUT_WIDTH{1'b1}} : {OUTPUT_WIDTH{1'b0}};
        assign index_array = lidx & mask;
    end
    else begin : rec_case
        localparam START_BIT_LOW = START_BIT;
        localparam DIM2_LOW = DIM2 / 2;
        logic [DIM2_LOW-1:0] onehot_low;
        logic [OUTPUT_WIDTH-1:0] index_low;
        localparam START_BIT_HIGH = START_BIT + DIM2_LOW;
        localparam DIM2_HIGH = DIM2 - DIM2_LOW;
        logic [DIM2_HIGH-1:0] onehot_high;
        logic [OUTPUT_WIDTH-1:0] index_high;

        assign onehot_low = onehot_array[DIM2_LOW-1:0];
        assign onehot_high = onehot_array[DIM2-1:DIM2_LOW];

        assign index_array = index_low | index_high;
        
        onehot_translater_rec #(.DIM2(DIM2_LOW), .OUTPUT_WIDTH(OUTPUT_WIDTH), .START_BIT(START_BIT_LOW))
            u_rec_low(
                .onehot_array(onehot_low),
                .index_array(index_low)
            );
        onehot_translater_rec #(.DIM2(DIM2_HIGH), .OUTPUT_WIDTH(OUTPUT_WIDTH), .START_BIT(START_BIT_HIGH))
            u_rec_high(
                .onehot_array(onehot_high),
                .index_array(index_high)
            );
        
    end
endmodule
