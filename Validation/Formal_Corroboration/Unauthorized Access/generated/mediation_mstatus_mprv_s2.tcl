if {[info exists ::env(SECID_UA_MED_ROOT)] && $::env(SECID_UA_MED_ROOT) ne ""} {
  set ROOT [file normalize $::env(SECID_UA_MED_ROOT)]
} else {
  error "SECID_UA_MED_ROOT is not set. Run through package run_*.sh scripts."
}
if {[info exists ::env(SECID_UA_MED_RESULT_DIR)] && $::env(SECID_UA_MED_RESULT_DIR) ne ""} {
  set RESULT_DIR [file normalize $::env(SECID_UA_MED_RESULT_DIR)]
} else {
  set RESULT_DIR [file join $ROOT results mediation/mstatus_mprv_s2]
}
file mkdir $RESULT_DIR
analyze -sv +incdir+[file join $ROOT input] [file join $ROOT input secid_neorv32_top_source_observed.v] [file join $ROOT generated mediation_mstatus_mprv_s2.sv]
elaborate -top ua_mediation_mstatus_mprv_s2

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
puts $mf {type=MEDIATION}
puts $mf {case_id=mstatus_mprv_s2}
puts $mf {asset=neorv32_cpu_control.csr.mstatus_mprv}
puts $mf {role=SECID}
puts $mf {scenario=M_MPRV_U_UNMATCHED_DENY}
puts $mf {tag=s2_a0}
puts $mf {obs_bit=2157}
puts $mf {dynamic_ucp_reachability=0.0}
puts $mf {dynamic_bypass_sensitivity=0.26666666666666666}
puts $mf {bound=900}
puts $mf "elapsed_ms=$ELAPSED_MS"
puts $mf "report_rc=$rrc"
puts $mf $rmsg
close $mf
puts "SECID_UA_MEDIATION_COMPLETE case=mstatus_mprv_s2"
exit -force
