// ============================================================================
// Cluster-local relation RTL: C029 -> openMSP430.frontend_0.pc
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 5 RTL-proximal candidates. Members: openMSP430.mem_backbone_0.fe_pmem_en, openMSP430.mem_backbone_0.fe_pmem_en_dly, openMSP430.mem_backbone_0.fe_pmem_restore, openMSP430.mem_backbone_0.fe_pmem_save, openMSP430.mem_backbone_0.pmem_dout_bckup_sel. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: omsp_execution_unit.v
// Module: omsp_execution_unit
// ----------------------------------------------------------------------------
output              pc_sw_wr;      // Program counter software write
// ... unrelated original RTL lines 105-170 omitted ...
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
// ... unrelated original RTL lines 25-130 omitted ...
output        [15:0] pc;               // Program counter
output        [15:0] pc_nxt;           // Next PC value (for CALL & IRQ)
// ... unrelated original RTL lines 133-144 omitted ...
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
// ... unrelated original RTL lines 174-181 omitted ...
   input  [2:0] binary;
// ... unrelated original RTL lines 183-208 omitted ...
parameter I_IRQ_FETCH = `I_IRQ_FETCH;
parameter I_IRQ_DONE  = `I_IRQ_DONE;
// ... unrelated original RTL lines 211-240 omitted ...
reg  [2:0] i_state;
// ... unrelated original RTL lines 242-284 omitted ...
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

// ----------------------------------------------------------------------------
// Original source: omsp_mem_backbone.v
// Module: omsp_mem_backbone
// ----------------------------------------------------------------------------
output        [15:0] fe_mdb_in;         // Frontend Memory data bus input
// ... unrelated original RTL lines 110-124 omitted ...
input                cpu_halt_st;       // Halt/Run status from CPU
// ... unrelated original RTL lines 126-135 omitted ...
input         [14:0] fe_mab;            // Frontend Memory address bus
input                fe_mb_en;          // Frontend Memory bus enable
input                mclk;              // Main system clock
// ... unrelated original RTL lines 139-144 omitted ...
input         [15:0] pmem_dout;         // Program Memory data output
input                puc_rst;           // Main system reset
// ... unrelated original RTL lines 147-254 omitted ...
parameter          PMEM_OFFSET   = (16'hFFFF-`PMEM_SIZE+1);
// ... unrelated original RTL lines 256-262 omitted ...
wire               fe_pmem_sel   = (fe_mab>=(PMEM_OFFSET>>1));
wire               fe_pmem_en    = fe_mb_en & fe_pmem_sel;
// ... unrelated original RTL lines 265-318 omitted ...
reg         fe_pmem_en_dly;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst) fe_pmem_en_dly <=  1'b0;
  else         fe_pmem_en_dly <=  fe_pmem_en;
// ... unrelated original RTL lines 323-323 omitted ...
wire fe_pmem_save    = (~fe_pmem_en &  fe_pmem_en_dly) & ~cpu_halt_st;
wire fe_pmem_restore = ( fe_pmem_en & ~fe_pmem_en_dly) |  cpu_halt_st;
// ... unrelated original RTL lines 326-336 omitted ...
reg  [15:0] pmem_dout_bckup;
// ... unrelated original RTL lines 338-346 omitted ...
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
// ... unrelated original RTL lines 170-219 omitted ...
wire          [15:0] fe_mdb_in;
wire                 fe_mb_en;
// ... unrelated original RTL lines 222-223 omitted ...
wire                 pc_sw_wr;
wire          [15:0] pc_sw;
wire          [15:0] pc;
wire          [15:0] pc_nxt;
// ... unrelated original RTL lines 228-254 omitted ...
wire                 cpu_halt_st;
// ... unrelated original RTL lines 256-322 omitted ...
omsp_frontend frontend_0 (
// ... unrelated original RTL lines 324-350 omitted ...
    .pc                (pc),                 // Program counter
    .pc_nxt            (pc_nxt),             // Next PC value (for CALL & IRQ)
// ... unrelated original RTL lines 353-364 omitted ...
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
// ... unrelated original RTL lines 394-422 omitted ...
);
// ... unrelated original RTL lines 424-429 omitted ...
omsp_mem_backbone mem_backbone_0 (
// ... unrelated original RTL lines 431-439 omitted ...
    .fe_mdb_in         (fe_mdb_in),          // Frontend Memory data bus input
// ... unrelated original RTL lines 441-454 omitted ...
    .cpu_halt_st       (cpu_halt_st),        // Halt/Run status from CPU
// ... unrelated original RTL lines 456-466 omitted ...
    .fe_mb_en          (fe_mb_en),           // Frontend Memory bus enable
// ... unrelated original RTL lines 468-474 omitted ...
    .pmem_dout         (pmem_dout),          // Program Memory data output
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 477-477 omitted ...
);

// ----------------------------------------------------------------------------
// Referenced original preprocessor definitions
// ----------------------------------------------------------------------------
// source: openMSP430_defines.v:692-692
`define CALL   5
// source: openMSP430_defines.v:750-750
`define E_DST_WR    4'hA
// source: openMSP430_defines.v:751-751
`define E_EXEC      4'hB
// source: openMSP430_defines.v:732-732
`define I_IRQ_DONE  3'h1
// source: openMSP430_defines.v:731-731
`define I_IRQ_FETCH 3'h0
// source: openMSP430_defines.v:561-561
  `define PMEM_SIZE         `PMEM_CUSTOM_SIZE
// source: openMSP430_defines.v:693-693
`define RETI   6
