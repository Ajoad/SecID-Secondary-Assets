// ============================================================================
// Cluster-local relation RTL: openMSP430.execution_unit_0.register_file_0.r4 -> C002
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 5 RTL-proximal candidates. Members: openMSP430.dbg_0.cpu_id_hi_rd, openMSP430.dbg_0.cpu_id_lo_rd, openMSP430.dbg_0.mem_data, openMSP430.dbg_0.mem_data_rd, openMSP430.execution_unit_0.register_file_0.r15. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: omsp_dbg.v
// Module: omsp_dbg
// ----------------------------------------------------------------------------
input        [31:0] cpu_id;            // CPU ID
// ... unrelated original RTL lines 106-107 omitted ...
input               dbg_clk;           // Debug unit clock
// ... unrelated original RTL lines 109-115 omitted ...
input        [15:0] dbg_reg_din;       // Debug unit CPU register data input
input               dbg_rst;           // Debug unit reset
// ... unrelated original RTL lines 118-132 omitted ...
wire  [5:0] dbg_addr;
wire [15:0] dbg_din;
wire        dbg_wr;
reg         mem_burst;
wire        dbg_reg_rd;
// ... unrelated original RTL lines 138-138 omitted ...
reg         dbg_mem_rd_dly;
// ... unrelated original RTL lines 140-140 omitted ...
wire        dbg_rd;
reg         dbg_rd_rdy;
wire        mem_burst_rd;
// ... unrelated original RTL lines 144-146 omitted ...
wire [15:0] brk0_dout;
// ... unrelated original RTL lines 148-149 omitted ...
wire [15:0] brk1_dout;
// ... unrelated original RTL lines 151-152 omitted ...
wire [15:0] brk2_dout;
// ... unrelated original RTL lines 154-155 omitted ...
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
// ... unrelated original RTL lines 289-386 omitted ...
reg   [3:1] mem_ctl;
// ... unrelated original RTL lines 388-405 omitted ...
reg  [15:0] mem_data;
// ... unrelated original RTL lines 407-407 omitted ...
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
// ... unrelated original RTL lines 421-622 omitted ...
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
// ... unrelated original RTL lines 652-712 omitted ...
wire mem_burst_start = (mem_start             &  |mem_cnt);
wire mem_burst_end   = ((dbg_wr | dbg_rd_rdy) & ~|mem_cnt);
// ... unrelated original RTL lines 715-716 omitted ...
always @(posedge dbg_clk or posedge dbg_rst)
  if (dbg_rst)              mem_burst <= 1'b0;
  else if (mem_burst_start) mem_burst <= 1'b1;
  else if (mem_burst_end)   mem_burst <= 1'b0;
// ... unrelated original RTL lines 721-778 omitted ...
assign      dbg_reg_rd     = mem_access & ~mem_ctl[1] &  mem_ctl[2];
// ... unrelated original RTL lines 780-798 omitted ...
omsp_dbg_uart dbg_uart_0 (
// ... unrelated original RTL lines 800-801 omitted ...
    .dbg_addr         (dbg_addr),         // Debug register address
// ... unrelated original RTL lines 803-809 omitted ...
    .dbg_dout         (dbg_dout),         // Debug register data output
    .dbg_rd_rdy       (dbg_rd_rdy),       // Debug register data is ready for read
    .dbg_rst          (dbg_rst),          // Debug unit reset
// ... unrelated original RTL lines 813-818 omitted ...
);

// ----------------------------------------------------------------------------
// Original source: omsp_dbg_uart.v
// Module: omsp_dbg_uart
// ----------------------------------------------------------------------------
output        [5:0] dbg_addr;       // Debug register address
// ... unrelated original RTL lines 75-81 omitted ...
input               dbg_clk;        // Debug unit clock
input        [15:0] dbg_dout;       // Debug register data output
input               dbg_rd_rdy;     // Debug register data is ready for read
input               dbg_rst;        // Debug unit reset
// ... unrelated original RTL lines 86-144 omitted ...
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

// ----------------------------------------------------------------------------
// Original source: omsp_execution_unit.v
// Module: omsp_execution_unit
// ----------------------------------------------------------------------------
input        [15:0] inst_dest;     // Decoded Inst: destination (one hot)
// ... unrelated original RTL lines 120-131 omitted ...
input               puc_rst;       // Main system reset
// ... unrelated original RTL lines 133-145 omitted ...
wire         [15:0] reg_dest;
wire         [15:0] reg_src;
// ... unrelated original RTL lines 148-156 omitted ...
wire reg_dest_wr  = ((e_state==`E_EXEC) & (
                     (inst_type[`INST_TO] & inst_ad[`DIR] & ~inst_alu[`EXEC_NO_WR])  |
                     (inst_type[`INST_SO] & inst_as[`DIR] & ~(inst_so[`PUSH] | inst_so[`CALL] | inst_so[`RETI])) |
                      inst_type[`INST_JMP])) | dbg_reg_wr;
// ... unrelated original RTL lines 161-180 omitted ...
omsp_register_file register_file_0 (
// ... unrelated original RTL lines 182-188 omitted ...
    .reg_dest     (reg_dest),     // Selected register destination content
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
output       [15:0] reg_dest;     // Selected register destination content
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
wire       r15_wr  = inst_dest[15] & reg_dest_wr;
// ... unrelated original RTL lines 558-559 omitted ...
`ifdef CLOCK_GATING
wire       r15_en  = r15_wr | r15_inc;
wire       mclk_r15;
omsp_clock_gate clock_gate_r15 (.gclk(mclk_r15),
                                .clk (mclk), .enable(r15_en), .scan_enable(scan_enable));
`else
wire       mclk_r15 = mclk;
`endif
// ... unrelated original RTL lines 568-568 omitted ...
always @(posedge mclk_r15 or posedge puc_rst)
  if (puc_rst)      r15 <= 16'h0000;
  else if (r15_wr)  r15 <= reg_dest_val_in;
 `ifdef CLOCK_GATING
  else              r15 <= reg_incr_val;
// ... unrelated original RTL lines 574-582 omitted ...
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
// ... unrelated original RTL lines 599-599 omitted ...
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
output               puc_rst;                // Main system reset
// ... unrelated original RTL lines 144-186 omitted ...
wire          [15:0] inst_dest;
// ... unrelated original RTL lines 188-242 omitted ...
wire                 dbg_rst;
// ... unrelated original RTL lines 244-251 omitted ...
wire          [15:0] dbg_reg_din;
// ... unrelated original RTL lines 253-381 omitted ...
omsp_execution_unit execution_unit_0 (
// ... unrelated original RTL lines 383-407 omitted ...
    .inst_dest         (inst_dest),          // Decoded Inst: destination (one hot)
// ... unrelated original RTL lines 409-420 omitted ...
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 422-422 omitted ...
);
// ... unrelated original RTL lines 424-598 omitted ...
omsp_dbg dbg_0 (
// ... unrelated original RTL lines 600-625 omitted ...
    .dbg_reg_din       (dbg_reg_din),        // Debug unit CPU register data input
    .dbg_rst           (dbg_rst),            // Debug unit reset
// ... unrelated original RTL lines 628-635 omitted ...
);

// ----------------------------------------------------------------------------
// Referenced original preprocessor definitions
// ----------------------------------------------------------------------------
// source: openMSP430_defines.v:692-692
`define CALL   5
// source: openMSP430_defines.v:772-772
`define DBG_UART_ADDR 16:11
// source: openMSP430_defines.v:877-877
`define DBG_UART_XFER_CNT_W 16
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
