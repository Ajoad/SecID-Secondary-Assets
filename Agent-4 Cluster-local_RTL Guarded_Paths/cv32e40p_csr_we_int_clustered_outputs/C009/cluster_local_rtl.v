// ============================================================================
// Cluster-local relation RTL: C009 -> cv32e40p_top.core_i.cs_registers_i.csr_we_int
// Source-faithful CV32E40P analysis-RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 3 RTL-proximal candidates. Members: cv32e40p_top.core_i.id_stage_i.imm_clip_type, cv32e40p_top.core_i.id_stage_i.register_file_i.we_a_dec, cv32e40p_top.core_i.id_stage_i.register_file_i.we_b_dec. Per-candidate guarded structural paths remain in separate JSON files; this shared file supplies only the cluster-local RTL context.
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
// ... unrelated original RTL lines 2777-2778 omitted ...
		.rst_n(rst_ni),
// ... unrelated original RTL lines 2780-2801 omitted ...
		.id_ready_o(id_ready),
		.ex_ready_i(ex_ready),
// ... unrelated original RTL lines 2804-2804 omitted ...
		.id_valid_o(id_valid),
// ... unrelated original RTL lines 2806-2809 omitted ...
		.alu_operand_a_ex_o(alu_operand_a_ex),
		.alu_operand_b_ex_o(alu_operand_b_ex),
// ... unrelated original RTL lines 2812-2856 omitted ...
		.csr_op_ex_o(csr_op_ex),
// ... unrelated original RTL lines 2858-2880 omitted ...
		.prepost_useincr_ex_o(useincr_addr_ex),
		.data_misaligned_i(data_misaligned),
// ... unrelated original RTL lines 2883-2913 omitted ...
		.mult_multicycle_i(mult_multicycle),
// ... unrelated original RTL lines 2915-2927 omitted ...
	);
