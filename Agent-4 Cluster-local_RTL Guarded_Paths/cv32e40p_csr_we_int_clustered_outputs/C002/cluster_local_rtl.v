// ============================================================================
// Cluster-local relation RTL: C002 -> cv32e40p_top.core_i.cs_registers_i.csr_we_int
// Source-faithful CV32E40P analysis-RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 3 RTL-proximal candidates. Members: cv32e40p_top.core_i.cs_registers_i.csr_mie_wdata, cv32e40p_top.core_i.cs_registers_i.mstatus_n, cv32e40p_top.core_i.id_stage_i.halt_id. Per-candidate guarded structural paths remain in separate JSON files; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: cv32e40p_analysis_lowered.v
// Source contains multiple sv2v-lowered CV32E40P modules
// ----------------------------------------------------------------------------
	input wire irq_req_ctrl_i;
// ... unrelated original RTL lines 1475-1523 omitted ...
	output reg halt_id_o;
// ... unrelated original RTL lines 1525-1532 omitted ...
	reg [4:0] ctrl_fsm_cs;
// ... unrelated original RTL lines 1534-1687 omitted ...
				if (irq_req_ctrl_i && ~(debug_req_pending || debug_mode_q)) begin
					halt_if_o = 1'b1;
// ... unrelated original RTL lines 1690-2449 omitted ...
	input wire rst_ni;
// ... unrelated original RTL lines 2451-2775 omitted ...
	) id_stage_i(
// ... unrelated original RTL lines 2777-2801 omitted ...
		.id_ready_o(id_ready),
// ... unrelated original RTL lines 2803-2804 omitted ...
		.id_valid_o(id_valid),
// ... unrelated original RTL lines 2806-2856 omitted ...
		.csr_op_ex_o(csr_op_ex),
// ... unrelated original RTL lines 2858-2886 omitted ...
		.mie_bypass_i(mie_bypass),
// ... unrelated original RTL lines 2888-2927 omitted ...
	);
// ... unrelated original RTL lines 2929-3071 omitted ...
	) cs_registers_i(
// ... unrelated original RTL lines 3073-3073 omitted ...
		.rst_n(rst_ni),
// ... unrelated original RTL lines 3075-3083 omitted ...
		.csr_op_i(csr_op),
// ... unrelated original RTL lines 3085-3090 omitted ...
		.mie_bypass_o(mie_bypass),
// ... unrelated original RTL lines 3092-3092 omitted ...
		.m_irq_enable_o(m_irq_enable),
// ... unrelated original RTL lines 3094-3139 omitted ...
	);
// ... unrelated original RTL lines 3141-3245 omitted ...
	input wire rst_n;
// ... unrelated original RTL lines 3247-3256 omitted ...
	input wire [1:0] csr_op_i;
// ... unrelated original RTL lines 3258-3264 omitted ...
	output wire [31:0] mie_bypass_o;
// ... unrelated original RTL lines 3266-3266 omitted ...
	output wire m_irq_enable_o;
// ... unrelated original RTL lines 3268-3290 omitted ...
	input wire csr_restore_mret_i;
// ... unrelated original RTL lines 3292-3340 omitted ...
	reg csr_we_int;
// ... unrelated original RTL lines 3342-3367 omitted ...
	reg [6:0] mstatus_q;
	reg [6:0] mstatus_n;
// ... unrelated original RTL lines 3370-3385 omitted ...
	reg [31:0] mie_q;
// ... unrelated original RTL lines 3387-3387 omitted ...
	reg [31:0] csr_mie_wdata;
	reg csr_mie_we;
// ... unrelated original RTL lines 3390-3431 omitted ...
	assign mie_bypass_o = ((csr_addr_i == 12'h304) && csr_mie_we ? csr_mie_wdata & cv32e40p_pkg_IRQ_MASK : mie_q);
// ... unrelated original RTL lines 3433-3930 omitted ...
	assign m_irq_enable_o = mstatus_q[5] && !(dcsr_q[2] && !dcsr_q[11]);
// ... unrelated original RTL lines 3932-4012 omitted ...
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
// ... unrelated original RTL lines 4055-7485 omitted ...
	output wire id_ready_o;
// ... unrelated original RTL lines 7487-7488 omitted ...
	output wire id_valid_o;
// ... unrelated original RTL lines 7490-7544 omitted ...
	output reg [1:0] csr_op_ex_o;
// ... unrelated original RTL lines 7546-7645 omitted ...
	wire halt_id;
// ... unrelated original RTL lines 7647-7741 omitted ...
	wire [1:0] csr_op;
// ... unrelated original RTL lines 7743-8313 omitted ...
	) controller_i(
// ... unrelated original RTL lines 8315-8365 omitted ...
		.irq_req_ctrl_i(irq_req_ctrl),
// ... unrelated original RTL lines 8367-8422 omitted ...
	);
	cv32e40p_int_controller #(.PULP_SECURE(PULP_SECURE)) int_controller_i(
// ... unrelated original RTL lines 8425-8428 omitted ...
		.irq_req_ctrl_o(irq_req_ctrl),
// ... unrelated original RTL lines 8430-8432 omitted ...
		.mie_bypass_i(mie_bypass_i),
// ... unrelated original RTL lines 8434-8437 omitted ...
	);
// ... unrelated original RTL lines 8439-8584 omitted ...
		else if (id_valid_o) begin
			alu_en_ex_o <= alu_en;
// ... unrelated original RTL lines 8587-8704 omitted ...
	assign id_valid_o = ~halt_id & id_ready_o;
// ... unrelated original RTL lines 8706-8984 omitted ...
	output wire irq_req_ctrl_o;
// ... unrelated original RTL lines 8986-8988 omitted ...
	input wire [31:0] mie_bypass_i;
// ... unrelated original RTL lines 8990-8993 omitted ...
	wire global_irq_enable;
	wire [31:0] irq_local_qual;
// ... unrelated original RTL lines 8996-9008 omitted ...
	assign irq_local_qual = irq_q & mie_bypass_i;
// ... unrelated original RTL lines 9010-9018 omitted ...
	assign irq_req_ctrl_o = |irq_local_qual && global_irq_enable;
// ... unrelated original RTL lines 9020-10427 omitted ...
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
