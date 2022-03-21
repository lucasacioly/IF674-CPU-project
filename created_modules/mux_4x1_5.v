module mux_4x1_5 (
    input wire [5:0] Data_0,
    input wire [5:0] Data_1,
    input wire [5:0] Data_2,
    input wire [5:0] Data_3,

    input wire [1:0] Selector,
    output wire [5:0] Data_out
);

wire [5:0] A1, A2;

assign A1 = (Selector[0]) ? Data_3 : Data_2;
assign A2 = (Selector[0]) ? Data_1 : Data_0;

assign Data_out = (Selector[1]) ? A1 : A2;
endmodule