// ============================================================================
// Cluster-local relation RTL: openMSP430.execution_unit_0.register_file_0.r4 -> C004
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 5 RTL-proximal candidates. Members: openMSP430.dbg_mem_dout, openMSP430.dbg_reg_din, openMSP430.execution_unit_0.alu_0.op_dst_in, openMSP430.execution_unit_0.op_dst, openMSP430.mem_backbone_0.pmem_din. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: omsp_alu.v
// Module: omsp_alu
// ----------------------------------------------------------------------------
input               exec_cycle;    // Instruction execution cycle
// ... unrelated original RTL lines 81-81 omitted ...
input               inst_bw;       // Decoded Inst: byte width
// ... unrelated original RTL lines 83-84 omitted ...
input        [15:0] op_dst;        // Destination operand
// ... unrelated original RTL lines 86-157 omitted ...
wire        op_bit8_msk     = ~exec_cycle | ~inst_bw;
// ... unrelated original RTL lines 159-159 omitted ...
wire [16:0] op_dst_in       = {1'b0, {op_dst[15:8]     & {8{op_bit8_msk}}}, op_dst[7:0]};

// ----------------------------------------------------------------------------
// Original source: omsp_dbg.v
// Module: omsp_dbg
// ----------------------------------------------------------------------------
output       [15:0] dbg_mem_dout;      // Debug unit data output
output              dbg_mem_en;        // Debug unit memory enable
// ... unrelated original RTL lines 98-107 omitted ...
input               dbg_clk;           // Debug unit clock
// ... unrelated original RTL lines 109-115 omitted ...
input        [15:0] dbg_reg_din;       // Debug unit CPU register data input
input               dbg_rst;           // Debug unit reset
// ... unrelated original RTL lines 118-133 omitted ...
wire [15:0] dbg_din;
wire        dbg_wr;
// ... unrelated original RTL lines 136-136 omitted ...
wire        dbg_reg_rd;
// ... unrelated original RTL lines 138-138 omitted ...
reg         dbg_mem_rd_dly;
// ... unrelated original RTL lines 140-158 omitted ...
parameter           NR_REG       = 25;
// ... unrelated original RTL lines 160-165 omitted ...
parameter           MEM_CTL      = 6'h04;
// ... unrelated original RTL lines 167-167 omitted ...
parameter           MEM_DATA     = 6'h06;
// ... unrelated original RTL lines 169-240 omitted ...
reg  [NR_REG-1:0]  reg_dec;
// ... unrelated original RTL lines 242-282 omitted ...
wire               reg_write =  dbg_wr;
// ... unrelated original RTL lines 284-286 omitted ...
wire  [NR_REG-1:0] reg_wr    = reg_dec & {NR_REG{reg_write}};
// ... unrelated original RTL lines 288-386 omitted ...
reg   [3:1] mem_ctl;
// ... unrelated original RTL lines 388-388 omitted ...
wire        mem_ctl_wr = reg_wr[MEM_CTL];
// ... unrelated original RTL lines 390-390 omitted ...
always @ (posedge dbg_clk or posedge dbg_rst)
  if (dbg_rst)         mem_ctl <=  3'h0;
  else if (mem_ctl_wr) mem_ctl <=  dbg_din[3:1];
// ... unrelated original RTL lines 394-401 omitted ...
wire        mem_bw    = mem_ctl[3];
// ... unrelated original RTL lines 403-405 omitted ...
reg  [15:0] mem_data;
reg  [15:0] mem_addr;
wire        mem_access;
// ... unrelated original RTL lines 409-409 omitted ...
wire        mem_data_wr = reg_wr[MEM_DATA];
// ... unrelated original RTL lines 411-411 omitted ...
wire [15:0] dbg_mem_din_bw = ~mem_bw      ? dbg_mem_din                :
                              mem_addr[0] ? {8'h00, dbg_mem_din[15:8]} :
                                            {8'h00, dbg_mem_din[7:0]};
// ... unrelated original RTL lines 415-415 omitted ...
always @ (posedge dbg_clk or posedge dbg_rst)
  if (dbg_rst)             mem_data <=  16'h0000;
  else if (mem_data_wr)    mem_data <=  dbg_din;
  else if (dbg_reg_rd)     mem_data <=  dbg_reg_din;
  else if (dbg_mem_rd_dly) mem_data <=  dbg_mem_din_bw;
// ... unrelated original RTL lines 421-773 omitted ...
assign      dbg_mem_dout   = ~mem_bw      ? mem_data               :
                              mem_addr[0] ? {mem_data[7:0], 8'h00} :
                                            {8'h00, mem_data[7:0]};
// ... unrelated original RTL lines 777-778 omitted ...
assign      dbg_reg_rd     = mem_access & ~mem_ctl[1] &  mem_ctl[2];
// ... unrelated original RTL lines 780-780 omitted ...
assign      dbg_mem_en     = mem_access & ~mem_ctl[2];

// ----------------------------------------------------------------------------
// Original source: omsp_execution_unit.v
// Module: omsp_execution_unit
// ----------------------------------------------------------------------------
input               dbg_halt_st;   // Halt/Run status from CPU
input        [15:0] dbg_mem_dout;  // Debug unit data output
// ... unrelated original RTL lines 112-112 omitted ...
input         [3:0] e_state;       // Execution state
// ... unrelated original RTL lines 114-114 omitted ...
input         [7:0] inst_ad;       // Decoded Inst: destination addressing mode
input         [7:0] inst_as;       // Decoded Inst: source addressing mode
// ... unrelated original RTL lines 117-123 omitted ...
input        [15:0] inst_sext;     // Decoded Inst: source extended instruction word
input         [7:0] inst_so;       // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 126-126 omitted ...
input         [2:0] inst_type;     // Decoded Instruction type
// ... unrelated original RTL lines 128-143 omitted ...
wire         [15:0] op_dst;
// ... unrelated original RTL lines 145-145 omitted ...
wire         [15:0] reg_dest;
// ... unrelated original RTL lines 147-147 omitted ...
wire         [15:0] mdb_in_bw;
// ... unrelated original RTL lines 149-149 omitted ...
wire          [3:0] status;
// ... unrelated original RTL lines 151-180 omitted ...
omsp_register_file register_file_0 (
// ... unrelated original RTL lines 182-188 omitted ...
    .reg_dest     (reg_dest),     // Selected register destination content
// ... unrelated original RTL lines 190-212 omitted ...
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
// ... unrelated original RTL lines 304-317 omitted ...
    .op_dst       (op_dst),       // Destination operand
// ... unrelated original RTL lines 319-320 omitted ...
);

// ----------------------------------------------------------------------------
// Original source: omsp_frontend.v
// Module: omsp_frontend
// ----------------------------------------------------------------------------
output               cpu_halt_st;      // Halt/Run status from CPU
// ... unrelated original RTL lines 107-144 omitted ...
input                mclk;             // Main system clock
// ... unrelated original RTL lines 146-150 omitted ...
input                puc_rst;          // Main system reset
// ... unrelated original RTL lines 152-213 omitted ...
parameter I_IDLE      = `I_IDLE;       // CPU is in IDLE mode
// ... unrelated original RTL lines 215-241 omitted ...
reg  [2:0] i_state_nxt;
// ... unrelated original RTL lines 243-252 omitted ...
wire   cpu_halt_req = cpu_halt_cmd | ~cpu_en_s;
// ... unrelated original RTL lines 254-288 omitted ...
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)  cpu_halt_st <= 1'b0;
  else          cpu_halt_st <= cpu_halt_req & (i_state_nxt==I_IDLE);

// ----------------------------------------------------------------------------
// Original source: omsp_mem_backbone.v
// Module: omsp_mem_backbone
// ----------------------------------------------------------------------------
output        [15:0] pmem_din;          // Program Memory data input (optional)
// ... unrelated original RTL lines 121-127 omitted ...
input         [15:0] dbg_mem_dout;      // Debug unit data output
input                dbg_mem_en;        // Debug unit memory enable
// ... unrelated original RTL lines 130-139 omitted ...
input         [15:0] dma_din;           // Direct Memory Access data input
// ... unrelated original RTL lines 141-188 omitted ...
wire [15:0] ext_mem_dout  =  dbg_mem_en ? dbg_mem_dout  :  dma_din;

// ----------------------------------------------------------------------------
// Original source: omsp_register_file.v
// Module: omsp_register_file
// ----------------------------------------------------------------------------
output       [15:0] reg_dest;     // Selected register destination content
// ... unrelated original RTL lines 92-101 omitted ...
input        [15:0] inst_dest;    // Register destination selection
// ... unrelated original RTL lines 103-141 omitted ...
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
// ... unrelated original RTL lines 557-599 omitted ...
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
// Original source: openMSP430.v
// Module: openMSP430
// ----------------------------------------------------------------------------
output        [15:0] pmem_din;               // Program Memory data input (optional)
// ... unrelated original RTL lines 142-142 omitted ...
output               puc_rst;                // Main system reset
// ... unrelated original RTL lines 144-161 omitted ...
input         [15:0] dma_din;                // Direct Memory Access data input
// ... unrelated original RTL lines 163-188 omitted ...
wire          [15:0] inst_sext;
// ... unrelated original RTL lines 190-242 omitted ...
wire                 dbg_rst;
// ... unrelated original RTL lines 244-245 omitted ...
wire                 dbg_mem_en;
// ... unrelated original RTL lines 247-249 omitted ...
wire          [15:0] dbg_mem_dout;
// ... unrelated original RTL lines 251-251 omitted ...
wire          [15:0] dbg_reg_din;
// ... unrelated original RTL lines 253-254 omitted ...
wire                 cpu_halt_st;
// ... unrelated original RTL lines 256-322 omitted ...
omsp_frontend frontend_0 (
// ... unrelated original RTL lines 324-325 omitted ...
    .cpu_halt_st       (cpu_halt_st),        // Halt/Run status from CPU
// ... unrelated original RTL lines 327-369 omitted ...
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 371-374 omitted ...
);
// ... unrelated original RTL lines 376-381 omitted ...
omsp_execution_unit execution_unit_0 (
// ... unrelated original RTL lines 383-385 omitted ...
    .dbg_reg_din       (dbg_reg_din),        // Debug unit CPU register data input
// ... unrelated original RTL lines 387-397 omitted ...
    .dbg_halt_st       (cpu_halt_st),        // Halt/Run status from CPU
    .dbg_mem_dout      (dbg_mem_dout),       // Debug unit data output
// ... unrelated original RTL lines 400-412 omitted ...
    .inst_sext         (inst_sext),          // Decoded Inst: source extended instruction word
// ... unrelated original RTL lines 414-422 omitted ...
);
// ... unrelated original RTL lines 424-429 omitted ...
omsp_mem_backbone mem_backbone_0 (
// ... unrelated original RTL lines 431-450 omitted ...
    .pmem_din          (pmem_din),           // Program Memory data input (optional)
// ... unrelated original RTL lines 452-457 omitted ...
    .dbg_mem_dout      (dbg_mem_dout),       // Debug unit data output
    .dbg_mem_en        (dbg_mem_en),         // Debug unit memory enable
// ... unrelated original RTL lines 460-469 omitted ...
    .dma_din           (dma_din),            // Direct Memory Access data input
// ... unrelated original RTL lines 471-477 omitted ...
);
// ... unrelated original RTL lines 479-598 omitted ...
omsp_dbg dbg_0 (
// ... unrelated original RTL lines 600-606 omitted ...
    .dbg_mem_dout      (dbg_mem_dout),       // Debug unit data output
    .dbg_mem_en        (dbg_mem_en),         // Debug unit memory enable
// ... unrelated original RTL lines 609-625 omitted ...
    .dbg_reg_din       (dbg_reg_din),        // Debug unit CPU register data input
    .dbg_rst           (dbg_rst),            // Debug unit reset
// ... unrelated original RTL lines 628-635 omitted ...
);

// ----------------------------------------------------------------------------
// Referenced original preprocessor definitions
// ----------------------------------------------------------------------------
// source: openMSP430_defines.v:727-727
`define ABS      6
// source: openMSP430_defines.v:692-692
`define CALL   5
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
// source: openMSP430_defines.v:723-723
`define INDIR    2
// source: openMSP430_defines.v:724-724
`define INDIR_I  3
// source: openMSP430_defines.v:683-683
`define INST_JMP 1
// source: openMSP430_defines.v:682-682
`define INST_SO  0
// source: openMSP430_defines.v:736-736
`define I_IDLE      3'h5
// source: openMSP430_defines.v:691-691
`define PUSH   4
// source: openMSP430_defines.v:693-693
`define RETI   6
// source: openMSP430_defines.v:725-725
`define SYMB     4
