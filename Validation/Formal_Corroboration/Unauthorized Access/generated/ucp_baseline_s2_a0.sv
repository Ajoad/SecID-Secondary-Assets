`timescale 1ns/1ps
module ua_ucp_baseline_s2_a0(input logic clk, input logic rstn, input logic attack_fire, input logic [2:0] attack_kind, input logic [31:0] attack_data_mask);
`include "program_mem_semantic.svh"
localparam logic [31:0] TARGET_ADDR=32'h80000000; localparam logic TARGET_WE=1'b0;
localparam logic EXPECT_ARCH_U=1'b0; localparam logic EXPECT_LSU_U=1'b1;
localparam integer SCENARIO_ID=2; localparam integer ACCESS_ID=0; localparam integer BOUND=900;
logic [31:0] xbus_dat_g; logic xbus_ack_g, xbus_err_g;
logic [31:0] xbus_adr_g, xbus_wdat_g; logic [2:0] xbus_tag_g; logic xbus_we_g; logic [3:0] xbus_sel_g; logic xbus_stb_g, xbus_cyc_g;
logic irq_mei_g, irq_msi_g, irq_mti_g; logic primary_g; logic [14501:0] obs_g;
logic pending_g; logic [31:0] pending_addr_g; logic [2:0] pending_tag_g;
wire req_g = xbus_stb_g && xbus_cyc_g;
wire pending_is_instr_g = pending_tag_g[2];
wire [31:0] nominal_rsp_data_g = pending_is_instr_g ? secid_program_word(pending_addr_g, SCENARIO_ID, ACCESS_ID) : 32'hC0DEC0DE;

logic [31:0] xbus_dat_a; logic xbus_ack_a, xbus_err_a;
logic [31:0] xbus_adr_a, xbus_wdat_a; logic [2:0] xbus_tag_a; logic xbus_we_a; logic [3:0] xbus_sel_a; logic xbus_stb_a, xbus_cyc_a;
logic irq_mei_a, irq_msi_a, irq_mti_a; logic primary_a; logic [14501:0] obs_a;
logic pending_a; logic [31:0] pending_addr_a; logic [2:0] pending_tag_a;
wire req_a = xbus_stb_a && xbus_cyc_a;
wire pending_is_instr_a = pending_tag_a[2];
wire [31:0] nominal_rsp_data_a = pending_is_instr_a ? secid_program_word(pending_addr_a, SCENARIO_ID, ACCESS_ID) : 32'hC0DEC0DE;

