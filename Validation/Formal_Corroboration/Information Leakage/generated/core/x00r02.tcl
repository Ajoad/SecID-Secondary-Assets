# AUTO-GENERATED -- do not hand-edit.
# Package: openmsp430_r4_il_jasper_single_exclusion_effort_v1_3_1_reuse10
# Campaign: 60_effort_exclude_00_execution_unit_0_reg_src_r02   Scope: core
if {[info exists ::env(SECID_ROOT)] && $::env(SECID_ROOT) ne ""} {
  set ROOT [file normalize $::env(SECID_ROOT)]
} else {
  error "SECID_ROOT is not set; point it to the full source package containing rtl/."
}
set RTL [file join $ROOT rtl]
set RESULT_DIR [file join $ROOT results core 60_effort_exclude_00_execution_unit_0_reg_src_r02]
file mkdir $RESULT_DIR
set RTL_FILES [list \
    [file join $RTL omsp_alu.v] \
    [file join $RTL omsp_and_gate.v] \
    [file join $RTL omsp_clock_gate.v] \
    [file join $RTL omsp_clock_module.v] \
    [file join $RTL omsp_clock_mux.v] \
    [file join $RTL omsp_dbg.v] \
    [file join $RTL omsp_dbg_hwbrk.v] \
    [file join $RTL omsp_dbg_i2c.v] \
    [file join $RTL omsp_dbg_uart.v] \
    [file join $RTL omsp_execution_unit.v] \
    [file join $RTL omsp_frontend.v] \
    [file join $RTL omsp_mem_backbone.v] \
    [file join $RTL omsp_multiplier.v] \
    [file join $RTL omsp_register_file.v] \
    [file join $RTL omsp_scan_mux.v] \
    [file join $RTL omsp_sfr.v] \
    [file join $RTL omsp_sync_cell.v] \
    [file join $RTL omsp_sync_reset.v] \
    [file join $RTL omsp_wakeup_cell.v] \
    [file join $RTL omsp_watchdog.v] \
    [file join $RTL openMSP430.v]
]

check_spv -init
analyze -v2k +incdir+$RTL {*}$RTL_FILES
elaborate -top openMSP430 -bbox_mul 64
clock dco_clk
reset -expression {!reset_n}

# Fixed environment: identical for baseline and every exclusion.
assume {scan_enable == 1'b0}
assume {scan_mode == 1'b0}
assume {cpu_en == 1'b1}
assume {dbg_en == 1'b1}
assume {lfxt_clk == 1'b0}

check_spv -create -name SECID_EFFORT_EXCL_SA00_R02_PRIMARY_TO_UOP -from {execution_unit_0.register_file_0.r4} -to {dbg_uart_txd} -not_through {execution_unit_0.reg_src} -taint_feedback_loop

set SECID_TARGET_PROPERTIES [list SECID_EFFORT_EXCL_SA00_R02_PRIMARY_TO_UOP]
check_spv -prove -property $SECID_TARGET_PROPERTIES

set cf [open [file join $RESULT_DIR consistency.txt] w]
set CONS_RC [catch {set CONS_MSG [check_spv -consistency -property $SECID_TARGET_PROPERTIES -list both -include_stopats]} CONS_ERR]
if {$CONS_RC == 0} { puts $cf $CONS_MSG } else { puts $cf "ERROR: $CONS_ERR" }
close $cf

set sf2 [open [file join $RESULT_DIR signoff.txt] w]
set SIGN_RC [catch {set SIGN_MSG [check_spv -signoff -properties $SECID_TARGET_PROPERTIES]} SIGN_ERR]
if {$SIGN_RC == 0} { puts $sf2 $SIGN_MSG } else { puts $sf2 "ERROR: $SIGN_ERR" }
close $sf2

set REPORT_RC [catch {report -summary -force -result -file [file join $RESULT_DIR report.rpt]} REPORT_MSG]
if {$REPORT_RC != 0} {
  set rf [open [file join $RESULT_DIR report_command_warning.txt] w]
  puts $rf $REPORT_MSG
  close $rf
}

set stf [open [file join $RESULT_DIR status.tsv] w]
puts $stf "property	status"
if {[llength [info commands get_property_list]] > 0} {
  if {![catch {set SECID_PROPS [get_property_list]}]} {
    foreach p $SECID_PROPS {
      if {[string match "*SECID_*" $p]} {
        set st "UNKNOWN"
        if {[catch {set st [get_property_info -property $p -list status]}]} {
          catch {set st [get_property_info $p -list status]}
        }
        puts $stf "$p	$st"
      }
    }
  }
}
close $stf
puts "SECID_RUN_COMPLETE	60_effort_exclude_00_execution_unit_0_reg_src_r02	[file normalize $RESULT_DIR]"
