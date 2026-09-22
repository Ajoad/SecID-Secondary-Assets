// ============================================================================
// Cluster-local relation RTL: C005 -> cv32e40p_top.core_i.cs_registers_i.csr_we_int
// Source-faithful CV32E40P analysis-RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 4 RTL-proximal candidates. Members: cv32e40p_top.core_i.dm_exception_addr_i, cv32e40p_top.core_i.dm_halt_addr_i, cv32e40p_top.core_i.id_stage_i.csr_op, cv32e40p_top.core_i.id_stage_i.deassert_we. Per-candidate guarded structural paths remain in separate JSON files; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: cv32e40p_analysis_lowered.v
// Source contains multiple sv2v-lowered CV32E40P modules
// ----------------------------------------------------------------------------
	input wire rst_n;
// ... unrelated original RTL lines 31-36 omitted ...
	input wire [31:0] branch_addr_i;
	input wire branch_i;
// ... unrelated original RTL lines 39-40 omitted ...
	output wire [31:0] pc_o;
// ... unrelated original RTL lines 42-46 omitted ...
	reg [31:0] pc_n;
	reg update_state;
// ... unrelated original RTL lines 49-146 omitted ...
		if (branch_i) begin
			update_state = 1'b1;
// ... unrelated original RTL lines 149-1429 omitted ...
	output reg is_decoding_o;
	input wire is_fetch_failed_i;
	output reg deassert_we_o;
	input wire illegal_insn_i;
// ... unrelated original RTL lines 1434-1445 omitted ...
	input wire instr_valid_i;
// ... unrelated original RTL lines 1447-1470 omitted ...
	input wire branch_taken_ex_i;
// ... unrelated original RTL lines 1472-1488 omitted ...
	input wire trigger_match_i;
// ... unrelated original RTL lines 1490-1523 omitted ...
	output reg halt_id_o;
// ... unrelated original RTL lines 1525-1532 omitted ...
	reg [4:0] ctrl_fsm_cs;
// ... unrelated original RTL lines 1534-1568 omitted ...
	wire debug_req_pending;
// ... unrelated original RTL lines 1570-1707 omitted ...
				if (branch_taken_ex_i) begin
					is_decoding_o = 1'b0;
// ... unrelated original RTL lines 1710-1712 omitted ...
				else if (data_err_i) begin
					is_decoding_o = 1'b0;
// ... unrelated original RTL lines 1715-1722 omitted ...
				else if (is_fetch_failed_i) begin
					is_decoding_o = 1'b0;
// ... unrelated original RTL lines 1725-1731 omitted ...
				else if (instr_valid_i) begin : blk_decode_level1
					is_decoding_o = 1'b1;
// ... unrelated original RTL lines 1734-1734 omitted ...
					if ((debug_req_pending || trigger_match_i) & ~debug_mode_q) begin
						is_decoding_o = (COREV_PULP ? 1'b0 : 1'b1);
