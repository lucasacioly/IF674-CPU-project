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

//-----------------------------------CONTADORES E TABELAS-------------------------------------//
    reg [6:0] STATE;    
    reg [5:0] COUNTER; // contador de clocks
    reg [42:0] STATE_OUTPUT_TABLE [0:68];
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

    assign OUTPUT_WORD = STATE_OUTPUT_TABLE[STATE];

//--------------------------------------PARAMETROS DE ESTADO--------------------------------------//

    //-----------------------------ESTADOS----------------------------//
    //  'ACABOU DE LIGAR'
    parameter STATE_ON                  = 7'b1111111;
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
    

    // ADDI, ADDIU
    parameter STATE_ADDI_ADDIU_0 = 7'd8; // ESTE ESTADO CONTARÁ COM UMA CHECAGEM DE OVERFLOW APENAS SE A INSTRUÇÃO EM QUESTÃO FOR O ADDI, MAS PRIMEIRO SERÁ IMPLEMENTADO O ADDIU
    parameter STATE_ADDI_ADDIU_1 = 7'd9;
    parameter STATE_ADDI_ADDIU_ENDING = 7'd10;
    
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

    STATE = STATE_ON;
    
    COUNTER = 0;
//     //----------------------  INICIALIZAÇÃO DA TABELA DE OUTPUTS  ---------------------//

//     //////////////  INICIO  ////////////////
        
    
//     ///////////////   RESET   /////////////
//     // RegWrite =1          /34
//     // RegDst = 3           /21:20
//     // MemToReg = 4         /19:17
//     // reset_out = 1        /0
     STATE_OUTPUT_TABLE[STATE_RESET] = 43'd0;

     STATE_OUTPUT_TABLE[STATE_RESET][34] = 1;        // RegWrite =1          /34
     STATE_OUTPUT_TABLE[STATE_RESET][21:20] = 2'd3;   // RegDst = 3           /21:20
     STATE_OUTPUT_TABLE[STATE_RESET][19:17] = 3'd4;   // MemToReg = 4         /19:17
     STATE_OUTPUT_TABLE[STATE_RESET][0] = 1;         // reset_out = 1        /0
//     ///////////////   RESET   /////////////

//      ///////////////  STATE_FETCH0   ///////////
//      // PCwrite = 0
//      // iorD = 0
//      // MEMwrite = 0
//      // IrWrite = 0
//      // ALUSrcA = 0         /16:15
//      // ALUSrcB = 1         /14:12   
//      // ALUop = 1           /42:40    
//      // PCSrc = 2           /11:9 
      STATE_OUTPUT_TABLE[STATE_FETCH0] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_FETCH0][14:12] = 3'd1;
      STATE_OUTPUT_TABLE[STATE_FETCH0][42:40] = 3'd1;
      STATE_OUTPUT_TABLE[STATE_FETCH0][11:9] = 3'd2;
//      ///////////////  STATE_FETCH0   ///////////

//      ///////////////  STATE_FETCH1     ///////////////////
//      // PCwrite = 1      /8
//      // iorD = 0
//      // MEMwrite = 0
//      // IrWrite = 1      /7
//      // ALUSrcA = 0 
//      // ALUSrcB = 1      /14:12
//      // ALUop = 1        /42:40
//      // PCSrc = 2        /11:9
      STATE_OUTPUT_TABLE[STATE_FETCH1] = 43'd0;
     
      STATE_OUTPUT_TABLE[STATE_FETCH1][8] = 1;
      STATE_OUTPUT_TABLE[STATE_FETCH1][7] = 1;
      STATE_OUTPUT_TABLE[STATE_FETCH1][14:12] = 3'd1;
      STATE_OUTPUT_TABLE[STATE_FETCH1][42:40] = 3'd1;
      STATE_OUTPUT_TABLE[STATE_FETCH1][11:9] = 3'd2;
//      ///////////////  STATE_FETCH1     ///////////////////

//      ///////////////  STATE_DECODE0     //////////////////////////
//      // ALUSrcA = 0 
//      // ALUSrcB = 3      /14:12
//      // ALUop = 1        /42:40
      STATE_OUTPUT_TABLE[STATE_DECODE0] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_DECODE0][14:12] = 3'd3;
      STATE_OUTPUT_TABLE[STATE_DECODE0][42:40] = 3'd1; 
