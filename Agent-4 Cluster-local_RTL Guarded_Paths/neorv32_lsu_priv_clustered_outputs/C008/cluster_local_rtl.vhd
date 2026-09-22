-- ============================================================================
-- Cluster-local fan-in RTL: C008 -> neorv32_cpu_control.ctrl_o.lsu_priv
-- Source-faithful NEORV32 VHDL relation slice.
-- Exact deduplicated union of the candidate-local VHDL evidence for 4 RTL-proximal candidates. Members: neorv32_cpu_control.csr.dpc, neorv32_cpu_control.csr.mepc, neorv32_cpu_control.csr.mtvec, neorv32_cpu_control.epc. Per-candidate guarded paths remain separate JSON files.
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

-- ... unrelated original VHDL lines 125-133 omitted ...
  signal alu_res     : std_ulogic_vector(31 downto 0); -- ALU result
  signal alu_add     : std_ulogic_vector(31 downto 0); -- ALU address result
  signal alu_cmp     : std_ulogic_vector(1 downto 0);  -- comparator result
-- ... unrelated original VHDL lines 137-140 omitted ...
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

-- ... unrelated original VHDL lines 337-421 omitted ...
  -- all buses are zero unless there is an according operation --
  rf_wdata <= alu_res or lsu_rdata or csr_rdata or ctrl.pc_ret;

-- ... unrelated original VHDL lines 425-463 omitted ...
    res_o  => alu_res,    -- ALU result
    add_o  => alu_add,    -- address computation result
    csr_o  => xcsr_alu,   -- CSR read data
-- ... unrelated original VHDL lines 467-483 omitted ...
    -- memory data access interface --
    addr_i      => alu_add,    -- access address
    wdata_i     => rs2,        -- write data
-- ... unrelated original VHDL lines 487-491 omitted ...
    -- data bus --
    dbus_req_o  => dbus_req,   -- request
    dbus_rsp_i  => dbus_rsp_i  -- response
-- ... unrelated original VHDL lines 495-496 omitted ...
  -- memory request --
  dbus_req_o <= dbus_req;

-- ... unrelated original VHDL lines 500-521 omitted ...
      -- data access check --
      d_addr_i => alu_add,       -- access address
      d_priv_i => ctrl.lsu_priv, -- access privilege

-- ----------------------------------------------------------------------------
-- Original source: neorv32_cpu_control.vhd
-- Entity: neorv32_cpu_control
-- ----------------------------------------------------------------------------
  -- trap logic --
  signal exc_buf   : std_ulogic_vector(exc_width_c-1 downto 0); -- synchronous exception buffer (one bit per exception)
  signal exc_fire  : std_ulogic;                                -- set if there is a valid source in the exception buffer
-- ... unrelated original VHDL lines 112-117 omitted ...
  signal instr_be  : std_ulogic; -- instruction fetch bus error
  signal instr_ma  : std_ulogic; -- instruction fetch misaligned address
  signal instr_il  : std_ulogic; -- illegal instruction
-- ... unrelated original VHDL lines 121-122 omitted ...
  signal epc       : std_ulogic_vector(31 downto 0); -- trap program counter
  signal ecause    : std_ulogic_vector(6 downto 0);  -- trap ID for cause CSRs

-- ... unrelated original VHDL lines 126-151 omitted ...
  signal csr : csr_t; -- register set
  signal csr_wdata, csr_rdata, dcsr_rdata : std_ulogic_vector(31 downto 0); -- read/write data

-- ... unrelated original VHDL lines 155-160 omitted ...
  -- misc/helpers --
  signal branch_taken : std_ulogic; -- branch condition true or unconditional jump
  signal monitor_cnt  : std_ulogic_vector(alu_cp_tmo_c downto 0); -- execution monitor cycle counter
-- ... unrelated original VHDL lines 164-181 omitted ...
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
-- ... unrelated original VHDL lines 219-230 omitted ...
    instr_ma          <= '0';
    ecall             <= '0';
-- ... unrelated original VHDL lines 233-283 omitted ...
        if (env_pend = '1') or (exc_fire = '1') then -- pending trap or pending exception (fast)
          exec_nxt.state <= S_TRAP_ENTER;
        elsif (frontend_i.valid = '1') and (hwtrig_i = '0') then -- new instruction word available and no pending HW trigger
          instr_be       <= frontend_i.fault; -- access fault during instruction fetch
          exec_nxt.ci    <= frontend_i.compr; -- this is a decompressed instruction
          exec_nxt.ir    <= frontend_i.i32; -- actual instruction word
          exec_nxt.irc   <= frontend_i.i16; -- original instruction word
          exec_nxt.pc    <= exec.pc2(31 downto 1) & '0';
          exec_nxt.state <= S_EXECUTE; -- start executing new instruction
