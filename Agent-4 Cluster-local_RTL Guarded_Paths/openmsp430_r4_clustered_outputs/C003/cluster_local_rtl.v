// ============================================================================
// Cluster-local relation RTL: openMSP430.execution_unit_0.register_file_0.r4 -> C003
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 4 RTL-proximal candidates. Members: openMSP430.dbg_0.cpu_stat_rd, openMSP430.execution_unit_0.register_file_0.r14, openMSP430.execution_unit_0.register_file_0.r5, openMSP430.frontend_0.pc_incr. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
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
// ... unrelated original RTL lines 85-85 omitted ...
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
// Original source: omsp_dbg.v
// Module: omsp_dbg
// ----------------------------------------------------------------------------
input               dbg_halt_st;       // Halt/Run status from CPU
// ... unrelated original RTL lines 111-145 omitted ...
wire        brk0_pnd;
// ... unrelated original RTL lines 147-148 omitted ...
wire        brk1_pnd;
// ... unrelated original RTL lines 150-151 omitted ...
wire        brk2_pnd;
// ... unrelated original RTL lines 153-154 omitted ...
wire        brk3_pnd;
// ... unrelated original RTL lines 156-158 omitted ...
parameter           NR_REG       = 25;
// ... unrelated original RTL lines 160-164 omitted ...
parameter           CPU_STAT     = 6'h03;
// ... unrelated original RTL lines 166-240 omitted ...
reg  [NR_REG-1:0]  reg_dec;
// ... unrelated original RTL lines 242-283 omitted ...
wire               reg_read  =  1'b1;
// ... unrelated original RTL lines 285-287 omitted ...
wire  [NR_REG-1:0] reg_rd    = reg_dec & {NR_REG{reg_read}};
// ... unrelated original RTL lines 289-349 omitted ...
reg   [3:2] cpu_stat;
// ... unrelated original RTL lines 351-360 omitted ...
wire  [7:0] cpu_stat_full = {brk3_pnd, brk2_pnd, brk1_pnd, brk0_pnd,
                             cpu_stat, 1'b0, dbg_halt_st};
// ... unrelated original RTL lines 363-625 omitted ...
wire [15:0] cpu_stat_rd  = {8'h00, cpu_stat_full} & {16{reg_rd[CPU_STAT]}};

// ----------------------------------------------------------------------------
// Original source: omsp_execution_unit.v
// Module: omsp_execution_unit
// ----------------------------------------------------------------------------
output              cpuoff;        // Turns off the CPU
// ... unrelated original RTL lines 96-112 omitted ...
input         [3:0] e_state;       // Execution state
// ... unrelated original RTL lines 114-115 omitted ...
input         [7:0] inst_as;       // Decoded Inst: source addressing mode
input        [11:0] inst_alu;      // ALU control signals
input               inst_bw;       // Decoded Inst: byte width
input        [15:0] inst_dest;     // Decoded Inst: destination (one hot)
input        [15:0] inst_dext;     // Decoded Inst: destination extended instruction word
// ... unrelated original RTL lines 121-123 omitted ...
input        [15:0] inst_sext;     // Decoded Inst: source extended instruction word
// ... unrelated original RTL lines 125-126 omitted ...
input         [2:0] inst_type;     // Decoded Instruction type
// ... unrelated original RTL lines 128-131 omitted ...
input               puc_rst;       // Main system reset
// ... unrelated original RTL lines 133-139 omitted ...
wire         [15:0] alu_out;
// ... unrelated original RTL lines 141-144 omitted ...
wire         [15:0] op_src;
wire         [15:0] reg_dest;
wire         [15:0] reg_src;
// ... unrelated original RTL lines 148-148 omitted ...
wire         [15:0] mdb_in_val;
// ... unrelated original RTL lines 150-156 omitted ...
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
// ... unrelated original RTL lines 185-189 omitted ...
    .reg_src      (reg_src),      // Selected register source content
// ... unrelated original RTL lines 191-197 omitted ...
    .inst_bw      (inst_bw),      // Decoded Inst: byte width
    .inst_dest    (inst_dest),    // Register destination selection
// ... unrelated original RTL lines 200-202 omitted ...
    .puc_rst      (puc_rst),      // Main system reset
    .reg_dest_val (alu_out),      // Selected register destination value
    .reg_dest_wr  (reg_dest_wr),  // Write selected register destination
// ... unrelated original RTL lines 206-209 omitted ...
    .reg_sr_wr    (reg_sr_wr),    // Status Register update for RETI instruction
// ... unrelated original RTL lines 211-212 omitted ...
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
// ... unrelated original RTL lines 257-302 omitted ...
omsp_alu alu_0 (
// ... unrelated original RTL lines 304-313 omitted ...
    .inst_alu     (inst_alu),     // ALU control signals
// ... unrelated original RTL lines 315-318 omitted ...
    .op_src       (op_src),       // Source operand
// ... unrelated original RTL lines 320-320 omitted ...
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
// ... unrelated original RTL lines 25-105 omitted ...
output               cpu_halt_st;      // Halt/Run status from CPU
output               decode_noirq;     // Frontend decode instruction
output         [3:0] e_state;          // Execution state
output               exec_done;        // Execution completed
// ... unrelated original RTL lines 110-112 omitted ...
output               inst_bw;          // Decoded Inst: byte width
// ... unrelated original RTL lines 114-130 omitted ...
output        [15:0] pc;               // Program counter
// ... unrelated original RTL lines 132-135 omitted ...
input                cpu_en_s;         // Enable CPU code execution (synchronous)
input                cpu_halt_cmd;     // Halt CPU command
input                cpuoff;           // Turns off the CPU
// ... unrelated original RTL lines 139-144 omitted ...
input                mclk;             // Main system clock
// ... unrelated original RTL lines 146-149 omitted ...
input                pc_sw_wr;         // Program counter software write
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
// ... unrelated original RTL lines 188-208 omitted ...
parameter I_IRQ_FETCH = `I_IRQ_FETCH;
// ... unrelated original RTL lines 210-210 omitted ...
parameter I_DEC       = `I_DEC;        // New instruction ready for decode
parameter I_EXT1      = `I_EXT1;       // 1st Extension word
// ... unrelated original RTL lines 213-213 omitted ...
parameter I_IDLE      = `I_IDLE;       // CPU is in IDLE mode
// ... unrelated original RTL lines 215-219 omitted ...
parameter E_IRQ_0     = `E_IRQ_0;
// ... unrelated original RTL lines 221-224 omitted ...
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
// ... unrelated original RTL lines 243-244 omitted ...
wire [1:0] inst_sz_nxt;
wire       irq_detect;
wire [2:0] inst_type_nxt;
// ... unrelated original RTL lines 248-249 omitted ...
reg  [3:0] e_state_nxt;
// ... unrelated original RTL lines 251-252 omitted ...
wire   cpu_halt_req = cpu_halt_cmd | ~cpu_en_s;
// ... unrelated original RTL lines 254-258 omitted ...
      I_IDLE     : i_state_nxt = (irq_detect & ~cpu_halt_req) ? I_IRQ_FETCH :
                                 (~cpuoff    & ~cpu_halt_req) ? I_DEC       : I_IDLE;
// ... unrelated original RTL lines 261-262 omitted ...
      I_DEC      : i_state_nxt =  irq_detect                  ? I_IRQ_FETCH :
                          (cpuoff | cpu_halt_req) & exec_done ? I_IDLE      :
                            cpu_halt_req & (e_state==E_IDLE)  ? I_IDLE      :
                                  pc_sw_wr                    ? I_DEC       :
                             ~exec_done & ~(e_state==E_IDLE)  ? I_DEC       :        // Wait in decode state
                                  (inst_sz_nxt!=2'b00)        ? I_EXT1      : I_DEC; // until execution is completed
// ... unrelated original RTL lines 269-283 omitted ...
wire   decode       =  decode_noirq | irq_detect;
wire   fetch        = ~((i_state==I_DEC) & ~(exec_done | (e_state==E_IDLE))) & ~(e_state_nxt==E_IDLE);
// ... unrelated original RTL lines 286-288 omitted ...
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)  cpu_halt_st <= 1'b0;
  else          cpu_halt_st <= cpu_halt_req & (i_state_nxt==I_IDLE);
// ... unrelated original RTL lines 292-410 omitted ...
wire [15:0] pc_incr = pc + {14'h0000, fetch, 1'b0};
// ... unrelated original RTL lines 412-447 omitted ...
wire [15:0] ir  = mdb_in;
// ... unrelated original RTL lines 449-564 omitted ...
wire  [7:0] inst_so_nxt = irq_detect ? 8'h80 : (one_hot8(ir[9:7]) & {8{inst_type_nxt[`INST_SO]}});
// ... unrelated original RTL lines 566-806 omitted ...
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

