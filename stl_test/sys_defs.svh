/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  sys_defs.svh                                        //
//                                                                     //
//  Description :  This file defines macros and data structures used   //
//                 throughout the processor.                           //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`ifndef __SYS_DEFS_SVH__
`define __SYS_DEFS_SVH__

// all files should `include "sys_defs.svh" to at least define the timescale
`timescale 1ns/100ps

///////////////////////////////////
// ---- Starting Parameters ---- //
///////////////////////////////////

// some starting parameters that you should set
// this is *your* processor, you decide these values (try analyzing which is best!)

// superscalar width
`define N 2
`define CDB_SZ `N // This MUST match your superscalar width
`define DEBUG_OUT

// sizes

`define ROB_SZ 8

`define RS_SZ 4

`define PHYS_REG_SZ_P6 32
`define PHYS_REG_SZ_R10K (32 + `ROB_SZ)
`define MAP_TABLE_SZ 32

//For testbench
`define PHYS_REG_NUM `PHYS_REG_SZ_R10K


// worry about these later

`define BRANCH_PRED_SZ 8
`define LSQ_SZ 8

// functional units (you should decide if you want more or fewer types of FUs)
`define NUM_FU_ALU 2
`define NUM_FU_MULT 1
`define NUM_FU_LOAD 8
`define NUM_FU_STORE 8


`define NUM_FU_ALU 2

`define NUM_FU_MULT 1
`define NUM_FU_LS 0
`define NUM_FU_BRANCH 0
// number of mult stages (2, 4) (you likely don't need 8)
`define MULT_STAGES 4
`define ALU_FOR_LS 1

`define STQ_SZ 8
`define LDU_SZ 4

// BTB Index/Tag length
`define BTB_IDX_LENGTH 5
`define BTB_TAG_LENGTH 3
`define BTB_DEPTH 32
`define RAS_DEPTH 5
`define PC_MASK_WIDTH 4

///////////////////////////////
// ---- Basic Constants ---- //
///////////////////////////////

// NOTE: the global CLOCK_PERIOD is defined in the Makefile

// useful boolean single-bit definitions
`define FALSE 1'h0
`define TRUE  1'h1

// word and register sizes
typedef logic [31:0] ADDR;
typedef logic [3:0] MASK;
typedef logic [31:0] DATA;
typedef logic [4:0] REG_IDX;
typedef logic [$clog2(32+`ROB_SZ)-1:0] TAG; 
typedef logic [6:0] OPCODE;
typedef logic [`PC_MASK_WIDTH-1:0] PC_MASK; // partial pc index for branch prediction
                                            // , map to the PHT entry this branch is looking at


// the zero register
// In RISC-V, any read of this register returns zero and any writes are thrown away
`define ZERO_REG 5'd0

// Basic NOP instruction. Allows pipline registers to clearly be reset with
// an instruction that does nothing instead of Zero which is really an ADDI x0, x0, 0
`define NOP 32'h00000013

//////////////////////////////////
// ---- Memory Definitions ---- //
//////////////////////////////////

// Cache mode removes the byte-level interface from memory, so it always returns
// a double word. The original processor won't work with this defined. Your new
// processor will have to account for this effect on mem.
// Notably, you can no longer write data without first reading.
// TODO: uncomment this line once you've implemented your cache
`define CACHE_MODE

// you are not allowed to change this definition for your final processor
// the project 3 processor has a massive boost in performance just from having no mem latency
// see if you can beat it's CPI in project 4 even with a 100ns latency!
//`define MEM_LATENCY_IN_CYCLES  0
`define MEM_LATENCY_IN_CYCLES (100.0/`CLOCK_PERIOD+0.49999)
// the 0.49999 is to force ceiling(100/period). The default behavior for
// float to integer conversion is rounding to nearest

// memory tags represent a unique id for outstanding mem transactions
// 0 is a sentinel value and is not a valid tag
`define NUM_MEM_TAGS 15
typedef logic [3:0] MEM_TAG;

// icache definitions
`define ICACHE_LINES 32
`define ICACHE_LINE_BITS $clog2(`ICACHE_LINES)

