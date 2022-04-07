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
    parameter STATE_RESET1              =   7'd50;
    parameter STATE_FETCH0              =   7'd1;
    parameter STATE_FETCH1              =   7'd2;
    parameter STATE_DECODE0             =   7'd3;
    parameter STATE_DECODE1             =   7'd4;


    //  ADD
    parameter STATE_ADD0                =   7'd5;
    parameter STATE_ADD1                =   7'd6;

    // AND 
    parameter STATE_AND_0               = 7'd11;
    parameter STATE_AND_1               = 7'd12;

    // SUB 
    parameter STATE_SUB_0               = 7'd13;
    parameter STATE_SUB_1               = 7'd14;

    //  ADD, AND, SUB ENDING STATE
    parameter STATE_ADD_AND_SUB_ENDING  =   7'd7;
    


    // ADDI, ADDIU
    parameter STATE_ADDI_ADDIU_0        = 7'd8; // ESTE ESTADO CONTARÁ COM UMA CHECAGEM DE OVERFLOW APENAS SE A INSTRUÇÃO EM QUESTÃO FOR O ADDI, MAS PRIMEIRO SERÁ IMPLEMENTADO O ADDIU
    parameter STATE_ADDI_ADDIU_1        = 7'd9;
    parameter STATE_ADDI_ADDIU_ENDING   = 7'd10;


    // MFHI
    parameter STATE_MFHI                = 7'd15;

    // MFLO
    parameter STATE_MFLO                = 7'd16;



    // JR
    parameter STATE_JR                  = 7'd17;

    // BREAK
    parameter STATE_BREAK               = 7'd18;

    // BEQ/BNE
    parameter STATE_BEQ_BNE             = 7'd19;

    // BLE/BGT
    parameter STATE_BLE_BGT             = 7'd20;

    // JR, BREAK, BEQ/BNE, BLE/BGT ENDING STATE
    parameter STATE_JR_BREAK_BRANCH_ENDING = 7'd21;



    // SLL, SRA, SRL INITIAL STATE
    parameter STATE_SLL_SRA_SRL_INITIAL     = 7'd22;
    
    // SLL
    parameter STATE_SLL                     = 7'd23; 
    
    // SRA
    parameter STATE_SRA                     = 7'd24;
    
    // SRL
    parameter STATE_SRL                     = 7'd24;
    
    // SLLV, SRAV INITIAL STATE
    parameter STATE_SLLV_SRAV_INITIAL       = 7'd25;
    
    // SLLV
    parameter STATE_SLLV                    = 7'd26;
    
    // SRAV
    parameter STATE_SRAV                    = 7'd27;
    
    // SHIFT END STATE
    parameter STATE_SHIFT_END               = 7'd28;
    
    

    // SLT
    parameter STATE_SLT_0                   = 7'd29;
    parameter STATE_SLT_1                   = 7'd30;
    // SLTI
    parameter STATE_SLTI_0                  = 7'd31;
    parameter STATE_SLTI_1                  = 7'd32;

    // jump (J)
    parameter STATE_JUMP                    = 7'd33;

    // RTE
    parameter STATE_RTE                     = 7'd34;

    // STORES, LOADS and SLLM
    parameter STATE_LOAD_STORES_0           = 7'd35;
    parameter STATE_LOAD_STORES_1           = 7'd36;
    parameter STATE_LOAD_STORES_2           = 7'd37;
    parameter STATE_LOAD_STORES_3           = 7'd38;

    parameter STATE_SW                      = 7'd39;
    parameter STATE_SH                      = 7'd40;
    parameter STATE_SB                      = 7'd41;

    parameter STATE_LW                      = 7'd42;
    parameter STATE_LH                      = 7'd43;
    parameter STATE_LB                      = 7'd44;
 
    parameter STATE_STORES_ENDING           = 7'd45;

    parameter STATE_LOADS_ENDING             = 7'd46;

    parameter STATE_SLLM_0                  = 7'd47;
    parameter STATE_SLLM_1                  = 7'd48;
    parameter STATE_SLLM_ENDING             = 7'd49;

    // CUIDADOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO!!!! O ESTADO 7'd50 SERÁ O STATE_RESET1, QUE PRECISA SER ADICIONADO PARA CARREGAR O VALOR 227 NO REGISTRADOR 29  //

    // ADDM
    parameter STATE_ADDM0                   = 7'd51;
    parameter STATE_ADDM1                   = 7'd52;
    parameter STATE_ADDM2                   = 7'd53;
    parameter STATE_ADDM3                   = 7'd54;
    parameter STATE_ADDM4                   = 7'd55;


    // LUI
    parameter STATE_LUI                     = 7'd56;     

    // JAL
    parameter STATE_JAL_0                   = 7'd57;
    parameter STATE_JAL_1                   = 7'd58;
    parameter STATE_JAL_2                   = 7'd59;


    // TRATAMENTO DE EXCEÇÕES  
    parameter STATE_EXP_OVERFLOW            = 7'd60;
    parameter STATE_EXP_DIV0                = 7'd61;
    parameter STATE_EXP_OPCODE              = 7'd62;

    parameter STATE_EXP_END_0               = 7'd63;
    parameter STATE_EXP_END_1               = 7'd64;


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

//--------------------------------------------------  INICIALIZAÇÃO  -------------------------------------------//

initial begin

    STATE = STATE_ON;
    
    COUNTER = 0;
//     //---------------------------------  INICIALIZAÇÃO DA TABELA DE OUTPUTS  -------------------------------//

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

//     ///////////////   RESET1   /////////////
//     // RegWrite =1          /34
//     // RegDst = 3           /21:20
//     // MemToReg = 4         /19:17
//     // reset_out = 0        /0
     STATE_OUTPUT_TABLE[STATE_RESET1] = 43'd0;

     STATE_OUTPUT_TABLE[STATE_RESET1][34] = 1;        // RegWrite =1          /34
     STATE_OUTPUT_TABLE[STATE_RESET1][21:20] = 2'd3;   // RegDst = 3           /21:20
     STATE_OUTPUT_TABLE[STATE_RESET1][19:17] = 3'd4;   // MemToReg = 4         /19:17
     STATE_OUTPUT_TABLE[STATE_RESET1][0] = 0;         // reset_out = 0        /0
//     ///////////////   RESET1   /////////////

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


