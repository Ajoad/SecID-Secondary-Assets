// ============================================================================
// Cluster-local relation RTL: C000 -> cv32e40p_top.core_i.cs_registers_i.csr_we_int
// Source-faithful CV32E40P analysis-RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 4 RTL-proximal candidates. Members: cv32e40p_top.core_i.apu_lat_ex, cv32e40p_top.core_i.ex_ready, cv32e40p_top.core_i.id_ready, cv32e40p_top.core_i.id_valid. Per-candidate guarded structural paths remain in separate JSON files; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: cv32e40p_analysis_lowered.v
// Source contains multiple sv2v-lowered CV32E40P modules
// ----------------------------------------------------------------------------
	input wire rst_ni;
// ... unrelated original RTL lines 2451-2570 omitted ...
	wire [1:0] apu_lat_ex;
// ... unrelated original RTL lines 2572-2621 omitted ...
	wire id_ready;
	wire ex_ready;
	wire id_valid;
// ... unrelated original RTL lines 2625-2775 omitted ...
	) id_stage_i(
// ... unrelated original RTL lines 2777-2801 omitted ...
		.id_ready_o(id_ready),
		.ex_ready_i(ex_ready),
// ... unrelated original RTL lines 2804-2804 omitted ...
		.id_valid_o(id_valid),
// ... unrelated original RTL lines 2806-2842 omitted ...
		.apu_lat_ex_o(apu_lat_ex),
// ... unrelated original RTL lines 2844-2856 omitted ...
		.csr_op_ex_o(csr_op_ex),
// ... unrelated original RTL lines 2858-2927 omitted ...
	);
// ... unrelated original RTL lines 2929-2935 omitted ...
	) ex_stage_i(
// ... unrelated original RTL lines 2937-3001 omitted ...
		.branch_in_ex_i(branch_in_ex),
// ... unrelated original RTL lines 3003-3019 omitted ...
		.ex_ready_o(ex_ready),
// ... unrelated original RTL lines 3021-3022 omitted ...
	);
// ... unrelated original RTL lines 3024-3071 omitted ...
	) cs_registers_i(
// ... unrelated original RTL lines 3073-3083 omitted ...
		.csr_op_i(csr_op),
// ... unrelated original RTL lines 3085-3139 omitted ...
	);
// ... unrelated original RTL lines 3141-3256 omitted ...
	input wire [1:0] csr_op_i;
// ... unrelated original RTL lines 3258-3340 omitted ...
	reg csr_we_int;
// ... unrelated original RTL lines 3342-6807 omitted ...
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
// ... unrelated original RTL lines 7490-7526 omitted ...
	output reg [1:0] apu_lat_ex_o;
// ... unrelated original RTL lines 7528-7544 omitted ...
	output reg [1:0] csr_op_ex_o;
// ... unrelated original RTL lines 7546-7643 omitted ...
	wire csr_apu_stall;
// ... unrelated original RTL lines 7645-7741 omitted ...
	wire [1:0] csr_op;
// ... unrelated original RTL lines 7743-8191 omitted ...
	assign csr_apu_stall = csr_access & ((apu_en_ex_o & (apu_lat_ex_o[1] == 1'b1)) | apu_busy_i);
// ... unrelated original RTL lines 8193-8584 omitted ...
		else if (id_valid_o) begin
			alu_en_ex_o <= alu_en;
// ... unrelated original RTL lines 8587-8655 omitted ...
		else if (ex_ready_i) begin
			regfile_we_ex_o <= 1'b0;
// ... unrelated original RTL lines 8658-8703 omitted ...
	assign id_ready_o = ((((~misaligned_stall & ~jr_stall) & ~load_stall) & ~apu_stall) & ~csr_apu_stall) & ex_ready_i;
	assign id_valid_o = ~halt_id & id_ready_o;
// ... unrelated original RTL lines 8706-10427 omitted ...
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
