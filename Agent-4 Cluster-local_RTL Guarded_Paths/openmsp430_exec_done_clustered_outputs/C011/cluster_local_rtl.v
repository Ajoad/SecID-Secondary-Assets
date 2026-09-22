// ============================================================================
// Cluster-local relation RTL: C011 -> openMSP430.frontend_0.exec_done
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 5 RTL-proximal candidates. Members: openMSP430.frontend_0.inst_to_1hot, openMSP430.frontend_0.irq_acc_all, openMSP430.inst_so, openMSP430.sfr_0.reg_lo_wr, openMSP430.watchdog_0.reg_wr. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: omsp_alu.v
// Module: omsp_alu
// ----------------------------------------------------------------------------
input               dbg_halt_st;   // Halt/Run status from CPU
input               exec_cycle;    // Instruction execution cycle
input        [11:0] inst_alu;      // ALU control signals
input               inst_bw;       // Decoded Inst: byte width
// ... unrelated original RTL lines 83-83 omitted ...
input         [7:0] inst_so;       // Single-operand arithmetic
input        [15:0] op_dst;        // Destination operand
input        [15:0] op_src;        // Source operand
input         [3:0] status;        // R2 Status {V,N,Z,C}
// ... unrelated original RTL lines 88-152 omitted ...
wire        op_src_inv_cmd = exec_cycle & (inst_alu[`ALU_SRC_INV]);
wire [15:0] op_src_inv     = {16{op_src_inv_cmd}} ^ op_src;
// ... unrelated original RTL lines 155-157 omitted ...
wire        op_bit8_msk     = ~exec_cycle | ~inst_bw;
wire [16:0] op_src_in       = {1'b0, {op_src_inv[15:8] & {8{op_bit8_msk}}}, op_src_inv[7:0]};
wire [16:0] op_dst_in       = {1'b0, {op_dst[15:8]     & {8{op_bit8_msk}}}, op_dst[7:0]};
// ... unrelated original RTL lines 161-169 omitted ...
wire [16:0] op_src_in_jmp  = op_src_in & {17{~jmp_not_taken}};
// ... unrelated original RTL lines 171-172 omitted ...
wire [16:0] alu_add        = op_src_in_jmp + op_dst_in;
wire [16:0] alu_and        = op_src_in     & op_dst_in;
wire [16:0] alu_or         = op_src_in     | op_dst_in;
wire [16:0] alu_xor        = op_src_in     ^ op_dst_in;
// ... unrelated original RTL lines 177-179 omitted ...
wire        alu_inc         = exec_cycle & ((inst_alu[`ALU_INC_C] & status[0]) |
                                             inst_alu[`ALU_INC]);
wire [16:0] alu_add_inc    = alu_add + {16'h0000, alu_inc};
// ... unrelated original RTL lines 183-186 omitted ...
wire  [4:0] alu_dadd0      = bcd_add(op_src_in[3:0],   op_dst_in[3:0],  status[0]);
wire  [4:0] alu_dadd1      = bcd_add(op_src_in[7:4],   op_dst_in[7:4],  alu_dadd0[4]);
wire  [4:0] alu_dadd2      = bcd_add(op_src_in[11:8],  op_dst_in[11:8], alu_dadd1[4]);
wire  [4:0] alu_dadd3      = bcd_add(op_src_in[15:12], op_dst_in[15:12],alu_dadd2[4]);
wire [16:0] alu_dadd       = {alu_dadd3, alu_dadd2[3:0], alu_dadd1[3:0], alu_dadd0[3:0]};
// ... unrelated original RTL lines 192-194 omitted ...
wire        alu_shift_msb  = inst_so[`RRC] ? status[0]     :
                             inst_bw       ? op_src[7]     : op_src[15];