//      /////////////// STATE_AND_0  /////////////////////
//      // ALUSrcA = 2      /16:15
//      // ALUSrcB = 0      /14:12
//      // ALUop = 3        /42:40
      STATE_OUTPUT_TABLE[STATE_AND_0] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_AND_0][16:15] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_AND_0][42:40] = 3'd3;
//      /////////////// STATE_AND_0  /////////////////////

//      /////////////// STATE_AND_1  /////////////////////
//      // ALUSrcA = 2      /16:15
//      // ALUSrcB = 0      /14:12
//      // ALUop = 3        /42:40
//      // ALUoutCtrl = 1   /1
      STATE_OUTPUT_TABLE[STATE_AND_1] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_AND_1][16:15] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_AND_1][42:40] = 3'd3;
      STATE_OUTPUT_TABLE[STATE_AND_1][1] = 1;
//      /////////////// STATE_AND_1  /////////////////////


//      /////////////// STATE_SUB_0  /////////////////////
//      // ALUSrcA = 2      /16:15
//      // ALUSrcB = 0      /14:12
//      // ALUop = 2        /42:40
      STATE_OUTPUT_TABLE[STATE_SUB_0] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_SUB_0][16:15] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_SUB_0][42:40] = 3'd2;
//      /////////////// STATE_SUB_0  /////////////////////

//      /////////////// STATE_SUB_1  /////////////////////
//      // ALUSrcA = 2      /16:15
//      // ALUSrcB = 0      /14:12
//      // ALUop = 2        /42:40
//      // ALUoutCtrl = 1   /1
      STATE_OUTPUT_TABLE[STATE_SUB_1] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_SUB_1][16:15] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_SUB_1][42:40] = 3'd2;
      STATE_OUTPUT_TABLE[STATE_SUB_1][1] = 1;
//      /////////////// STATE_SUB_1  /////////////////////
    

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



//      ///////////////  STATE_MFHI  ////////////////
//      // RegDst = 1       /21:20   
//      // MemToReg = 2     /19:17
//      // RegWrite = 1     /34
      STATE_OUTPUT_TABLE[STATE_MFHI] = 43'd0;
       
      STATE_OUTPUT_TABLE[STATE_MFHI][21:20] = 2'd1;
      STATE_OUTPUT_TABLE[STATE_MFHI][19:17] = 3'd2;
      STATE_OUTPUT_TABLE[STATE_MFHI][34] = 1;
//      ///////////////  STATE_MFHI  ////////////////

//      ///////////////  STATE_MFLO  ////////////////
//      // RegDst = 1       /21:20   
//      // MemToReg = 1     /19:17
//      // RegWrite = 1     /34
      STATE_OUTPUT_TABLE[STATE_MFLO] = 43'd0;
       
      STATE_OUTPUT_TABLE[STATE_MFLO][21:20] = 2'd1;
      STATE_OUTPUT_TABLE[STATE_MFLO][19:17] = 3'd1;
      STATE_OUTPUT_TABLE[STATE_MFLO][34] = 1;
//      ///////////////  STATE_MFLO  ////////////////


//      ///////////////  STATE_JR  ////////////////
//      // ALUSrcA = 2      /16:15
//      // PCSrc = 2        /11:9      
//      // ALUop =  0       /42:40
//      // ALUoutCtrl = 1   /1      
      STATE_OUTPUT_TABLE[STATE_JR] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_JR][16:15] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_JR][11:9] = 3'd2;
      STATE_OUTPUT_TABLE[STATE_JR][42:40] = 3'd0;
      STATE_OUTPUT_TABLE[STATE_JR][1] = 1;
//      ///////////////  STATE_JR  ////////////////

//      ///////////////  STATE_BEQ_BNE  ////////////////
//      // ALUSrcA = 2      /16:15
//      // ALUSrcB = 0      /14:12
//      // ALUop =  2       /42:40
//      // PCSrc = 4        /11:9           
      STATE_OUTPUT_TABLE[STATE_BEQ_BNE] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_BEQ_BNE][16:15] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_BEQ_BNE][14:12] = 3'd0;
      STATE_OUTPUT_TABLE[STATE_BEQ_BNE][42:40] = 3'd2;
      STATE_OUTPUT_TABLE[STATE_BEQ_BNE][11:9] = 3'd4;
//      ///////////////  STATE_BEQ_BNE  ////////////////

//      ///////////////  STATE_BLE_BGT  ////////////////
//      // ALUSrcA = 2      /16:15
//      // ALUSrcB = 0      /14:12
//      // ALUop =  7       /42:40
//      // PCSrc = 4        /11:9           
      STATE_OUTPUT_TABLE[STATE_BLE_BGT] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_BLE_BGT][16:15] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_BLE_BGT][14:12] = 2'd0;
      STATE_OUTPUT_TABLE[STATE_BLE_BGT][42:40] = 3'd7;
      STATE_OUTPUT_TABLE[STATE_BLE_BGT][11:9] = 3'd4;
//      ///////////////  STATE_BLE_BGT  ////////////////

//      ///////////////  STATE_BREAK  ////////////////
//      // ALUSrcA = 0      /16:15
//      // ALUSrcB = 1      /14:12
//      // ALUop =  2       /42:40
//      // PCSrc = 2        /11:9 
//      // ALUoutCtrl = 1   /1           
      STATE_OUTPUT_TABLE[STATE_BREAK] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_BREAK][16:15] = 2'd0;
      STATE_OUTPUT_TABLE[STATE_BREAK][14:12] = 3'd1;
      STATE_OUTPUT_TABLE[STATE_BREAK][42:40] = 3'd2;
      STATE_OUTPUT_TABLE[STATE_BREAK][11:9] = 3'd2;
      STATE_OUTPUT_TABLE[STATE_BREAK][1] = 1;      
//      ///////////////  STATE_BREAK  ////////////////

//      ///////////////  STATE_JR_BREAK_BRANCH_ENDING  ////////////////
//      // PCwrite = 1      /8
      STATE_OUTPUT_TABLE[STATE_JR_BREAK_BRANCH_ENDING] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_JR_BREAK_BRANCH_ENDING][8] = 1;
//      ///////////////  STATE_JR_BREAK_BRANCH_ENDING  ////////////////