logic [15:0] cycle;
wire [31:0] exec_pc_g=obs_g[2835:2804]; wire prv_g=obs_g[2223]; wire [31:0] pmp_addr_g=obs_g[12464:12433]; wire pmp_err_g=obs_g[454];
wire target_context_g=(exec_pc_g==32'h00000114) && (prv_g==(EXPECT_ARCH_U?1'b0:1'b1)) && (primary_g==(EXPECT_LSU_U?1'b0:1'b1));
wire pmp_deny_g=(pmp_addr_g==TARGET_ADDR) && pmp_err_g;
wire protected_g=req_g && (xbus_adr_g==TARGET_ADDR) && (xbus_we_g==TARGET_WE);
wire protected_a=req_a && (xbus_adr_a==TARGET_ADDR) && (xbus_we_a==TARGET_WE);
logic seen_target_context_g, seen_pmp_deny_g, seen_protected_g;
wire target_context_seen_by_now=seen_target_context_g||target_context_g; wire pmp_deny_seen_by_now=seen_pmp_deny_g||pmp_deny_g; wire protected_g_seen_by_now=seen_protected_g||protected_g;
always_ff @(posedge clk or negedge rstn) begin
  if(!rstn) begin cycle<=0; seen_target_context_g<=0; seen_pmp_deny_g<=0; seen_protected_g<=0; end
  else begin if(cycle<16'hffff) cycle<=cycle+1'b1; if(target_context_g) seen_target_context_g<=1; if(pmp_deny_g) seen_pmp_deny_g<=1; if(protected_g) seen_protected_g<=1; end
end

assign xbus_ack_g = pending_g;
assign xbus_err_g = 1'b0;
assign xbus_dat_g = nominal_rsp_data_g;
always_comb begin irq_mei_g=1'b0; irq_msi_g=1'b0; irq_mti_g=1'b0; end
always_ff @(posedge clk or negedge rstn) begin
  if(!rstn) begin pending_g<=1'b0; pending_addr_g<=32'd0; pending_tag_g<=3'd0; end
  else begin
    if(!pending_g && req_g) begin pending_g<=1'b1; pending_addr_g<=xbus_adr_g; pending_tag_g<=xbus_tag_g; end
    else if(pending_g && xbus_ack_g) pending_g<=1'b0;
  end
end
wire attack_xbus_data = attack_fire && (attack_kind==3'd0);
wire attack_xbus_ack  = attack_fire && (attack_kind==3'd1);
wire attack_xbus_err  = attack_fire && (attack_kind==3'd2);
wire attack_irq_mei   = attack_fire && (attack_kind==3'd3);
wire attack_irq_msi   = attack_fire && (attack_kind==3'd4);
wire attack_irq_mti   = attack_fire && (attack_kind==3'd5);
assign xbus_ack_a = pending_a && !attack_xbus_ack;
assign xbus_err_a = pending_a && attack_xbus_err;
assign xbus_dat_a = nominal_rsp_data_a ^ (attack_xbus_data ? attack_data_mask : 32'd0);
always_comb begin irq_mei_a=attack_irq_mei; irq_msi_a=attack_irq_msi; irq_mti_a=attack_irq_mti; end
always_ff @(posedge clk or negedge rstn) begin
  if(!rstn) begin pending_a<=1'b0; pending_addr_a<=32'd0; pending_tag_a<=3'd0; end
  else begin
    if(!pending_a && req_a) begin pending_a<=1'b1; pending_addr_a<=xbus_adr_a; pending_tag_a<=xbus_tag_a; end
    else if(pending_a && xbus_ack_a) pending_a<=1'b0;
  end
end
secid_neorv32_top dut_g (
  .clk_i(clk), .rstn_i(rstn),
  .jtag_tck_i(1'b0), .jtag_tdi_i(1'b0), .jtag_tms_i(1'b0), .smc_sdi_i(1'b0),
  .xbus_dat_i(xbus_dat_g), .xbus_ack_i(xbus_ack_g), .xbus_err_i(xbus_err_g),
  .slink_rx_dat_i(32'd0), .slink_rx_src_i(4'd0), .slink_rx_val_i(1'b0), .slink_rx_lst_i(1'b0), .slink_tx_rdy_i(1'b0),
  .gpio_i(32'd0), .uart0_rxd_i(1'b1), .uart0_ctsn_i(1'b0), .uart1_rxd_i(1'b1), .uart1_ctsn_i(1'b0),
  .spi_dat_i(1'b0), .sdi_clk_i(1'b0), .sdi_dat_i(1'b0), .sdi_csn_i(1'b1),
  .twi_sda_i(1'b1), .twi_scl_i(1'b1), .twd_sda_i(1'b1), .twd_scl_i(1'b1), .onewire_i(1'b1),
  .cfs_in_i(256'd0), .irq_msi_i(irq_msi_g), .irq_mti_i(irq_mti_g), .irq_mei_i(irq_mei_g),
  .secid_dcsr_force_en_i(32'd0), .secid_dcsr_force_val_i(32'd0),
  .secid_irq_fast_force_en_i(16'd0), .secid_irq_fast_force_val_i(16'd0),
  .xbus_adr_o(xbus_adr_g), .xbus_dat_o(xbus_wdat_g), .xbus_tag_o(xbus_tag_g), .xbus_we_o(xbus_we_g),
  .xbus_sel_o(xbus_sel_g), .xbus_stb_o(xbus_stb_g), .xbus_cyc_o(xbus_cyc_g),
  .secid_primary_o(primary_g), .secid_obs_o(obs_g)
);
secid_neorv32_top dut_a (
  .clk_i(clk), .rstn_i(rstn),
  .jtag_tck_i(1'b0), .jtag_tdi_i(1'b0), .jtag_tms_i(1'b0), .smc_sdi_i(1'b0),
  .xbus_dat_i(xbus_dat_a), .xbus_ack_i(xbus_ack_a), .xbus_err_i(xbus_err_a),
  .slink_rx_dat_i(32'd0), .slink_rx_src_i(4'd0), .slink_rx_val_i(1'b0), .slink_rx_lst_i(1'b0), .slink_tx_rdy_i(1'b0),
  .gpio_i(32'd0), .uart0_rxd_i(1'b1), .uart0_ctsn_i(1'b0), .uart1_rxd_i(1'b1), .uart1_ctsn_i(1'b0),
  .spi_dat_i(1'b0), .sdi_clk_i(1'b0), .sdi_dat_i(1'b0), .sdi_csn_i(1'b1),
  .twi_sda_i(1'b1), .twi_scl_i(1'b1), .twd_sda_i(1'b1), .twd_scl_i(1'b1), .onewire_i(1'b1),
  .cfs_in_i(256'd0), .irq_msi_i(irq_msi_a), .irq_mti_i(irq_mti_a), .irq_mei_i(irq_mei_a),
  .secid_dcsr_force_en_i(32'd0), .secid_dcsr_force_val_i(32'd0),
  .secid_irq_fast_force_en_i(16'd0), .secid_irq_fast_force_val_i(16'd0),
  .xbus_adr_o(xbus_adr_a), .xbus_dat_o(xbus_wdat_a), .xbus_tag_o(xbus_tag_a), .xbus_we_o(xbus_we_a),
  .xbus_sel_o(xbus_sel_a), .xbus_stb_o(xbus_stb_a), .xbus_cyc_o(xbus_cyc_a),
  .secid_primary_o(primary_a), .secid_obs_o(obs_a)
);
logic attack_used, seen_attack, seen_bypass_a, seen_primary_compromise_after_attack;
wire post_pmp_or_target_pc = (exec_pc_g>=32'h000000a8) && (exec_pc_g<=32'h00000114);
wire matching_pending = pending_g && pending_a && pending_is_instr_g && pending_is_instr_a && (pending_addr_g==pending_addr_a) && (pending_tag_g==pending_tag_a);
wire bus_attack_window = matching_pending && (pending_addr_g>=32'h000000a8) && (pending_addr_g<=32'h00000114);
wire irq_attack_window = post_pmp_or_target_pc;
wire attack_eligible = (attack_kind<=3'd2) ? bus_attack_window : ((attack_kind<=3'd5) ? irq_attack_window : 1'b0);
wire primary_compromise_now = (primary_g==1'b0) && (primary_a==1'b1);
wire bypass_after_attack_now = protected_a && seen_primary_compromise_after_attack && primary_compromise_now;
always_ff @(posedge clk or negedge rstn) begin
  if(!rstn) begin attack_used<=0; seen_attack<=0; seen_bypass_a<=0; seen_primary_compromise_after_attack<=0; end
  else begin
    if(attack_fire) begin attack_used<=1; seen_attack<=1; end
    if((seen_attack || attack_fire) && primary_compromise_now) seen_primary_compromise_after_attack<=1;
    if(bypass_after_attack_now) seen_bypass_a<=1;
  end
end
UA_ATTACK_KIND_VALID: assume property (@(posedge clk) disable iff(!rstn) attack_fire |-> (attack_kind<=3'd5));
UA_ATTACK_ONE_CYCLE: assume property (@(posedge clk) disable iff(!rstn) attack_used |-> !attack_fire);
UA_ATTACK_ONLY_ELIGIBLE: assume property (@(posedge clk) disable iff(!rstn) attack_fire |-> attack_eligible);
UA_DATA_ATTACK_ONE_BIT: assume property (@(posedge clk) disable iff(!rstn) (attack_fire && attack_kind==3'd0) |-> $onehot(attack_data_mask));
UA_ATTACK_MUST_OCCUR_BY_BOUND: assume property (@(posedge clk) disable iff(!rstn) (cycle==BOUND) |-> (seen_attack || attack_fire));
UA_COVER_ATTACK: cover property (@(posedge clk) disable iff(!rstn) attack_fire);
UA_COVER_PRIMARY_COMPROMISE_AFTER_UCP: cover property (@(posedge clk) disable iff(!rstn) seen_primary_compromise_after_attack);
UA_GOLDEN_NONVACUOUS_BY_BOUND: assert property (@(posedge clk) disable iff(!rstn) (cycle==BOUND) |-> (target_context_seen_by_now && pmp_deny_seen_by_now && !protected_g_seen_by_now));
UA_UCP_BASE_NO_BYPASS_BY_BOUND: assert property (@(posedge clk) disable iff(!rstn) (cycle==BOUND) |-> !(seen_bypass_a || bypass_after_attack_now));
endmodule
