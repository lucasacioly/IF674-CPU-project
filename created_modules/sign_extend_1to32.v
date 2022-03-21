module sign_extend_1to32(
    input wire data_in,
    output reg [31:0] data_out
);

    always @(data_in)
        begin
            if (data_in[15] == 1'b1)
                begin
                    data_out = {{31{1'b1}},data_in};
                end
            else
                begin
                    data_out = {{31{1'b0}},data_in};
                end
        end
endmodule