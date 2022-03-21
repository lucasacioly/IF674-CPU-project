module shift_left_16_lui(
    input wire [15:0] data_in,
    output wire [31:0] data_out
);

    assign data_out = {data_in, {16{1'b0}}};

endmodule