`ifndef INF_TEMP_SVH
`define INF_TEMP_SVH

// typedef logic[7:0] Byte;
interface inf_temp;
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

    // modport fifo (
    //     input  valid_1,
    //     input  payload_1,
    //     input  addr_1,
    //     output ready_1,
    //     output valid_2,
    //     output payload_2,
    //     output addr_2,
    //     input  ready_2
    // );
endinterface

`endif