// ============================================================================
// Cluster-local relation RTL: C019 -> openMSP430.frontend_0.pc
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 5 RTL-proximal candidates. Members: openMSP430.execution_unit_0.alu_0.alu_shift, openMSP430.frontend_0.irq_acc, openMSP430.frontend_0.irq_acc_all, openMSP430.inst_jmp, openMSP430.sfr_0.scan_mode. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
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
input               inst_bw;       // Decoded Inst: byte width
input         [7:0] inst_jmp;      // Decoded Inst: Conditional jump
input         [7:0] inst_so;       // Single-operand arithmetic
// ... unrelated original RTL lines 85-85 omitted ...
input        [15:0] op_src;        // Source operand
input         [3:0] status;        // R2 Status {V,N,Z,C}
// ... unrelated original RTL lines 88-152 omitted ...
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
// Original source: omsp_clock_module.v
// Module: omsp_clock_module
// ----------------------------------------------------------------------------
output              puc_rst;          // Main system reset
// ... unrelated original RTL lines 114-135 omitted ...
input               scan_mode;        // Scan mode
// ... unrelated original RTL lines 137-395 omitted ...
wire por_a;
// ... unrelated original RTL lines 397-1268 omitted ...
wire puc_noscan_n;
// ... unrelated original RTL lines 1270-1303 omitted ...
omsp_scan_mux scan_mux_puc_rst (
    .scan_mode    (scan_mode),
    .data_in_scan (por_a),
    .data_in_func (~puc_noscan_n),
    .data_out     (puc_rst)
);

// ----------------------------------------------------------------------------
// Original source: omsp_execution_unit.v
// Module: omsp_execution_unit
// ----------------------------------------------------------------------------
output              pc_sw_wr;      // Program counter software write
// ... unrelated original RTL lines 105-112 omitted ...
input         [3:0] e_state;       // Execution state
// ... unrelated original RTL lines 114-115 omitted ...
input         [7:0] inst_as;       // Decoded Inst: source addressing mode
input        [11:0] inst_alu;      // ALU control signals
input               inst_bw;       // Decoded Inst: byte width
// ... unrelated original RTL lines 119-119 omitted ...
input        [15:0] inst_dext;     // Decoded Inst: destination extended instruction word
// ... unrelated original RTL lines 121-121 omitted ...
input         [7:0] inst_jmp;      // Decoded Inst: Conditional jump
// ... unrelated original RTL lines 123-123 omitted ...
input        [15:0] inst_sext;     // Decoded Inst: source extended instruction word
input         [7:0] inst_so;       // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 126-126 omitted ...
input         [2:0] inst_type;     // Decoded Instruction type
// ... unrelated original RTL lines 128-139 omitted ...
wire         [15:0] alu_out;
// ... unrelated original RTL lines 141-144 omitted ...
wire         [15:0] op_src;
wire         [15:0] reg_dest;
wire         [15:0] reg_src;
// ... unrelated original RTL lines 148-148 omitted ...
wire         [15:0] mdb_in_val;
wire          [3:0] status;
// ... unrelated original RTL lines 151-170 omitted ...
wire reg_pc_call  = ((e_state==`E_EXEC)   & inst_so[`CALL]) |
                    ((e_state==`E_DST_WR) & inst_so[`RETI]);
