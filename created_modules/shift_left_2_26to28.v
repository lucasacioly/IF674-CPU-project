module shift_left_2_26to28(
    input wire [25:0] data_in,
    output wire [27:0] data_out
);

    assign data_out = {data_in, {2{1'b0}}};

endmodule