//      ///////////////  STATE_SLL_SRA_SRL_INITIAL  ////////////////
//      // ShiftRegCtrl = 1     /24
//      // ShiftAmmCtrl =2      /23:22
//      // shift = 1            /37:35
      STATE_OUTPUT_TABLE[STATE_SLL_SRA_SRL_INITIAL] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_SLL_SRA_SRL_INITIAL][24] = 1;
      STATE_OUTPUT_TABLE[STATE_SLL_SRA_SRL_INITIAL][23:22] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_SLL_SRA_SRL_INITIAL][37:35] = 3'd1;
//      ///////////////  STATE_SLL_SRA_SRL_INITIAL  ////////////////

//      ///////////////  STATE_SLL  ////////////////
//      // ShiftRegCtrl = 1     /24
//      // ShiftAmmCtrl =2      /23:22
//      // shift = 2            /37:35
      STATE_OUTPUT_TABLE[STATE_SLL] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_SLL][24] = 1;
      STATE_OUTPUT_TABLE[STATE_SLL][23:22] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_SLL][37:35] = 3'd2;
//      ///////////////  STATE_SLL  ////////////////

//      ///////////////  STATE_SRA  ////////////////
//      // ShiftRegCtrl = 1     /24
//      // ShiftAmmCtrl =2      /23:22
//      // shift = 4            /37:35
      STATE_OUTPUT_TABLE[STATE_SRA] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_SRA][24] = 1;
      STATE_OUTPUT_TABLE[STATE_SRA][23:22] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_SRA][37:35] = 3'd4;
//      ///////////////  STATE_SRA  ////////////////

//      ///////////////  STATE_SRL  ////////////////
//      // ShiftRegCtrl = 1     /24
//      // ShiftAmmCtrl =2      /23:22
//      // shift = 3            /37:35
      STATE_OUTPUT_TABLE[STATE_SRL] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_SRL][24] = 1;
      STATE_OUTPUT_TABLE[STATE_SRL][23:22] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_SRL][37:35] = 3'd3;
//      ///////////////  STATE_SRL  ////////////////

//      ///////////////  STATE_SLLV_SRAV_INITIAL  ////////////////
//      // ShiftRegCtrl = 0     /24
//      // ShiftAmmCtrl =0      /23:22
//      // shift = 1            /37:35
      STATE_OUTPUT_TABLE[STATE_SLLV_SRAV_INITIAL] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_SLLV_SRAV_INITIAL][24] = 0;
      STATE_OUTPUT_TABLE[STATE_SLLV_SRAV_INITIAL][23:22] = 2'd0;
      STATE_OUTPUT_TABLE[STATE_SLLV_SRAV_INITIAL][37:35] = 3'd1;
//      ///////////////  STATE_SLLV_SRAV_INITIAL  ////////////////

//      ///////////////  STATE_SRAV  ////////////////
//      // ShiftRegCtrl = 0     /24
//      // ShiftAmmCtrl = 0      /23:22
//      // shift = 4            /37:35
      STATE_OUTPUT_TABLE[STATE_SRAV] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_SRAV][24] = 0;
      STATE_OUTPUT_TABLE[STATE_SRAV][23:22] = 2'd0;
      STATE_OUTPUT_TABLE[STATE_SRAV][37:35] = 3'd4;
//      ///////////////  STATE_SRAV  ////////////////

//      ///////////////  STATE_SLLV  ////////////////
//      // ShiftRegCtrl = 0     /24
//      // ShiftAmmCtrl = 0      /23:22
//      // shift = 2            /37:35
      STATE_OUTPUT_TABLE[STATE_SLLV] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_SLLV][24] = 0;
      STATE_OUTPUT_TABLE[STATE_SLLV][23:22] = 2'd0;
      STATE_OUTPUT_TABLE[STATE_SLLV][37:35] = 3'd2;
//      ///////////////  STATE_SLLV  ////////////////

//      ///////////////  STATE_SHIFT_END  ////////////////
//      // RegDst = 1       /21:20   
//      // MemToReg = 5     /19:17
//      // RegWrite = 1     /34
      STATE_OUTPUT_TABLE[STATE_SHIFT_END] = 43'd0;
       
      STATE_OUTPUT_TABLE[STATE_SHIFT_END][21:20] = 2'd1;
      STATE_OUTPUT_TABLE[STATE_SHIFT_END][19:17] = 3'd5;
      STATE_OUTPUT_TABLE[STATE_SHIFT_END][34] = 1;
//      ///////////////  STATE_SHIFT_END  ////////////////



//      ///////////////  STATE_SLT_0  ////////////////
//      // ALUSrcA = 2      /16:15
//      // ALUSrcB = 0      /14:12
//      // ALUop =  7       /42:40
      STATE_OUTPUT_TABLE[STATE_SLT_0] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_SLT_0][16:15] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_SLT_0][14:12] = 3'd0;
      STATE_OUTPUT_TABLE[STATE_SLT_0][42:40] = 3'd7;
//      ///////////////  STATE_SLT_0  ////////////////

//      ///////////////  STATE_SLT_1  ////////////////
//      // RegDst = 1       /21:20   
//      // MemToReg = 7     /19:17
//      // RegWrite = 1     /34
      STATE_OUTPUT_TABLE[STATE_SLT_1] = 43'd0;
       
      STATE_OUTPUT_TABLE[STATE_SLT_1][21:20] = 2'd1;
      STATE_OUTPUT_TABLE[STATE_SLT_1][19:17] = 3'd7;
      STATE_OUTPUT_TABLE[STATE_SLT_1][34] = 1;
//      ///////////////  STATE_SLT_1  ////////////////


//      ///////////////  STATE_SLTI_0  ////////////////
//      // ALUSrcA = 2      /16:15
//      // ALUSrcB = 3      /14:12
//      // ALUop =  7       /42:40
      STATE_OUTPUT_TABLE[STATE_SLTI_0] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_SLTI_0][16:15] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_SLTI_0][14:12] = 3'd3;
      STATE_OUTPUT_TABLE[STATE_SLTI_0][42:40] = 3'd7;
//      ///////////////  STATE_SLTI_0  ////////////////

