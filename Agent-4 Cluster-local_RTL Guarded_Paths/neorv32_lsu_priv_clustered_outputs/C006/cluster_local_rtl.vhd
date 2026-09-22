-- ============================================================================
-- Cluster-local fan-in RTL: C006 -> neorv32_cpu_control.ctrl_o.lsu_priv
-- Source-faithful NEORV32 VHDL relation slice.
-- Exact deduplicated union of the candidate-local VHDL evidence for 5 RTL-proximal candidates. Members: neorv32_cpu.frontend.i32, neorv32_cpu_control.exec.ir, neorv32_cpu_control.exec_nxt.ir, neorv32_cpu_frontend.ipb_rdata(0), neorv32_cpu_frontend.ipb_rdata(1). Per-candidate guarded paths remain separate JSON files.
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
  signal dbus_req : bus_req_t;  -- intermediate data memory request
-- ... unrelated original VHDL lines 124-130 omitted ...
  signal rf_wdata    : std_ulogic_vector(31 downto 0); -- register file write data
  signal rs1         : std_ulogic_vector(31 downto 0); -- source register 1
  signal rs2         : std_ulogic_vector(31 downto 0); -- source register 2
-- ... unrelated original VHDL lines 134-242 omitted ...
    -- back-end interface --
    frontend_o => frontend     -- fetch data and status
  );
-- ... unrelated original VHDL lines 246-301 omitted ...
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
  -- trap logic --
  signal exc_buf   : std_ulogic_vector(exc_width_c-1 downto 0); -- synchronous exception buffer (one bit per exception)
  signal exc_fire  : std_ulogic;                                -- set if there is a valid source in the exception buffer
-- ... unrelated original VHDL lines 112-114 omitted ...
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
  signal csr_valid    : std_ulogic_vector(2 downto 0); -- CSR access: [2] implemented, [1] r/w access, [0] privilege
  signal illegal_cmd  : std_ulogic; -- illegal instruction check
  signal cnt_event    : std_ulogic_vector(cnt_event_width_c-1 downto 0); -- counter events
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
-- ... unrelated original VHDL lines 188-199 omitted ...
      exec.state <= S_RESTART;
      exec.ir    <= (others => '0');
      exec.irc   <= (others => '0');
      exec.ci    <= '0';
-- ... unrelated original VHDL lines 204-212 omitted ...
  -- Execution Micro Sequencer Comb ---------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  exec_comb: process(exec, env_pend, exc_fire, ecause, exc_buf, irq_buf, debug_ctrl, hwtrig_i,
                     frontend_i, csr, ctrl, alu_cp_done_i, lsu_wait_i, alu_add_i, branch_taken)
    variable opcode_v : std_ulogic_vector(6 downto 0);
    variable funct7_v : std_ulogic_vector(6 downto 0);
-- ... unrelated original VHDL lines 219-227 omitted ...
    env_enter         <= '0';
    env_exit          <= '0';
    instr_be          <= '0';
    instr_ma          <= '0';
    ecall             <= '0';
-- ... unrelated original VHDL lines 233-233 omitted ...
    ctrl_nxt          <= ctrl_bus_terminate_c; -- all zero/off by default (ALU operation = ZERO, ALU.adder_out = ADD)
    ctrl_nxt.csr_addr <= ctrl.csr_addr; -- keep previous CSR address
    ctrl_nxt.lsu_rd   <= ctrl.lsu_rd; -- keep memory read access type
-- ... unrelated original VHDL lines 237-283 omitted ...
        if (env_pend = '1') or (exc_fire = '1') then -- pending trap or pending exception (fast)
          exec_nxt.state <= S_TRAP_ENTER;
        elsif (frontend_i.valid = '1') and (hwtrig_i = '0') then -- new instruction word available and no pending HW trigger
          instr_be       <= frontend_i.fault; -- access fault during instruction fetch
          exec_nxt.ci    <= frontend_i.compr; -- this is a decompressed instruction
          exec_nxt.ir    <= frontend_i.i32; -- actual instruction word
          exec_nxt.irc   <= frontend_i.i16; -- original instruction word
          exec_nxt.pc    <= exec.pc2(31 downto 1) & '0';
-- ... unrelated original VHDL lines 292-294 omitted ...
        if (frontend_i.i32(instr_opcode_msb_c downto instr_opcode_lsb_c+2) = opcode_system_c(6 downto 2)) then
          ctrl_nxt.csr_addr <= frontend_i.i32(instr_imm12_msb_c downto instr_imm12_lsb_c);
        end if;
-- ... unrelated original VHDL lines 298-309 omitted ...
        env_enter      <= '1';
        exec_nxt.state <= S_RESTART; -- restart instruction fetch