-- ... unrelated original VHDL lines 293-298 omitted ...
      when S_TRAP_ENTER => -- enter trap environment and jump to trap vector
      -- ------------------------------------------------------------
        if (ecause(5) = '1') and RISCV_ISA_Sdext then -- debug mode entry
          exec_nxt.pc2 <= DEBUG_PARK_ADDR(31 downto 2) & "00"; -- start at "parking loop" <normal_entry>
        elsif (debug_ctrl.run = '1') and RISCV_ISA_Sdext then -- any other trap INSIDE debug mode
          exec_nxt.pc2 <= DEBUG_EXC_ADDR(31 downto 2) & "00"; -- start at "parking loop" <exception_entry>
        elsif (csr.mtvec(0) = '1') and (ecause(6) = '1') then -- M-mode trap: vectored mode and interrupt
          exec_nxt.pc2 <= csr.mtvec(31 downto 7) & ecause(4 downto 0) & "00"; -- PC = mtvec + 4 * mcause
        else -- M-mode trap: direct mode
          exec_nxt.pc2 <= csr.mtvec(31 downto 2) & "00"; -- PC = mtvec
        end if;
-- ... unrelated original VHDL lines 310-312 omitted ...
      when S_TRAP_EXIT => -- return from trap environment and jump to trap PC
      -- ------------------------------------------------------------
        if (debug_ctrl.run = '1') and RISCV_ISA_Sdext then -- debug mode exit
          exec_nxt.pc2 <= csr.dpc(31 downto 1) & '0';
        else -- normal end of trap
          exec_nxt.pc2 <= csr.mepc(31 downto 1) & '0';
        end if;
