// ============================================================================
// Cluster-local relation RTL: C007 -> cv32e40p_top.core_i.cs_registers_i.csr_we_int
// Source-faithful CV32E40P analysis-RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 4 RTL-proximal candidates. Members: cv32e40p_top.core_i.ex_stage_i.alu_i.shift_amt, cv32e40p_top.core_i.ex_stage_i.alu_i.shift_amt_int, cv32e40p_top.core_i.ex_stage_i.alu_i.shift_amt_left, cv32e40p_top.core_i.ex_stage_i.alu_i.shift_amt_norm. Per-candidate guarded structural paths remain in separate JSON files; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: cv32e40p_analysis_lowered.v
// Source contains multiple sv2v-lowered CV32E40P modules
// ----------------------------------------------------------------------------
	input wire [31:0] operand_b_i;
// ... unrelated original RTL lines 183-183 omitted ...
	input wire [1:0] vector_mode_i;
// ... unrelated original RTL lines 185-185 omitted ...
	input wire [4:0] bmask_b_i;
// ... unrelated original RTL lines 187-187 omitted ...
	input wire is_clpx_i;
// ... unrelated original RTL lines 189-190 omitted ...
	output reg [31:0] result_o;
// ... unrelated original RTL lines 192-214 omitted ...
	wire [5:0] div_shift;
	wire div_valid;
// ... unrelated original RTL lines 217-279 omitted ...
	wire shift_left;
	wire shift_use_round;
// ... unrelated original RTL lines 282-282 omitted ...
	reg [31:0] shift_amt_left;
	wire [31:0] shift_amt;
	wire [31:0] shift_amt_int;
	wire [31:0] shift_amt_norm;
// ... unrelated original RTL lines 287-287 omitted ...
	wire [31:0] shift_result;
// ... unrelated original RTL lines 289-289 omitted ...
	wire [31:0] shift_left_result;
	wire [15:0] clpx_shift_ex;
	assign shift_amt = (div_valid ? div_shift : operand_b_i);
