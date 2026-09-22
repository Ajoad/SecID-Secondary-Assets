// ============================================================================
// Cluster-local relation RTL: C001 -> apb_gpio_gpio_dir_cone.gpio_dir
// Source-faithful APB-GPIO analysis-RTL relation slice.
// Exact deduplicated union of the already-selected candidate-local RTL evidence for 3 RTL-proximal candidates. Members: apb_gpio_gpio_dir_cone.PSEL, apb_gpio_gpio_dir_cone.PWRITE, apb_gpio_gpio_dir_cone.r_gpio_dir. Per-candidate guarded structural paths remain in separate JSON files; this shared file supplies only the cluster-local RTL context.
// Unrelated RTL is intentionally omitted. This evidence file is not intended
// to be a standalone compilation unit.
// ============================================================================

// ----------------------------------------------------------------------------
// Original source: apb_gpio_gpio_dir_cone.sv
// Source: audited source-equivalent APB-GPIO gpio_dir fan-in cone
// ----------------------------------------------------------------------------
    input  logic        HCLK,
    input  logic        HRESETn,
    input  logic [11:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PSEL,
    input  logic        PENABLE,
    output logic [31:0] gpio_dir
);
    localparam logic [4:0] REG_PADDIR   = 5'b00000;
    localparam logic [4:0] REG_GPIOLOCK = 5'b10010;
// ... unrelated original RTL lines 15-15 omitted ...
    (* keep *) logic [31:0] r_gpio_dir;
    (* keep *) logic [31:0] r_gpio_lock;
    (* keep *) logic [31:0] pwdata_l;
    (* keep *) logic [4:0]  s_apb_addr;
// ... unrelated original RTL lines 20-29 omitted ...
    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            r_gpio_dir  <= '0;
            r_gpio_lock <= '0;
        end else if (PSEL && PENABLE && PWRITE) begin
            case (s_apb_addr)
                REG_PADDIR:   r_gpio_dir  <= pwdata_l;
                REG_GPIOLOCK: r_gpio_lock <= PWDATA;
                default: ;
            endcase
        end
    end
// ... unrelated original RTL lines 42-42 omitted ...
    assign gpio_dir = r_gpio_dir;
