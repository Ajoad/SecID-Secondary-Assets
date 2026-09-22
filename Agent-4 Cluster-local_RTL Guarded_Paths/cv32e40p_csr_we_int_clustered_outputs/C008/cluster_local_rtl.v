// ============================================================================
// Cluster-local relation RTL: C008 -> cv32e40p_top.core_i.cs_registers_i.csr_we_int
// Source-faithful CV32E40P analysis-RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 4 RTL-proximal candidates. Members: cv32e40p_top.core_i.ex_stage_i.mult_i.dot_short_mul, cv32e40p_top.core_i.ex_stage_i.mult_i.dot_short_result, cv32e40p_top.core_i.ex_stage_i.mult_i.short_result, cv32e40p_top.core_i.ex_stage_i.mult_i.short_round_tmp. Per-candidate guarded structural paths remain in separate JSON files; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: cv32e40p_analysis_lowered.v
// Source contains multiple sv2v-lowered CV32E40P modules
// ----------------------------------------------------------------------------
	input wire rst_ni;
// ... unrelated original RTL lines 2451-2775 omitted ...
	) id_stage_i(
// ... unrelated original RTL lines 2777-2802 omitted ...
		.ex_ready_i(ex_ready),
// ... unrelated original RTL lines 2804-2809 omitted ...
		.alu_operand_a_ex_o(alu_operand_a_ex),
// ... unrelated original RTL lines 2811-2824 omitted ...
		.mult_en_ex_o(mult_en_ex),
// ... unrelated original RTL lines 2826-2835 omitted ...
		.mult_is_clpx_ex_o(mult_is_clpx_ex),
// ... unrelated original RTL lines 2837-2855 omitted ...
		.csr_access_ex_o(csr_access_ex),
		.csr_op_ex_o(csr_op_ex),
// ... unrelated original RTL lines 2858-2880 omitted ...
		.prepost_useincr_ex_o(useincr_addr_ex),
		.data_misaligned_i(data_misaligned),
// ... unrelated original RTL lines 2883-2927 omitted ...
	);
// ... unrelated original RTL lines 2929-2935 omitted ...
	) ex_stage_i(
// ... unrelated original RTL lines 2937-2954 omitted ...
		.mult_en_i(mult_en_ex),
// ... unrelated original RTL lines 2956-2999 omitted ...
		.csr_access_i(csr_access_ex),
		.csr_rdata_i(csr_rdata),
		.branch_in_ex_i(branch_in_ex),
// ... unrelated original RTL lines 3003-3015 omitted ...
		.regfile_alu_wdata_fw_o(regfile_alu_wdata_fw),
// ... unrelated original RTL lines 3017-3019 omitted ...
		.ex_ready_o(ex_ready),
// ... unrelated original RTL lines 3021-3022 omitted ...
	);
	cv32e40p_load_store_unit #(.PULP_OBI(PULP_OBI)) load_store_unit_i(
// ... unrelated original RTL lines 3025-3039 omitted ...
		.data_type_ex_i(data_type_ex),
// ... unrelated original RTL lines 3041-3045 omitted ...
		.data_req_ex_i(data_req_ex),
		.operand_a_ex_i(alu_operand_a_ex),
		.operand_b_ex_i(alu_operand_b_ex),
		.addr_useincr_ex_i(useincr_addr_ex),
// ... unrelated original RTL lines 3050-3050 omitted ...
		.data_misaligned_o(data_misaligned),
// ... unrelated original RTL lines 3052-3056 omitted ...
	);
// ... unrelated original RTL lines 3058-3071 omitted ...
	) cs_registers_i(
// ... unrelated original RTL lines 3073-3083 omitted ...
		.csr_op_i(csr_op),
// ... unrelated original RTL lines 3085-3139 omitted ...
	);
// ... unrelated original RTL lines 3141-3256 omitted ...
	input wire [1:0] csr_op_i;
// ... unrelated original RTL lines 3258-3340 omitted ...
	reg csr_we_int;
// ... unrelated original RTL lines 3342-6762 omitted ...
	input wire mult_en_i;
// ... unrelated original RTL lines 6764-6807 omitted ...
	input wire branch_in_ex_i;
// ... unrelated original RTL lines 6809-6812 omitted ...
	input wire csr_access_i;
	input wire [31:0] csr_rdata_i;
// ... unrelated original RTL lines 6815-6821 omitted ...
	output reg [31:0] regfile_alu_wdata_fw_o;
// ... unrelated original RTL lines 6823-6827 omitted ...
	output wire ex_ready_o;
// ... unrelated original RTL lines 6829-6831 omitted ...
	wire [31:0] mult_result;
// ... unrelated original RTL lines 6833-6874 omitted ...
			if (mult_en_i)
				regfile_alu_wdata_fw_o = mult_result;
			if (csr_access_i)
				regfile_alu_wdata_fw_o = csr_rdata_i;
// ... unrelated original RTL lines 6879-6923 omitted ...
	cv32e40p_mult mult_i(
// ... unrelated original RTL lines 6925-6927 omitted ...
		.operator_i(mult_operator_i),
// ... unrelated original RTL lines 6929-6933 omitted ...
		.imm_i(mult_imm_i),
// ... unrelated original RTL lines 6935-6938 omitted ...
		.is_clpx_i(mult_is_clpx_i),
// ... unrelated original RTL lines 6940-6946 omitted ...
	);
// ... unrelated original RTL lines 6948-7044 omitted ...
	assign ex_ready_o = (((((~apu_stall & alu_ready) & mult_ready) & lsu_ready_ex_i) & wb_ready_i) & ~wb_contention) | branch_in_ex_i;
// ... unrelated original RTL lines 7046-7486 omitted ...
	input wire ex_ready_i;
