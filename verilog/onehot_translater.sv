// `include "sys_defs.svh"

// translate onehot coded array
module onehot_translater#(parameter DIM1 = 1, DIM2 = 16) (
    input [DIM1-1:0] [DIM2-1:0] onehot_array,

    output wor [DIM1-1:0] [$clog2(DIM2)-1:0] index_array
);
genvar a, b, c, d;
for (a=0;a<DIM1;a=a+1)
	for(b=0;b<$clog2(DIM2);b=b+1)
		for(c=2**b;c<DIM2;c=c+(2**(b+1)))
			for(d=c;d<c+2**b && d<DIM2;d=d+1)
				assign index_array[a][b] = onehot_array[a][d];

endmodule