module StoreMask(
  input wire [31:0] B,
  input wire [31:0] MR,
  input wire [1:0] CT,
  output reg [31:0] OUT
);

  always @ (*) begin
    case (CT)
      2'b00: 
        OUT = B;
      2'b01:
        begin
          OUT[31:16] = MR[31:16];
          OUT[15:0] = B[15:0];
        end
      2'b10:
        begin
          OUT[31:8] = MR[31:8];
          OUT[7:0] = B[7:0];
        end
      default: 
        OUT = B;
    endcase
  end

endmodule