// ============================================================================
// Cluster-local fan-out RTL: keccak.in -> C000
// Source-faithful SHA-3/Keccak relation excerpt.
// Exact deduplicated union of candidate-local RTL evidence for 5 RTL-proximal candidates.
// Members: keccak.f_permutation_.out, keccak.f_permutation_.round_.ff[3][3], keccak.f_permutation_.round_.ff[4][3], keccak.f_permutation_.round_.out, keccak.out1
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

// relation evidence: keccak:f_permutation_port_out
// f_permutation f_permutation_: .out(f_out)

// relation evidence: keccak:out1_slice
assign out1 = f_out[1599:1599-511];

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

// relation evidence: padder:v1_direct_in
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
// Original source: f_permutation.v
// ----------------------------------------------------------------------------
// relation evidence: f_permutation:out_reg
always @ (posedge clk)
  if (reset) out <= 0;
  else if (update) out <= round_out;

// relation evidence: f_permutation:round_in_accept
assign round_in = accept ? {in ^ out[1599:1599-575], out[1599-576:0]} : out;

// relation evidence: f_permutation:round_port_out
// round2in1 round_: .in(round_in), .out(round_out)

// relation evidence: f_permutation:guard_accept
assign accept = in_ready & (~ calc);

// relation evidence: f_permutation:guard_update
assign update = calc | accept;

// ----------------------------------------------------------------------------
// Original source: round2in1.v
// ----------------------------------------------------------------------------
// relation evidence: round:a_0_0
assign a[0][0] = in[`HIGH_POS(0,0) : `LOW_POS(0,0)];

// relation evidence: round:a_0_4
assign a[0][4] = in[`HIGH_POS(0,4) : `LOW_POS(0,4)];

// relation evidence: round:a_1_0
assign a[1][0] = in[`HIGH_POS(1,0) : `LOW_POS(1,0)];

// relation evidence: round:a_1_1
assign a[1][1] = in[`HIGH_POS(1,1) : `LOW_POS(1,1)];

// relation evidence: round:a_1_2
assign a[1][2] = in[`HIGH_POS(1,2) : `LOW_POS(1,2)];

// relation evidence: round:a_1_3
assign a[1][3] = in[`HIGH_POS(1,3) : `LOW_POS(1,3)];

// relation evidence: round:a_1_4
assign a[1][4] = in[`HIGH_POS(1,4) : `LOW_POS(1,4)];

// relation evidence: round:a_2_0
assign a[2][0] = in[`HIGH_POS(2,0) : `LOW_POS(2,0)];

// relation evidence: round:a_2_1
assign a[2][1] = in[`HIGH_POS(2,1) : `LOW_POS(2,1)];

// relation evidence: round:b_2
assign b[2] = a[2][0] ^ a[2][1] ^ a[2][2] ^ a[2][3] ^ a[2][4];

// relation evidence: round:bb_0
assign bb[0] = g[0][0] ^ g[0][1] ^ g[0][2] ^ g[0][3] ^ g[0][4];

// relation evidence: round:bb_1
assign bb[1] = g[1][0] ^ g[1][1] ^ g[1][2] ^ g[1][3] ^ g[1][4];

// relation evidence: round:bb_2
assign bb[2] = g[2][0] ^ g[2][1] ^ g[2][2] ^ g[2][3] ^ g[2][4];

// relation evidence: round:bb_3
assign bb[3] = g[3][0] ^ g[3][1] ^ g[3][2] ^ g[3][3] ^ g[3][4];

// relation evidence: round:bb_4
assign bb[4] = g[4][0] ^ g[4][1] ^ g[4][2] ^ g[4][3] ^ g[4][4];

// relation evidence: round:c_0_0
assign c[0][0] = a[0][0] ^ b[`SUB_1(0)] ^ `ROT_UP_1(b[`ADD_1(0)]);

// relation evidence: round:c_0_4
assign c[0][4] = a[0][4] ^ b[`SUB_1(0)] ^ `ROT_UP_1(b[`ADD_1(0)]);

// relation evidence: round:c_1_0
assign c[1][0] = a[1][0] ^ b[`SUB_1(1)] ^ `ROT_UP_1(b[`ADD_1(1)]);

// relation evidence: round:c_1_1
assign c[1][1] = a[1][1] ^ b[`SUB_1(1)] ^ `ROT_UP_1(b[`ADD_1(1)]);

