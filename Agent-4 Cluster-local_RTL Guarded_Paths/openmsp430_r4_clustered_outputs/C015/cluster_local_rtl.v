// ============================================================================
// Cluster-local relation RTL: openMSP430.execution_unit_0.register_file_0.r4 -> C015
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 4 RTL-proximal candidates. Members: openMSP430.execution_unit_0.register_file_0.r6, openMSP430.execution_unit_0.register_file_0.r7, openMSP430.execution_unit_0.register_file_0.r8, openMSP430.execution_unit_0.register_file_0.r9. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: omsp_execution_unit.v
// Module: omsp_execution_unit
// ----------------------------------------------------------------------------
input        [15:0] inst_dest;     // Decoded Inst: destination (one hot)
// ... unrelated original RTL lines 120-131 omitted ...
input               puc_rst;       // Main system reset
// ... unrelated original RTL lines 133-146 omitted ...
wire         [15:0] reg_src;
// ... unrelated original RTL lines 148-156 omitted ...
wire reg_dest_wr  = ((e_state==`E_EXEC) & (
                     (inst_type[`INST_TO] & inst_ad[`DIR] & ~inst_alu[`EXEC_NO_WR])  |
                     (inst_type[`INST_SO] & inst_as[`DIR] & ~(inst_so[`PUSH] | inst_so[`CALL] | inst_so[`RETI])) |
                      inst_type[`INST_JMP])) | dbg_reg_wr;
// ... unrelated original RTL lines 161-180 omitted ...
omsp_register_file register_file_0 (
// ... unrelated original RTL lines 182-189 omitted ...
    .reg_src      (reg_src),      // Selected register source content
// ... unrelated original RTL lines 191-198 omitted ...
    .inst_dest    (inst_dest),    // Register destination selection
// ... unrelated original RTL lines 200-202 omitted ...
    .puc_rst      (puc_rst),      // Main system reset
// ... unrelated original RTL lines 204-204 omitted ...
    .reg_dest_wr  (reg_dest_wr),  // Write selected register destination
// ... unrelated original RTL lines 206-212 omitted ...
);

// ----------------------------------------------------------------------------
// Original source: omsp_register_file.v
// Module: omsp_register_file
// ----------------------------------------------------------------------------
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
// ... unrelated original RTL lines 109-114 omitted ...
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
// ... unrelated original RTL lines 180-264 omitted ...
reg [15:0] r3;
// ... unrelated original RTL lines 266-291 omitted ...
reg [15:0] r4;
// ... unrelated original RTL lines 293-315 omitted ...
reg [15:0] r5;
// ... unrelated original RTL lines 317-339 omitted ...
reg [15:0] r6;
wire       r6_wr  = inst_dest[6] & reg_dest_wr;
// ... unrelated original RTL lines 342-343 omitted ...
`ifdef CLOCK_GATING
wire       r6_en  = r6_wr | r6_inc;
wire       mclk_r6;
omsp_clock_gate clock_gate_r6 (.gclk(mclk_r6),
                               .clk (mclk), .enable(r6_en), .scan_enable(scan_enable));
`else
wire       mclk_r6 = mclk;
`endif
// ... unrelated original RTL lines 352-352 omitted ...
always @(posedge mclk_r6 or posedge puc_rst)
  if (puc_rst)      r6  <= 16'h0000;
  else if (r6_wr)   r6  <= reg_dest_val_in;
`ifdef CLOCK_GATING
  else              r6  <= reg_incr_val;
// ... unrelated original RTL lines 358-363 omitted ...
reg [15:0] r7;
wire       r7_wr  = inst_dest[7] & reg_dest_wr;
// ... unrelated original RTL lines 366-367 omitted ...
`ifdef CLOCK_GATING
wire       r7_en  = r7_wr | r7_inc;
wire       mclk_r7;
omsp_clock_gate clock_gate_r7 (.gclk(mclk_r7),
                               .clk (mclk), .enable(r7_en), .scan_enable(scan_enable));
`else
wire       mclk_r7 = mclk;
`endif
// ... unrelated original RTL lines 376-376 omitted ...
always @(posedge mclk_r7 or posedge puc_rst)
  if (puc_rst)      r7  <= 16'h0000;
  else if (r7_wr)   r7  <= reg_dest_val_in;
`ifdef CLOCK_GATING
  else              r7  <= reg_incr_val;
// ... unrelated original RTL lines 382-387 omitted ...
reg [15:0] r8;
wire       r8_wr  = inst_dest[8] & reg_dest_wr;
// ... unrelated original RTL lines 390-391 omitted ...
`ifdef CLOCK_GATING
wire       r8_en  = r8_wr | r8_inc;
wire       mclk_r8;
omsp_clock_gate clock_gate_r8 (.gclk(mclk_r8),
                               .clk (mclk), .enable(r8_en), .scan_enable(scan_enable));
`else
wire       mclk_r8 = mclk;
`endif
// ... unrelated original RTL lines 400-400 omitted ...
always @(posedge mclk_r8 or posedge puc_rst)
  if (puc_rst)      r8  <= 16'h0000;
  else if (r8_wr)   r8  <= reg_dest_val_in;
`ifdef CLOCK_GATING
  else              r8  <= reg_incr_val;
// ... unrelated original RTL lines 406-411 omitted ...
reg [15:0] r9;
wire       r9_wr  = inst_dest[9] & reg_dest_wr;
// ... unrelated original RTL lines 414-415 omitted ...
`ifdef CLOCK_GATING
wire       r9_en  = r9_wr | r9_inc;
wire       mclk_r9;
omsp_clock_gate clock_gate_r9 (.gclk(mclk_r9),
                               .clk (mclk), .enable(r9_en), .scan_enable(scan_enable));
`else
wire       mclk_r9 = mclk;
`endif
// ... unrelated original RTL lines 424-424 omitted ...
always @(posedge mclk_r9 or posedge puc_rst)
  if (puc_rst)      r9  <= 16'h0000;
  else if (r9_wr)   r9  <= reg_dest_val_in;
`ifdef CLOCK_GATING
  else              r9  <= reg_incr_val;
// ... unrelated original RTL lines 430-435 omitted ...
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

// ----------------------------------------------------------------------------
// Original source: openMSP430.v
// Module: openMSP430
// ----------------------------------------------------------------------------
output               puc_rst;                // Main system reset
// ... unrelated original RTL lines 144-186 omitted ...
wire          [15:0] inst_dest;
// ... unrelated original RTL lines 188-381 omitted ...
omsp_execution_unit execution_unit_0 (
// ... unrelated original RTL lines 383-407 omitted ...
    .inst_dest         (inst_dest),          // Decoded Inst: destination (one hot)
// ... unrelated original RTL lines 409-420 omitted ...
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 422-422 omitted ...
);

// ----------------------------------------------------------------------------
// Referenced original preprocessor definitions
// ----------------------------------------------------------------------------
// source: openMSP430_defines.v:692-692
`define CALL   5
// source: openMSP430_defines.v:721-721
`define DIR      0
// source: openMSP430_defines.v:767-767
`define EXEC_NO_WR   11
// source: openMSP430_defines.v:751-751
`define E_EXEC      4'hB
// source: openMSP430_defines.v:683-683
`define INST_JMP 1
// source: openMSP430_defines.v:682-682
`define INST_SO  0
// source: openMSP430_defines.v:684-684
`define INST_TO  2
// source: openMSP430_defines.v:691-691
`define PUSH   4
// source: openMSP430_defines.v:693-693
`define RETI   6