//      ///////////////  STATE_SLTI_1  ////////////////
//      // RegDst = 0       /21:20   
//      // MemToReg = 7     /19:17
//      // RegWrite = 1     /34
      STATE_OUTPUT_TABLE[STATE_SLTI_1] = 43'd0;
       
      STATE_OUTPUT_TABLE[STATE_SLTI_1][21:20] = 2'd0;
      STATE_OUTPUT_TABLE[STATE_SLTI_1][19:17] = 3'd7;
      STATE_OUTPUT_TABLE[STATE_SLTI_1][34] = 1;
//      ///////////////  STATE_SLTI_1  ////////////////


//      ///////////////  STATE_J  ////////////////
//      // PCSrc = 0           /11:9
//      // PCwrite = 1         /8
      STATE_OUTPUT_TABLE[STATE_JUMP] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_JUMP][11:9] = 3'd0;
      STATE_OUTPUT_TABLE[STATE_JUMP][8] = 1;
//      ///////////////  STATE_J  ////////////////

//      ///////////////  STATE_RTE  ////////////////
//      // PCSrc = 3           /11:9
//      // PCwrite = 1         /8
      STATE_OUTPUT_TABLE[STATE_RTE] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_RTE][11:9] = 3'd3;
      STATE_OUTPUT_TABLE[STATE_RTE][8] = 1;
//      ///////////////  STATE_RTE  ////////////////




//      ///////////////  STATE_LOAD_STORES_0  ////////////////
//      // ALUSrcA = 2      /16:15
//      // ALUSrcB = 3      /14:12
//      // ALUop =  1       /42:40         
      STATE_OUTPUT_TABLE[STATE_LOAD_STORES_0] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_LOAD_STORES_0][16:15] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_LOAD_STORES_0][14:12] = 3'd3;
      STATE_OUTPUT_TABLE[STATE_LOAD_STORES_0][42:40] = 3'd1;
//      ///////////////  STATE_LOAD_STORES_0  ////////////////

//      ///////////////  STATE_LOAD_STORES_1  ////////////////
//      // ALUSrcA = 2      /16:15
//      // ALUSrcB = 3      /14:12
//      // ALUop =  1       /42:40   
//      // ALUoutCtrl = 1   /1      
      STATE_OUTPUT_TABLE[STATE_LOAD_STORES_1] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_LOAD_STORES_1][16:15] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_LOAD_STORES_1][14:12] = 3'd3;
      STATE_OUTPUT_TABLE[STATE_LOAD_STORES_1][42:40] = 3'd1;
      STATE_OUTPUT_TABLE[STATE_LOAD_STORES_1][1] = 1;
//      ///////////////  STATE_LOAD_STORES_1  ////////////////

//      ///////////////  STATE_LOAD_STORES_2  ////////////////
//      // iorD = 4         /27:25
//      // MEMwrite = 0
      STATE_OUTPUT_TABLE[STATE_LOAD_STORES_2] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_LOAD_STORES_2][27:25] = 3'd4;
//      ///////////////  STATE_LOAD_STORES_2  ////////////////

//      ///////////////  STATE_LOAD_STORES_3  ////////////////
//      // MDRwrite = 1    /6
      STATE_OUTPUT_TABLE[STATE_LOAD_STORES_3] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_LOAD_STORES_3][6] = 1;
//      ///////////////  STATE_LOAD_STORES_3  ////////////////



//      ///////////////  STATE_SW  ////////////////
//      // SMcontrol = 0    /33:32
      STATE_OUTPUT_TABLE[STATE_SW] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_SW][33:32] = 2'd0;
//      ///////////////  STATE_SW  ////////////////

//      ///////////////  STATE_SH  ////////////////
//      // SMcontrol = 1    /33:32
      STATE_OUTPUT_TABLE[STATE_SH] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_SH][33:32] = 2'd1;
//      ///////////////  STATE_SH  ////////////////

//      ///////////////  STATE_SB  ////////////////
//      // SMcontrol = 2    /33:32
      STATE_OUTPUT_TABLE[STATE_SB] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_SB][33:32] = 2'd2;
//      ///////////////  STATE_SB  ////////////////


//      ///////////////  STATE_LW  ////////////////
//      // LMcontrol = 0    /31:30
      STATE_OUTPUT_TABLE[STATE_LW] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_LW][31:30] = 2'd0;
//      ///////////////  STATE_LW  ////////////////

//      ///////////////  STATE_LH  ////////////////
//      // LMcontrol = 1    /31:30
      STATE_OUTPUT_TABLE[STATE_LH] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_LH][31:30] = 2'd1;
//      ///////////////  STATE_LH  ////////////////

//      ///////////////  STATE_LB  ////////////////
//      // LMcontrol = 2    /31:30
      STATE_OUTPUT_TABLE[STATE_LB] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_LB][31:30] = 2'd2;
//      ///////////////  STATE_LB  ////////////////


//      ///////////////  STATE_STORES_ENDING  ////////////////
//      // iorD = 4         /27:25
//      // MEMwrite = 1     /38
      STATE_OUTPUT_TABLE[STATE_STORES_ENDING] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_STORES_ENDING][27:25] = 3'd4;
      STATE_OUTPUT_TABLE[STATE_STORES_ENDING][38] = 1;
//      ///////////////  STATE_STORES_ENDING  ////////////////

//      ///////////////  STATE_LOADS_ENDING  ////////////////
//      // RegDst = 0       /21:20   
//      // MemToReg = 0     /19:17
//      // RegWrite = 1     /34
      STATE_OUTPUT_TABLE[STATE_LOADS_ENDING] = 43'd0;
       
      STATE_OUTPUT_TABLE[STATE_LOADS_ENDING][21:20] = 2'd0;
      STATE_OUTPUT_TABLE[STATE_LOADS_ENDING][19:17] = 3'd0;
      STATE_OUTPUT_TABLE[STATE_LOADS_ENDING][34] = 1;
//      ///////////////  STATE_LOADS_ENDING  ////////////////


//      ///////////////  STATE_SLLM_0  ////////////////
//      // ShiftRegCtrl = 1     /24
//      // ShiftAmmCtrl = 1      /23:22
//      // shift = 1            /37:35
      STATE_OUTPUT_TABLE[STATE_SLLV] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_SLLV][24] = 1;
      STATE_OUTPUT_TABLE[STATE_SLLV][23:22] = 2'd1;
      STATE_OUTPUT_TABLE[STATE_SLLV][37:35] = 3'd1;
