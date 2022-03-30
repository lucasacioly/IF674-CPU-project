
module CPU(
    input wire clk,
    input wire reset
);

//-----------------------------------parâmetros especiais-------------------------------------//
parameter REG_31 = 5'd31;
parameter REG_29 = 5'd29;
parameter NUM_4 = 32'd4;     // para somas e subtrações na ULA    
parameter NUM_227 = 32'd227; //para reset
parameter NUM_253 = 32'd253; //para os exceção
parameter NUM_254 = 32'd254; //para os exceção
parameter NUM_255 = 32'd255; //para os exceção

//---------------------------------INSTANCIAR FIOS DA CPU-----------------------------------//

//--------------------------------------fios de dados--------------------------------------// 

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


// PC
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

//A
wire [31:0] A_out;

//B
wire [31:0] B_out;



// LOAD MASK
wire [31:0] load_mask_out;

// STORE MASK
wire [31:0] store_mask_out;


// sign extend 1 to 32
wire [31:0] one_to32_out;
// sign extend 16 to 32
wire [31:0] sixteen_to32_out;
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

// fios de dados obtidos por concatenação de outros fios 
wire input_to_shift_jump;
assign input_to_shift_jump = {RS, {RT, OFSET}};

wire input_jump_adres;
assign input_jump_adres = {PC_out[31:28], shift2_jump_out};




//----------------------------------sinais de controle-----------------------------------//

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
wire MEMwrite;             // MEMÓRIA
wire [2:0] Shift;         // registrador de deslocamento
wire RegWrite;              // banco de registradores

// ULA
wire [2:0] ALUop;
wire O;         // OVERFLOW
wire ZERO;         // ZERO on operation
wire GT;        // Greater than
wire LT;        // Less than
wire EG;        // Equal to
wire N;          // negative

// DIV e MULT
wire Div_Mult_Ctrl;
wire DIV0;


//----------------------------INSTANCIANDO MÓDULOS UTILIZADOS----------------------------//

// ULA
Ula32 ULA(
    .A(mux_ulaA_out), 			
	.B(mux_ulaB_out), 			
	.Seletor(ALUop), 	
	.S(ula_result), 			  
	.Overflow(O), 	
	.Negativo(N),	
	.z(ZERO),			
	.Igual(EG),		
	.Maior(GT),		
	.Menor(LT)
);

// DIV e MULT

// IR 
Instr_reg IR(
    .Clk(clk),			
	.Reset(reset),		
	.Load_ir(IrWrite),		
	.Entrada(mem_out),		
	.Instr31_26(OP_CODE),	
	.Instr25_21(RS),	
	.Instr20_16(RT),	
	.Instr15_0(OFSET)
);

// MEMORIA
Memoria memory(
    .Address(mux_memory_out),	
	.Clock(clk),
	.Wr(MEMwrite),	
	.Datain(store_mask_out),	
	.Dataout(mem_out)
);

// BANCO DE REGISTRADORES
Banco_reg banco_reg (
    .Clk(clk),
    .Reset(reset),
    .RegWrite(RegWrite),
    .ReadReg1(RS),
    .ReadReg2(RT),
        
    .WriteReg(mux_Write_Reg_out),
    .WriteData(mux_Write_Data_out),
        
    .ReadData1(read_data_1),
    .ReadData2(read_data_2)
);


// REGISTRADOR DE DESLOCAMENTOS
RegDesloc shift_reg(
    .Clk(clk),		
	.Reset(reset),	
	.Shift(Shift),	 
	.N(mux_Shift_Ammount_out),		
	.Entrada(mux_Shift_Reg_out), 
	.Saida(shift_out)
);


// PC
Registrador PC(
    clk,		
	reset,	
	PCwrite,
	mux_PC_out, 
	PC_out
);

// REG A
Registrador A(
    clk,		
	reset,	
	Awrite,	
	read_data_1,
	A_out
);

// REG B
Registrador B(
    clk,		
	reset,	
	Bwrite,	
	read_data_2,
	B_out
);

// ALUout
Registrador ALUout(
    clk,		
	reset,	
	ALUoutCtrl,	
	ula_result,
	ALUout_out
);

// EPC
Registrador EPC(
    clk,		
	reset,	
	EPCcontrol,	
	ula_result,
	EPC_out
);

// MDR
Registrador MDR(
    clk,		
	reset,	
	MDRwrite,	
	mem_out,
	MDR_out
);

// HI
Registrador HI(
    clk,		
	reset,	
	write,	
	div_mult_hi,
	HI_out
);

// LO
Registrador LO(
    clk,		
	reset,	
	write,	
	div_mult_lo,
	LO_out
);




// LOAD MASK
LoadMask LOAD_MASK(
    .MR(MDR_out),
    .CT(LMcontrol),
    .OUT(load_mask_out)
);
// STORE MASK
StoreMask STORE_MASK(
    .B(B_out),
    .MR(MDR_out),
    .CT(SMcontrol),
    .OUT(store_mask_out)
);