// ... unrelated original RTL lines 173-180 omitted ...
omsp_register_file register_file_0 (
// ... unrelated original RTL lines 182-187 omitted ...
    .pc_sw_wr     (pc_sw_wr),     // Program counter software write
// ... unrelated original RTL lines 189-197 omitted ...
    .inst_bw      (inst_bw),      // Decoded Inst: byte width
// ... unrelated original RTL lines 199-203 omitted ...
    .reg_dest_val (alu_out),      // Selected register destination value
// ... unrelated original RTL lines 205-205 omitted ...
    .reg_pc_call  (reg_pc_call),  // Trigger PC update for a CALL instruction
// ... unrelated original RTL lines 207-212 omitted ...
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
// ... unrelated original RTL lines 257-300 omitted ...
wire exec_cycle = (e_state==`E_EXEC);
// ... unrelated original RTL lines 302-302 omitted ...
omsp_alu alu_0 (
// ... unrelated original RTL lines 304-313 omitted ...
    .inst_alu     (inst_alu),     // ALU control signals
    .inst_bw      (inst_bw),      // Decoded Inst: byte width
    .inst_jmp     (inst_jmp),     // Decoded Inst: Conditional jump
    .inst_so      (inst_so),      // Single-operand arithmetic
// ... unrelated original RTL lines 318-318 omitted ...
    .op_src       (op_src),       // Source operand
    .status       (status)        // R2 Status {V,N,Z,C}
);
// ... unrelated original RTL lines 322-392 omitted ...
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
// ... unrelated original RTL lines 114-116 omitted ...
output         [7:0] inst_jmp;         // Decoded Inst: Conditional jump
// ... unrelated original RTL lines 118-119 omitted ...
output         [7:0] inst_so;          // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 121-121 omitted ...
output         [2:0] inst_type;        // Decoded Instruction type
output [`IRQ_NR-3:0] irq_acc;          // Interrupt request accepted (one-hot signal)
// ... unrelated original RTL lines 124-130 omitted ...
output        [15:0] pc;               // Program counter
output        [15:0] pc_nxt;           // Next PC value (for CALL & IRQ)
// ... unrelated original RTL lines 133-137 omitted ...
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
input                scan_enable;      // Scan enable (active during scan shifting)
input                wdt_irq;          // Watchdog-timer interrupt
// ... unrelated original RTL lines 154-162 omitted ...
function [63:0] one_hot64;
   input  [5:0] binary;
   begin
      one_hot64         = 64'h0000_0000_0000_0000;
      one_hot64[binary] =  1'b1;
   end
endfunction
// ... unrelated original RTL lines 170-172 omitted ...
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
// ... unrelated original RTL lines 254-283 omitted ...
wire   decode       =  decode_noirq | irq_detect;
wire   fetch        = ~((i_state==I_DEC) & ~(exec_done | (e_state==E_IDLE))) & ~(e_state_nxt==E_IDLE);
// ... unrelated original RTL lines 286-308 omitted ...
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
// ... unrelated original RTL lines 566-566 omitted ...
always @(posedge mclk_decode or posedge puc_rst)
  if (puc_rst)     inst_so <= 8'h00;
`ifdef CLOCK_GATING
  else             inst_so <= inst_so_nxt;
// ... unrelated original RTL lines 571-588 omitted ...
reg   [2:0] inst_jmp_bin;
// ... unrelated original RTL lines 590-597 omitted ...
wire [7:0] inst_jmp = one_hot8(inst_jmp_bin) & {8{inst_type[`INST_JMP]}};
// ... unrelated original RTL lines 599-806 omitted ...
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
// Original source: omsp_register_file.v
// Module: omsp_register_file
// ----------------------------------------------------------------------------
output              pc_sw_wr;     // Program counter software write
// ... unrelated original RTL lines 91-100 omitted ...
input               inst_bw;      // Decoded Inst: byte width
input        [15:0] inst_dest;    // Register destination selection
// ... unrelated original RTL lines 103-106 omitted ...
input        [15:0] reg_dest_val; // Selected register destination value
input               reg_dest_wr;  // Write selected register destination
input               reg_pc_call;  // Trigger PC update for a CALL instruction
// ... unrelated original RTL lines 110-125 omitted ...
wire [15:0] reg_dest_val_in = inst_bw ? {8'h00,reg_dest_val[7:0]} : reg_dest_val;
// ... unrelated original RTL lines 127-144 omitted ...
wire        pc_sw_wr = (inst_dest[0] & reg_dest_wr) | reg_pc_call;

// ----------------------------------------------------------------------------
// Original source: omsp_scan_mux.v
// Module: omsp_scan_mux
// ----------------------------------------------------------------------------
output              data_out;      // Scan mux data output
// ... unrelated original RTL lines 60-62 omitted ...
input               data_in_scan;  // Selected data input for scan mode
input               data_in_func;  // Selected data input for functional mode
input               scan_mode;     // Scan mode
// ... unrelated original RTL lines 66-71 omitted ...
assign  data_out  =  scan_mode ? data_in_scan : data_in_func;

// ----------------------------------------------------------------------------
// Original source: omsp_sfr.v
// Module: omsp_sfr
// ----------------------------------------------------------------------------
output              nmi_pnd;      // NMI Pending
// ... unrelated original RTL lines 82-91 omitted ...
input               mclk;         // Main system clock
// ... unrelated original RTL lines 93-93 omitted ...
input               nmi_acc;      // Non-Maskable interrupt request accepted
// ... unrelated original RTL lines 95-98 omitted ...
input               puc_rst;      // Main system reset
input               scan_mode;    // Scan mode
// ... unrelated original RTL lines 101-115 omitted ...
parameter [DEC_WD-1:0] IE1         =  'h0,
                       IFG1        =  'h2,
                       CPU_ID_LO   =  'h4,
                       CPU_ID_HI   =  'h6,
                       CPU_NR      =  'h8;
// ... unrelated original RTL lines 121-157 omitted ...
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
// ... unrelated original RTL lines 178-201 omitted ...
reg        nmiifg;
// ... unrelated original RTL lines 203-354 omitted ...
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
// ... unrelated original RTL lines 96-99 omitted ...
input               por;            // Power-on reset
// ... unrelated original RTL lines 101-105 omitted ...
input               wdtie;          // Watchdog timer interrupt enable
input               wdtifg_irq_clr; // Clear Watchdog-timer interrupt flag
input               wdtifg_sw_clr;  // Watchdog-timer interrupt flag software clear
input               wdtifg_sw_set;  // Watchdog-timer interrupt flag software set
// ... unrelated original RTL lines 110-202 omitted ...
wire       wdttmsel    = wdtctl[4];
// ... unrelated original RTL lines 204-408 omitted ...
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
output               puc_rst;                // Main system reset
// ... unrelated original RTL lines 144-171 omitted ...
input                scan_mode;              // ASIC ONLY: Scan mode
// ... unrelated original RTL lines 173-182 omitted ...
wire          [11:0] inst_alu;
wire                 inst_bw;
// ... unrelated original RTL lines 185-189 omitted ...
wire           [7:0] inst_so;
// ... unrelated original RTL lines 191-191 omitted ...
wire           [2:0] inst_type;
wire           [7:0] inst_jmp;
wire           [3:0] e_state;
// ... unrelated original RTL lines 195-201 omitted ...
wire                 por;
// ... unrelated original RTL lines 203-219 omitted ...
wire          [15:0] fe_mdb_in;
// ... unrelated original RTL lines 221-223 omitted ...
wire                 pc_sw_wr;
wire          [15:0] pc_sw;
wire          [15:0] pc;
wire          [15:0] pc_nxt;
// ... unrelated original RTL lines 228-228 omitted ...
wire                 nmi_acc;
wire                 nmi_pnd;
// ... unrelated original RTL lines 231-234 omitted ...
wire                 wdtifg;
wire                 wdt_irq;
// ... unrelated original RTL lines 237-269 omitted ...
omsp_clock_module clock_module_0 (
// ... unrelated original RTL lines 271-309 omitted ...
    .scan_mode         (scan_mode),          // Scan mode
// ... unrelated original RTL lines 311-313 omitted ...
);
// ... unrelated original RTL lines 315-322 omitted ...
omsp_frontend frontend_0 (
// ... unrelated original RTL lines 324-327 omitted ...
    .e_state           (e_state),            // Execution state
// ... unrelated original RTL lines 329-331 omitted ...
    .inst_alu          (inst_alu),           // ALU control signals
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
// ... unrelated original RTL lines 334-336 omitted ...
    .inst_jmp          (inst_jmp),           // Decoded Inst: Conditional jump
// ... unrelated original RTL lines 338-339 omitted ...
    .inst_so           (inst_so),            // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 341-341 omitted ...
    .inst_type         (inst_type),          // Decoded Instruction type
// ... unrelated original RTL lines 343-350 omitted ...
    .pc                (pc),                 // Program counter
    .pc_nxt            (pc_nxt),             // Next PC value (for CALL & IRQ)
// ... unrelated original RTL lines 353-364 omitted ...
    .mdb_in            (fe_mdb_in),          // Frontend Memory data bus input
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
// ... unrelated original RTL lines 383-392 omitted ...
    .pc_sw_wr          (pc_sw_wr),           // Program counter software write
// ... unrelated original RTL lines 394-400 omitted ...
    .e_state           (e_state),            // Execution state
// ... unrelated original RTL lines 402-405 omitted ...
    .inst_alu          (inst_alu),           // ALU control signals
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
// ... unrelated original RTL lines 408-410 omitted ...
    .inst_jmp          (inst_jmp),           // Decoded Inst: Conditional jump
// ... unrelated original RTL lines 412-413 omitted ...
    .inst_so           (inst_so),            // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 415-422 omitted ...
);
// ... unrelated original RTL lines 424-484 omitted ...
omsp_sfr sfr_0 (
// ... unrelated original RTL lines 486-488 omitted ...
    .nmi_pnd           (nmi_pnd),            // NMI Pending
// ... unrelated original RTL lines 490-500 omitted ...
    .nmi_acc           (nmi_acc),            // Non-Maskable interrupt request accepted
// ... unrelated original RTL lines 502-505 omitted ...
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 507-509 omitted ...
);
// ... unrelated original RTL lines 511-516 omitted ...
omsp_watchdog watchdog_0 (
// ... unrelated original RTL lines 518-520 omitted ...
    .wdt_irq           (wdt_irq),            // Watchdog-timer interrupt
// ... unrelated original RTL lines 522-523 omitted ...
    .wdtifg            (wdtifg),             // Watchdog-timer interrupt flag
// ... unrelated original RTL lines 525-535 omitted ...
    .por               (por),                // Power-on reset
// ... unrelated original RTL lines 537-545 omitted ...
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
// source: openMSP430_defines.v:694-694
`define IRQ    7
// source: openMSP430_defines.v:673-673
`define IRQ_NR 64
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
