// shift
`define FUNCT_SLL       6'b000000
`define FUNCT_SRL       6'b000010
`define FUNCT_SRA       6'b000011
`define FUNCT_SLLV      6'b000100
`define FUNCT_SRLV      6'b000110
`define FUNCT_SRAV      6'b000111

// jump
`define FUNCT_JR        6'b001000
`define FUNCT_JALR      6'b001001

// move
`define FUNCT_MOVZ      6'b001010   // unused
`define FUNCT_MOVN      6'b001011   // unused

// interruption
`define FUNCT_SYSCALL   6'b001100
`define FUNCT_BREAK     6'b001101

// HI & LO
`define FUNCT_MFHI      6'b010000
`define FUNCT_MTHI      6'b010001
`define FUNCT_MFLO      6'b010010
`define FUNCT_MTLO      6'b010011

// multiplication & division
`define FUNCT_MULT      6'b011000
`define FUNCT_MULTU     6'b011001
`define FUNCT_DIV       6'b011010
`define FUNCT_DIVU      6'b011011

// arithmetic
`define FUNCT_ADD       6'b100000
`define FUNCT_ADDU      6'b100001
`define FUNCT_SUB       6'b100010
`define FUNCT_SUBU      6'b100011

// logic
`define FUNCT_AND       6'b100100
`define FUNCT_OR        6'b100101
`define FUNCT_XOR       6'b100110
`define FUNCT_NOR       6'b100111

// comparison
`define FUNCT_SLT       6'b101010
`define FUNCT_SLTU      6'b101011

// NOTE: improper usage
// it's NOP because '111111' is meaningless in current MIPS ISA
// but we can't make sure it won't be used in a future version
`define FUNCT_NOP       6'b111111
