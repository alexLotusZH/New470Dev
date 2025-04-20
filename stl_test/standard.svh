`ifndef _STANDARD_SVH_
`define _STANDARD_SVH_

// all files should `include "sys_defs.svh" to at least define the timescale
`timescale 1ns/100ps


typedef logic[7:0]  ADDRS;
typedef logic[15:0] DATAS;

typedef struct packed{
    logic ld_st;
    ADDRS addr;
} Req;  // PAcket sent from Producer to Consumer to request MSHR response

typedef struct packed{
    logic hit_miss;
    ADDRS addr;
    DATAS data;
} Rsp;  // PAcket sent from Producer to Consumer to request MSHR response




`endif