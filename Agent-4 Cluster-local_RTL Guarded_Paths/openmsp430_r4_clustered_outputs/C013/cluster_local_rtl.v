// ============================================================================
// Cluster-local relation RTL: openMSP430.execution_unit_0.register_file_0.r4 -> C013
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 5 RTL-proximal candidates. Members: openMSP430.execution_unit_0.register_file_0.r1, openMSP430.execution_unit_0.register_file_0.r10, openMSP430.execution_unit_0.register_file_0.r11, openMSP430.execution_unit_0.register_file_0.r12, openMSP430.execution_unit_0.register_file_0.reg_incr_val. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: omsp_execution_unit.v
// Module: omsp_execution_unit
// ----------------------------------------------------------------------------
input         [3:0] e_state;       // Execution state
// ... unrelated original RTL lines 114-115 omitted ...
input         [7:0] inst_as;       // Decoded Inst: source addressing mode
// ... unrelated original RTL lines 117-118 omitted ...
input        [15:0] inst_dest;     // Decoded Inst: destination (one hot)
// ... unrelated original RTL lines 120-120 omitted ...
input               inst_irq_rst;  // Decoded Inst: reset interrupt
// ... unrelated original RTL lines 122-124 omitted ...
input         [7:0] inst_so;       // Decoded Inst: Single-operand arithmetic
input        [15:0] inst_src;      // Decoded Inst: source (one hot)
// ... unrelated original RTL lines 127-131 omitted ...
input               puc_rst;       // Main system reset
// ... unrelated original RTL lines 133-140 omitted ...
wire         [15:0] alu_out_add;
// ... unrelated original RTL lines 142-146 omitted ...
wire         [15:0] reg_src;
// ... unrelated original RTL lines 148-156 omitted ...
wire reg_dest_wr  = ((e_state==`E_EXEC) & (
                     (inst_type[`INST_TO] & inst_ad[`DIR] & ~inst_alu[`EXEC_NO_WR])  |
                     (inst_type[`INST_SO] & inst_as[`DIR] & ~(inst_so[`PUSH] | inst_so[`CALL] | inst_so[`RETI])) |
                      inst_type[`INST_JMP])) | dbg_reg_wr;