// sign extend 1 to 32
sign_extend_1to32 sign_extend_1to32(
	.data_in(LT),
    .data_out(one_to32_out)
);
// sign extend 16 to 32
sign_extend_16to32 sign_extend_16to32(
	.data_in(OFSET),
    .data_out(sixteen_to32_out)
);
// shift left 16
shift_left_16_lui shift_left_16_lui(
	.data_in(OFSET),
    .data_out(shift16_out)
);
// shift left 2 branch
shift_left_2 shift_left_2_branch(
	.data_in(sixteen_to32_out),
    .data_out(shift2_branch_out)
);

// shift left 2 jump
shift_left_2_26to28 shift_left_2_jump(
	.data_in(input_to_shift_jump),
    .data_out(shift2_jump_out)
);



// mux_EXCP
mux_3x1 mux_EXCP(
	.Data_0(NUM_253),
    .Data_1(NUM_254),
    .Data_2(NUM_255),

    .Selector(EXCPcontrol),
    .Data_out(mux_EXCP_out)
);
// mux_memory, o que leva dados para a memoria
mux_6x1 mux_memory(
	.Data_0(PC_out),
    .Data_1(ula_result),
    .Data_2(B_out),
    .Data_3(A_out),
    .Data_4(ALUout_out),
	.Data_5(mux_EXCP_out),

    .Selector(IorD),
    .Data_out(mux_memory_out)
);
// mux_PC, o que leva os dados para o PC
mux_5x1 mux_PC(
	.Data_0(input_jump_adres),
    .Data_1(load_mask_out),
    .Data_2(ula_result),
    .Data_3(EPC_out),
    .Data_4(ALUout_out),

    .Selector(PCsrc),
    .Data_out(mux_PC_out)
);
// mux_Shift_Ammount
mux_3x1_5 mux_Shift_Ammount(
	.Data_0(B_out[4:0]),
    .Data_1(MDR_out[4:0]),
    .Data_2(OFSET[10:6]),

    .Selector(ShiftAmmCtrl),
    .Data_out(mux_Shift_Ammount_out)
);
// mux_Shift_Reg
mux_2x1 mux_Shift_Reg(
	.Data_0(A_out),
    .Data_1(B_out),

    .Selector(ShiftRegCtrl),
    .Data_out(mux_Shift_Reg_out)
);
// mux_ulaA
mux_3x1 mux_ulaA(
	.Data_0(PC_out),
    .Data_1(mem_out),
    .Data_2(A_out),

    .Selector(ALUsrcA),
    .Data_out(mux_ulaA_out)
);
// mux_ulaB
mux_5x1 mux_ulaB(
	.Data_0(B_out),
    .Data_1(NUM_4),
    .Data_2(MDR_out),
    .Data_3(sixteen_to32_out),
    .Data_4(shift2_branch_out),

    .Selector(ALUsrcB),
    .Data_out(mux_ulaB_out)
);
// mux_Write_Data
mux_8x1 mux_Write_Data(
	.Data_0(load_mask_out),
    .Data_1(LO_out),
    .Data_2(HI_out),
    .Data_3(shift16_out),
    .Data_4(NUM_227),
    .Data_5(shift_out),
    .Data_6(ALUout_out),
    .Data_7(LT),

    .Selector(MemToReg),
    .Data_out(mux_Write_Data_out)
);
// mux_Write_Reg
mux_4x1_5 mux_Write_Reg(
	.Data_0(RT),
    .Data_1(OFSET[15:11]),
    .Data_2(REG_31),
    .Data_3(REG_29),

    .Selector(RegDst),
    .Data_out(mux_Write_Reg_out)
);


//----------------------- CONTROL UNIT -------------------------//

control_unit CONTROL_UNIT(
    .clk(clk),
    .reset_in(reset),

// instruction
    .OPCODE(OPCODE),
    .FUNCT(FUNCT),

// flags

    .O(O),         // OVERFLOW
    .ZERO(ZERO),      // ZERO on operation
    .GT(GT),        // Greater than
    .LT(LT),        // Less than
    .EG(EG),        // Equal to
    .N(N),         // negative
    .DIV0(DIV0),      // DIV0 exception signal

// outputs

// ULA
    .ALUop(ALUop),

// DIV e MULT
    .Div_Mult_Ctrl(Div_Mult_Ctrl),

// armazenamentos e deslocamentos
    .MEMwrite(MEMwrite),             // MEMÓRIA
    .Shift(Shift),         // registrador de deslocamento
    .RegWrite(RegWrite),              // banco de registradores

// Mascaras de Store e Load
    .SMcontrol(SMcontrol),
    .LMcontrol(LMcontrol),

// multiplexadores
    .EXCPcontrol(EXCPcontrol),
    .IorD(IorD),
    .ShiftRegCtrl(ShiftRegCtrl),
    .ShiftAmmCtrl(ShiftAmmCtrl),
    .RegDst(RegDst),
    .MemToReg(MemToReg),
    .ALUsrcA(ALUsrcA),
    .ALUsrcB(ALUsrcB),
    .PCsrc(PCsrc),


// registradores

    .PCwrite(PCwrite),
    .IrWrite(IrWrite),
    .MDRwrite(MDRwrite),
    .write(write),     // sinal para escrever em HI e LO
    .Awrite(Awrite),
    .Bwrite(Bwrite),
    .EPCcontrol(EPCcontrol),
    .ALUoutCtrl(ALUoutCtrl),

// reset 
    .reset_out(reset)
);

endmodule