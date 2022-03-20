//Para compilar este testbench a partir desta pasta esse deve ser o include
//`include "../store_mask.v"
//Para compilar a partir da pasta raiz/usando o script compile_testbenches o include a seguir resolve
`include "./created_modules/store_mask.v"
`timescale 1ns/1ps

module StoreMask_tb();
  reg [31:0] B;
  reg [31:0] mem;
  reg [1:0] ct;
  wire [31:0] outp;

  StoreMask StoreMask(
    .B(B),
    .MR(mem),
    .CT(ct),
    .OUT(outp)
  );

  initial begin
    $dumpfile("./created_modules/tests/vcd/store_mask_tb.vcd");
    $dumpvars(0, StoreMask_tb);

    B = 0;
    mem = 'hFFFFFFFF; //valor numérico de 32 bits preenchido por 1s
    ct = 0;

    #10;
      B = 'h8; //valor numérico de 32 bits que tem 1 no meio do byte menos significativo
    #10;
      ct = 1;
    #10;
      ct = 2;
    #10;
      ct = 0;
  end


endmodule