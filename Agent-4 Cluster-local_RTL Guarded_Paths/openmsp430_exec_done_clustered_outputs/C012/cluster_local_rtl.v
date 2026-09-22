// ============================================================================
// Cluster-local relation RTL: C012 -> openMSP430.frontend_0.exec_done
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 5 RTL-proximal candidates. Members: openMSP430.inst_ad, openMSP430.inst_jmp, openMSP430.multiplier_0.product, openMSP430.multiplier_0.reg_wr, openMSP430.watchdog_0.reg_rd. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: omsp_alu.v
// Module: omsp_alu
// ----------------------------------------------------------------------------
input               dbg_halt_st;   // Halt/Run status from CPU
// ... unrelated original RTL lines 80-80 omitted ...
input        [11:0] inst_alu;      // ALU control signals
// ... unrelated original RTL lines 82-82 omitted ...
input         [7:0] inst_jmp;      // Decoded Inst: Conditional jump
input         [7:0] inst_so;       // Single-operand arithmetic
input        [15:0] op_dst;        // Destination operand
// ... unrelated original RTL lines 86-86 omitted ...
input         [3:0] status;        // R2 Status {V,N,Z,C}
// ... unrelated original RTL lines 88-157 omitted ...
wire        op_bit8_msk     = ~exec_cycle | ~inst_bw;
wire [16:0] op_src_in       = {1'b0, {op_src_inv[15:8] & {8{op_bit8_msk}}}, op_src_inv[7:0]};
wire [16:0] op_dst_in       = {1'b0, {op_dst[15:8]     & {8{op_bit8_msk}}}, op_dst[7:0]};
// ... unrelated original RTL lines 161-162 omitted ...
wire        jmp_not_taken  = (inst_jmp[`JL]  & ~(status[3]^status[2])) |
                             (inst_jmp[`JGE] &  (status[3]^status[2])) |
                             (inst_jmp[`JN]  &  ~status[2])            |
                             (inst_jmp[`JC]  &  ~status[0])            |
                             (inst_jmp[`JNC] &   status[0])            |
                             (inst_jmp[`JEQ] &  ~status[1])            |
                             (inst_jmp[`JNE] &   status[1]);
wire [16:0] op_src_in_jmp  = op_src_in & {17{~jmp_not_taken}};
// ... unrelated original RTL lines 171-172 omitted ...
wire [16:0] alu_add        = op_src_in_jmp + op_dst_in;
// ... unrelated original RTL lines 174-179 omitted ...
wire        alu_inc         = exec_cycle & ((inst_alu[`ALU_INC_C] & status[0]) |
                                             inst_alu[`ALU_INC]);
wire [16:0] alu_add_inc    = alu_add + {16'h0000, alu_inc};
// ... unrelated original RTL lines 183-190 omitted ...
wire [16:0] alu_dadd       = {alu_dadd3, alu_dadd2[3:0], alu_dadd1[3:0], alu_dadd0[3:0]};
// ... unrelated original RTL lines 192-213 omitted ...
wire [16:0] alu_short      = ({17{inst_alu[`ALU_AND]}}   & alu_and)   |
                             ({17{inst_alu[`ALU_OR]}}    & alu_or)    |
                             ({17{inst_alu[`ALU_XOR]}}   & alu_xor)   |
                             ({17{inst_alu[`ALU_SHIFT]}} & alu_shift) |
                             ({17{inst_so[`SWPB]}}       & alu_swpb)  |
                             ({17{inst_so[`SXT]}}        & alu_sxt)   |
                             ({17{alu_short_thro}}       & op_src_in);
// ... unrelated original RTL lines 221-223 omitted ...
wire [16:0] alu_out_nxt    = (inst_so[`IRQ] | dbg_halt_st |
                              inst_alu[`ALU_ADD]) ? alu_add_inc :
                              inst_alu[`ALU_DADD] ? alu_dadd    : alu_short;

// ----------------------------------------------------------------------------
// Original source: omsp_execution_unit.v
// Module: omsp_execution_unit
// ----------------------------------------------------------------------------
output              cpuoff;        // Turns off the CPU
// ... unrelated original RTL lines 96-109 omitted ...
input               dbg_halt_st;   // Halt/Run status from CPU
input        [15:0] dbg_mem_dout;  // Debug unit data output
input               dbg_reg_wr;    // Debug unit CPU register write
input         [3:0] e_state;       // Execution state
// ... unrelated original RTL lines 114-114 omitted ...
input         [7:0] inst_ad;       // Decoded Inst: destination addressing mode
input         [7:0] inst_as;       // Decoded Inst: source addressing mode
input        [11:0] inst_alu;      // ALU control signals
input               inst_bw;       // Decoded Inst: byte width
// ... unrelated original RTL lines 119-121 omitted ...
input         [7:0] inst_jmp;      // Decoded Inst: Conditional jump
// ... unrelated original RTL lines 123-123 omitted ...
input        [15:0] inst_sext;     // Decoded Inst: source extended instruction word
input         [7:0] inst_so;       // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 126-126 omitted ...
input         [2:0] inst_type;     // Decoded Instruction type
// ... unrelated original RTL lines 128-128 omitted ...
input        [15:0] mdb_in;        // Memory data bus input
// ... unrelated original RTL lines 130-139 omitted ...
wire         [15:0] alu_out;
// ... unrelated original RTL lines 141-143 omitted ...
wire         [15:0] op_dst;
// ... unrelated original RTL lines 145-145 omitted ...
wire         [15:0] reg_dest;
// ... unrelated original RTL lines 147-147 omitted ...
wire         [15:0] mdb_in_bw;
// ... unrelated original RTL lines 149-149 omitted ...
wire          [3:0] status;
// ... unrelated original RTL lines 151-156 omitted ...
wire reg_dest_wr  = ((e_state==`E_EXEC) & (
                     (inst_type[`INST_TO] & inst_ad[`DIR] & ~inst_alu[`EXEC_NO_WR])  |
                     (inst_type[`INST_SO] & inst_as[`DIR] & ~(inst_so[`PUSH] | inst_so[`CALL] | inst_so[`RETI])) |
                      inst_type[`INST_JMP])) | dbg_reg_wr;
// ... unrelated original RTL lines 161-166 omitted ...
wire reg_sr_wr    =  (e_state==`E_DST_RD) & inst_so[`RETI];
// ... unrelated original RTL lines 168-180 omitted ...
omsp_register_file register_file_0 (
// ... unrelated original RTL lines 182-183 omitted ...
    .cpuoff       (cpuoff),       // Turns off the CPU
// ... unrelated original RTL lines 185-197 omitted ...
    .inst_bw      (inst_bw),      // Decoded Inst: byte width
// ... unrelated original RTL lines 199-203 omitted ...
    .reg_dest_val (alu_out),      // Selected register destination value
    .reg_dest_wr  (reg_dest_wr),  // Write selected register destination
// ... unrelated original RTL lines 206-209 omitted ...
    .reg_sr_wr    (reg_sr_wr),    // Status Register update for RETI instruction
// ... unrelated original RTL lines 211-212 omitted ...
);
// ... unrelated original RTL lines 214-267 omitted ...
wire dst_inst_sext_sel  = ((e_state==`E_SRC_RD) & (inst_as[`IDX] | inst_as[`SYMB] |
                                                   inst_as[`ABS]))                |
                          ((e_state==`E_SRC_WR) & (inst_as[`IDX] | inst_as[`SYMB] |
                                                   inst_as[`ABS]));
// ... unrelated original RTL lines 272-272 omitted ...
wire dst_mdb_in_bw_sel  = ((e_state==`E_DST_WR) &   inst_so[`RETI]) |
                          ((e_state==`E_EXEC)   & ~(inst_ad[`DIR] | inst_type[`INST_JMP] |
                                                    inst_type[`INST_SO]) & ~inst_so[`RETI]);
// ... unrelated original RTL lines 276-276 omitted ...
wire dst_fffe_sel       =  (e_state==`E_IRQ_0)  |
                           (e_state==`E_IRQ_1)  |
                           (e_state==`E_IRQ_3)  |
                          ((e_state==`E_DST_RD) & (inst_so[`PUSH] | inst_so[`CALL]) & ~inst_so[`RETI]) |
                          ((e_state==`E_SRC_AD) & (inst_so[`PUSH] | inst_so[`CALL]) & inst_as[`IDX]) |
                          ((e_state==`E_SRC_RD) & (inst_so[`PUSH] | inst_so[`CALL]) & (inst_as[`INDIR] | inst_as[`INDIR_I]) & inst_src[1]);
// ... unrelated original RTL lines 283-283 omitted ...
wire dst_reg_dest_sel   = ((e_state==`E_DST_RD) & ~(inst_so[`PUSH] | inst_so[`CALL] | inst_ad[`ABS] | inst_so[`RETI])) |
                          ((e_state==`E_DST_WR) &  ~inst_ad[`ABS]) |
                          ((e_state==`E_EXEC)   &  (inst_ad[`DIR] | inst_type[`INST_JMP] |
                                                    inst_type[`INST_SO]) & ~inst_so[`RETI]);
// ... unrelated original RTL lines 288-289 omitted ...
assign op_dst = dbg_halt_st        ? dbg_mem_dout  :
                dst_inst_sext_sel  ? inst_sext     :
                dst_mdb_in_bw_sel  ? mdb_in_bw     :
                dst_reg_dest_sel   ? reg_dest      :
                dst_fffe_sel       ? 16'hfffe      : 16'h0000;
// ... unrelated original RTL lines 295-302 omitted ...
omsp_alu alu_0 (
// ... unrelated original RTL lines 304-313 omitted ...
    .inst_alu     (inst_alu),     // ALU control signals
// ... unrelated original RTL lines 315-315 omitted ...
    .inst_jmp     (inst_jmp),     // Decoded Inst: Conditional jump
// ... unrelated original RTL lines 317-320 omitted ...
);
// ... unrelated original RTL lines 322-378 omitted ...
reg        mab_lsb;
// ... unrelated original RTL lines 380-383 omitted ...
assign mdb_in_bw  = ~inst_bw ? mdb_in :
                     mab_lsb ? {2{mdb_in[15:8]}} : mdb_in;

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
output               decode_noirq;     // Frontend decode instruction
output         [3:0] e_state;          // Execution state
output               exec_done;        // Execution completed
output         [7:0] inst_ad;          // Decoded Inst: destination addressing mode
// ... unrelated original RTL lines 111-112 omitted ...
output               inst_bw;          // Decoded Inst: byte width
// ... unrelated original RTL lines 114-116 omitted ...
output         [7:0] inst_jmp;         // Decoded Inst: Conditional jump
// ... unrelated original RTL lines 118-121 omitted ...
output         [2:0] inst_type;        // Decoded Instruction type
// ... unrelated original RTL lines 123-135 omitted ...
input                cpu_en_s;         // Enable CPU code execution (synchronous)
input                cpu_halt_cmd;     // Halt CPU command
input                cpuoff;           // Turns off the CPU
// ... unrelated original RTL lines 139-144 omitted ...
input                mclk;             // Main system clock
// ... unrelated original RTL lines 146-150 omitted ...
input                puc_rst;          // Main system reset
// ... unrelated original RTL lines 152-163 omitted ...
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
// ... unrelated original RTL lines 188-213 omitted ...
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
// ... unrelated original RTL lines 243-245 omitted ...
wire       irq_detect;
wire [2:0] inst_type_nxt;
// ... unrelated original RTL lines 248-249 omitted ...
reg  [3:0] e_state_nxt;
// ... unrelated original RTL lines 251-252 omitted ...
wire   cpu_halt_req = cpu_halt_cmd | ~cpu_en_s;
// ... unrelated original RTL lines 254-283 omitted ...
wire   decode       =  decode_noirq | irq_detect;
// ... unrelated original RTL lines 285-288 omitted ...
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)  cpu_halt_st <= 1'b0;
  else          cpu_halt_st <= cpu_halt_req & (i_state_nxt==I_IDLE);
// ... unrelated original RTL lines 292-447 omitted ...
wire [15:0] ir  = mdb_in;
// ... unrelated original RTL lines 449-520 omitted ...
wire       mclk_decode;
// ... unrelated original RTL lines 522-564 omitted ...
wire  [7:0] inst_so_nxt = irq_detect ? 8'h80 : (one_hot8(ir[9:7]) & {8{inst_type_nxt[`INST_SO]}});
// ... unrelated original RTL lines 566-588 omitted ...
reg   [2:0] inst_jmp_bin;
// ... unrelated original RTL lines 590-597 omitted ...
wire [7:0] inst_jmp = one_hot8(inst_jmp_bin) & {8{inst_type[`INST_JMP]}};
// ... unrelated original RTL lines 599-765 omitted ...
reg  [7:0] inst_ad_nxt;
// ... unrelated original RTL lines 767-791 omitted ...
always @(posedge mclk_decode or posedge puc_rst)
  if (puc_rst)     inst_ad <= 8'h00;
`ifdef CLOCK_GATING
  else             inst_ad <= inst_ad_nxt;
// ... unrelated original RTL lines 796-806 omitted ...
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)     inst_bw     <= 1'b0;
  else if (decode) inst_bw     <= ir[6] & ~inst_type_nxt[`INST_JMP] & ~irq_detect & ~cpu_halt_req;
// ... unrelated original RTL lines 810-833 omitted ...
wire src_acalc_pre =  inst_as_nxt[`IDX]   | inst_as_nxt[`SYMB]    | inst_as_nxt[`ABS];
wire src_rd_pre    =  inst_as_nxt[`INDIR] | inst_as_nxt[`INDIR_I] | inst_as_nxt[`IMM]  | inst_so_nxt[`RETI];
wire dst_acalc_pre =  inst_ad_nxt[`IDX]   | inst_ad_nxt[`SYMB]    | inst_ad_nxt[`ABS];
wire dst_acalc     =  inst_ad[`IDX]       | inst_ad[`SYMB]        | inst_ad[`ABS];
wire dst_rd_pre    =  inst_ad_nxt[`IDX]   | inst_so_nxt[`PUSH]    | inst_so_nxt[`CALL] | inst_so_nxt[`RETI];
wire dst_rd        =  inst_ad[`IDX]       | inst_so[`PUSH]        | inst_so[`CALL]     | inst_so[`RETI];
// ... unrelated original RTL lines 840-840 omitted ...
wire inst_branch   =  (inst_ad_nxt[`DIR] & (ir[3:0]==4'h0)) | inst_type_nxt[`INST_JMP] | inst_so_nxt[`RETI];
// ... unrelated original RTL lines 842-842 omitted ...
reg exec_jmp;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)                   exec_jmp <= 1'b0;
  else if (inst_branch & decode) exec_jmp <= 1'b1;
  else if (e_state==E_JUMP)      exec_jmp <= 1'b0;
// ... unrelated original RTL lines 848-848 omitted ...
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
// ... unrelated original RTL lines 875-893 omitted ...
      E_SRC_RD : e_state_nxt =  dst_acalc         ? E_DST_AD :
                                 dst_rd           ? E_DST_RD : E_EXEC;
// ... unrelated original RTL lines 896-914 omitted ...
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
output        [15:0] eu_mdb_in;         // Execution Unit Memory data bus input
// ... unrelated original RTL lines 109-130 omitted ...
input         [15:0] dmem_dout;         // Data Memory data output
// ... unrelated original RTL lines 132-132 omitted ...
input                eu_mb_en;          // Execution Unit Memory bus enable
input          [1:0] eu_mb_wr;          // Execution Unit Memory bus write transfer
// ... unrelated original RTL lines 135-137 omitted ...
input                mclk;              // Main system clock
// ... unrelated original RTL lines 139-143 omitted ...
input         [15:0] per_dout;          // Peripheral data output
input         [15:0] pmem_dout;         // Program Memory data output
input                puc_rst;           // Main system reset
// ... unrelated original RTL lines 147-257 omitted ...
wire               eu_pmem_sel   = (eu_mab>=(PMEM_OFFSET>>1));
wire               eu_pmem_en    = eu_mb_en & ~|eu_mb_wr & eu_pmem_sel;
// ... unrelated original RTL lines 260-287 omitted ...
wire               eu_per_sel    =  (eu_mab<(`PER_SIZE>>1));
wire               eu_per_en     =  eu_mb_en & eu_per_sel;
// ... unrelated original RTL lines 290-306 omitted ...
reg   [15:0] per_dout_val;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)  per_dout_val    <=  16'h0000;
  else          per_dout_val    <=  per_dout;
// ... unrelated original RTL lines 311-360 omitted ...
reg [1:0] eu_mdb_in_sel;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)  eu_mdb_in_sel  <= 2'b00;
  else          eu_mdb_in_sel  <= {eu_pmem_en, eu_per_en};
