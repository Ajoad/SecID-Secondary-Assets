// ============================================================================
// Cluster-local relation RTL: openMSP430.execution_unit_0.register_file_0.r4 -> C009
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 5 RTL-proximal candidates. Members: openMSP430.execution_unit_0.alu_0.alu_and, openMSP430.execution_unit_0.alu_0.alu_or, openMSP430.execution_unit_0.mab_lsb, openMSP430.execution_unit_0.mdb_in_buf, openMSP430.execution_unit_0.mdb_in_bw. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: omsp_alu.v
// Module: omsp_alu
// ----------------------------------------------------------------------------
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

// ----------------------------------------------------------------------------
// Original source: omsp_execution_unit.v
// Module: omsp_execution_unit
// ----------------------------------------------------------------------------
output              mb_en;         // Memory bus enable
// ... unrelated original RTL lines 100-112 omitted ...
input         [3:0] e_state;       // Execution state
// ... unrelated original RTL lines 114-115 omitted ...
input         [7:0] inst_as;       // Decoded Inst: source addressing mode
input        [11:0] inst_alu;      // ALU control signals
input               inst_bw;       // Decoded Inst: byte width
// ... unrelated original RTL lines 119-119 omitted ...
input        [15:0] inst_dext;     // Decoded Inst: destination extended instruction word
// ... unrelated original RTL lines 121-122 omitted ...
input               inst_mov;      // Decoded Inst: mov instruction
input        [15:0] inst_sext;     // Decoded Inst: source extended instruction word
input         [7:0] inst_so;       // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 126-126 omitted ...
input         [2:0] inst_type;     // Decoded Instruction type
input               mclk;          // Main system clock
input        [15:0] mdb_in;        // Memory data bus input
// ... unrelated original RTL lines 130-131 omitted ...
input               puc_rst;       // Main system reset
input               scan_enable;   // Scan enable (active during scan shifting)
// ... unrelated original RTL lines 134-140 omitted ...
wire         [15:0] alu_out_add;
// ... unrelated original RTL lines 142-144 omitted ...
wire         [15:0] op_src;
wire         [15:0] reg_dest;
wire         [15:0] reg_src;
wire         [15:0] mdb_in_bw;
wire         [15:0] mdb_in_val;
// ... unrelated original RTL lines 150-180 omitted ...
omsp_register_file register_file_0 (
// ... unrelated original RTL lines 182-189 omitted ...
    .reg_src      (reg_src),      // Selected register source content
// ... unrelated original RTL lines 191-212 omitted ...
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
// ... unrelated original RTL lines 304-318 omitted ...
    .op_src       (op_src),       // Source operand
// ... unrelated original RTL lines 320-320 omitted ...
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
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)    mab_lsb <= 1'b0;
  else if (mb_en) mab_lsb <= alu_out_add[0];
// ... unrelated original RTL lines 383-383 omitted ...
assign mdb_in_bw  = ~inst_bw ? mdb_in :
                     mab_lsb ? {2{mdb_in[15:8]}} : mdb_in;
// ... unrelated original RTL lines 386-387 omitted ...
reg         mdb_in_buf_en;
// ... unrelated original RTL lines 389-398 omitted ...
reg  [15:0] mdb_in_buf;
// ... unrelated original RTL lines 400-400 omitted ...
`ifdef CLOCK_GATING
wire        mclk_mdb_in_buf;
omsp_clock_gate clock_gate_mdb_in_buf (.gclk(mclk_mdb_in_buf),
                                       .clk (mclk), .enable(mdb_in_buf_en), .scan_enable(scan_enable));
`else
wire        mclk_mdb_in_buf = mclk;
`endif
// ... unrelated original RTL lines 408-408 omitted ...
always @(posedge mclk_mdb_in_buf or posedge puc_rst)
  if (puc_rst)            mdb_in_buf <= 16'h0000;
`ifdef CLOCK_GATING
  else                    mdb_in_buf <= mdb_in_bw;

// ----------------------------------------------------------------------------
// Original source: omsp_frontend.v
// Module: omsp_frontend
// ----------------------------------------------------------------------------
output               decode_noirq;     // Frontend decode instruction
// ... unrelated original RTL lines 108-112 omitted ...
output               inst_bw;          // Decoded Inst: byte width
// ... unrelated original RTL lines 114-144 omitted ...
input                mclk;             // Main system clock
// ... unrelated original RTL lines 146-150 omitted ...
input                puc_rst;          // Main system reset
// ... unrelated original RTL lines 152-245 omitted ...
wire       irq_detect;
wire [2:0] inst_type_nxt;
// ... unrelated original RTL lines 248-252 omitted ...
wire   cpu_halt_req = cpu_halt_cmd | ~cpu_en_s;
// ... unrelated original RTL lines 254-283 omitted ...
wire   decode       =  decode_noirq | irq_detect;
// ... unrelated original RTL lines 285-447 omitted ...
wire [15:0] ir  = mdb_in;
// ... unrelated original RTL lines 449-806 omitted ...
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)     inst_bw     <= 1'b0;
  else if (decode) inst_bw     <= ir[6] & ~inst_type_nxt[`INST_JMP] & ~irq_detect & ~cpu_halt_req;

// ----------------------------------------------------------------------------
// Original source: omsp_register_file.v
// Module: omsp_register_file
// ----------------------------------------------------------------------------
output       [15:0] reg_src;      // Selected register source content
// ... unrelated original RTL lines 93-121 omitted ...
wire [15:0] inst_src_in;
// ... unrelated original RTL lines 123-141 omitted ...
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

// ----------------------------------------------------------------------------
// Original source: openMSP430.v
// Module: openMSP430
// ----------------------------------------------------------------------------
output               puc_rst;                // Main system reset
// ... unrelated original RTL lines 144-183 omitted ...
wire                 inst_bw;
// ... unrelated original RTL lines 185-214 omitted ...
wire          [15:0] eu_mdb_in;
// ... unrelated original RTL lines 216-217 omitted ...
wire                 eu_mb_en;
// ... unrelated original RTL lines 219-322 omitted ...
omsp_frontend frontend_0 (
// ... unrelated original RTL lines 324-332 omitted ...
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
// ... unrelated original RTL lines 334-369 omitted ...
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 371-374 omitted ...
);
// ... unrelated original RTL lines 376-381 omitted ...
omsp_execution_unit execution_unit_0 (
// ... unrelated original RTL lines 383-387 omitted ...
    .mb_en             (eu_mb_en),           // Memory bus enable
// ... unrelated original RTL lines 389-406 omitted ...
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
// ... unrelated original RTL lines 408-417 omitted ...
    .mdb_in            (eu_mdb_in),          // Memory data bus input
// ... unrelated original RTL lines 419-420 omitted ...
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 422-422 omitted ...
);

// ----------------------------------------------------------------------------
// Referenced original preprocessor definitions
// ----------------------------------------------------------------------------
// source: openMSP430_defines.v:727-727
`define ABS      6
// source: openMSP430_defines.v:756-756
`define ALU_SRC_INV   0
// source: openMSP430_defines.v:692-692
`define CALL   5
// source: openMSP430_defines.v:728-728
`define CONST    7
// source: openMSP430_defines.v:721-721
`define DIR      0
// source: openMSP430_defines.v:767-767
`define EXEC_NO_WR   11
// source: openMSP430_defines.v:749-749
`define E_DST_RD    4'h9
// source: openMSP430_defines.v:750-750
`define E_DST_WR    4'hA
// source: openMSP430_defines.v:751-751
`define E_EXEC      4'hB
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
// source: openMSP430_defines.v:725-725
`define SYMB     4
