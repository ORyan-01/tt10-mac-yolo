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

    // Pines bidireccionales forzados como entradas
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    wire signed [31:0] mac_out_full;
    wire valid_out_signal;

    mac_int8 u_mac (
        .clk           (clk),
        .rst_n         (rst_n),
        .valid_in      (1'b1),
        .accumulate_en (1'b0),
        .a_in          (ui_in),
        .b_in          (uio_in),
        .valid_out     (valid_out_signal),
        .mac_out       (mac_out_full)
    );

    assign uo_out = mac_out_full[7:0];

    // Sumidero estándar para silenciar a Verilator
    wire _unused = &{1'b0, ena, valid_out_signal, mac_out_full[31:8]};

endmodule
