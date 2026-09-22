// ============================================================================
// Cluster-local relation RTL: C018 -> openMSP430.frontend_0.pc
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 5 RTL-proximal candidates. Members: openMSP430.execution_unit_0.alu_0.alu_out_nxt, openMSP430.execution_unit_0.alu_out, openMSP430.inst_bw, openMSP430.multiplier_0.reg_dec, openMSP430.multiplier_0.reg_rd. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
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

// ----------------------------------------------------------------------------
// Original source: omsp_execution_unit.v
// Module: omsp_execution_unit
// ----------------------------------------------------------------------------
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
// ... unrelated original RTL lines 119-123 omitted ...
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
// ... unrelated original RTL lines 315-320 omitted ...
);
// ... unrelated original RTL lines 322-378 omitted ...
reg        mab_lsb;
// ... unrelated original RTL lines 380-383 omitted ...
assign mdb_in_bw  = ~inst_bw ? mdb_in :
                     mab_lsb ? {2{mdb_in[15:8]}} : mdb_in;

// ----------------------------------------------------------------------------
// Original source: omsp_frontend.v
// Module: omsp_frontend
// ----------------------------------------------------------------------------
output               cpu_halt_st;      // Halt/Run status from CPU
output               decode_noirq;     // Frontend decode instruction
// ... unrelated original RTL lines 108-112 omitted ...
output               inst_bw;          // Decoded Inst: byte width
// ... unrelated original RTL lines 114-130 omitted ...
output        [15:0] pc;               // Program counter
output        [15:0] pc_nxt;           // Next PC value (for CALL & IRQ)
// ... unrelated original RTL lines 133-144 omitted ...
input                mclk;             // Main system clock
input         [15:0] mdb_in;           // Frontend Memory data bus input
// ... unrelated original RTL lines 147-148 omitted ...
input         [15:0] pc_sw;            // Program counter software value
input                pc_sw_wr;         // Program counter software write
input                puc_rst;          // Main system reset
input                scan_enable;      // Scan enable (active during scan shifting)
// ... unrelated original RTL lines 153-208 omitted ...
parameter I_IRQ_FETCH = `I_IRQ_FETCH;
parameter I_IRQ_DONE  = `I_IRQ_DONE;
// ... unrelated original RTL lines 211-213 omitted ...
parameter I_IDLE      = `I_IDLE;       // CPU is in IDLE mode
// ... unrelated original RTL lines 215-240 omitted ...
reg  [2:0] i_state;
reg  [2:0] i_state_nxt;
// ... unrelated original RTL lines 243-245 omitted ...
wire       irq_detect;
wire [2:0] inst_type_nxt;
// ... unrelated original RTL lines 248-252 omitted ...
wire   cpu_halt_req = cpu_halt_cmd | ~cpu_en_s;
// ... unrelated original RTL lines 254-283 omitted ...
wire   decode       =  decode_noirq | irq_detect;
// ... unrelated original RTL lines 285-288 omitted ...
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)  cpu_halt_st <= 1'b0;
  else          cpu_halt_st <= cpu_halt_req & (i_state_nxt==I_IDLE);
// ... unrelated original RTL lines 292-345 omitted ...
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
// ... unrelated original RTL lines 449-806 omitted ...
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)     inst_bw     <= 1'b0;
  else if (decode) inst_bw     <= ir[6] & ~inst_type_nxt[`INST_JMP] & ~irq_detect & ~cpu_halt_req;

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
// ... unrelated original RTL lines 68-74 omitted ...
input         [1:0] per_we;         // Peripheral write enable (high active)
// ... unrelated original RTL lines 76-90 omitted ...
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
// ... unrelated original RTL lines 113-125 omitted ...
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
// ... unrelated original RTL lines 140-142 omitted ...
wire              reg_read    = ~|per_we & reg_sel;
// ... unrelated original RTL lines 144-146 omitted ...
wire [DEC_SZ-1:0] reg_rd      = reg_dec & {DEC_SZ{reg_read}};
// ... unrelated original RTL lines 148-280 omitted ...
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
// ... unrelated original RTL lines 144-157 omitted ...
input         [15:0] dmem_dout;              // Data Memory data output
// ... unrelated original RTL lines 159-167 omitted ...
input         [15:0] per_dout;               // Peripheral data output
input         [15:0] pmem_dout;              // Program Memory data output
// ... unrelated original RTL lines 170-182 omitted ...
wire          [11:0] inst_alu;
wire                 inst_bw;
// ... unrelated original RTL lines 185-188 omitted ...
wire          [15:0] inst_sext;
// ... unrelated original RTL lines 190-214 omitted ...
wire          [15:0] eu_mdb_in;
// ... unrelated original RTL lines 216-223 omitted ...
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
// ... unrelated original RTL lines 327-332 omitted ...
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
// ... unrelated original RTL lines 334-350 omitted ...
    .pc                (pc),                 // Program counter
    .pc_nxt            (pc_nxt),             // Next PC value (for CALL & IRQ)
// ... unrelated original RTL lines 353-367 omitted ...
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
// ... unrelated original RTL lines 400-405 omitted ...
    .inst_alu          (inst_alu),           // ALU control signals
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
// ... unrelated original RTL lines 408-412 omitted ...
    .inst_sext         (inst_sext),          // Decoded Inst: source extended instruction word
// ... unrelated original RTL lines 414-417 omitted ...
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
// ... unrelated original RTL lines 569-577 omitted ...
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
// source: openMSP430_defines.v:694-694
`define IRQ    7
// source: openMSP430_defines.v:736-736
`define I_IDLE      3'h5
// source: openMSP430_defines.v:732-732
`define I_IRQ_DONE  3'h1
// source: openMSP430_defines.v:731-731
`define I_IRQ_FETCH 3'h0
// source: openMSP430_defines.v:653-653
  `define PER_SIZE          `PER_CUSTOM_SIZE
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
