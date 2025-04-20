`timescale 1ns/100ps
`define DEBUG_OUT


  parameter DCACHE_ENTRY_NUM = 4;
  parameter MSHR_ENTRY_NUM   = 2;
  parameter ADDR_WIDTH       = 32;
  parameter TAG_WIDTH        = 4;

  typedef struct packed {
      logic [ADDR_WIDTH-1:0] addr;
  } DcacheReq;

  typedef struct packed {
      logic hit;
      logic [TAG_WIDTH-1:0] tag;
  } MshrResp;


/*
Ready-valid Handshake, one producer one consumer, one connection interface
*/

interface ready_valid_if #(
    parameter type Payload = logic[15:0]
    );
    logic ready;
    logic valid;
    Payload payload;

    modport producer(input ready, output valid, output payload);
    modport consumer(output ready, input valid, input payload);

        // procedural block or third modport to impl FIFO
endinterface


/*
    M Dcache entries broadcast to all N MSHR entries upon Dcache request

*/
module DCache_MSHR_arbiter #(
    parameter DCACHE_ENTRY_NUM = 32,
    parameter MSHR_ENTRY_NUM   = 16
)(
    input logic clk,
    input logic rst
);

    ready_valid_if#(DcacheReq) dcache_to_mshr_req [DCACHE_ENTRY_NUM][MSHR_ENTRY_NUM]; 
    ready_valid_if#(MshrResp)  mshr_to_dcache_rsp [MSHR_ENTRY_NUM][DCACHE_ENTRY_NUM]; 

    // MSHR to DCache 
    // P: MSHR[j]; D: Dcache[i];

endmodule

/*

*/


module DCache #(
    parameter int ENTRY_ID = 0,
    parameter int N,
    parameter int ADDR_WIDTH = 32,
    parameter int TAG_WIDTH = 4
)(
    input logic clk,
    input logic rst,

    output ready_valid_if#(DCacheReq).producer dcache_reqs [N],
    input  ready_valid_if#(MSHRResp).consumer dcache_rsps [N]
);

    logic [ADDR_WIDTH-1:0] pending_addr;
    logic miss_valid;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            miss_valid <= 0;
        end else begin
            miss_valid <= 1;
            pending_addr <= 32'hDEAD_0000 +  ENTRY_ID;
        end
    end

    always_comb begin
        for (int j = 0; j < N; j++) begin
            dcache_reqs[j].valid = miss_valid;
            dcache_reqs[j].data.addr = pending_addr;
        end

        for (int j = 0; j < N; j++) begin
            dcache_rsps[j].ready = 1;
            if (dcache_rsps[j].valid && dcache_rsps[j].data.hit) begin
                $display("DCache[%0d] got hit response from MSHR[%0d] tag=%0d", ENTRY_ID, j, dcache_rsps[j].data.tag);
            end
        end
    end
endmodule


module MSHR #(
    parameter int ENTRY_ID,
    parameter int M,
    parameter int ADDR_WIDTH = 32,
    parameter int TAG_WIDTH = 4
)(
    input logic clk,
    input logic rst,

    input  ready_valid_if#(DCacheReq).consumer mshr_reqs [M],
    output ready_valid_if#(MSHRResp).producer mshr_rsps [M]
);

    // 伪命中逻辑：MSHR 命中地址以 ENTRY_ID 为低位
    function logic hit_check(logic [ADDR_WIDTH-1:0] addr);
        return (addr[3:0] == ENTRY_ID);
    endfunction

    always_comb begin
        for (int i = 0; i < M; i++) begin
            mshr_reqs[i].ready = 1;
            if (mshr_reqs[i].valid && hit_check(mshr_reqs[i].data.addr)) begin
                mshr_rsps[i].valid = 1;
                mshr_rsps[i].data.hit = 1;
                mshr_rsps[i].data.tag = ENTRY_ID;
            end else begin
                mshr_rsps[i].valid = 0;
                mshr_rsps[i].data = '0;
            end
        end
    end
endmodule
