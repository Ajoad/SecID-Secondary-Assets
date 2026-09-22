// ============================================================================
// Cluster-local relation RTL: C028 -> openMSP430.frontend_0.pc
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 5 RTL-proximal candidates. Members: openMSP430.inst_dest, openMSP430.inst_src, openMSP430.multiplier_0.product, openMSP430.multiplier_0.reg_wr, openMSP430.watchdog_0.reg_rd. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
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
// ... unrelated original RTL lines 82-83 omitted ...
input         [7:0] inst_so;       // Single-operand arithmetic
input        [15:0] op_dst;        // Destination operand
input        [15:0] op_src;        // Source operand
// ... unrelated original RTL lines 87-152 omitted ...
wire        op_src_inv_cmd = exec_cycle & (inst_alu[`ALU_SRC_INV]);
wire [15:0] op_src_inv     = {16{op_src_inv_cmd}} ^ op_src;
// ... unrelated original RTL lines 155-157 omitted ...
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
// ... unrelated original RTL lines 192-197 omitted ...
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

// ----------------------------------------------------------------------------
// Original source: omsp_execution_unit.v
// Module: omsp_execution_unit
// ----------------------------------------------------------------------------
output              cpuoff;        // Turns off the CPU
// ... unrelated original RTL lines 96-103 omitted ...
output              pc_sw_wr;      // Program counter software write
// ... unrelated original RTL lines 105-109 omitted ...
input               dbg_halt_st;   // Halt/Run status from CPU
input        [15:0] dbg_mem_dout;  // Debug unit data output
// ... unrelated original RTL lines 112-112 omitted ...
input         [3:0] e_state;       // Execution state
// ... unrelated original RTL lines 114-114 omitted ...
input         [7:0] inst_ad;       // Decoded Inst: destination addressing mode
input         [7:0] inst_as;       // Decoded Inst: source addressing mode
input        [11:0] inst_alu;      // ALU control signals
input               inst_bw;       // Decoded Inst: byte width
input        [15:0] inst_dest;     // Decoded Inst: destination (one hot)
input        [15:0] inst_dext;     // Decoded Inst: destination extended instruction word
// ... unrelated original RTL lines 121-123 omitted ...
input        [15:0] inst_sext;     // Decoded Inst: source extended instruction word
input         [7:0] inst_so;       // Decoded Inst: Single-operand arithmetic
input        [15:0] inst_src;      // Decoded Inst: source (one hot)
input         [2:0] inst_type;     // Decoded Instruction type
// ... unrelated original RTL lines 128-128 omitted ...
input        [15:0] mdb_in;        // Memory data bus input
// ... unrelated original RTL lines 130-139 omitted ...
wire         [15:0] alu_out;
// ... unrelated original RTL lines 141-143 omitted ...
wire         [15:0] op_dst;
wire         [15:0] op_src;
wire         [15:0] reg_dest;
wire         [15:0] reg_src;
wire         [15:0] mdb_in_bw;
wire         [15:0] mdb_in_val;
wire          [3:0] status;
// ... unrelated original RTL lines 151-168 omitted ...
wire reg_sr_clr   =  (e_state==`E_IRQ_2);
// ... unrelated original RTL lines 170-170 omitted ...
wire reg_pc_call  = ((e_state==`E_EXEC)   & inst_so[`CALL]) |
                    ((e_state==`E_DST_WR) & inst_so[`RETI]);
// ... unrelated original RTL lines 173-180 omitted ...
omsp_register_file register_file_0 (
// ... unrelated original RTL lines 182-183 omitted ...
    .cpuoff       (cpuoff),       // Turns off the CPU
// ... unrelated original RTL lines 185-187 omitted ...
    .pc_sw_wr     (pc_sw_wr),     // Program counter software write
    .reg_dest     (reg_dest),     // Selected register destination content
    .reg_src      (reg_src),      // Selected register source content
// ... unrelated original RTL lines 191-197 omitted ...
    .inst_bw      (inst_bw),      // Decoded Inst: byte width
    .inst_dest    (inst_dest),    // Register destination selection
    .inst_src     (inst_src),     // Register source selection
// ... unrelated original RTL lines 201-203 omitted ...
    .reg_dest_val (alu_out),      // Selected register destination value
// ... unrelated original RTL lines 205-205 omitted ...
    .reg_pc_call  (reg_pc_call),  // Trigger PC update for a CALL instruction
// ... unrelated original RTL lines 207-208 omitted ...
    .reg_sr_clr   (reg_sr_clr),   // Status register clear for interrupts
// ... unrelated original RTL lines 210-212 omitted ...
);
// ... unrelated original RTL lines 214-227 omitted ...
wire src_reg_src_sel    =  (e_state==`E_IRQ_0)                    |
                           (e_state==`E_IRQ_2)                    |
                          ((e_state==`E_SRC_RD) & ~inst_as[`ABS]) |
                          ((e_state==`E_SRC_WR) & ~inst_as[`ABS]) |
                          ((e_state==`E_EXEC)   &  inst_as[`DIR] & ~inst_type[`INST_JMP]);
// ... unrelated original RTL lines 233-233 omitted ...
wire src_reg_dest_sel   =  (e_state==`E_IRQ_1)                    |
                           (e_state==`E_IRQ_3)                    |
                          ((e_state==`E_DST_RD) & (inst_so[`PUSH] | inst_so[`CALL])) |
                          ((e_state==`E_SRC_AD) & (inst_so[`PUSH] | inst_so[`CALL]) & inst_as[`IDX]);
// ... unrelated original RTL lines 238-238 omitted ...
wire src_mdb_in_val_sel = ((e_state==`E_DST_RD) &  inst_so[`RETI])                     |
                          ((e_state==`E_EXEC)   & (inst_as[`INDIR] | inst_as[`INDIR_I] |
                                                   inst_as[`IDX]   | inst_as[`SYMB]    |
                                                   inst_as[`ABS]));