// ... unrelated original RTL lines 293-309 omitted ...
	assign shift_left = ((((((((operator_i == sv2v_cast_C07C4(7'b0100111)) || (operator_i == sv2v_cast_C07C4(7'b0101010))) || (operator_i == sv2v_cast_C07C4(7'b0110111))) || (operator_i == sv2v_cast_C07C4(7'b0110101))) || (operator_i == sv2v_cast_C07C4(7'b0110001))) || (operator_i == sv2v_cast_C07C4(7'b0110000))) || (operator_i == sv2v_cast_C07C4(7'b0110011))) || (operator_i == sv2v_cast_C07C4(7'b0110010))) || (operator_i == sv2v_cast_C07C4(7'b1001001));
	assign shift_use_round = (((((((operator_i == sv2v_cast_C07C4(7'b0011000)) || (operator_i == sv2v_cast_C07C4(7'b0011001))) || (operator_i == sv2v_cast_C07C4(7'b0011100))) || (operator_i == sv2v_cast_C07C4(7'b0011101))) || (operator_i == sv2v_cast_C07C4(7'b0011010))) || (operator_i == sv2v_cast_C07C4(7'b0011011))) || (operator_i == sv2v_cast_C07C4(7'b0011110))) || (operator_i == sv2v_cast_C07C4(7'b0011111));
// ... unrelated original RTL lines 312-313 omitted ...
	assign shift_amt_int = (shift_use_round ? shift_amt_norm : (shift_left ? shift_amt_left : shift_amt));
	assign shift_amt_norm = (is_clpx_i ? {clpx_shift_ex, clpx_shift_ex} : {4 {3'b000, bmask_b_i}});
// ... unrelated original RTL lines 316-323 omitted ...
				shift_right_result[31:16] = $signed({shift_arithmetic & shift_op_a[31], shift_op_a[31:16]}) >>> shift_amt_int[19:16];
				shift_right_result[15:0] = $signed({shift_arithmetic & shift_op_a[15], shift_op_a[15:0]}) >>> shift_amt_int[3:0];
// ... unrelated original RTL lines 326-327 omitted ...
				shift_right_result[31:24] = $signed({shift_arithmetic & shift_op_a[31], shift_op_a[31:24]}) >>> shift_amt_int[26:24];
				shift_right_result[23:16] = $signed({shift_arithmetic & shift_op_a[23], shift_op_a[23:16]}) >>> shift_amt_int[18:16];
				shift_right_result[15:8] = $signed({shift_arithmetic & shift_op_a[15], shift_op_a[15:8]}) >>> shift_amt_int[10:8];
				shift_right_result[7:0] = $signed({shift_arithmetic & shift_op_a[7], shift_op_a[7:0]}) >>> shift_amt_int[2:0];
// ... unrelated original RTL lines 332-332 omitted ...
			default: shift_right_result = shift_op_a_32 >> shift_amt_int[4:0];
// ... unrelated original RTL lines 334-342 omitted ...
	assign shift_result = (shift_left ? shift_left_result : shift_right_result);
// ... unrelated original RTL lines 344-472 omitted ...
				if (vector_mode_i == cv32e40p_pkg_VEC_MODE8) begin
					shuffle_reg_sel[3:1] = 3'b111;
// ... unrelated original RTL lines 475-703 omitted ...
	wire extract_is_signed;
// ... unrelated original RTL lines 705-708 omitted ...
	wire [31:0] bextins_result;
// ... unrelated original RTL lines 710-720 omitted ...
	wire [31:0] radix_2_rev;
// ... unrelated original RTL lines 722-831 omitted ...
	input wire [C_WIDTH - 1:0] OpB_DI;
// ... unrelated original RTL lines 833-2449 omitted ...
	input wire rst_ni;
// ... unrelated original RTL lines 2451-2775 omitted ...
	) id_stage_i(
// ... unrelated original RTL lines 2777-2802 omitted ...
		.ex_ready_i(ex_ready),
// ... unrelated original RTL lines 2804-2807 omitted ...
		.alu_en_ex_o(alu_en_ex),
// ... unrelated original RTL lines 2809-2809 omitted ...
		.alu_operand_a_ex_o(alu_operand_a_ex),
// ... unrelated original RTL lines 2811-2824 omitted ...
		.mult_en_ex_o(mult_en_ex),
// ... unrelated original RTL lines 2826-2855 omitted ...
		.csr_access_ex_o(csr_access_ex),
		.csr_op_ex_o(csr_op_ex),
// ... unrelated original RTL lines 2858-2880 omitted ...
		.prepost_useincr_ex_o(useincr_addr_ex),
		.data_misaligned_i(data_misaligned),
// ... unrelated original RTL lines 2883-2927 omitted ...
	);
// ... unrelated original RTL lines 2929-2935 omitted ...
	) ex_stage_i(
// ... unrelated original RTL lines 2937-2938 omitted ...
		.alu_en_i(alu_en_ex),
// ... unrelated original RTL lines 2940-2944 omitted ...
		.bmask_b_i(bmask_b_ex),
// ... unrelated original RTL lines 2946-2954 omitted ...
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
// ... unrelated original RTL lines 3342-6749 omitted ...
	input wire alu_en_i;
// ... unrelated original RTL lines 6751-6762 omitted ...
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
// ... unrelated original RTL lines 6829-6830 omitted ...
	wire [31:0] alu_result;
	wire [31:0] mult_result;
// ... unrelated original RTL lines 6833-6872 omitted ...
			if (alu_en_i)
				regfile_alu_wdata_fw_o = alu_result;
			if (mult_en_i)
				regfile_alu_wdata_fw_o = mult_result;
			if (csr_access_i)
				regfile_alu_wdata_fw_o = csr_rdata_i;
// ... unrelated original RTL lines 6879-6903 omitted ...
	cv32e40p_alu alu_i(
// ... unrelated original RTL lines 6905-6909 omitted ...
		.operand_b_i(alu_operand_b_i),
// ... unrelated original RTL lines 6911-6911 omitted ...
		.vector_mode_i(alu_vec_mode_i),
// ... unrelated original RTL lines 6913-6913 omitted ...
		.bmask_b_i(bmask_b_i),
// ... unrelated original RTL lines 6915-6915 omitted ...
		.is_clpx_i(alu_is_clpx_i),
// ... unrelated original RTL lines 6917-6922 omitted ...
	);
// ... unrelated original RTL lines 6924-7044 omitted ...
	assign ex_ready_o = (((((~apu_stall & alu_ready) & mult_ready) & lsu_ready_ex_i) & wb_ready_i) & ~wb_contention) | branch_in_ex_i;
// ... unrelated original RTL lines 7046-7486 omitted ...
	input wire ex_ready_i;
// ... unrelated original RTL lines 7488-7491 omitted ...
	output reg [31:0] alu_operand_a_ex_o;
// ... unrelated original RTL lines 7493-7502 omitted ...
	output reg alu_en_ex_o;
// ... unrelated original RTL lines 7504-7513 omitted ...
	output reg mult_en_ex_o;
// ... unrelated original RTL lines 7515-7542 omitted ...
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
// ... unrelated original RTL lines 9378-10427 omitted ...
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