// ... unrelated original RTL lines 7488-7491 omitted ...
	output reg [31:0] alu_operand_a_ex_o;
// ... unrelated original RTL lines 7493-7513 omitted ...
	output reg mult_en_ex_o;
// ... unrelated original RTL lines 7515-7521 omitted ...
	output reg mult_is_clpx_ex_o;
// ... unrelated original RTL lines 7523-7542 omitted ...
	output reg csr_access_ex_o;
// ... unrelated original RTL lines 7544-7544 omitted ...
	output reg [1:0] csr_op_ex_o;
// ... unrelated original RTL lines 7546-7567 omitted ...
	output reg prepost_useincr_ex_o;
	input wire data_misaligned_i;
// ... unrelated original RTL lines 7570-7597 omitted ...
	input wire [31:0] regfile_wdata_wb_i;
// ... unrelated original RTL lines 7599-7601 omitted ...
	input wire [31:0] regfile_alu_wdata_fw_i;
// ... unrelated original RTL lines 7603-7640 omitted ...
	wire misaligned_stall;
// ... unrelated original RTL lines 7642-7682 omitted ...
	wire [31:0] regfile_data_ra_id;
// ... unrelated original RTL lines 7684-7740 omitted ...
	wire csr_access;
// ... unrelated original RTL lines 7742-7744 omitted ...
	wire [1:0] operand_a_fw_mux_sel;
// ... unrelated original RTL lines 7746-7747 omitted ...
	reg [31:0] operand_a_fw_id;
// ... unrelated original RTL lines 7749-8572 omitted ...
		else if (data_misaligned_i) begin
			if (ex_ready_i) begin
				if (prepost_useincr_ex_o == 1'b1)
					alu_operand_a_ex_o <= operand_a_fw_id;
// ... unrelated original RTL lines 8577-9144 omitted ...
	input wire [1:0] data_type_ex_i;
// ... unrelated original RTL lines 9146-9150 omitted ...
	input wire data_req_ex_i;
	input wire [31:0] operand_a_ex_i;
	input wire [31:0] operand_b_ex_i;
	input wire addr_useincr_ex_i;
// ... unrelated original RTL lines 9155-9155 omitted ...
	output reg data_misaligned_o;
// ... unrelated original RTL lines 9157-9179 omitted ...
	wire [31:0] data_addr_int;
// ... unrelated original RTL lines 9181-9366 omitted ...
		if ((data_req_ex_i == 1'b1) && (data_misaligned_ex_i == 1'b0))
			case (data_type_ex_i)
				2'b00:
					if (data_addr_int[1:0] != 2'b00)
						data_misaligned_o = 1'b1;
// ... unrelated original RTL lines 9372-9372 omitted ...
					if (data_addr_int[1:0] == 2'b11)
						data_misaligned_o = 1'b1;
// ... unrelated original RTL lines 9375-9376 omitted ...
	assign data_addr_int = (addr_useincr_ex_i ? operand_a_ex_i + operand_b_ex_i : operand_a_ex_i);
// ... unrelated original RTL lines 9378-9467 omitted ...
	input wire [2:0] operator_i;
// ... unrelated original RTL lines 9469-9473 omitted ...
	input wire [4:0] imm_i;
// ... unrelated original RTL lines 9475-9478 omitted ...
	input wire is_clpx_i;
// ... unrelated original RTL lines 9480-9481 omitted ...
	output reg [31:0] result_o;
// ... unrelated original RTL lines 9483-9490 omitted ...
	wire [33:0] short_mac;
	wire [31:0] short_round;
	wire [31:0] short_round_tmp;
	wire [33:0] short_result;
// ... unrelated original RTL lines 9495-9496 omitted ...
	wire [4:0] short_imm;
// ... unrelated original RTL lines 9498-9510 omitted ...
	assign short_round_tmp = 32'h00000001 << imm_i;
// ... unrelated original RTL lines 9512-9515 omitted ...
	assign short_round = (operator_i == sv2v_cast_9F558(3'b011) ? {1'b0, short_round_tmp[31:1]} : {32 {1'sb0}});
// ... unrelated original RTL lines 9517-9522 omitted ...
	assign short_mac = ($signed(short_op_c) + $signed(short_mul)) + $signed(short_round);
	assign short_result = $signed({short_shift_arith & short_mac_msb1, short_shift_arith & short_mac_msb0, short_mac[31:0]}) >>> short_imm;
// ... unrelated original RTL lines 9525-9607 omitted ...
	wire [31:0] dot_char_result;
	wire [32:0] dot_short_result;
	wire [31:0] accumulator;
// ... unrelated original RTL lines 9611-9614 omitted ...
	wire [33:0] dot_short_op_a;
	wire [33:0] dot_short_op_b;
	wire [67:0] dot_short_mul;
	wire [16:0] dot_short_op_a_1_neg;
// ... unrelated original RTL lines 9619-9637 omitted ...
	assign dot_short_mul[0+:34] = $signed(dot_short_op_a[0+:17]) * $signed(dot_short_op_b[0+:17]);
	assign dot_short_mul[34+:34] = $signed(dot_short_op_a_1_neg) * $signed(dot_short_op_b[17+:17]);
// ... unrelated original RTL lines 9640-9641 omitted ...
	assign dot_short_result = ($signed(dot_short_mul[31-:32]) + $signed(dot_short_mul[65-:32])) + $signed(accumulator);
// ... unrelated original RTL lines 9643-9653 omitted ...
				if (is_clpx_i) begin
					if (clpx_img_i) begin
						result_o[31:16] = clpx_shift_result;
// ... unrelated original RTL lines 9657-10427 omitted ...
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
