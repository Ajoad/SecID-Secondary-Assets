// ============================================================================
// Cluster-local relation RTL: C012 -> openMSP430.frontend_0.pc
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 5 RTL-proximal candidates. Members: openMSP430.dbg_en_s, openMSP430.exec_done, openMSP430.frontend_0.inst_sz, openMSP430.frontend_0.inst_sz_nxt, openMSP430.mem_backbone_0.pmem_dout_bckup. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: omsp_dbg.v
// Module: omsp_dbg
// ----------------------------------------------------------------------------
output              dbg_halt_cmd;      // Halt CPU command
// ... unrelated original RTL lines 94-108 omitted ...
input               dbg_en_s;          // Debug interface enable (synchronous)
// ... unrelated original RTL lines 110-124 omitted ...
input               puc_pnd_set;       // PUC pending set for the serial debug interface
// ... unrelated original RTL lines 126-139 omitted ...
wire        dbg_swbrk;
// ... unrelated original RTL lines 141-144 omitted ...
wire        brk0_halt;
// ... unrelated original RTL lines 146-147 omitted ...
wire        brk1_halt;
// ... unrelated original RTL lines 149-150 omitted ...
wire        brk2_halt;
// ... unrelated original RTL lines 152-153 omitted ...
wire        brk3_halt;
// ... unrelated original RTL lines 155-325 omitted ...
reg   [6:3] cpu_ctl;
// ... unrelated original RTL lines 327-339 omitted ...
wire        halt_cpu = cpu_ctl_wr & dbg_din[`HALT]  & ~dbg_halt_st;
// ... unrelated original RTL lines 341-664 omitted ...
wire halt_rst = cpu_ctl[`RST_BRK_EN] & dbg_en_s & puc_pnd_set;
// ... unrelated original RTL lines 666-679 omitted ...
reg [1:0] inc_step;
// ... unrelated original RTL lines 681-688 omitted ...
reg   halt_flag;
// ... unrelated original RTL lines 690-690 omitted ...
wire  mem_halt_cpu;
// ... unrelated original RTL lines 692-694 omitted ...
wire  halt_flag_set = halt_cpu  | halt_rst  | dbg_swbrk | mem_halt_cpu |
                      brk0_halt | brk1_halt | brk2_halt | brk3_halt;
// ... unrelated original RTL lines 697-702 omitted ...
wire dbg_halt_cmd = (halt_flag | halt_flag_set) & ~inc_step[1];

// ----------------------------------------------------------------------------
// Original source: omsp_execution_unit.v
// Module: omsp_execution_unit
// ----------------------------------------------------------------------------
output              pc_sw_wr;      // Program counter software write
// ... unrelated original RTL lines 105-112 omitted ...
input         [3:0] e_state;       // Execution state
// ... unrelated original RTL lines 114-124 omitted ...
input         [7:0] inst_so;       // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 126-170 omitted ...
wire reg_pc_call  = ((e_state==`E_EXEC)   & inst_so[`CALL]) |
                    ((e_state==`E_DST_WR) & inst_so[`RETI]);
// ... unrelated original RTL lines 173-180 omitted ...
omsp_register_file register_file_0 (
// ... unrelated original RTL lines 182-187 omitted ...
    .pc_sw_wr     (pc_sw_wr),     // Program counter software write
// ... unrelated original RTL lines 189-205 omitted ...
    .reg_pc_call  (reg_pc_call),  // Trigger PC update for a CALL instruction
// ... unrelated original RTL lines 207-212 omitted ...
);
// ... unrelated original RTL lines 214-300 omitted ...
wire exec_cycle = (e_state==`E_EXEC);
// ... unrelated original RTL lines 302-392 omitted ...
reg         mdb_in_buf_valid;
// ... unrelated original RTL lines 394-395 omitted ...
  else if (e_state==`E_EXEC) mdb_in_buf_valid <= 1'b0;

