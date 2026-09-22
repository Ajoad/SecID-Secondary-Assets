-- ============================================================================
-- Cluster-local fan-in RTL: C000 -> neorv32_cpu_control.ctrl_o.lsu_priv
-- Source-faithful NEORV32 VHDL relation slice.
-- Exact deduplicated union of the candidate-local VHDL evidence for 5 RTL-proximal candidates. Members: neorv32_cpu.ctrl.cpu_trap, neorv32_cpu_control.ctrl_nxt.csr_we, neorv32_cpu_control.debug_ctrl.run, neorv32_cpu_control.env_exit, neorv32_cpu_frontend.ipb_avail. Per-candidate guarded paths remain separate JSON files.
-- Unrelated VHDL is intentionally omitted. This evidence file is not intended
-- to be a standalone compilation unit.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Original source: neorv32_cpu.vhd
-- Entity: neorv32_cpu
-- ----------------------------------------------------------------------------
  -- busses --
  signal ctrl     : ctrl_bus_t; -- main control bus
  signal frontend : if_bus_t;   -- front-end to back-end interface
-- ... unrelated original VHDL lines 123-301 omitted ...
    rstn_i        => rstn_i,      -- global reset, low-active, async
    ctrl_o        => ctrl,        -- main control bus
    -- misc --
-- ... unrelated original VHDL lines 305-329 omitted ...
  -- CPU is sleeping --
  sleep_o <= not ctrl.cnt_event(cnt_event_cy_c);

-- ... unrelated original VHDL lines 333-333 omitted ...
  ifence_o <= ctrl.if_fence;
  dfence_o <= ctrl.lsu_fence;

-- ... unrelated original VHDL lines 337-421 omitted ...
  -- all buses are zero unless there is an according operation --
  rf_wdata <= alu_res or lsu_rdata or csr_rdata or ctrl.pc_ret;


-- ----------------------------------------------------------------------------
-- Original source: neorv32_cpu_control.vhd
-- Entity: neorv32_cpu_control
-- ----------------------------------------------------------------------------
  signal env_pend  : std_ulogic; -- pending start of trap environment
  signal env_enter : std_ulogic; -- enter trap environment
  signal env_exit  : std_ulogic; -- leave trap environment
  signal instr_be  : std_ulogic; -- instruction fetch bus error
-- ... unrelated original VHDL lines 119-166 omitted ...
  signal ebreak_trig  : std_ulogic; -- environment break exception trigger
  signal trap_env     : std_ulogic_vector(6 downto 0); -- environment call cause-value helper
  signal retire_start : std_ulogic; -- start of instruction retire tracking
-- ... unrelated original VHDL lines 170-227 omitted ...
    env_enter         <= '0';
    env_exit          <= '0';
    instr_be          <= '0';
-- ... unrelated original VHDL lines 231-309 omitted ...
        env_enter      <= '1';
        exec_nxt.state <= S_RESTART; -- restart instruction fetch
-- ... unrelated original VHDL lines 312-319 omitted ...
        env_exit       <= '1';
        exec_nxt.state <= S_RESTART; -- restart instruction fetch
-- ... unrelated original VHDL lines 322-471 omitted ...
            ctrl_nxt.csr_we <= '1'; -- CSRRW[I]: always write CSR; CSRR[S/C][I]: write CSR if rs1/imm5 is NOT zero
          end if;
-- ... unrelated original VHDL lines 474-517 omitted ...
  ctrl_o.lsu_mo_en    <= '1' when (exec.state = S_MEM_REQ) else '0'; -- write memory output registers
  ctrl_o.lsu_mi_en    <= '1' when (exec.state = S_MEM_RSP) else '0'; -- write memory input registers
  ctrl_o.lsu_priv     <= csr.mstatus_mpp when (csr.mstatus_mprv = '1') else csr.prv_level; -- effective privilege level for loads/stores in M-mode
  ctrl_o.lsu_fence    <= ctrl.lsu_fence;
-- ... unrelated original VHDL lines 522-536 omitted ...
  ctrl_o.cpu_trap     <= env_enter;
  ctrl_o.cpu_sync_exc <= exc_fire;
  ctrl_o.cpu_debug    <= debug_ctrl.run;

