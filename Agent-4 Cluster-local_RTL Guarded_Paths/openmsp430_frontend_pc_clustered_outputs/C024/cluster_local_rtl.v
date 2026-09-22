// ============================================================================
// Cluster-local relation RTL: C024 -> openMSP430.frontend_0.pc
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 5 RTL-proximal candidates. Members: openMSP430.execution_unit_0.reg_pc_call, openMSP430.frontend_0.dst_rd, openMSP430.frontend_0.inst_ad_nxt, openMSP430.inst_ad, openMSP430.mem_backbone_0.fe_mab. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: omsp_execution_unit.v
// Module: omsp_execution_unit
// ----------------------------------------------------------------------------
output              pc_sw_wr;      // Program counter software write
// ... unrelated original RTL lines 105-111 omitted ...
input               dbg_reg_wr;    // Debug unit CPU register write
input         [3:0] e_state;       // Execution state
// ... unrelated original RTL lines 114-114 omitted ...
input         [7:0] inst_ad;       // Decoded Inst: destination addressing mode
input         [7:0] inst_as;       // Decoded Inst: source addressing mode
input        [11:0] inst_alu;      // ALU control signals
// ... unrelated original RTL lines 118-124 omitted ...
input         [7:0] inst_so;       // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 126-126 omitted ...
input         [2:0] inst_type;     // Decoded Instruction type
// ... unrelated original RTL lines 128-156 omitted ...
wire reg_dest_wr  = ((e_state==`E_EXEC) & (
                     (inst_type[`INST_TO] & inst_ad[`DIR] & ~inst_alu[`EXEC_NO_WR])  |
                     (inst_type[`INST_SO] & inst_as[`DIR] & ~(inst_so[`PUSH] | inst_so[`CALL] | inst_so[`RETI])) |
                      inst_type[`INST_JMP])) | dbg_reg_wr;
// ... unrelated original RTL lines 161-170 omitted ...
wire reg_pc_call  = ((e_state==`E_EXEC)   & inst_so[`CALL]) |
                    ((e_state==`E_DST_WR) & inst_so[`RETI]);
// ... unrelated original RTL lines 173-180 omitted ...
omsp_register_file register_file_0 (
// ... unrelated original RTL lines 182-187 omitted ...
    .pc_sw_wr     (pc_sw_wr),     // Program counter software write
// ... unrelated original RTL lines 189-204 omitted ...
    .reg_dest_wr  (reg_dest_wr),  // Write selected register destination
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
output         [7:0] inst_ad;          // Decoded Inst: destination addressing mode
// ... unrelated original RTL lines 111-119 omitted ...
output         [7:0] inst_so;          // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 121-130 omitted ...
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
// ... unrelated original RTL lines 212-213 omitted ...
parameter I_IDLE      = `I_IDLE;       // CPU is in IDLE mode
// ... unrelated original RTL lines 215-219 omitted ...
parameter E_IRQ_0     = `E_IRQ_0;
parameter E_IRQ_1     = `E_IRQ_1;
// ... unrelated original RTL lines 222-224 omitted ...
parameter E_SRC_AD    = `E_SRC_AD;
parameter E_SRC_RD    = `E_SRC_RD;
// ... unrelated original RTL lines 227-227 omitted ...
parameter E_DST_AD    = `E_DST_AD;
parameter E_DST_RD    = `E_DST_RD;
// ... unrelated original RTL lines 230-230 omitted ...
parameter E_EXEC      = `E_EXEC;
// ... unrelated original RTL lines 232-232 omitted ...
parameter E_IDLE      = `E_IDLE;
// ... unrelated original RTL lines 234-240 omitted ...
reg  [2:0] i_state;
// ... unrelated original RTL lines 242-245 omitted ...
wire       irq_detect;
wire [2:0] inst_type_nxt;
// ... unrelated original RTL lines 248-249 omitted ...
reg  [3:0] e_state_nxt;
// ... unrelated original RTL lines 251-252 omitted ...
wire   cpu_halt_req = cpu_halt_cmd | ~cpu_en_s;
// ... unrelated original RTL lines 254-284 omitted ...
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
// ... unrelated original RTL lines 767-771 omitted ...
     if (~inst_type_nxt[`INST_TO])
       inst_ad_nxt =  8'b00000000;
// ... unrelated original RTL lines 774-791 omitted ...
always @(posedge mclk_decode or posedge puc_rst)
  if (puc_rst)     inst_ad <= 8'h00;
