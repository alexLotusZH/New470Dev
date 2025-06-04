`ifndef CDVD_IF_SVH
`define CDVD_IF_SVH

// typedef logic[7:0] Byte;
interface cdvd_if;
    logic        valid_1, valid_2;
    logic        ready_1, ready_2;
    logic [7:0]  payload_1;
    logic [7:0]  payload_2;
    logic [7:0]  addr_1;
    logic [7:0]  addr_2;

    // Modport for the producer (output signals)
    modport producer (
        output valid_1,
        output payload_1,
        output addr_1,
        input  ready_1
    );

    // Modport for the consumer (input signals)
    modport consumer (
        input  valid_2,
        input  payload_2,
        input  addr_2,
        output ready_2
    );

    modport fifo (
        input  valid_1,
        input  payload_1,
        input  addr_1,
        output ready_1,
        output valid_2,
        output payload_2,
        output addr_2,
        input  ready_2
    );
endinterface

`endif // VO_IF_SVH