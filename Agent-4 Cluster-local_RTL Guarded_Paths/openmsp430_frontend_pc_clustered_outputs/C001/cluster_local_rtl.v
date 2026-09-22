// ============================================================================
// Cluster-local relation RTL: C001 -> openMSP430.frontend_0.pc
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 5 RTL-proximal candidates. Members: openMSP430.cpu_en_s, openMSP430.execution_unit_0.alu_0.UNUSED_inst_so_reti, openMSP430.frontend_0.inst_type_nxt, openMSP430.frontend_0.sconst_nxt, openMSP430.inst_type. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
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
// ... unrelated original RTL lines 86-157 omitted ...
wire        op_bit8_msk     = ~exec_cycle | ~inst_bw;
// ... unrelated original RTL lines 159-159 omitted ...
wire [16:0] op_dst_in       = {1'b0, {op_dst[15:8]     & {8{op_bit8_msk}}}, op_dst[7:0]};
// ... unrelated original RTL lines 161-169 omitted ...
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
// ... unrelated original RTL lines 227-258 omitted ...
wire    UNUSED_inst_so_reti = inst_so[`RETI];

// ----------------------------------------------------------------------------
// Original source: omsp_execution_unit.v
// Module: omsp_execution_unit
// ----------------------------------------------------------------------------
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
input        [15:0] inst_dest;     // Decoded Inst: destination (one hot)
// ... unrelated original RTL lines 120-123 omitted ...
input        [15:0] inst_sext;     // Decoded Inst: source extended instruction word
input         [7:0] inst_so;       // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 126-126 omitted ...
input         [2:0] inst_type;     // Decoded Instruction type
// ... unrelated original RTL lines 128-139 omitted ...
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
// ... unrelated original RTL lines 161-170 omitted ...
wire reg_pc_call  = ((e_state==`E_EXEC)   & inst_so[`CALL]) |
                    ((e_state==`E_DST_WR) & inst_so[`RETI]);
// ... unrelated original RTL lines 173-180 omitted ...
omsp_register_file register_file_0 (
// ... unrelated original RTL lines 182-187 omitted ...
    .pc_sw_wr     (pc_sw_wr),     // Program counter software write
// ... unrelated original RTL lines 189-197 omitted ...
    .inst_bw      (inst_bw),      // Decoded Inst: byte width
    .inst_dest    (inst_dest),    // Register destination selection
// ... unrelated original RTL lines 200-203 omitted ...
    .reg_dest_val (alu_out),      // Selected register destination value
    .reg_dest_wr  (reg_dest_wr),  // Write selected register destination
    .reg_pc_call  (reg_pc_call),  // Trigger PC update for a CALL instruction
// ... unrelated original RTL lines 207-212 omitted ...
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
// ... unrelated original RTL lines 295-300 omitted ...
wire exec_cycle = (e_state==`E_EXEC);
// ... unrelated original RTL lines 302-302 omitted ...
omsp_alu alu_0 (
// ... unrelated original RTL lines 304-313 omitted ...
    .inst_alu     (inst_alu),     // ALU control signals
// ... unrelated original RTL lines 315-316 omitted ...
    .inst_so      (inst_so),      // Single-operand arithmetic
// ... unrelated original RTL lines 318-320 omitted ...
);
// ... unrelated original RTL lines 322-335 omitted ...
                        ((e_state==`E_DST_WR) & ~inst_so[`RETI])      |
                         (e_state==`E_SRC_WR);
// ... unrelated original RTL lines 338-392 omitted ...
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
output         [7:0] inst_ad;          // Decoded Inst: destination addressing mode
output         [7:0] inst_as;          // Decoded Inst: source addressing mode
// ... unrelated original RTL lines 112-112 omitted ...
output               inst_bw;          // Decoded Inst: byte width
output        [15:0] inst_dest;        // Decoded Inst: destination (one hot)
// ... unrelated original RTL lines 115-118 omitted ...
output        [15:0] inst_sext;        // Decoded Inst: source extended instruction word
output         [7:0] inst_so;          // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 121-121 omitted ...
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
wire       is_const;
reg [15:0] sconst_nxt;
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
// ... unrelated original RTL lines 347-362 omitted ...
                  ~((cpuoff | ~cpu_en_s) &          //      - the CPUOFF flag, cpu_en command, instruction
                   (i_state==I_IDLE) &              //        and execution state machines are all two
                   (e_state==E_IDLE));              //        not idle.
// ... unrelated original RTL lines 366-410 omitted ...
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
// ... unrelated original RTL lines 449-459 omitted ...
wire [15:0] ext_nxt  = ir + ext_incr;
// ... unrelated original RTL lines 461-468 omitted ...
wire       mclk_inst_sext;
// ... unrelated original RTL lines 470-475 omitted ...
always @(posedge mclk_inst_sext or posedge puc_rst)
  if (puc_rst)                                 inst_sext <= 16'h0000;
  else if (decode & is_const)                  inst_sext <= sconst_nxt;
  else if (decode & inst_type_nxt[`INST_JMP])  inst_sext <= {{5{ir[9]}},ir[9:0],1'b0};
`ifdef CLOCK_GATING
  else                                         inst_sext <= ext_nxt;
// ... unrelated original RTL lines 482-520 omitted ...
wire       mclk_decode;
// ... unrelated original RTL lines 522-537 omitted ...
assign     inst_type_nxt = {(ir[15:14]!=2'b00),
                            (ir[15:13]==3'b001),
                            (ir[15:13]==3'b000)} & {3{~irq_detect}};
// ... unrelated original RTL lines 541-541 omitted ...
always @(posedge mclk_decode or posedge puc_rst)
  if (puc_rst)      inst_type <= 3'b000;
`ifdef CLOCK_GATING
  else              inst_type <= inst_type_nxt;
// ... unrelated original RTL lines 546-564 omitted ...
wire  [7:0] inst_so_nxt = irq_detect ? 8'h80 : (one_hot8(ir[9:7]) & {8{inst_type_nxt[`INST_SO]}});
// ... unrelated original RTL lines 566-566 omitted ...
always @(posedge mclk_decode or posedge puc_rst)
  if (puc_rst)     inst_so <= 8'h00;
`ifdef CLOCK_GATING
  else             inst_so <= inst_so_nxt;
// ... unrelated original RTL lines 571-636 omitted ...
reg [3:0] inst_dest_bin;
// ... unrelated original RTL lines 638-645 omitted ...
wire  [15:0] inst_dest = cpu_halt_st          ? one_hot16(dbg_reg_sel) :
                         inst_type[`INST_JMP] ? 16'h0001               :
                         inst_so[`IRQ]  |
                         inst_so[`PUSH] |
                         inst_so[`CALL]       ? 16'h0002               :
                                                one_hot16(inst_dest_bin);
// ... unrelated original RTL lines 652-688 omitted ...
reg [12:0] inst_as_nxt;
// ... unrelated original RTL lines 690-694 omitted ...
     if (inst_type_nxt[`INST_JMP])
       inst_as_nxt =  13'b0000000000001;
