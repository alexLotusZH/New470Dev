`ifndef SYNTHESIS

//
// This is an automatically generated file from 
// dc_shell Version V-2023.12-SP5 -- Jul 16, 2024
//

// For simulation only. Do not modify.

module full_adder_64bit_svsim (
    input  [63:0] A, B,
    input         carry_in,
    output [63:0] S,
    output        carry_out
);

            

  full_adder_64bit full_adder_64bit( {>>{ A }}, {>>{ B }}, {>>{ carry_in }}, 
        {>>{ S }}, {>>{ carry_out }} );
endmodule
`endif