-- ... unrelated original VHDL lines 541-824 omitted ...
    elsif rising_edge(clk_i) then
      -- interrupt pending: synchronize requests --
      irq_pnd <= debug_ctrl.trig_halt & irq_fast_i & irq_machine_i;
      -- interrupt buffer: local feedback to ensure requests stay active until trap environment has started --
      irq_buf(irq_db_halt_c) <=  irq_pnd(irq_db_halt_c)                  or (env_pend and irq_buf(irq_db_halt_c));
      irq_buf(irq_msi_irq_c) <= (irq_pnd(irq_msi_irq_c) and csr.mie_msi) or (env_pend and irq_buf(irq_msi_irq_c));
      irq_buf(irq_mei_irq_c) <= (irq_pnd(irq_mei_irq_c) and csr.mie_mei) or (env_pend and irq_buf(irq_mei_irq_c));
      irq_buf(irq_mti_irq_c) <= (irq_pnd(irq_mti_irq_c) and csr.mie_mti) or (env_pend and irq_buf(irq_mti_irq_c));
      for i in 0 to 15 loop
        irq_buf(irq_firq_0_c+i) <= (irq_pnd(irq_firq_0_c+i) and csr.mie_firq(i)) or (env_pend and irq_buf(irq_firq_0_c+i));
      end loop;
      -- exception buffer: accumulate exception requests; clear all requests at once when trap environment starts --
      exc_buf(exc_iaccess_c) <= (exc_buf(exc_iaccess_c) or instr_be)              and (not env_enter);
      exc_buf(exc_illegal_c) <= (exc_buf(exc_illegal_c) or instr_il)              and (not env_enter);
      exc_buf(exc_ialign_c)  <= (exc_buf(exc_ialign_c)  or instr_ma)              and (not env_enter);
-- ... unrelated original VHDL lines 840-862 omitted ...
    elsif rising_edge(clk_i) then
      if (env_enter = '1') then -- start of trap environment acknowledged by execute engine
        env_pend <= '0';
      elsif (exc_fire = '1') or (or_reduce_f(irq_fire) = '1') then -- trap trigger
-- ... unrelated original VHDL lines 867-874 omitted ...
  -- any system interrupt? --
  irq_fire(0) <= '1' when
    ((exec.state = S_EXECUTE) or (exec.state = S_SLEEP)) and -- trigger system IRQ only in S_EXECUTE state or in sleep mode
    (or_reduce_f(irq_buf(irq_firq_15_c downto irq_msi_irq_c)) = '1') and -- pending system IRQ
    ((csr.mstatus_mie = '1') or (csr.prv_level = priv_mode_u_c)) and -- IRQ only when in M-mode and MIE=1 OR when in U-mode
    (debug_ctrl.run = '0') and (csr.dcsr_step = '0') else '0'; -- no system IRQs when in debug-mode / during single-stepping

-- ... unrelated original VHDL lines 882-885 omitted ...
  -- Trap Priority Encoder ------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  ecause <=
    -- standard RISC-V synchronous exceptions --
    trap_iaf_c     when (exc_buf(exc_iaccess_c) = '1') else -- instruction access fault
    trap_iil_c     when (exc_buf(exc_illegal_c) = '1') else -- illegal instruction
    trap_ima_c     when (exc_buf(exc_ialign_c)  = '1') else -- instruction address misaligned
    trap_env       when (exc_buf(exc_ecall_c)   = '1') else -- environment call from U/M-mode
    trap_brk_c     when (exc_buf(exc_ebreak_c)  = '1') else -- environment breakpoint
    trap_sma_c     when (exc_buf(exc_salign_c)  = '1') else -- store address misaligned
    trap_lma_c     when (exc_buf(exc_lalign_c)  = '1') else -- load address misaligned
    trap_saf_c     when (exc_buf(exc_saccess_c) = '1') else -- store access fault
    trap_laf_c     when (exc_buf(exc_laccess_c) = '1') else -- load access fault
    -- standard RISC-V debug-mode traps --
    trap_db_halt_c when (irq_buf(irq_db_halt_c) = '1') and RISCV_ISA_Sdext  else -- external halt request
    trap_db_trig_c when (exc_buf(exc_db_trig_c) = '1') and RISCV_ISA_Sdtrig else -- hardware trigger
    trap_db_brkp_c when (exc_buf(exc_db_brkp_c) = '1') and RISCV_ISA_Sdext  else -- breakpoint
    trap_db_step_c when (exc_buf(exc_db_step_c) = '1') and RISCV_ISA_Sdext  else -- single stepping
    -- NEORV32-specific fast interrupts --
    trap_firq0_c   when (irq_buf(irq_firq_0_c)  = '1') else -- fast interrupt channel 0
    trap_firq1_c   when (irq_buf(irq_firq_1_c)  = '1') else -- fast interrupt channel 1
    trap_firq2_c   when (irq_buf(irq_firq_2_c)  = '1') else -- fast interrupt channel 2
    trap_firq3_c   when (irq_buf(irq_firq_3_c)  = '1') else -- fast interrupt channel 3
    trap_firq4_c   when (irq_buf(irq_firq_4_c)  = '1') else -- fast interrupt channel 4
    trap_firq5_c   when (irq_buf(irq_firq_5_c)  = '1') else -- fast interrupt channel 5
