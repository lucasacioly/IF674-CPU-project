
module CPU(
    input wire clk,
    input wire reset
);

// parâmetros especiais
parameter REG_31 = 5'd31;
parameter REG_29 = 5'd29;
parameter NUM_4 = 32'd4;     // para somas e subtrações na ULA    
parameter NUM_227 = 32'd227; //para reset
parameter NUM_253 = 32'd253; //para os exceção
parameter NUM_254 = 32'd254; //para os exceção
parameter NUM_255 = 32'd255; //para os exceção

//----------------------INSTANCIAR FIOS DA CPU------------------------//

//--------------------------fios de dados----------------------------// 

//obs -> esses fios estão mapeados de acordo com o módulo do qual saem!

// ULA
wire [31:0] ula_result;

// REGISTRADOR DE DESLOCAMENTOS
wire [31:0] shift_out;

// DIV e MULT
wire [31:0] div_mult_hi;
wire [31:0] div_mult_lo;


// BANCO DE REGISTRADORES
wire [31:0] read_data_1;
wire [31:0] read_data_2;

// MEMORIA
wire [31:0] mem_out;


// P
wire [31:0] PC_out;

// IR
wire [5:0] OP_CODE;
wire [4:0] RS;
wire [4:0] RT;
wire [15:0] OFSET;

// MDR
wire [31:0] MDR_out;

// ALUout
wire [31:0] ALUout_out;

// EPC
wire [31:0] EPC_out;

// HI
wire [31:0] HI_out;

// LO
wire [31:0] LO_out;



// LOAD MASK
wire [31:0] load_mask_out;

// STORE MASK
wire [31:0] store_mask_out;


// sign extend 1 to 32
wire [31:0] 1to32_out;
// sign extend 16 to 32
wire [31:0] 16to32_out;
// shift left 16
wire [31:0] shift16_out;
// shift left 2 branch
wire [31:0] shift2_branch_out;
// shift left 2 jump
wire [27:0] shift2_jump_out;


// mux_EXCP
wire [31:0] mux_EXCP_out;

// mux_memory, o que leva dados para a memoria
wire [31:0] mux_memory_out;

// mux_PC, o que leva os dados para o PC
wire [31:0] mux_PC_out;

// mux_Shift_Ammount
wire [4:0] mux_Shift_Ammount_out;

// mux_Shift_Reg
wire [31:0] mux_Shift_Reg_out;

// mux_ulaA
wire [31:0] mux_ulaA_out;

// mux_ulaB
wire [31:0] mux_ulaB_out;

// mux_Write_Data
wire [31:0] mux_Write_Data_out;

// mux_Write_Reg
wire [4:0] mux_Write_Reg_out;


//-----------------------sinais de controle-------------------------//

// registradores

wire PCwrite;
wire IrWrite;
wire MDRwrite;
wire write;     // sinal para escrever em HI e LO
wire Awrite;
wire Bwrite;
wire EPCcontrol;
wire ALUoutCtrl;

// multiplexadores
wire [1:0] EXCPcontrol;
wire [2:0] IorD;
wire ShiftRegCtrl;
wire [1:0] ShiftAmmCtrl;
wire [1:0] RegDst;
wire [2:0] MemToReg;
wire [1:0] ALUsrcA;
wire [2:0] ALUsrcB;
wire [2:0] PCsrc;

// Mascaras de Store e Load
wire [1:0] SMcontrol;
wire [1:0] LMcontrol;

// armazenamentos e deslocamentos
wire MEMwrite;      // MEMÓRIA
wire [2:0] Shift;         // registrador de deslocamento
wire RegWrite;       // banco de registradores

// ULA
wire [3:0] ALUop;
wire O;         // OVERFLOW
wire Z;         // ZERO on operation
wire GT;        // Greater than
wire LT;        // Less than
wire EG;        // Equal to

// DIV e MULT
wire Div_Mult_Ctrl;
wire DIV0;



endmodule