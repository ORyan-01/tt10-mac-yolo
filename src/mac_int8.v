`default_nettype none

module mac_int8 (
    input  wire               clk,           
    input  wire               rst_n,         
    input  wire               valid_in,      
    input  wire               accumulate_en, 
    input  wire signed [7:0]  a_in,          
    input  wire signed [7:0]  b_in,          
    output reg                valid_out,     
    output reg signed [31:0]  mac_out        
);

    wire signed [15:0] product;
    wire signed [31:0] product_ext;
    wire signed [31:0] next_mac;

    assign product     = a_in * b_in;
    // Extensión de signo manual para evitar el fallo de Yosys
    assign product_ext = {{16{product[15]}}, product}; 
    assign next_mac    = accumulate_en ? (mac_out + product_ext) : product_ext;

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