wire        alu_shift_7    = inst_bw       ? alu_shift_msb : op_src[8];
wire [16:0] alu_shift      = {1'b0, alu_shift_msb, op_src[15:9], alu_shift_7, op_src[7:1]};
// ... unrelated original RTL lines 199-201 omitted ...
wire [16:0] alu_swpb       = {1'b0, op_src[7:0],op_src[15:8]};
wire [16:0] alu_sxt        = {1'b0, {8{op_src[7]}},op_src[7:0]};
// ... unrelated original RTL lines 204-206 omitted ...
wire        alu_short_thro = ~(inst_alu[`ALU_AND]   |
                               inst_alu[`ALU_OR]    |
                               inst_alu[`ALU_XOR]   |
                               inst_alu[`ALU_SHIFT] |
                               inst_so[`SWPB]       |
                               inst_so[`SXT]);
// ... unrelated original RTL lines 213-213 omitted ...
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
// ... unrelated original RTL lines 227-238 omitted ...
wire    V           = inst_bw ? ((~op_src_in[7]  & ~op_dst_in[7]  &  alu_out[7])  |
                                 ( op_src_in[7]  &  op_dst_in[7]  & ~alu_out[7])) :
                                ((~op_src_in[15] & ~op_dst_in[15] &  alu_out[15]) |
                                 ( op_src_in[15] &  op_dst_in[15] & ~alu_out[15]));
// ... unrelated original RTL lines 243-243 omitted ...
wire    N           = inst_bw ?  alu_out[7]       : alu_out[15];
wire    Z           = inst_bw ? (alu_out[7:0]==0) : (alu_out==0);
wire    C           = inst_bw ?  alu_out[8]       : alu_out_nxt[16];

// ----------------------------------------------------------------------------
// Original source: omsp_execution_unit.v
// Module: omsp_execution_unit
// ----------------------------------------------------------------------------
output              cpuoff;        // Turns off the CPU
// ... unrelated original RTL lines 96-98 omitted ...
output              mb_en;         // Memory bus enable
// ... unrelated original RTL lines 100-103 omitted ...
output              pc_sw_wr;      // Program counter software write
// ... unrelated original RTL lines 105-109 omitted ...
input               dbg_halt_st;   // Halt/Run status from CPU
input        [15:0] dbg_mem_dout;  // Debug unit data output
input               dbg_reg_wr;    // Debug unit CPU register write
input         [3:0] e_state;       // Execution state
// ... unrelated original RTL lines 114-114 omitted ...
input         [7:0] inst_ad;       // Decoded Inst: destination addressing mode
input         [7:0] inst_as;       // Decoded Inst: source addressing mode
input        [11:0] inst_alu;      // ALU control signals
input               inst_bw;       // Decoded Inst: byte width
// ... unrelated original RTL lines 119-122 omitted ...
input               inst_mov;      // Decoded Inst: mov instruction
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
// ... unrelated original RTL lines 168-170 omitted ...
wire reg_pc_call  = ((e_state==`E_EXEC)   & inst_so[`CALL]) |
                    ((e_state==`E_DST_WR) & inst_so[`RETI]);
// ... unrelated original RTL lines 173-180 omitted ...
omsp_register_file register_file_0 (
// ... unrelated original RTL lines 182-183 omitted ...
    .cpuoff       (cpuoff),       // Turns off the CPU
// ... unrelated original RTL lines 185-187 omitted ...
    .pc_sw_wr     (pc_sw_wr),     // Program counter software write
// ... unrelated original RTL lines 189-197 omitted ...
    .inst_bw      (inst_bw),      // Decoded Inst: byte width
// ... unrelated original RTL lines 199-203 omitted ...
    .reg_dest_val (alu_out),      // Selected register destination value
    .reg_dest_wr  (reg_dest_wr),  // Write selected register destination
    .reg_pc_call  (reg_pc_call),  // Trigger PC update for a CALL instruction
// ... unrelated original RTL lines 207-209 omitted ...
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
// ... unrelated original RTL lines 315-316 omitted ...
    .inst_so      (inst_so),      // Single-operand arithmetic
// ... unrelated original RTL lines 318-319 omitted ...
    .status       (status)        // R2 Status {V,N,Z,C}
);
// ... unrelated original RTL lines 322-328 omitted ...
wire        mb_rd_det = ((e_state==`E_SRC_RD) & ~inst_as[`IMM])       |
                        ((e_state==`E_EXEC)   &  inst_so[`RETI])      |
                        ((e_state==`E_DST_RD) & ~inst_type[`INST_SO]
                                              & ~inst_mov);
// ... unrelated original RTL lines 333-333 omitted ...
wire        mb_wr_det = ((e_state==`E_IRQ_1)  & ~inst_irq_rst)        |
                        ((e_state==`E_IRQ_3)  & ~inst_irq_rst)        |
                        ((e_state==`E_DST_WR) & ~inst_so[`RETI])      |
                         (e_state==`E_SRC_WR);
// ... unrelated original RTL lines 338-342 omitted ...
assign      mb_en     = mb_rd_det | (mb_wr_det & ~inst_alu[`EXEC_NO_WR]);
// ... unrelated original RTL lines 344-378 omitted ...
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
// ... unrelated original RTL lines 111-111 omitted ...
output        [11:0] inst_alu;         // ALU control signals
output               inst_bw;          // Decoded Inst: byte width
// ... unrelated original RTL lines 114-117 omitted ...
output               inst_mov;         // Decoded Inst: mov instruction
// ... unrelated original RTL lines 119-119 omitted ...
output         [7:0] inst_so;          // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 121-131 omitted ...
output        [15:0] pc_nxt;           // Next PC value (for CALL & IRQ)
// ... unrelated original RTL lines 133-135 omitted ...
input                cpu_en_s;         // Enable CPU code execution (synchronous)
input                cpu_halt_cmd;     // Halt CPU command
input                cpuoff;           // Turns off the CPU
// ... unrelated original RTL lines 139-142 omitted ...
input                gie;              // General interrupt enable
input  [`IRQ_NR-3:0] irq;              // Maskable interrupts
input                mclk;             // Main system clock
input         [15:0] mdb_in;           // Frontend Memory data bus input
input                nmi_pnd;          // Non-maskable interrupt pending
// ... unrelated original RTL lines 148-148 omitted ...
input         [15:0] pc_sw;            // Program counter software value
input                pc_sw_wr;         // Program counter software write
input                puc_rst;          // Main system reset
// ... unrelated original RTL lines 152-152 omitted ...
input                wdt_irq;          // Watchdog-timer interrupt
// ... unrelated original RTL lines 154-162 omitted ...
function [63:0] one_hot64;
   input  [5:0] binary;
   begin
      one_hot64         = 64'h0000_0000_0000_0000;
      one_hot64[binary] =  1'b1;
   end
endfunction
// ... unrelated original RTL lines 170-171 omitted ...
function [15:0] one_hot16;
   input  [3:0] binary;
   begin
      one_hot16         = 16'h0000;
      one_hot16[binary] =  1'b1;
   end
endfunction
// ... unrelated original RTL lines 179-180 omitted ...
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
// ... unrelated original RTL lines 211-213 omitted ...
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
// ... unrelated original RTL lines 292-308 omitted ...
assign  irq_detect = (nmi_pnd | ((|irq | wdt_irq) & gie)) & ~cpu_halt_req & ~cpu_halt_st & (exec_done | (i_state==I_IDLE));
// ... unrelated original RTL lines 310-334 omitted ...
reg  [5:0] irq_num;
// ... unrelated original RTL lines 336-345 omitted ...
wire [15:0] irq_addr    = {9'h1ff, irq_num, 1'b0};
// ... unrelated original RTL lines 347-348 omitted ...
wire        [63:0] irq_acc_all = one_hot64(irq_num) & {64{(i_state==I_IRQ_FETCH)}};
// ... unrelated original RTL lines 350-410 omitted ...
wire [15:0] pc_incr = pc + {14'h0000, fetch, 1'b0};
wire [15:0] pc_nxt  = pc_sw_wr               ? pc_sw    :
                      (i_state==I_IRQ_FETCH) ? irq_addr :
                      (i_state==I_IRQ_DONE)  ? mdb_in   :  pc_incr;
// ... unrelated original RTL lines 415-447 omitted ...
wire [15:0] ir  = mdb_in;
// ... unrelated original RTL lines 449-520 omitted ...
wire       mclk_decode;
// ... unrelated original RTL lines 522-564 omitted ...
wire  [7:0] inst_so_nxt = irq_detect ? 8'h80 : (one_hot8(ir[9:7]) & {8{inst_type_nxt[`INST_SO]}});
// ... unrelated original RTL lines 566-566 omitted ...
always @(posedge mclk_decode or posedge puc_rst)
  if (puc_rst)     inst_so <= 8'h00;
