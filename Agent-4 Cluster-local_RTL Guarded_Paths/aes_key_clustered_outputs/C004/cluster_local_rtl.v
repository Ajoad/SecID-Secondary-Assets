// Cluster-local RTL evidence for AES key fan-out analysis
// cluster: C004
// primary: aes_cipher_top.key
// members:
//   - aes_cipher_top.sa33_next
//   - aes_cipher_top.sa33
//   - aes_cipher_top.sa23_next
//   - aes_cipher_top.sa13_next
//   - aes_cipher_top.sa03_next
// NOTE: This is a hierarchy-annotated source slice for LLM analysis; it is not intended as a standalone compilable design.

// ============================================================================
// hierarchy: aes_cipher_top
// source: aes_cipher_top.v:121-121  process=aes_cipher_top::Always@L121#5
// ============================================================================
always @(posedge clk)	sa33 <= #1 ld_r ? text_in_r[007:000] ^ w3[07:00] : sa33_next;

// ============================================================================
// hierarchy: aes_cipher_top
// source: aes_cipher_top.v:186-186  process=aes_cipher_top::continuous@L186#44
// ============================================================================
assign sa03_next = sa03_mc ^ w3[31:24];

// ============================================================================
// hierarchy: aes_cipher_top
// source: aes_cipher_top.v:190-190  process=aes_cipher_top::continuous@L190#48
// ============================================================================
assign sa13_next = sa13_mc ^ w3[23:16];

// ============================================================================
// hierarchy: aes_cipher_top
// source: aes_cipher_top.v:194-194  process=aes_cipher_top::continuous@L194#52
// ============================================================================
assign sa23_next = sa23_mc ^ w3[15:08];

// ============================================================================
// hierarchy: aes_cipher_top
// source: aes_cipher_top.v:198-198  process=aes_cipher_top::continuous@L198#56
// ============================================================================
assign sa33_next = sa33_mc ^ w3[07:00];

// ============================================================================
// hierarchy: aes_cipher_top
// source: aes_cipher_top.v:232-239
// ============================================================================
aes_key_expand_128 u0(
	.clk(		clk	),
	.kld(		ld	),
	.key(		key	),
	.wo_0(		w0	),
	.wo_1(		w1	),
	.wo_2(		w2	),
	.wo_3(		w3	));

// ============================================================================
// hierarchy: aes_cipher_top.u0
// source: aes_cipher_top.v:232-239
// ============================================================================
aes_key_expand_128 u0(
	.clk(		clk	),
	.kld(		ld	),
	.key(		key	),
	.wo_0(		w0	),
	.wo_1(		w1	),
	.wo_2(		w2	),
	.wo_3(		w3	));

// ============================================================================
// hierarchy: aes_cipher_top.u0
// source: aes_key_expand_128.v:72-72  process=aes_cipher_top.u0::continuous@L332#76
// ============================================================================
assign wo_3 = w[3];

// ============================================================================
// hierarchy: aes_cipher_top.u0
// source: aes_key_expand_128.v:73-73  process=aes_cipher_top.u0::Always@L333#77
// ============================================================================
always @(posedge clk)	w[0] <= #1 kld ? key[127:096] : w[0]^subword^rcon;

// ============================================================================
// hierarchy: aes_cipher_top.u0
// source: aes_key_expand_128.v:73-74  process=aes_cipher_top.u0::Always@L334#78
// ============================================================================
always @(posedge clk)	w[0] <= #1 kld ? key[127:096] : w[0]^subword^rcon;
always @(posedge clk)	w[1] <= #1 kld ? key[095:064] : w[0]^w[1]^subword^rcon;

// ============================================================================
// hierarchy: aes_cipher_top.u0
// source: aes_key_expand_128.v:74-75  process=aes_cipher_top.u0::Always@L335#79
// ============================================================================
always @(posedge clk)	w[1] <= #1 kld ? key[095:064] : w[0]^w[1]^subword^rcon;
always @(posedge clk)	w[2] <= #1 kld ? key[063:032] : w[0]^w[2]^w[1]^subword^rcon;

// ============================================================================
// hierarchy: aes_cipher_top.u0
// source: aes_key_expand_128.v:75-76  process=aes_cipher_top.u0::Always@L336#80
// ============================================================================
always @(posedge clk)	w[2] <= #1 kld ? key[063:032] : w[0]^w[2]^w[1]^subword^rcon;
always @(posedge clk)	w[3] <= #1 kld ? key[031:000] : w[0]^w[3]^w[2]^w[1]^subword^rcon;

