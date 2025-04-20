`timescale 1ns/100ps
`define DEBUG_OUT
`include "standard.svh"


/*
Ready-valid Handshake, one producer one consumer, one connection interface
Non-broadcast N-way bus, encapsulate an arbiter
TODO: M*N connections with broadcast good?

BROADCAST:

M*N interface instances, huge resource consumption, simply connection, impl needs to be decided by students

*/



/*
Valid-then-ready:
M lines -> N lines
        <-
** Instantiation of modules inside interface is not allowed,
    either define a module instead of interface,    ==> can do, but that means we staff will introduce extra amount of hardware everywhere. 
    or implement select logic inside interface.     ==> limit design freedom; will synthesize to circuit
*/

// interface ready_valid_if #(
//     parameter type Payload = logic[15:0],
//     parameter M = 5,
//     parameter N = 3
//     );

//     // Producer side signals
//     logic   [M-1:0] p_valid;      // output
//     logic   [M-1:0] p_ready;      // input
//     Payload [M-1:0] p_data;       // output

//     // Consumer side output signals
//     logic   [N-1:0] c_valid;    // input
//     logic   [N-1:0] c_ready;    // output
//     Payload [N-1:0] c_data;     // input


//     // end

//     modport producer(
//         input   p_ready,
//         output  p_valid,
//         output  p_data
//     );

//     modport consumer(
//         input   c_valid,
//         input   c_data,
//         output  c_ready
//     );

//         // procedural block or third modport to impl FIFO
// endinterface

interface ready_valid #(parameter type Payload = logic[15:0]);
    logic ready;
    logic valid;
    Payload data;
    
    modport producer(input ready, output valid, output data);
    modport consumer(output ready, input valid, input data);

endinterface


// route left and right with psel
module ready_valid_arbiter #(
    parameter type Payload = logic[15:0],
    parameter M = 5,
    parameter N = 3
    )(
        ready_valid_if left [M-1:0],
        ready_valid_if right [N-1:0]

    );

    // Internal arbitration signals
    logic [N-1:0][M-1:0] gnt;
    logic grant_valid[N];

    // Arbitration logic for each consumer
    psel_gen#(
        .WIDTH(M),
        .REQS(N)
    ) p2c_arbiter (
        .req(left.p_valid),
        .gnt(grant_valid),
        .gnt_bus(gnt),
        .empty()
    );
    
    // route Consumer side singals to Producer side.
    always_comb begin
        in_out.p_ready = '0;
        in_out.c_data = '0;

        for(int j = 0; j < N; j++) begin
            for(int i = 0; i < M; i++) begin
                if(gnt[j][i]) begin
                    right.valid[i] = left.valid[j];
                    break;
                end
            end
        end


        for(int j = 0; j < N; j++) begin
            for(int i = 0; i < M; i++) begin
                if(gnt[j][i]) begin
                    right.data[i] = left.data[j];
                    break;
                end
            end
        end

        for(int j = 0; j < N; j++) begin
            for(int i = 0; i < M; i++) begin
                if(gnt[j][i]) begin
                    left.ready[i] = right.ready[j];
                    break;
                end
            end
        end

    end


        // procedural block or third modport to impl FIFO
endmodule


// M producers
module Producer #(
  parameter int N = 3,
  parameter type Payload = logic[31:0]
)(
  input logic clk,
  input logic rst,
  ready_valid_if.producer out
);


// TODO: really want to generate random testcases in synthesizable modules
// Will use generate loop in real cases
    always_ff @(posedge clk) begin
        if(rst) begin
            out.p_valid <= '0;
            out.p_data <= '0;
        end else begin
            out.p_valid <= 5'b01001;
                out.p_data[0] <= 17'h01;
                out.p_data[1] <= 17'h01;
                out.p_data[2] <= 17'h02;
                out.p_data[3] <= 17'h03;
                out.p_data[4] <= 17'h04;
            if((|out.p_ready)) $display("Producer received repsonse: %b", out.p_ready);
        end

    end

endmodule

// N consumers
module Consumer #(
  parameter int M = 4,
  parameter type Payload = logic[31:0]
)(
  input logic clk,
  input logic rst,
  ready_valid_if.consumer in
);
    // genvar j;
    // generate
    //     for(j=0; j<`N; j++) begin
    //         if(in.c_valid[j] & in.c_ready[j]);  
    //     end     
    // endgenerate

    always_ff @(posedge clk) begin
        if(rst) begin
            in.c_ready <= '0;
        end else begin
            in.c_ready <= 3'b101;
            if(in.c_valid[0] & in.c_ready[0]) $display("Consumer0 received data: %h", in.c_data);
            if(in.c_valid[1] & in.c_ready[1]) $display("Consumer1 received data: %h", in.c_data);
            if(in.c_valid[2] & in.c_ready[2]) $display("Consumer2 received data: %h", in.c_data);
            $display("cvalid: %b %b", in.c_valid, in.c_ready);
        end
    end





endmodule
