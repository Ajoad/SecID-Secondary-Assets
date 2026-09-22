// ============================================================================
// Cluster-local relation RTL: openMSP430.execution_unit_0.register_file_0.r4 -> C018
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 5 RTL-proximal candidates. Members: openMSP430.watchdog_0.reg_addr, openMSP430.watchdog_0.reg_dec, openMSP430.watchdog_0.reg_rd, openMSP430.watchdog_0.reg_wr, openMSP430.watchdog_0.wdtctl_wr. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: omsp_alu.v
// Module: omsp_alu
// ----------------------------------------------------------------------------
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

// ----------------------------------------------------------------------------
// Original source: omsp_execution_unit.v
// Module: omsp_execution_unit
// ----------------------------------------------------------------------------
input         [3:0] e_state;       // Execution state
// ... unrelated original RTL lines 114-115 omitted ...
input         [7:0] inst_as;       // Decoded Inst: source addressing mode
// ... unrelated original RTL lines 117-119 omitted ...
input        [15:0] inst_dext;     // Decoded Inst: destination extended instruction word
// ... unrelated original RTL lines 121-123 omitted ...
input        [15:0] inst_sext;     // Decoded Inst: source extended instruction word
// ... unrelated original RTL lines 125-126 omitted ...
input         [2:0] inst_type;     // Decoded Instruction type
// ... unrelated original RTL lines 128-144 omitted ...
wire         [15:0] op_src;
wire         [15:0] reg_dest;
wire         [15:0] reg_src;
// ... unrelated original RTL lines 148-148 omitted ...
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

// ----------------------------------------------------------------------------
// Original source: omsp_mem_backbone.v
// Module: omsp_mem_backbone
// ----------------------------------------------------------------------------
input         [15:1] dbg_mem_addr;      // Debug address for rd/wr access
// ... unrelated original RTL lines 128-128 omitted ...
input                dbg_mem_en;        // Debug unit memory enable
// ... unrelated original RTL lines 130-131 omitted ...
input         [14:0] eu_mab;            // Execution Unit Memory address bus
// ... unrelated original RTL lines 133-138 omitted ...
input         [15:1] dma_addr;          // Direct Memory Access address
// ... unrelated original RTL lines 140-148 omitted ...
wire                 ext_mem_en;
// ... unrelated original RTL lines 150-154 omitted ...
wire                 ext_per_sel;
wire                 ext_per_en;
// ... unrelated original RTL lines 157-187 omitted ...
wire [15:1] ext_mem_addr  =  dbg_mem_en ? dbg_mem_addr  :  dma_addr;
// ... unrelated original RTL lines 189-288 omitted ...
wire               eu_per_en     =  eu_mb_en & eu_per_sel;
// ... unrelated original RTL lines 290-295 omitted ...
assign             ext_per_en    =  ext_mem_en & ext_per_sel & ~eu_per_en;
// ... unrelated original RTL lines 297-300 omitted ...
wire  [`PER_MSB:0] per_addr_mux  =  ext_per_en ? ext_mem_addr[`PER_MSB+1:1] : eu_mab[`PER_MSB:0];

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
// Original source: omsp_watchdog.v
// Module: omsp_watchdog
// ----------------------------------------------------------------------------
input        [13:0] per_addr;       // Peripheral address
// ... unrelated original RTL lines 97-98 omitted ...
input         [1:0] per_we;         // Peripheral write enable (high active)
// ... unrelated original RTL lines 100-119 omitted ...
parameter              DEC_WD      =  2;
// ... unrelated original RTL lines 121-122 omitted ...
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
wire              reg_read  = ~|per_we & reg_sel;
// ... unrelated original RTL lines 149-150 omitted ...
wire [DEC_SZ-1:0] reg_wr    = reg_dec & {DEC_SZ{reg_write}};
wire [DEC_SZ-1:0] reg_rd    = reg_dec & {DEC_SZ{reg_read}};
// ... unrelated original RTL lines 153-164 omitted ...
wire       wdtctl_wr = reg_wr[WDTCTL];

// ----------------------------------------------------------------------------
// Original source: openMSP430.v
// Module: openMSP430
// ----------------------------------------------------------------------------
wire          [15:0] eu_mab;
// ... unrelated original RTL lines 215-429 omitted ...
omsp_mem_backbone mem_backbone_0 (
// ... unrelated original RTL lines 431-461 omitted ...
    .eu_mab            (eu_mab[15:1]),       // Execution Unit Memory address bus
// ... unrelated original RTL lines 463-477 omitted ...
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
// source: openMSP430_defines.v:662-662
`define PER_MSB    `PER_AWIDTH-1
// source: openMSP430_defines.v:691-691
`define PUSH   4
// source: openMSP430_defines.v:693-693
`define RETI   6
// source: openMSP430_defines.v:725-725
`define SYMB     4