// ... unrelated original RTL lines 365-366 omitted ...
assign          eu_mdb_in       = eu_mdb_in_sel[1] ? pmem_dout    :
                                  eu_mdb_in_sel[0] ? per_dout_val : dmem_dout;

// ----------------------------------------------------------------------------
// Original source: omsp_multiplier.v
// Module: omsp_multiplier
// ----------------------------------------------------------------------------
output       [15:0] per_dout;       // Peripheral data output
// ... unrelated original RTL lines 68-70 omitted ...
input               mclk;           // Main system clock
// ... unrelated original RTL lines 72-72 omitted ...
input        [15:0] per_din;        // Peripheral data input
// ... unrelated original RTL lines 74-74 omitted ...
input         [1:0] per_we;         // Peripheral write enable (high active)
input               puc_rst;        // Main system reset
// ... unrelated original RTL lines 77-90 omitted ...
parameter [DEC_WD-1:0] OP1_MPY     = 'h0,
                       OP1_MPYS    = 'h2,
                       OP1_MAC     = 'h4,
                       OP1_MACS    = 'h6,
                       OP2         = 'h8,
                       RESLO       = 'hA,
                       RESHI       = 'hC,
                       SUMEXT      = 'hE;
// ... unrelated original RTL lines 99-100 omitted ...
parameter              DEC_SZ      =  (1 << DEC_WD);
// ... unrelated original RTL lines 102-104 omitted ...
parameter [DEC_SZ-1:0] OP1_MPY_D   = (BASE_REG << OP1_MPY),
                       OP1_MPYS_D  = (BASE_REG << OP1_MPYS),
                       OP1_MAC_D   = (BASE_REG << OP1_MAC),
                       OP1_MACS_D  = (BASE_REG << OP1_MACS),
                       OP2_D       = (BASE_REG << OP2),
                       RESLO_D     = (BASE_REG << RESLO),
                       RESHI_D     = (BASE_REG << RESHI),
                       SUMEXT_D    = (BASE_REG << SUMEXT);
