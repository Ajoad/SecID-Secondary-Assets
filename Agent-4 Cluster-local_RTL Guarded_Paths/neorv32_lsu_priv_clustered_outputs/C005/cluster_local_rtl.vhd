-- ============================================================================
-- Cluster-local fan-in RTL: C005 -> neorv32_cpu_control.ctrl_o.lsu_priv
-- Source-faithful NEORV32 VHDL relation slice.
-- Exact deduplicated union of the candidate-local VHDL evidence for 5 RTL-proximal candidates. Members: neorv32_cpu.ctrl.rf_rd, neorv32_cpu.ctrl.rf_wb_en, neorv32_cpu_control.ctrl.rf_zero, neorv32_cpu_control.ctrl_nxt.rf_zero, neorv32_cpu_regfile.addr. Per-candidate guarded paths remain separate JSON files.
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
-- ... unrelated original VHDL lines 123-130 omitted ...
  signal rf_wdata    : std_ulogic_vector(31 downto 0); -- register file write data
  signal rs1         : std_ulogic_vector(31 downto 0); -- source register 1
  signal rs2         : std_ulogic_vector(31 downto 0); -- source register 2
-- ... unrelated original VHDL lines 134-301 omitted ...
    rstn_i        => rstn_i,      -- global reset, low-active, async
    ctrl_o        => ctrl,        -- main control bus
    -- misc --
-- ... unrelated original VHDL lines 305-309 omitted ...
    alu_add_i     => alu_add,     -- ALU address result
    rf_rs1_i      => rs1,         -- register file source 1
    csr_rdata_o   => csr_rdata,   -- CSR read data
-- ... unrelated original VHDL lines 313-329 omitted ...
  -- CPU is sleeping --
  sleep_o <= not ctrl.cnt_event(cnt_event_cy_c);

-- ... unrelated original VHDL lines 333-333 omitted ...
  ifence_o <= ctrl.if_fence;
  dfence_o <= ctrl.lsu_fence;

-- ... unrelated original VHDL lines 337-403 omitted ...
  )
  port map (
    -- global control --
    clk_i      => clk_i,
    rstn_i     => rstn_i,
    zero_i     => ctrl.rf_zero,
    -- write port (rd) --
    rd_we_i    => ctrl.rf_wb_en,
    rd_addr_i  => ctrl.rf_rd,
    rd_data_i  => rf_wdata,
    -- read port 1 (rs1) --
    rs1_addr_i => ctrl.rf_rs1,
    rs1_data_o => rs1,
    -- read port 1 (rs2) --
    rs2_addr_i => ctrl.rf_rs2,
    rs2_data_o => rs2
  );

  -- all buses are zero unless there is an according operation --
  rf_wdata <= alu_res or lsu_rdata or csr_rdata or ctrl.pc_ret;

-- ... unrelated original VHDL lines 425-458 omitted ...
    -- data input --
    rs1_i  => rs1,        -- rf source 1
    rs2_i  => rs2,        -- rf source 2

-- ----------------------------------------------------------------------------
-- Original source: neorv32_cpu_control.vhd
-- Entity: neorv32_cpu_control
-- ----------------------------------------------------------------------------
    case exec.state is

      when S_RESTART => -- reset and restart instruction fetch at next-PC
      -- ------------------------------------------------------------
        ctrl_nxt.rf_zero  <= '1'; -- [house keeping] force writing zero to x0 in case it is an array register
        ctrl_nxt.if_reset <= '1';
-- ... unrelated original VHDL lines 271-502 omitted ...
  ctrl_o.rf_zero      <= ctrl.rf_zero;
  -- alu --
-- ... unrelated original VHDL lines 505-517 omitted ...
  ctrl_o.lsu_mo_en    <= '1' when (exec.state = S_MEM_REQ) else '0'; -- write memory output registers
  ctrl_o.lsu_mi_en    <= '1' when (exec.state = S_MEM_RSP) else '0'; -- write memory input registers
  ctrl_o.lsu_priv     <= csr.mstatus_mpp when (csr.mstatus_mprv = '1') else csr.prv_level; -- effective privilege level for loads/stores in M-mode
  ctrl_o.lsu_fence    <= ctrl.lsu_fence;
-- ... unrelated original VHDL lines 522-525 omitted ...
  ctrl_o.csr_wdata    <= csr_wdata;
  -- counter events --
-- ... unrelated original VHDL lines 528-1004 omitted ...
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
-- ... unrelated original VHDL lines 1055-1143 omitted ...
          if (csr.dcsr_prv /= priv_mode_m_c) then
            csr.mstatus_mprv <= '0'; -- clear if return to priv. level less than M
          end if;
-- ... unrelated original VHDL lines 1147-1148 omitted ...
          if (csr.mstatus_mpp /= priv_mode_m_c) then
            csr.mstatus_mprv <= '0'; -- clear if return to priv. level less than M
          end if;
-- ... unrelated original VHDL lines 1152-1169 omitted ...
      if not RISCV_ISA_U then
        csr.prv_level    <= priv_mode_m_c;
        csr.mstatus_mpp  <= priv_mode_m_c;
        csr.mstatus_mprv <= '0';
        csr.mstatus_tw   <= '0';

-- ----------------------------------------------------------------------------
-- Original source: neorv32_cpu_regfile.vhd
-- Entity: neorv32_cpu_regfile
-- ----------------------------------------------------------------------------
  signal rf_we  : std_ulogic;
  signal addr   : std_ulogic_vector(4 downto 0);
  signal wdata  : std_ulogic_vector(31 downto 0);
-- ... unrelated original VHDL lines 56-68 omitted ...
    -- Register zero (x0) is just another physical register that has to be initialized by the CPU control.
    -- Writes to x0 are inhibited unless the control forces a write (writing zero) to re-initialize x0.
    rf_we <= (rd_we_i and or_reduce_f(rd_addr_i(AWIDTH-1 downto 0))) or zero_i;
    addr  <= (others => '0') when (zero_i  = '1') else -- force rd = zero
             rd_addr_i       when (rd_we_i = '1') else rs1_addr_i; -- multiplexed rd/rs1

-- ... unrelated original VHDL lines 75-78 omitted ...
        if (rf_we = '1') then
          regfile(to_integer(unsigned(addr(AWIDTH-1 downto 0)))) <= rd_data_i;
        end if;
        rs1_data_o <= regfile(to_integer(unsigned(addr(AWIDTH-1 downto 0))));
        rs2_data_o <= regfile(to_integer(unsigned(rs2_addr_i(AWIDTH-1 downto 0))));
