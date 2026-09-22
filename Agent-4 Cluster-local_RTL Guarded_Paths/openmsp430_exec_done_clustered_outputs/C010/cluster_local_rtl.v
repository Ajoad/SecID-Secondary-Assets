// ============================================================================
// Cluster-local relation RTL: C010 -> openMSP430.frontend_0.exec_done
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 5 RTL-proximal candidates. Members: openMSP430.frontend_0.exec_dext_rdy, openMSP430.frontend_0.exec_dst_wr, openMSP430.frontend_0.inst_dext_en, openMSP430.frontend_0.inst_sext_rdy, openMSP430.frontend_0.is_sext. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

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
// ... unrelated original RTL lines 110-110 omitted ...
output         [7:0] inst_as;          // Decoded Inst: source addressing mode
// ... unrelated original RTL lines 112-137 omitted ...
input                cpuoff;           // Turns off the CPU
// ... unrelated original RTL lines 139-144 omitted ...
input                mclk;             // Main system clock
// ... unrelated original RTL lines 146-150 omitted ...
input                puc_rst;          // Main system reset
// ... unrelated original RTL lines 152-163 omitted ...
   input  [5:0] binary;
// ... unrelated original RTL lines 165-172 omitted ...
   input  [3:0] binary;
// ... unrelated original RTL lines 174-181 omitted ...
   input  [2:0] binary;
// ... unrelated original RTL lines 183-211 omitted ...
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
// ... unrelated original RTL lines 242-249 omitted ...
reg  [3:0] e_state_nxt;
// ... unrelated original RTL lines 251-252 omitted ...
wire   cpu_halt_req = cpu_halt_cmd | ~cpu_en_s;
// ... unrelated original RTL lines 254-283 omitted ...
wire   decode       =  decode_noirq | irq_detect;
// ... unrelated original RTL lines 285-450 omitted ...
wire is_sext = (inst_as[`IDX] | inst_as[`SYMB] | inst_as[`ABS] | inst_as[`IMM]);
// ... unrelated original RTL lines 452-486 omitted ...
wire inst_sext_rdy = (i_state==I_EXT1) & is_sext;
// ... unrelated original RTL lines 488-493 omitted ...
wire       inst_dext_en  = ((i_state==I_EXT1) & ~is_sext) |
                            (i_state==I_EXT2);
// ... unrelated original RTL lines 496-512 omitted ...
wire inst_dext_rdy = (((i_state==I_EXT1) & ~is_sext) | (i_state==I_EXT2));
// ... unrelated original RTL lines 514-564 omitted ...
wire  [7:0] inst_so_nxt = irq_detect ? 8'h80 : (one_hot8(ir[9:7]) & {8{inst_type_nxt[`INST_SO]}});
// ... unrelated original RTL lines 566-833 omitted ...
wire src_acalc_pre =  inst_as_nxt[`IDX]   | inst_as_nxt[`SYMB]    | inst_as_nxt[`ABS];
wire src_rd_pre    =  inst_as_nxt[`INDIR] | inst_as_nxt[`INDIR_I] | inst_as_nxt[`IMM]  | inst_so_nxt[`RETI];
wire dst_acalc_pre =  inst_ad_nxt[`IDX]   | inst_ad_nxt[`SYMB]    | inst_ad_nxt[`ABS];
// ... unrelated original RTL lines 837-837 omitted ...
wire dst_rd_pre    =  inst_ad_nxt[`IDX]   | inst_so_nxt[`PUSH]    | inst_so_nxt[`CALL] | inst_so_nxt[`RETI];
// ... unrelated original RTL lines 839-840 omitted ...
wire inst_branch   =  (inst_ad_nxt[`DIR] & (ir[3:0]==4'h0)) | inst_type_nxt[`INST_JMP] | inst_so_nxt[`RETI];
// ... unrelated original RTL lines 842-842 omitted ...
reg exec_jmp;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)                   exec_jmp <= 1'b0;
  else if (inst_branch & decode) exec_jmp <= 1'b1;
  else if (e_state==E_JUMP)      exec_jmp <= 1'b0;
// ... unrelated original RTL lines 848-848 omitted ...
reg exec_dst_wr;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)                exec_dst_wr <= 1'b0;
  else if (e_state==E_DST_RD) exec_dst_wr <= 1'b1;
  else if (e_state==E_DST_WR) exec_dst_wr <= 1'b0;
// ... unrelated original RTL lines 854-854 omitted ...
reg exec_src_wr;
// ... unrelated original RTL lines 856-860 omitted ...
reg exec_dext_rdy;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)                exec_dext_rdy <= 1'b0;
  else if (e_state==E_DST_RD) exec_dext_rdy <= 1'b0;
  else if (inst_dext_rdy)     exec_dext_rdy <= 1'b1;
// ... unrelated original RTL lines 866-867 omitted ...
wire [3:0] e_first_state = ~cpu_halt_st  & inst_so_nxt[`IRQ] ? E_IRQ_0  :
                            cpu_halt_req | (i_state==I_IDLE) ? E_IDLE   :
                            cpuoff                           ? E_IDLE   :
                            src_acalc_pre                    ? E_SRC_AD :
                            src_rd_pre                       ? E_SRC_RD :
                            dst_acalc_pre                    ? E_DST_AD :
                            dst_rd_pre                       ? E_DST_RD : E_EXEC;
// ... unrelated original RTL lines 875-891 omitted ...
      E_SRC_AD : e_state_nxt =  inst_sext_rdy     ? E_SRC_RD : E_SRC_AD;
// ... unrelated original RTL lines 893-896 omitted ...
      E_DST_AD : e_state_nxt =  (inst_dext_rdy |
                                 exec_dext_rdy)   ? E_DST_RD : E_DST_AD;
// ... unrelated original RTL lines 899-914 omitted ...
always @(posedge mclk or posedge puc_rst)
  if (puc_rst) e_state  <= E_IRQ_1;
  else         e_state  <= e_state_nxt;
// ... unrelated original RTL lines 918-922 omitted ...
wire exec_done = exec_jmp        ? (e_state==E_JUMP)   :
                 exec_dst_wr     ? (e_state==E_DST_WR) :
                 exec_src_wr     ? (e_state==E_SRC_WR) : (e_state==E_EXEC);

// ----------------------------------------------------------------------------
// Original source: openMSP430.v
// Module: openMSP430
// ----------------------------------------------------------------------------
output               puc_rst;                // Main system reset
// ... unrelated original RTL lines 144-181 omitted ...
wire           [7:0] inst_as;
// ... unrelated original RTL lines 183-193 omitted ...
wire           [3:0] e_state;
wire                 exec_done;
// ... unrelated original RTL lines 196-322 omitted ...
omsp_frontend frontend_0 (
// ... unrelated original RTL lines 324-327 omitted ...
    .e_state           (e_state),            // Execution state
    .exec_done         (exec_done),          // Execution completed
// ... unrelated original RTL lines 330-330 omitted ...
    .inst_as           (inst_as),            // Decoded Inst: source addressing mode
// ... unrelated original RTL lines 332-369 omitted ...
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 371-374 omitted ...
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
// source: openMSP430_defines.v:694-694
`define IRQ    7
// source: openMSP430_defines.v:734-734
`define I_EXT1      3'h3
// source: openMSP430_defines.v:735-735
`define I_EXT2      3'h4
// source: openMSP430_defines.v:736-736
`define I_IDLE      3'h5
// source: openMSP430_defines.v:691-691
`define PUSH   4
// source: openMSP430_defines.v:693-693
`define RETI   6
// source: openMSP430_defines.v:725-725
`define SYMB     4
