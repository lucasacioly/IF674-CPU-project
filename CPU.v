
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

// REGISTRADOR DE DESLOCAMENTOS

// DIV e MULT



// BANCO DE REGISTRADORES
// MEMORIA



// PC
// IR
// MDR
// ALUout
// EPC
// HI
// LO



// LOAD MASK
// STORE MASK



// mux_EXCP
wire mux_EXCP_out;

// mux_memory
wire mux_memory_out;

// mux_PC
wire mux_PC_out;

// mux_Shift_Ammount
wire mux_Shift_Ammount_out;

// mux_Shift_Reg
wire mux_Shift_Reg_out;

// mux_ulaA
wire mux_ulaA_out;

// mux_ulaB
wire mux_ulaB_out;

// mux_Write_Data
wire mux_Write_Data_out;

// mux_Write_Reg
wire mux_Write_Reg_out;


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
wire EXCPcontrol;
wire IorD;
wire ShiftRegCtrl;
wire ShiftAmmCtrl;
wire RegDst;
wire MemToReg;
wire ALUsrcA;
wire ALUsrcB;
wire PCsrc;

// Mascaras de Store e Load
wire SMcontrol;
wire LMcontrol;

// armazenamentos e deslocamentos
wire MEMwrite;      // MEMÓRIA
wire Shift;         // registrador de deslocamento
wire RegWrite;       // banco de registradores

// ULA
wire ALUop;
wire O;         // OVERFLOW
wire Z;         // ZERO on operation
wire GT;        // Greater than
wire LT;        // Less than
wire EG;        // Equal to

// DIV e MULT
wire Div_Mult_Ctrl;
wire DIV0;



endmodule