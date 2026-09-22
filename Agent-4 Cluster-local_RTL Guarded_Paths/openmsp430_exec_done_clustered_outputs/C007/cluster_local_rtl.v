// ============================================================================
// Cluster-local relation RTL: C007 -> openMSP430.frontend_0.exec_done
// Source-faithful OpenMSP430 RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 5 RTL-proximal candidates. Members: openMSP430.decode_noirq, openMSP430.frontend_0.decode, openMSP430.frontend_0.exec_src_wr, openMSP430.frontend_0.inst_type_nxt, openMSP430.frontend_0.irq_acc. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: omsp_frontend.v
// Module: omsp_frontend
// ----------------------------------------------------------------------------
output               cpu_halt_st;      // Halt/Run status from CPU
output               decode_noirq;     // Frontend decode instruction
output         [3:0] e_state;          // Execution state
output               exec_done;        // Execution completed
// ... unrelated original RTL lines 110-121 omitted ...
output         [2:0] inst_type;        // Decoded Instruction type
output [`IRQ_NR-3:0] irq_acc;          // Interrupt request accepted (one-hot signal)
// ... unrelated original RTL lines 124-142 omitted ...
input                gie;              // General interrupt enable
input  [`IRQ_NR-3:0] irq;              // Maskable interrupts
input                mclk;             // Main system clock
// ... unrelated original RTL lines 146-146 omitted ...
input                nmi_pnd;          // Non-maskable interrupt pending
// ... unrelated original RTL lines 148-150 omitted ...
input                puc_rst;          // Main system reset
// ... unrelated original RTL lines 152-152 omitted ...
input                wdt_irq;          // Watchdog-timer interrupt
// ... unrelated original RTL lines 154-162 omitted ...
function [63:0] one_hot64;
   input  [5:0] binary;
   begin
      one_hot64         = 64'h0000_0000_0000_0000;
      one_hot64[binary] =  1'b1;
   end
endfunction
// ... unrelated original RTL lines 170-180 omitted ...
function [7:0] one_hot8;
   input  [2:0] binary;
   begin
      one_hot8         = 8'h00;
      one_hot8[binary] = 1'b1;
   end
endfunction
// ... unrelated original RTL lines 188-208 omitted ...
parameter I_IRQ_FETCH = `I_IRQ_FETCH;
// ... unrelated original RTL lines 210-210 omitted ...
parameter I_DEC       = `I_DEC;        // New instruction ready for decode
// ... unrelated original RTL lines 212-213 omitted ...
parameter I_IDLE      = `I_IDLE;       // CPU is in IDLE mode
// ... unrelated original RTL lines 215-225 omitted ...
parameter E_SRC_RD    = `E_SRC_RD;
parameter E_SRC_WR    = `E_SRC_WR;
// ... unrelated original RTL lines 228-228 omitted ...
parameter E_DST_RD    = `E_DST_RD;
parameter E_DST_WR    = `E_DST_WR;
parameter E_EXEC      = `E_EXEC;
parameter E_JUMP      = `E_JUMP;
parameter E_IDLE      = `E_IDLE;
// ... unrelated original RTL lines 234-240 omitted ...
reg  [2:0] i_state;
// ... unrelated original RTL lines 242-245 omitted ...
wire       irq_detect;
wire [2:0] inst_type_nxt;
// ... unrelated original RTL lines 248-252 omitted ...
wire   cpu_halt_req = cpu_halt_cmd | ~cpu_en_s;
// ... unrelated original RTL lines 254-282 omitted ...
wire   decode_noirq =  ((i_state==I_DEC) &  (exec_done | (e_state==E_IDLE)));
wire   decode       =  decode_noirq | irq_detect;
// ... unrelated original RTL lines 285-308 omitted ...
assign  irq_detect = (nmi_pnd | ((|irq | wdt_irq) & gie)) & ~cpu_halt_req & ~cpu_halt_st & (exec_done | (i_state==I_IDLE));
// ... unrelated original RTL lines 310-334 omitted ...
reg  [5:0] irq_num;
// ... unrelated original RTL lines 336-348 omitted ...
wire        [63:0] irq_acc_all = one_hot64(irq_num) & {64{(i_state==I_IRQ_FETCH)}};
// ... unrelated original RTL lines 350-447 omitted ...
wire [15:0] ir  = mdb_in;
// ... unrelated original RTL lines 449-520 omitted ...
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
// ... unrelated original RTL lines 566-765 omitted ...
reg  [7:0] inst_ad_nxt;
// ... unrelated original RTL lines 767-771 omitted ...
     if (~inst_type_nxt[`INST_TO])
       inst_ad_nxt =  8'b00000000;
// ... unrelated original RTL lines 774-840 omitted ...
wire inst_branch   =  (inst_ad_nxt[`DIR] & (ir[3:0]==4'h0)) | inst_type_nxt[`INST_JMP] | inst_so_nxt[`RETI];
// ... unrelated original RTL lines 842-842 omitted ...
reg exec_jmp;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)                   exec_jmp <= 1'b0;
  else if (inst_branch & decode) exec_jmp <= 1'b1;
  else if (e_state==E_JUMP)      exec_jmp <= 1'b0;
// ... unrelated original RTL lines 848-848 omitted ...
reg exec_dst_wr;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)                exec_dst_wr <= 1'b0;
  else if (e_state==E_DST_RD) exec_dst_wr <= 1'b1;
  else if (e_state==E_DST_WR) exec_dst_wr <= 1'b0;
