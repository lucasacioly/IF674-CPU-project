# IF674-CPU-project

Projeto de CPU baseado no processador MIPS


## Datapath

![DataPath](./docs/datapath.svg)

## Tabela de instruções

### Instruções do tipo R
 
|        Assembly        | Opcode | rs | rt | rd | shamt |  funct   |      Comportamento     |
|:----------------------:|:------:|:--:|:--:|:--:|:-----:|:--------:|:----------------------:|
|     add rd, rs, rt     | 000000 | rs | rt | rd |       | 00100000 |      rd ← rs + rt      |
|     and rd, rs, rt     | 000000 | rs | rt | rd |       | 00100100 |      rd ← rs & rt      |
|       div rs, rt       | 000000 | rs | rt |    |       | 00011010 |         rs / rt        |
|       mult rs, rt      | 000000 | rs | rt |    |       | 00011000 |         rs x rt        |
|          jr rs         | 000000 | rs |    |    |       | 00001000 |         PC ← rs        |
|         mfhi rd        | 000000 |    |    | rd |       | 00010000 |         rd ← hi        |
|         mflo rd        | 000000 |    |    | rd |       | 00010010 |         rd ← lo        |
|    sll rd, rt, shamt   | 000000 |    | rt | rd | shamt | 00000000 |    rd ← rt << shamt    |
|     sllv rd, rs, rt    | 000000 | rs | rt | rd |       | 00000100 |      rd ← rs << rt     |
|     slt rd, rs, rt     | 000000 | rs | rt | rd |       | 00101010 |  rd ← (rs < rt) ?1 :0  |
|    sra rd, rt, shamt   | 000000 |    | rt | rd | shamt | 00000011 |    rd ← rt >> shamt*   |
|     srav rd, rs, rt    | 000000 | rs | rt | rd |       | 00000111 |     rd ← rs >> rt*     |
|    srl rd, rt, shamt   | 000000 |    | rt | rd | shamt | 00000010 |    rd ← rt >> shamt    |
|     sub rd, rs, rt     | 000000 | rs | rt | rd |       | 00100010 |      rd ← rs – rt      |
|          break         | 000000 |    |    |    |       | 00001101 |       PC ← PC - 4      |
|           Rte          | 000000 |    |    |    |       | 00010011 |        PC ← EPC        |
|       addm rs, rt, rd  | 000000 | rs | rt | rd |       | 00000101 | rd ← Mem[rs] + Mem[rt] |

### Instruções do tipo I

|        Assembly        | Opcode | rs | rt | Imediato |          Comportamento         |
|:----------------------:|:------:|:--:|:--:|:--------:|:------------------------------:|
|  addi rt, rs, imediato | 001000 | rs | rt | imediato |      rt ← rs + imediato**      |
| addiu rt, rs, imediato | 001001 | rs | rt | imediato |      rt ← rs + imediato**      |
|    beq rs,rt, offset   | 000100 | rs | rt |  offset  |       Desvia se rs == rt       |
|    bne rs,rt, offset   | 000101 | rs | rt |  offset  |       Desvia se rs != rt       |
|    ble rs,rt,offset    | 000110 | rs | rt |  offset  |       Desvia se rs <= rt       |
|    bgt rs,rt,offset    | 000111 | rs | rt |  offset  |        Desvia se rs > rt       |
|   sllm rt, offset(rs)  | 000001 | rs | rt |  offset  |  rt ← rt << Mem[offset + rs]*  |
|    lb rt, offset(rs)   | 100000 | rs | rt |  offset  |   rt ← byte Mem[offset + rs]   |
|    lh rt, offset(rs)   | 100001 | rs | rt |  offset  | rt ← halfword Mem[offset + rs] |
|    lui rt, imediato    | 001111 |    | rt | imediato |       rt ← imediato << 16      |
|    lw rt, offset(rs)   | 100011 | rs | rt |  offset  |      rt ← Mem[offset + rs]     |
|    sb rt, offset(rs)   | 101000 | rs | rt |  offset  |   Mem[offset + rs] ← byte[rt]  |
|    sh rt, offset(rs)   | 101001 | rs | rt |  offset  | Mem[offset + rs] ← halfword[rt]|
|  slti rt, rs, imediato | 001010 | rs | rt | imediato |   rt ← (rs < imediato) ?1 :0   |
|    sw rt, offset(rs)   | 101011 | rs | rt |  offset  |      Mem[offset + rs] ← rt     |

### Instruções do tipo J

|  Assembly  | Opcode | Offset |     Comportamento     |
|:----------:|:------:|:------:|:---------------------:|
|  j offset  | 000010 | offset |         Desvia        |
| jal offset | 000011 | offset | reg[31] ← PC e desvia |

> \* instruções devem estender o sinal (deslocamento aritmético)
> ** o valor de ‘imediato’ deve ser estendido para 32 bits, estendendo seu sinal (bit mais significativo da constante).
## Instruções feitas:

Essas são as instruções que conseguimos fazer:

### Instruções do tipo R

- [] add rd, rs, rt
- [] and rd, rs, rt
- [] sub rd, rs, rt
- [] sll rd, rt, shamt
- [] sra rd, rt, shamt
- [] srl rd, rt, shamt 
- [] sllv rd, rs, rt
- [] srav rd, rs, rt
- [] slt rd, rs, rt
- [] jr rs
- [] break 
- [] Rte 
- [] div rs, rt
- [] mult rs, rt
- [] mfhi rd
- [] mflo rd
- [] addm rs, rt, rd

### Instruções do tipo I

- [] addi rt, rs, imediato
- [] addiu rt, rs, imediato
- [] beq rs, rt, offset
- [] bne rs, rt, offset 
- [] ble rs, rt, offset 
- [] bgt rs, rtx, offset 
- [] lb rt, offset(rs) 
- [] lh rt, offset(rs)
- [] lw rt, offset(rs)
- [] lui rt, imediato
- [] sb rt, offset(rs)
- [] sh rt, offset(rs)
- [] sw rt, offset(rs)
- [] slti rs, rt, imediato
- [] sllm rt, offset(rs) 

### Instruções do tipo J

- [] j offset
- [] jal offset

### Exceção
- [] Overflow
- [] div by 0
- [] opcode inexistente