// relation evidence: round:c_1_2
assign c[1][2] = a[1][2] ^ b[`SUB_1(1)] ^ `ROT_UP_1(b[`ADD_1(1)]);

// relation evidence: round:c_1_3
assign c[1][3] = a[1][3] ^ b[`SUB_1(1)] ^ `ROT_UP_1(b[`ADD_1(1)]);

// relation evidence: round:c_1_4
assign c[1][4] = a[1][4] ^ b[`SUB_1(1)] ^ `ROT_UP_1(b[`ADD_1(1)]);

// relation evidence: round:c_2_0
assign c[2][0] = a[2][0] ^ b[`SUB_1(2)] ^ `ROT_UP_1(b[`ADD_1(2)]);

// relation evidence: round:c_3_0
assign c[3][0] = a[3][0] ^ b[`SUB_1(3)] ^ `ROT_UP_1(b[`ADD_1(3)]);

// relation evidence: round:c_3_4
assign c[3][4] = a[3][4] ^ b[`SUB_1(3)] ^ `ROT_UP_1(b[`ADD_1(3)]);

// relation evidence: round:cc_0_0
assign cc[0][0] = g[0][0] ^ bb[`SUB_1(0)] ^ `ROT_UP_1(bb[`ADD_1(0)]);

// relation evidence: round:cc_0_1
assign cc[0][1] = g[0][1] ^ bb[`SUB_1(0)] ^ `ROT_UP_1(bb[`ADD_1(0)]);

// relation evidence: round:cc_2_3
assign cc[2][3] = g[2][3] ^ bb[`SUB_1(2)] ^ `ROT_UP_1(bb[`ADD_1(2)]);

// relation evidence: round:cc_3_1
assign cc[3][1] = g[3][1] ^ bb[`SUB_1(3)] ^ `ROT_UP_1(bb[`ADD_1(3)]);

// relation evidence: round:cc_3_2
assign cc[3][2] = g[3][2] ^ bb[`SUB_1(3)] ^ `ROT_UP_1(bb[`ADD_1(3)]);

// relation evidence: round:cc_3_4
assign cc[3][4] = g[3][4] ^ bb[`SUB_1(3)] ^ `ROT_UP_1(bb[`ADD_1(3)]);

// relation evidence: round:cc_4_0
assign cc[4][0] = g[4][0] ^ bb[`SUB_1(4)] ^ `ROT_UP_1(bb[`ADD_1(4)]);

// relation evidence: round:cc_4_2
assign cc[4][2] = g[4][2] ^ bb[`SUB_1(4)] ^ `ROT_UP_1(bb[`ADD_1(4)]);

