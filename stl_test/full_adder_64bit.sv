module full_adder_64bit (
    input  [63:0] A, B,
    input         carry_in,
    output [63:0] S,
    output        carry_out
);

    // LAB2 TODO: Implement a 64-bit adder using array instantiated 1-bit adders
    // NOTE: bit 63 of 63:0 is the MSB
    wire [62:0] carries;

    full_adder_1bit addr [63:0] (
        .A(A), .B(B), .carry_in({carries, carry_in}),
        .S(S), .carry_out({carry_out, carries})
    );     

endmodule