//      ///////////////  STATE_SLLM_0  ////////////////

//      ///////////////  STATE_SLLM_1  ////////////////
//      // ShiftRegCtrl = 1     /24
//      // ShiftAmmCtrl = 1      /23:22
//      // shift = 2            /37:35
      STATE_OUTPUT_TABLE[STATE_SLLV] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_SLLV][24] = 1;
      STATE_OUTPUT_TABLE[STATE_SLLV][23:22] = 2'd1;
      STATE_OUTPUT_TABLE[STATE_SLLV][37:35] = 3'd2;
//      ///////////////  STATE_SLLM_1  ////////////////

//      ///////////////  STATE_SLLM_ENDING  ////////////////
//      // RegDst = 0       /21:20   
//      // MemToReg = 5     /19:17
//      // RegWrite = 1     /34
      STATE_OUTPUT_TABLE[STATE_SLLM_ENDING] = 43'd0;
       
      STATE_OUTPUT_TABLE[STATE_SLLM_ENDING][21:20] = 2'd0;
      STATE_OUTPUT_TABLE[STATE_SLLM_ENDING][19:17] = 3'd5;
      STATE_OUTPUT_TABLE[STATE_SLLM_ENDING][34] = 1;
//      ///////////////  STATE_SLLM_ENDING  ////////////////



//      ///////////////  STATE_ADDM0  ////////////////
//      // IorD = 3         /27:25
        STATE_OUTPUT_TABLE[STATE_ADDM0] = 43'd0;

        STATE_OUTPUT_TABLE[STATE_ADDM0][27:25] = 3'd3;
//      ///////////////  STATE_ADDM0  ////////////////

//      ///////////////  STATE_ADDM1  ////////////////
//      // MDRwrite = 1     /6
        STATE_OUTPUT_TABLE[STATE_ADDM1] = 43'd0;
        
        STATE_OUTPUT_TABLE[STATE_ADDM1][6] = 1;
//      ///////////////  STATE_ADDM1  ////////////////

//      ///////////////  STATE_ADDM2  ////////////////
//      // ALUop = 1        /42:40
//      // IorD = 2         /27:25
//      // ALUsrcA = 1      /16:15
//      // ALUsrcB = 2      /14:12
        STATE_OUTPUT_TABLE[STATE_ADDM2] = 43'd0;
        
        STATE_OUTPUT_TABLE[STATE_ADDM2][42:40] = 3'd1;
        STATE_OUTPUT_TABLE[STATE_ADDM2][27:25] = 3'd2;
        STATE_OUTPUT_TABLE[STATE_ADDM2][16:15] = 2'd1;
        STATE_OUTPUT_TABLE[STATE_ADDM2][14:12] = 3'd2;
//      ///////////////  STATE_ADDM2  ////////////////

//      ///////////////  STATE_ADDM3  ////////////////
//      // ALUop = 1        /42:40
//      // ALUsrcA = 1      /16:15
//      // ALUsrcB = 2      /14:12
//      // ALUoutCtrl = 1   /1
        STATE_OUTPUT_TABLE[STATE_ADDM3] = 43'd0;
        
        STATE_OUTPUT_TABLE[STATE_ADDM3][42:40] = 3'd1;
        STATE_OUTPUT_TABLE[STATE_ADDM3][16:15] = 2'd1;
        STATE_OUTPUT_TABLE[STATE_ADDM3][14:12] = 3'd2;
        STATE_OUTPUT_TABLE[STATE_ADDM3][1]     = 1;
//      ///////////////  STATE_ADDM3  ////////////////

//      ///////////////  STATE_ADDM4  ////////////////
//      // RegWrite = 1      /34
//      // RegDst = 1        /21:20
//      // MemToReg = 6      /19:17
        STATE_OUTPUT_TABLE[STATE_ADDM4] = 43'd0;
        
        STATE_OUTPUT_TABLE[STATE_ADDM4][34] = 1;
        STATE_OUTPUT_TABLE[STATE_ADDM4][21:20] = 2'd1;
        STATE_OUTPUT_TABLE[STATE_ADDM4][19:17] = 3'd6;
//      ///////////////  STATE_ADDM4  ////////////////



//      ///////////////  STATE_LUI  ////////////////
//      // RegDst = 0       /21:20   
//      // MemToReg = 3     /19:17
//      // RegWrite = 1     /34
      STATE_OUTPUT_TABLE[STATE_LUI] = 43'd0;
       
      STATE_OUTPUT_TABLE[STATE_LUI][21:20] = 2'd0;
      STATE_OUTPUT_TABLE[STATE_LUI][19:17] = 3'd3;
      STATE_OUTPUT_TABLE[STATE_LUI][34] = 1;
//      ///////////////  STATE_LUI  ////////////////



//      ///////////////  STATE_JAL_0  ////////////////
//      // ALUSrcA = 0      /16:15
//      // PCSrc = 2        /11:9      
//      // ALUop =  0       /42:40     
      STATE_OUTPUT_TABLE[STATE_JAL_0] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_JAL_0][16:15] = 2'd0;
      STATE_OUTPUT_TABLE[STATE_JAL_0][11:9] = 3'd2;
      STATE_OUTPUT_TABLE[STATE_JAL_0][42:40] = 3'd0;
//      ///////////////  STATE_JAL_0  ////////////////

//      ///////////////  STATE_JAL_1  ////////////////
//      // ALUSrcA = 0      /16:15
//      // PCSrc = 2        /11:9      
//      // ALUop =  0       /42:40    
//      // ALUoutCtrl = 1   /1 
//      // RegDst = 2       /21:20   
//      // MemToReg = 6     /19:17
//      // PCwrite = 1      /8
      STATE_OUTPUT_TABLE[STATE_JAL_1] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_JAL_1][16:15] = 2'd0;
      STATE_OUTPUT_TABLE[STATE_JAL_1][11:9] = 3'd2;
      STATE_OUTPUT_TABLE[STATE_JAL_1][42:40] = 3'd0;
      STATE_OUTPUT_TABLE[STATE_JAL_1][1]     = 1;
      STATE_OUTPUT_TABLE[STATE_JAL_1][21:20] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_JAL_1][19:17] = 3'd6;
      STATE_OUTPUT_TABLE[STATE_JAL_1][8] = 1;
