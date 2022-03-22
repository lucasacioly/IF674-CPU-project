module mux_3x1_4 (
    input wire [4:0] Data_0,
    input wire [4:0] Data_1,
    input wire [4:0] Data_2,

    input wire [1:0] Selector,
    output wire [4:0] Data_out
);

wire [4:0] A1;
assign A1 = (Selector[0]) ? Data_1 : Data_0;

assign Data_out = (Selector[1]) ? Data_2 : A1;
endmodule