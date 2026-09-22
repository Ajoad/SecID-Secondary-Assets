// ============================================================================
// Cluster-local relation RTL: C005 -> openMSP430.frontend_0.pc
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 5 RTL-proximal candidates. Members: openMSP430.dbg_0.cpu_ctl_rd, openMSP430.dbg_0.mem_bw, openMSP430.dbg_0.mem_ctl, openMSP430.dbg_0.mem_data, openMSP430.dbg_0.mem_data_wr. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
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
// Original source: omsp_dbg.v
// Module: omsp_dbg
// ----------------------------------------------------------------------------
output              dbg_halt_cmd;      // Halt CPU command
// ... unrelated original RTL lines 94-95 omitted ...
output       [15:0] dbg_mem_dout;      // Debug unit data output
// ... unrelated original RTL lines 97-98 omitted ...
output              dbg_reg_wr;        // Debug unit CPU register write
// ... unrelated original RTL lines 100-107 omitted ...
input               dbg_clk;           // Debug unit clock
input               dbg_en_s;          // Debug interface enable (synchronous)
input               dbg_halt_st;       // Halt/Run status from CPU
// ... unrelated original RTL lines 111-115 omitted ...
input        [15:0] dbg_reg_din;       // Debug unit CPU register data input
input               dbg_rst;           // Debug unit reset
// ... unrelated original RTL lines 118-118 omitted ...
input               decode_noirq;      // Frontend decode instruction
// ... unrelated original RTL lines 120-122 omitted ...
input        [15:0] fe_mdb_in;         // Frontend Memory data bus input
// ... unrelated original RTL lines 124-124 omitted ...
input               puc_pnd_set;       // PUC pending set for the serial debug interface
// ... unrelated original RTL lines 126-132 omitted ...
wire  [5:0] dbg_addr;
wire [15:0] dbg_din;
wire        dbg_wr;
reg         mem_burst;
wire        dbg_reg_rd;
// ... unrelated original RTL lines 138-138 omitted ...
reg         dbg_mem_rd_dly;
wire        dbg_swbrk;
wire        dbg_rd;
reg         dbg_rd_rdy;
wire        mem_burst_rd;
// ... unrelated original RTL lines 144-144 omitted ...
wire        brk0_halt;
// ... unrelated original RTL lines 146-146 omitted ...
wire [15:0] brk0_dout;
wire        brk1_halt;
// ... unrelated original RTL lines 149-149 omitted ...
wire [15:0] brk1_dout;
wire        brk2_halt;
// ... unrelated original RTL lines 152-152 omitted ...
wire [15:0] brk2_dout;
wire        brk3_halt;
// ... unrelated original RTL lines 155-155 omitted ...
wire [15:0] brk3_dout;
// ... unrelated original RTL lines 157-158 omitted ...
parameter           NR_REG       = 25;
// ... unrelated original RTL lines 160-161 omitted ...
parameter           CPU_ID_LO    = 6'h00;
parameter           CPU_ID_HI    = 6'h01;
parameter           CPU_CTL      = 6'h02;
parameter           CPU_STAT     = 6'h03;
parameter           MEM_CTL      = 6'h04;
parameter           MEM_ADDR     = 6'h05;
parameter           MEM_DATA     = 6'h06;
parameter           MEM_CNT      = 6'h07;
// ... unrelated original RTL lines 170-170 omitted ...
parameter           BRK0_CTL     = 6'h08;
parameter           BRK0_STAT    = 6'h09;
parameter           BRK0_ADDR0   = 6'h0A;
parameter           BRK0_ADDR1   = 6'h0B;
// ... unrelated original RTL lines 175-176 omitted ...
parameter           BRK1_CTL     = 6'h0C;
parameter           BRK1_STAT    = 6'h0D;
parameter           BRK1_ADDR0   = 6'h0E;
parameter           BRK1_ADDR1   = 6'h0F;
// ... unrelated original RTL lines 181-182 omitted ...
parameter           BRK2_CTL     = 6'h10;
parameter           BRK2_STAT    = 6'h11;
parameter           BRK2_ADDR0   = 6'h12;
parameter           BRK2_ADDR1   = 6'h13;
// ... unrelated original RTL lines 187-188 omitted ...
parameter           BRK3_CTL     = 6'h14;
parameter           BRK3_STAT    = 6'h15;
parameter           BRK3_ADDR0   = 6'h16;
parameter           BRK3_ADDR1   = 6'h17;
// ... unrelated original RTL lines 193-193 omitted ...
parameter           CPU_NR       = 6'h18;
// ... unrelated original RTL lines 195-197 omitted ...
parameter           CPU_ID_LO_D  = (BASE_D << CPU_ID_LO);
parameter           CPU_ID_HI_D  = (BASE_D << CPU_ID_HI);
parameter           CPU_CTL_D    = (BASE_D << CPU_CTL);
parameter           CPU_STAT_D   = (BASE_D << CPU_STAT);
parameter           MEM_CTL_D    = (BASE_D << MEM_CTL);
parameter           MEM_ADDR_D   = (BASE_D << MEM_ADDR);
parameter           MEM_DATA_D   = (BASE_D << MEM_DATA);
parameter           MEM_CNT_D    = (BASE_D << MEM_CNT);
// ... unrelated original RTL lines 206-206 omitted ...
parameter           BRK0_CTL_D   = (BASE_D << BRK0_CTL);
parameter           BRK0_STAT_D  = (BASE_D << BRK0_STAT);
parameter           BRK0_ADDR0_D = (BASE_D << BRK0_ADDR0);
parameter           BRK0_ADDR1_D = (BASE_D << BRK0_ADDR1);
// ... unrelated original RTL lines 211-212 omitted ...
parameter           BRK1_CTL_D   = (BASE_D << BRK1_CTL);
parameter           BRK1_STAT_D  = (BASE_D << BRK1_STAT);
parameter           BRK1_ADDR0_D = (BASE_D << BRK1_ADDR0);
parameter           BRK1_ADDR1_D = (BASE_D << BRK1_ADDR1);
// ... unrelated original RTL lines 217-218 omitted ...
parameter           BRK2_CTL_D   = (BASE_D << BRK2_CTL);
parameter           BRK2_STAT_D  = (BASE_D << BRK2_STAT);
parameter           BRK2_ADDR0_D = (BASE_D << BRK2_ADDR0);
parameter           BRK2_ADDR1_D = (BASE_D << BRK2_ADDR1);
// ... unrelated original RTL lines 223-224 omitted ...
parameter           BRK3_CTL_D   = (BASE_D << BRK3_CTL);
parameter           BRK3_STAT_D  = (BASE_D << BRK3_STAT);
parameter           BRK3_ADDR0_D = (BASE_D << BRK3_ADDR0);
parameter           BRK3_ADDR1_D = (BASE_D << BRK3_ADDR1);
// ... unrelated original RTL lines 229-229 omitted ...
parameter           CPU_NR_D     = (BASE_D << CPU_NR);
// ... unrelated original RTL lines 231-237 omitted ...
wire  [5:0] dbg_addr_in = mem_burst ? MEM_DATA : dbg_addr;
// ... unrelated original RTL lines 239-240 omitted ...
reg  [NR_REG-1:0]  reg_dec;
// ... unrelated original RTL lines 242-242 omitted ...
  case (dbg_addr_in)
    CPU_ID_LO :  reg_dec  =  CPU_ID_LO_D;
    CPU_ID_HI :  reg_dec  =  CPU_ID_HI_D;
    CPU_CTL   :  reg_dec  =  CPU_CTL_D;
    CPU_STAT  :  reg_dec  =  CPU_STAT_D;
    MEM_CTL   :  reg_dec  =  MEM_CTL_D;
    MEM_ADDR  :  reg_dec  =  MEM_ADDR_D;
    MEM_DATA  :  reg_dec  =  MEM_DATA_D;
    MEM_CNT   :  reg_dec  =  MEM_CNT_D;