`define MEM_SIZE_IN_BYTES (64*1024)
`define MEM_64BIT_LINES   (`MEM_SIZE_IN_BYTES/8)

// Dcache parameters 
`define DCACHE_LINES 32
`define DCACHE_offset_bit 3
`define ASSOCIATIVITY 4
`define DCACHE_SET (`DCACHE_LINES/`ASSOCIATIVITY)

`define DCACHE_INDEX_BIT $clog2(`DCACHE_SET)
`define DCACHE_TAG_BIT  13-`DCACHE_INDEX_BIT

`define ALU_FOR_BRANCH 1

`define MSHR_SZ `NUM_MEM_TAGS+1
`define INS_BUFFER_SZ 16

// A memory or cache block
typedef union packed {
    logic [7:0][7:0]  byte_level;
    logic [3:0][15:0] half_level;
    logic [1:0][31:0] word_level;
    logic      [63:0] dbbl_level;
} MEM_BLOCK;

typedef enum logic [1:0] {
    BYTE   = 2'h0,
    HALF   = 2'h1,
    WORD   = 2'h2,
    DOUBLE = 2'h3
} MEM_SIZE;

// Memory bus commands
typedef enum logic [1:0] {
    MEM_NONE   = 2'h0,
    MEM_LOAD   = 2'h1,
    MEM_STORE  = 2'h2
} MEM_COMMAND;

// icache tag struct
typedef struct packed {
    logic [12-`ICACHE_LINE_BITS:0] tags;
    logic                          valid;
} ICACHE_TAG;

typedef struct packed {
    logic [`DCACHE_TAG_BIT-1:0] tags;
    logic                       valid;
} DCACHE_TAG;

typedef struct packed {
    logic [`BTB_TAG_LENGTH-1:0] tags;
    logic valid;
} BTB_ENTRY;

///////////////////////////////
// ---- Exception Codes ---- //
///////////////////////////////

/**
 * Exception codes for when something goes wrong in the processor.
 * Note that we use HALTED_ON_WFI to signify the end of computation.
 * It's original meaning is to 'Wait For an Interrupt', but we generally
 * ignore interrupts in 470
 *
 * This mostly follows the RISC-V Privileged spec
 * except a few add-ons for our infrastructure
 * The majority of them won't be used, but it's good to know what they are
 */

typedef enum logic [3:0] {
    INST_ADDR_MISALIGN  = 4'h0,
    INST_ACCESS_FAULT   = 4'h1,
    ILLEGAL_INST        = 4'h2,
    BREAKPOINT          = 4'h3,
    LOAD_ADDR_MISALIGN  = 4'h4,
    LOAD_ACCESS_FAULT   = 4'h5,
    STORE_ADDR_MISALIGN = 4'h6,
    STORE_ACCESS_FAULT  = 4'h7,
    ECALL_U_MODE        = 4'h8,
    ECALL_S_MODE        = 4'h9,
    NO_ERROR            = 4'ha, // a reserved code that we use to signal no errors
    ECALL_M_MODE        = 4'hb,
    INST_PAGE_FAULT     = 4'hc,
    LOAD_PAGE_FAULT     = 4'hd,
    HALTED_ON_WFI       = 4'he, // 'Wait For Interrupt'. In 470, signifies the end of computation
    STORE_PAGE_FAULT    = 4'hf
} EXCEPTION_CODE;

///////////////////////////////////
// ---- Instruction Typedef ---- //
///////////////////////////////////

