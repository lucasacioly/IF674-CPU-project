`include "../load_mask.v"

`timescale 1ns/1ps

module LoadMask_tb();
  reg [31:0] inp;
  reg [1:0] ct;
  wire [31:0] outp;

  LoadMask loadMask(
    .MR(inp),
    .CT(ct),
    .OUT(outp)
  );

  initial begin
    $dumpfile("./created_modules/tests/vcd/load_mask_tb.vcd");
    $dumpvars(0, LoadMask_tb);

    inp = 0;
    ct = 0;

    #10;
      inp = 'h80000000; //valor numérico de 32 bits que tem 1 no bit mais significativo
    #10;
      ct = 1;
    #10;
      ct = 2;
    #10;
      ct = 0;
  end


endmodule