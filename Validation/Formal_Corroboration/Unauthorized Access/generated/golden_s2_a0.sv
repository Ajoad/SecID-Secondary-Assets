`timescale 1ns/1ps
module ua_med_golden_s2_a0(input logic clk,input logic rstn);
`include "program_mem_semantic.svh"
localparam integer SCENARIO_ID=2; localparam integer ACCESS_ID=0; localparam integer BOUND=900;
localparam logic [31:0] TARGET_ADDR=32'h80000000; localparam logic TARGET_WE=1'b0; localparam logic EXPECT_ARCH_U=1'b0; localparam logic EXPECT_LSU_U=1'b1;
logic [31:0] xbus_dat_g; logic xbus_ack_g, xbus_err_g;
logic [31:0] xbus_adr_g, xbus_wdat_g; logic [2:0] xbus_tag_g; logic xbus_we_g; logic [3:0] xbus_sel_g; logic xbus_stb_g, xbus_cyc_g;
logic irq_mei_g, irq_msi_g, irq_mti_g; logic primary_g; logic [14501:0] obs_g;
logic pending_g; logic [31:0] pending_addr_g; logic [2:0] pending_tag_g;
wire req_g = xbus_stb_g && xbus_cyc_g;
wire pending_is_instr_g = pending_tag_g[2];
wire [31:0] nominal_rsp_data_g = pending_is_instr_g ? secid_program_word(pending_addr_g, SCENARIO_ID, ACCESS_ID) : 32'hC0DEC0DE;

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
logic [15:0] cycle; wire [31:0] exec_pc_g=obs_g[2835:2804]; wire prv_g=obs_g[2223]; wire [31:0] pmp_addr_g=obs_g[12464:12433]; wire pmp_err_g=obs_g[454];
wire target_context_g=(exec_pc_g==32'h00000114)&&(prv_g==(EXPECT_ARCH_U?1'b0:1'b1))&&(primary_g==(EXPECT_LSU_U?1'b0:1'b1));
wire pmp_deny_g=(pmp_addr_g==TARGET_ADDR)&&pmp_err_g; wire protected_g=req_g&&(xbus_adr_g==TARGET_ADDR)&&(xbus_we_g==TARGET_WE);
logic seen_ctx,seen_deny,seen_prot;
always_ff @(posedge clk or negedge rstn) begin if(!rstn) begin cycle<=0;seen_ctx<=0;seen_deny<=0;seen_prot<=0;end else begin if(cycle<16'hffff)cycle<=cycle+1'b1;if(target_context_g)seen_ctx<=1;if(pmp_deny_g)seen_deny<=1;if(protected_g)seen_prot<=1;end end
UA_GOLDEN_SEMANTIC_DENY_BY_BOUND: assert property (@(posedge clk) disable iff(!rstn) (cycle==BOUND)|->((seen_ctx||target_context_g)&&(seen_deny||pmp_deny_g)&&!(seen_prot||protected_g)));
endmodule