//      ///////////////  STATE_DECODE0     //////////////////////////
     
//      ///////////////  STATE_DECODE1   /////////////////////////////
//      // ALUSrcA = 0 
//      // ALUSrcB = 3      /14:12
//      // ALUop = 1        /42:40
//      // Awrite = 1       /4
//      // Bwrite = 1       /3
//      // ALUoutCtrl = 1   /1
      STATE_OUTPUT_TABLE[STATE_DECODE1] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_DECODE1][14:12] = 3'd3;
      STATE_OUTPUT_TABLE[STATE_DECODE1][42:40] = 3'd1;
      STATE_OUTPUT_TABLE[STATE_DECODE1][4] = 1;
     STATE_OUTPUT_TABLE[STATE_DECODE1][3] = 1;
      STATE_OUTPUT_TABLE[STATE_DECODE1][1] = 1;
//      ///////////////  STATE_DECODE1   /////////////////////////////
    
//      ///////////////  STATE_ADD0   /////////////////////
//      // ALUSrcA = 2      /16:15
//      // ALUSrcB = 0      /14:12
//      // ALUop = 1        /42:40
      STATE_OUTPUT_TABLE[STATE_ADD0] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_ADD0][16:15] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_ADD0][42:40] = 3'd1;
//      ///////////////  STATE_ADD0   /////////////////////

//      ///////////////  STATE_ADD1   ////////////////////
//      // ALUSrcA = 2      /16:15
//      // ALUSrcB = 0      /14:12
//      // ALUop = 1        /42:40
//      // ALUoutCtrl = 1   /1
      STATE_OUTPUT_TABLE[STATE_ADD1] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_ADD0][16:15] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_ADD0][42:40] = 3'd1;
      STATE_OUTPUT_TABLE[STATE_ADD0][1] = 1;
//      ///////////////  STATE_ADD1   ////////////////////
    
//      ///////////////  STATE_ADD_AND_SUB_ENDING  ////////////////
//      // RegDst = 1       /21:20   
//      // MemToReg = 6     /19:17
//      // RegWrite = 1     /34
      STATE_OUTPUT_TABLE[STATE_ADD_AND_SUB_ENDING] = 43'd0;
       
      STATE_OUTPUT_TABLE[STATE_ADD_AND_SUB_ENDING][21:20] = 2'd1;
      STATE_OUTPUT_TABLE[STATE_ADD_AND_SUB_ENDING][19:17] = 3'd6;
      STATE_OUTPUT_TABLE[STATE_ADD_AND_SUB_ENDING][34] = 1;
//      ///////////////  STATE_ADD_AND_SUB_ENDING  ////////////////

//      ///////////////  STATE_ADDI_ADDIU_0  ////////////////
//      // ALUop = 1       /42:40
//      // ALUSrcA = 2     /16:15
//      // ALUSrcB = 3     /14:12
      STATE_OUTPUT_TABLE[STATE_ADDI_ADDIU_0] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_ADDI_ADDIU_0][42:40] = 3'd1;
      STATE_OUTPUT_TABLE[STATE_ADDI_ADDIU_0][16:15] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_ADDI_ADDIU_0][14:12] = 3'd3;
//      ///////////////  STATE_ADDI_ADDIU_0  ////////////////

//      ///////////////  STATE_ADDI_ADDIU_1  ////////////////
//      // ALUop = 1       /42:40
//      // ALUSrcA = 2     /16:15
//      // ALUSrcB = 3     /14:12
//      // ALUoutCtrl = 1  /1
      STATE_OUTPUT_TABLE[STATE_ADDI_ADDIU_1] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_ADDI_ADDIU_1][42:40] = 3'd1;
      STATE_OUTPUT_TABLE[STATE_ADDI_ADDIU_1][16:15] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_ADDI_ADDIU_1][14:12] = 3'd3;
      STATE_OUTPUT_TABLE[STATE_ADDI_ADDIU_1][1] = 1;
//      ///////////////  STATE_ADDI_ADDIU_1  ////////////////