//      ///////////////  STATE_JAL_1  ////////////////

//      ///////////////  STATE_JAL_2  //////////////// 
//      // RegDst = 2       /21:20   
//      // MemToReg = 6     /19:17
//      // RegWrite = 1     /34
      STATE_OUTPUT_TABLE[STATE_JAL_2] = 43'd0;
      
      STATE_OUTPUT_TABLE[STATE_JAL_1][21:20] = 2'd2;
      STATE_OUTPUT_TABLE[STATE_JAL_1][19:17] = 3'd6;
      STATE_OUTPUT_TABLE[STATE_JAL_2][34] = 1;
//      ///////////////  STATE_JAL_2  ////////////////



//      ///////////////  STATE_EXP_OVERFLOW  ////////////////
//      // MEMwrite = 0             /38
//      // ALUSrcA = 0              /16:15
//      // EXCPControl = 1          /29:28
//      // IorD = 5                 /27:25
//      // ALUop = 0                /42:40 
//      // EPCcontrol = 1           /2
        STATE_OUTPUT_TABLE[STATE_EXP_OVERFLOW] = 43'd0;        

        STATE_OUTPUT_TABLE[STATE_EXP_OVERFLOW][29:28] = 2'd1;
        STATE_OUTPUT_TABLE[STATE_EXP_OVERFLOW][27:25] = 3'd5;
        STATE_OUTPUT_TABLE[STATE_EXP_OVERFLOW][2] = 1;
//      ///////////////  STATE_EXP_OVERFLOW  //////////////// 

//      ///////////////  STATE_EXP_DIV0  //////////////// 
//      // MEMwrite = 0             /38
//      // ALUSrcA = 0              /16:15
//      // EXCPControl = 2          /29:28
//      // IorD = 5                 /27:25
//      // ALUop = 0                /42:40 
//      // EPCcontrol = 1           /2
        STATE_OUTPUT_TABLE[STATE_EXP_DIV0] = 43'd0;        

        STATE_OUTPUT_TABLE[STATE_EXP_DIV0][29:28] = 2'd2;
        STATE_OUTPUT_TABLE[STATE_EXP_DIV0][27:25] = 3'd5;
        STATE_OUTPUT_TABLE[STATE_EXP_DIV0][2] = 1;
//      ///////////////  STATE_EXP_DIV0  ////////////////

//      ///////////////  STATE_EXP_OPCODE  //////////////// 
//      // MEMwrite = 0             /38
//      // ALUSrcA = 0              /16:15
//      // EXCPControl = 0          /29:28
//      // IorD = 5                 /27:25
//      // ALUop = 0                /42:40 
//      // EPCcontrol = 1           /2
        STATE_OUTPUT_TABLE[STATE_EXP_OPCODE] = 43'd0;        

        STATE_OUTPUT_TABLE[STATE_EXP_OPCODE][29:28] = 2'd0;
        STATE_OUTPUT_TABLE[STATE_EXP_OPCODE][27:25] = 3'd5;
        STATE_OUTPUT_TABLE[STATE_EXP_OPCODE][2] = 1;
//      ///////////////  STATE_EXP_OPCODE  ////////////////

//      ///////////////  STATE_EXP_END_0  //////////////// 
//      // MDRwrite = 1    /6
      STATE_OUTPUT_TABLE[STATE_EXP_END_0] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_EXP_END_0][6] = 1;
//      ///////////////  STATE_EXP_END_0  ////////////////

//      ///////////////  STATE_EXP_END_1  //////////////// 
//      // LMcontrol = 3       /31:30
//      // PCSrc = 1           /11:9
//      // PCwrite = 1         /8
      STATE_OUTPUT_TABLE[STATE_EXP_END_1] = 43'd0;

      STATE_OUTPUT_TABLE[STATE_EXP_END_1][31:30] = 2'd3;
      STATE_OUTPUT_TABLE[STATE_JUMP][11:9] = 3'd1;
      STATE_OUTPUT_TABLE[STATE_JUMP][8] = 1;