// from the RISC-V ISA spec
typedef union packed {
    logic [31:0] inst;
    struct packed {
        logic [6:0] funct7;
        logic [4:0] rs2; // source register 2
        logic [4:0] rs1; // source register 1
        logic [2:0] funct3;
        logic [4:0] rd; // destination register
        logic [6:0] opcode;
    } r; // register-to-register instructions
    struct packed {
        logic [11:0] imm; // immediate value for calculating address
        logic [4:0]  rs1; // source register 1 (used as address base)
        logic [2:0]  funct3;
        logic [4:0]  rd;  // destination register
        logic [6:0]  opcode;
    } i; // immediate or load instructions
    struct packed {
        logic [6:0] off; // offset[11:5] for calculating address
        logic [4:0] rs2; // source register 2
        logic [4:0] rs1; // source register 1 (used as address base)
        logic [2:0] funct3;
        logic [4:0] set; // offset[4:0] for calculating address
        logic [6:0] opcode;
    } s; // store instructions
    struct packed {
        logic       of;  // offset[12]
        logic [5:0] s;   // offset[10:5]
        logic [4:0] rs2; // source register 2
        logic [4:0] rs1; // source register 1
        logic [2:0] funct3;
        logic [3:0] et;  // offset[4:1]
        logic       f;   // offset[11]
        logic [6:0] opcode;
    } b; // branch instructions
    struct packed {
        logic [19:0] imm; // immediate value
        logic [4:0]  rd; // destination register
        logic [6:0]  opcode;
    } u; // upper-immediate instructions
    struct packed {
        logic       of; // offset[20]
        logic [9:0] et; // offset[10:1]
        logic       s;  // offset[11]
        logic [7:0] f;  // offset[19:12]
        logic [4:0] rd; // destination register
        logic [6:0] opcode;
    } j;  // jump instructions

// extensions for other instruction types
`ifdef ATOMIC_EXT
    struct packed {
        logic [4:0] funct5;
        logic       aq;
        logic       rl;
        logic [4:0] rs2;
        logic [4:0] rs1;
        logic [2:0] funct3;
        logic [4:0] rd;
        logic [6:0] opcode;
    } a; // atomic instructions
`endif
`ifdef SYSTEM_EXT
    struct packed {
        logic [11:0] csr;
        logic [4:0]  rs1;
        logic [2:0]  funct3;
        logic [4:0]  rd;
        logic [6:0]  opcode;
    } sys; // system call instructions
`endif

} INST; // instruction typedef, this should cover all types of instructions

////////////////////////////////////////
// ---- Datapath Control Signals ---- //
////////////////////////////////////////

// ALU opA input mux selects
typedef enum logic [1:0] {
    OPA_IS_RS1  = 2'h0,
    OPA_IS_NPC  = 2'h1,
    OPA_IS_PC   = 2'h2,
    OPA_IS_ZERO = 2'h3
} ALU_OPA_SELECT;

// ALU opB input mux selects
typedef enum logic [3:0] {
    OPB_IS_RS2    = 4'h0,
    OPB_IS_I_IMM  = 4'h1,
    OPB_IS_S_IMM  = 4'h2,
    OPB_IS_B_IMM  = 4'h3,
    OPB_IS_U_IMM  = 4'h4,
    OPB_IS_J_IMM  = 4'h5
} ALU_OPB_SELECT;

// ALU function code
typedef enum logic [3:0] {
    ALU_ADD     = 4'h0,
    ALU_SUB     = 4'h1,
    ALU_SLT     = 4'h2,
    ALU_SLTU    = 4'h3,
    ALU_AND     = 4'h4,
    ALU_OR      = 4'h5,
    ALU_XOR     = 4'h6,
    ALU_SLL     = 4'h7,
    ALU_SRL     = 4'h8,
    ALU_SRA     = 4'h9
} ALU_FUNC;

// MULT funct3 code
// we don't include division or rem options
typedef enum logic [2:0] {
    M_MUL,
    M_MULH,
    M_MULHSU,
    M_MULHU
} MULT_FUNC;

////////////////////////////////
// ---- Datapath Packets ---- //
////////////////////////////////

/**
 * Packets are used to move many variables between modules with
 * just one datatype, but can be cumbersome in some circumstances.
 *
 * Define new ones in project 4 at your own discretion
 */

/**
 * IF_ID Packet:
 * Data exchanged from the IF to the ID stage
 */
typedef struct packed {
    INST  inst;
    ADDR  PC;
    ADDR  NPC; // PC + 4

    ADDR  BTB_PC;               // target-PC fetched from BTB, if this is a cond branch
    logic predicted_direction;  // direction prediction made by branch predictor, if this is a cond branch

    logic valid;
} IF_ID_PACKET;