// ... unrelated original RTL lines 697-728 omitted ...
always @(posedge mclk_decode or posedge puc_rst)
  if (puc_rst)     inst_as <= 8'h00;
`ifdef CLOCK_GATING
  else             inst_as <= {is_const, inst_as_nxt[6:0]};
// ... unrelated original RTL lines 733-745 omitted ...
     if (inst_as_nxt[7])        sconst_nxt = 16'h0004;
// ... unrelated original RTL lines 747-765 omitted ...
reg  [7:0] inst_ad_nxt;
// ... unrelated original RTL lines 767-771 omitted ...
     if (~inst_type_nxt[`INST_TO])
       inst_ad_nxt =  8'b00000000;
// ... unrelated original RTL lines 774-791 omitted ...
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
// Original source: openMSP430.v
// Module: openMSP430
// ----------------------------------------------------------------------------
output               puc_rst;                // Main system reset
// ... unrelated original RTL lines 144-180 omitted ...
wire           [7:0] inst_ad;
wire           [7:0] inst_as;
wire          [11:0] inst_alu;
wire                 inst_bw;
// ... unrelated original RTL lines 185-186 omitted ...
wire          [15:0] inst_dest;
// ... unrelated original RTL lines 188-188 omitted ...
wire          [15:0] inst_sext;
wire           [7:0] inst_so;
// ... unrelated original RTL lines 191-191 omitted ...
wire           [2:0] inst_type;
// ... unrelated original RTL lines 193-193 omitted ...
wire           [3:0] e_state;
// ... unrelated original RTL lines 195-196 omitted ...
wire                 cpu_en_s;
wire                 cpuoff;
// ... unrelated original RTL lines 199-219 omitted ...
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
// ... unrelated original RTL lines 256-322 omitted ...
omsp_frontend frontend_0 (
// ... unrelated original RTL lines 324-325 omitted ...
    .cpu_halt_st       (cpu_halt_st),        // Halt/Run status from CPU
// ... unrelated original RTL lines 327-327 omitted ...
    .e_state           (e_state),            // Execution state
// ... unrelated original RTL lines 329-329 omitted ...
    .inst_ad           (inst_ad),            // Decoded Inst: destination addressing mode
    .inst_as           (inst_as),            // Decoded Inst: source addressing mode
// ... unrelated original RTL lines 332-332 omitted ...
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
    .inst_dest         (inst_dest),          // Decoded Inst: destination (one hot)
// ... unrelated original RTL lines 335-338 omitted ...
    .inst_sext         (inst_sext),          // Decoded Inst: source extended instruction word
    .inst_so           (inst_so),            // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 341-341 omitted ...
    .inst_type         (inst_type),          // Decoded Instruction type
// ... unrelated original RTL lines 343-350 omitted ...
    .pc                (pc),                 // Program counter
    .pc_nxt            (pc_nxt),             // Next PC value (for CALL & IRQ)
// ... unrelated original RTL lines 353-354 omitted ...
    .cpu_en_s          (cpu_en_s),           // Enable CPU code execution (synchronous)
// ... unrelated original RTL lines 356-356 omitted ...
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
// ... unrelated original RTL lines 394-397 omitted ...
    .dbg_halt_st       (cpu_halt_st),        // Halt/Run status from CPU
    .dbg_mem_dout      (dbg_mem_dout),       // Debug unit data output
// ... unrelated original RTL lines 400-400 omitted ...
    .e_state           (e_state),            // Execution state
// ... unrelated original RTL lines 402-404 omitted ...
    .inst_as           (inst_as),            // Decoded Inst: source addressing mode
    .inst_alu          (inst_alu),           // ALU control signals
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
    .inst_dest         (inst_dest),          // Decoded Inst: destination (one hot)
// ... unrelated original RTL lines 409-412 omitted ...
    .inst_sext         (inst_sext),          // Decoded Inst: source extended instruction word
    .inst_so           (inst_so),            // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 415-415 omitted ...
    .inst_type         (inst_type),          // Decoded Instruction type
// ... unrelated original RTL lines 417-422 omitted ...
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