-- ... unrelated original VHDL lines 911-925 omitted ...
  -- environment call helper --
  trap_env <= trap_env_c(6 downto 2) & csr.prv_level & csr.prv_level;

-- ... unrelated original VHDL lines 929-940 omitted ...
      if (rstn_i = '0') then
        debug_ctrl.run <= '0';
      elsif rising_edge(clk_i) then
        if (debug_ctrl.run = '0') and (env_enter = '1') and (ecause(5) = '1') then -- entry event
          debug_ctrl.run <= '1';
        elsif (env_exit = '1') then -- exit event
          debug_ctrl.run <= '0';
        end if;
-- ... unrelated original VHDL lines 949-1016 omitted ...
    if (rstn_i = '0') then
      csr.prv_level    <= priv_mode_m_c;
      csr.mstatus_mie  <= '0';
      csr.mstatus_mpie <= '0';
      csr.mstatus_mpp  <= '0';
      csr.mstatus_mprv <= '0';
      csr.mstatus_tw   <= '0';
-- ... unrelated original VHDL lines 1024-1048 omitted ...
          when csr_mstatus_c => -- machine status register (low word)
            csr.mstatus_mie  <= csr_wdata(3);
            csr.mstatus_mpie <= csr_wdata(7);
            csr.mstatus_mpp  <= and_reduce_f(csr_wdata(12 downto 11)); -- everything != M will fall back to U
            csr.mstatus_mprv <= csr_wdata(17);
            csr.mstatus_tw   <= csr_wdata(21);
-- ... unrelated original VHDL lines 1055-1140 omitted ...
      elsif (env_exit = '1') then
        if RISCV_ISA_Sdext and (debug_ctrl.run = '1') then -- return from debug-mode
          csr.prv_level <= csr.dcsr_prv;
          if (csr.dcsr_prv /= priv_mode_m_c) then
            csr.mstatus_mprv <= '0'; -- clear if return to priv. level less than M
          end if;
        else -- return from machine-mode trap
          csr.prv_level <= csr.mstatus_mpp;
          if (csr.mstatus_mpp /= priv_mode_m_c) then
            csr.mstatus_mprv <= '0'; -- clear if return to priv. level less than M
          end if;
          csr.mstatus_mpp  <= priv_mode_u_c; -- set to least-privileged level that is supported
          csr.mstatus_mie  <= csr.mstatus_mpie;
-- ... unrelated original VHDL lines 1154-1169 omitted ...
      if not RISCV_ISA_U then
        csr.prv_level    <= priv_mode_m_c;
        csr.mstatus_mpp  <= priv_mode_m_c;
        csr.mstatus_mprv <= '0';
        csr.mstatus_tw   <= '0';

-- ----------------------------------------------------------------------------
-- Original source: neorv32_cpu_frontend.vhd
-- Entity: neorv32_cpu_frontend
-- ----------------------------------------------------------------------------
  signal ipb_we,    ipb_re    : std_ulogic_vector(1 downto 0);
  signal ipb_free,  ipb_avail : std_ulogic_vector(1 downto 0);

-- ... unrelated original VHDL lines 85-184 omitted ...
      rdata_o => ipb_rdata(i),
      avail_o => ipb_avail(i)
    );
-- ... unrelated original VHDL lines 188-231 omitted ...
      if (align_q = '0') then
        if (ipb_rdata(0)(1 downto 0) /= "11") then -- compressed, consume IPB(0) entry
          align_set        <= ipb_avail(0); -- start of next instruction word is NOT 32-bit-aligned
          issue_valid      <= '0' & ipb_avail(0);
          frontend_o.fault <= ipb_rdata(0)(16);
-- ... unrelated original VHDL lines 237-238 omitted ...
        else -- aligned uncompressed, consume both IPB entries
          issue_valid      <= (others => (ipb_avail(1) and ipb_avail(0)));
          frontend_o.fault <= ipb_rdata(1)(16) or ipb_rdata(0)(16);
-- ... unrelated original VHDL lines 242-246 omitted ...
        if (ipb_rdata(1)(1 downto 0) /= "11") then -- compressed, consume IPB(1) entry
          align_clr        <= ipb_avail(1); -- start of next instruction word IS 32-bit-aligned again
          issue_valid      <= ipb_avail(1) & '0';