/**
 * ID_EX Packet:
 * Data exchanged from the ID to the EX stage
 */
typedef struct packed {
    INST inst;
    ADDR PC;
    ADDR NPC; // PC + 4

    // Branch prediction
    ADDR  predicted_NPC;        // target-PC predicted
    logic predicted_direction;  // direction prediction made by branch predictor, if this is a cond branch
    logic meta_prediction;  //Predicted by the meta chooser

    DATA rs1_value; // reg A value
    DATA rs2_value; // reg B value

    //b_mask
    MASK b_mask;
    MASK b_tag;

    ALU_OPA_SELECT opa_select; // ALU opa mux select (ALU_OPA_xxx *)
    ALU_OPB_SELECT opb_select; // ALU opb mux select (ALU_OPB_xxx *)

    REG_IDX  dest_reg_idx;  // destination (writeback) register index
    ALU_FUNC alu_func;      // ALU function select (ALU_xxx *)
    logic    mult;          // Is inst a multiply instruction?
    logic    rd_mem;        // Does inst read memory?
    logic    wr_mem;        // Does inst write memory?
    logic    cond_branch;   // Is inst a conditional branch?
    logic    uncond_branch; // Is inst an unconditional branch?
    logic    take_func_call;
    logic    take_return;   
    logic    halt;          // Is this a halt?
    logic    illegal;       // Is this instruction illegal?
    logic    csr_op;        // Is this a CSR operation? (we only used this as a cheap way to get return code)

    logic    valid;
} ID_EX_PACKET;

/**
 * EX_MEM Packet:
 * Data exchanged from the EX to the MEM stage
 */
typedef struct packed {
    DATA alu_result;
    ADDR NPC;

    logic    take_branch; // Is this a taken branch?
    // Pass-through from decode stage
    DATA     rs2_value;
    logic    rd_mem;
    logic    wr_mem;
    REG_IDX  dest_reg_idx;
    logic    halt;
    logic    illegal;
    logic    csr_op;
    logic    rd_unsigned; // Whether proc2Dmem_data is signed or unsigned
    MEM_SIZE mem_size;
    logic    valid;
} EX_MEM_PACKET;

/**
 * MEM_WB Packet:
 * Data exchanged from the MEM to the WB stage
 *
 * Does not include data sent from the MEM stage to memory
 */
typedef struct packed {
    DATA    result;
    ADDR    NPC;
    REG_IDX dest_reg_idx; // writeback destination (ZERO_REG if no writeback)
    logic   take_branch;
    logic   halt;    // not used by wb stage
    logic   illegal; // not used by wb stage
    logic   valid;
} MEM_WB_PACKET;

/**
 * Commit Packet:
 * This is an output of the processor and used in the testbench for counting
 * committed instructions
 *
 * It also acts as a "WB_PACKET", and can be reused in the final project with
 * some slight changes
 */
typedef struct packed {
    ADDR    NPC;
    INST    inst;
    DATA    data;
    logic    wr_mem;
    logic    rd_mem;
    REG_IDX reg_idx;
    logic   halt;
    logic   illegal;
    logic   valid;
} COMMIT_PACKET;


/**
*   RS Output Packet:
*   Output packet to FU/LSQ/...
*   
*/
typedef struct packed{
    ID_EX_PACKET id_ex_packet_s;
    TAG     T, T1, T2; //@TAG
    logic   [$clog2(`ROB_SZ):0] rob_idx;
} RS_EX_PACKET;


typedef struct packed {
    logic   [$clog2(`ROB_SZ):0] rob_idx;
    TAG     T;
    logic   rd_mem;
    logic   wr_mem;
    logic   valid;  // For load and store instrs: means addr_valid; For others: CDB ready
    DATA    result;
    
    MASK b_tag;
    MASK b_mask;
    // logic   take_conditional;
} EX_COM_PACKET;