// ... unrelated original RTL lines 854-854 omitted ...
reg exec_src_wr;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst)                                         exec_src_wr <= 1'b0;
  else if (inst_type[`INST_SO] & (e_state==E_SRC_RD))  exec_src_wr <= 1'b1;
  else if ((e_state==E_SRC_WR) || (e_state==E_DST_WR)) exec_src_wr <= 1'b0;
// ... unrelated original RTL lines 860-922 omitted ...
wire exec_done = exec_jmp        ? (e_state==E_JUMP)   :
                 exec_dst_wr     ? (e_state==E_DST_WR) :
                 exec_src_wr     ? (e_state==E_SRC_WR) : (e_state==E_EXEC);

// ----------------------------------------------------------------------------
// Original source: omsp_watchdog.v
// Module: omsp_watchdog
// ----------------------------------------------------------------------------
output              wdt_irq;        // Watchdog-timer interrupt
// ... unrelated original RTL lines 85-86 omitted ...
output              wdtifg;         // Watchdog-timer interrupt flag
// ... unrelated original RTL lines 88-94 omitted ...
input               mclk;           // Main system clock
// ... unrelated original RTL lines 96-99 omitted ...
input               por;            // Power-on reset
// ... unrelated original RTL lines 101-105 omitted ...
input               wdtie;          // Watchdog timer interrupt enable
input               wdtifg_irq_clr; // Clear Watchdog-timer interrupt flag
input               wdtifg_sw_clr;  // Watchdog-timer interrupt flag software clear
input               wdtifg_sw_set;  // Watchdog-timer interrupt flag software set
// ... unrelated original RTL lines 110-202 omitted ...
wire       wdttmsel    = wdtctl[4];
// ... unrelated original RTL lines 204-408 omitted ...
wire       wdtifg_evt =  (wdt_evt_toggle_sync_dly ^ wdt_evt_toggle_sync) | wdtpw_error;
// ... unrelated original RTL lines 410-416 omitted ...
wire wdtifg_clr;
// ... unrelated original RTL lines 418-455 omitted ...
wire       wdtifg_set =  wdtifg_evt                  |  wdtifg_sw_set;
assign     wdtifg_clr =  (wdtifg_irq_clr & wdttmsel) |  wdtifg_sw_clr;
// ... unrelated original RTL lines 458-458 omitted ...
always @ (posedge mclk or posedge por)
  if (por)             wdtifg <=  1'b0;
  else if (wdtifg_set) wdtifg <=  1'b1;
  else if (wdtifg_clr) wdtifg <=  1'b0;
// ... unrelated original RTL lines 463-466 omitted ...
wire    wdt_irq       = wdttmsel & wdtifg & wdtie;

// ----------------------------------------------------------------------------
// Original source: openMSP430.v
// Module: openMSP430
// ----------------------------------------------------------------------------
output               puc_rst;                // Main system reset
// ... unrelated original RTL lines 144-191 omitted ...
wire           [2:0] inst_type;
// ... unrelated original RTL lines 193-194 omitted ...
wire                 exec_done;
wire                 decode_noirq;
// ... unrelated original RTL lines 197-201 omitted ...
wire                 por;
// ... unrelated original RTL lines 203-234 omitted ...
wire                 wdtifg;
wire                 wdt_irq;
// ... unrelated original RTL lines 237-322 omitted ...
omsp_frontend frontend_0 (
// ... unrelated original RTL lines 324-326 omitted ...
    .decode_noirq      (decode_noirq),       // Frontend decode instruction
// ... unrelated original RTL lines 328-328 omitted ...
    .exec_done         (exec_done),          // Execution completed
// ... unrelated original RTL lines 330-341 omitted ...
    .inst_type         (inst_type),          // Decoded Instruction type
// ... unrelated original RTL lines 343-369 omitted ...
    .puc_rst           (puc_rst),            // Main system reset
// ... unrelated original RTL lines 371-371 omitted ...
    .wdt_irq           (wdt_irq),            // Watchdog-timer interrupt
// ... unrelated original RTL lines 373-374 omitted ...
);
// ... unrelated original RTL lines 376-516 omitted ...
omsp_watchdog watchdog_0 (
// ... unrelated original RTL lines 518-520 omitted ...
    .wdt_irq           (wdt_irq),            // Watchdog-timer interrupt
// ... unrelated original RTL lines 522-523 omitted ...
    .wdtifg            (wdtifg),             // Watchdog-timer interrupt flag
// ... unrelated original RTL lines 525-535 omitted ...
    .por               (por),                // Power-on reset
// ... unrelated original RTL lines 537-545 omitted ...
);

// ----------------------------------------------------------------------------
// Referenced original preprocessor definitions
// ----------------------------------------------------------------------------
// source: openMSP430_defines.v:721-721
`define DIR      0
// source: openMSP430_defines.v:749-749
`define E_DST_RD    4'h9
// source: openMSP430_defines.v:750-750
`define E_DST_WR    4'hA
// source: openMSP430_defines.v:751-751
`define E_EXEC      4'hB
// source: openMSP430_defines.v:753-753
`define E_IDLE      4'hD
// source: openMSP430_defines.v:752-752
`define E_JUMP      4'hC
// source: openMSP430_defines.v:746-746
`define E_SRC_RD    4'h6
// source: openMSP430_defines.v:747-747
`define E_SRC_WR    4'h7
// source: openMSP430_defines.v:683-683
`define INST_JMP 1
// source: openMSP430_defines.v:682-682
`define INST_SO  0
// source: openMSP430_defines.v:684-684
`define INST_TO  2
// source: openMSP430_defines.v:673-673
`define IRQ_NR 64
// source: openMSP430_defines.v:733-733
`define I_DEC       3'h2
// source: openMSP430_defines.v:736-736
`define I_IDLE      3'h5
// source: openMSP430_defines.v:731-731
`define I_IRQ_FETCH 3'h0
// source: openMSP430_defines.v:693-693
`define RETI   6
