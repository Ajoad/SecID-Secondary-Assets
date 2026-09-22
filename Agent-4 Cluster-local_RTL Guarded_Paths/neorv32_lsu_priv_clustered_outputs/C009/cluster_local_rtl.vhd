-- ============================================================================
-- Cluster-local fan-in RTL: C009 -> neorv32_cpu_control.ctrl_o.lsu_priv
-- Source-faithful NEORV32 VHDL relation slice.
-- Exact deduplicated union of the candidate-local VHDL evidence for 5 RTL-proximal candidates. Members: neorv32_cpu_control.csr.dscratch0, neorv32_cpu_control.csr.mscratch, neorv32_cpu_control.csr.mtval, neorv32_cpu_control.csr_rdata, neorv32_cpu_lsu.req.addr. Per-candidate guarded paths remain separate JSON files.
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
-- ... unrelated original VHDL lines 123-129 omitted ...
  signal hwtrig      : std_ulogic;                     -- hardware trigger firing
  signal rf_wdata    : std_ulogic_vector(31 downto 0); -- register file write data
  signal rs1         : std_ulogic_vector(31 downto 0); -- source register 1
  signal rs2         : std_ulogic_vector(31 downto 0); -- source register 2
  signal alu_res     : std_ulogic_vector(31 downto 0); -- ALU result
  signal alu_add     : std_ulogic_vector(31 downto 0); -- ALU address result
  signal alu_cmp     : std_ulogic_vector(1 downto 0);  -- comparator result
  signal alu_cp_done : std_ulogic;                     -- ALU co-processor operation done
  signal lsu_rdata   : std_ulogic_vector(31 downto 0); -- LSU memory read data
  signal lsu_mar     : std_ulogic_vector(31 downto 0); -- LSU memory address register
-- ... unrelated original VHDL lines 140-140 omitted ...
  signal lsu_wait    : std_ulogic;                     -- wait for current data bus access
  signal csr_rdata   : std_ulogic_vector(31 downto 0); -- CSR read data
  signal irq_machine : std_ulogic_vector(2 downto 0);  -- RISC-V standard machine-level interrupts
-- ... unrelated original VHDL lines 144-301 omitted ...
    rstn_i        => rstn_i,      -- global reset, low-active, async
    ctrl_o        => ctrl,        -- main control bus
    -- misc --
-- ... unrelated original VHDL lines 305-308 omitted ...
    alu_cmp_i     => alu_cmp,     -- comparator status
    alu_add_i     => alu_add,     -- ALU address result
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
    -- data output --
-- ... unrelated original VHDL lines 463-463 omitted ...
    res_o  => alu_res,    -- ALU result
    add_o  => alu_add,    -- address computation result
    csr_o  => xcsr_alu,   -- CSR read data
-- ... unrelated original VHDL lines 467-483 omitted ...
    -- memory data access interface --
    addr_i      => alu_add,    -- access address
    wdata_i     => rs2,        -- write data
    rdata_o     => lsu_rdata,  -- read data
    mar_o       => lsu_mar,    -- memory address register
-- ... unrelated original VHDL lines 489-521 omitted ...
      -- data access check --
      d_addr_i => alu_add,       -- access address
      d_priv_i => ctrl.lsu_priv, -- access privilege
-- ... unrelated original VHDL lines 525-546 omitted ...
      -- operands --
      rs1_rdata_i => rs1,           -- rs1 read data
      rs2_rdata_i => rs2,           -- rs2 read data
      rd_wdata_i  => rf_wdata,      -- rd write data
      mem_ben_i   => dbus_req.ben,  -- memory byte-enable

