// ============================================================================
// Cluster-local relation RTL: C017 -> openMSP430.frontend_0.pc
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 5 RTL-proximal candidates. Members: openMSP430.execution_unit_0.alu_0.alu_dadd0, openMSP430.execution_unit_0.alu_0.op_src_inv_cmd, openMSP430.frontend_0.alu_src_inv, openMSP430.frontend_0.inst_alu_nxt, openMSP430.inst_alu. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: omsp_alu.v
// Module: omsp_alu
// ----------------------------------------------------------------------------
output        [3:0] alu_stat;      // ALU Status {V,N,Z,C}
output        [3:0] alu_stat_wr;   // ALU Status write {V,N,Z,C}
// ... unrelated original RTL lines 76-78 omitted ...
input               dbg_halt_st;   // Halt/Run status from CPU
input               exec_cycle;    // Instruction execution cycle
input        [11:0] inst_alu;      // ALU control signals
// ... unrelated original RTL lines 82-83 omitted ...
input         [7:0] inst_so;       // Single-operand arithmetic
// ... unrelated original RTL lines 85-85 omitted ...
input        [15:0] op_src;        // Source operand
input         [3:0] status;        // R2 Status {V,N,Z,C}
// ... unrelated original RTL lines 88-93 omitted ...
function [4:0] bcd_add;

   input [3:0] X;
   input [3:0] Y;
   input       C_;

   reg   [4:0] Z_;
   begin
      Z_ = {1'b0,X}+{1'b0,Y}+{4'b0000,C_};
      if (Z_<5'd10) bcd_add = Z_;
      else          bcd_add = Z_+5'd6;
   end

endfunction
// ... unrelated original RTL lines 108-152 omitted ...
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
// ... unrelated original RTL lines 227-235 omitted ...
wire    V_xor       = inst_bw ? (op_src_in[7]  & op_dst_in[7])  :
                                (op_src_in[15] & op_dst_in[15]);
// ... unrelated original RTL lines 238-238 omitted ...
wire    V           = inst_bw ? ((~op_src_in[7]  & ~op_dst_in[7]  &  alu_out[7])  |
                                 ( op_src_in[7]  &  op_dst_in[7]  & ~alu_out[7])) :
                                ((~op_src_in[15] & ~op_dst_in[15] &  alu_out[15]) |
                                 ( op_src_in[15] &  op_dst_in[15] & ~alu_out[15]));
// ... unrelated original RTL lines 243-243 omitted ...
wire    N           = inst_bw ?  alu_out[7]       : alu_out[15];
wire    Z           = inst_bw ? (alu_out[7:0]==0) : (alu_out==0);
wire    C           = inst_bw ?  alu_out[8]       : alu_out_nxt[16];
// ... unrelated original RTL lines 247-247 omitted ...
assign  alu_stat    = inst_alu[`ALU_SHIFT]  ? {1'b0, N,Z,op_src_in[0]} :
                      inst_alu[`ALU_STAT_7] ? {1'b0, N,Z,~Z}           :
                      inst_alu[`ALU_XOR]    ? {V_xor,N,Z,~Z}           : {V,N,Z,C};
// ... unrelated original RTL lines 251-251 omitted ...
assign  alu_stat_wr = (inst_alu[`ALU_STAT_F] & exec_cycle) ? 4'b1111 : 4'b0000;

// ----------------------------------------------------------------------------
// Original source: omsp_execution_unit.v
// Module: omsp_execution_unit
// ----------------------------------------------------------------------------
output              mb_en;         // Memory bus enable
// ... unrelated original RTL lines 100-103 omitted ...
output              pc_sw_wr;      // Program counter software write
// ... unrelated original RTL lines 105-111 omitted ...
input               dbg_reg_wr;    // Debug unit CPU register write
input         [3:0] e_state;       // Execution state
// ... unrelated original RTL lines 114-114 omitted ...
input         [7:0] inst_ad;       // Decoded Inst: destination addressing mode
input         [7:0] inst_as;       // Decoded Inst: source addressing mode
input        [11:0] inst_alu;      // ALU control signals
input               inst_bw;       // Decoded Inst: byte width
// ... unrelated original RTL lines 119-124 omitted ...
input         [7:0] inst_so;       // Decoded Inst: Single-operand arithmetic
// ... unrelated original RTL lines 126-126 omitted ...
input         [2:0] inst_type;     // Decoded Instruction type
// ... unrelated original RTL lines 128-131 omitted ...
input               puc_rst;       // Main system reset
// ... unrelated original RTL lines 133-139 omitted ...
wire         [15:0] alu_out;
// ... unrelated original RTL lines 141-141 omitted ...
wire          [3:0] alu_stat;
wire          [3:0] alu_stat_wr;
// ... unrelated original RTL lines 144-149 omitted ...
wire          [3:0] status;
// ... unrelated original RTL lines 151-156 omitted ...
wire reg_dest_wr  = ((e_state==`E_EXEC) & (
                     (inst_type[`INST_TO] & inst_ad[`DIR] & ~inst_alu[`EXEC_NO_WR])  |
                     (inst_type[`INST_SO] & inst_as[`DIR] & ~(inst_so[`PUSH] | inst_so[`CALL] | inst_so[`RETI])) |
                      inst_type[`INST_JMP])) | dbg_reg_wr;
// ... unrelated original RTL lines 161-168 omitted ...
wire reg_sr_clr   =  (e_state==`E_IRQ_2);
// ... unrelated original RTL lines 170-170 omitted ...
wire reg_pc_call  = ((e_state==`E_EXEC)   & inst_so[`CALL]) |
                    ((e_state==`E_DST_WR) & inst_so[`RETI]);
// ... unrelated original RTL lines 173-180 omitted ...
omsp_register_file register_file_0 (
// ... unrelated original RTL lines 182-187 omitted ...
    .pc_sw_wr     (pc_sw_wr),     // Program counter software write
// ... unrelated original RTL lines 189-195 omitted ...
    .alu_stat     (alu_stat),     // ALU Status {V,N,Z,C}
    .alu_stat_wr  (alu_stat_wr),  // ALU Status write {V,N,Z,C}
    .inst_bw      (inst_bw),      // Decoded Inst: byte width
// ... unrelated original RTL lines 199-202 omitted ...
    .puc_rst      (puc_rst),      // Main system reset
    .reg_dest_val (alu_out),      // Selected register destination value
    .reg_dest_wr  (reg_dest_wr),  // Write selected register destination
    .reg_pc_call  (reg_pc_call),  // Trigger PC update for a CALL instruction
// ... unrelated original RTL lines 207-208 omitted ...
    .reg_sr_clr   (reg_sr_clr),   // Status register clear for interrupts
// ... unrelated original RTL lines 210-212 omitted ...
);
// ... unrelated original RTL lines 214-300 omitted ...
wire exec_cycle = (e_state==`E_EXEC);
// ... unrelated original RTL lines 302-302 omitted ...
omsp_alu alu_0 (
// ... unrelated original RTL lines 304-307 omitted ...
    .alu_stat     (alu_stat),     // ALU Status {V,N,Z,C}
    .alu_stat_wr  (alu_stat_wr),  // ALU Status write {V,N,Z,C}
// ... unrelated original RTL lines 310-312 omitted ...
    .exec_cycle   (exec_cycle),   // Instruction execution cycle
    .inst_alu     (inst_alu),     // ALU control signals
// ... unrelated original RTL lines 315-319 omitted ...
    .status       (status)        // R2 Status {V,N,Z,C}
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
// ... unrelated original RTL lines 344-357 omitted ...
                                (e_state==`E_IRQ_0) | (e_state==`E_IRQ_2));

// ----------------------------------------------------------------------------
// Original source: omsp_frontend.v
// Module: omsp_frontend
// ----------------------------------------------------------------------------
output               decode_noirq;     // Frontend decode instruction
// ... unrelated original RTL lines 108-111 omitted ...
output        [11:0] inst_alu;         // ALU control signals
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
// ... unrelated original RTL lines 153-171 omitted ...
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
// ... unrelated original RTL lines 211-240 omitted ...
reg  [2:0] i_state;
// ... unrelated original RTL lines 242-245 omitted ...
wire       irq_detect;
wire [2:0] inst_type_nxt;
// ... unrelated original RTL lines 248-252 omitted ...
wire   cpu_halt_req = cpu_halt_cmd | ~cpu_en_s;
// ... unrelated original RTL lines 254-283 omitted ...
wire   decode       =  decode_noirq | irq_detect;
// ... unrelated original RTL lines 285-345 omitted ...
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
// ... unrelated original RTL lines 566-618 omitted ...
wire [15:0] inst_to_1hot = one_hot16(ir[15:12]) & {16{inst_type_nxt[`INST_TO]}};
wire [11:0] inst_to_nxt  = inst_to_1hot[15:4];
// ... unrelated original RTL lines 621-806 omitted ...
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)     inst_bw     <= 1'b0;
  else if (decode) inst_bw     <= ir[6] & ~inst_type_nxt[`INST_JMP] & ~irq_detect & ~cpu_halt_req;
// ... unrelated original RTL lines 810-950 omitted ...
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
// ... unrelated original RTL lines 91-98 omitted ...
input         [3:0] alu_stat;     // ALU Status {V,N,Z,C}
input         [3:0] alu_stat_wr;  // ALU Status write {V,N,Z,C}
input               inst_bw;      // Decoded Inst: byte width
input        [15:0] inst_dest;    // Register destination selection
// ... unrelated original RTL lines 103-105 omitted ...
input               puc_rst;      // Main system reset
input        [15:0] reg_dest_val; // Selected register destination value
input               reg_dest_wr;  // Write selected register destination
input               reg_pc_call;  // Trigger PC update for a CALL instruction
// ... unrelated original RTL lines 110-112 omitted ...
input               reg_sr_clr;   // Status register clear for interrupts
// ... unrelated original RTL lines 114-125 omitted ...
wire [15:0] reg_dest_val_in = inst_bw ? {8'h00,reg_dest_val[7:0]} : reg_dest_val;
// ... unrelated original RTL lines 127-144 omitted ...
wire        pc_sw_wr = (inst_dest[0] & reg_dest_wr) | reg_pc_call;
// ... unrelated original RTL lines 146-178 omitted ...
reg  [15:0] r2;
// ... unrelated original RTL lines 180-182 omitted ...
wire        r2_c   = alu_stat_wr[0] ? alu_stat[0]          : reg_dest_val_in[0]; // C
// ... unrelated original RTL lines 184-184 omitted ...
wire        r2_z   = alu_stat_wr[1] ? alu_stat[1]          : reg_dest_val_in[1]; // Z
// ... unrelated original RTL lines 186-186 omitted ...
wire        r2_n   = alu_stat_wr[2] ? alu_stat[2]          : reg_dest_val_in[2]; // N
// ... unrelated original RTL lines 188-188 omitted ...
wire  [7:3] r2_nxt = r2_wr          ? reg_dest_val_in[7:3] : r2[7:3];
// ... unrelated original RTL lines 190-190 omitted ...
wire        r2_v   = alu_stat_wr[3] ? alu_stat[3]          : reg_dest_val_in[8]; // V
// ... unrelated original RTL lines 192-193 omitted ...
wire        mclk_r2;
// ... unrelated original RTL lines 195-244 omitted ...
   wire [15:0] r2_mask     = cpuoff_mask | oscoff_mask | scg0_mask | scg1_mask | 16'h010f;
// ... unrelated original RTL lines 246-246 omitted ...
always @(posedge mclk_r2 or posedge puc_rst)
  if (puc_rst)         r2 <= 16'h0000;
  else if (reg_sr_clr) r2 <= 16'h0000;
  else                 r2 <= {7'h00, r2_v, r2_nxt, r2_n, r2_z, r2_c} & r2_mask;

// ----------------------------------------------------------------------------
// Original source: openMSP430.v
// Module: openMSP430
// ----------------------------------------------------------------------------
output               puc_rst;                // Main system reset
// ... unrelated original RTL lines 144-182 omitted ...
wire          [11:0] inst_alu;
wire                 inst_bw;
// ... unrelated original RTL lines 185-193 omitted ...
wire           [3:0] e_state;
// ... unrelated original RTL lines 195-223 omitted ...
wire                 pc_sw_wr;
wire          [15:0] pc_sw;
wire          [15:0] pc;
wire          [15:0] pc_nxt;
// ... unrelated original RTL lines 228-322 omitted ...
omsp_frontend frontend_0 (
// ... unrelated original RTL lines 324-331 omitted ...
    .inst_alu          (inst_alu),           // ALU control signals
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
// ... unrelated original RTL lines 394-400 omitted ...
    .e_state           (e_state),            // Execution state
// ... unrelated original RTL lines 402-405 omitted ...
    .inst_alu          (inst_alu),           // ALU control signals
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
// ... unrelated original RTL lines 408-420 omitted ...
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 422-422 omitted ...
);

// ----------------------------------------------------------------------------
// Referenced original preprocessor definitions
// ----------------------------------------------------------------------------
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
// source: openMSP430_defines.v:764-764
`define ALU_STAT_7    8
// source: openMSP430_defines.v:765-765
`define ALU_STAT_F    9
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
// source: openMSP430_defines.v:713-713
`define DADD   6
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
// source: openMSP430_defines.v:746-746
`define E_SRC_RD    4'h6
// source: openMSP430_defines.v:747-747
`define E_SRC_WR    4'h7
// source: openMSP430_defines.v:726-726
`define IMM      5
// source: openMSP430_defines.v:683-683
`define INST_JMP 1
// source: openMSP430_defines.v:682-682
`define INST_SO  0
// source: openMSP430_defines.v:684-684
`define INST_TO  2
// source: openMSP430_defines.v:694-694
`define IRQ    7
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
// source: openMSP430_defines.v:717-717
`define XOR   10
