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

    // Decodificación de control desde uio_in
    wire       valid_in      = uio_in[0];
    wire       accumulate_en = uio_in[1];
    wire       load_b        = uio_in[5];
    wire [1:0] byte_sel      = uio_in[4:3];

    reg signed [7:0] a_reg;
    reg signed [7:0] b_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg <= 8'sd0;
            b_reg <= 8'sd0;
        end else if (ena) begin
            if (!load_b) 
                a_reg <= ui_in;
            else         
                b_reg <= ui_in;
        end
    end

    wire valid_out_core;
    wire signed [31:0] mac_result;

    mac_int8 mac_core (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .accumulate_en(accumulate_en),
        .a_in(a_reg),
        .b_in(b_reg),
        .valid_out(valid_out_core),
        .mac_out(mac_result)
    );

    // Multiplexor de salida: extrae el resultado de 32 bits en bloques de 8 bits
    assign uo_out = (byte_sel == 2'b00) ? mac_result[7:0]   :
                    (byte_sel == 2'b01) ? mac_result[15:8]  :
                    (byte_sel == 2'b10) ? mac_result[23:16] :
                                          mac_result[31:24];

    // Configuración de puertos bidireccionales
    assign uio_oe       = 8'b0000_0100; // uio[2] como salida para valid_out
    assign uio_out[2]   = valid_out_core;
    assign uio_out[7:3] = 5'b0;
    assign uio_out[1:0] = 2'b0;

    wire _unused = &{ena, 1'b0};

endmodule