-- ... unrelated original VHDL lines 312-426 omitted ...
      when S_BRANCH => -- update next-PC on taken branches and jumps
      -- ------------------------------------------------------------
        if CPU_CONSTT_BR_EN or (branch_taken = '1') then
          ctrl_nxt.if_reset <= '1'; -- reset instruction fetch to restart at next-PC (pc2)
        end if;
        if (branch_taken = '1') then -- taken/unconditional branch
          instr_ma     <= alu_add_i(1) and bool_to_ulogic_f(not RISCV_ISA_C); -- branch destination misaligned?
          exec_nxt.pc2 <= alu_add_i(31 downto 1) & '0';
-- ... unrelated original VHDL lines 435-471 omitted ...
            ctrl_nxt.csr_we <= '1'; -- CSRRW[I]: always write CSR; CSRR[S/C][I]: write CSR if rs1/imm5 is NOT zero
          end if;
-- ... unrelated original VHDL lines 474-517 omitted ...
  ctrl_o.lsu_mo_en    <= '1' when (exec.state = S_MEM_REQ) else '0'; -- write memory output registers
  ctrl_o.lsu_mi_en    <= '1' when (exec.state = S_MEM_RSP) else '0'; -- write memory input registers
  ctrl_o.lsu_priv     <= csr.mstatus_mpp when (csr.mstatus_mprv = '1') else csr.prv_level; -- effective privilege level for loads/stores in M-mode
  ctrl_o.lsu_fence    <= ctrl.lsu_fence;
-- ... unrelated original VHDL lines 522-525 omitted ...
  ctrl_o.csr_wdata    <= csr_wdata;
  -- counter events --
-- ... unrelated original VHDL lines 528-536 omitted ...
  ctrl_o.cpu_trap     <= env_enter;
  ctrl_o.cpu_sync_exc <= exc_fire;
-- ... unrelated original VHDL lines 539-705 omitted ...
    illegal_cmd <= '1'; -- default: illegal
    case exec.ir(instr_opcode_msb_c downto instr_opcode_lsb_c) is -- check entire opcode
-- ... unrelated original VHDL lines 708-709 omitted ...
      when opcode_lui_c | opcode_auipc_c | opcode_jal_c =>
        illegal_cmd <= '0'; -- all encodings are valid

-- ... unrelated original VHDL lines 713-714 omitted ...
        if (exec.ir(instr_funct3_msb_c downto instr_funct3_lsb_c) = "000") then
          illegal_cmd <= '0';
        end if;
-- ... unrelated original VHDL lines 718-778 omitted ...
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

-- ... unrelated original VHDL lines 812-822 omitted ...
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
-- ... unrelated original VHDL lines 842-862 omitted ...
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
-- ... unrelated original VHDL lines 947-971 omitted ...
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
-- ... unrelated original VHDL lines 982-1004 omitted ...
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
-- ... unrelated original VHDL lines 1055-1103 omitted ...
      elsif (env_enter = '1') then
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
-- ... unrelated original VHDL lines 1118-1143 omitted ...
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
    -- half-word select --
    cmd16 <= ipb_rdata(0)(15 downto 0) when (align_q = '0') else ipb_rdata(1)(15 downto 0);
    frontend_o.i16 <= cmd16; -- original 16-bit instruction
-- ... unrelated original VHDL lines 212-231 omitted ...
      if (align_q = '0') then
        if (ipb_rdata(0)(1 downto 0) /= "11") then -- compressed, consume IPB(0) entry
          align_set        <= ipb_avail(0); -- start of next instruction word is NOT 32-bit-aligned
          issue_valid      <= '0' & ipb_avail(0);
          frontend_o.fault <= ipb_rdata(0)(16);
          frontend_o.i32   <= cmd32;
          frontend_o.compr <= '1';
        else -- aligned uncompressed, consume both IPB entries
          issue_valid      <= (others => (ipb_avail(1) and ipb_avail(0)));
          frontend_o.fault <= ipb_rdata(1)(16) or ipb_rdata(0)(16);
          frontend_o.i32   <= ipb_rdata(1)(15 downto 0) & ipb_rdata(0)(15 downto 0);
          frontend_o.compr <= '0';
-- ... unrelated original VHDL lines 244-246 omitted ...
        if (ipb_rdata(1)(1 downto 0) /= "11") then -- compressed, consume IPB(1) entry
          align_clr        <= ipb_avail(1); -- start of next instruction word IS 32-bit-aligned again
          issue_valid      <= ipb_avail(1) & '0';
          frontend_o.fault <= ipb_rdata(1)(16);
          frontend_o.i32   <= cmd32;
          frontend_o.compr <= '1';
        else -- unaligned uncompressed, consume both IPB entries
          issue_valid      <= (others => (ipb_avail(0) and ipb_avail(1)));
          frontend_o.fault <= ipb_rdata(0)(16) or ipb_rdata(1)(16);
          frontend_o.i32   <= ipb_rdata(0)(15 downto 0) & ipb_rdata(1)(15 downto 0);

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
