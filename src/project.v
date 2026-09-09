`default_nettype none

module tt_um_mac_int8 (
    input  wire [7:0] ui_in,    // Operando A (8 bits con signo)
    output wire [7:0] uo_out,   // Salida (8 bits inferiores del acumulador)
    input  wire [7:0] uio_in,   // Operando B (8 bits con signo)
    output wire [7:0] uio_out,  // Pines bidireccionales (en 0)
    output wire [7:0] uio_oe,   // Habilitación bidireccional (0 = entradas)
    input  wire       ena,      // Habilitación del sistema
    input  wire       clk,      // Reloj del sistema
    input  wire       rst_n     // Reset activo en bajo
);

    // Configurar pines bidireccionales estrictamente como entradas
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Cables internos para la unidad MAC
    wire signed [31:0] mac_out_full;
    wire valid_out_signal;

    // Instanciación de la unidad MAC
    mac_int8 u_mac (
        .clk           (clk),
        .rst_n         (rst_n),
        .valid_in      (1'b1),
        .accumulate_en (1'b0),
        .a_in          ($signed(ui_in)),
        .b_in          ($signed(uio_in)),
        .valid_out     (valid_out_signal),
        .mac_out       (mac_out_full)
    );

    // Asignación de los 8 bits inferiores a la salida física de Tiny Tapeout
    assign uo_out = mac_out_full[7:0];

    // Supresión de advertencias del Linter (Verilator) para bits no conectados
    wire _unused = &{ena, valid_out_signal, mac_out_full[31:8], 1'b0};

endmodule