// ... unrelated original RTL lines 243-243 omitted ...
wire src_inst_dext_sel =  ((e_state==`E_DST_RD) & ~(inst_so[`PUSH] | inst_so[`CALL])) |
                          ((e_state==`E_DST_WR) & ~(inst_so[`PUSH] | inst_so[`CALL]   |
                                                    inst_so[`RETI]));
// ... unrelated original RTL lines 247-247 omitted ...
wire src_inst_sext_sel =  ((e_state==`E_EXEC)   &  (inst_type[`INST_JMP] | inst_as[`IMM] |
                                                    inst_as[`CONST]      | inst_so[`RETI]));
// ... unrelated original RTL lines 250-251 omitted ...
assign op_src = src_reg_src_sel     ?  reg_src    :
                src_reg_dest_sel    ?  reg_dest   :
                src_mdb_in_val_sel  ?  mdb_in_val :
                src_inst_dext_sel   ?  inst_dext  :
                src_inst_sext_sel   ?  inst_sext  : 16'h0000;
// ... unrelated original RTL lines 257-267 omitted ...
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
// ... unrelated original RTL lines 295-300 omitted ...
wire exec_cycle = (e_state==`E_EXEC);
// ... unrelated original RTL lines 302-302 omitted ...
omsp_alu alu_0 (
// ... unrelated original RTL lines 304-313 omitted ...
    .inst_alu     (inst_alu),     // ALU control signals
// ... unrelated original RTL lines 315-318 omitted ...
    .op_src       (op_src),       // Source operand
// ... unrelated original RTL lines 320-320 omitted ...
);
// ... unrelated original RTL lines 322-357 omitted ...
                                (e_state==`E_IRQ_0) | (e_state==`E_IRQ_2));
// ... unrelated original RTL lines 359-378 omitted ...
reg        mab_lsb;
// ... unrelated original RTL lines 380-383 omitted ...
assign mdb_in_bw  = ~inst_bw ? mdb_in :
                     mab_lsb ? {2{mdb_in[15:8]}} : mdb_in;
// ... unrelated original RTL lines 386-392 omitted ...
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
output               decode_noirq;     // Frontend decode instruction
output         [3:0] e_state;          // Execution state
output               exec_done;        // Execution completed
// ... unrelated original RTL lines 110-111 omitted ...
output        [11:0] inst_alu;         // ALU control signals
output               inst_bw;          // Decoded Inst: byte width
output        [15:0] inst_dest;        // Decoded Inst: destination (one hot)
// ... unrelated original RTL lines 115-119 omitted ...
output         [7:0] inst_so;          // Decoded Inst: Single-operand arithmetic
output        [15:0] inst_src;         // Decoded Inst: source (one hot)
output         [2:0] inst_type;        // Decoded Instruction type
// ... unrelated original RTL lines 123-130 omitted ...
output        [15:0] pc;               // Program counter
output        [15:0] pc_nxt;           // Next PC value (for CALL & IRQ)
// ... unrelated original RTL lines 133-135 omitted ...
input                cpu_en_s;         // Enable CPU code execution (synchronous)
input                cpu_halt_cmd;     // Halt CPU command
input                cpuoff;           // Turns off the CPU
input          [3:0] dbg_reg_sel;      // Debug selected register for rd/wr access
// ... unrelated original RTL lines 140-144 omitted ...
input                mclk;             // Main system clock
input         [15:0] mdb_in;           // Frontend Memory data bus input
// ... unrelated original RTL lines 147-148 omitted ...
input         [15:0] pc_sw;            // Program counter software value
input                pc_sw_wr;         // Program counter software write
input                puc_rst;          // Main system reset
input                scan_enable;      // Scan enable (active during scan shifting)
// ... unrelated original RTL lines 153-163 omitted ...
   input  [5:0] binary;
// ... unrelated original RTL lines 165-171 omitted ...
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
wire   fetch        = ~((i_state==I_DEC) & ~(exec_done | (e_state==E_IDLE))) & ~(e_state_nxt==E_IDLE);
// ... unrelated original RTL lines 286-288 omitted ...
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)  cpu_halt_st <= 1'b0;
  else          cpu_halt_st <= cpu_halt_req & (i_state_nxt==I_IDLE);
// ... unrelated original RTL lines 292-334 omitted ...
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
// ... unrelated original RTL lines 566-636 omitted ...
reg [3:0] inst_dest_bin;
// ... unrelated original RTL lines 638-645 omitted ...
wire  [15:0] inst_dest = cpu_halt_st          ? one_hot16(dbg_reg_sel) :
                         inst_type[`INST_JMP] ? 16'h0001               :
                         inst_so[`IRQ]  |
                         inst_so[`PUSH] |
                         inst_so[`CALL]       ? 16'h0002               :
                                                one_hot16(inst_dest_bin);
// ... unrelated original RTL lines 652-654 omitted ...
reg [3:0] inst_src_bin;
// ... unrelated original RTL lines 656-663 omitted ...
wire  [15:0] inst_src = inst_type[`INST_TO] ? one_hot16(inst_src_bin)  :
                        inst_so[`RETI]      ? 16'h0002                 :
                        inst_so[`IRQ]       ? 16'h0001                 :
                        inst_type[`INST_SO] ? one_hot16(inst_dest_bin) : 16'h0000;
// ... unrelated original RTL lines 668-806 omitted ...
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)     inst_bw     <= 1'b0;
  else if (decode) inst_bw     <= ir[6] & ~inst_type_nxt[`INST_JMP] & ~irq_detect & ~cpu_halt_req;
// ... unrelated original RTL lines 810-833 omitted ...
wire src_acalc_pre =  inst_as_nxt[`IDX]   | inst_as_nxt[`SYMB]    | inst_as_nxt[`ABS];
wire src_rd_pre    =  inst_as_nxt[`INDIR] | inst_as_nxt[`INDIR_I] | inst_as_nxt[`IMM]  | inst_so_nxt[`RETI];
wire dst_acalc_pre =  inst_ad_nxt[`IDX]   | inst_ad_nxt[`SYMB]    | inst_ad_nxt[`ABS];
// ... unrelated original RTL lines 837-837 omitted ...
wire dst_rd_pre    =  inst_ad_nxt[`IDX]   | inst_so_nxt[`PUSH]    | inst_so_nxt[`CALL] | inst_so_nxt[`RETI];
// ... unrelated original RTL lines 839-867 omitted ...
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
// ... unrelated original RTL lines 918-950 omitted ...
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
// ... unrelated original RTL lines 87-89 omitted ...
output              pc_sw_wr;     // Program counter software write
output       [15:0] reg_dest;     // Selected register destination content
output       [15:0] reg_src;      // Selected register source content
// ... unrelated original RTL lines 93-100 omitted ...
input               inst_bw;      // Decoded Inst: byte width
input        [15:0] inst_dest;    // Register destination selection
input        [15:0] inst_src;     // Register source selection
// ... unrelated original RTL lines 104-106 omitted ...
input        [15:0] reg_dest_val; // Selected register destination value
input               reg_dest_wr;  // Write selected register destination
input               reg_pc_call;  // Trigger PC update for a CALL instruction
// ... unrelated original RTL lines 110-111 omitted ...
input               reg_sr_wr;    // Status register update for RETI instruction
input               reg_sr_clr;   // Status register clear for interrupts
// ... unrelated original RTL lines 114-121 omitted ...
wire [15:0] inst_src_in;
// ... unrelated original RTL lines 123-125 omitted ...
wire [15:0] reg_dest_val_in = inst_bw ? {8'h00,reg_dest_val[7:0]} : reg_dest_val;
// ... unrelated original RTL lines 127-135 omitted ...
assign inst_src_in = reg_sr_clr ? 16'h0004 : inst_src;
// ... unrelated original RTL lines 137-141 omitted ...
wire [15:0] r0       = pc;
// ... unrelated original RTL lines 143-144 omitted ...
wire        pc_sw_wr = (inst_dest[0] & reg_dest_wr) | reg_pc_call;
// ... unrelated original RTL lines 146-149 omitted ...
reg [15:0] r1;
// ... unrelated original RTL lines 151-178 omitted ...
reg  [15:0] r2;
wire        r2_wr  = (inst_dest[2] & reg_dest_wr) | reg_sr_wr;
// ... unrelated original RTL lines 181-188 omitted ...
wire  [7:3] r2_nxt = r2_wr          ? reg_dest_val_in[7:3] : r2[7:3];
// ... unrelated original RTL lines 190-218 omitted ...
   wire [15:0] cpuoff_mask = 16'h0010;
// ... unrelated original RTL lines 220-253 omitted ...
assign cpuoff =  r2[4] | (r2_nxt[4] & r2_wr & cpuoff_mask[4]);
// ... unrelated original RTL lines 255-264 omitted ...
reg [15:0] r3;
// ... unrelated original RTL lines 266-291 omitted ...
reg [15:0] r4;
// ... unrelated original RTL lines 293-315 omitted ...
reg [15:0] r5;
// ... unrelated original RTL lines 317-339 omitted ...
reg [15:0] r6;
// ... unrelated original RTL lines 341-363 omitted ...
reg [15:0] r7;
// ... unrelated original RTL lines 365-387 omitted ...
reg [15:0] r8;
// ... unrelated original RTL lines 389-411 omitted ...
reg [15:0] r9;
// ... unrelated original RTL lines 413-435 omitted ...
reg [15:0] r10;
// ... unrelated original RTL lines 437-459 omitted ...
reg [15:0] r11;
// ... unrelated original RTL lines 461-483 omitted ...
reg [15:0] r12;
// ... unrelated original RTL lines 485-507 omitted ...
reg [15:0] r13;
// ... unrelated original RTL lines 509-531 omitted ...
reg [15:0] r14;
// ... unrelated original RTL lines 533-555 omitted ...
reg [15:0] r15;
// ... unrelated original RTL lines 557-582 omitted ...
assign reg_src  = (r0      & {16{inst_src_in[0]}})   |
                  (r1      & {16{inst_src_in[1]}})   |
                  (r2      & {16{inst_src_in[2]}})   |
                  (r3      & {16{inst_src_in[3]}})   |
                  (r4      & {16{inst_src_in[4]}})   |
                  (r5      & {16{inst_src_in[5]}})   |
                  (r6      & {16{inst_src_in[6]}})   |
                  (r7      & {16{inst_src_in[7]}})   |
                  (r8      & {16{inst_src_in[8]}})   |
                  (r9      & {16{inst_src_in[9]}})   |
                  (r10     & {16{inst_src_in[10]}})  |
                  (r11     & {16{inst_src_in[11]}})  |
                  (r12     & {16{inst_src_in[12]}})  |
                  (r13     & {16{inst_src_in[13]}})  |
                  (r14     & {16{inst_src_in[14]}})  |
                  (r15     & {16{inst_src_in[15]}});
// ... unrelated original RTL lines 599-599 omitted ...
assign reg_dest = (r0      & {16{inst_dest[0]}})  |
                  (r1      & {16{inst_dest[1]}})  |
                  (r2      & {16{inst_dest[2]}})  |
                  (r3      & {16{inst_dest[3]}})  |
                  (r4      & {16{inst_dest[4]}})  |
                  (r5      & {16{inst_dest[5]}})  |
                  (r6      & {16{inst_dest[6]}})  |
                  (r7      & {16{inst_dest[7]}})  |
                  (r8      & {16{inst_dest[8]}})  |
                  (r9      & {16{inst_dest[9]}})  |
                  (r10     & {16{inst_dest[10]}}) |
                  (r11     & {16{inst_dest[11]}}) |
                  (r12     & {16{inst_dest[12]}}) |
                  (r13     & {16{inst_dest[13]}}) |
                  (r14     & {16{inst_dest[14]}}) |
                  (r15     & {16{inst_dest[15]}});

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
// ... unrelated original RTL lines 170-182 omitted ...
wire          [11:0] inst_alu;
wire                 inst_bw;
// ... unrelated original RTL lines 185-186 omitted ...
wire          [15:0] inst_dest;
// ... unrelated original RTL lines 188-188 omitted ...
wire          [15:0] inst_sext;
// ... unrelated original RTL lines 190-190 omitted ...
wire          [15:0] inst_src;
wire           [2:0] inst_type;
// ... unrelated original RTL lines 193-193 omitted ...
wire           [3:0] e_state;
// ... unrelated original RTL lines 195-197 omitted ...
wire                 cpuoff;
// ... unrelated original RTL lines 199-214 omitted ...
wire          [15:0] eu_mdb_in;
// ... unrelated original RTL lines 216-219 omitted ...
wire          [15:0] fe_mdb_in;
// ... unrelated original RTL lines 221-223 omitted ...
wire                 pc_sw_wr;
wire          [15:0] pc_sw;
wire          [15:0] pc;
wire          [15:0] pc_nxt;
// ... unrelated original RTL lines 228-249 omitted ...
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
// ... unrelated original RTL lines 329-331 omitted ...
    .inst_alu          (inst_alu),           // ALU control signals
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
    .inst_dest         (inst_dest),          // Decoded Inst: destination (one hot)
// ... unrelated original RTL lines 335-340 omitted ...
    .inst_src          (inst_src),           // Decoded Inst: source (one hot)
    .inst_type         (inst_type),          // Decoded Instruction type
// ... unrelated original RTL lines 343-350 omitted ...
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
// ... unrelated original RTL lines 383-384 omitted ...
    .cpuoff            (cpuoff),             // Turns off the CPU
// ... unrelated original RTL lines 386-392 omitted ...
    .pc_sw_wr          (pc_sw_wr),           // Program counter software write
// ... unrelated original RTL lines 394-397 omitted ...
    .dbg_halt_st       (cpu_halt_st),        // Halt/Run status from CPU
    .dbg_mem_dout      (dbg_mem_dout),       // Debug unit data output
// ... unrelated original RTL lines 400-400 omitted ...
    .e_state           (e_state),            // Execution state
// ... unrelated original RTL lines 402-405 omitted ...
    .inst_alu          (inst_alu),           // ALU control signals
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
    .inst_dest         (inst_dest),          // Decoded Inst: destination (one hot)
// ... unrelated original RTL lines 409-412 omitted ...
    .inst_sext         (inst_sext),          // Decoded Inst: source extended instruction word
// ... unrelated original RTL lines 414-414 omitted ...
    .inst_src          (inst_src),           // Decoded Inst: source (one hot)
// ... unrelated original RTL lines 416-417 omitted ...
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
// source: openMSP430_defines.v:728-728
`define CONST    7
// source: openMSP430_defines.v:713-713
`define DADD   6
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
// source: openMSP430_defines.v:742-742
`define E_IRQ_2     4'h0
// source: openMSP430_defines.v:743-743
`define E_IRQ_3     4'h3
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
// source: openMSP430_defines.v:733-733
`define I_DEC       3'h2
// source: openMSP430_defines.v:736-736
`define I_IDLE      3'h5
// source: openMSP430_defines.v:732-732
`define I_IRQ_DONE  3'h1
// source: openMSP430_defines.v:731-731
`define I_IRQ_FETCH 3'h0
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