-- ... unrelated original VHDL lines 320-418 omitted ...
      when S_ALU_WAIT => -- wait for multi-cycle ALU co-processor operation to finish or trap
      -- ------------------------------------------------------------
        ctrl_nxt.alu_op   <= alu_op_cp_c;
        ctrl_nxt.rf_wb_en <= alu_cp_done_i; -- valid RF write-back (won't happen if exception)
        if (alu_cp_done_i = '1') or (or_reduce_f(exc_buf(exc_ialign_c downto exc_iaccess_c)) = '1') then
          exec_nxt.state <= S_DISPATCH;
        end if;
-- ... unrelated original VHDL lines 426-426 omitted ...
      when S_BRANCH => -- update next-PC on taken branches and jumps
      -- ------------------------------------------------------------
        if CPU_CONSTT_BR_EN or (branch_taken = '1') then
          ctrl_nxt.if_reset <= '1'; -- reset instruction fetch to restart at next-PC (pc2)
        end if;
        if (branch_taken = '1') then -- taken/unconditional branch
          instr_ma     <= alu_add_i(1) and bool_to_ulogic_f(not RISCV_ISA_C); -- branch destination misaligned?
          exec_nxt.pc2 <= alu_add_i(31 downto 1) & '0';
-- ... unrelated original VHDL lines 435-441 omitted ...
      when S_MEM_REQ => -- trigger memory request
      -- ------------------------------------------------------------
        if (or_reduce_f(exc_buf(exc_ialign_c downto exc_iaccess_c)) = '0') then -- memory request if no instruction exception
          ctrl_nxt.lsu_req <= '1';
          exec_nxt.state   <= S_MEM_RSP;
-- ... unrelated original VHDL lines 447-450 omitted ...
      when S_MEM_RSP => -- wait for memory response
      -- ------------------------------------------------------------
        if (lsu_wait_i = '0') or (or_reduce_f(exc_buf(exc_laccess_c downto exc_salign_c)) = '1') then -- bus response or load/store exception
          ctrl_nxt.rf_wb_en <= ctrl.lsu_rd; -- write to RF if read operation (won't happen in case of exception)
          exec_nxt.state    <= S_DISPATCH;
-- ... unrelated original VHDL lines 456-457 omitted ...
      when S_SYSTEM => -- CSR/ENVIRONMENT operation; no effect if illegal instruction
      -- ------------------------------------------------------------
        exec_nxt.state <= S_DISPATCH; -- default
        if (or_reduce_f(exc_buf(exc_ialign_c downto exc_iaccess_c)) = '0') then -- non-illegal instruction
          if (funct3_v = funct3_env_c) then -- environment instruction
            case exec.ir(instr_imm12_lsb_c+2 downto instr_imm12_lsb_c) is -- three LSBs are sufficient here
              when "000"  => ecall          <= '1';         -- ecall
              when "001"  => ebreak         <= '1';         -- ebreak
-- ... unrelated original VHDL lines 466-517 omitted ...
  ctrl_o.lsu_mo_en    <= '1' when (exec.state = S_MEM_REQ) else '0'; -- write memory output registers
  ctrl_o.lsu_mi_en    <= '1' when (exec.state = S_MEM_RSP) else '0'; -- write memory input registers
  ctrl_o.lsu_priv     <= csr.mstatus_mpp when (csr.mstatus_mprv = '1') else csr.prv_level; -- effective privilege level for loads/stores in M-mode
  ctrl_o.lsu_fence    <= ctrl.lsu_fence;
-- ... unrelated original VHDL lines 522-525 omitted ...
  ctrl_o.csr_wdata    <= csr_wdata;
  -- counter events --
-- ... unrelated original VHDL lines 528-838 omitted ...
      exc_buf(exc_ialign_c)  <= (exc_buf(exc_ialign_c)  or instr_ma)              and (not env_enter);
      exc_buf(exc_ecall_c)   <= (exc_buf(exc_ecall_c)   or ecall)                 and (not env_enter);
-- ... unrelated original VHDL lines 841-885 omitted ...
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
-- ... unrelated original VHDL lines 906-928 omitted ...
  -- exception program counter: async. interrupt or sync. exception? --
  epc <= exec.pc2 when (ecause(6) = '1') else exec.pc;

-- ... unrelated original VHDL lines 932-971 omitted ...
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
-- ... unrelated original VHDL lines 1024-1026 omitted ...
      csr.mie_firq     <= (others => '0');
      csr.mepc         <= (others => '0');
      csr.mcause       <= (others => '0');
      csr.mtvec        <= (others => '0');
      csr.mtval        <= (others => '0');
-- ... unrelated original VHDL lines 1032-1037 omitted ...
      csr.dcsr_cause   <= (others => '0');
      csr.dpc          <= (others => '0');
      csr.dscratch0    <= (others => '0');
-- ... unrelated original VHDL lines 1041-1046 omitted ...
        case ctrl.csr_addr is

          when csr_mstatus_c => -- machine status register (low word)
            csr.mstatus_mie  <= csr_wdata(3);
            csr.mstatus_mpie <= csr_wdata(7);
            csr.mstatus_mpp  <= and_reduce_f(csr_wdata(12 downto 11)); -- everything != M will fall back to U
            csr.mstatus_mprv <= csr_wdata(17);
            csr.mstatus_tw   <= csr_wdata(21);
-- ... unrelated original VHDL lines 1055-1061 omitted ...
          when csr_mtvec_c => -- machine trap-handler base + mode
            if (csr_wdata(1 downto 0) = "01") then -- vectored mode
              csr.mtvec <= csr_wdata(31 downto 7) & "00000" & "01"; -- enforce alignment
            else -- direct mode (fallback for reserved modes)
              csr.mtvec <= csr_wdata(31 downto 2) & "00";
            end if;
-- ... unrelated original VHDL lines 1068-1071 omitted ...
          when csr_mscratch_c => -- machine scratch
            csr.mscratch <= csr_wdata;

          when csr_mepc_c => -- machine exception program counter
            csr.mepc <= csr_wdata(31 downto 1) & '0';

-- ... unrelated original VHDL lines 1078-1083 omitted ...
          when csr_dcsr_c => -- debug mode control and status
            csr.dcsr_step    <= csr_wdata(2);
            csr.dcsr_ebreaku <= csr_wdata(12);
            csr.dcsr_ebreakm <= csr_wdata(15);
            csr.dcsr_prv     <= and_reduce_f(csr_wdata(1 downto 0)); -- everything != M will fall back to U

          when csr_dpc_c => -- debug mode program counter
            csr.dpc <= csr_wdata(31 downto 1) & '0';

-- ... unrelated original VHDL lines 1093-1104 omitted ...
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
-- ... unrelated original VHDL lines 1119-1143 omitted ...
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
-- ... unrelated original VHDL lines 1175-1184 omitted ...
        csr.dcsr_cause   <= (others => '0');
        csr.dpc          <= (others => '0');
        csr.dscratch0    <= (others => '0');
-- ... unrelated original VHDL lines 1188-1189 omitted ...
      if not RISCV_ISA_C then
        csr.mepc(1) <= '0'; -- xPC[1] is masked when IALIGN == 32
        csr.dpc(1)  <= '0';
      end if;
-- ... unrelated original VHDL lines 1194-1246 omitted ...
          when csr_mscratch_c => -- machine scratch register
            csr_rdata <= csr.mscratch;

          when csr_mepc_c => -- machine exception program counter
            csr_rdata <= csr.mepc(31 downto 1) & '0';
