module LoadMask(
    input wire [31:0] MR,
    input wire [1:0] CT,
    output reg [31:0] OUT
);

    always @ (*) begin
      case (CT)
          2'b00: 
            OUT = MR;
          2'b01:
            begin
                OUT[31:16] = 16'b0;
                OUT[15:0] = MR[15:0];
            end
          2'b10:
            begin
                OUT[31:8] = 24'b0;
                OUT[7:0] = MR[7:0];
            end
          default: 
            OUT = MR;
      endcase
    end

endmodule