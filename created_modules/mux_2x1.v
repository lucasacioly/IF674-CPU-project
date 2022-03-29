module mux_2x1 (
    input wire [31:0] Data_0,
    input wire [31:0] Data_1,

    input wire Selector,
    output wire [31:0] Data_out
);

assign Data_out = (Selector) ? Data_1 : Data_0;

endmodule