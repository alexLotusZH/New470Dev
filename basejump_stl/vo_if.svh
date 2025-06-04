`ifndef VO_IF_SVH
`define VO_IF_SVH

// typedef logic[7:0] Byte;
interface vo_if;
    logic        valid;
    logic        ready;
    logic [7:0]  payload;
    logic [7:0]  addr;

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