// ... unrelated original RTL lines 161-161 omitted ...
wire reg_sp_wr    = (((e_state==`E_IRQ_1) | (e_state==`E_IRQ_3)) & ~inst_irq_rst) |
                     ((e_state==`E_DST_RD) & ((inst_so[`PUSH] | inst_so[`CALL]) &  ~inst_as[`IDX] & ~((inst_as[`INDIR] | inst_as[`INDIR_I]) & inst_src[1]))) |
                     ((e_state==`E_SRC_AD) & ((inst_so[`PUSH] | inst_so[`CALL]) &  inst_as[`IDX])) |
                     ((e_state==`E_SRC_RD) & ((inst_so[`PUSH] | inst_so[`CALL]) &  ((inst_as[`INDIR] | inst_as[`INDIR_I]) & inst_src[1])));
// ... unrelated original RTL lines 166-180 omitted ...
omsp_register_file register_file_0 (
// ... unrelated original RTL lines 182-189 omitted ...
    .reg_src      (reg_src),      // Selected register source content
// ... unrelated original RTL lines 191-198 omitted ...
    .inst_dest    (inst_dest),    // Register destination selection
// ... unrelated original RTL lines 200-202 omitted ...
    .puc_rst      (puc_rst),      // Main system reset
// ... unrelated original RTL lines 204-204 omitted ...
    .reg_dest_wr  (reg_dest_wr),  // Write selected register destination
// ... unrelated original RTL lines 206-206 omitted ...
    .reg_sp_val   (alu_out_add),  // Stack Pointer next value
    .reg_sp_wr    (reg_sp_wr),    // Stack Pointer write
// ... unrelated original RTL lines 209-212 omitted ...
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
// ... unrelated original RTL lines 109-109 omitted ...
input        [15:0] reg_sp_val;   // Stack Pointer next value
input               reg_sp_wr;    // Stack Pointer write
// ... unrelated original RTL lines 112-114 omitted ...
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
wire       r1_wr  = inst_dest[1] & reg_dest_wr;
// ... unrelated original RTL lines 152-153 omitted ...
`ifdef CLOCK_GATING
wire       r1_en  = r1_wr | reg_sp_wr | r1_inc;
wire       mclk_r1;
omsp_clock_gate clock_gate_r1 (.gclk(mclk_r1),
                               .clk (mclk), .enable(r1_en), .scan_enable(scan_enable));
`else
// ... unrelated original RTL lines 160-160 omitted ...
wire       mclk_r1            = mclk;
`endif
// ... unrelated original RTL lines 163-163 omitted ...
always @(posedge mclk_r1 or posedge puc_rst)
  if (puc_rst)        r1 <= 16'h0000;
  else if (r1_wr)     r1 <= reg_dest_val_in & 16'hfffe;
  else if (reg_sp_wr) r1 <= reg_sp_val      & 16'hfffe;
`ifdef CLOCK_GATING
  else                r1 <= reg_incr_val    & 16'hfffe;
// ... unrelated original RTL lines 170-178 omitted ...
reg  [15:0] r2;
// ... unrelated original RTL lines 180-264 omitted ...
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
wire       r10_wr  = inst_dest[10] & reg_dest_wr;
// ... unrelated original RTL lines 438-439 omitted ...
`ifdef CLOCK_GATING
wire       r10_en  = r10_wr | r10_inc;
wire       mclk_r10;
omsp_clock_gate clock_gate_r10 (.gclk(mclk_r10),
                                .clk (mclk), .enable(r10_en), .scan_enable(scan_enable));
`else
wire       mclk_r10 = mclk;
`endif
// ... unrelated original RTL lines 448-448 omitted ...
always @(posedge mclk_r10 or posedge puc_rst)
  if (puc_rst)      r10 <= 16'h0000;
  else if (r10_wr)  r10 <= reg_dest_val_in;
`ifdef CLOCK_GATING
  else              r10 <= reg_incr_val;
// ... unrelated original RTL lines 454-459 omitted ...
reg [15:0] r11;
wire       r11_wr  = inst_dest[11] & reg_dest_wr;
// ... unrelated original RTL lines 462-463 omitted ...
`ifdef CLOCK_GATING
wire       r11_en  = r11_wr | r11_inc;
wire       mclk_r11;
omsp_clock_gate clock_gate_r11 (.gclk(mclk_r11),
                                .clk (mclk), .enable(r11_en), .scan_enable(scan_enable));
`else
wire       mclk_r11 = mclk;
`endif
// ... unrelated original RTL lines 472-472 omitted ...
always @(posedge mclk_r11 or posedge puc_rst)
  if (puc_rst)      r11 <= 16'h0000;
  else if (r11_wr)  r11 <= reg_dest_val_in;
`ifdef CLOCK_GATING
  else              r11 <= reg_incr_val;
// ... unrelated original RTL lines 478-483 omitted ...
reg [15:0] r12;
wire       r12_wr  = inst_dest[12] & reg_dest_wr;
// ... unrelated original RTL lines 486-487 omitted ...
`ifdef CLOCK_GATING
wire       r12_en  = r12_wr | r12_inc;
wire       mclk_r12;
omsp_clock_gate clock_gate_r12 (.gclk(mclk_r12),
                                .clk (mclk), .enable(r12_en), .scan_enable(scan_enable));
`else
wire       mclk_r12 = mclk;
`endif
// ... unrelated original RTL lines 496-496 omitted ...
always @(posedge mclk_r12 or posedge puc_rst)
  if (puc_rst)      r12 <= 16'h0000;
  else if (r12_wr)  r12 <= reg_dest_val_in;
`ifdef CLOCK_GATING
  else              r12 <= reg_incr_val;
// ... unrelated original RTL lines 502-507 omitted ...
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
// source: openMSP430_defines.v:749-749
`define E_DST_RD    4'h9
// source: openMSP430_defines.v:751-751
`define E_EXEC      4'hB
// source: openMSP430_defines.v:741-741
`define E_IRQ_1     4'h1
// source: openMSP430_defines.v:743-743
`define E_IRQ_3     4'h3
// source: openMSP430_defines.v:745-745
`define E_SRC_AD    4'h5
// source: openMSP430_defines.v:746-746
`define E_SRC_RD    4'h6
// source: openMSP430_defines.v:722-722
`define IDX      1
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
// source: openMSP430_defines.v:691-691
`define PUSH   4
// source: openMSP430_defines.v:693-693
`define RETI   6
