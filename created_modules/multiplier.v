module multiplier(

input [31:0] mc, mp,
input [1:0]start,
input clk, reset,
output [31:0] hi, lo

);

reg [31:0] A, Q, M;
reg Q_1;
reg [5:0] count;
wire [31:0] sum, difference;
wire [63:0] prod;

always @(posedge clk) begin
    if (reset || start == 2'd0 || start == 2'd1) begin
        A <= 32'b0;
        Q <= 32'b0;
        M <= 32'b0;
        Q_1 <= 0;
        count <= 6'b0;
    end
    else if (start == 2'd2) begin
        if (count == 0) begin
            A <= 32'b0;
            M <= mc;
            Q <= mp;
            Q_1 <= 1'b0;
            count <= 6'b000001;
        end

        else if(count > 0 && count < 33) begin
            case ({Q[0], Q_1})
                2'b0_1 : {A, Q, Q_1} <= {sum[31], sum, Q};
                2'b1_0 : {A, Q, Q_1} <= {difference[31], difference, Q};
            default: {A, Q, Q_1} <= {A[31], A, Q};
            endcase

            count <= count + 1'b1;
        end

    end
    

end

assign sum = A + M;
assign difference = A + ~M + 1;
assign hi = A;
assign lo = Q;
assign prod = {A, Q};

endmodule