`default_nettype none

module tt_um_mac_int8 (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire signed [31:0] mac_result;
    wire               mac_valid;

    // Instanciación de tu función principal (intacta)
    mac_int8 u_mac (
        .clk            (clk),
        .rst_n          (rst_n),
        .valid_in       (1'b1),
        .accumulate_en  (1'b1),
        .a_in           (ui_in),
        .b_in           (uio_in),
        .valid_out      (mac_valid),
        .mac_out        (mac_result)
    );

    // Lógica de saturación (intacta y con formato limpio)
    localparam signed [31:0] SAT_MAX = 32'sd127;
    localparam signed [31:0] SAT_MIN = -32'sd128;

    wire signed [7:0] sat_out;
    assign sat_out = (mac_result > SAT_MAX) ? SAT_MAX[7:0] :
                     (mac_result < SAT_MIN) ? SAT_MIN[7:0] :
                                              mac_result[7:0];

    assign uo_out = sat_out;

    // =======================================================
    // FIX APLICADO AQUÍ: 
    // Se elimina el always block y los registros (* keep *).
    // La asignación directa a 0 le indica al flujo de OpenLane 
    // que inserte celdas Tie-Low físicas en el Layout.
    // =======================================================
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Sumidero de señales no utilizadas para evitar warnings de linter (intacto)
    wire _unused = &{ena, mac_valid, 1'b0};

endmodule
