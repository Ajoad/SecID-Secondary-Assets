-- ============================================================================
-- Cluster-local fan-in RTL: C002 -> neorv32_cpu_control.ctrl_o.lsu_priv
-- Source-faithful NEORV32 VHDL relation slice.
-- Exact deduplicated union of the candidate-local VHDL evidence for 5 RTL-proximal candidates. Members: neorv32_cpu.ctrl.ir_funct3, neorv32_cpu_control.csr.dcsr_ebreaku, neorv32_cpu_control.csr.dcsr_prv, neorv32_cpu_control.ctrl.csr_re, neorv32_cpu_control.ctrl_nxt.csr_re. Per-candidate guarded paths remain separate JSON files.
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
-- ... unrelated original VHDL lines 123-140 omitted ...
  signal lsu_wait    : std_ulogic;                     -- wait for current data bus access
  signal csr_rdata   : std_ulogic_vector(31 downto 0); -- CSR read data
  signal irq_machine : std_ulogic_vector(2 downto 0);  -- RISC-V standard machine-level interrupts
-- ... unrelated original VHDL lines 144-301 omitted ...
    rstn_i        => rstn_i,      -- global reset, low-active, async
    ctrl_o        => ctrl,        -- main control bus
    -- misc --
-- ... unrelated original VHDL lines 305-310 omitted ...
    rf_rs1_i      => rs1,         -- register file source 1
    csr_rdata_o   => csr_rdata,   -- CSR read data
    xcsr_rdata_i  => xcsr_res,    -- external CSR read data
    -- interrupts --
-- ... unrelated original VHDL lines 315-329 omitted ...
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
          when others =>
            if (funct3_v /= funct3_env_c) and (funct3_v /= funct3_zimop_c) then -- no CSR read if environment or may-be operation
              ctrl_nxt.csr_re <= '1';
            end if;
-- ... unrelated original VHDL lines 415-517 omitted ...
  ctrl_o.lsu_mo_en    <= '1' when (exec.state = S_MEM_REQ) else '0'; -- write memory output registers
  ctrl_o.lsu_mi_en    <= '1' when (exec.state = S_MEM_RSP) else '0'; -- write memory input registers
  ctrl_o.lsu_priv     <= csr.mstatus_mpp when (csr.mstatus_mprv = '1') else csr.prv_level; -- effective privilege level for loads/stores in M-mode
  ctrl_o.lsu_fence    <= ctrl.lsu_fence;
-- ... unrelated original VHDL lines 522-523 omitted ...
  ctrl_o.csr_re       <= ctrl.csr_re;
  ctrl_o.csr_addr     <= ctrl.csr_addr;
  ctrl_o.csr_wdata    <= csr_wdata;
  -- counter events --
-- ... unrelated original VHDL lines 528-851 omitted ...
  -- environment break exception trigger --
  ebreak_trig <= (ebreak and (    csr.prv_level) and (not csr.dcsr_ebreakm) and (not debug_ctrl.run)) or -- M-mode trap on M-ebreak
                 (ebreak and (not csr.prv_level) and (not csr.dcsr_ebreaku) and (not debug_ctrl.run));   -- M-mode trap on U-ebreak

-- ... unrelated original VHDL lines 856-971 omitted ...
  -- Debug Control and Status Register (dcsr) - Read-Back -----------------------------------
  -- -------------------------------------------------------------------------------------------
  dcsr_rdata(31 downto 28) <= "0100"; -- xdebugver: external debug support compatible to spec. version 1.0
  dcsr_rdata(27 downto 16) <= (others => '0'); -- reserved
  dcsr_rdata(15)           <= csr.dcsr_ebreakm; -- ebreakm: what happens on ebreak in m-mode? (normal trap OR debug-enter)
  dcsr_rdata(14)           <= '0'; -- reserved
  dcsr_rdata(13)           <= '0'; -- ebreaks: supervisor mode not implemented
  dcsr_rdata(12)           <= csr.dcsr_ebreaku when RISCV_ISA_U else '0'; -- ebreaku: what happens on ebreak in u-mode? (normal trap OR debug-enter)
  dcsr_rdata(11)           <= '0'; -- stepie: interrupts are disabled during single-stepping