//      ///////////////  STATE_ADDI_ADDIU_ENDING  ////////////////
//      // RegDst = 0       /21:20   
//      // MemToReg = 6     /19:17
//      // RegWrite = 1     /34
      STATE_OUTPUT_TABLE[STATE_ADDI_ADDIU_ENDING] = 43'd0;
       
      STATE_OUTPUT_TABLE[STATE_ADDI_ADDIU_ENDING][21:20] = 2'd0;
      STATE_OUTPUT_TABLE[STATE_ADDI_ADDIU_ENDING][19:17] = 3'd6;
      STATE_OUTPUT_TABLE[STATE_ADDI_ADDIU_ENDING][34] = 1;
//      ///////////////  STATE_ADDI_ADDIU_ENDING  ////////////////


//     //------------------  FIM DA INICIALIZAÇÃO DA TABELA DE OUTPUTS  ------------------//
end

always @(posedge clk) begin
    if (reset_in == 1'b1) begin
        if (STATE != STATE_RESET) begin
            STATE = STATE_RESET;
            
            
            // SET COUNTER FOR NEXT OPERATION
            COUNTER = 0;
        end
        
        else begin
            STATE = STATE_FETCH0;
            
            
            // SET COUNTER FOR NEXT OPERATION
            COUNTER = 0;
        end
    end 

    else begin
        case (STATE)
            //------        ESTADOS "COMUNS"      --------//
            STATE_RESET: begin
                STATE = STATE_FETCH0;
            end

            STATE_FETCH0: begin
                if (COUNTER == 0 || COUNTER == 1) begin
                    STATE = STATE_FETCH0;
                    
                    // SET COUNTER FOR NEXT OPERATION
                    COUNTER = COUNTER + 1; 
                end
                else if (COUNTER == 2) begin
                    STATE = STATE_FETCH1;
                    
                    // SET COUNTER FOR NEXT OPERATION
                    COUNTER = 0;
                end
            end

            STATE_FETCH1: begin
                STATE = STATE_DECODE0;
                
                // SET COUNTER FOR NEXT OPERATION
                COUNTER = 0;
            end

            STATE_DECODE0: begin
                STATE = STATE_DECODE1;
                
                // SET COUNTER FOR NEXT OPERATION
                COUNTER = 0;
            end
            
            STATE_DECODE1: begin
                if (COUNTER == 0 || COUNTER == 1) begin
                    STATE = STATE_DECODE1;
                    
                    // SET COUNTER FOR NEXT OPERATION
                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 2) begin
                    COUNTER = 0;
                    
                    case (OPCODE)
                        R_instruction: begin
                            case (FUNCT)
                                ADD:
                                    STATE = STATE_ADD0;
                                default:
                                    STATE = STATE_FETCH0; // esse será dps o default para tratamento de exceções
                            endcase
                        end

                        ADDIU:
                            STATE = STATE_ADDI_ADDIU_0;
                        default:
                            STATE = STATE_FETCH0; // esse será dps o default para tratamento de exceções
                    endcase
                end
            end
            //------     FIM ESTADOS "COMUNS"     --------//

            //  ADD
            STATE_ADD0: begin
                STATE = STATE_ADD1;
                COUNTER = 0;
            end
            STATE_ADD1: begin
                STATE = STATE_ADD_AND_SUB_ENDING;
                COUNTER = 0;
            end
            
            //  ADD, AND, SUB ENDING STATE
            STATE_ADD_AND_SUB_ENDING: begin
                STATE = STATE_FETCH0;
                COUNTER = 0;
            end
            
            // ADDIU, - ADDI AINDA NÃO IMPLEMENTADO
            STATE_ADDI_ADDIU_0: begin
                STATE = STATE_ADDI_ADDIU_1; // ESTE ESTADO CONTARÁ COM UMA CHECAGEM DE OVERFLOW APENAS SE A INSTRUÇÃO EM QUESTÃO FOR O ADDI, MAS PRIMEIRO SERÁ IMPLEMENTADO O ADDIU
                COUNTER = 0;
            end
            STATE_ADDI_ADDIU_1: begin
                STATE = STATE_ADDI_ADDIU_ENDING;
                COUNTER = 0;
            end
            STATE_ADDI_ADDIU_ENDING: begin
                STATE = STATE_FETCH0;
                COUNTER = 0;
            end
            
            default: begin
                STATE = STATE_RESET;
                COUNTER = 0;
            end
        endcase
    end

end

endmodule