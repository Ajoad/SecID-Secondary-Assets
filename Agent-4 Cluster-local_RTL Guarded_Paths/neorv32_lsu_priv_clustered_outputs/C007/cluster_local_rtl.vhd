-- ============================================================================
-- Cluster-local fan-in RTL: C007 -> neorv32_cpu_control.ctrl_o.lsu_priv
-- Source-faithful NEORV32 VHDL relation slice.
-- Exact deduplicated union of the candidate-local VHDL evidence for 4 RTL-proximal candidates. Members: neorv32_cpu.irq_machine, neorv32_cpu.mei_i, neorv32_cpu_control.irq_fast_i, neorv32_cpu_control.irq_pnd. Per-candidate guarded paths remain separate JSON files.
-- Unrelated VHDL is intentionally omitted. This evidence file is not intended
-- to be a standalone compilation unit.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Original source: neorv32_cpu.vhd
-- Entity: neorv32_cpu
-- ----------------------------------------------------------------------------
  port (
    -- global control --
    clk_i      : in  std_ulogic;                     -- global clock, rising edge
    rstn_i     : in  std_ulogic;                     -- global reset, low-active, async
    -- status --
    mtime_i    : in  std_ulogic_vector(63 downto 0); -- system time input from CLINT/MTIME
    trace_o    : out trace_port_t;                   -- execution trace port (enabled when CPU_TRACE_EN = true)
    sleep_o    : out std_ulogic;                     -- CPU is in sleep mode
    -- interrupts --
    msi_i      : in  std_ulogic;                     -- RISC-V machine software interrupt
    mei_i      : in  std_ulogic;                     -- RISC-V machine external interrupt
    mti_i      : in  std_ulogic;                     -- RISC-V machine timer interrupt
-- ... unrelated original VHDL lines 92-119 omitted ...
  -- busses --
  signal ctrl     : ctrl_bus_t; -- main control bus
  signal frontend : if_bus_t;   -- front-end to back-end interface
-- ... unrelated original VHDL lines 123-140 omitted ...
  signal lsu_wait    : std_ulogic;                     -- wait for current data bus access
  signal csr_rdata   : std_ulogic_vector(31 downto 0); -- CSR read data
  signal irq_machine : std_ulogic_vector(2 downto 0);  -- RISC-V standard machine-level interrupts

-- ... unrelated original VHDL lines 145-301 omitted ...
    rstn_i        => rstn_i,      -- global reset, low-active, async
    ctrl_o        => ctrl,        -- main control bus
    -- misc --
-- ... unrelated original VHDL lines 305-310 omitted ...
    rf_rs1_i      => rs1,         -- register file source 1
    csr_rdata_o   => csr_rdata,   -- CSR read data
    xcsr_rdata_i  => xcsr_res,    -- external CSR read data
    -- interrupts --
    irq_dbg_i     => dbi_i,       -- debug mode (halt) request
    irq_machine_i => irq_machine, -- RISC-V interrupts
    irq_fast_i    => firq_i,      -- fast interrupts
-- ... unrelated original VHDL lines 318-323 omitted ...
  -- RISC-V machine interrupts --
  irq_machine <= mei_i & mti_i & msi_i;

-- ... unrelated original VHDL lines 327-329 omitted ...
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
    -- data path interface --
    alu_cp_done_i : in  std_ulogic;                     -- ALU iterative operation done
    alu_cmp_i     : in  std_ulogic_vector(1 downto 0);  -- comparator status
    alu_add_i     : in  std_ulogic_vector(31 downto 0); -- ALU address result
    rf_rs1_i      : in  std_ulogic_vector(31 downto 0); -- register file source 1
    csr_rdata_o   : out std_ulogic_vector(31 downto 0); -- CSR read data
    xcsr_rdata_i  : in  std_ulogic_vector(31 downto 0); -- external CSR read data
    -- interrupts --
    irq_dbg_i     : in  std_ulogic;                     -- debug mode (halt) request
    irq_machine_i : in  std_ulogic_vector(2 downto 0);  -- RISC-V interrupt
    irq_fast_i    : in  std_ulogic_vector(15 downto 0); -- fast interrupts
    -- load/store unit interface --
-- ... unrelated original VHDL lines 87-108 omitted ...
  -- trap logic --
  signal exc_buf   : std_ulogic_vector(exc_width_c-1 downto 0); -- synchronous exception buffer (one bit per exception)
  signal exc_fire  : std_ulogic;                                -- set if there is a valid source in the exception buffer
  signal irq_pnd   : std_ulogic_vector(irq_width_c-1 downto 0); -- pending interrupt
  signal irq_buf   : std_ulogic_vector(irq_width_c-1 downto 0); -- asynchronous exception/interrupt buffer (one bit per interrupt)
  signal irq_fire  : std_ulogic_vector(1 downto 0);             -- set if an interrupt is actually kicking in
  signal env_pend  : std_ulogic; -- pending start of trap environment
  signal env_enter : std_ulogic; -- enter trap environment
  signal env_exit  : std_ulogic; -- leave trap environment
-- ... unrelated original VHDL lines 118-122 omitted ...
  signal epc       : std_ulogic_vector(31 downto 0); -- trap program counter
  signal ecause    : std_ulogic_vector(6 downto 0);  -- trap ID for cause CSRs

-- ... unrelated original VHDL lines 126-166 omitted ...
  signal ebreak_trig  : std_ulogic; -- environment break exception trigger
  signal trap_env     : std_ulogic_vector(6 downto 0); -- environment call cause-value helper
  signal retire_start : std_ulogic; -- start of instruction retire tracking
-- ... unrelated original VHDL lines 170-212 omitted ...
  -- Execution Micro Sequencer Comb ---------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  exec_comb: process(exec, env_pend, exc_fire, ecause, exc_buf, irq_buf, debug_ctrl, hwtrig_i,
                     frontend_i, csr, ctrl, alu_cp_done_i, lsu_wait_i, alu_add_i, branch_taken)
    variable opcode_v : std_ulogic_vector(6 downto 0);
    variable funct7_v : std_ulogic_vector(6 downto 0);
-- ... unrelated original VHDL lines 219-227 omitted ...
    env_enter         <= '0';
    env_exit          <= '0';
-- ... unrelated original VHDL lines 230-517 omitted ...
  ctrl_o.lsu_mo_en    <= '1' when (exec.state = S_MEM_REQ) else '0'; -- write memory output registers
  ctrl_o.lsu_mi_en    <= '1' when (exec.state = S_MEM_RSP) else '0'; -- write memory input registers
  ctrl_o.lsu_priv     <= csr.mstatus_mpp when (csr.mstatus_mprv = '1') else csr.prv_level; -- effective privilege level for loads/stores in M-mode
  ctrl_o.lsu_fence    <= ctrl.lsu_fence;
-- ... unrelated original VHDL lines 522-525 omitted ...
  ctrl_o.csr_wdata    <= csr_wdata;
  -- counter events --
-- ... unrelated original VHDL lines 528-820 omitted ...
    if (rstn_i = '0') then
      irq_pnd <= (others => '0');
      irq_buf <= (others => '0');
      exc_buf <= (others => '0');
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
-- ... unrelated original VHDL lines 867-871 omitted ...
  -- any sync. exception? --
  exc_fire <= or_reduce_f(exc_buf); -- cannot be masked

-- ... unrelated original VHDL lines 875-885 omitted ...
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

  -- exception program counter: async. interrupt or sync. exception? --
  epc <= exec.pc2 when (ecause(6) = '1') else exec.pc;

-- ... unrelated original VHDL lines 932-942 omitted ...
      elsif rising_edge(clk_i) then
        if (debug_ctrl.run = '0') and (env_enter = '1') and (ecause(5) = '1') then -- entry event
          debug_ctrl.run <= '1';
        elsif (env_exit = '1') then -- exit event
-- ... unrelated original VHDL lines 947-1004 omitted ...
    case exec.ir(instr_funct3_msb_c-1 downto instr_funct3_lsb_c) is
      when "10"   => csr_wdata <= csr_rdata or opb_v; -- set
      when "11"   => csr_wdata <= csr_rdata and (not opb_v); -- clear
      when others => csr_wdata <= opb_v; -- write
    end case;
-- ... unrelated original VHDL lines 1010-1016 omitted ...
    if (rstn_i = '0') then
      csr.prv_level    <= priv_mode_m_c;
      csr.mstatus_mie  <= '0';
      csr.mstatus_mpie <= '0';
      csr.mstatus_mpp  <= '0';
      csr.mstatus_mprv <= '0';
      csr.mstatus_tw   <= '0';
-- ... unrelated original VHDL lines 1024-1046 omitted ...
        case ctrl.csr_addr is

          when csr_mstatus_c => -- machine status register (low word)
            csr.mstatus_mie  <= csr_wdata(3);
            csr.mstatus_mpie <= csr_wdata(7);
            csr.mstatus_mpp  <= and_reduce_f(csr_wdata(12 downto 11)); -- everything != M will fall back to U
            csr.mstatus_mprv <= csr_wdata(17);
            csr.mstatus_tw   <= csr_wdata(21);
-- ... unrelated original VHDL lines 1055-1104 omitted ...
        if (debug_ctrl.run = '0') then -- no CSR update when in debug-mode
          if RISCV_ISA_Sdext and (ecause(5) = '1') then -- trap to debug-mode
            csr.prv_level  <= priv_mode_m_c;
            csr.dcsr_cause <= ecause(2 downto 0);
            csr.dcsr_prv   <= csr.prv_level;
            csr.dpc        <= epc(31 downto 1) & '0';
          else -- trap to machine-mode
            csr.prv_level    <= priv_mode_m_c;
            csr.mstatus_mpp  <= csr.prv_level;
            csr.mstatus_mie  <= '0';
-- ... unrelated original VHDL lines 1115-1143 omitted ...
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