// ----------------------------------------------------------------------------
// Original source: omsp_frontend.v
// Module: omsp_frontend
// ----------------------------------------------------------------------------
`timescale 1ns/1ps

//----------------------------------------------------------------------------
// Copyright (C) 2009 , Olivier Girard
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the authors nor the names of its contributors
//       may be used to endorse or promote products derived from this software
//       without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// ... unrelated original RTL lines 25-105 omitted ...
output               cpu_halt_st;      // Halt/Run status from CPU
// ... unrelated original RTL lines 107-107 omitted ...
output         [3:0] e_state;          // Execution state
output               exec_done;        // Execution completed
// ... unrelated original RTL lines 110-130 omitted ...
output        [15:0] pc;               // Program counter
output        [15:0] pc_nxt;           // Next PC value (for CALL & IRQ)
// ... unrelated original RTL lines 133-135 omitted ...
input                cpu_en_s;         // Enable CPU code execution (synchronous)
input                cpu_halt_cmd;     // Halt CPU command
input                cpuoff;           // Turns off the CPU
// ... unrelated original RTL lines 139-144 omitted ...
input                mclk;             // Main system clock
input         [15:0] mdb_in;           // Frontend Memory data bus input
// ... unrelated original RTL lines 147-148 omitted ...
input         [15:0] pc_sw;            // Program counter software value
input                pc_sw_wr;         // Program counter software write
input                puc_rst;          // Main system reset
input                scan_enable;      // Scan enable (active during scan shifting)
// ... unrelated original RTL lines 153-163 omitted ...
   input  [5:0] binary;
// ... unrelated original RTL lines 165-172 omitted ...
   input  [3:0] binary;
// ... unrelated original RTL lines 174-180 omitted ...
function [7:0] one_hot8;
   input  [2:0] binary;
   begin
      one_hot8         = 8'h00;
      one_hot8[binary] = 1'b1;
   end
endfunction
// ... unrelated original RTL lines 188-208 omitted ...
parameter I_IRQ_FETCH = `I_IRQ_FETCH;
parameter I_IRQ_DONE  = `I_IRQ_DONE;
parameter I_DEC       = `I_DEC;        // New instruction ready for decode
parameter I_EXT1      = `I_EXT1;       // 1st Extension word
parameter I_EXT2      = `I_EXT2;       // 2nd Extension word
parameter I_IDLE      = `I_IDLE;       // CPU is in IDLE mode
// ... unrelated original RTL lines 215-219 omitted ...
parameter E_IRQ_0     = `E_IRQ_0;
parameter E_IRQ_1     = `E_IRQ_1;
// ... unrelated original RTL lines 222-224 omitted ...
parameter E_SRC_AD    = `E_SRC_AD;
parameter E_SRC_RD    = `E_SRC_RD;
parameter E_SRC_WR    = `E_SRC_WR;
parameter E_DST_AD    = `E_DST_AD;
parameter E_DST_RD    = `E_DST_RD;
parameter E_DST_WR    = `E_DST_WR;
parameter E_EXEC      = `E_EXEC;
parameter E_JUMP      = `E_JUMP;
parameter E_IDLE      = `E_IDLE;
// ... unrelated original RTL lines 234-240 omitted ...
reg  [2:0] i_state;
reg  [2:0] i_state_nxt;
// ... unrelated original RTL lines 243-243 omitted ...
reg  [1:0] inst_sz;
wire [1:0] inst_sz_nxt;
wire       irq_detect;
wire [2:0] inst_type_nxt;
// ... unrelated original RTL lines 248-249 omitted ...
reg  [3:0] e_state_nxt;
// ... unrelated original RTL lines 251-252 omitted ...
wire   cpu_halt_req = cpu_halt_cmd | ~cpu_en_s;
// ... unrelated original RTL lines 254-262 omitted ...
      I_DEC      : i_state_nxt =  irq_detect                  ? I_IRQ_FETCH :
                          (cpuoff | cpu_halt_req) & exec_done ? I_IDLE      :
                            cpu_halt_req & (e_state==E_IDLE)  ? I_IDLE      :
                                  pc_sw_wr                    ? I_DEC       :
                             ~exec_done & ~(e_state==E_IDLE)  ? I_DEC       :        // Wait in decode state
                                  (inst_sz_nxt!=2'b00)        ? I_EXT1      : I_DEC; // until execution is completed
      I_EXT1     : i_state_nxt =  pc_sw_wr                    ? I_DEC       :
                                  (inst_sz!=2'b01)            ? I_EXT2      : I_DEC;
// ... unrelated original RTL lines 271-277 omitted ...
always @(posedge mclk or posedge puc_rst)
  if (puc_rst) i_state  <= I_IRQ_FETCH;
  else         i_state  <= i_state_nxt;
// ... unrelated original RTL lines 281-283 omitted ...
wire   decode       =  decode_noirq | irq_detect;
wire   fetch        = ~((i_state==I_DEC) & ~(exec_done | (e_state==E_IDLE))) & ~(e_state_nxt==E_IDLE);
// ... unrelated original RTL lines 286-334 omitted ...
reg  [5:0] irq_num;
// ... unrelated original RTL lines 336-345 omitted ...
wire [15:0] irq_addr    = {9'h1ff, irq_num, 1'b0};
// ... unrelated original RTL lines 347-410 omitted ...
wire [15:0] pc_incr = pc + {14'h0000, fetch, 1'b0};
wire [15:0] pc_nxt  = pc_sw_wr               ? pc_sw    :
                      (i_state==I_IRQ_FETCH) ? irq_addr :
                      (i_state==I_IRQ_DONE)  ? mdb_in   :  pc_incr;
// ... unrelated original RTL lines 415-415 omitted ...
`ifdef CLOCK_GATING
wire       pc_en  = fetch                  |
                    pc_sw_wr               |
                    (i_state==I_IRQ_FETCH) |
                    (i_state==I_IRQ_DONE);
wire       mclk_pc;
omsp_clock_gate clock_gate_pc (.gclk(mclk_pc),
                               .clk (mclk), .enable(pc_en), .scan_enable(scan_enable));
`else
wire       mclk_pc = mclk;
`endif
// ... unrelated original RTL lines 427-427 omitted ...
always @(posedge mclk_pc or posedge puc_rst)
  if (puc_rst)  pc <= 16'h0000;
  else          pc <= pc_nxt;
// ... unrelated original RTL lines 431-447 omitted ...
wire [15:0] ir  = mdb_in;
// ... unrelated original RTL lines 449-520 omitted ...
wire       mclk_decode;
// ... unrelated original RTL lines 522-564 omitted ...
wire  [7:0] inst_so_nxt = irq_detect ? 8'h80 : (one_hot8(ir[9:7]) & {8{inst_type_nxt[`INST_SO]}});
// ... unrelated original RTL lines 566-688 omitted ...
reg [12:0] inst_as_nxt;
// ... unrelated original RTL lines 690-765 omitted ...
reg  [7:0] inst_ad_nxt;
// ... unrelated original RTL lines 767-811 omitted ...
assign    inst_sz_nxt = {1'b0,  (inst_as_nxt[`IDX] | inst_as_nxt[`SYMB] | inst_as_nxt[`ABS] | inst_as_nxt[`IMM])} +
                        {1'b0, ((inst_ad_nxt[`IDX] | inst_ad_nxt[`SYMB] | inst_ad_nxt[`ABS]) & ~inst_type_nxt[`INST_SO])};
always @(posedge mclk_decode or posedge puc_rst)
  if (puc_rst)     inst_sz     <= 2'b00;
`ifdef CLOCK_GATING
  else             inst_sz     <= inst_sz_nxt;
// ... unrelated original RTL lines 818-833 omitted ...
wire src_acalc_pre =  inst_as_nxt[`IDX]   | inst_as_nxt[`SYMB]    | inst_as_nxt[`ABS];
wire src_rd_pre    =  inst_as_nxt[`INDIR] | inst_as_nxt[`INDIR_I] | inst_as_nxt[`IMM]  | inst_so_nxt[`RETI];
wire dst_acalc_pre =  inst_ad_nxt[`IDX]   | inst_ad_nxt[`SYMB]    | inst_ad_nxt[`ABS];
// ... unrelated original RTL lines 837-837 omitted ...
wire dst_rd_pre    =  inst_ad_nxt[`IDX]   | inst_so_nxt[`PUSH]    | inst_so_nxt[`CALL] | inst_so_nxt[`RETI];
// ... unrelated original RTL lines 839-842 omitted ...
reg exec_jmp;
// ... unrelated original RTL lines 844-848 omitted ...
reg exec_dst_wr;
// ... unrelated original RTL lines 850-854 omitted ...
reg exec_src_wr;
// ... unrelated original RTL lines 856-867 omitted ...
wire [3:0] e_first_state = ~cpu_halt_st  & inst_so_nxt[`IRQ] ? E_IRQ_0  :
                            cpu_halt_req | (i_state==I_IDLE) ? E_IDLE   :
                            cpuoff                           ? E_IDLE   :
                            src_acalc_pre                    ? E_SRC_AD :
                            src_rd_pre                       ? E_SRC_RD :
                            dst_acalc_pre                    ? E_DST_AD :
                            dst_rd_pre                       ? E_DST_RD : E_EXEC;
// ... unrelated original RTL lines 875-914 omitted ...
always @(posedge mclk or posedge puc_rst)
  if (puc_rst) e_state  <= E_IRQ_1;
  else         e_state  <= e_state_nxt;
// ... unrelated original RTL lines 918-922 omitted ...
wire exec_done = exec_jmp        ? (e_state==E_JUMP)   :
                 exec_dst_wr     ? (e_state==E_DST_WR) :
                 exec_src_wr     ? (e_state==E_SRC_WR) : (e_state==E_EXEC);

// ----------------------------------------------------------------------------
// Original source: omsp_mem_backbone.v
// Module: omsp_mem_backbone
// ----------------------------------------------------------------------------
output               cpu_halt_cmd;      // Halt CPU command
// ... unrelated original RTL lines 103-108 omitted ...
output        [15:0] fe_mdb_in;         // Frontend Memory data bus input
// ... unrelated original RTL lines 110-125 omitted ...
input                dbg_halt_cmd;      // Debug interface Halt CPU command
// ... unrelated original RTL lines 127-137 omitted ...
input                mclk;              // Main system clock
// ... unrelated original RTL lines 139-140 omitted ...
input                dma_en;            // Direct Memory Access enable (high active)
input                dma_priority;      // Direct Memory Access priority (0:low / 1:high)
// ... unrelated original RTL lines 143-144 omitted ...
input         [15:0] pmem_dout;         // Program Memory data output
input                puc_rst;           // Main system reset
// ... unrelated original RTL lines 147-169 omitted ...
assign      cpu_halt_cmd  =  dbg_halt_cmd | (dma_en & dma_priority);
// ... unrelated original RTL lines 171-323 omitted ...
wire fe_pmem_save    = (~fe_pmem_en &  fe_pmem_en_dly) & ~cpu_halt_st;
wire fe_pmem_restore = ( fe_pmem_en & ~fe_pmem_en_dly) |  cpu_halt_st;
// ... unrelated original RTL lines 326-336 omitted ...
reg  [15:0] pmem_dout_bckup;
always @(posedge `MCLK_BCKUP or posedge puc_rst)
  if (puc_rst)              pmem_dout_bckup     <=  16'h0000;
`ifdef CLOCK_GATING
  else                      pmem_dout_bckup     <=  pmem_dout;
// ... unrelated original RTL lines 342-346 omitted ...
reg         pmem_dout_bckup_sel;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)              pmem_dout_bckup_sel <=  1'b0;
  else if (fe_pmem_save)    pmem_dout_bckup_sel <=  1'b1;
  else if (fe_pmem_restore) pmem_dout_bckup_sel <=  1'b0;
// ... unrelated original RTL lines 352-352 omitted ...
assign fe_mdb_in = pmem_dout_bckup_sel ? pmem_dout_bckup : pmem_dout;

// ----------------------------------------------------------------------------
// Original source: omsp_register_file.v
// Module: omsp_register_file
// ----------------------------------------------------------------------------
output              pc_sw_wr;     // Program counter software write
// ... unrelated original RTL lines 91-101 omitted ...
input        [15:0] inst_dest;    // Register destination selection
// ... unrelated original RTL lines 103-107 omitted ...
input               reg_dest_wr;  // Write selected register destination
input               reg_pc_call;  // Trigger PC update for a CALL instruction
// ... unrelated original RTL lines 110-144 omitted ...
wire        pc_sw_wr = (inst_dest[0] & reg_dest_wr) | reg_pc_call;

// ----------------------------------------------------------------------------
// Original source: openMSP430.v
// Module: openMSP430
// ----------------------------------------------------------------------------
output               puc_rst;                // Main system reset
// ... unrelated original RTL lines 144-168 omitted ...
input         [15:0] pmem_dout;              // Program Memory data output
// ... unrelated original RTL lines 170-193 omitted ...
wire           [3:0] e_state;
wire                 exec_done;
// ... unrelated original RTL lines 196-219 omitted ...
wire          [15:0] fe_mdb_in;
// ... unrelated original RTL lines 221-223 omitted ...
wire                 pc_sw_wr;
wire          [15:0] pc_sw;
wire          [15:0] pc;
wire          [15:0] pc_nxt;
// ... unrelated original RTL lines 228-243 omitted ...
wire                 dbg_en_s;
wire                 dbg_halt_cmd;
// ... unrelated original RTL lines 246-255 omitted ...
wire                 cpu_halt_cmd;
// ... unrelated original RTL lines 257-322 omitted ...
omsp_frontend frontend_0 (
// ... unrelated original RTL lines 324-327 omitted ...
    .e_state           (e_state),            // Execution state
    .exec_done         (exec_done),          // Execution completed
// ... unrelated original RTL lines 330-350 omitted ...
    .pc                (pc),                 // Program counter
    .pc_nxt            (pc_nxt),             // Next PC value (for CALL & IRQ)
// ... unrelated original RTL lines 353-355 omitted ...
    .cpu_halt_cmd      (cpu_halt_cmd),       // Halt CPU command
// ... unrelated original RTL lines 357-364 omitted ...
    .mdb_in            (fe_mdb_in),          // Frontend Memory data bus input
// ... unrelated original RTL lines 366-367 omitted ...
    .pc_sw             (pc_sw),              // Program counter software value
    .pc_sw_wr          (pc_sw_wr),           // Program counter software write
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 371-374 omitted ...
);
// ... unrelated original RTL lines 376-381 omitted ...
omsp_execution_unit execution_unit_0 (
// ... unrelated original RTL lines 383-392 omitted ...
    .pc_sw_wr          (pc_sw_wr),           // Program counter software write
// ... unrelated original RTL lines 394-400 omitted ...
    .e_state           (e_state),            // Execution state
// ... unrelated original RTL lines 402-422 omitted ...
);
// ... unrelated original RTL lines 424-429 omitted ...
omsp_mem_backbone mem_backbone_0 (
// ... unrelated original RTL lines 431-432 omitted ...
    .cpu_halt_cmd      (cpu_halt_cmd),       // Halt CPU command
// ... unrelated original RTL lines 434-439 omitted ...
    .fe_mdb_in         (fe_mdb_in),          // Frontend Memory data bus input
// ... unrelated original RTL lines 441-455 omitted ...
    .dbg_halt_cmd      (dbg_halt_cmd),       // Debug interface Halt CPU command
// ... unrelated original RTL lines 457-474 omitted ...
    .pmem_dout         (pmem_dout),          // Program Memory data output
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 477-477 omitted ...
);
// ... unrelated original RTL lines 479-598 omitted ...
omsp_dbg dbg_0 (
// ... unrelated original RTL lines 600-603 omitted ...
    .dbg_halt_cmd      (dbg_halt_cmd),       // Halt CPU command
// ... unrelated original RTL lines 605-618 omitted ...
    .dbg_en_s          (dbg_en_s),           // Debug interface enable (synchronous)
// ... unrelated original RTL lines 620-635 omitted ...
);

// ----------------------------------------------------------------------------
// Referenced original preprocessor definitions
// ----------------------------------------------------------------------------
// source: openMSP430_defines.v:727-727
`define ABS      6
// source: openMSP430_defines.v:692-692
`define CALL   5
// source: openMSP430_defines.v:748-748
`define E_DST_AD    4'h8
// source: openMSP430_defines.v:749-749
`define E_DST_RD    4'h9
// source: openMSP430_defines.v:750-750
`define E_DST_WR    4'hA
// source: openMSP430_defines.v:751-751
`define E_EXEC      4'hB
// source: openMSP430_defines.v:753-753
`define E_IDLE      4'hD
// source: openMSP430_defines.v:740-740
`define E_IRQ_0     4'h2
// source: openMSP430_defines.v:741-741
`define E_IRQ_1     4'h1
// source: openMSP430_defines.v:752-752
`define E_JUMP      4'hC
// source: openMSP430_defines.v:745-745
`define E_SRC_AD    4'h5
// source: openMSP430_defines.v:746-746
`define E_SRC_RD    4'h6
// source: openMSP430_defines.v:747-747
`define E_SRC_WR    4'h7
// source: openMSP430_defines.v:775-775
`define HALT        0
// source: openMSP430_defines.v:722-722
`define IDX      1
// source: openMSP430_defines.v:726-726
`define IMM      5
// source: openMSP430_defines.v:723-723
`define INDIR    2
// source: openMSP430_defines.v:724-724
`define INDIR_I  3
// source: openMSP430_defines.v:682-682
`define INST_SO  0
// source: openMSP430_defines.v:694-694
`define IRQ    7
// source: openMSP430_defines.v:733-733
`define I_DEC       3'h2
// source: openMSP430_defines.v:734-734
`define I_EXT1      3'h3
// source: openMSP430_defines.v:735-735
`define I_EXT2      3'h4
// source: openMSP430_defines.v:736-736
`define I_IDLE      3'h5
// source: openMSP430_defines.v:732-732
`define I_IRQ_DONE  3'h1
// source: openMSP430_defines.v:731-731
`define I_IRQ_FETCH 3'h0
// source: omsp_mem_backbone.v:334-334
`define MCLK_BCKUP           mclk        // use macro to solve delta cycle issues with some mixed VHDL/Verilog simulators
// source: openMSP430_defines.v:691-691
`define PUSH   4
// source: openMSP430_defines.v:693-693
`define RETI   6
// source: openMSP430_defines.v:780-780
`define RST_BRK_EN  5
// source: openMSP430_defines.v:725-725
`define SYMB     4
