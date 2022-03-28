module control_unit(
    input wire clk,
    input wire reset_in,

// instruction
    input wire [5:0] OPCODE,
    input wire [5:0] FUNCT,

// flags

    input wire O,         // OVERFLOW
    input wire ZERO,      // ZERO on operation
    input wire GT,        // Greater than
    input wire LT,        // Less than
    input wire EG,        // Equal to
    input wire N,         // negative
    input wire DIV0,      // DIV0 exception signal

// outputs

// ULA
    output wire [2:0] ALUop,

// DIV e MULT
    output wire Div_Mult_Ctrl,

// armazenamentos e deslocamentos
    output wire MEMwrite,             // MEMÓRIA
    output wire [2:0] Shift,         // registrador de deslocamento
    output wire RegWrite,              // banco de registradores

// Mascaras de Store e Load
    output wire [1:0] SMcontrol,
    output wire [1:0] LMcontrol,

// multiplexadores
    output wire [1:0] EXCPcontrol,
    output wire [2:0] IorD,
    output wire ShiftRegCtrl,
    output wire [1:0] ShiftAmmCtrl,
    output wire [1:0] RegDst,
    output wire [2:0] MemToReg,
    output wire [1:0] ALUsrcA,
    output wire [2:0] ALUsrcB,
    output wire [2:0] PCsrc,


// registradores

    output wire PCwrite,
    output wire IrWrite,
    output wire MDRwrite,
    output wire write,     // sinal para escrever em HI e LO
    output wire Awrite,
    output wire Bwrite,
    output wire EPCcontrol,
    output wire ALUoutCtrl,

// reset 
    output wire reset_out
);


    reg [6:0] STATE;
    reg [5:0] COUNTER;
    reg [42:0] STATE_OUTPUT_TABLE [0:6];
    wire [42:0] OUTPUT_WORD;

    assign ALUop = OUTPUT_WORD[42:40];
    assign Div_Mult_Ctrl = OUTPUT_WORD[39];
    assign MEMwrite = OUTPUT_WORD[38];
    assign Shift = OUTPUT_WORD[37:35];
    assign RegWrite = OUTPUT_WORD[34];
    assign SMcontrol = OUTPUT_WORD[33:32];
    assign LMcontrol = OUTPUT_WORD[31:30];
    assign EXCPcontrol = OUTPUT_WORD[29:28];
    assign IorD = OUTPUT_WORD[27:25];
    assign ShiftRegCtrl = OUTPUT_WORD[24];
    assign ShiftAmmCtrl = OUTPUT_WORD[23:22];
    assign RegDst = OUTPUT_WORD[21:20];
    assign MemToReg = OUTPUT_WORD[19:17];
    assign ALUsrcA = OUTPUT_WORD[16:15];
    assign ALUsrcB = OUTPUT_WORD[14:12];
    assign PCsrc = OUTPUT_WORD[11:9];
    assign PCwrite = OUTPUT_WORD[8];
    assign IrWrite = OUTPUT_WORD[7];
    assign MDRwrite = OUTPUT_WORD[6];
    assign write = OUTPUT_WORD[5];
    assign Awrite = OUTPUT_WORD[4];
    assign Bwrite = OUTPUT_WORD[3];
    assign EPCcontrol = OUTPUT_WORD[2];
    assign ALUoutCtrl = OUTPUT_WORD[1];
    assign reset_out = OUTPUT_WORD[0];

    //assign OUTPUT_WORD = STATE_OUTPUT_TABLE[STATE];

//-------------------------------PARAMETROS DE ESTADO------------------------------//

    //-----------------------------ESTADOS----------------------------//
    //  COMUNS
    parameter STATE_RESET               =   7'd0;
    parameter STATE_FETCH0              =   7'd1;
    parameter STATE_FETCH1              =   7'd2;
    parameter STATE_DECODE0             =   7'd3;
    parameter STATE_DECODE1             =   7'd4;
    //  ADD
    parameter STATE_ADD0                =   7'd5;
    parameter STATE_ADD1                =   7'd6;

    //  ADD, AND, SUB ENDING STATE
    parameter STATE_ADD_AND_SUB_ENDING  =   7'd7;
    

    //---------------------------FIM ESTADOS--------------------------//


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
    
    
//     //----------------------  INICIALIZAÇÃO DA TABELA DE OUTPUTS  ---------------------//

    
//     ///////////////   RESET   /////////////
//     // RegWrite =1          /34
//     // RegDst = 3           /21:20
//     // MemToReg = 4         /19:17
//     // reset_out = 1        /0
//     STATE_OUTPUT_TABLE[STATE_RESET] = 43'd0;

//     STATE_OUTPUT_TABLE[STATE_RESET][34] = 1;        // RegWrite =1          /34
//     STATE_OUTPUT_TABLE[STATE_RESET][21:20] = 2'd3;   // RegDst = 3           /21:20
//     STATE_OUTPUT_TABLE[STATE_RESET][19:17] = 3'd4;   // MemToReg = 4         /19:17
//     STATE_OUTPUT_TABLE[STATE_RESET][0] = 1;         // reset_out = 1        /0
//     ///////////////   RESET   /////////////


//     //------------------  FIM DA INICIALIZAÇÃO DA TABELA DE OUTPUTS  ------------------//

    STATE = STATE_RESET;
end

always @(posedge clk) begin
    if (reset_in == 1'b1) begin
        if (STATE != STATE_RESET) begin
            STATE = STATE_RESET;
        end
    end else begin
        case (STATE)
            //------        ESTADOS "COMUNS"      --------//
            STATE_RESET:
                STATE = STATE_FETCH0; 
            STATE_FETCH0:
                STATE = STATE_FETCH1;
            STATE_FETCH1:
                STATE = STATE_DECODE0;
            STATE_DECODE0:
                STATE = STATE_DECODE1;
            STATE_DECODE1:
                if (OPCODE == 0 && FUNCT == ADD) begin
                    STATE = STATE_ADD0;
                end else
                    STATE = STATE_FETCH0;
            //------     FIM ESTADOS "COMUNS"     --------//

            //  ADD
            STATE_ADD0:
                STATE = STATE_ADD1;
            STATE_ADD1:
                STATE = STATE_ADD_AND_SUB_ENDING;

            //  ADD, AND, SUB ENDING STATE
            STATE_ADD_AND_SUB_ENDING:
                STATE = STATE_FETCH0;

            default: 
                STATE = STATE_RESET;
        endcase
    end

end

endmodule