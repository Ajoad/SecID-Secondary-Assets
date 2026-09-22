// ============================================================================
// Cluster-local relation RTL: C003 -> cv32e40p_top.core_i.cs_registers_i.csr_we_int
// Source-faithful CV32E40P analysis-RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 4 RTL-proximal candidates. Members: cv32e40p_top.core_i.cs_registers_i.dcsr_n, cv32e40p_top.core_i.cs_registers_i.mhpmcounter_write_lower, cv32e40p_top.core_i.cs_registers_i.mhpmcounter_write_upper, cv32e40p_top.core_i.mtvec_addr_i. Per-candidate guarded structural paths remain in separate JSON files; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: cv32e40p_analysis_lowered.v
// Source contains multiple sv2v-lowered CV32E40P modules
// ----------------------------------------------------------------------------
	input wire rst_ni;
// ... unrelated original RTL lines 2451-2453 omitted ...
	input wire [31:0] mtvec_addr_i;
// ... unrelated original RTL lines 2455-2715 omitted ...
	) if_stage_i(
// ... unrelated original RTL lines 2717-2736 omitted ...
		.pc_set_i(pc_set),
// ... unrelated original RTL lines 2738-2748 omitted ...
		.csr_mtvec_init_o(csr_mtvec_init),
// ... unrelated original RTL lines 2750-2757 omitted ...
	);
// ... unrelated original RTL lines 2759-2775 omitted ...
	) id_stage_i(
// ... unrelated original RTL lines 2777-2802 omitted ...
		.ex_ready_i(ex_ready),
// ... unrelated original RTL lines 2804-2809 omitted ...
		.alu_operand_a_ex_o(alu_operand_a_ex),
// ... unrelated original RTL lines 2811-2855 omitted ...
		.csr_access_ex_o(csr_access_ex),
		.csr_op_ex_o(csr_op_ex),
// ... unrelated original RTL lines 2858-2880 omitted ...
		.prepost_useincr_ex_o(useincr_addr_ex),
		.data_misaligned_i(data_misaligned),
// ... unrelated original RTL lines 2883-2927 omitted ...
	);
// ... unrelated original RTL lines 2929-2935 omitted ...
	) ex_stage_i(
// ... unrelated original RTL lines 2937-2999 omitted ...
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
// ... unrelated original RTL lines 3073-3073 omitted ...
		.rst_n(rst_ni),
// ... unrelated original RTL lines 3075-3079 omitted ...
		.mtvec_addr_i(mtvec_addr_i[31:0]),
		.csr_mtvec_init_i(csr_mtvec_init),
		.csr_addr_i(csr_addr),
// ... unrelated original RTL lines 3083-3083 omitted ...
		.csr_op_i(csr_op),
// ... unrelated original RTL lines 3085-3120 omitted ...
		.csr_save_cause_i(csr_save_cause),
// ... unrelated original RTL lines 3122-3139 omitted ...
	);
// ... unrelated original RTL lines 3141-3245 omitted ...
	input wire rst_n;
// ... unrelated original RTL lines 3247-3247 omitted ...
	output wire [23:0] mtvec_o;
// ... unrelated original RTL lines 3249-3252 omitted ...
	input wire csr_mtvec_init_i;
	input wire [11:0] csr_addr_i;
// ... unrelated original RTL lines 3255-3256 omitted ...
	input wire [1:0] csr_op_i;
	output wire [31:0] csr_rdata_o;
// ... unrelated original RTL lines 3259-3276 omitted ...
	output wire [31:0] depc_o;
// ... unrelated original RTL lines 3278-3294 omitted ...
	input wire csr_save_cause_i;
// ... unrelated original RTL lines 3296-3338 omitted ...
	reg [31:0] csr_wdata_int;
// ... unrelated original RTL lines 3340-3340 omitted ...
	reg csr_we_int;
// ... unrelated original RTL lines 3342-3356 omitted ...
	reg [31:0] dcsr_q;
	reg [31:0] dcsr_n;
// ... unrelated original RTL lines 3359-3360 omitted ...
	reg [31:0] dscratch0_q;
// ... unrelated original RTL lines 3362-3364 omitted ...
	reg [31:0] mscratch_q;
// ... unrelated original RTL lines 3366-3376 omitted ...
	reg [23:0] mtvec_n;
	reg [23:0] mtvec_q;
// ... unrelated original RTL lines 3379-3385 omitted ...
	reg [31:0] mie_q;
// ... unrelated original RTL lines 3387-3397 omitted ...
	reg [2047:0] mhpmcounter_q;
// ... unrelated original RTL lines 3399-3406 omitted ...
	wire [31:0] mhpmcounter_write_lower;
	wire [31:0] mhpmcounter_write_upper;
