`timescale 1ns/1ps
// Z01X primary-asset detector for reverse candidate -> PC fault validation.
//
// v1.1.1 policy:
//   * FaultInfo.Attempts > 0 is authoritative for whether a fault was actually
//     simulated by Z01X.
//   * U8: a defined 0/1 PC difference was observed.
//   * U9: a PC difference involving X/Z was observed.
//   * There is intentionally NO synthetic end-of-test "no difference" status.
//     If an actually-attempted fault never reaches U8/U9, the analysis labels
//     it PC_NOT_DETECTED for that workload.  This avoids relying on a late
//     $fs_set_status callback for fault machines that Z01X may have already
//     merged/dropped from active concurrent simulation.
//   * NC/NO/NS remain Z01X-native zero-attempt testability outcomes.
//
// The good machine has an empty $fs_get_status(). Faulty-machine invocations
// have a non-empty status.  U8/U9 are generated only by an observed PC effect.
module secid_pc_strobe;
  integer cmp;
  integer status_probe_done;
  string fs_status;

  initial status_probe_done = 0;

  function automatic integer secid_is_pc_detected(input string s);
    begin
      secid_is_pc_detected = ((s == "U8") || (s == "U9"));
    end
  endfunction

  // dco_clk always runs in the OpenMSP430 harness, unlike gated mclk. This lets
  // us detect a PC effect even when a candidate fault stalls MCLK.
  always @(posedge tb.dco_clk) begin
    if (tb.reset_n === 1'b1) begin
      fs_status = $fs_get_status();

      // One diagnostic line per faulty-machine invocation.  The good machine
      // has an empty status and therefore does not print this line.
      if ((fs_status != "") && !status_probe_done) begin
        $display("SECID_FS_STATUS_INITIAL,%s", fs_status);
        status_probe_done = 1;
      end

      if ((fs_status != "") && !secid_is_pc_detected(fs_status)) begin
        // Never use a golden X/Z as detection evidence.
        if ((^tb.dut_g.frontend_0.pc) !== 1'bx) begin
          cmp = $fs_compare(tb.dut_g.frontend_0.pc);
          if (cmp == 1)
            $fs_drop_status("U8", tb.dut_g.frontend_0.pc);
          else if (cmp == 2)
            $fs_drop_status("U9", tb.dut_g.frontend_0.pc);
        end
      end
    end
  end
endmodule