// relation evidence: round:cc_4_4
assign cc[4][4] = g[4][4] ^ bb[`SUB_1(4)] ^ `ROT_UP_1(bb[`ADD_1(4)]);

// relation evidence: round:d_0_0
assign d[0][0] = c[0][0];

// relation evidence: round:d_0_4
assign d[0][4] = `ROT_UP(c[0][4], 18);

// relation evidence: round:d_1_0
assign d[1][0] = `ROT_UP_1(c[1][0]);

// relation evidence: round:d_1_1
assign d[1][1] = `ROT_UP(c[1][1], 44);

// relation evidence: round:d_1_2
assign d[1][2] = `ROT_UP(c[1][2], 10);

// relation evidence: round:d_1_3
assign d[1][3] = `ROT_UP(c[1][3], 45);

// relation evidence: round:d_1_4
assign d[1][4] = `ROT_UP(c[1][4], 2);

// relation evidence: round:d_2_0
assign d[2][0] = `ROT_UP(c[2][0], 62);

// relation evidence: round:d_3_0
assign d[3][0] = `ROT_UP(c[3][0], 28);

// relation evidence: round:d_3_4
assign d[3][4] = `ROT_UP(c[3][4], 56);

// relation evidence: round:dd_0_0
assign dd[0][0] = cc[0][0];

// relation evidence: round:dd_0_1
assign dd[0][1] = `ROT_UP(cc[0][1], 36);

// relation evidence: round:dd_2_3
assign dd[2][3] = `ROT_UP(cc[2][3], 15);

// relation evidence: round:dd_3_1
assign dd[3][1] = `ROT_UP(cc[3][1], 55);

// relation evidence: round:dd_3_2
assign dd[3][2] = `ROT_UP(cc[3][2], 25);

// relation evidence: round:dd_3_4
assign dd[3][4] = `ROT_UP(cc[3][4], 56);

// relation evidence: round:dd_4_0
assign dd[4][0] = `ROT_UP(cc[4][0], 27);

// relation evidence: round:dd_4_2
assign dd[4][2] = `ROT_UP(cc[4][2], 39);

// relation evidence: round:dd_4_4
assign dd[4][4] = `ROT_UP(cc[4][4], 14);

// relation evidence: round:e_0_0
assign e[0][0] = d[0][0];

// relation evidence: round:e_0_1
assign e[0][1] = d[3][0];

// relation evidence: round:e_0_2
assign e[0][2] = d[1][0];

// relation evidence: round:e_0_4
assign e[0][4] = d[2][0];

// relation evidence: round:e_1_0
assign e[1][0] = d[1][1];

// relation evidence: round:e_2_3
assign e[2][3] = d[1][2];

// relation evidence: round:e_3_1
assign e[3][1] = d[1][3];

// relation evidence: round:e_4_2
assign e[4][2] = d[0][4];

// relation evidence: round:e_4_3
assign e[4][3] = d[3][4];

// relation evidence: round:e_4_4
assign e[4][4] = d[1][4];

// relation evidence: round:ee_0_0
assign ee[0][0] = dd[0][0];

// relation evidence: round:ee_0_3
assign ee[0][3] = dd[4][0];

// relation evidence: round:ee_1_3
assign ee[1][3] = dd[0][1];

// relation evidence: round:ee_1_4
assign ee[1][4] = dd[3][1];

// relation evidence: round:ee_2_2
assign ee[2][2] = dd[3][2];

// relation evidence: round:ee_2_4
assign ee[2][4] = dd[4][2];

// relation evidence: round:ee_3_3
assign ee[3][3] = dd[2][3];

// relation evidence: round:ee_4_0
assign ee[4][0] = dd[4][4];

// relation evidence: round:ee_4_3
assign ee[4][3] = dd[3][4];

// relation evidence: round:f_0_0
assign f[0][0] = e[0][0] ^ ((~ e[`ADD_1(0)][0]) & e[`ADD_2(0)][0]);

// relation evidence: round:f_0_1
assign f[0][1] = e[0][1] ^ ((~ e[`ADD_1(0)][1]) & e[`ADD_2(0)][1]);

// relation evidence: round:f_1_3
assign f[1][3] = e[1][3] ^ ((~ e[`ADD_1(1)][3]) & e[`ADD_2(1)][3]);

// relation evidence: round:f_2_1
assign f[2][1] = e[2][1] ^ ((~ e[`ADD_1(2)][1]) & e[`ADD_2(2)][1]);

// relation evidence: round:f_2_3
assign f[2][3] = e[2][3] ^ ((~ e[`ADD_1(2)][3]) & e[`ADD_2(2)][3]);

// relation evidence: round:f_3_1
assign f[3][1] = e[3][1] ^ ((~ e[`ADD_1(3)][1]) & e[`ADD_2(3)][1]);

// relation evidence: round:f_3_2
assign f[3][2] = e[3][2] ^ ((~ e[`ADD_1(3)][2]) & e[`ADD_2(3)][2]);

// relation evidence: round:f_3_4
assign f[3][4] = e[3][4] ^ ((~ e[`ADD_1(3)][4]) & e[`ADD_2(3)][4]);

// relation evidence: round:f_4_0
assign f[4][0] = e[4][0] ^ ((~ e[`ADD_1(4)][0]) & e[`ADD_2(4)][0]);

// relation evidence: round:f_4_2
assign f[4][2] = e[4][2] ^ ((~ e[`ADD_1(4)][2]) & e[`ADD_2(4)][2]);

// relation evidence: round:f_4_4
assign f[4][4] = e[4][4] ^ ((~ e[`ADD_1(4)][4]) & e[`ADD_2(4)][4]);

// relation evidence: round:ff_0_0
assign ff[0][0] = ee[0][0] ^ ((~ ee[`ADD_1(0)][0]) & ee[`ADD_2(0)][0]);

// relation evidence: round:ff_0_3
assign ff[0][3] = ee[0][3] ^ ((~ ee[`ADD_1(0)][3]) & ee[`ADD_2(0)][3]);

// relation evidence: round:ff_2_2
assign ff[2][2] = ee[2][2] ^ ((~ ee[`ADD_1(2)][2]) & ee[`ADD_2(2)][2]);

// relation evidence: round:ff_2_4
assign ff[2][4] = ee[2][4] ^ ((~ ee[`ADD_1(2)][4]) & ee[`ADD_2(2)][4]);

// relation evidence: round:ff_3_3
assign ff[3][3] = ee[3][3] ^ ((~ ee[`ADD_1(3)][3]) & ee[`ADD_2(3)][3]);

// relation evidence: round:ff_4_0
assign ff[4][0] = ee[4][0] ^ ((~ ee[`ADD_1(4)][0]) & ee[`ADD_2(4)][0]);

// relation evidence: round:ff_4_3
assign ff[4][3] = ee[4][3] ^ ((~ ee[`ADD_1(4)][3]) & ee[`ADD_2(4)][3]);

// relation evidence: round:ff_4_4
assign ff[4][4] = ee[4][4] ^ ((~ ee[`ADD_1(4)][4]) & ee[`ADD_2(4)][4]);

// relation evidence: round:g_0_0
// generate iota: g[0][0][z] = f[0][0][z] ^ round_const_1[z] on RC bits; otherwise f[0][0][z].

// relation evidence: round:g_0_1
assign g[0][1] = f[0][1];

// relation evidence: round:g_1_3
assign g[1][3] = f[1][3];

// relation evidence: round:g_2_1
assign g[2][1] = f[2][1];

// relation evidence: round:g_2_3
assign g[2][3] = f[2][3];

// relation evidence: round:g_3_1
assign g[3][1] = f[3][1];

// relation evidence: round:g_3_2
assign g[3][2] = f[3][2];

// relation evidence: round:g_3_4
assign g[3][4] = f[3][4];

// relation evidence: round:g_4_0
assign g[4][0] = f[4][0];

// relation evidence: round:g_4_2
assign g[4][2] = f[4][2];

// relation evidence: round:g_4_4
assign g[4][4] = f[4][4];

// relation evidence: round:gg_0_0
// generate iota: gg[0][0][z] = ff[0][0][z] ^ round_const_2[z] on RC bits; otherwise ff[0][0][z].

// relation evidence: round:gg_0_3
assign gg[0][3] = ff[0][3];

// relation evidence: round:gg_2_2
assign gg[2][2] = ff[2][2];

// relation evidence: round:gg_2_4
assign gg[2][4] = ff[2][4];

// relation evidence: round:gg_3_3
assign gg[3][3] = ff[3][3];

// relation evidence: round:gg_4_0
assign gg[4][0] = ff[4][0];

// relation evidence: round:gg_4_3
assign gg[4][3] = ff[4][3];

// relation evidence: round:gg_4_4
assign gg[4][4] = ff[4][4];

// relation evidence: round:out_0_0
// generate output mapping lane (0,0): assign out[`HIGH_POS(0,0) : `LOW_POS(0,0)] = gg[0][0];

// relation evidence: round:out_0_3
// generate output mapping lane (0,3): assign out[`HIGH_POS(0,3) : `LOW_POS(0,3)] = gg[0][3];

// relation evidence: round:out_2_2
// generate output mapping lane (2,2): assign out[`HIGH_POS(2,2) : `LOW_POS(2,2)] = gg[2][2];

// relation evidence: round:out_2_4
// generate output mapping lane (2,4): assign out[`HIGH_POS(2,4) : `LOW_POS(2,4)] = gg[2][4];

// relation evidence: round:out_3_3
// generate output mapping lane (3,3): assign out[`HIGH_POS(3,3) : `LOW_POS(3,3)] = gg[3][3];

// relation evidence: round:out_4_0
// generate output mapping lane (4,0): assign out[`HIGH_POS(4,0) : `LOW_POS(4,0)] = gg[4][0];

// relation evidence: round:out_4_3
// generate output mapping lane (4,3): assign out[`HIGH_POS(4,3) : `LOW_POS(4,3)] = gg[4][3];

// relation evidence: round:out_4_4
// generate output mapping lane (4,4): assign out[`HIGH_POS(4,4) : `LOW_POS(4,4)] = gg[4][4];
