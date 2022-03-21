module mux_8x1 (
    input wire [31:0] Data_0,
    input wire [31:0] Data_1,
    input wire [31:0] Data_2,
    input wire [31:0] Data_3,
    input wire [31:0] Data_4,
    input wire [31:0] Data_5,
    input wire [31:0] Data_6,
    input wire [31:0] Data_7,

    input wire [2:0] Selector,
    output wire [31:0] Data_out

);
wire [31:0] A1, A2, A3, A4;

assign A1 = (Selector[0]) ? Data_7 : Data_6;
assign A2 = (Selector[0]) ? Data_5 : Data_4;
assign A3 = (Selector[0]) ? Data_3 : Data_2;
assign A4 = (Selector[0]) ? Data_1 : Data_0;

assign Data_out = (Selector[2]) ? ((Selector[1]) ? A1 : A2) :
                    (Selector[1]) ? A3 : A4;

    
endmodule