// ----------------------------------------------------------------------------
// Original source: omsp_register_file.v
// Module: omsp_register_file
// ----------------------------------------------------------------------------
output              cpuoff;       // Turns off the CPU
// ... unrelated original RTL lines 87-91 omitted ...
output       [15:0] reg_src;      // Selected register source content
// ... unrelated original RTL lines 93-100 omitted ...
input               inst_bw;      // Decoded Inst: byte width
input        [15:0] inst_dest;    // Register destination selection
// ... unrelated original RTL lines 103-103 omitted ...
input               mclk;         // Main system clock
// ... unrelated original RTL lines 105-105 omitted ...
input               puc_rst;      // Main system reset
input        [15:0] reg_dest_val; // Selected register destination value
input               reg_dest_wr;  // Write selected register destination
// ... unrelated original RTL lines 109-111 omitted ...
input               reg_sr_wr;    // Status register update for RETI instruction
// ... unrelated original RTL lines 113-114 omitted ...
input               scan_enable;  // Scan enable (active during scan shifting)
// ... unrelated original RTL lines 116-121 omitted ...
wire [15:0] inst_src_in;
wire [15:0] incr_op         = (inst_bw & ~inst_src_in[1]) ? 16'h0001 : 16'h0002;
wire [15:0] reg_incr_val    = reg_src+incr_op;
// ... unrelated original RTL lines 125-125 omitted ...
wire [15:0] reg_dest_val_in = inst_bw ? {8'h00,reg_dest_val[7:0]} : reg_dest_val;
// ... unrelated original RTL lines 127-141 omitted ...
wire [15:0] r0       = pc;
// ... unrelated original RTL lines 143-149 omitted ...
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
wire       r5_wr  = inst_dest[5] & reg_dest_wr;
// ... unrelated original RTL lines 318-319 omitted ...
`ifdef CLOCK_GATING
wire       r5_en  = r5_wr | r5_inc;
wire       mclk_r5;
omsp_clock_gate clock_gate_r5 (.gclk(mclk_r5),
                               .clk (mclk), .enable(r5_en), .scan_enable(scan_enable));
`else
wire       mclk_r5 = mclk;
`endif
// ... unrelated original RTL lines 328-328 omitted ...
always @(posedge mclk_r5 or posedge puc_rst)
  if (puc_rst)      r5  <= 16'h0000;
  else if (r5_wr)   r5  <= reg_dest_val_in;
`ifdef CLOCK_GATING
  else              r5  <= reg_incr_val;
// ... unrelated original RTL lines 334-339 omitted ...
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
wire       r14_wr  = inst_dest[14] & reg_dest_wr;
// ... unrelated original RTL lines 534-535 omitted ...
`ifdef CLOCK_GATING
wire       r14_en  = r14_wr | r14_inc;
wire       mclk_r14;
omsp_clock_gate clock_gate_r14 (.gclk(mclk_r14),
                                .clk (mclk), .enable(r14_en), .scan_enable(scan_enable));
`else
wire       mclk_r14 = mclk;
`endif
// ... unrelated original RTL lines 544-544 omitted ...
always @(posedge mclk_r14 or posedge puc_rst)
  if (puc_rst)      r14 <= 16'h0000;
  else if (r14_wr)  r14 <= reg_dest_val_in;
`ifdef CLOCK_GATING
  else              r14 <= reg_incr_val;
// ... unrelated original RTL lines 550-555 omitted ...
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

// ----------------------------------------------------------------------------
// Original source: openMSP430.v
// Module: openMSP430
// ----------------------------------------------------------------------------
output               puc_rst;                // Main system reset
// ... unrelated original RTL lines 144-182 omitted ...
wire          [11:0] inst_alu;
wire                 inst_bw;
// ... unrelated original RTL lines 185-186 omitted ...
wire          [15:0] inst_dest;
// ... unrelated original RTL lines 188-193 omitted ...
wire           [3:0] e_state;
wire                 exec_done;
// ... unrelated original RTL lines 196-197 omitted ...
wire                 cpuoff;
// ... unrelated original RTL lines 199-225 omitted ...
wire          [15:0] pc;
// ... unrelated original RTL lines 227-254 omitted ...
wire                 cpu_halt_st;
// ... unrelated original RTL lines 256-322 omitted ...
omsp_frontend frontend_0 (
// ... unrelated original RTL lines 324-325 omitted ...
    .cpu_halt_st       (cpu_halt_st),        // Halt/Run status from CPU
// ... unrelated original RTL lines 327-327 omitted ...
    .e_state           (e_state),            // Execution state
    .exec_done         (exec_done),          // Execution completed
// ... unrelated original RTL lines 330-332 omitted ...
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
// ... unrelated original RTL lines 334-350 omitted ...
    .pc                (pc),                 // Program counter
// ... unrelated original RTL lines 352-356 omitted ...
    .cpuoff            (cpuoff),             // Turns off the CPU
// ... unrelated original RTL lines 358-369 omitted ...
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 371-374 omitted ...
);
// ... unrelated original RTL lines 376-381 omitted ...
omsp_execution_unit execution_unit_0 (
// ... unrelated original RTL lines 383-384 omitted ...
    .cpuoff            (cpuoff),             // Turns off the CPU
// ... unrelated original RTL lines 386-405 omitted ...
    .inst_alu          (inst_alu),           // ALU control signals
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
    .inst_dest         (inst_dest),          // Decoded Inst: destination (one hot)
// ... unrelated original RTL lines 409-420 omitted ...
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 422-422 omitted ...
);

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
// source: openMSP430_defines.v:756-756
`define ALU_SRC_INV   0
// source: openMSP430_defines.v:762-762
`define ALU_XOR       6
// source: openMSP430_defines.v:692-692
`define CALL   5
// source: openMSP430_defines.v:728-728
`define CONST    7
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
// source: openMSP430_defines.v:734-734
`define I_EXT1      3'h3
// source: openMSP430_defines.v:736-736
`define I_IDLE      3'h5
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
