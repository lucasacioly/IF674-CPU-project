module shift_left_2_26to28(
    input wire [15:0] data_in,
    output wire [31:0] data_out
);

    assign data_out = {data_in, {2{1'b0}}};

endmodule