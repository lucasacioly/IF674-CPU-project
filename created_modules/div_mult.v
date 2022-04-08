module div_mult(
    input clk,
    input reset,
    input [1:0] controle,
    input [31:0] A, B, 

    output reg [31:0] HI, LO,
    output wire div0
);

wire [31:0] HI_MULT;
wire [31:0] LO_MULT;
wire [31:0] HI_DIV;
wire [31:0] LO_DIV;

multiplier mult(
    .mc(A), 
    .mp(B),
    .clk(clk),
    .start(controle), 
    .reset(reset),
    .hi(HI_MULT), 
    .lo(LO_MULT)
);

div divide(
    .A(A), 
    .B(B),
    .clk(clk),
    .start(controle), 
    .reset(reset),  
    .hi(HI_DIV), 
    .lo(LO_DIV),
    .flag(div0) 
);



// instanciar div

always @(posedge clk) begin
    case (controle) 

        2'd0: begin
            HI = 32'b0;
            LO = 32'b0;
        end

        2'd1: begin
            HI = HI_DIV;
            LO = LO_DIV;
        end

        2'd2: begin
            HI = HI_MULT;
            LO = LO_MULT;
        end
    endcase
end


endmodule