// ... unrelated original RTL lines 3409-3785 omitted ...
				mtvec_n = (csr_mtvec_init_i ? mtvec_addr_i[31:8] : mtvec_q);
// ... unrelated original RTL lines 3787-4012 omitted ...
	always @(posedge clk or negedge rst_n)
		if (rst_n == 1'b0) begin
			if (FPU == 1) begin
				frm_q <= 1'sb0;
				fflags_q <= 1'sb0;
				if (ZFINX == 0)
					mstatus_fs_q <= 2'b00;
			end
			mstatus_q <= 7'b0000110;
			mepc_q <= 1'sb0;
			mcause_q <= 1'sb0;
			depc_q <= 1'sb0;
			dcsr_q <= {23'h200000, cv32e40p_pkg_DBG_CAUSE_NONE, 6'b000011};
			dscratch0_q <= 1'sb0;
			dscratch1_q <= 1'sb0;
			mscratch_q <= 1'sb0;
			mie_q <= 1'sb0;
			mtvec_q <= 1'sb0;
			mtvec_mode_q <= MTVEC_MODE;
		end
		else begin
			if (FPU == 1) begin
				frm_q <= frm_n;
				fflags_q <= fflags_n;
				if (ZFINX == 0)
					mstatus_fs_q <= mstatus_fs_n;
			end
			if (PULP_SECURE == 1)
				mstatus_q <= mstatus_n;
			else
				mstatus_q <= {1'b0, mstatus_n[5], 1'b0, mstatus_n[3], 3'b110};
			mepc_q <= mepc_n;
			mcause_q <= mcause_n;
			depc_q <= depc_n;
			dcsr_q <= dcsr_n;
			dscratch0_q <= dscratch0_n;
			dscratch1_q <= dscratch1_n;
			mscratch_q <= mscratch_n;
			mie_q <= mie_n;
			mtvec_q <= mtvec_n;
			mtvec_mode_q <= mtvec_mode_n;
		end
// ... unrelated original RTL lines 4055-4131 omitted ...
			assign mhpmcounter_write_lower[wcnt_gidx] = csr_we_int && (csr_addr_i == (12'hb00 + wcnt_gidx));
			assign mhpmcounter_write_upper[wcnt_gidx] = ((!mhpmcounter_write_lower[wcnt_gidx] && csr_we_int) && (csr_addr_i == (12'hb80 + wcnt_gidx))) && 1'd1;
// ... unrelated original RTL lines 4134-4162 omitted ...
				always @(posedge clk or negedge rst_n)
					if (!rst_n)
						mhpmcounter_q[cnt_gidx * 64+:64] <= 'b0;
					else if (mhpmcounter_write_lower[cnt_gidx])
						mhpmcounter_q[(cnt_gidx * 64) + 31-:32] <= csr_wdata_int;
					else if (mhpmcounter_write_upper[cnt_gidx])
						mhpmcounter_q[(cnt_gidx * 64) + 63-:32] <= csr_wdata_int;
					else if (mhpmcounter_write_increment[cnt_gidx])
						mhpmcounter_q[cnt_gidx * 64+:64] <= mhpmcounter_increment[cnt_gidx * 64+:64];
// ... unrelated original RTL lines 4172-6807 omitted ...
	input wire branch_in_ex_i;
// ... unrelated original RTL lines 6809-6812 omitted ...
	input wire csr_access_i;
	input wire [31:0] csr_rdata_i;
// ... unrelated original RTL lines 6815-6821 omitted ...
	output reg [31:0] regfile_alu_wdata_fw_o;
// ... unrelated original RTL lines 6823-6827 omitted ...
	output wire ex_ready_o;
// ... unrelated original RTL lines 6829-6876 omitted ...
			if (csr_access_i)
				regfile_alu_wdata_fw_o = csr_rdata_i;
// ... unrelated original RTL lines 6879-7044 omitted ...
	assign ex_ready_o = (((((~apu_stall & alu_ready) & mult_ready) & lsu_ready_ex_i) & wb_ready_i) & ~wb_contention) | branch_in_ex_i;
// ... unrelated original RTL lines 7046-7486 omitted ...
	input wire ex_ready_i;
// ... unrelated original RTL lines 7488-7491 omitted ...
	output reg [31:0] alu_operand_a_ex_o;
// ... unrelated original RTL lines 7493-7542 omitted ...
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
// ... unrelated original RTL lines 8577-8781 omitted ...
	input wire pc_set_i;
// ... unrelated original RTL lines 8783-8789 omitted ...
	output wire csr_mtvec_init_o;
// ... unrelated original RTL lines 8791-8874 omitted ...
	assign csr_mtvec_init_o = (pc_mux_i == cv32e40p_pkg_PC_BOOT) & pc_set_i;
// ... unrelated original RTL lines 8876-9144 omitted ...
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