`ifdef CLOCK_GATING
  else             inst_so <= inst_so_nxt;
// ... unrelated original RTL lines 571-618 omitted ...
wire [15:0] inst_to_1hot = one_hot16(ir[15:12]) & {16{inst_type_nxt[`INST_TO]}};
wire [11:0] inst_to_nxt  = inst_to_1hot[15:4];
// ... unrelated original RTL lines 621-622 omitted ...
always @(posedge mclk_decode or posedge puc_rst)
  if (puc_rst)     inst_mov <= 1'b0;
`ifdef CLOCK_GATING
  else             inst_mov <= inst_to_nxt[`MOV];
// ... unrelated original RTL lines 627-765 omitted ...
reg  [7:0] inst_ad_nxt;
// ... unrelated original RTL lines 767-806 omitted ...
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
// ... unrelated original RTL lines 926-950 omitted ...
wire        alu_src_inv   = inst_to_nxt[`SUB]  | inst_to_nxt[`SUBC] |
                            inst_to_nxt[`CMP]  | inst_to_nxt[`BIC] ;
// ... unrelated original RTL lines 953-953 omitted ...
wire        alu_inc       = inst_to_nxt[`SUB]  | inst_to_nxt[`CMP];
// ... unrelated original RTL lines 955-955 omitted ...
wire        alu_inc_c     = inst_to_nxt[`ADDC] | inst_to_nxt[`DADD] |
                            inst_to_nxt[`SUBC];
// ... unrelated original RTL lines 958-958 omitted ...
wire        alu_add       = inst_to_nxt[`ADD]  | inst_to_nxt[`ADDC]       |
                            inst_to_nxt[`SUB]  | inst_to_nxt[`SUBC]       |
                            inst_to_nxt[`CMP]  | inst_type_nxt[`INST_JMP] |
                            inst_so_nxt[`RETI];
