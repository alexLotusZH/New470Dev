`ifndef PVCD_MN_IF_SVH
`define PVCD_MN_IF_SVH

// typedef logic[7:0] Byte;
interface pvcd_mn_if#(parameter int M = 16);
    logic               valid;
    logic [M-1:0]       ready;
    logic [M-1:0][7:0]  payload;
    logic [M-1:0][7:0]  addr;

    // Modport for the producer (output signals)
    modport producer (
        output valid,
        output payload,
        output addr,
        input  ready
    );

    // Modport for the consumer (input signals)
    modport consumer (
        input  valid,
        input  payload,
        input  addr,
        output ready
    );
endinterface

`endif // VO_IF_SVH