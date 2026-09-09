/*
 * Copyright (c) 2024 Joaquin O'Ryan
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_mac_int8 (
    input  wire [7:0] ui_in,    // Dedicated inputs       -> operando A (int8, con signo)
    output wire [7:0] uo_out,   // Dedicated outputs      -> resultado MAC, saturado a int8
    input  wire [7:0] uio_in,   // IOs: Input path        -> operando B (int8, con signo)
    output wire [7:0] uio_out,  // IOs: Output path       -> no usado
    output wire [7:0] uio_oe,   // IOs: Enable path       -> no usado (todo como entrada)
    input  wire        ena,      // always 1 when the design is powered, so you can ignore it
    input  wire        clk,      // clock
    input  wire        rst_n     // reset_n - low to reset
);

    // ------------------------------------------------------------------
    // Nucleo MAC: acumulacion CONTINUA (accumulate_en=1, valid_in=1 fijos).
    //
    // rst_n cumple doble funcion: reset de encendido, y "iniciar nueva
    // ventana de acumulacion". Para calcular un nuevo producto punto
    // (siguiente ventana de convolucion / siguiente canal de salida):
    //   1. Pulsa rst_n en bajo >=1 ciclo de reloj  -> mac_out vuelve a 0
    //   2. Sube rst_n a alto
    //   3. Alimenta un par (operando A, operando B) por cada ciclo de reloj
    // ------------------------------------------------------------------
    wire signed [31:0] mac_result;
    wire               mac_valid;

    mac_int8 u_mac (
        .clk           (clk),
        .rst_n         (rst_n),
        .valid_in      (1'b1),
        .accumulate_en (1'b1),
        .a_in          (ui_in),
        .b_in          (uio_in),
        .valid_out     (mac_valid),
        .mac_out       (mac_result)
    );

    // ------------------------------------------------------------------
    // El acumulador es de 32 bits pero uo_out solo tiene 8 pines.
    // En vez de truncar en crudo (lo que provocaba wraparound silencioso
    // en la version anterior), saturamos al rango int8 [-128, 127].
    // ------------------------------------------------------------------
    localparam signed [31:0] SAT_MAX = 32'sd127;
    localparam signed [31:0] SAT_MIN = -32'sd128;

    wire signed [7:0] sat_out;
    assign sat_out = (mac_result > SAT_MAX) ? SAT_MAX[7:0] :
                      (mac_result < SAT_MIN) ? SAT_MIN[7:0] :
                                                mac_result[7:0];

    assign uo_out = sat_out;

    // Pines bidireccionales: no se usan, se dejan como entrada y en 0.
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Evita warnings de "senal no usada" en el linter (no afecta la logica).
    wire _unused = &{ena, mac_valid, 1'b0};

endmodule
