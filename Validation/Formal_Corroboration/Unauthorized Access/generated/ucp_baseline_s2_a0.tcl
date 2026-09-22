if {[info exists ::env(SECID_UA_MED_ROOT)] && $::env(SECID_UA_MED_ROOT) ne ""} {
  set ROOT [file normalize $::env(SECID_UA_MED_ROOT)]
} else {
  error "SECID_UA_MED_ROOT is not set. Run through package run_*.sh scripts."
}
if {[info exists ::env(SECID_UA_MED_RESULT_DIR)] && $::env(SECID_UA_MED_RESULT_DIR) ne ""} {
  set RESULT_DIR [file normalize $::env(SECID_UA_MED_RESULT_DIR)]
} else {
  set RESULT_DIR [file join $ROOT results ucp_baseline/s2_a0]
}
file mkdir $RESULT_DIR
analyze -sv +incdir+[file join $ROOT input] [file join $ROOT input secid_neorv32_top_source_observed.v] [file join $ROOT generated ucp_baseline_s2_a0.sv]
elaborate -top ua_ucp_baseline_s2_a0

clock clk
reset -expression {!rstn}
set T0 [::tcl::clock::milliseconds]
prove -all
set T1 [::tcl::clock::milliseconds]
set ELAPSED_MS [expr {$T1-$T0}]
set stf [open [file join $RESULT_DIR status.tsv] w]
puts $stf "property	status"
if {[llength [info commands get_property_list]]>0 && ![catch {set ALLP [get_property_list]}]} {
  foreach p $ALLP {
    if {[string match "*UA_*" $p]} {
      set st "UNKNOWN"
      # Jasper 2024.09 accepts two get_property_info forms depending on app/context.
      # Try the keyword form first, then the positional property form used by
      # the previously validated UA package.  Do not silently leave UNKNOWN
      # just because one syntax is unsupported.
      if {[catch {set st [get_property_info -property $p -list status]}]} {
        catch {set st [get_property_info $p -list status]}
      }
      puts $stf "$p	$st"
    }
  }
}
close $stf
set rrc [catch {report -summary -force -result -file [file join $RESULT_DIR report.rpt]} rmsg]
set mf [open [file join $RESULT_DIR metadata.txt] w]
puts $mf {type=UCP_BASELINE}
puts $mf {scenario=M_MPRV_U_UNMATCHED_DENY}
puts $mf {tag=s2_a0}
puts $mf {bound=900}
puts $mf {attack_space=XBUS_DATA_1BIT|XBUS_ACK_DROP|XBUS_ERR|IRQ_MEI|IRQ_MSI|IRQ_MTI}
puts $mf {attack_window=0xA8-0x114}
puts $mf {pmp_setup_corruption_excluded=1}
puts $mf {primary_gate=golden_lsu_priv_U_to_attacked_lsu_priv_M_before_protected_request}
puts $mf {jtag_included=0}
puts $mf "elapsed_ms=$ELAPSED_MS"
puts $mf "report_rc=$rrc"
puts $mf $rmsg
close $mf
puts "SECID_UA_UCP_BASELINE_COMPLETE tag=s2_a0"
exit -force
