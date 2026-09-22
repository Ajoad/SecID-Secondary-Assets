// ============================================================================
// Cluster-local relation RTL: C004 -> cv32e40p_top.core_i.cs_registers_i.csr_we_int
// Source-faithful CV32E40P analysis-RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 4 RTL-proximal candidates. Members: cv32e40p_top.core_i.csr_op, cv32e40p_top.core_i.data_misaligned, cv32e40p_top.core_i.load_store_unit_i.data_addr_int, cv32e40p_top.core_i.mult_multicycle. Per-candidate guarded structural paths remain in separate JSON files; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: cv32e40p_analysis_lowered.v
// Source contains multiple sv2v-lowered CV32E40P modules
// ----------------------------------------------------------------------------
	input wire rst_ni;
// ... unrelated original RTL lines 2451-2520 omitted ...
	wire data_misaligned;
	wire mult_multicycle;
// ... unrelated original RTL lines 2523-2603 omitted ...
	wire [1:0] csr_op;
// ... unrelated original RTL lines 2605-2775 omitted ...
	) id_stage_i(
// ... unrelated original RTL lines 2777-2856 omitted ...
		.csr_op_ex_o(csr_op_ex),
// ... unrelated original RTL lines 2858-2927 omitted ...
	);
// ... unrelated original RTL lines 2929-3023 omitted ...
	cv32e40p_load_store_unit #(.PULP_OBI(PULP_OBI)) load_store_unit_i(
// ... unrelated original RTL lines 3025-3039 omitted ...
		.data_type_ex_i(data_type_ex),
// ... unrelated original RTL lines 3041-3045 omitted ...
		.data_req_ex_i(data_req_ex),
		.operand_a_ex_i(alu_operand_a_ex),
// ... unrelated original RTL lines 3048-3048 omitted ...
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
// ... unrelated original RTL lines 3342-7544 omitted ...
	output reg [1:0] csr_op_ex_o;
// ... unrelated original RTL lines 7546-7640 omitted ...
	wire misaligned_stall;
// ... unrelated original RTL lines 7642-9144 omitted ...
	input wire [1:0] data_type_ex_i;
// ... unrelated original RTL lines 9146-9150 omitted ...
	input wire data_req_ex_i;
	input wire [31:0] operand_a_ex_i;
// ... unrelated original RTL lines 9153-9153 omitted ...
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
// ... unrelated original RTL lines 9484-10427 omitted ...
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
