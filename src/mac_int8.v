/*
 * Modulo: mac_int8
 * Descripcion: Unidad Multiply-Accumulate de 1 ciclo para inferencia INT8.
 * Estandar: IEEE 1364-2005 (Verilog). Optimizado para Yosys/OpenLane.
 *
 * Sin cambios de logica respecto a tu version original: este archivo ya
 * estaba correcto. El bug estaba en como project.v lo conectaba.
 */

module mac_int8 (
    input  wire               clk,           // Reloj del sistema
    input  wire               rst_n,         // Reset asincrono (activo en bajo)
    input  wire               valid_in,      // Senal de control: Entradas validas
    input  wire                accumulate_en, // 1: Acumula | 0: Carga solo multiplicacion
    input  wire signed [7:0]  a_in,          // Operando A (INT8 con signo)
    input  wire signed [7:0]  b_in,          // Operando B (INT8 con signo)
    output reg                 valid_out,     // Indica que mac_out tiene dato valido
    output reg  signed [31:0] mac_out        // Acumulador de 32 bits
);

    // ------------------------------------------------------------
    // 1. SENALES INTERNAS
    // ------------------------------------------------------------

    // Multiplicacion de 8-bit x 8-bit con signo genera 16 bits
    wire signed [15:0] product;

    // Resultado intermedio antes de registrarse en el acumulador
    wire signed [31:0] next_mac;

    // ------------------------------------------------------------
    // 2. LOGICA COMBINACIONAL (Aritmetica de sintesis)
    // ------------------------------------------------------------

    // Multiplicacion directa (Yosys la inferira como celdas aritmeticas optimizadas)
    assign product = a_in * b_in;

    // Multiplexion de acumulacion y extension de signo implicita ($signed)
    assign next_mac = (accumulate_en) ? (mac_out + $signed(product)) : $signed(product);

    // ------------------------------------------------------------
    // 3. LOGICA SECUENCIAL (Flip-Flops)
    // ------------------------------------------------------------

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mac_out   <= 32'sd0;
            valid_out <= 1'b0;
        end else begin
            if (valid_in) begin
                mac_out   <= next_mac;
                valid_out <= 1'b1;
            end else begin
                valid_out <= 1'b0;
            end
        end
    end

endmodule