//      ///////////////  STATE_EXP_END_1  ////////////////

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
                STATE = STATE_RESET1;
            end

            STATE_RESET1: begin
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
                               
                                AND:
                                    STATE = STATE_AND_0;
                               
                                SUB:
                                    STATE = STATE_SUB_0;

                                MFHI:
                                    STATE = STATE_MFHI;

                                MFLO:
                                    STATE = STATE_MFLO;
                                
                                JR:
                                    STATE = STATE_JR;
                                
                                BREAK:
                                    STATE = STATE_BREAK;
                                
                                SLL:
                                    STATE = STATE_SLL_SRA_SRL_INITIAL;
                               
                                SRA:
                                    STATE = STATE_SLL_SRA_SRL_INITIAL;
                              
                                SRL:
                                    STATE = STATE_SLL_SRA_SRL_INITIAL;
                               
                                SLLV:
                                    STATE = STATE_SLLV_SRAV_INITIAL;

                                SRAV:
                                    STATE = STATE_SLLV_SRAV_INITIAL;

                                SLT: 
                                    STATE = STATE_SLT_0;
                                
                                RTE: 
                                    STATE = STATE_RTE;

                                ADDM:
                                    STATE = STATE_ADDM0;

                                default:
                                    STATE = STATE_EXP_OPCODE; // tratamento de exceções de OPCODE INEXISTENTE 
                            endcase
                        end

                        ADDI:
                            STATE = STATE_ADDI_ADDIU_0;

                        ADDIU:
                            STATE = STATE_ADDI_ADDIU_0;

                        BEQ:
                            STATE = STATE_BEQ_BNE;
                        BNE:
                            STATE = STATE_BEQ_BNE;
                        BLE:
                            STATE = STATE_BLE_BGT;
                        BGT:
                            STATE = STATE_BLE_BGT;

                        SLTI: 
                            STATE = STATE_SLTI_0;
                        
                        JUMP:
                            STATE = STATE_JUMP;


                        SW: 
                            STATE = STATE_LOAD_STORES_0;
                        SH:
                            STATE = STATE_LOAD_STORES_0;
                        SB:
                            STATE = STATE_LOAD_STORES_0;

                        LW:
                            STATE = STATE_LOAD_STORES_0;
                        LH:
                            STATE = STATE_LOAD_STORES_0;
                        LB:
                            STATE = STATE_LOAD_STORES_0;

                        SLLM:
                            STATE = STATE_LOAD_STORES_0;

                        LUI:
                            STATE = STATE_LUI;

                        JAL:
                            STATE = STATE_JAL_0;

                        default:
                            STATE = STATE_EXP_OPCODE; // tratamento de exceções de OPCODE INEXISTENTE
                    endcase
                end
            end
            //------     FIM ESTADOS "COMUNS"     --------//

            //  ADD
            STATE_ADD0: begin
                if (O == 1) begin
                    STATE = STATE_EXP_OVERFLOW;
                end else begin
                    STATE = STATE_ADD1;
                    COUNTER = 0;
                end
            end
            STATE_ADD1: begin
                STATE = STATE_ADD_AND_SUB_ENDING;
                COUNTER = 0;
            end

            //  AND
            STATE_AND_0: begin
                STATE = STATE_AND_1;
                COUNTER = 0;
            end
            STATE_AND_1: begin
                STATE = STATE_ADD_AND_SUB_ENDING;
                COUNTER = 0;
            end

            //  SUB
            STATE_SUB_0: begin
                if (O == 1) begin
                    STATE = STATE_EXP_OVERFLOW;
                end else begin
                    STATE = STATE_SUB_1;
                    COUNTER = 0;
                end
            end
            STATE_SUB_1: begin
                STATE = STATE_ADD_AND_SUB_ENDING;
                COUNTER = 0;
            end
            
            //  ADD, AND, SUB ENDING STATE
            STATE_ADD_AND_SUB_ENDING: begin
                STATE = STATE_FETCH0;
                COUNTER = 0;
            end
            
            // ADDIU, ADDI
            STATE_ADDI_ADDIU_0: begin
                if (OPCODE == ADDIU && O == 1) begin
                    STATE = STATE_EXP_OVERFLOW;
                end else begin
                    STATE = STATE_ADDI_ADDIU_1; // ESTE ESTADO CONTARÁ COM UMA CHECAGEM DE OVERFLOW APENAS SE A INSTRUÇÃO EM QUESTÃO FOR O ADDI, MAS PRIMEIRO SERÁ IMPLEMENTADO O ADDIU
                    COUNTER = 0;
                end
            end
            STATE_ADDI_ADDIU_1: begin
                STATE = STATE_ADDI_ADDIU_ENDING;
                COUNTER = 0;
            end
            STATE_ADDI_ADDIU_ENDING: begin
                STATE = STATE_FETCH0;
                COUNTER = 0;
            end

            //  MFHI
            STATE_MFHI: begin
                STATE = STATE_FETCH0;
                COUNTER = 0;
            end

            // FMLO
            STATE_MFLO: begin
                STATE = STATE_FETCH0;
                COUNTER = 0;
            end
            
            //  JR
            STATE_JR: begin
                if (COUNTER == 0) begin
                    COUNTER = COUNTER + 1;
                end else begin
                    STATE = STATE_JR_BREAK_BRANCH_ENDING;
                    COUNTER = 0;
                end    
            end
            
            // BREAK
            STATE_BREAK: begin
                if (COUNTER == 0)
                    COUNTER = COUNTER + 1;
                end else begin
                    STATE = STATE_JR_BREAK_BRANCH_ENDING;
                    COUNTER = 0;
                end
            end
            
            // BEQ/BNE
            STATE_BEQ_BNE: begin
                if (OPCODE == BEQ && ZERO == 1) begin
                    STATE = STATE_JR_BREAK_BRANCH_ENDING;
                    COUNTER = 0; 
                end
                else if (OPCODE == BNE && ZERO == 0) begin
                    STATE = STATE_JR_BREAK_BRANCH_ENDING;
                    COUNTER = 0;
                end
                else begin
                    STATE = STATE_FETCH0;
                end
            end

            // BLE/BGT
            STATE_BLE_BGT: begin
                if (OPCODE == BGT && GT == 1) begin
                    STATE = STATE_JR_BREAK_BRANCH_ENDING;
                    COUNTER = 0; 
                end
                else if (OPCODE == BLE && GT == 0) begin
                    STATE = STATE_JR_BREAK_BRANCH_ENDING;
                    COUNTER = 0;
                end
                else begin
                    STATE = STATE_FETCH0;
                    COUNTER = 0;
                end
            end

            // JR, BREAK, BRANCHES ENDING STATE
            STATE_JR_BREAK_BRANCH_ENDING: begin
                STATE = STATE_FETCH0;
                COUNTER = 0;
            end

            
            // SLL, SRA, SRL INITIAL STATE
            STATE_SLL_SRA_SRL_INITIAL: begin
                if (FUNCT == SLL) begin
                    STATE = STATE_SLL;
                    COUNTER = 0;
                end
                else if (FUNCT == SRA) begin
                    STATE = STATE_SRA;
                    COUNTER = 0;
                end 
                else if (FUNCT == SRL) begin
                    STATE = STATE_SRL;
                    COUNTER = 0;
                end 
            end

            //  SLL
            STATE_SLL: begin
                STATE = STATE_SHIFT_END;
                COUNTER = 0;
            end
            
            //  SRA
            STATE_SRA: begin
                STATE = STATE_SHIFT_END;
                COUNTER = 0;
            end
           
            //  SRL
            STATE_SRL: begin
                STATE = STATE_SHIFT_END;
                COUNTER = 0;
            end
            

            // SLLV, SRAV INITIAL STATE
            STATE_SLLV_SRAV_INITIAL: begin
                if (FUNCT == SLLV) begin
                    STATE = STATE_SLLV;
                    COUNTER = 0;
                end
                else if (FUNCT == SRAV) begin
                    STATE = STATE_SRAV;
                    COUNTER = 0;
                end 
            end
            
            //  SLLV
            STATE_SLLV: begin
                STATE = STATE_SHIFT_END;
                COUNTER = 0;
            end
            
            //  SRAV
            STATE_SRAV: begin
                STATE = STATE_SHIFT_END;
                COUNTER = 0;
            end 

            // SHIFT END STATE
            STATE_SHIFT_END: begin
                STATE = STATE_FETCH0;
                COUNTER = 0;
            end


            // SLT
            STATE_SLT_0: begin
                STATE = STATE_SLT_1;
                COUNTER = 0;
            end
            STATE_SLT_1: begin
                STATE = STATE_FETCH0;
                COUNTER = 0;
            end

            // SLTI
            STATE_SLTI_0: begin
                STATE = STATE_SLTI_1;
                COUNTER = 0;
            end
            STATE_SLTI_1: begin
                STATE = STATE_FETCH0;
                COUNTER = 0;
            end

            // JUMP
            STATE_JUMP: begin
                STATE = STATE_FETCH0;
                COUNTER = 0;
            end

            // RTE
            STATE_RTE: begin
                STATE = STATE_FETCH0;
                COUNTER = 0;
            end

            // RESOLUÇÃO DE ESTADOS DE LOADS, STORES E SLLM

            //STATE_LOAD_STORES_0
            STATE_LOAD_STORES_0: begin
                STATE = STATE_LOAD_STORES_1;
                COUNTER = 0;
            end

            //STATE_LOAD_STORES_1
            STATE_LOAD_STORES_1: begin
                STATE = STATE_LOAD_STORES_2;
                COUNTER = 0;
            end

            //STATE_LOAD_STORES_2
            STATE_LOAD_STORES_2: begin
                if (COUNTER == 0 || COUNTER == 1) begin
                    STATE = STATE_LOAD_STORES_2;
                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 2) begin
                    STATE = STATE_LOAD_STORES_3;
                    COUNTER = 0;
                end
            end

            //STATE_LOAD_STORES_3
            STATE_LOAD_STORES_3: begin
                if (OPCODE == SW) begin
                    STATE = STATE_SW;
                    COUNTER = 0;
                end
                else if (OPCODE == SH) begin
                    STATE = STATE_SH;
                    COUNTER = 0;
                end
                else if (OPCODE == SB) begin
                    STATE = STATE_SB;
                    COUNTER = 0;
                end
                else if (OPCODE == LW) begin
                    STATE = STATE_LW;
                    COUNTER = 0;
                end
                else if (OPCODE == LH) begin
                    STATE = STATE_LH;
                    COUNTER = 0;
                end
                else if (OPCODE == LB) begin
                    STATE = STATE_LB;
                    COUNTER = 0;
                end
                else if (OPCODE == SLLM) begin
                    STATE = STATE_SLLM_0;
                    COUNTER = 0;
                end
            end
            
            
            //STATE_SW
            STATE_SW: begin
                STATE = STATE_STORES_ENDING;
            end
            //STATE_SH
            STATE_SH: begin
                STATE = STATE_STORES_ENDING;
            end
            //STATE_SB
            STATE_SB: begin
                STATE = STATE_STORES_ENDING;
            end

            
            //STATE_LW
            STATE_LW: begin
                STATE = STATE_LOADS_ENDING;
            end
            //STATE_LH
            STATE_LH: begin
                STATE = STATE_LOADS_ENDING;
            end
            //STATE_LB
            STATE_LB: begin
                STATE = STATE_LOADS_ENDING;
            end
 
            
            //STATE_STORES_ENDING
            STATE_STORES_ENDING: begin
                STATE = STATE_FETCH0;
            end    
            //STATE_LOADS_ENDING
            STATE_LOADS_ENDING: begin
                STATE = STATE_FETCH0;
            end
            
            //STATE_SLLM_0 
            STATE_SLLM_0: begin
                STATE = STATE_SLLM_1;
            end
            //STATE_SLLM_1
            STATE_SLLM_1: begin
                STATE = STATE_SLLM_ENDING;
            end
            //STATE_SLLM_ENDING
            STATE_SLLM_ENDING: begin
                STATE = STATE_FETCH0;
            end

            //STATE_ADDM0
            STATE_ADDM0: begin
                if (COUNTER < 2) begin
                    COUNTER = COUNTER + 1;
                end else begin
                    if (O == 1) begin
                        STATE = STATE_EXP_OVERFLOW;
                    end else begin
                        COUNTER = 0;
                        STATE = STATE_ADDM1;
                    end
                end
            end
            //STATE_ADDM1
            STATE_ADDM1: begin
                STATE = STATE_ADDM2;
            end
            //STATE_ADDM2
            STATE_ADDM2: begin
                if (COUNTER < 2) begin
                    COUNTER = COUNTER + 1;
                end else begin
                    COUNTER = 0;
                    STATE = STATE_ADDM3;
                end
            end
            //STATE_ADDM3
            STATE_ADDM3: begin
                STATE = STATE_ADDM4;
            end
            //STATE_ADDM4
            STATE_ADDM4: begin
                STATE = STATE_FETCH0;
            end

            // LUI
            STATE_LUI: begin
                STATE = STATE_FETCH0;
            end

            // JAL
            STATE_JAL_0: begin
                STATE = STATE_JAL_1;
                COUNTER = 0;
            end
            STATE_JAL_1: begin
                STATE = STATE_JAL_2;
            end
            STATE_JAL_2: begin
                STATE = STATE_FETCH0;
            end


            //-------------- TRATAMENTO DE EXCEÇÕES ------------------//
            
            // OVERFLOW
            STATE_EXP_OVERFLOW: begin
                if (COUNTER < 2) begin
                    COUNTER = COUNTER + 1;
                end
                else begin
                    COUNTER = 0;
                    STATE = STATE_EXP_END_0;
                end                
            end

            // DIVISÃO POR ZERO
            STATE_EXP_DIV0: begin
                if (COUNTER < 2) begin
                    COUNTER = COUNTER + 1;
                end
                else begin
                    COUNTER = 0;
                    STATE = STATE_EXP_END_0;
                end 
            end

            // OPCODE INEXISTENTE
            STATE_EXP_OPCODE: begin
                if (COUNTER < 2) begin
                    COUNTER = COUNTER + 1;
                end
                else begin
                    COUNTER = 0;
                    STATE = STATE_EXP_END_0;
                end 
            end

            // FINAIZAÇÃO DO TRATAMENTO 0
            STATE_EXP_END_0: begin
                STATE = STATE_EXP_END_1;
            end

            // FINAIZAÇÃO DO TRATAMENTO 1
            STATE_EXP_END_1: begin
                STATE =STATE_FETCH0;
            end
            

            default: begin
                STATE = STATE_RESET;
                COUNTER = 0;
            end

        endcase
    end

end

endmodule