// ... unrelated original RTL lines 113-115 omitted ...
wire  result_wr;
wire  result_clr;
wire  early_read;
// ... unrelated original RTL lines 119-125 omitted ...
wire              reg_sel     =  per_en & (per_addr[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);
// ... unrelated original RTL lines 127-128 omitted ...
wire [DEC_WD-1:0] reg_addr    =  {per_addr[DEC_WD-2:0], 1'b0};
// ... unrelated original RTL lines 130-131 omitted ...
wire [DEC_SZ-1:0] reg_dec     =  (OP1_MPY_D   &  {DEC_SZ{(reg_addr == OP1_MPY  )}})  |
                                 (OP1_MPYS_D  &  {DEC_SZ{(reg_addr == OP1_MPYS )}})  |
                                 (OP1_MAC_D   &  {DEC_SZ{(reg_addr == OP1_MAC  )}})  |
                                 (OP1_MACS_D  &  {DEC_SZ{(reg_addr == OP1_MACS )}})  |
                                 (OP2_D       &  {DEC_SZ{(reg_addr == OP2      )}})  |
                                 (RESLO_D     &  {DEC_SZ{(reg_addr == RESLO    )}})  |
                                 (RESHI_D     &  {DEC_SZ{(reg_addr == RESHI    )}})  |
                                 (SUMEXT_D    &  {DEC_SZ{(reg_addr == SUMEXT   )}});
// ... unrelated original RTL lines 140-141 omitted ...
wire              reg_write   =  |per_we & reg_sel;
// ... unrelated original RTL lines 143-145 omitted ...
wire [DEC_SZ-1:0] reg_wr      = reg_dec & {DEC_SZ{reg_write}};
wire [DEC_SZ-1:0] reg_rd      = reg_dec & {DEC_SZ{reg_read}};
// ... unrelated original RTL lines 148-149 omitted ...
wire       [15:0] per_din_msk =  per_din & {{8{per_we[1]}}, 8'hff};
// ... unrelated original RTL lines 151-157 omitted ...
reg  [15:0] op1;
// ... unrelated original RTL lines 159-165 omitted ...
wire        mclk_op1;
// ... unrelated original RTL lines 167-188 omitted ...
wire        op2_wr = reg_wr[OP2];
// ... unrelated original RTL lines 190-240 omitted ...
reg  [15:0] reshi;
// ... unrelated original RTL lines 242-242 omitted ...
wire [15:0] reshi_nxt;
wire        reshi_wr = reg_wr[RESHI];
// ... unrelated original RTL lines 245-247 omitted ...
wire        mclk_reshi;
// ... unrelated original RTL lines 249-254 omitted ...
always @ (posedge mclk_reshi or posedge puc_rst)
  if (puc_rst)         reshi <=  16'h0000;
  else if (reshi_wr)   reshi <=  per_din_msk;
  else if (result_clr) reshi <=  16'h0000;
`ifdef CLOCK_GATING
  else                 reshi <=  reshi_nxt;
// ... unrelated original RTL lines 261-264 omitted ...
wire [15:0] reshi_rd = early_read ? reshi_nxt  : reshi;
// ... unrelated original RTL lines 266-269 omitted ...
reg  [1:0] sumext_s;
// ... unrelated original RTL lines 271-271 omitted ...
wire [1:0] sumext_s_nxt;
// ... unrelated original RTL lines 273-273 omitted ...
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)         sumext_s <=  2'b00;
  else if (op2_wr)     sumext_s <=  2'b00;
  else if (result_wr)  sumext_s <=  sumext_s_nxt;
// ... unrelated original RTL lines 278-278 omitted ...
wire [15:0] sumext_nxt = {{14{sumext_s_nxt[1]}}, sumext_s_nxt};
wire [15:0] sumext     = {{14{sumext_s[1]}},     sumext_s};
wire [15:0] sumext_rd  = early_read ? sumext_nxt : sumext;
// ... unrelated original RTL lines 282-288 omitted ...
wire [15:0] op1_mux    = op1_rd     & {16{reg_rd[OP1_MPY]  |
                                          reg_rd[OP1_MPYS] |
                                          reg_rd[OP1_MAC]  |
                                          reg_rd[OP1_MACS]}};
wire [15:0] op2_mux    = op2_rd     & {16{reg_rd[OP2]}};
wire [15:0] reslo_mux  = reslo_rd   & {16{reg_rd[RESLO]}};
wire [15:0] reshi_mux  = reshi_rd   & {16{reg_rd[RESHI]}};
wire [15:0] sumext_mux = sumext_rd  & {16{reg_rd[SUMEXT]}};
// ... unrelated original RTL lines 297-297 omitted ...
wire [15:0] per_dout   = op1_mux    |
                         op2_mux    |
                         reslo_mux  |
                         reshi_mux  |
                         sumext_mux;
// ... unrelated original RTL lines 303-312 omitted ...
reg sign_sel;
always @ (posedge mclk_op1 or posedge puc_rst)
  if (puc_rst)     sign_sel <=  1'b0;
`ifdef CLOCK_GATING
  else             sign_sel <=  reg_wr[OP1_MPYS] | reg_wr[OP1_MACS];
// ... unrelated original RTL lines 318-323 omitted ...
reg acc_sel;
always @ (posedge mclk_op1 or posedge puc_rst)
  if (puc_rst)     acc_sel  <=  1'b0;
`ifdef CLOCK_GATING
  else             acc_sel  <=  reg_wr[OP1_MAC]  | reg_wr[OP1_MACS];
// ... unrelated original RTL lines 329-334 omitted ...
assign      result_clr = op2_wr & ~acc_sel;
// ... unrelated original RTL lines 336-337 omitted ...
wire [31:0] result     = {reshi, reslo};
// ... unrelated original RTL lines 339-381 omitted ...
reg [1:0] cycle;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) cycle <=  2'b00;
  else         cycle <=  {cycle[0], op2_wr};
// ... unrelated original RTL lines 386-390 omitted ...
wire signed [16:0] op1_xp    = {sign_sel & op1[15], op1};
wire signed  [8:0] op2_hi_xp = {sign_sel & op2[15], op2[15:8]};
wire signed  [8:0] op2_lo_xp = {              1'b0, op2[7:0]};
wire signed  [8:0] op2_xp    = cycle[0] ? op2_hi_xp : op2_lo_xp;
// ... unrelated original RTL lines 395-397 omitted ...
wire signed [25:0] product    = op1_xp * op2_xp;
// ... unrelated original RTL lines 399-399 omitted ...
wire        [31:0] product_xp = cycle[0] ? {product[23:0], 8'h00} :
                                           {{8{sign_sel & product[23]}}, product[23:0]};
// ... unrelated original RTL lines 402-403 omitted ...
wire [32:0] result_nxt  = {1'b0, result} + {1'b0, product_xp[31:0]};
// ... unrelated original RTL lines 405-409 omitted ...
assign sumext_s_nxt =  sign_sel ? {2{result_nxt[31]}} :
                                  {1'b0, result_nxt[32] | sumext_s[0]};

// ----------------------------------------------------------------------------
// Original source: omsp_register_file.v
// Module: omsp_register_file
// ----------------------------------------------------------------------------
output              cpuoff;       // Turns off the CPU
// ... unrelated original RTL lines 87-100 omitted ...
input               inst_bw;      // Decoded Inst: byte width
input        [15:0] inst_dest;    // Register destination selection
// ... unrelated original RTL lines 103-106 omitted ...
input        [15:0] reg_dest_val; // Selected register destination value
input               reg_dest_wr;  // Write selected register destination
// ... unrelated original RTL lines 109-111 omitted ...
input               reg_sr_wr;    // Status register update for RETI instruction
// ... unrelated original RTL lines 113-125 omitted ...
wire [15:0] reg_dest_val_in = inst_bw ? {8'h00,reg_dest_val[7:0]} : reg_dest_val;
// ... unrelated original RTL lines 127-178 omitted ...
reg  [15:0] r2;
wire        r2_wr  = (inst_dest[2] & reg_dest_wr) | reg_sr_wr;
// ... unrelated original RTL lines 181-188 omitted ...
wire  [7:3] r2_nxt = r2_wr          ? reg_dest_val_in[7:3] : r2[7:3];
// ... unrelated original RTL lines 190-218 omitted ...
   wire [15:0] cpuoff_mask = 16'h0010;
// ... unrelated original RTL lines 220-253 omitted ...
assign cpuoff =  r2[4] | (r2_nxt[4] & r2_wr & cpuoff_mask[4]);

// ----------------------------------------------------------------------------
// Original source: omsp_watchdog.v
// Module: omsp_watchdog
// ----------------------------------------------------------------------------
output       [15:0] per_dout;       // Peripheral data output
// ... unrelated original RTL lines 84-98 omitted ...
input         [1:0] per_we;         // Peripheral write enable (high active)
// ... unrelated original RTL lines 100-122 omitted ...
parameter [DEC_WD-1:0] WDTCTL      = 'h0;
// ... unrelated original RTL lines 124-125 omitted ...
parameter              DEC_SZ      =  (1 << DEC_WD);
// ... unrelated original RTL lines 127-129 omitted ...
parameter [DEC_SZ-1:0] WDTCTL_D    = (BASE_REG << WDTCTL);
// ... unrelated original RTL lines 131-137 omitted ...
wire              reg_sel   =  per_en & (per_addr[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);
// ... unrelated original RTL lines 139-140 omitted ...
wire [DEC_WD-1:0] reg_addr  =  {per_addr[DEC_WD-2:0], 1'b0};
// ... unrelated original RTL lines 142-143 omitted ...
wire [DEC_SZ-1:0] reg_dec   =  (WDTCTL_D & {DEC_SZ{(reg_addr==WDTCTL)}});
// ... unrelated original RTL lines 145-147 omitted ...
wire              reg_read  = ~|per_we & reg_sel;
// ... unrelated original RTL lines 149-151 omitted ...
wire [DEC_SZ-1:0] reg_rd    = reg_dec & {DEC_SZ{reg_read}};
// ... unrelated original RTL lines 153-162 omitted ...
reg  [7:0] wdtctl;
// ... unrelated original RTL lines 164-224 omitted ...
parameter [7:0] WDTCTL_RD_MASK  = WDTNMI_RD_MASK | WDTSSEL_RD_MASK;
// ... unrelated original RTL lines 226-227 omitted ...
wire [15:0] wdtctl_rd  = {8'h69, wdtctl | WDTCTL_RD_MASK} & {16{reg_rd[WDTCTL]}};

// ----------------------------------------------------------------------------
// Original source: openMSP430.v
// Module: openMSP430
// ----------------------------------------------------------------------------
output               puc_rst;                // Main system reset
// ... unrelated original RTL lines 144-157 omitted ...
input         [15:0] dmem_dout;              // Data Memory data output
// ... unrelated original RTL lines 159-167 omitted ...
input         [15:0] per_dout;               // Peripheral data output
input         [15:0] pmem_dout;              // Program Memory data output
// ... unrelated original RTL lines 170-180 omitted ...
wire           [7:0] inst_ad;
// ... unrelated original RTL lines 182-182 omitted ...
wire          [11:0] inst_alu;
wire                 inst_bw;
// ... unrelated original RTL lines 185-188 omitted ...
wire          [15:0] inst_sext;
// ... unrelated original RTL lines 190-191 omitted ...
wire           [2:0] inst_type;
wire           [7:0] inst_jmp;
wire           [3:0] e_state;
wire                 exec_done;
// ... unrelated original RTL lines 196-197 omitted ...
wire                 cpuoff;
// ... unrelated original RTL lines 199-214 omitted ...
wire          [15:0] eu_mdb_in;
// ... unrelated original RTL lines 216-249 omitted ...
wire          [15:0] dbg_mem_dout;
// ... unrelated original RTL lines 251-254 omitted ...
wire                 cpu_halt_st;
// ... unrelated original RTL lines 256-258 omitted ...
wire          [15:0] per_dout_or;
wire          [15:0] per_dout_sfr;
wire          [15:0] per_dout_wdog;
wire          [15:0] per_dout_mpy;
wire          [15:0] per_dout_clk;
// ... unrelated original RTL lines 264-322 omitted ...
omsp_frontend frontend_0 (
// ... unrelated original RTL lines 324-325 omitted ...
    .cpu_halt_st       (cpu_halt_st),        // Halt/Run status from CPU
// ... unrelated original RTL lines 327-327 omitted ...
    .e_state           (e_state),            // Execution state
    .exec_done         (exec_done),          // Execution completed
    .inst_ad           (inst_ad),            // Decoded Inst: destination addressing mode
// ... unrelated original RTL lines 331-332 omitted ...
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
// ... unrelated original RTL lines 334-336 omitted ...
    .inst_jmp          (inst_jmp),           // Decoded Inst: Conditional jump
// ... unrelated original RTL lines 338-341 omitted ...
    .inst_type         (inst_type),          // Decoded Instruction type
// ... unrelated original RTL lines 343-356 omitted ...
    .cpuoff            (cpuoff),             // Turns off the CPU
// ... unrelated original RTL lines 358-369 omitted ...
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 371-374 omitted ...
);
// ... unrelated original RTL lines 376-381 omitted ...
omsp_execution_unit execution_unit_0 (
// ... unrelated original RTL lines 383-384 omitted ...
    .cpuoff            (cpuoff),             // Turns off the CPU
// ... unrelated original RTL lines 386-397 omitted ...
    .dbg_halt_st       (cpu_halt_st),        // Halt/Run status from CPU
    .dbg_mem_dout      (dbg_mem_dout),       // Debug unit data output
// ... unrelated original RTL lines 400-403 omitted ...
    .inst_ad           (inst_ad),            // Decoded Inst: destination addressing mode
// ... unrelated original RTL lines 405-405 omitted ...
    .inst_alu          (inst_alu),           // ALU control signals
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
// ... unrelated original RTL lines 408-410 omitted ...
    .inst_jmp          (inst_jmp),           // Decoded Inst: Conditional jump
// ... unrelated original RTL lines 412-412 omitted ...
    .inst_sext         (inst_sext),          // Decoded Inst: source extended instruction word
// ... unrelated original RTL lines 414-417 omitted ...
    .mdb_in            (eu_mdb_in),          // Memory data bus input
// ... unrelated original RTL lines 419-422 omitted ...
);
// ... unrelated original RTL lines 424-429 omitted ...
omsp_mem_backbone mem_backbone_0 (
// ... unrelated original RTL lines 431-438 omitted ...
    .eu_mdb_in         (eu_mdb_in),          // Execution Unit Memory data bus input
// ... unrelated original RTL lines 440-460 omitted ...
    .dmem_dout         (dmem_dout),          // Data Memory data output
// ... unrelated original RTL lines 462-473 omitted ...
    .per_dout          (per_dout_or),        // Peripheral data output
    .pmem_dout         (pmem_dout),          // Program Memory data output
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 477-477 omitted ...
);
// ... unrelated original RTL lines 479-564 omitted ...
omsp_multiplier multiplier_0 (
// ... unrelated original RTL lines 566-567 omitted ...
    .per_dout          (per_dout_mpy),       // Peripheral data output
// ... unrelated original RTL lines 569-575 omitted ...
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 577-577 omitted ...
);
// ... unrelated original RTL lines 579-586 omitted ...
assign  per_dout_or  =  per_dout      |
                        per_dout_clk  |
                        per_dout_sfr  |
                        per_dout_wdog |
                        per_dout_mpy;

// ----------------------------------------------------------------------------
// Referenced original preprocessor definitions
// ----------------------------------------------------------------------------
// source: openMSP430_defines.v:727-727
`define ABS      6
// source: openMSP430_defines.v:759-759
`define ALU_ADD       3
// source: openMSP430_defines.v:760-760
`define ALU_AND       4
// source: openMSP430_defines.v:763-763
`define ALU_DADD      7
// source: openMSP430_defines.v:757-757
`define ALU_INC       1
// source: openMSP430_defines.v:758-758
`define ALU_INC_C     2
// source: openMSP430_defines.v:761-761
`define ALU_OR        5
// source: openMSP430_defines.v:766-766
`define ALU_SHIFT    10
// source: openMSP430_defines.v:762-762
`define ALU_XOR       6
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
// source: openMSP430_defines.v:743-743
`define E_IRQ_3     4'h3
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
// source: openMSP430_defines.v:684-684
`define INST_TO  2
// source: openMSP430_defines.v:694-694
`define IRQ    7
// source: openMSP430_defines.v:736-736
`define I_IDLE      3'h5
// source: openMSP430_defines.v:700-700
`define JC     3
// source: openMSP430_defines.v:698-698
`define JEQ    1
// source: openMSP430_defines.v:702-702
`define JGE    5
// source: openMSP430_defines.v:703-703
`define JL     6
// source: openMSP430_defines.v:701-701
`define JN     4
// source: openMSP430_defines.v:699-699
`define JNC    2
// source: openMSP430_defines.v:697-697
`define JNE    0
// source: openMSP430_defines.v:653-653
  `define PER_SIZE          `PER_CUSTOM_SIZE
// source: openMSP430_defines.v:691-691
`define PUSH   4
// source: openMSP430_defines.v:693-693
`define RETI   6
// source: openMSP430_defines.v:688-688
`define SWPB   1
// source: openMSP430_defines.v:690-690
`define SXT    3
// source: openMSP430_defines.v:725-725
`define SYMB     4
