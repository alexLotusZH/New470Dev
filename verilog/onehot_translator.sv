module onehot_translator #(
    parameter DIM2 = 16  // Width of output binary representation
) (
    input [DIM2-1:0] onehot_array,
    output logic [$clog2(DIM2)-1:0] index_array
);

localparam OUTPUT_WIDTH = $clog2(DIM2);
localparam START_BIT = 0;

onehot_translater_rec #(DIM2, OUTPUT_WIDTH, START_BIT) u_rec(.*);

endmodule
//    0 1 2 3 4 5 6 7
//  0 0 1 0 1 0 1 0 1
//  1 0 0 1 1 0 0 1 1
//  2 0 0 0 0 1 1 1 1
//
//  0 1 2 3 4 5 6 7
//  0 1 2 3          4 5 6 7
//  0 1    2 3       4 5    6 7
//  0   1   2   3     4  5   6   7
//  0   0   0   0     1  1   1   1
//  0   0   1   1     0  0   1   1
//  0   1   0   1     0  1   0   1