// ... unrelated original RTL lines 1737-2283 omitted ...
		if (~is_decoding_o)
			deassert_we_o = 1'b1;
		if (illegal_insn_i)
			deassert_we_o = 1'b1;
		if ((((data_req_ex_i == 1'b1) && (regfile_we_ex_i == 1'b1)) || ((wb_ready_i == 1'b0) && (regfile_we_wb_i == 1'b1))) && ((((reg_d_ex_is_reg_a_i == 1'b1) || (reg_d_ex_is_reg_b_i == 1'b1)) || (reg_d_ex_is_reg_c_i == 1'b1)) || ((is_decoding_o && (regfile_we_id_i && !data_misaligned_i)) && (regfile_waddr_ex_i == regfile_alu_waddr_id_i)))) begin
			deassert_we_o = 1'b1;
// ... unrelated original RTL lines 2290-2291 omitted ...
		if ((ctrl_transfer_insn_in_dec_i == cv32e40p_pkg_BRANCH_JALR) && (((((regfile_we_wb_i == 1'b1) && (reg_d_wb_is_reg_a_i == 1'b1)) || ((regfile_we_ex_i == 1'b1) && (reg_d_ex_is_reg_a_i == 1'b1))) || ((regfile_alu_we_fw_i == 1'b1) && (reg_d_alu_is_reg_a_i == 1'b1))) || (FPU && (apu_read_dep_for_jalr_i == 1'b1)))) begin
			jr_stall_o = 1'b1;
// ... unrelated original RTL lines 2294-2449 omitted ...
	input wire rst_ni;
// ... unrelated original RTL lines 2451-2454 omitted ...
	input wire [31:0] dm_halt_addr_i;
// ... unrelated original RTL lines 2456-2456 omitted ...
	input wire [31:0] dm_exception_addr_i;
// ... unrelated original RTL lines 2458-2715 omitted ...
	) if_stage_i(
// ... unrelated original RTL lines 2717-2717 omitted ...
		.rst_n(rst_ni),
// ... unrelated original RTL lines 2719-2732 omitted ...
		.instr_valid_id_o(instr_valid_id),
// ... unrelated original RTL lines 2734-2734 omitted ...
		.is_fetch_failed_o(is_fetch_failed_id),
// ... unrelated original RTL lines 2736-2736 omitted ...
		.pc_set_i(pc_set),
// ... unrelated original RTL lines 2738-2740 omitted ...
		.pc_mux_i(pc_mux_id),
		.exc_pc_mux_i(exc_pc_mux_id),
		.pc_id_o(pc_id),
		.pc_if_o(pc_if),
// ... unrelated original RTL lines 2745-2757 omitted ...
	);
// ... unrelated original RTL lines 2759-2775 omitted ...
	) id_stage_i(
// ... unrelated original RTL lines 2777-2782 omitted ...
		.is_decoding_o(is_decoding),
		.instr_valid_i(instr_valid_id),
// ... unrelated original RTL lines 2785-2786 omitted ...
		.branch_in_ex_o(branch_in_ex),
		.branch_decision_i(branch_decision),
// ... unrelated original RTL lines 2789-2796 omitted ...
		.is_fetch_failed_i(is_fetch_failed_id),
// ... unrelated original RTL lines 2798-2799 omitted ...
		.illegal_c_insn_i(illegal_c_insn_id),
// ... unrelated original RTL lines 2801-2801 omitted ...
		.id_ready_o(id_ready),
// ... unrelated original RTL lines 2803-2804 omitted ...
		.id_valid_o(id_valid),
// ... unrelated original RTL lines 2806-2856 omitted ...
		.csr_op_ex_o(csr_op_ex),
// ... unrelated original RTL lines 2858-2902 omitted ...
		.trigger_match_i(trigger_match),
// ... unrelated original RTL lines 2904-2927 omitted ...
	);
// ... unrelated original RTL lines 2929-3071 omitted ...
	) cs_registers_i(
// ... unrelated original RTL lines 3073-3083 omitted ...
		.csr_op_i(csr_op),
// ... unrelated original RTL lines 3085-3106 omitted ...
		.trigger_match_o(trigger_match),
// ... unrelated original RTL lines 3108-3111 omitted ...
		.pc_id_i(pc_id),
// ... unrelated original RTL lines 3113-3139 omitted ...
	);
// ... unrelated original RTL lines 3141-3256 omitted ...
	input wire [1:0] csr_op_i;
// ... unrelated original RTL lines 3258-3280 omitted ...
	output wire trigger_match_o;
// ... unrelated original RTL lines 3282-3285 omitted ...
	input wire [31:0] pc_id_i;
// ... unrelated original RTL lines 3287-3340 omitted ...
	reg csr_we_int;
// ... unrelated original RTL lines 3342-4076 omitted ...
			assign trigger_match_o = tmatch_control_exec_q & (pc_id_i[31:0] == tmatch_value_q[31:0]);
// ... unrelated original RTL lines 4078-4330 omitted ...
	input wire deassert_we_i;
	output reg illegal_insn_o;
// ... unrelated original RTL lines 4333-4354 omitted ...
	input wire illegal_c_insn_i;
// ... unrelated original RTL lines 4356-4399 omitted ...
	output wire [1:0] csr_op_o;
// ... unrelated original RTL lines 4401-4425 omitted ...
	reg [1:0] csr_op;
// ... unrelated original RTL lines 4427-6630 omitted ...
		if (illegal_c_insn_i)
			illegal_insn_o = 1'b1;
// ... unrelated original RTL lines 6633-6641 omitted ...
	assign csr_op_o = (deassert_we_i ? sv2v_cast_EB06E(2'b00) : csr_op);
// ... unrelated original RTL lines 6643-7473 omitted ...
	output reg branch_in_ex_o;
	input wire branch_decision_i;
// ... unrelated original RTL lines 7476-7485 omitted ...
	output wire id_ready_o;
// ... unrelated original RTL lines 7487-7488 omitted ...
	output wire id_valid_o;
// ... unrelated original RTL lines 7490-7544 omitted ...
	output reg [1:0] csr_op_ex_o;
// ... unrelated original RTL lines 7546-7625 omitted ...
	wire deassert_we;
// ... unrelated original RTL lines 7627-7637 omitted ...
	wire branch_taken_ex;
// ... unrelated original RTL lines 7639-7645 omitted ...
	wire halt_id;
// ... unrelated original RTL lines 7647-7741 omitted ...
	wire [1:0] csr_op;
// ... unrelated original RTL lines 7743-7834 omitted ...
	assign branch_taken_ex = branch_in_ex_o && branch_decision_i;
// ... unrelated original RTL lines 7836-8226 omitted ...
	) decoder_i(
		.deassert_we_i(deassert_we),
		.illegal_insn_o(illegal_insn_dec),
// ... unrelated original RTL lines 8230-8251 omitted ...
		.illegal_c_insn_i(illegal_c_insn_i),
// ... unrelated original RTL lines 8253-8288 omitted ...
		.csr_op_o(csr_op),
// ... unrelated original RTL lines 8290-8308 omitted ...
	);
// ... unrelated original RTL lines 8310-8313 omitted ...
	) controller_i(
// ... unrelated original RTL lines 8315-8319 omitted ...
		.is_decoding_o(is_decoding_o),
		.is_fetch_failed_i(is_fetch_failed_i),
		.deassert_we_o(deassert_we),
		.illegal_insn_i(illegal_insn_dec),
// ... unrelated original RTL lines 8324-8335 omitted ...
		.instr_valid_i(instr_valid_i),
// ... unrelated original RTL lines 8337-8361 omitted ...
		.branch_taken_ex_i(branch_taken_ex),
// ... unrelated original RTL lines 8363-8378 omitted ...
		.trigger_match_i(trigger_match_i),
// ... unrelated original RTL lines 8380-8422 omitted ...
	);
// ... unrelated original RTL lines 8424-8584 omitted ...
		else if (id_valid_o) begin
			alu_en_ex_o <= alu_en;
// ... unrelated original RTL lines 8587-8704 omitted ...
	assign id_valid_o = ~halt_id & id_ready_o;
// ... unrelated original RTL lines 8706-8758 omitted ...
	input wire rst_n;
// ... unrelated original RTL lines 8760-8763 omitted ...
	input wire [31:0] dm_exception_addr_i;
	input wire [31:0] dm_halt_addr_i;
// ... unrelated original RTL lines 8766-8773 omitted ...
	output reg instr_valid_id_o;
// ... unrelated original RTL lines 8775-8777 omitted ...
	output wire [31:0] pc_if_o;
	output reg [31:0] pc_id_o;
	output reg is_fetch_failed_o;
// ... unrelated original RTL lines 8781-8781 omitted ...
	input wire pc_set_i;
	input wire [31:0] mepc_i;
// ... unrelated original RTL lines 8784-8785 omitted ...
	input wire [3:0] pc_mux_i;
	input wire [2:0] exc_pc_mux_i;
// ... unrelated original RTL lines 8788-8798 omitted ...
	wire if_valid;
// ... unrelated original RTL lines 8800-8801 omitted ...
	reg branch_req;
	reg [31:0] branch_addr_n;
// ... unrelated original RTL lines 8804-8806 omitted ...
	reg [31:0] exc_pc;
// ... unrelated original RTL lines 8808-8811 omitted ...
	wire instr_valid;
// ... unrelated original RTL lines 8813-8904 omitted ...
		if (pc_set_i)
			branch_req = 1'b1;
// ... unrelated original RTL lines 8907-8913 omitted ...
	always @(posedge clk or negedge rst_n) begin : IF_ID_PIPE_REGISTERS
		if (rst_n == 1'b0) begin
			instr_valid_id_o <= 1'b0;
			instr_rdata_id_o <= 1'sb0;
			is_fetch_failed_o <= 1'b0;
			pc_id_o <= 1'sb0;
			is_compressed_id_o <= 1'b0;
			illegal_c_insn_id_o <= 1'b0;
		end
		else if (if_valid && instr_valid) begin
			instr_valid_id_o <= 1'b1;
			instr_rdata_id_o <= instr_decompressed;
			is_compressed_id_o <= instr_compressed_int;
			illegal_c_insn_id_o <= illegal_c_insn;
			is_fetch_failed_o <= 1'b0;
			pc_id_o <= pc_if_o;
		end
		else if (clear_instr_valid_i) begin
			instr_valid_id_o <= 1'b0;
			is_fetch_failed_o <= fetch_failed;
		end
	end
// ... unrelated original RTL lines 8936-8937 omitted ...
	cv32e40p_aligner aligner_i(
		.clk(clk),
		.rst_n(rst_n),
		.fetch_valid_i(fetch_valid),
		.aligner_ready_o(aligner_ready),
		.if_valid_i(if_valid),
		.fetch_rdata_i(fetch_rdata),
		.instr_aligned_o(instr_aligned),
		.instr_valid_o(instr_valid),
		.branch_addr_i({branch_addr_n[31:1], 1'b0}),
		.branch_i(branch_req),
		.hwlp_addr_i(hwlp_target_i),
		.hwlp_update_pc_i(hwlp_jump_i),
		.pc_o(pc_if_o)
	);
// ... unrelated original RTL lines 8953-10427 omitted ...
	) core_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.pulp_clock_en_i(pulp_clock_en_i),
		.scan_cg_en_i(scan_cg_en_i),
		.boot_addr_i(boot_addr_i),
		.mtvec_addr_i(mtvec_addr_i),
		.dm_halt_addr_i(dm_halt_addr_i),
		.hart_id_i(hart_id_i),
		.dm_exception_addr_i(dm_exception_addr_i),
		.instr_req_o(instr_req_o),
		.instr_gnt_i(instr_gnt_i),
		.instr_rvalid_i(instr_rvalid_i),
		.instr_addr_o(instr_addr_o),
		.instr_rdata_i(instr_rdata_i),
		.data_req_o(data_req_o),
		.data_gnt_i(data_gnt_i),
		.data_rvalid_i(data_rvalid_i),
		.data_we_o(data_we_o),
		.data_be_o(data_be_o),
		.data_addr_o(data_addr_o),
		.data_wdata_o(data_wdata_o),
		.data_rdata_i(data_rdata_i),
		.apu_busy_o(apu_busy),
		.apu_req_o(apu_req),
		.apu_gnt_i(apu_gnt),
		.apu_operands_o(apu_operands),
		.apu_op_o(apu_op),
		.apu_flags_o(apu_flags),
		.apu_rvalid_i(apu_rvalid),
		.apu_result_i(apu_rdata),
		.apu_flags_i(apu_rflags),
		.irq_i(irq_i),
		.irq_ack_o(irq_ack_o),
		.irq_id_o(irq_id_o),
		.debug_req_i(debug_req_i),
		.debug_havereset_o(debug_havereset_o),
		.debug_running_o(debug_running_o),
		.debug_halted_o(debug_halted_o),
		.fetch_enable_i(fetch_enable_i),
		.core_sleep_o(core_sleep_o)
	);

// ----------------------------------------------------------------------------
// Original source: cv32e40p_cs_registers.sv
// Source contains multiple sv2v-lowered CV32E40P modules
// ----------------------------------------------------------------------------
  always_comb begin
    csr_wdata_int = csr_wdata_i;
    csr_we_int    = 1'b1;

    case (csr_op_i)
      CSR_OP_WRITE: csr_wdata_int = csr_wdata_i;
      CSR_OP_SET:   csr_wdata_int = csr_wdata_i | csr_rdata_o;
      CSR_OP_CLEAR: csr_wdata_int = (~csr_wdata_i) & csr_rdata_o;

      CSR_OP_READ: begin
        csr_wdata_int = csr_wdata_i;
        csr_we_int    = 1'b0;
      end
    endcase
  end