-- ... unrelated original VHDL lines 981-986 omitted ...
  dcsr_rdata(2)            <= csr.dcsr_step; -- step: single-step mode
  dcsr_rdata(1 downto 0)   <= (others => csr.dcsr_prv); -- prv: privilege level when debug mode was entered

-- ... unrelated original VHDL lines 990-1004 omitted ...
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
-- ... unrelated original VHDL lines 1024-1034 omitted ...
      csr.dcsr_ebreaku <= '0';
      csr.dcsr_step    <= '0';
      csr.dcsr_prv     <= '0';
      csr.dcsr_cause   <= (others => '0');
-- ... unrelated original VHDL lines 1039-1046 omitted ...
        case ctrl.csr_addr is

          when csr_mstatus_c => -- machine status register (low word)
            csr.mstatus_mie  <= csr_wdata(3);
            csr.mstatus_mpie <= csr_wdata(7);
            csr.mstatus_mpp  <= and_reduce_f(csr_wdata(12 downto 11)); -- everything != M will fall back to U
            csr.mstatus_mprv <= csr_wdata(17);
            csr.mstatus_tw   <= csr_wdata(21);
-- ... unrelated original VHDL lines 1055-1083 omitted ...
          when csr_dcsr_c => -- debug mode control and status
            csr.dcsr_step    <= csr_wdata(2);
            csr.dcsr_ebreaku <= csr_wdata(12);
            csr.dcsr_ebreakm <= csr_wdata(15);
-- ... unrelated original VHDL lines 1088-1105 omitted ...
          if RISCV_ISA_Sdext and (ecause(5) = '1') then -- trap to debug-mode
            csr.prv_level  <= priv_mode_m_c;
            csr.dcsr_cause <= ecause(2 downto 0);
            csr.dcsr_prv   <= csr.prv_level;
            csr.dpc        <= epc(31 downto 1) & '0';
          else -- trap to machine-mode
            csr.prv_level    <= priv_mode_m_c;
            csr.mstatus_mpp  <= csr.prv_level;
            csr.mstatus_mie  <= '0';
-- ... unrelated original VHDL lines 1115-1140 omitted ...
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
-- ... unrelated original VHDL lines 1152-1169 omitted ...
      if not RISCV_ISA_U then
        csr.prv_level    <= priv_mode_m_c;
        csr.mstatus_mpp  <= priv_mode_m_c;
        csr.mstatus_mprv <= '0';
        csr.mstatus_tw   <= '0';
        csr.dcsr_ebreaku <= '0';
        csr.dcsr_prv     <= '0';
        csr.mcounteren   <= (others => '0');
-- ... unrelated original VHDL lines 1178-1179 omitted ...
      if not RISCV_ISA_Sdext then
        csr.dcsr_ebreakm <= '0';
        csr.dcsr_step    <= '0';
        csr.dcsr_ebreaku <= '0';
        csr.dcsr_prv     <= priv_mode_m_c;
        csr.dcsr_cause   <= (others => '0');
-- ... unrelated original VHDL lines 1186-1202 omitted ...
    if rising_edge(clk_i) then
      csr_rdata <= (others => '0'); -- output all-zero if there is no CSR read operation
      if (ctrl.csr_re = '1') then
        case ctrl.csr_addr is

          -- --------------------------------------------------------------------
          -- machine trap setup
          -- --------------------------------------------------------------------
          when csr_mstatus_c => -- machine status register, low word
            csr_rdata(3)  <= csr.mstatus_mie;
            csr_rdata(7)  <= csr.mstatus_mpie;