`ifdef CLOCK_GATING
  else             inst_ad <= inst_ad_nxt;
// ... unrelated original RTL lines 796-833 omitted ...
wire src_acalc_pre =  inst_as_nxt[`IDX]   | inst_as_nxt[`SYMB]    | inst_as_nxt[`ABS];
wire src_rd_pre    =  inst_as_nxt[`INDIR] | inst_as_nxt[`INDIR_I] | inst_as_nxt[`IMM]  | inst_so_nxt[`RETI];
wire dst_acalc_pre =  inst_ad_nxt[`IDX]   | inst_ad_nxt[`SYMB]    | inst_ad_nxt[`ABS];
wire dst_acalc     =  inst_ad[`IDX]       | inst_ad[`SYMB]        | inst_ad[`ABS];
wire dst_rd_pre    =  inst_ad_nxt[`IDX]   | inst_so_nxt[`PUSH]    | inst_so_nxt[`CALL] | inst_so_nxt[`RETI];
wire dst_rd        =  inst_ad[`IDX]       | inst_so[`PUSH]        | inst_so[`CALL]     | inst_so[`RETI];
// ... unrelated original RTL lines 840-867 omitted ...
wire [3:0] e_first_state = ~cpu_halt_st  & inst_so_nxt[`IRQ] ? E_IRQ_0  :
                            cpu_halt_req | (i_state==I_IDLE) ? E_IDLE   :
                            cpuoff                           ? E_IDLE   :
                            src_acalc_pre                    ? E_SRC_AD :
                            src_rd_pre                       ? E_SRC_RD :
                            dst_acalc_pre                    ? E_DST_AD :
                            dst_rd_pre                       ? E_DST_RD : E_EXEC;
// ... unrelated original RTL lines 875-893 omitted ...
      E_SRC_RD : e_state_nxt =  dst_acalc         ? E_DST_AD :
                                 dst_rd           ? E_DST_RD : E_EXEC;
// ... unrelated original RTL lines 896-914 omitted ...
always @(posedge mclk or posedge puc_rst)
  if (puc_rst) e_state  <= E_IRQ_1;
  else         e_state  <= e_state_nxt;

// ----------------------------------------------------------------------------
// Original source: omsp_mem_backbone.v
// Module: omsp_mem_backbone
// ----------------------------------------------------------------------------
input         [14:0] fe_mab;            // Frontend Memory address bus

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
// ... unrelated original RTL lines 144-180 omitted ...
wire           [7:0] inst_ad;
// ... unrelated original RTL lines 182-189 omitted ...
wire           [7:0] inst_so;
// ... unrelated original RTL lines 191-193 omitted ...
wire           [3:0] e_state;
// ... unrelated original RTL lines 195-197 omitted ...
wire                 cpuoff;
// ... unrelated original RTL lines 199-219 omitted ...
wire          [15:0] fe_mdb_in;
// ... unrelated original RTL lines 221-223 omitted ...
wire                 pc_sw_wr;
wire          [15:0] pc_sw;
wire          [15:0] pc;
wire          [15:0] pc_nxt;
// ... unrelated original RTL lines 228-322 omitted ...
omsp_frontend frontend_0 (
// ... unrelated original RTL lines 324-327 omitted ...
    .e_state           (e_state),            // Execution state
// ... unrelated original RTL lines 329-329 omitted ...
    .inst_ad           (inst_ad),            // Decoded Inst: destination addressing mode
// ... unrelated original RTL lines 331-339 omitted ...
    .inst_so           (inst_so),            // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 341-350 omitted ...
    .pc                (pc),                 // Program counter
    .pc_nxt            (pc_nxt),             // Next PC value (for CALL & IRQ)
// ... unrelated original RTL lines 353-356 omitted ...
    .cpuoff            (cpuoff),             // Turns off the CPU
// ... unrelated original RTL lines 358-364 omitted ...
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
// ... unrelated original RTL lines 402-403 omitted ...
    .inst_ad           (inst_ad),            // Decoded Inst: destination addressing mode
// ... unrelated original RTL lines 405-422 omitted ...
);

// ----------------------------------------------------------------------------
// Referenced original preprocessor definitions
// ----------------------------------------------------------------------------
// source: openMSP430_defines.v:727-727
`define ABS      6
// source: openMSP430_defines.v:692-692
`define CALL   5
// source: openMSP430_defines.v:721-721
`define DIR      0
// source: openMSP430_defines.v:767-767
`define EXEC_NO_WR   11
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
// source: openMSP430_defines.v:745-745
`define E_SRC_AD    4'h5
// source: openMSP430_defines.v:746-746
`define E_SRC_RD    4'h6
// source: openMSP430_defines.v:722-722
`define IDX      1
// source: openMSP430_defines.v:726-726
`define IMM      5
// source: openMSP430_defines.v:723-723
`define INDIR    2
// source: openMSP430_defines.v:724-724
`define INDIR_I  3
// source: openMSP430_defines.v:683-683
`define INST_JMP 1
// source: openMSP430_defines.v:682-682
`define INST_SO  0
// source: openMSP430_defines.v:684-684
`define INST_TO  2
// source: openMSP430_defines.v:694-694
`define IRQ    7
// source: openMSP430_defines.v:733-733
`define I_DEC       3'h2
// source: openMSP430_defines.v:736-736
`define I_IDLE      3'h5
// source: openMSP430_defines.v:732-732
`define I_IRQ_DONE  3'h1
// source: openMSP430_defines.v:731-731
`define I_IRQ_FETCH 3'h0
// source: openMSP430_defines.v:691-691
`define PUSH   4
// source: openMSP430_defines.v:693-693
`define RETI   6
// source: openMSP430_defines.v:725-725
`define SYMB     4