-- ----------------------------------------------------------------------------
-- Original source: neorv32_cpu_alu_shifter.vhd
-- Entity: neorv32_cpu_alu_shifter
-- ----------------------------------------------------------------------------
  port (
    -- global control --
    clk_i   : in  std_ulogic; -- global clock, rising edge
    rstn_i  : in  std_ulogic; -- global reset, low-active, async
    ctrl_i  : in  ctrl_bus_t; -- main control bus
    -- data input --
    rs1_i   : in  std_ulogic_vector(31 downto 0); -- rf source 1
    shamt_i : in  std_ulogic_vector(4 downto 0);  -- shift amount
    -- result and status --
-- ... unrelated original VHDL lines 34-86 omitted ...
        if (valid_cmd = '1') then
          cnt  <= shamt_i;
          sreg <= rs1_i;
-- ... unrelated original VHDL lines 90-122 omitted ...
    for i in 0 to 4 generate
      lvl(i+1)(31 downto 32-2**i) <= (others => sgn)        when (shamt_i(i) = '1') else lvl(i)(31 downto 32-2**i);
      lvl(i+1)(31-2**i downto 0)  <= lvl(i)(31 downto 2**i) when (shamt_i(i) = '1') else lvl(i)(31-2**i downto 0);
    end generate;

-- ----------------------------------------------------------------------------
-- Original source: neorv32_cpu_control.vhd
-- Entity: neorv32_cpu_control
-- ----------------------------------------------------------------------------
  -- trap logic --
  signal exc_buf   : std_ulogic_vector(exc_width_c-1 downto 0); -- synchronous exception buffer (one bit per exception)
  signal exc_fire  : std_ulogic;                                -- set if there is a valid source in the exception buffer
  signal irq_pnd   : std_ulogic_vector(irq_width_c-1 downto 0); -- pending interrupt
  signal irq_buf   : std_ulogic_vector(irq_width_c-1 downto 0); -- asynchronous exception/interrupt buffer (one bit per interrupt)
  signal irq_fire  : std_ulogic_vector(1 downto 0);             -- set if an interrupt is actually kicking in
  signal env_pend  : std_ulogic; -- pending start of trap environment
  signal env_enter : std_ulogic; -- enter trap environment
  signal env_exit  : std_ulogic; -- leave trap environment
  signal instr_be  : std_ulogic; -- instruction fetch bus error
  signal instr_ma  : std_ulogic; -- instruction fetch misaligned address
  signal instr_il  : std_ulogic; -- illegal instruction
  signal ecall     : std_ulogic; -- ecall instruction
-- ... unrelated original VHDL lines 122-122 omitted ...
  signal epc       : std_ulogic_vector(31 downto 0); -- trap program counter
  signal ecause    : std_ulogic_vector(6 downto 0);  -- trap ID for cause CSRs

-- ... unrelated original VHDL lines 126-151 omitted ...
  signal csr : csr_t; -- register set
  signal csr_wdata, csr_rdata, dcsr_rdata : std_ulogic_vector(31 downto 0); -- read/write data

-- ... unrelated original VHDL lines 155-160 omitted ...
  -- misc/helpers --
  signal branch_taken : std_ulogic; -- branch condition true or unconditional jump
  signal monitor_cnt  : std_ulogic_vector(alu_cp_tmo_c downto 0); -- execution monitor cycle counter
-- ... unrelated original VHDL lines 164-166 omitted ...
  signal ebreak_trig  : std_ulogic; -- environment break exception trigger
  signal trap_env     : std_ulogic_vector(6 downto 0); -- environment call cause-value helper
  signal retire_start : std_ulogic; -- start of instruction retire tracking
-- ... unrelated original VHDL lines 170-181 omitted ...
    if (exec.ir(instr_opcode_lsb_c+2) = '0') then -- conditional branch
      if (exec.ir(instr_funct3_msb_c) = '0') then -- beq / bne
        branch_taken <= alu_cmp_i(0) xor exec.ir(instr_funct3_lsb_c);
      else -- blt(u) / bge(u)
        branch_taken <= alu_cmp_i(1) xor exec.ir(instr_funct3_lsb_c);
      end if;
-- ... unrelated original VHDL lines 188-212 omitted ...
  -- Execution Micro Sequencer Comb ---------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  exec_comb: process(exec, env_pend, exc_fire, ecause, exc_buf, irq_buf, debug_ctrl, hwtrig_i,
                     frontend_i, csr, ctrl, alu_cp_done_i, lsu_wait_i, alu_add_i, branch_taken)
    variable opcode_v : std_ulogic_vector(6 downto 0);
    variable funct7_v : std_ulogic_vector(6 downto 0);
-- ... unrelated original VHDL lines 219-227 omitted ...
    env_enter         <= '0';
    env_exit          <= '0';
-- ... unrelated original VHDL lines 230-230 omitted ...
    instr_ma          <= '0';
    ecall             <= '0';
-- ... unrelated original VHDL lines 233-426 omitted ...
      when S_BRANCH => -- update next-PC on taken branches and jumps
      -- ------------------------------------------------------------
        if CPU_CONSTT_BR_EN or (branch_taken = '1') then
          ctrl_nxt.if_reset <= '1'; -- reset instruction fetch to restart at next-PC (pc2)
        end if;
        if (branch_taken = '1') then -- taken/unconditional branch
          instr_ma     <= alu_add_i(1) and bool_to_ulogic_f(not RISCV_ISA_C); -- branch destination misaligned?
          exec_nxt.pc2 <= alu_add_i(31 downto 1) & '0';
-- ... unrelated original VHDL lines 435-517 omitted ...
  ctrl_o.lsu_mo_en    <= '1' when (exec.state = S_MEM_REQ) else '0'; -- write memory output registers
  ctrl_o.lsu_mi_en    <= '1' when (exec.state = S_MEM_RSP) else '0'; -- write memory input registers
  ctrl_o.lsu_priv     <= csr.mstatus_mpp when (csr.mstatus_mprv = '1') else csr.prv_level; -- effective privilege level for loads/stores in M-mode
  ctrl_o.lsu_fence    <= ctrl.lsu_fence;
-- ... unrelated original VHDL lines 522-741 omitted ...
          case exec.ir(instr_funct5_msb_c downto instr_funct5_lsb_c) is
            when "00001" | "00000" | "00100" | "01100" | "01000" | "10000" | "10100" | "11000" | "11100" => illegal_cmd <= not bool_to_ulogic_f(RISCV_ISA_Zaamo);
            when "00010" => illegal_cmd <= (not bool_to_ulogic_f(RISCV_ISA_Zalrsc)) or or_reduce_f(exec.ir(instr_rs2_msb_c downto instr_rs2_lsb_c)); -- LR
            when "00011" => illegal_cmd <= not bool_to_ulogic_f(RISCV_ISA_Zalrsc); -- SC
            when others  => illegal_cmd <= '1';
          end case;
-- ... unrelated original VHDL lines 748-767 omitted ...
              when funct12_dret_c   => illegal_cmd <= not debug_ctrl.run; -- dret allowed in debug mode only
              when funct12_wfi_c    => illegal_cmd <= (not csr.prv_level) and csr.mstatus_tw; -- wfi allowed in M-mode or if TW is zero
              when others           => illegal_cmd <= '1'; -- undefined
-- ... unrelated original VHDL lines 771-778 omitted ...
        elsif (csr_valid = "111") then -- valid CSR operation
          illegal_cmd <= '0';
        end if;
-- ... unrelated original VHDL lines 782-783 omitted ...
      when others =>
        illegal_cmd <= '1';

-- ... unrelated original VHDL lines 787-806 omitted ...
  -- Illegal Operation Check ----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  instr_il <= '1' when ((exec.state = S_EXECUTE) or (exec.state = S_ALU_WAIT)) and -- check execution states
                       ((monitor_cnt(alu_cp_tmo_c) = '1') or (illegal_cmd = '1')) else '0'; -- timeout or illegal

-- ... unrelated original VHDL lines 812-821 omitted ...
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
      exc_buf(exc_ecall_c)   <= (exc_buf(exc_ecall_c)   or ecall)                 and (not env_enter);
      exc_buf(exc_ebreak_c)  <= (exc_buf(exc_ebreak_c)  or ebreak_trig)           and (not env_enter);
-- ... unrelated original VHDL lines 842-847 omitted ...
      exc_buf(exc_db_step_c) <= (exc_buf(exc_db_step_c) or debug_ctrl.trig_step)  and (not env_enter);
    end if;
-- ... unrelated original VHDL lines 850-862 omitted ...
    elsif rising_edge(clk_i) then
      if (env_enter = '1') then -- start of trap environment acknowledged by execute engine
        env_pend <= '0';
      elsif (exc_fire = '1') or (or_reduce_f(irq_fire) = '1') then -- trap trigger
-- ... unrelated original VHDL lines 867-885 omitted ...
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
-- ... unrelated original VHDL lines 947-951 omitted ...
    -- debug mode entry triggers --
    debug_ctrl.trig_halt  <= irq_dbg_i and (not debug_ctrl.run); -- external halt request (if not halted already)
    debug_ctrl.trig_step  <= (csr.dcsr_step and (not debug_ctrl.run)) when (exec.state = S_EXECUTE) else '0'; -- single-step mode
    debug_ctrl.trig_hw    <= hwtrig_i and (not debug_ctrl.run); -- enter debug-mode by HW trigger module
-- ... unrelated original VHDL lines 956-965 omitted ...
    debug_ctrl.trig_step  <= '0';
    debug_ctrl.trig_hw    <= '0';
-- ... unrelated original VHDL lines 968-971 omitted ...
  -- Debug Control and Status Register (dcsr) - Read-Back -----------------------------------
  -- -------------------------------------------------------------------------------------------
  dcsr_rdata(31 downto 28) <= "0100"; -- xdebugver: external debug support compatible to spec. version 1.0
  dcsr_rdata(27 downto 16) <= (others => '0'); -- reserved
  dcsr_rdata(15)           <= csr.dcsr_ebreakm; -- ebreakm: what happens on ebreak in m-mode? (normal trap OR debug-enter)
  dcsr_rdata(14)           <= '0'; -- reserved
  dcsr_rdata(13)           <= '0'; -- ebreaks: supervisor mode not implemented
  dcsr_rdata(12)           <= csr.dcsr_ebreaku when RISCV_ISA_U else '0'; -- ebreaku: what happens on ebreak in u-mode? (normal trap OR debug-enter)
  dcsr_rdata(11)           <= '0'; -- stepie: interrupts are disabled during single-stepping
  dcsr_rdata(10)           <= '1'; -- stopcount: standard counters and HPMs are stopped when in debug mode
  dcsr_rdata(9)            <= '0'; -- stoptime: timers increment as usual
-- ... unrelated original VHDL lines 983-1004 omitted ...
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
      csr.mie_msi      <= '0';
      csr.mie_mei      <= '0';
      csr.mie_mti      <= '0';
      csr.mie_firq     <= (others => '0');
      csr.mepc         <= (others => '0');
-- ... unrelated original VHDL lines 1029-1029 omitted ...
      csr.mtvec        <= (others => '0');
      csr.mtval        <= (others => '0');
      csr.mscratch     <= (others => '0');
      csr.mcounteren   <= (others => '0');
-- ... unrelated original VHDL lines 1034-1038 omitted ...
      csr.dpc          <= (others => '0');
      csr.dscratch0    <= (others => '0');
    elsif rising_edge(clk_i) then
-- ... unrelated original VHDL lines 1042-1046 omitted ...
        case ctrl.csr_addr is

          when csr_mstatus_c => -- machine status register (low word)
            csr.mstatus_mie  <= csr_wdata(3);
            csr.mstatus_mpie <= csr_wdata(7);
            csr.mstatus_mpp  <= and_reduce_f(csr_wdata(12 downto 11)); -- everything != M will fall back to U
            csr.mstatus_mprv <= csr_wdata(17);
            csr.mstatus_tw   <= csr_wdata(21);

          when csr_mie_c => -- machine interrupt enable
            csr.mie_msi  <= csr_wdata(3);
            csr.mie_mti  <= csr_wdata(7);
            csr.mie_mei  <= csr_wdata(11);
            csr.mie_firq <= csr_wdata(31 downto 16);

-- ... unrelated original VHDL lines 1062-1068 omitted ...
          when csr_mcounteren_c => -- machine counter access enable
            csr.mcounteren <= csr_wdata;

          when csr_mscratch_c => -- machine scratch
            csr.mscratch <= csr_wdata;

-- ... unrelated original VHDL lines 1075-1077 omitted ...
          when csr_mcause_c => -- machine trap cause
            csr.mcause <= csr_wdata(31) & csr_wdata(4 downto 0);

          when csr_mtval_c => -- machine trap value
            csr.mtval <= csr_wdata;

-- ... unrelated original VHDL lines 1084-1089 omitted ...
          when csr_dpc_c => -- debug mode program counter
            csr.dpc <= csr_wdata(31 downto 1) & '0';

          when csr_dscratch0_c => -- debug mode scratch register 0
            csr.dscratch0 <= csr_wdata;

-- ... unrelated original VHDL lines 1096-1104 omitted ...
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
            csr.mstatus_mpie <= csr.mstatus_mie;
            csr.mcause       <= ecause(6) & ecause(4 downto 0);
            csr.mepc         <= epc(31 downto 1) & '0';
            if (ecause(6) = '0') then -- sync. exception
              if (ecause(2) = '1') then -- load/store misaligned/access fault
                csr.mtval <= lsu_mar_i;
              elsif (ecause(1 downto 0) = "10") then -- illegal instruction
                if RISCV_ISA_C and (exec.ci = '1') then
                  csr.mtval <= x"0000" & exec.irc;
                else
                  csr.mtval <= exec.ir;
                end if;
              elsif (not RISCV_ISA_C) and (ecause(1 downto 0) = "00") then -- instruction address misaligned
                csr.mtval <= exec.pc2;
              else -- everything else
                csr.mtval <= (others => '0');
              end if;
-- ... unrelated original VHDL lines 1132-1143 omitted ...
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
        csr.dcsr_ebreaku <= '0';
-- ... unrelated original VHDL lines 1176-1185 omitted ...
        csr.dpc          <= (others => '0');
        csr.dscratch0    <= (others => '0');
      end if;
-- ... unrelated original VHDL lines 1189-1210 omitted ...
          when csr_mstatus_c => -- machine status register, low word
            csr_rdata(3)  <= csr.mstatus_mie;
            csr_rdata(7)  <= csr.mstatus_mpie;
            csr_rdata(11) <= csr.mstatus_mpp;
            csr_rdata(12) <= csr.mstatus_mpp;
            csr_rdata(17) <= csr.mstatus_mprv;
            csr_rdata(21) <= csr.mstatus_tw and bool_to_ulogic_f(RISCV_ISA_U);

-- ... unrelated original VHDL lines 1219-1229 omitted ...
          when csr_mie_c => -- machine interrupt-enable register
            csr_rdata(3)  <= csr.mie_msi;
            csr_rdata(7)  <= csr.mie_mti;
            csr_rdata(11) <= csr.mie_mei;
            csr_rdata(31 downto 16) <= csr.mie_firq;

-- ... unrelated original VHDL lines 1236-1246 omitted ...
          when csr_mscratch_c => -- machine scratch register
            csr_rdata <= csr.mscratch;

-- ... unrelated original VHDL lines 1250-1277 omitted ...
          when csr_dpc_c       => if RISCV_ISA_Sdext then csr_rdata <= csr.dpc;       end if; -- program counter
          when csr_dscratch0_c => if RISCV_ISA_Sdext then csr_rdata <= csr.dscratch0; end if; -- scratch register 0


-- ----------------------------------------------------------------------------
-- Original source: neorv32_cpu_lsu.vhd
-- Entity: neorv32_cpu_lsu
-- ----------------------------------------------------------------------------
    if (rstn_i = '0') then
      req.addr <= (others => '0');
      req.data <= (others => '0');
-- ... unrelated original VHDL lines 103-106 omitted ...
      if (ctrl_i.lsu_mo_en = '1') then
        req.addr <= addr_i; -- memory address register
        case ctrl_i.ir_funct3(1 downto 0) is -- alignment + byte-enable
-- ... unrelated original VHDL lines 110-135 omitted ...
  req.burst  <= '0'; -- only non-burst/single-accesses
  req.stb    <= ctrl_i.lsu_req and (not misalign) and (not pmp_fault_i); -- access request (all source signals are driven by registers)
  dbus_req_o <= req; -- output bus request
  mar_o      <= req.addr; -- address feedback for MTVAL CSR

-- ... unrelated original VHDL lines 141-149 omitted ...
          when "00" => -- byte
            case req.addr(1 downto 0) is
              when "00"   => rdata_o <= replicate_f((not ctrl_i.ir_funct3(2)) and dbus_rsp_i.data(7),  24) & dbus_rsp_i.data(7 downto 0);
              when "01"   => rdata_o <= replicate_f((not ctrl_i.ir_funct3(2)) and dbus_rsp_i.data(15), 24) & dbus_rsp_i.data(15 downto 8);
-- ... unrelated original VHDL lines 154-157 omitted ...
          when "01" => -- half-word
            if (req.addr(1) = '0') then
              rdata_o <= replicate_f((not ctrl_i.ir_funct3(2)) and dbus_rsp_i.data(15), 16) & dbus_rsp_i.data(15 downto 0);
            else

-- ----------------------------------------------------------------------------
-- Original source: neorv32_cpu_regfile.vhd
-- Entity: neorv32_cpu_regfile
-- ----------------------------------------------------------------------------
  signal rf_we  : std_ulogic;
  signal addr   : std_ulogic_vector(4 downto 0);
  signal wdata  : std_ulogic_vector(31 downto 0);
-- ... unrelated original VHDL lines 56-58 omitted ...
  type   regfile_t is array ((2**AWIDTH)-1 downto 0) of std_ulogic_vector(31 downto 0);
  signal regfile : regfile_t;

-- ... unrelated original VHDL lines 62-68 omitted ...
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
      end if;
-- ... unrelated original VHDL lines 85-105 omitted ...
        if (rd_we_i = '1') then
          regfile(to_integer(unsigned(addr(AWIDTH-1 downto 0)))) <= rd_data_i;
        end if;