`ifdef DBG_HWBRK_0
    BRK0_CTL  :  reg_dec  =  BRK0_CTL_D;
    BRK0_STAT :  reg_dec  =  BRK0_STAT_D;
    BRK0_ADDR0:  reg_dec  =  BRK0_ADDR0_D;
    BRK0_ADDR1:  reg_dec  =  BRK0_ADDR1_D;
`endif
`ifdef DBG_HWBRK_1
    BRK1_CTL  :  reg_dec  =  BRK1_CTL_D;
    BRK1_STAT :  reg_dec  =  BRK1_STAT_D;
    BRK1_ADDR0:  reg_dec  =  BRK1_ADDR0_D;
    BRK1_ADDR1:  reg_dec  =  BRK1_ADDR1_D;
`endif
`ifdef DBG_HWBRK_2
    BRK2_CTL  :  reg_dec  =  BRK2_CTL_D;
    BRK2_STAT :  reg_dec  =  BRK2_STAT_D;
    BRK2_ADDR0:  reg_dec  =  BRK2_ADDR0_D;
    BRK2_ADDR1:  reg_dec  =  BRK2_ADDR1_D;
`endif
`ifdef DBG_HWBRK_3
    BRK3_CTL  :  reg_dec  =  BRK3_CTL_D;
    BRK3_STAT :  reg_dec  =  BRK3_STAT_D;
    BRK3_ADDR0:  reg_dec  =  BRK3_ADDR0_D;
    BRK3_ADDR1:  reg_dec  =  BRK3_ADDR1_D;
`endif
    CPU_NR    :  reg_dec  =  CPU_NR_D;
  // pragma coverage off
    default:     reg_dec  =  {NR_REG{1'b0}};
  // pragma coverage on
  endcase
// ... unrelated original RTL lines 281-282 omitted ...
wire               reg_write =  dbg_wr;
wire               reg_read  =  1'b1;
// ... unrelated original RTL lines 285-286 omitted ...
wire  [NR_REG-1:0] reg_wr    = reg_dec & {NR_REG{reg_write}};
wire  [NR_REG-1:0] reg_rd    = reg_dec & {NR_REG{reg_read}};
// ... unrelated original RTL lines 289-325 omitted ...
reg   [6:3] cpu_ctl;
// ... unrelated original RTL lines 327-327 omitted ...
wire        cpu_ctl_wr = reg_wr[CPU_CTL];
// ... unrelated original RTL lines 329-329 omitted ...
always @ (posedge dbg_clk or posedge dbg_rst)
`ifdef DBG_RST_BRK_EN
  if (dbg_rst)         cpu_ctl <=  4'h6;
`else
  if (dbg_rst)         cpu_ctl <=  4'h2;
`endif
  else if (cpu_ctl_wr) cpu_ctl <=  dbg_din[6:3];
// ... unrelated original RTL lines 337-337 omitted ...
wire  [7:0] cpu_ctl_full = {1'b0, cpu_ctl, 3'b000};
// ... unrelated original RTL lines 339-339 omitted ...
wire        halt_cpu = cpu_ctl_wr & dbg_din[`HALT]  & ~dbg_halt_st;
// ... unrelated original RTL lines 341-386 omitted ...
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
// ... unrelated original RTL lines 421-426 omitted ...
wire        mem_addr_wr  = reg_wr[MEM_ADDR];
// ... unrelated original RTL lines 428-430 omitted ...
wire [15:0] mem_addr_inc = (mem_cnt==16'h0000)                       ? 16'h0000 :
                           (mem_burst &  dbg_mem_acc & ~mem_bw)      ? 16'h0002 :
                           (mem_burst & (dbg_mem_acc | dbg_reg_acc)) ? 16'h0001 : 16'h0000;
// ... unrelated original RTL lines 434-434 omitted ...
always @ (posedge dbg_clk or posedge dbg_rst)
  if (dbg_rst)          mem_addr <=  16'h0000;
  else if (mem_addr_wr) mem_addr <=  dbg_din;
  else                  mem_addr <=  mem_addr + mem_addr_inc;
// ... unrelated original RTL lines 439-622 omitted ...
wire [15:0] cpu_id_lo_rd = cpu_id[15:0]           & {16{reg_rd[CPU_ID_LO]}};
wire [15:0] cpu_id_hi_rd = cpu_id[31:16]          & {16{reg_rd[CPU_ID_HI]}};
wire [15:0] cpu_ctl_rd   = {8'h00, cpu_ctl_full}  & {16{reg_rd[CPU_CTL]}};
wire [15:0] cpu_stat_rd  = {8'h00, cpu_stat_full} & {16{reg_rd[CPU_STAT]}};
wire [15:0] mem_ctl_rd   = {8'h00, mem_ctl_full}  & {16{reg_rd[MEM_CTL]}};
wire [15:0] mem_data_rd  = mem_data               & {16{reg_rd[MEM_DATA]}};
wire [15:0] mem_addr_rd  = mem_addr               & {16{reg_rd[MEM_ADDR]}};
wire [15:0] mem_cnt_rd   = mem_cnt                & {16{reg_rd[MEM_CNT]}};
wire [15:0] cpu_nr_rd    = cpu_nr                 & {16{reg_rd[CPU_NR]}};
// ... unrelated original RTL lines 632-632 omitted ...
wire [15:0] dbg_dout = cpu_id_lo_rd |
                       cpu_id_hi_rd |
                       cpu_ctl_rd   |
                       cpu_stat_rd  |
                       mem_ctl_rd   |
                       mem_data_rd  |
                       mem_addr_rd  |
                       mem_cnt_rd   |
                       brk0_dout    |
                       brk1_dout    |
                       brk2_dout    |
                       brk3_dout    |
                       cpu_nr_rd;
// ... unrelated original RTL lines 646-647 omitted ...
always @ (posedge dbg_clk or posedge dbg_rst)
  if (dbg_rst)                       dbg_rd_rdy  <=  1'b0;
  else if (mem_burst | mem_burst_rd) dbg_rd_rdy  <= (dbg_reg_rd | dbg_mem_rd_dly);
  else                               dbg_rd_rdy  <=  dbg_rd;
// ... unrelated original RTL lines 652-664 omitted ...
wire halt_rst = cpu_ctl[`RST_BRK_EN] & dbg_en_s & puc_pnd_set;
// ... unrelated original RTL lines 666-674 omitted ...
assign dbg_swbrk = (fe_mdb_in==`DBG_SWBRK_OP) & decode_noirq & cpu_ctl[`SW_BRK_EN];
// ... unrelated original RTL lines 676-679 omitted ...
reg [1:0] inc_step;
// ... unrelated original RTL lines 681-688 omitted ...
reg   halt_flag;
// ... unrelated original RTL lines 690-690 omitted ...
wire  mem_halt_cpu;
// ... unrelated original RTL lines 692-694 omitted ...
wire  halt_flag_set = halt_cpu  | halt_rst  | dbg_swbrk | mem_halt_cpu |
                      brk0_halt | brk1_halt | brk2_halt | brk3_halt;
// ... unrelated original RTL lines 697-702 omitted ...
wire dbg_halt_cmd = (halt_flag | halt_flag_set) & ~inc_step[1];
// ... unrelated original RTL lines 704-712 omitted ...
wire mem_burst_start = (mem_start             &  |mem_cnt);
wire mem_burst_end   = ((dbg_wr | dbg_rd_rdy) & ~|mem_cnt);
// ... unrelated original RTL lines 715-716 omitted ...
always @(posedge dbg_clk or posedge dbg_rst)
  if (dbg_rst)              mem_burst <= 1'b0;
  else if (mem_burst_start) mem_burst <= 1'b1;
  else if (mem_burst_end)   mem_burst <= 1'b0;
// ... unrelated original RTL lines 721-773 omitted ...
assign      dbg_mem_dout   = ~mem_bw      ? mem_data               :
                              mem_addr[0] ? {mem_data[7:0], 8'h00} :
                                            {8'h00, mem_data[7:0]};
// ... unrelated original RTL lines 777-777 omitted ...
assign      dbg_reg_wr     = mem_access &  mem_ctl[1] &  mem_ctl[2];
// ... unrelated original RTL lines 779-798 omitted ...
omsp_dbg_uart dbg_uart_0 (
// ... unrelated original RTL lines 800-801 omitted ...
    .dbg_addr         (dbg_addr),         // Debug register address
    .dbg_din          (dbg_din),          // Debug register data input
// ... unrelated original RTL lines 804-809 omitted ...
    .dbg_dout         (dbg_dout),         // Debug register data output
    .dbg_rd_rdy       (dbg_rd_rdy),       // Debug register data is ready for read
    .dbg_rst          (dbg_rst),          // Debug unit reset
// ... unrelated original RTL lines 813-813 omitted ...
    .mem_burst        (mem_burst),        // Burst on going
// ... unrelated original RTL lines 815-817 omitted ...
    .mem_bw           (mem_bw)            // Burst byte width
);

// ----------------------------------------------------------------------------
// Original source: omsp_dbg_uart.v
// Module: omsp_dbg_uart
// ----------------------------------------------------------------------------
output        [5:0] dbg_addr;       // Debug register address
output       [15:0] dbg_din;        // Debug register data input
// ... unrelated original RTL lines 76-81 omitted ...
input               dbg_clk;        // Debug unit clock
input        [15:0] dbg_dout;       // Debug register data output
input               dbg_rd_rdy;     // Debug register data is ready for read
input               dbg_rst;        // Debug unit reset
// ... unrelated original RTL lines 86-86 omitted ...
input               mem_burst;      // Burst on going
// ... unrelated original RTL lines 88-90 omitted ...
input               mem_bw;         // Burst byte width
// ... unrelated original RTL lines 92-144 omitted ...
reg   [2:0] uart_state;
// ... unrelated original RTL lines 146-148 omitted ...
wire        xfer_done;
reg  [19:0] xfer_buf;
wire [19:0] xfer_buf_nxt;
// ... unrelated original RTL lines 152-154 omitted ...
parameter  RX_CMD   = 3'h1;
// ... unrelated original RTL lines 156-191 omitted ...
wire cmd_valid = (uart_state==RX_CMD) & xfer_done;
// ... unrelated original RTL lines 193-230 omitted ...
reg                      [3:0] xfer_bit;
reg [`DBG_UART_XFER_CNT_W-1:0] xfer_cnt;
// ... unrelated original RTL lines 233-235 omitted ...
wire       xfer_bit_inc = (xfer_bit!=4'h0) & (xfer_cnt=={`DBG_UART_XFER_CNT_W{1'b0}});
// ... unrelated original RTL lines 237-255 omitted ...
always @ (posedge dbg_clk or posedge dbg_rst)
  if (dbg_rst)           xfer_buf <=  20'h00000;
  else if (dbg_rd_rdy)   xfer_buf <=  {1'b1, dbg_dout[15:8], 2'b01, dbg_dout[7:0], 1'b0};
  else if (xfer_bit_inc) xfer_buf <=  xfer_buf_nxt;
// ... unrelated original RTL lines 260-275 omitted ...
 always @ (posedge dbg_clk or posedge dbg_rst)
  if (dbg_rst)        dbg_addr <=  6'h00;
  else if (cmd_valid) dbg_addr <=  xfer_buf_nxt[`DBG_UART_ADDR];
// ... unrelated original RTL lines 279-279 omitted ...
reg       dbg_bw;
always @ (posedge dbg_clk or posedge dbg_rst)
  if (dbg_rst)        dbg_bw   <=  1'b0;
  else if (cmd_valid) dbg_bw   <=  xfer_buf_nxt[`DBG_UART_BW];
// ... unrelated original RTL lines 284-284 omitted ...
wire        dbg_din_bw =  mem_burst  ? mem_bw : dbg_bw;
// ... unrelated original RTL lines 286-286 omitted ...
wire [15:0] dbg_din    =  dbg_din_bw ? {8'h00,           xfer_buf_nxt[18:11]} :
                                       {xfer_buf_nxt[18:11], xfer_buf_nxt[9:2]};

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
// ... unrelated original RTL lines 315-320 omitted ...
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
// ... unrelated original RTL lines 110-112 omitted ...
output               inst_bw;          // Decoded Inst: byte width
output        [15:0] inst_dest;        // Decoded Inst: destination (one hot)
// ... unrelated original RTL lines 115-119 omitted ...
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
// ... unrelated original RTL lines 248-249 omitted ...
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
// ... unrelated original RTL lines 449-564 omitted ...
wire  [7:0] inst_so_nxt = irq_detect ? 8'h80 : (one_hot8(ir[9:7]) & {8{inst_type_nxt[`INST_SO]}});
// ... unrelated original RTL lines 566-636 omitted ...
reg [3:0] inst_dest_bin;
// ... unrelated original RTL lines 638-645 omitted ...
wire  [15:0] inst_dest = cpu_halt_st          ? one_hot16(dbg_reg_sel) :
                         inst_type[`INST_JMP] ? 16'h0001               :
                         inst_so[`IRQ]  |
                         inst_so[`PUSH] |
                         inst_so[`CALL]       ? 16'h0002               :
                                                one_hot16(inst_dest_bin);
// ... unrelated original RTL lines 652-806 omitted ...
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

// ----------------------------------------------------------------------------
// Original source: omsp_mem_backbone.v
// Module: omsp_mem_backbone
// ----------------------------------------------------------------------------
output               cpu_halt_cmd;      // Halt CPU command
// ... unrelated original RTL lines 103-125 omitted ...
input                dbg_halt_cmd;      // Debug interface Halt CPU command
// ... unrelated original RTL lines 127-140 omitted ...
input                dma_en;            // Direct Memory Access enable (high active)
input                dma_priority;      // Direct Memory Access priority (0:low / 1:high)
// ... unrelated original RTL lines 143-169 omitted ...
assign      cpu_halt_cmd  =  dbg_halt_cmd | (dma_en & dma_priority);

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
// ... unrelated original RTL lines 144-182 omitted ...
wire          [11:0] inst_alu;
wire                 inst_bw;
// ... unrelated original RTL lines 185-186 omitted ...
wire          [15:0] inst_dest;
// ... unrelated original RTL lines 188-193 omitted ...
wire           [3:0] e_state;
// ... unrelated original RTL lines 195-219 omitted ...
wire          [15:0] fe_mdb_in;
// ... unrelated original RTL lines 221-223 omitted ...
wire                 pc_sw_wr;
wire          [15:0] pc_sw;
wire          [15:0] pc;
wire          [15:0] pc_nxt;
// ... unrelated original RTL lines 228-242 omitted ...
wire                 dbg_rst;
// ... unrelated original RTL lines 244-244 omitted ...
wire                 dbg_halt_cmd;
// ... unrelated original RTL lines 246-246 omitted ...
wire                 dbg_reg_wr;
// ... unrelated original RTL lines 248-248 omitted ...
wire          [15:0] dbg_mem_addr;
wire          [15:0] dbg_mem_dout;
// ... unrelated original RTL lines 251-254 omitted ...
wire                 cpu_halt_st;
wire                 cpu_halt_cmd;
// ... unrelated original RTL lines 257-322 omitted ...
omsp_frontend frontend_0 (
// ... unrelated original RTL lines 324-325 omitted ...
    .cpu_halt_st       (cpu_halt_st),        // Halt/Run status from CPU
// ... unrelated original RTL lines 327-327 omitted ...
    .e_state           (e_state),            // Execution state
// ... unrelated original RTL lines 329-332 omitted ...
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
    .inst_dest         (inst_dest),          // Decoded Inst: destination (one hot)
// ... unrelated original RTL lines 335-350 omitted ...
    .pc                (pc),                 // Program counter
    .pc_nxt            (pc_nxt),             // Next PC value (for CALL & IRQ)
// ... unrelated original RTL lines 353-355 omitted ...
    .cpu_halt_cmd      (cpu_halt_cmd),       // Halt CPU command
// ... unrelated original RTL lines 357-357 omitted ...
    .dbg_reg_sel       (dbg_mem_addr[3:0]),  // Debug selected register for rd/wr access
// ... unrelated original RTL lines 359-364 omitted ...
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
    .dbg_reg_wr        (dbg_reg_wr),         // Debug unit CPU register write
    .e_state           (e_state),            // Execution state
// ... unrelated original RTL lines 402-405 omitted ...
    .inst_alu          (inst_alu),           // ALU control signals
    .inst_bw           (inst_bw),            // Decoded Inst: byte width
    .inst_dest         (inst_dest),          // Decoded Inst: destination (one hot)
// ... unrelated original RTL lines 409-422 omitted ...
);
// ... unrelated original RTL lines 424-429 omitted ...
omsp_mem_backbone mem_backbone_0 (
// ... unrelated original RTL lines 431-432 omitted ...
    .cpu_halt_cmd      (cpu_halt_cmd),       // Halt CPU command
// ... unrelated original RTL lines 434-455 omitted ...
    .dbg_halt_cmd      (dbg_halt_cmd),       // Debug interface Halt CPU command
// ... unrelated original RTL lines 457-477 omitted ...
);
// ... unrelated original RTL lines 479-598 omitted ...
omsp_dbg dbg_0 (
// ... unrelated original RTL lines 600-603 omitted ...
    .dbg_halt_cmd      (dbg_halt_cmd),       // Halt CPU command
// ... unrelated original RTL lines 605-606 omitted ...
    .dbg_mem_dout      (dbg_mem_dout),       // Debug unit data output
// ... unrelated original RTL lines 608-609 omitted ...
    .dbg_reg_wr        (dbg_reg_wr),         // Debug unit CPU register write
// ... unrelated original RTL lines 611-626 omitted ...
    .dbg_rst           (dbg_rst),            // Debug unit reset
// ... unrelated original RTL lines 628-635 omitted ...
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
// source: openMSP430_defines.v:840-840
`define DBG_SWBRK_OP 16'h4343
// source: openMSP430_defines.v:772-772
`define DBG_UART_ADDR 16:11
// source: openMSP430_defines.v:771-771
`define DBG_UART_BW   17
// source: openMSP430_defines.v:877-877
`define DBG_UART_XFER_CNT_W 16
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
// source: openMSP430_defines.v:775-775
`define HALT        0
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
// source: openMSP430_defines.v:780-780
`define RST_BRK_EN  5
// source: openMSP430_defines.v:688-688
`define SWPB   1
// source: openMSP430_defines.v:778-778
`define SW_BRK_EN   3
// source: openMSP430_defines.v:690-690
`define SXT    3
// source: openMSP430_defines.v:725-725
`define SYMB     4
