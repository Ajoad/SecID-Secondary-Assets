`timescale 1ns/1ps
module tb;
  integer scenario, timing_seed, seed_variant, mode, max_mclk, start_cycle, duration, observe_after;
  integer mcyc, dcyc, i, p, jitter, progress_tokens, debug_progress_tokens, cutset_activity_tokens, xz_count, mismatch_count;
  integer fp_enable, stimulus_fp_fd, pc_fp_fd;
  reg dco_clk=0, lfxt_clk=0;
  reg cpu_en=1, dbg_en=0, dbg_i2c_scl=1, dbg_i2c_sda_in=1, dbg_uart_rxd=1;
  reg [6:0] dbg_i2c_addr=7'h42, dbg_i2c_broadcast=7'h7f;
  reg [13:0] irq=14'h0000;
  reg [15:1] dma_addr=15'h0000; reg [15:0] dma_din=16'h0000;
  reg dma_en=0, dma_priority=0; reg [1:0] dma_we=2'b00; reg dma_wkup=0;
  reg nmi=0, reset_n=0, scan_enable=0, scan_mode=0, wkup=0;
  reg fi_en=0; reg [63:0] fi_mask=64'b0; reg [63:0] fi_forced=64'b0;
  // Centralized normal termination path. v1.1.1 does not synthesize a
  // no-difference Z01X status at end-of-test; non-detection is derived from
  // FaultInfo.Attempts > 0 with no U8/U9 observation.
  reg secid_finish_started=0;

  wire [10:0] pmem_addr_g, pmem_addr_f; wire pmem_cen_g,pmem_cen_f; wire [15:0] pmem_din_g,pmem_din_f; wire [1:0] pmem_wen_g,pmem_wen_f;
  wire [8:0] dmem_addr_g,dmem_addr_f; wire dmem_cen_g,dmem_cen_f; wire [15:0] dmem_din_g,dmem_din_f; wire [1:0] dmem_wen_g,dmem_wen_f;
  wire mclk_g,mclk_f,puc_rst_g,puc_rst_f,dbg_uart_txd_g,dbg_uart_txd_f;
  wire aclk_g,aclk_f,aclk_en_g,aclk_en_f,dbg_freeze_g,dbg_freeze_f,dbg_i2c_sda_out_g,dbg_i2c_sda_out_f;
  wire dco_enable_g,dco_enable_f,dco_wkup_g,dco_wkup_f,lfxt_enable_g,lfxt_enable_f,lfxt_wkup_g,lfxt_wkup_f;
  wire [13:0] irq_acc_g,irq_acc_f;
  wire [15:0] dma_dout_g,dma_dout_f; wire dma_ready_g,dma_ready_f,dma_resp_g,dma_resp_f,smclk_g,smclk_f,smclk_en_g,smclk_en_f;
  wire [13:0] per_addr_g,per_addr_f; wire [15:0] per_din_g,per_din_f; wire per_en_g,per_en_f; wire [1:0] per_we_g,per_we_f;
  // Match the official OpenMSP430 bench RAM timing: synchronous address capture,
  // asynchronous data from the registered address. A combinational PMEM model creates
  // a PC<->PMEM feedback loop during I_IRQ_DONE reset-vector loading.
  reg [15:0] pmem_init[0:2047];
  reg [15:0] pmem_g[0:2047]; reg [15:0] pmem_f[0:2047];
  reg [15:0] dmem_g[0:511];  reg [15:0] dmem_f[0:511];
  reg [10:0] pmem_addr_reg_g=11'h000, pmem_addr_reg_f=11'h000;
  reg [8:0]  dmem_addr_reg_g=9'h000,  dmem_addr_reg_f=9'h000;
  wire [15:0] pmem_dout_g=pmem_g[pmem_addr_reg_g], pmem_dout_f=pmem_f[pmem_addr_reg_f];
  wire [15:0] dmem_dout_g=dmem_g[dmem_addr_reg_g], dmem_dout_f=dmem_f[dmem_addr_reg_f];
  wire [15:0] per_dout_g=16'h0000, per_dout_f=16'h0000;


  always #25 dco_clk=~dco_clk;
  always #500 lfxt_clk=~lfxt_clk;

  openMSP430 dut_g(
    .mclk(mclk_g),.puc_rst(puc_rst_g),.dbg_uart_txd(dbg_uart_txd_g),
    .dmem_addr(dmem_addr_g),.dmem_cen(dmem_cen_g),.dmem_din(dmem_din_g),.dmem_wen(dmem_wen_g),
    .pmem_addr(pmem_addr_g),.pmem_cen(pmem_cen_g),.pmem_din(pmem_din_g),.pmem_wen(pmem_wen_g),
    .per_addr(per_addr_g),.per_din(per_din_g),.per_en(per_en_g),.per_we(per_we_g),
    .aclk(aclk_g),.aclk_en(aclk_en_g),.dbg_freeze(dbg_freeze_g),.dbg_i2c_sda_out(dbg_i2c_sda_out_g),.dco_enable(dco_enable_g),.dco_wkup(dco_wkup_g),.irq_acc(irq_acc_g),.lfxt_enable(lfxt_enable_g),.lfxt_wkup(lfxt_wkup_g),
    .dma_dout(dma_dout_g),.dma_ready(dma_ready_g),.dma_resp(dma_resp_g),.smclk(smclk_g),.smclk_en(smclk_en_g),
    .cpu_en(cpu_en),.dbg_en(dbg_en),.dbg_i2c_addr(dbg_i2c_addr),.dbg_i2c_broadcast(dbg_i2c_broadcast),.dbg_i2c_scl(dbg_i2c_scl),.dbg_i2c_sda_in(dbg_i2c_sda_in),.dbg_uart_rxd(dbg_uart_rxd),
    .dco_clk(dco_clk),.dmem_dout(dmem_dout_g),.irq(irq),.lfxt_clk(lfxt_clk),.dma_addr(dma_addr),.dma_din(dma_din),.dma_en(dma_en),.dma_priority(dma_priority),.dma_we(dma_we),.dma_wkup(dma_wkup),
    .nmi(nmi),.per_dout(per_dout_g),.pmem_dout(pmem_dout_g),.reset_n(reset_n),.scan_enable(scan_enable),.scan_mode(scan_mode),.wkup(wkup));
  openMSP430 dut_f(
    .mclk(mclk_f),.puc_rst(puc_rst_f),.dbg_uart_txd(dbg_uart_txd_f),
    .dmem_addr(dmem_addr_f),.dmem_cen(dmem_cen_f),.dmem_din(dmem_din_f),.dmem_wen(dmem_wen_f),
    .pmem_addr(pmem_addr_f),.pmem_cen(pmem_cen_f),.pmem_din(pmem_din_f),.pmem_wen(pmem_wen_f),
    .per_addr(per_addr_f),.per_din(per_din_f),.per_en(per_en_f),.per_we(per_we_f),
    .aclk(aclk_f),.aclk_en(aclk_en_f),.dbg_freeze(dbg_freeze_f),.dbg_i2c_sda_out(dbg_i2c_sda_out_f),.dco_enable(dco_enable_f),.dco_wkup(dco_wkup_f),.irq_acc(irq_acc_f),.lfxt_enable(lfxt_enable_f),.lfxt_wkup(lfxt_wkup_f),
    .dma_dout(dma_dout_f),.dma_ready(dma_ready_f),.dma_resp(dma_resp_f),.smclk(smclk_f),.smclk_en(smclk_en_f),
    .cpu_en(cpu_en),.dbg_en(dbg_en),.dbg_i2c_addr(dbg_i2c_addr),.dbg_i2c_broadcast(dbg_i2c_broadcast),.dbg_i2c_scl(dbg_i2c_scl),.dbg_i2c_sda_in(dbg_i2c_sda_in),.dbg_uart_rxd(dbg_uart_rxd),
    .dco_clk(dco_clk),.dmem_dout(dmem_dout_f),.irq(irq),.lfxt_clk(lfxt_clk),.dma_addr(dma_addr),.dma_din(dma_din),.dma_en(dma_en),.dma_priority(dma_priority),.dma_we(dma_we),.dma_wkup(dma_wkup),
    .nmi(nmi),.per_dout(per_dout_f),.pmem_dout(pmem_dout_f),.reset_n(reset_n),.scan_enable(scan_enable),.scan_mode(scan_mode),.wkup(wkup));

  wire [0:0] candidate_norm_g = dut_g.pc_sw_wr;
  wire [0:0] candidate_norm_f = dut_f.pc_sw_wr;
  wire [0:0] injection_norm_g = dut_g.frontend_0.pc_sw_wr;
  wire [0:0] injection_norm_f = dut_f.frontend_0.pc_sw_wr;
  wire [2:0] cutset_norm_g_0 = dut_g.frontend_0.i_state_nxt;
  wire [2:0] cutset_norm_f_0 = dut_f.frontend_0.i_state_nxt;
  wire [15:0] cutset_norm_g_1 = dut_g.frontend_0.mab;
  wire [15:0] cutset_norm_f_1 = dut_f.frontend_0.mab;
  wire [0:0] cutset_norm_g_2 = dut_g.frontend_0.mb_en;
  wire [0:0] cutset_norm_f_2 = dut_f.frontend_0.mb_en;
  reg [2:0] prev_cutset_g_0 = 3'bx;
  reg [15:0] prev_cutset_g_1 = 16'bx;
  reg [0:0] prev_cutset_g_2 = 1'bx;

  // v3.1.0 fault hook mode: GUARDED_HIERARCHICAL_FORCE_RELEASE. No RTL rewriting. Internal
  // candidates use guarded force/release. Canonical top-level input aliases use
  // a private faulted-DUT input driver so the golden DUT remains untouched.
  always @(fi_en or fi_mask[0] or injection_norm_g[0]) begin
    if (fi_en && fi_mask[0]) begin
      force dut_f.frontend_0.pc_sw_wr = ~injection_norm_g[0];
      fi_forced[0] = 1'b1;
    end else if (fi_forced[0]) begin
      release dut_f.frontend_0.pc_sw_wr;
      fi_forced[0] = 1'b0;
    end
  end

  // Independent golden/faulted memories prevent a faulty write from contaminating
  // the paired reference core. Read timing mirrors core/bench/verilog/ram.v.
  always @(posedge mclk_g) begin
    if(!pmem_cen_g) begin
      if(pmem_wen_g==2'b00) pmem_g[pmem_addr_g] <= pmem_din_g;
      else if(pmem_wen_g==2'b01) pmem_g[pmem_addr_g] <= {pmem_din_g[15:8],pmem_g[pmem_addr_g][7:0]};
      else if(pmem_wen_g==2'b10) pmem_g[pmem_addr_g] <= {pmem_g[pmem_addr_g][15:8],pmem_din_g[7:0]};
      pmem_addr_reg_g <= pmem_addr_g;
    end
    if(!dmem_cen_g) begin
      if(dmem_wen_g==2'b00) dmem_g[dmem_addr_g] <= dmem_din_g;
      else if(dmem_wen_g==2'b01) dmem_g[dmem_addr_g] <= {dmem_din_g[15:8],dmem_g[dmem_addr_g][7:0]};
      else if(dmem_wen_g==2'b10) dmem_g[dmem_addr_g] <= {dmem_g[dmem_addr_g][15:8],dmem_din_g[7:0]};
      dmem_addr_reg_g <= dmem_addr_g;
    end
  end
  always @(posedge mclk_f) begin
    if(!pmem_cen_f) begin
      if(pmem_wen_f==2'b00) pmem_f[pmem_addr_f] <= pmem_din_f;
      else if(pmem_wen_f==2'b01) pmem_f[pmem_addr_f] <= {pmem_din_f[15:8],pmem_f[pmem_addr_f][7:0]};
      else if(pmem_wen_f==2'b10) pmem_f[pmem_addr_f] <= {pmem_f[pmem_addr_f][15:8],pmem_din_f[7:0]};
      pmem_addr_reg_f <= pmem_addr_f;
    end
    if(!dmem_cen_f) begin
      if(dmem_wen_f==2'b00) dmem_f[dmem_addr_f] <= dmem_din_f;
      else if(dmem_wen_f==2'b01) dmem_f[dmem_addr_f] <= {dmem_din_f[15:8],dmem_f[dmem_addr_f][7:0]};
      else if(dmem_wen_f==2'b10) dmem_f[dmem_addr_f] <= {dmem_f[dmem_addr_f][15:8],dmem_din_f[7:0]};
      dmem_addr_reg_f <= dmem_addr_f;
    end
  end

  task uart_bit(input reg b); begin dbg_uart_rxd=b; repeat(10) @(posedge dco_clk); end endtask
  task uart_byte(input [7:0] b); integer k; begin uart_bit(1'b0); for(k=0;k<8;k=k+1) uart_bit(b[k]); uart_bit(1'b1); repeat(2) @(posedge dco_clk); end endtask
  task dbg_write_word(input [5:0] a,input [15:0] d); begin uart_byte({1'b1,1'b0,a}); uart_byte(d[7:0]); uart_byte(d[15:8]); repeat(4) @(posedge dco_clk); end endtask
  task dbg_read_word(input [5:0] a); begin uart_byte({1'b0,1'b0,a}); repeat(28) @(posedge dco_clk); end endtask

  task init_program; integer q; reg [15:0] data_base, branch_base, mem_base; begin
    // Publication-matrix seed variants: three controlled data/program variants per workload.
    // They preserve the scenario semantics while avoiding identical deterministic replays.
    seed_variant = timing_seed % 3;
    data_base   = 16'h1234 + (seed_variant * 16'h0111);
    branch_base = 16'h0100 + seed_variant;
    mem_base    = 16'h0200 + (seed_variant * 16'h0004);
    for(q=0;q<2048;q=q+1) pmem_init[q]=16'h4303;
    for(q=0;q<512;q=q+1) begin dmem_g[q]=16'h0000; dmem_f[q]=16'h0000; end
    pmem_init[2047]=16'hF000; pmem_init[2046]=16'hF400;
    case(scenario)
      0: for(q=0;q<384;q=q+6) begin pmem_init[q]=16'h4034;pmem_init[q+1]=data_base+q;pmem_init[q+2]=16'h5314;pmem_init[q+3]=16'h4405;pmem_init[q+4]=16'hE405;pmem_init[q+5]=16'h4303; end
      1: for(q=0;q<364;q=q+14) begin
           // Preserve one equal and one unequal comparison per block for every seed variant.
           pmem_init[q]=16'h4034;pmem_init[q+1]=branch_base; pmem_init[q+2]=16'h9034;pmem_init[q+3]=branch_base; pmem_init[q+4]=16'h2401; pmem_init[q+5]=16'h4303;
           pmem_init[q+6]=16'h4034;pmem_init[q+7]=branch_base+16'h0001; pmem_init[q+8]=16'h9034;pmem_init[q+9]=branch_base; pmem_init[q+10]=16'h2401;pmem_init[q+11]=16'h4303;pmem_init[q+12]=16'h5314;pmem_init[q+13]=16'h4303; end
      2: begin
           pmem_init[0]=16'h4031; pmem_init[1]=16'h0300;
           for(q=2;q<356;q=q+6) begin pmem_init[q]=16'h4034;pmem_init[q+1]=16'h0100+q+(seed_variant*16'h0010);pmem_init[q+2]=16'h12B0;pmem_init[q+3]=16'hF300;pmem_init[q+4]=16'h5314;pmem_init[q+5]=16'h4303; end
           pmem_init[384]=16'h5315; pmem_init[385]=16'h4506; pmem_init[386]=16'h4130;
         end
      3: for(q=0;q<360;q=q+9) begin pmem_init[q]=16'h40B2;pmem_init[q+1]=16'h1000+q+(seed_variant*16'h0101);pmem_init[q+2]=mem_base;pmem_init[q+3]=16'h4215;pmem_init[q+4]=mem_base;pmem_init[q+5]=16'h5315;pmem_init[q+6]=16'h4582;pmem_init[q+7]=mem_base+16'h0002;pmem_init[q+8]=16'h4303;end
      4: for(q=0;q<360;q=q+15) begin pmem_init[q]=16'h40B2;pmem_init[q+1]=16'h5A80;pmem_init[q+2]=16'h0120;pmem_init[q+3]=16'h40B2;pmem_init[q+4]=16'h0003+seed_variant;pmem_init[q+5]=16'h0130;pmem_init[q+6]=16'h40B2;pmem_init[q+7]=16'h0007+(seed_variant*2);pmem_init[q+8]=16'h0138;pmem_init[q+9]=16'h4215;pmem_init[q+10]=16'h013A;pmem_init[q+11]=16'h40B2;pmem_init[q+12]=16'h5A80;pmem_init[q+13]=16'h0120;pmem_init[q+14]=16'h4303;end
      default: for(q=0;q<384;q=q+4) begin pmem_init[q]=16'h4034;pmem_init[q+1]=16'h2200+q+(seed_variant*16'h0101);pmem_init[q+2]=16'h5314;pmem_init[q+3]=16'h4303;end
    endcase
    for(q=512;q<760;q=q+1) pmem_init[q]=16'h4303;
    // Copy the immutable initial image into independent paired memories.
    for(q=0;q<2048;q=q+1) begin pmem_g[q]=pmem_init[q]; pmem_f[q]=pmem_init[q]; end
    pmem_addr_reg_g=11'h000; pmem_addr_reg_f=11'h000;
    dmem_addr_reg_g=9'h000; dmem_addr_reg_f=9'h000;
  end endtask

  // Publication audit: baseline fingerprints are derived from realized stimulus
  // content and the cycle-by-cycle golden PC trajectory.  Raw seed identifiers
  // are intentionally NOT written into the hashed source files, so distinct
  // hashes prove distinct realized content rather than merely distinct labels.
  task open_baseline_fingerprint_sources; integer r; integer jlocal; begin
    if(mode==0 && fp_enable!=0) begin
      stimulus_fp_fd = $fopen("baseline_stimulus_source.txt", "w");
      pc_fp_fd       = $fopen("baseline_pc_trace_source.txt", "w");
      if(stimulus_fp_fd==0 || pc_fp_fd==0) begin
        $display("FINGERPRINT_ERROR,cannot_open_source_files");
        $fatal(1);
      end
      jlocal = timing_seed % 23;
      $fwrite(stimulus_fp_fd,"STIMULUS_SOURCE_V1\n");
      $fwrite(stimulus_fp_fd,"SCENARIO,%0d\n",scenario);
      // Canonical external-stimulus schedule.  These are realized values, not seed labels.
      if(scenario==5) begin
        $fwrite(stimulus_fp_fd,"NMI_RAISE_AFTER_DCO,%0d\n",160+jlocal);
        $fwrite(stimulus_fp_fd,"NMI_HIGH_DCO,4\n");
      end else if(scenario==6) begin
        $fwrite(stimulus_fp_fd,"DMA_FIRST_AFTER_DCO,%0d\n",180+jlocal);
        $fwrite(stimulus_fp_fd,"DMA_ADDR,7800\n");
        $fwrite(stimulus_fp_fd,"DMA_FIRST_HIGH_DCO,24\n");
        $fwrite(stimulus_fp_fd,"DMA_GAP_DCO,120\n");
        $fwrite(stimulus_fp_fd,"DMA_SECOND_HIGH_DCO,16\n");
      end else if(scenario==7) begin
        $fwrite(stimulus_fp_fd,"DEBUG_START_AFTER_DCO,%0d\n",120+jlocal);
        $fwrite(stimulus_fp_fd,"DEBUG_BOOT_BYTE,80\n");
        $fwrite(stimulus_fp_fd,"DEBUG_FINAL_WRITE,%04x\n",16'h1234+seed_variant);
      end else begin
        $fwrite(stimulus_fp_fd,"EXTERNAL_SCHEDULE,NONE\n");
      end
      // Hash source contains the entire realized initial program and data images.
      for(r=0;r<2048;r=r+1) $fwrite(stimulus_fp_fd,"PMEM,%04d,%04x\n",r,pmem_init[r]);
      for(r=0;r<512;r=r+1)  $fwrite(stimulus_fp_fd,"DMEM,%04d,%04x\n",r,dmem_g[r]);
      $fflush(stimulus_fp_fd);
      $fclose(stimulus_fp_fd);
      stimulus_fp_fd=0;
      $fwrite(pc_fp_fd,"PC_TRACE_SOURCE_V1\n");
      $fflush(pc_fp_fd);
    end
  end endtask

  task secid_finish; begin
    if (!secid_finish_started) begin
      secid_finish_started = 1'b1;
      if(pc_fp_fd!=0) begin
        $fflush(pc_fp_fd);
        $fclose(pc_fp_fd);
        pc_fp_fd=0;
      end
      $finish;
    end
  end endtask

  task scenario_stimulus; begin
    jitter=timing_seed%23;
    if(scenario==5) begin repeat(160+jitter) @(posedge dco_clk);nmi=1;repeat(4) @(posedge dco_clk);nmi=0;end
    else if(scenario==6) begin repeat(180+jitter) @(posedge dco_clk);dma_addr=15'h7800;dma_priority=1;dma_en=1;dma_we=2'b00;repeat(24) @(posedge dco_clk);dma_en=0;dma_priority=0;repeat(120) @(posedge dco_clk);dma_en=1;dma_priority=1;repeat(16) @(posedge dco_clk);dma_en=0;dma_priority=0;end
    else if(scenario==7) begin dbg_en=1;repeat(120+jitter) @(posedge dco_clk);uart_byte(8'h80);repeat(20) @(posedge dco_clk);dbg_read_word(6'h00);dbg_write_word(6'h02,16'h0001);repeat(60) @(posedge dco_clk);dbg_read_word(6'h03);dbg_write_word(6'h05,16'hF000);dbg_write_word(6'h04,16'h0001);repeat(40) @(posedge dco_clk);dbg_read_word(6'h06);dbg_write_word(6'h06,16'h1234+seed_variant);dbg_write_word(6'h02,16'h0002);end
  end endtask

  wire [22:0] dbg_activity_g = {dut_g.dbg_0.dbg_uart_0.uart_state,dut_g.dbg_0.dbg_uart_0.xfer_buf};
  reg  [22:0] prev_dbg_activity=23'hx;
  reg [63:0] cand_snapshot_g,cand_snapshot_f,expected_delta;
  // Design-adapter outputs consumed by the portable use-directed window engine.
  wire domain_active_now = ((((!pmem_cen_g) || (!dmem_cen_g) || per_en_g || (irq != 14'h0000) || nmi)) === 1'b1);
  wire candidate_known_now = (((^cand_snapshot_g[0:0]) !== 1'bx));
  wire cutset_known_now = ((^cutset_norm_g_0) !== 1'bx) || ((^cutset_norm_g_1) !== 1'bx) || ((^cutset_norm_g_2) !== 1'bx);
  localparam integer HAS_INDEPENDENT_CUTSET = 1;
  always @* begin
    cand_snapshot_g=64'b0; cand_snapshot_f=64'b0; expected_delta=64'b0;
    cand_snapshot_g[0] = candidate_norm_g[0];
    cand_snapshot_f[0] = candidate_norm_f[0];
    expected_delta[0] = fi_mask[0];
  end

  wire candidate_xz=((^cand_snapshot_g[0:0])===1'bx)||((^cand_snapshot_f[0:0])===1'bx);
  wire independent_cutset_corruption_now = (fi_mask[0] && ((((^cutset_norm_g_0)!==1'bx) && (((^cutset_norm_f_0)===1'bx) || (cutset_norm_g_0 !== cutset_norm_f_0))) || (((^cutset_norm_g_1)!==1'bx) && (((^cutset_norm_f_1)===1'bx) || (cutset_norm_g_1 !== cutset_norm_f_1))) || (((^cutset_norm_g_2)!==1'bx) && (((^cutset_norm_f_2)===1'bx) || (cutset_norm_g_2 !== cutset_norm_f_2)))));
  wire independent_cutset_xz_now = (fi_mask[0] && ((((^cutset_norm_g_0)!==1'bx) && ((^cutset_norm_f_0)===1'bx)) || (((^cutset_norm_g_1)!==1'bx) && ((^cutset_norm_f_1)===1'bx)) || (((^cutset_norm_g_2)!==1'bx) && ((^cutset_norm_f_2)===1'bx))));
  wire static_terminal_primary_for_mask = (1'b0);
  wire pc_xz_now=((^dut_g.frontend_0.pc)===1'bx)||((^dut_f.frontend_0.pc)===1'bx);
  wire pair_mismatch_now=(!fi_en) && ({dut_g.frontend_0.pc,mclk_g,puc_rst_g,pmem_addr_g,pmem_cen_g,dmem_addr_g,dmem_cen_g,per_addr_g,per_en_g}
                       !== {dut_f.frontend_0.pc,mclk_f,puc_rst_f,pmem_addr_f,pmem_cen_f,dmem_addr_f,dmem_cen_f,per_addr_f,per_en_f});

  reg [15:0] prev_pc=16'hxxxx;
  reg independent_cutset_seen=0, terminal_primary_cutpoint_seen=0, cutset_success=0,
      primary_after_independent_cutset=0, primary_before_independent_cutset=0,
      primary_any=0, cutset_model_escape=0, fault_induced_cutset_xz=0,
      activation_ok=0, pre_fault_mismatch=0, pre_fault_xz=0, fault_induced_primary_xz=0, trial_active=0;
  integer independent_cutset_cycle=-1, primary_cycle=-1, applied_cycle=-1, released_cycle=-1;

  task sample_independent_cutset; begin
    if(trial_active && independent_cutset_corruption_now && !independent_cutset_seen) begin
      independent_cutset_seen=1; cutset_success=1; independent_cutset_cycle=mcyc;
      if(independent_cutset_xz_now) fault_induced_cutset_xz=1'b1;
      /* CUTSET trace suppressed for Z01X validation */
    end
  end endtask

  // Event-driven sampling prevents a brief combinational first-use divergence
  // from being missed between clock edges.  Explicit calls at fault apply and
  // clock edges cover the case where the condition is already high.
  always @(independent_cutset_corruption_now) begin #0; sample_independent_cutset(); end
  always @(posedge dco_clk) begin dcyc=dcyc+1; #1; sample_independent_cutset(); end

  always @(posedge mclk_g) begin
    mcyc=mcyc+1; #1;
    if(reset_n && !puc_rst_g) begin
      if(mode==0 && fp_enable!=0 && pc_fp_fd!=0) begin
        if((^dut_g.frontend_0.pc)===1'bx) $fwrite(pc_fp_fd,"%0d,XXXX\n",mcyc);
        else                              $fwrite(pc_fp_fd,"%0d,%04x\n",mcyc,dut_g.frontend_0.pc);
      end
      if(pc_xz_now) begin
        xz_count=xz_count+1;
        if(mode==1) begin
          if(applied_cycle<0) pre_fault_xz=1'b1;
          else fault_induced_primary_xz=1'b1;
        end
      end
      if(pair_mismatch_now) begin mismatch_count=mismatch_count+1; if(mode==1 && applied_cycle<0) pre_fault_mismatch=1; end
      if((^dut_g.frontend_0.pc)!==1'bx && dut_g.frontend_0.pc!==prev_pc) begin progress_tokens=progress_tokens+1;prev_pc=dut_g.frontend_0.pc;end
      if((^dbg_activity_g)!==1'bx && dbg_activity_g!==prev_dbg_activity) begin debug_progress_tokens=debug_progress_tokens+1;prev_dbg_activity=dbg_activity_g;end
      if ((^cutset_norm_g_0) !== 1'bx) begin if ((^prev_cutset_g_0) !== 1'bx && cutset_norm_g_0 !== prev_cutset_g_0) cutset_activity_tokens=cutset_activity_tokens+1; prev_cutset_g_0=cutset_norm_g_0; end
      if ((^cutset_norm_g_1) !== 1'bx) begin if ((^prev_cutset_g_1) !== 1'bx && cutset_norm_g_1 !== prev_cutset_g_1) cutset_activity_tokens=cutset_activity_tokens+1; prev_cutset_g_1=cutset_norm_g_1; end
      if ((^cutset_norm_g_2) !== 1'bx) begin if ((^prev_cutset_g_2) !== 1'bx && cutset_norm_g_2 !== prev_cutset_g_2) cutset_activity_tokens=cutset_activity_tokens+1; prev_cutset_g_2=cutset_norm_g_2; end
      if(mode==0) $display("CAL,%0d,%04x,%016x,%016x,%0d,%0d,%06x,%0d,%0d,%0d,%0d",mcyc,dut_g.frontend_0.pc,cand_snapshot_g,cutset_activity_tokens,pc_xz_now,pair_mismatch_now,dbg_activity_g,domain_active_now,candidate_known_now,cutset_known_now,HAS_INDEPENDENT_CUTSET);
      sample_independent_cutset();
      if(trial_active && (dut_g.frontend_0.pc !== dut_f.frontend_0.pc)) begin
        if(!primary_any) begin
          primary_any=1; primary_cycle=mcyc;
          if(!independent_cutset_seen) begin
            primary_before_independent_cutset=1; terminal_primary_cutpoint_seen=1; cutset_success=1;
            if(!static_terminal_primary_for_mask) cutset_model_escape=1'b1;
          end
        end
        if(independent_cutset_seen) primary_after_independent_cutset=1;
      end
    end
  end

  initial begin
    scenario=0;timing_seed=20260818;mode=0;max_mclk=220;start_cycle=40;duration=1;observe_after=5;fi_mask=0;fp_enable=0;stimulus_fp_fd=0;pc_fp_fd=0;
    if(!$value$plusargs("SCENARIO=%d",scenario)) scenario=0;
    if(!$value$plusargs("SEED=%d",timing_seed)) timing_seed=20260818;
    if(!$value$plusargs("MODE=%d",mode)) mode=0;
    if(!$value$plusargs("MAX_MCLK=%d",max_mclk)) max_mclk=220;
    if(!$value$plusargs("START=%d",start_cycle)) start_cycle=40;
    if(!$value$plusargs("DURATION=%d",duration)) duration=1;
    if(!$value$plusargs("OBSERVE=%d",observe_after)) observe_after=5;
    if(!$value$plusargs("FI_MASK=%h",fi_mask)) fi_mask=0;
    if(!$value$plusargs("FP_ENABLE=%d",fp_enable)) fp_enable=0;
    mcyc=0;dcyc=0;progress_tokens=0;debug_progress_tokens=0;cutset_activity_tokens=0;xz_count=0;mismatch_count=0;
    init_program(); open_baseline_fingerprint_sources(); if(scenario==7) dbg_en=1; fork scenario_stimulus(); join_none
    repeat(16) @(posedge dco_clk);reset_n=1;
  end

  initial begin : trial_control
    wait(reset_n===1'b1); wait(puc_rst_g===1'b0);
    if(mode==1) begin
      while(mcyc<start_cycle) @(posedge mclk_g);
      @(negedge mclk_g); trial_active=1'b1; fi_en=1'b1; applied_cycle=mcyc; #2;
      activation_ok = ((fi_mask[0] && ((injection_norm_g[0]===1'b0)||(injection_norm_g[0]===1'b1)) && (injection_norm_f[0] === ~injection_norm_g[0]))) && (fi_mask[0:0] != 1'h0);
      sample_independent_cutset();
      repeat(duration) @(posedge mclk_g);
      @(negedge mclk_g); fi_en=1'b0; released_cycle=mcyc;
      repeat(observe_after) @(posedge mclk_g);
      trial_active=1'b0;
      secid_finish();
    end
  end

  initial begin : timeout_control
    while(mcyc<max_mclk) @(posedge mclk_g);
    if(mode==0 && $fs_get_status()=="") $display("BASE_SUMMARY,%0d,%0d,%0d,%0d,%04x,%04x",progress_tokens,debug_progress_tokens,xz_count,mismatch_count,dut_g.frontend_0.pc,dut_f.frontend_0.pc);
    
    secid_finish();
  end
endmodule
