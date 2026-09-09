`default_nettype none

module tt_um_mac_int8 (
    input  wire [7:0] ui_in,
    output wire [7:0] mac_result, // Alineado con el info.yaml para el Precheck
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire signed [31:0] mac_result_internal;
    wire               mac_valid;

    // Instancia de tu función principal (intacta)
    mac_int8 u_mac (
        .clk            (clk),
        .rst_n          (rst_n),
        .valid_in       (1'b1),
        .accumulate_en  (1'b1),
        .a_in           (ui_in),
        .b_in           (uio_in),
        .valid_out      (mac_valid),
        .mac_out        (mac_result_internal)
    );

    // Lógica de saturación para visión artificial (intacta)
    localparam signed [31:0] SAT_MAX = 32'sd127;
    localparam signed [31:0] SAT_MIN = -32'sd128;

    wire signed [7:0] sat_out;
    assign sat_out = (mac_result_internal > SAT_MAX) ? SAT_MAX[7:0] :
                     (mac_result_internal < SAT_MIN) ? SAT_MIN[7:0] :
                                                       mac_result_internal[7:0];

    // Conexión directa al bus de salida que espera el Precheck y tu info.yaml
    assign mac_result = sat_out;

    // Asignación de pines bidireccionales como entradas puras (Tie-Low físico)
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Sumidero para evitar advertencias del linter
    wire _unused = &{ena, mac_valid, 1'b0};

endmodule