// ... unrelated original RTL lines 2929-2935 omitted ...
	) ex_stage_i(
// ... unrelated original RTL lines 2937-3001 omitted ...
		.branch_in_ex_i(branch_in_ex),
// ... unrelated original RTL lines 3003-3019 omitted ...
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
// ... unrelated original RTL lines 3342-4330 omitted ...
	input wire deassert_we_i;
// ... unrelated original RTL lines 4332-4355 omitted ...
	output wire alu_en_o;
// ... unrelated original RTL lines 4357-4426 omitted ...
	reg alu_en;
// ... unrelated original RTL lines 4428-6633 omitted ...
	assign alu_en_o = (deassert_we_i ? 1'b0 : alu_en);
// ... unrelated original RTL lines 6635-6807 omitted ...
	input wire branch_in_ex_i;
// ... unrelated original RTL lines 6809-6827 omitted ...
	output wire ex_ready_o;
// ... unrelated original RTL lines 6829-7044 omitted ...
	assign ex_ready_o = (((((~apu_stall & alu_ready) & mult_ready) & lsu_ready_ex_i) & wb_ready_i) & ~wb_contention) | branch_in_ex_i;
// ... unrelated original RTL lines 7046-7485 omitted ...
	output wire id_ready_o;
	input wire ex_ready_i;
// ... unrelated original RTL lines 7488-7488 omitted ...
	output wire id_valid_o;
// ... unrelated original RTL lines 7490-7491 omitted ...
	output reg [31:0] alu_operand_a_ex_o;
	output reg [31:0] alu_operand_b_ex_o;
// ... unrelated original RTL lines 7494-7544 omitted ...
	output reg [1:0] csr_op_ex_o;
// ... unrelated original RTL lines 7546-7567 omitted ...
	output reg prepost_useincr_ex_o;
	input wire data_misaligned_i;
// ... unrelated original RTL lines 7570-7597 omitted ...
	input wire [31:0] regfile_wdata_wb_i;
// ... unrelated original RTL lines 7599-7601 omitted ...
	input wire [31:0] regfile_alu_wdata_fw_i;
	input wire mult_multicycle_i;
// ... unrelated original RTL lines 7604-7640 omitted ...
	wire misaligned_stall;
// ... unrelated original RTL lines 7642-7662 omitted ...
	reg [31:0] imm_shuffle_type;
	wire [31:0] imm_clip_type;
// ... unrelated original RTL lines 7665-7665 omitted ...
	reg [31:0] imm_b;
// ... unrelated original RTL lines 7667-7682 omitted ...
	wire [31:0] regfile_data_ra_id;
// ... unrelated original RTL lines 7684-7685 omitted ...
	wire alu_en;
// ... unrelated original RTL lines 7687-7688 omitted ...
	wire [2:0] alu_op_b_mux_sel;
// ... unrelated original RTL lines 7690-7692 omitted ...
	wire [3:0] imm_b_mux_sel;
// ... unrelated original RTL lines 7694-7744 omitted ...
	wire [1:0] operand_a_fw_mux_sel;
// ... unrelated original RTL lines 7746-7747 omitted ...
	reg [31:0] operand_a_fw_id;
	reg [31:0] operand_b_fw_id;
// ... unrelated original RTL lines 7750-7750 omitted ...
	reg [31:0] operand_b;
	reg [31:0] operand_b_vec;
// ... unrelated original RTL lines 7753-7755 omitted ...
	wire [31:0] alu_operand_b;
// ... unrelated original RTL lines 7757-7804 omitted ...
	assign imm_clip_type = (32'h00000001 << instr[24:20]) - 1;
// ... unrelated original RTL lines 7806-7952 omitted ...
	assign alu_operand_b = (scalar_replication == 1'b1 ? operand_b_vec : operand_b);
// ... unrelated original RTL lines 7954-8197 omitted ...
	) register_file_i(
// ... unrelated original RTL lines 8199-8199 omitted ...
		.rst_n(rst_n),
// ... unrelated original RTL lines 8201-8202 omitted ...
		.rdata_a_o(regfile_data_ra_id),
// ... unrelated original RTL lines 8204-8209 omitted ...
		.we_a_i(regfile_we_wb_power_i),
// ... unrelated original RTL lines 8211-8211 omitted ...
		.wdata_b_i(regfile_alu_wdata_fw_i),
		.we_b_i(regfile_alu_we_fw_power_i)
	);
// ... unrelated original RTL lines 8215-8226 omitted ...
	) decoder_i(
		.deassert_we_i(deassert_we),
// ... unrelated original RTL lines 8229-8252 omitted ...
		.alu_en_o(alu_en),
// ... unrelated original RTL lines 8254-8308 omitted ...
	);
// ... unrelated original RTL lines 8310-8572 omitted ...
		else if (data_misaligned_i) begin
			if (ex_ready_i) begin
				if (prepost_useincr_ex_o == 1'b1)
					alu_operand_a_ex_o <= operand_a_fw_id;
// ... unrelated original RTL lines 8577-8582 omitted ...
		else if (mult_multicycle_i)
			mult_operand_c_ex_o <= operand_c_fw_id;
		else if (id_valid_o) begin
			alu_en_ex_o <= alu_en;
			if (alu_en) begin
				alu_operator_ex_o <= alu_operator;
// ... unrelated original RTL lines 8589-8589 omitted ...
				if ((alu_op_b_mux_sel == cv32e40p_pkg_OP_B_REGB_OR_FWD) && ((alu_operator == sv2v_cast_C07C4(7'b0010110)) || (alu_operator == sv2v_cast_C07C4(7'b0010111))))
					alu_operand_b_ex_o <= {1'b0, alu_operand_b[30:0]};
// ... unrelated original RTL lines 8592-8704 omitted ...
	assign id_valid_o = ~halt_id & id_ready_o;
// ... unrelated original RTL lines 8706-9144 omitted ...
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
// ... unrelated original RTL lines 9378-9482 omitted ...
	output reg multicycle_o;
// ... unrelated original RTL lines 9484-10182 omitted ...
	input wire rst_n;
// ... unrelated original RTL lines 10184-10185 omitted ...
	output wire [DATA_WIDTH - 1:0] rdata_a_o;
// ... unrelated original RTL lines 10187-10192 omitted ...
	input wire we_a_i;
// ... unrelated original RTL lines 10194-10194 omitted ...
	input wire [DATA_WIDTH - 1:0] wdata_b_i;
	input wire we_b_i;
// ... unrelated original RTL lines 10197-10199 omitted ...
	reg [(NUM_WORDS * DATA_WIDTH) - 1:0] mem;
// ... unrelated original RTL lines 10201-10203 omitted ...
	wire [NUM_TOT_WORDS - 1:0] we_a_dec;
	wire [NUM_TOT_WORDS - 1:0] we_b_dec;
	assign rdata_a_o = (raddr_a_i[5] ? mem_fp[raddr_a_i[4:0] * DATA_WIDTH+:DATA_WIDTH] : mem[raddr_a_i[4:0] * DATA_WIDTH+:DATA_WIDTH]);
// ... unrelated original RTL lines 10207-10214 omitted ...
			assign we_a_dec[gidx] = (waddr_a == gidx ? we_a_i : 1'b0);
			assign we_b_dec[gidx] = (waddr_b == gidx ? we_b_i : 1'b0);
// ... unrelated original RTL lines 10217-10228 omitted ...
			always @(posedge clk or negedge rst_n) begin : register_write_behavioral
				if (rst_n == 1'b0)
					mem[i * DATA_WIDTH+:DATA_WIDTH] <= 32'b00000000000000000000000000000000;
				else if (we_b_dec[i] == 1'b1)
					mem[i * DATA_WIDTH+:DATA_WIDTH] <= wdata_b_i;
				else if (we_a_dec[i] == 1'b1)
					mem[i * DATA_WIDTH+:DATA_WIDTH] <= wdata_a_i;
			end
// ... unrelated original RTL lines 10237-10427 omitted ...
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