typedef struct packed {
    // FIXME: When from ex stage, situation of only 2nd packet valid is possible.

    EX_COM_PACKET ex_packet_in;     // result: mem address

    logic [2:0] memsize;
    // after mem
    DATA    data;   //ld: data from mem; st: data to mem
    logic   data_ready;  // data ready

    MASK b_mask;
    
} EX_LSQ_PACKET;


/*
  Data structure of rob entry
*/
typedef struct packed{
    // logic valid;

    logic complete;
    logic is_stq_head;
    ADDR  NPC;
    INST  inst;
    logic wr_mem;
    logic rd_mem;
    DATA  result;                                      
    REG_IDX dest_reg_idx;
    TAG   T, Told;
    logic   halt;
    logic   illegal;

} ROB_ENTRY;

typedef struct packed{
    // logic  valid;
    logic  [$clog2(`ROB_SZ):0] tail;
    logic  [$clog2(`ROB_SZ):0] space;
} ROB_mask_tag;



typedef struct packed{
    logic [$clog2(`INS_BUFFER_SZ):0] ins_pos;
    ADDR                            addr;
    MEM_TAG                         tag;
    logic [`ICACHE_LINE_BITS -1:0]  index;
    logic                           valid;
} ICACHE_MSHR_ENTRY;

typedef struct packed{
    ADDR        addr;
    logic [`DCACHE_TAG_BIT-1:0]     tag;
    logic [`DCACHE_INDEX_BIT -1:0]  index;
    // MEM_SIZE                        mem_size;
    logic [63:0]                    valid_mask;
    logic                           is_ld; // 1 ld; 0 st
    MEM_BLOCK                            st_data;
    logic                           valid;
    logic                           found_similar; // have store to same addr[15:3] in mshr, but different addr[2]
    // logic [$clog2(`LDU_SZ)-1:0]     ldu_idx;
} DCACHE_MSHR_ENTRY;

typedef struct packed{
    ADDR PC;
    logic    valid; // FIFO valid bit
    logic   [$clog2(`ROB_SZ):0]     rob_idx;
    INST      inst;
    // MASK       b_mask;
    ADDR        addr;   
    logic       addr_ready;
    DATA        data;
    logic       data_ready;
    logic [31:0] data_mask; 
    logic        stq_request_bit;

    // logic    request_accept;

    // DATA data_mask; 

} STQ_ENTRY;




typedef struct packed{
    ADDR [`LDU_SZ-1:0]PC;
    logic  [`LDU_SZ-1:0] valid; // 0: occupied 1: vacant
    INST    [`LDU_SZ-1:0]  inst;
    logic  [`LDU_SZ-1:0] [$clog2(`ROB_SZ):0] rob_idx;

    TAG [`LDU_SZ-1:0]   T;
    MASK [`LDU_SZ-1:0]  b_mask;

    ADDR   [`LDU_SZ-1:0] addr; // from cdb
    logic  [`LDU_SZ-1:0] addr_ready; 

    DATA   [`LDU_SZ-1:0] data; 
    logic  [`LDU_SZ-1:0] data_ready; // ready to interface 

    // DATA   [`LDU_SZ-1:0] data_cdb; //data return from interface
    logic  [`LDU_SZ-1:0] data_cdb_ready; // wait for cdb to select

    logic  [`LDU_SZ-1:0][`STQ_SZ-1:0] checklist;

    logic  [`LDU_SZ-1:0][`STQ_SZ-1:0] calculate_list;

    logic  [`LDU_SZ-1:0][31:0] data_mask;
    logic  [`LDU_SZ-1:0][31:0] data_valid_mask; // forwarding & cache/mem

    logic  [`LDU_SZ-1:0] ldu_request_bit; // means the inst is accessing cache

    logic  [`LDU_SZ-1:0] request_accept; // means the inst is accessing cache

} LDU_ENTRY;




// rollback structure for lsq
// store queue
typedef struct packed {
    logic  [$clog2(`STQ_SZ)-1:0] tail;
    logic   [$clog2(`STQ_SZ):0]         stq_space;
} STQ_branch_ENTRY;

`endif // __SYS_DEFS_SVH__