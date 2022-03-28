module ctrl_unity(
    input wire clk,
    input wire reset_in,

// instruction
    input wire [5:0] OPCODE,
    input wire [5:0] FUNCT,

// flags

    input wire O;         // OVERFLOW
    input wire ZERO;      // ZERO on operation
    input wire GT;        // Greater than
    input wire LT;        // Less than
    input wire EG;        // Equal to
    input wire N          // negative

// outputs

// ULA
output reg [2:0] ALUop;

// DIV e MULT
output reg Div_Mult_Ctrl;
output reg DIV0;

// armazenamentos e deslocamentos
output reg MEMwrite;             // MEMÓRIA
output reg [2:0] Shift;         // registrador de deslocamento
output reg RegWrite;              // banco de registradores

// Mascaras de Store e Load
output reg [1:0] SMcontrol;
output reg [1:0] LMcontrol;

// multiplexadores
output reg [1:0] EXCPcontrol;
output reg [2:0] IorD;
output reg ShiftRegCtrl;
output reg [1:0] ShiftAmmCtrl;
output reg [1:0] RegDst;
output reg [2:0] MemToReg;
output reg [1:0] ALUsrcA;
output reg [2:0] ALUsrcB;
output reg [2:0] PCsrc;


// registradores

output reg PCwrite;
output reg IrWrite;
output reg MDRwrite;
output reg write;     // sinal para escrever em HI e LO
output reg Awrite;
output reg Bwrite;
output reg EPCcontrol;
output reg ALUoutCtrl;

// reset 
output reg reset_out;

);


    reg [6:0] STATE;
    reg [5:0] COUNTER;
    reg [42:0] OUTPUT_TABLE [0:6];
//-------------------------------PARAMETROS DE ESTADO------------------------------//

    // ESTADOS
    parameter STATE_RESET        =   7'd0;
    parameter STATE_FETCH0       =   7'd1;
    parameter STATE_FETCH1       =   7'd2;


    // OPCODES E FUNÇÕES

    parameter R_instruction     =   6'h0;
    parameter ADD               =   6'h20;
    parameter AND               =   6'h24;
    parameter DIV               =   6'h1a;
    parameter MULT              =   6'h18;
    parameter JR                =   6'h8;
    parameter MFHI              =   6'h10;
    parameter MFLO              =   6'h12;
    parameter SLL               =   6'h0;
    parameter SLLV              =   6'h4;
    parameter SLT               =   6'h2a;
    parameter SRA               =   6'h3;
    parameter SRAV              =   6'h7;
    parameter SRL               =   6'h2;
    parameter SUB               =   6'h22;
    parameter BREAK             =   6'hd;
    parameter RTE               =   6'h13;
    parameter ADDM              =   6'h5;


    parameter ADDI              =   6'h8;
    parameter ADDIU             =   6'h9;
    parameter BEQ               =   6'h4;
    parameter BNE               =   6'h5;
    parameter BLE               =   6'h6;
    parameter BGT               =   6'h7;
    parameter SLLM              =   6'h1;
    parameter LB                =   6'h20;
    parameter LH                =   6'h21;
    parameter LUI               =   6'hf;
    parameter LW                =   6'h23;
    parameter SB                =   6'h28;
    parameter SH                =   6'h29;
    parameter SLTI              =   6'ha;
    parameter SW                =   6'h2B;


    parameter JUMP              =   6'h2;
    parameter JAL               =   6'h3;

//-------------------------------------INICIALIZAÇÃO-------------------------//

initial begin
    // reset inicial    
    reset_out = 1'b1;  
end


always @(posedge clk) begin
    if (reset_in == 1'b1) begin
        if (STATE != STATE_RESET) begin
            STATE = STATE_RESET;

            //SET ALL SIGNALS
            
        end
    end
end

endmodule