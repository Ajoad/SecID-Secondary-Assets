// ============================================================================
// Cluster-local relation RTL: C000 -> axi_adapter_valid_o_cone.valid_o
// Source-faithful AXI-adapter analysis-RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 4 RTL-proximal candidates. Members: axi_adapter_valid_o_cone.amo_d, axi_adapter_valid_o_cone.amo_i, axi_adapter_valid_o_cone.amo_q, axi_adapter_valid_o_cone.axi_resp_i.b_valid. Per-candidate guarded structural paths remain in paths/per_candidate/*.json; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: axi_adapter_valid_o_cone.sv
// Module: axi_adapter_valid_o_cone
// ----------------------------------------------------------------------------
// Analysis-only source-equivalent fan-in cone for axi_adapter.valid_o.
// Derived from the uploaded CVA6/Ariane axi_adapter.sv.
// Case-study parameterization: DATA_WIDTH=256, AXI_DATA_WIDTH=64 => 4 beats,
// BURST_SIZE=3, ADDR_INDEX=2. Datapath-only logic that cannot reach valid_o
// through DATA or CONTROL dependence is intentionally omitted.
module axi_adapter_valid_o_cone (
  input  logic       clk_i,
  input  logic       rst_ni,
  input  logic       req_i,
  input  logic       type_i,       // 0=SINGLE_REQ, 1=CACHE_LINE_REQ
  input  logic [3:0] amo_i,
  input  logic       we_i,
  input  logic       axi_resp_i_aw_ready,
  input  logic       axi_resp_i_w_ready,
  input  logic       axi_resp_i_b_valid,
  input  logic       axi_resp_i_ar_ready,
  input  logic       axi_resp_i_r_valid,
  input  logic       axi_resp_i_r_last,
  output logic       valid_o
);
// ... unrelated original RTL lines 21-35 omitted ...
  localparam logic [3:0]
    AMO_NONE = 4'h0,
    AMO_LR   = 4'h1,
    AMO_SC   = 4'h2,
    AMO_SWAP = 4'h3,
    AMO_ADD  = 4'h4,
    AMO_AND  = 4'h5,
    AMO_OR   = 4'h6,
    AMO_XOR  = 4'h7,
    AMO_MAX  = 4'h8,
    AMO_MAXU = 4'h9,
    AMO_MIN  = 4'hA,
    AMO_MINU = 4'hB,
    AMO_CAS1 = 4'hC,
    AMO_CAS2 = 4'hD;
// ... unrelated original RTL lines 51-51 omitted ...
  (* keep *) logic [3:0] state_q, state_d;
  (* keep *) logic [1:0] cnt_q, cnt_d;
  (* keep *) logic [3:0] amo_q, amo_d;
// ... unrelated original RTL lines 55-55 omitted ...
  function automatic logic amo_returns_data(input logic [3:0] amo);
    unique case (amo)
      AMO_SWAP, AMO_ADD, AMO_AND, AMO_OR, AMO_XOR,
      AMO_MAX, AMO_MAXU, AMO_MIN, AMO_MINU: amo_returns_data = 1'b1;
      default: amo_returns_data = 1'b0;
    endcase
  endfunction
// ... unrelated original RTL lines 63-105 omitted ...
        if (axi_resp_i_aw_ready) begin
          state_d = WAIT_B_VALID;
// ... unrelated original RTL lines 108-147 omitted ...
        if (axi_resp_i_b_valid) begin
          if (amo_returns_data(amo_q)) begin
            if (axi_resp_i_r_valid) begin
              valid_o = 1'b1;
// ... unrelated original RTL lines 152-186 omitted ...
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      state_q <= IDLE;
      cnt_q   <= '0;
      amo_q   <= AMO_NONE;
    end else begin
      state_q <= state_d;
      cnt_q   <= cnt_d;
      amo_q   <= amo_d;
    end
  end
