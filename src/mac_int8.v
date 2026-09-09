`default_nettype none

module mac_int8 (
    input  wire               clk,           // Reloj del sistema
    input  wire               rst_n,         // Reset asíncrono (activo en bajo)
    input  wire               valid_in,      // Señal de control: Entradas válidas
    input  wire               accumulate_en, // 1: Acumula | 0: Carga solo multiplicación
    input  wire signed [7:0]  a_in,          // Operando A (INT8 con signo)
    input  wire signed [7:0]  b_in,          // Operando B (INT8 con signo)
    output reg                valid_out,     // Indica que mac_out tiene dato válido
    output reg signed [31:0]  mac_out        // Acumulador de 32 bits
);

    // 1. SEÑALES INTERNAS
    wire signed [15:0] product;
    wire signed [31:0] next_mac;

    // 2. LÓGICA COMBINACIONAL (Aritmética de síntesis)
    assign product  = a_in * b_in;
    assign next_mac = accumulate_en ? (mac_out + $signed(product)) : $signed(product);

    // 3. LÓGICA SECUENCIAL (Flip-Flops)
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