// ... unrelated original RTL lines 963-964 omitted ...
wire        alu_and       = inst_to_nxt[`AND]  | inst_to_nxt[`BIC]  |
                            inst_to_nxt[`BIT];
// ... unrelated original RTL lines 967-967 omitted ...
wire        alu_or        = inst_to_nxt[`BIS];
// ... unrelated original RTL lines 969-969 omitted ...
wire        alu_xor       = inst_to_nxt[`XOR];
// ... unrelated original RTL lines 971-971 omitted ...
wire        alu_dadd      = inst_to_nxt[`DADD];
// ... unrelated original RTL lines 973-973 omitted ...
wire        alu_stat_7    = inst_to_nxt[`BIT]  | inst_to_nxt[`AND]  |
                            inst_so_nxt[`SXT];
// ... unrelated original RTL lines 976-976 omitted ...
wire        alu_stat_f    = inst_to_nxt[`ADD]  | inst_to_nxt[`ADDC] |
                            inst_to_nxt[`SUB]  | inst_to_nxt[`SUBC] |
                            inst_to_nxt[`CMP]  | inst_to_nxt[`DADD] |
                            inst_to_nxt[`BIT]  | inst_to_nxt[`XOR]  |
                            inst_to_nxt[`AND]  |
                            inst_so_nxt[`RRC]  | inst_so_nxt[`RRA]  |
                            inst_so_nxt[`SXT];
// ... unrelated original RTL lines 984-984 omitted ...
wire        alu_shift     = inst_so_nxt[`RRC]  | inst_so_nxt[`RRA];
// ... unrelated original RTL lines 986-986 omitted ...
wire        exec_no_wr    = inst_to_nxt[`CMP] | inst_to_nxt[`BIT];
// ... unrelated original RTL lines 988-988 omitted ...
wire [11:0] inst_alu_nxt  = {exec_no_wr,
                             alu_shift,
                             alu_stat_f,
                             alu_stat_7,
                             alu_dadd,
                             alu_xor,
                             alu_or,
                             alu_and,
                             alu_add,
                             alu_inc_c,
                             alu_inc,
                             alu_src_inv};
// ... unrelated original RTL lines 1001-1001 omitted ...
always @(posedge mclk_decode or posedge puc_rst)
  if (puc_rst)     inst_alu <= 12'h000;
`ifdef CLOCK_GATING
  else             inst_alu <= inst_alu_nxt;

// ----------------------------------------------------------------------------
// Original source: omsp_mem_backbone.v
// Module: omsp_mem_backbone
// ----------------------------------------------------------------------------
output        [15:0] eu_mdb_in;         // Execution Unit Memory data bus input
output        [15:0] fe_mdb_in;         // Frontend Memory data bus input
// ... unrelated original RTL lines 110-114 omitted ...
output        [15:0] per_din;           // Peripheral data input
// ... unrelated original RTL lines 116-116 omitted ...
output               per_en;            // Peripheral enable (high active)
// ... unrelated original RTL lines 118-124 omitted ...
input                cpu_halt_st;       // Halt/Run status from CPU
// ... unrelated original RTL lines 126-127 omitted ...
input         [15:0] dbg_mem_dout;      // Debug unit data output
input                dbg_mem_en;        // Debug unit memory enable
// ... unrelated original RTL lines 130-130 omitted ...
input         [15:0] dmem_dout;         // Data Memory data output
// ... unrelated original RTL lines 132-132 omitted ...
input                eu_mb_en;          // Execution Unit Memory bus enable
input          [1:0] eu_mb_wr;          // Execution Unit Memory bus write transfer
input         [15:0] eu_mdb_out;        // Execution Unit Memory data bus output
input         [14:0] fe_mab;            // Frontend Memory address bus
input                fe_mb_en;          // Frontend Memory bus enable
input                mclk;              // Main system clock
// ... unrelated original RTL lines 139-139 omitted ...
input         [15:0] dma_din;           // Direct Memory Access data input
// ... unrelated original RTL lines 141-144 omitted ...
input         [15:0] pmem_dout;         // Program Memory data output
input                puc_rst;           // Main system reset
// ... unrelated original RTL lines 147-148 omitted ...
wire                 ext_mem_en;
// ... unrelated original RTL lines 150-154 omitted ...
wire                 ext_per_sel;
wire                 ext_per_en;
// ... unrelated original RTL lines 157-188 omitted ...
wire [15:0] ext_mem_dout  =  dbg_mem_en ? dbg_mem_dout  :  dma_din;
// ... unrelated original RTL lines 190-254 omitted ...
parameter          PMEM_OFFSET   = (16'hFFFF-`PMEM_SIZE+1);
// ... unrelated original RTL lines 256-257 omitted ...
wire               eu_pmem_sel   = (eu_mab>=(PMEM_OFFSET>>1));
wire               eu_pmem_en    = eu_mb_en & ~|eu_mb_wr & eu_pmem_sel;
// ... unrelated original RTL lines 260-262 omitted ...
wire               fe_pmem_sel   = (fe_mab>=(PMEM_OFFSET>>1));
wire               fe_pmem_en    = fe_mb_en & fe_pmem_sel;
// ... unrelated original RTL lines 265-287 omitted ...
wire               eu_per_sel    =  (eu_mab<(`PER_SIZE>>1));
wire               eu_per_en     =  eu_mb_en & eu_per_sel;
// ... unrelated original RTL lines 290-295 omitted ...
assign             ext_per_en    =  ext_mem_en & ext_per_sel & ~eu_per_en;
// ... unrelated original RTL lines 297-298 omitted ...
wire               per_en        =  ext_per_en | eu_per_en;
// ... unrelated original RTL lines 300-303 omitted ...
wire        [15:0] per_din       =  ext_per_en ? ext_mem_dout               : eu_mdb_out;
// ... unrelated original RTL lines 305-306 omitted ...
reg   [15:0] per_dout_val;
// ... unrelated original RTL lines 308-318 omitted ...
reg         fe_pmem_en_dly;
// ... unrelated original RTL lines 320-323 omitted ...
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
// ... unrelated original RTL lines 354-360 omitted ...
reg [1:0] eu_mdb_in_sel;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)  eu_mdb_in_sel  <= 2'b00;
  else          eu_mdb_in_sel  <= {eu_pmem_en, eu_per_en};
// ... unrelated original RTL lines 365-366 omitted ...
assign          eu_mdb_in       = eu_mdb_in_sel[1] ? pmem_dout    :
                                  eu_mdb_in_sel[0] ? per_dout_val : dmem_dout;

// ----------------------------------------------------------------------------
// Original source: omsp_register_file.v
// Module: omsp_register_file
// ----------------------------------------------------------------------------
output              cpuoff;       // Turns off the CPU
// ... unrelated original RTL lines 87-89 omitted ...
output              pc_sw_wr;     // Program counter software write
// ... unrelated original RTL lines 91-100 omitted ...
input               inst_bw;      // Decoded Inst: byte width
input        [15:0] inst_dest;    // Register destination selection
// ... unrelated original RTL lines 103-106 omitted ...
input        [15:0] reg_dest_val; // Selected register destination value
input               reg_dest_wr;  // Write selected register destination
input               reg_pc_call;  // Trigger PC update for a CALL instruction
// ... unrelated original RTL lines 110-111 omitted ...
input               reg_sr_wr;    // Status register update for RETI instruction
// ... unrelated original RTL lines 113-125 omitted ...
wire [15:0] reg_dest_val_in = inst_bw ? {8'h00,reg_dest_val[7:0]} : reg_dest_val;
// ... unrelated original RTL lines 127-144 omitted ...
wire        pc_sw_wr = (inst_dest[0] & reg_dest_wr) | reg_pc_call;
// ... unrelated original RTL lines 146-178 omitted ...
reg  [15:0] r2;
wire        r2_wr  = (inst_dest[2] & reg_dest_wr) | reg_sr_wr;
// ... unrelated original RTL lines 181-188 omitted ...
wire  [7:3] r2_nxt = r2_wr          ? reg_dest_val_in[7:3] : r2[7:3];
// ... unrelated original RTL lines 190-218 omitted ...
   wire [15:0] cpuoff_mask = 16'h0010;
// ... unrelated original RTL lines 220-253 omitted ...
assign cpuoff =  r2[4] | (r2_nxt[4] & r2_wr & cpuoff_mask[4]);

// ----------------------------------------------------------------------------
// Original source: omsp_sfr.v
// Module: omsp_sfr
// ----------------------------------------------------------------------------
output              nmi_pnd;      // NMI Pending
// ... unrelated original RTL lines 82-83 omitted ...
output              wdtie;        // Watchdog-timer interrupt enable
// ... unrelated original RTL lines 85-91 omitted ...
input               mclk;         // Main system clock
// ... unrelated original RTL lines 93-93 omitted ...
input               nmi_acc;      // Non-Maskable interrupt request accepted
input        [13:0] per_addr;     // Peripheral address
input        [15:0] per_din;      // Peripheral data input
input               per_en;       // Peripheral enable (high active)
input         [1:0] per_we;       // Peripheral write enable (high active)
input               puc_rst;      // Main system reset
// ... unrelated original RTL lines 100-109 omitted ...
parameter       [14:0] BASE_ADDR   = 15'h0000;
// ... unrelated original RTL lines 111-112 omitted ...
parameter              DEC_WD      =  4;
// ... unrelated original RTL lines 114-115 omitted ...
parameter [DEC_WD-1:0] IE1         =  'h0,
                       IFG1        =  'h2,
                       CPU_ID_LO   =  'h4,
                       CPU_ID_HI   =  'h6,
                       CPU_NR      =  'h8;
// ... unrelated original RTL lines 121-122 omitted ...
parameter              DEC_SZ      =  (1 << DEC_WD);
// ... unrelated original RTL lines 124-126 omitted ...
parameter [DEC_SZ-1:0] IE1_D       = (BASE_REG << IE1),
                       IFG1_D      = (BASE_REG << IFG1),
                       CPU_ID_LO_D = (BASE_REG << CPU_ID_LO),
                       CPU_ID_HI_D = (BASE_REG << CPU_ID_HI),
                       CPU_NR_D    = (BASE_REG << CPU_NR);
// ... unrelated original RTL lines 132-138 omitted ...
wire              reg_sel      =  per_en & (per_addr[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);
// ... unrelated original RTL lines 140-141 omitted ...
wire [DEC_WD-1:0] reg_addr     =  {1'b0, per_addr[DEC_WD-2:0]};
// ... unrelated original RTL lines 143-144 omitted ...
wire [DEC_SZ-1:0] reg_dec      = (IE1_D        &  {DEC_SZ{(reg_addr==(IE1       >>1))}})  |
                                 (IFG1_D       &  {DEC_SZ{(reg_addr==(IFG1      >>1))}})  |
                                 (CPU_ID_LO_D  &  {DEC_SZ{(reg_addr==(CPU_ID_LO >>1))}})  |
                                 (CPU_ID_HI_D  &  {DEC_SZ{(reg_addr==(CPU_ID_HI >>1))}})  |
                                 (CPU_NR_D     &  {DEC_SZ{(reg_addr==(CPU_NR    >>1))}});
// ... unrelated original RTL lines 150-151 omitted ...
wire              reg_lo_write =  per_we[0] & reg_sel;
// ... unrelated original RTL lines 153-157 omitted ...
wire [DEC_SZ-1:0] reg_lo_wr    = reg_dec & {DEC_SZ{reg_lo_write}};
// ... unrelated original RTL lines 159-168 omitted ...
wire       ie1_wr  = IE1[0] ? reg_hi_wr[IE1] : reg_lo_wr[IE1];
wire [7:0] ie1_nxt = IE1[0] ? per_din[15:8]  : per_din[7:0];
// ... unrelated original RTL lines 171-172 omitted ...
reg        nmie;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)      nmie  <=  1'b0;
  else if (nmi_acc) nmie  <=  1'b0;
  else if (ie1_wr)  nmie  <=  ie1_nxt[4];
// ... unrelated original RTL lines 178-183 omitted ...
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)      wdtie <=  1'b0;
  else if (ie1_wr)  wdtie <=  ie1_nxt[0];
// ... unrelated original RTL lines 187-197 omitted ...
wire       ifg1_wr  = IFG1[0] ? reg_hi_wr[IFG1] : reg_lo_wr[IFG1];
wire [7:0] ifg1_nxt = IFG1[0] ? per_din[15:8]   : per_din[7:0];
// ... unrelated original RTL lines 200-201 omitted ...
reg        nmiifg;
wire       nmi_edge;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)       nmiifg <=  1'b0;
  else if (nmi_edge) nmiifg <=  1'b1;
  else if (ifg1_wr)  nmiifg <=  ifg1_nxt[4];
// ... unrelated original RTL lines 208-354 omitted ...
wire        nmi_pnd   = nmiifg & nmie;

// ----------------------------------------------------------------------------
// Original source: omsp_watchdog.v
// Module: omsp_watchdog
// ----------------------------------------------------------------------------
output              wdt_irq;        // Watchdog-timer interrupt
// ... unrelated original RTL lines 85-86 omitted ...
output              wdtifg;         // Watchdog-timer interrupt flag
// ... unrelated original RTL lines 88-94 omitted ...
input               mclk;           // Main system clock
// ... unrelated original RTL lines 96-96 omitted ...
input        [15:0] per_din;        // Peripheral data input
// ... unrelated original RTL lines 98-98 omitted ...
input         [1:0] per_we;         // Peripheral write enable (high active)
input               por;            // Power-on reset
input               puc_rst;        // Main system reset
// ... unrelated original RTL lines 102-105 omitted ...
input               wdtie;          // Watchdog timer interrupt enable
input               wdtifg_irq_clr; // Clear Watchdog-timer interrupt flag
input               wdtifg_sw_clr;  // Watchdog-timer interrupt flag software clear
input               wdtifg_sw_set;  // Watchdog-timer interrupt flag software set
// ... unrelated original RTL lines 110-122 omitted ...
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
// ... unrelated original RTL lines 145-146 omitted ...
wire              reg_write =  |per_we & reg_sel;
// ... unrelated original RTL lines 148-150 omitted ...
wire [DEC_SZ-1:0] reg_wr    = reg_dec & {DEC_SZ{reg_write}};
// ... unrelated original RTL lines 152-162 omitted ...
reg  [7:0] wdtctl;
// ... unrelated original RTL lines 164-164 omitted ...
wire       wdtctl_wr = reg_wr[WDTCTL];
// ... unrelated original RTL lines 166-167 omitted ...
wire       mclk_wdtctl;
// ... unrelated original RTL lines 169-191 omitted ...
parameter [7:0] WDTCTL_MASK   = (8'b1001_0011 | WDTSSEL_MASK | WDTNMIES_MASK);
// ... unrelated original RTL lines 193-193 omitted ...
always @ (posedge mclk_wdtctl or posedge puc_rst)
  if (puc_rst)        wdtctl <=  8'h00;
`ifdef CLOCK_GATING
  else                wdtctl <=  per_din[7:0] & WDTCTL_MASK;
// ... unrelated original RTL lines 198-201 omitted ...
wire       wdtpw_error = wdtctl_wr & (per_din[15:8]!=8'h5a);
wire       wdttmsel    = wdtctl[4];
// ... unrelated original RTL lines 204-394 omitted ...
wire       wdt_evt_toggle_sync;
// ... unrelated original RTL lines 396-403 omitted ...
reg        wdt_evt_toggle_sync_dly;
// ... unrelated original RTL lines 405-408 omitted ...
wire       wdtifg_evt =  (wdt_evt_toggle_sync_dly ^ wdt_evt_toggle_sync) | wdtpw_error;
// ... unrelated original RTL lines 410-416 omitted ...
wire wdtifg_clr;
// ... unrelated original RTL lines 418-455 omitted ...
wire       wdtifg_set =  wdtifg_evt                  |  wdtifg_sw_set;
assign     wdtifg_clr =  (wdtifg_irq_clr & wdttmsel) |  wdtifg_sw_clr;
// ... unrelated original RTL lines 458-458 omitted ...
always @ (posedge mclk or posedge por)
  if (por)             wdtifg <=  1'b0;
  else if (wdtifg_set) wdtifg <=  1'b1;
  else if (wdtifg_clr) wdtifg <=  1'b0;
// ... unrelated original RTL lines 463-466 omitted ...
wire    wdt_irq       = wdttmsel & wdtifg & wdtie;

// ----------------------------------------------------------------------------
// Original source: openMSP430.v
// Module: openMSP430
// ----------------------------------------------------------------------------
output        [15:0] per_din;                // Peripheral data input
output               per_en;                 // Peripheral enable (high active)
// ... unrelated original RTL lines 138-142 omitted ...
output               puc_rst;                // Main system reset
// ... unrelated original RTL lines 144-157 omitted ...
input         [15:0] dmem_dout;              // Data Memory data output
// ... unrelated original RTL lines 159-168 omitted ...
input         [15:0] pmem_dout;              // Program Memory data output
// ... unrelated original RTL lines 170-180 omitted ...
wire           [7:0] inst_ad;
// ... unrelated original RTL lines 182-182 omitted ...
wire          [11:0] inst_alu;
wire                 inst_bw;
// ... unrelated original RTL lines 185-185 omitted ...
wire                 inst_mov;
// ... unrelated original RTL lines 187-188 omitted ...
wire          [15:0] inst_sext;
wire           [7:0] inst_so;
// ... unrelated original RTL lines 191-193 omitted ...
wire           [3:0] e_state;
wire                 exec_done;
// ... unrelated original RTL lines 196-197 omitted ...
wire                 cpuoff;
// ... unrelated original RTL lines 199-201 omitted ...
wire                 por;
// ... unrelated original RTL lines 203-214 omitted ...
wire          [15:0] eu_mdb_in;
wire          [15:0] eu_mdb_out;
// ... unrelated original RTL lines 217-217 omitted ...
wire                 eu_mb_en;
wire          [15:0] fe_mab;
wire          [15:0] fe_mdb_in;
// ... unrelated original RTL lines 221-223 omitted ...
wire                 pc_sw_wr;
wire          [15:0] pc_sw;
// ... unrelated original RTL lines 226-226 omitted ...
wire          [15:0] pc_nxt;
// ... unrelated original RTL lines 228-228 omitted ...
wire                 nmi_acc;
wire                 nmi_pnd;
// ... unrelated original RTL lines 231-232 omitted ...
wire                 wdtie;
// ... unrelated original RTL lines 234-234 omitted ...
wire                 wdtifg;
wire                 wdt_irq;
// ... unrelated original RTL lines 237-239 omitted ...
wire                 wdtifg_sw_set;
// ... unrelated original RTL lines 241-249 omitted ...
wire          [15:0] dbg_mem_dout;
// ... unrelated original RTL lines 251-254 omitted ...
wire                 cpu_halt_st;
// ... unrelated original RTL lines 256-322 omitted ...
omsp_frontend frontend_0 (
// ... unrelated original RTL lines 324-325 omitted ...
    .cpu_halt_st       (cpu_halt_st),        // Halt/Run status from CPU
// ... unrelated original RTL lines 327-327 omitted ...
    .e_state           (e_state),            // Execution state
    .exec_done         (exec_done),          // Execution completed
    .inst_ad           (inst_ad),            // Decoded Inst: destination addressing mode
// ... unrelated original RTL lines 331-331 omitted ...
    .inst_alu          (inst_alu),           // ALU control signals
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
// ... unrelated original RTL lines 334-337 omitted ...
    .inst_mov          (inst_mov),           // Decoded Inst: mov instruction
// ... unrelated original RTL lines 339-339 omitted ...
    .inst_so           (inst_so),            // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 341-351 omitted ...
    .pc_nxt            (pc_nxt),             // Next PC value (for CALL & IRQ)
// ... unrelated original RTL lines 353-356 omitted ...
    .cpuoff            (cpuoff),             // Turns off the CPU
// ... unrelated original RTL lines 358-365 omitted ...
    .nmi_pnd           (nmi_pnd),            // Non-maskable interrupt pending
// ... unrelated original RTL lines 367-367 omitted ...
    .pc_sw             (pc_sw),              // Program counter software value
    .pc_sw_wr          (pc_sw_wr),           // Program counter software write
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 371-371 omitted ...
    .wdt_irq           (wdt_irq),            // Watchdog-timer interrupt
// ... unrelated original RTL lines 373-374 omitted ...
);
// ... unrelated original RTL lines 376-381 omitted ...
omsp_execution_unit execution_unit_0 (
// ... unrelated original RTL lines 383-384 omitted ...
    .cpuoff            (cpuoff),             // Turns off the CPU
// ... unrelated original RTL lines 386-387 omitted ...
    .mb_en             (eu_mb_en),           // Memory bus enable
// ... unrelated original RTL lines 389-392 omitted ...
    .pc_sw_wr          (pc_sw_wr),           // Program counter software write
// ... unrelated original RTL lines 394-397 omitted ...
    .dbg_halt_st       (cpu_halt_st),        // Halt/Run status from CPU
    .dbg_mem_dout      (dbg_mem_dout),       // Debug unit data output
// ... unrelated original RTL lines 400-405 omitted ...
    .inst_alu          (inst_alu),           // ALU control signals
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
// ... unrelated original RTL lines 408-411 omitted ...
    .inst_mov          (inst_mov),           // Decoded Inst: mov instruction
    .inst_sext         (inst_sext),          // Decoded Inst: source extended instruction word
    .inst_so           (inst_so),            // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 415-417 omitted ...
    .mdb_in            (eu_mdb_in),          // Memory data bus input
// ... unrelated original RTL lines 419-422 omitted ...
);
// ... unrelated original RTL lines 424-429 omitted ...
omsp_mem_backbone mem_backbone_0 (
// ... unrelated original RTL lines 431-438 omitted ...
    .eu_mdb_in         (eu_mdb_in),          // Execution Unit Memory data bus input
    .fe_mdb_in         (fe_mdb_in),          // Frontend Memory data bus input
// ... unrelated original RTL lines 441-445 omitted ...
    .per_din           (per_din),            // Peripheral data input
// ... unrelated original RTL lines 447-447 omitted ...
    .per_en            (per_en),             // Peripheral enable (high active)
// ... unrelated original RTL lines 449-460 omitted ...
    .dmem_dout         (dmem_dout),          // Data Memory data output
// ... unrelated original RTL lines 462-462 omitted ...
    .eu_mb_en          (eu_mb_en),           // Execution Unit Memory bus enable
// ... unrelated original RTL lines 464-464 omitted ...
    .eu_mdb_out        (eu_mdb_out),         // Execution Unit Memory data bus output
    .fe_mab            (fe_mab[15:1]),       // Frontend Memory address bus
// ... unrelated original RTL lines 467-474 omitted ...
    .pmem_dout         (pmem_dout),          // Program Memory data output
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 477-477 omitted ...
);
// ... unrelated original RTL lines 479-484 omitted ...
omsp_sfr sfr_0 (
// ... unrelated original RTL lines 486-488 omitted ...
    .nmi_pnd           (nmi_pnd),            // NMI Pending
// ... unrelated original RTL lines 490-491 omitted ...
    .wdtie             (wdtie),              // Watchdog-timer interrupt enable
// ... unrelated original RTL lines 493-500 omitted ...
    .nmi_acc           (nmi_acc),            // Non-Maskable interrupt request accepted
// ... unrelated original RTL lines 502-503 omitted ...
    .per_en            (per_en),             // Peripheral enable (high active)
// ... unrelated original RTL lines 505-505 omitted ...
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 507-509 omitted ...
);
// ... unrelated original RTL lines 511-516 omitted ...
omsp_watchdog watchdog_0 (
// ... unrelated original RTL lines 518-520 omitted ...
    .wdt_irq           (wdt_irq),            // Watchdog-timer interrupt
// ... unrelated original RTL lines 522-523 omitted ...
    .wdtifg            (wdtifg),             // Watchdog-timer interrupt flag
// ... unrelated original RTL lines 525-532 omitted ...
    .per_din           (per_din),            // Peripheral data input
// ... unrelated original RTL lines 534-535 omitted ...
    .por               (por),                // Power-on reset
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 538-541 omitted ...
    .wdtie             (wdtie),              // Watchdog-timer interrupt enable
// ... unrelated original RTL lines 543-544 omitted ...
    .wdtifg_sw_set     (wdtifg_sw_set)       // Watchdog-timer interrupt flag software set
);

// ----------------------------------------------------------------------------
// Referenced original preprocessor definitions
// ----------------------------------------------------------------------------
// source: openMSP430_defines.v:727-727
`define ABS      6
// source: openMSP430_defines.v:708-708
`define ADD    1
// source: openMSP430_defines.v:709-709
`define ADDC   2
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
// source: openMSP430_defines.v:756-756
`define ALU_SRC_INV   0
// source: openMSP430_defines.v:762-762
`define ALU_XOR       6
// source: openMSP430_defines.v:718-718
`define AND   11
// source: openMSP430_defines.v:715-715
`define BIC    8
// source: openMSP430_defines.v:716-716
`define BIS    9
// source: openMSP430_defines.v:714-714
`define BIT    7
// source: openMSP430_defines.v:692-692
`define CALL   5
// source: openMSP430_defines.v:712-712
`define CMP    5
// source: openMSP430_defines.v:713-713
`define DADD   6
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
// source: openMSP430_defines.v:673-673
`define IRQ_NR 64
// source: openMSP430_defines.v:736-736
`define I_IDLE      3'h5
// source: openMSP430_defines.v:732-732
`define I_IRQ_DONE  3'h1
// source: openMSP430_defines.v:731-731
`define I_IRQ_FETCH 3'h0
// source: openMSP430_defines.v:707-707
`define MOV    0
// source: openMSP430_defines.v:653-653
  `define PER_SIZE          `PER_CUSTOM_SIZE
// source: openMSP430_defines.v:561-561
  `define PMEM_SIZE         `PMEM_CUSTOM_SIZE
// source: openMSP430_defines.v:691-691
`define PUSH   4
// source: openMSP430_defines.v:693-693
`define RETI   6
// source: openMSP430_defines.v:689-689
`define RRA    2
// source: openMSP430_defines.v:687-687
`define RRC    0
// source: openMSP430_defines.v:711-711
`define SUB    4
// source: openMSP430_defines.v:710-710
`define SUBC   3
// source: openMSP430_defines.v:688-688
`define SWPB   1
// source: openMSP430_defines.v:690-690
`define SXT    3
// source: openMSP430_defines.v:725-725
`define SYMB     4
// source: openMSP430_defines.v:717-717
`define XOR   10
