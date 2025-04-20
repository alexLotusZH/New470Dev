module full_adder_1bit (
    input A, B, carry_in,
    output S, carry_out
);

    logic w1, w2, w3, w4;

    // LAB2 TODO: identify the bug in this logic and fix it! (write your testbench first...)
    assign w2 = B & carry_in;
    assign w1 = B ^ carry_in;
    assign S = A ^ w1;
    assign w3 = B & A;
    assign w4 = carry_in  & A;
    assign carry_out = (w2 | w3 | w4);

endmodule
