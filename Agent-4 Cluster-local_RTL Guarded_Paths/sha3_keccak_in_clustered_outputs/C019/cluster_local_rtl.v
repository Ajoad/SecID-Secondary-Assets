// ============================================================================
// Cluster-local fan-out RTL: keccak.in -> C019
// Source-faithful SHA-3/Keccak relation excerpt.
// Exact deduplicated union of candidate-local RTL evidence for 5 RTL-proximal candidates.
// Members: keccak.f_permutation_.round_.c[2][0], keccak.f_permutation_.round_.c[2][1], keccak.f_permutation_.round_.c[2][2], keccak.f_permutation_.round_.c[2][3], keccak.f_permutation_.round_.c[2][4]
// Per-candidate guarded structural paths are stored in paths/*.json.
// Unrelated RTL is intentionally omitted; this is not a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: keccak.v
// ----------------------------------------------------------------------------
// relation evidence: keccak:byte_reorder_padder
// generate byte reorder: assign padder_out[...] = padder_out_1[...];

// relation evidence: keccak:f_permutation_port_in
// f_permutation f_permutation_: .in(padder_out)

// relation evidence: keccak:padder_port_out
// padder padder_: .out(padder_out_1)

// relation evidence: keccak:port_in_to_padder
// padder padder_: .in(in)

// relation evidence: keccak:guard_is_last
// is_last is propagated to padder_ and controls the terminal-word padding branch.

// ----------------------------------------------------------------------------
// Original source: padder.v
// ----------------------------------------------------------------------------
// relation evidence: padder:out_shift
always @ (posedge clk)
  if (reset) out <= 0;
  else if (update) out <= {out[575-64:0], v1};

// relation evidence: padder:p0_port_in
// padder1 p0: .in(in)

// relation evidence: padder:v1_direct_in
always_comb begin
  if (state) begin v1 = 0; v1[7] = v1[7] | i[7]; end
  else if (is_last == 0) v1 = in;
  else begin v1 = v0; v1[7] = v1[7] | i[7]; end
end

// relation evidence: padder:v1_padded_in
always_comb begin
  if (state) begin v1 = 0; v1[7] = v1[7] | i[7]; end
  else if (is_last == 0) v1 = in;
  else begin v1 = v0; v1[7] = v1[7] | i[7]; end
end

// relation evidence: padder:guard_state
always @ (posedge clk)
  if (reset) state <= 0;
  else if (is_last) state <= 1;

// relation evidence: padder:guard_update
assign update = (accept | (state & (~ buffer_full))) & (~ done);

// ----------------------------------------------------------------------------
// Original source: padder1.v
// ----------------------------------------------------------------------------
// relation evidence: padder1:case_byte_num
always_comb begin
  case (byte_num)
    0: out =             64'h0100000000000000;
    1: out = {in[63:56], 56'h01000000000000};
    2: out = {in[63:48], 48'h010000000000};
    3: out = {in[63:40], 40'h0100000000};
    4: out = {in[63:32], 32'h01000000};
    5: out = {in[63:24], 24'h010000};
    6: out = {in[63:16], 16'h0100};
    7: out = {in[63:8],   8'h01};
    default: out = 64'h0100000000000000;
  endcase
end

// relation evidence: padder1:guard_byte_num
// byte_num selects the padder1 case arm that forms out from in.

// ----------------------------------------------------------------------------
// Original source: f_permutation.v
// ----------------------------------------------------------------------------
// relation evidence: f_permutation:round_in_accept
assign round_in = accept ? {in ^ out[1599:1599-575], out[1599-576:0]} : out;

// relation evidence: f_permutation:guard_accept
assign accept = in_ready & (~ calc);

// ----------------------------------------------------------------------------
// Original source: round2in1.v
// ----------------------------------------------------------------------------
// relation evidence: round:a_1_3
assign a[1][3] = in[`HIGH_POS(1,3) : `LOW_POS(1,3)];

// relation evidence: round:a_1_4
assign a[1][4] = in[`HIGH_POS(1,4) : `LOW_POS(1,4)];

// relation evidence: round:a_2_0
assign a[2][0] = in[`HIGH_POS(2,0) : `LOW_POS(2,0)];

// relation evidence: round:a_2_1
assign a[2][1] = in[`HIGH_POS(2,1) : `LOW_POS(2,1)];

// relation evidence: round:a_2_2
assign a[2][2] = in[`HIGH_POS(2,2) : `LOW_POS(2,2)];

// relation evidence: round:a_2_3
assign a[2][3] = in[`HIGH_POS(2,3) : `LOW_POS(2,3)];

// relation evidence: round:a_2_4
assign a[2][4] = in[`HIGH_POS(2,4) : `LOW_POS(2,4)];

// relation evidence: round:a_3_0
assign a[3][0] = in[`HIGH_POS(3,0) : `LOW_POS(3,0)];

// relation evidence: round:a_3_1
assign a[3][1] = in[`HIGH_POS(3,1) : `LOW_POS(3,1)];

// relation evidence: round:a_3_2
assign a[3][2] = in[`HIGH_POS(3,2) : `LOW_POS(3,2)];

// relation evidence: round:a_3_3
assign a[3][3] = in[`HIGH_POS(3,3) : `LOW_POS(3,3)];

// relation evidence: round:a_3_4
assign a[3][4] = in[`HIGH_POS(3,4) : `LOW_POS(3,4)];

// relation evidence: round:b_1
assign b[1] = a[1][0] ^ a[1][1] ^ a[1][2] ^ a[1][3] ^ a[1][4];

// relation evidence: round:b_3
assign b[3] = a[3][0] ^ a[3][1] ^ a[3][2] ^ a[3][3] ^ a[3][4];

// relation evidence: round:c_2_0
assign c[2][0] = a[2][0] ^ b[`SUB_1(2)] ^ `ROT_UP_1(b[`ADD_1(2)]);

// relation evidence: round:c_2_1
assign c[2][1] = a[2][1] ^ b[`SUB_1(2)] ^ `ROT_UP_1(b[`ADD_1(2)]);

// relation evidence: round:c_2_2
assign c[2][2] = a[2][2] ^ b[`SUB_1(2)] ^ `ROT_UP_1(b[`ADD_1(2)]);

// relation evidence: round:c_2_3
assign c[2][3] = a[2][3] ^ b[`SUB_1(2)] ^ `ROT_UP_1(b[`ADD_1(2)]);

// relation evidence: round:c_2_4
assign c[2][4] = a[2][4] ^ b[`SUB_1(2)] ^ `ROT_UP_1(b[`ADD_1(2)]);
