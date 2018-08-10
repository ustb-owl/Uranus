from enum import Enum, unique

# r-type (SPECIAL)
__op_special = 0b000000

# reg-imm
__op_regimm = 0b000001

# j-type
__op_j = 0b000010
__op_jal = 0b000011

# branch
__op_beq = 0b000100
__op_bne = 0b000101
__op_blez = 0b000110
__op_bgtz = 0b000111

# arithmetic
__op_addi = 0b001000
__op_addiu = 0b001001

# comparison
__op_slti = 0b001010
__op_sltiu = 0b001011

# logic
__op_andi = 0b001100
__op_ori = 0b001101
__op_xori = 0b001110

# immediate
__op_lui = 0b001111

# coprocessor
__op_cp0 = 0b010000

# memory accessing
__op_lb = 0b100000
__op_lh = 0b100001
__op_lw = 0b100011
__op_lbu = 0b100100
__op_lhu = 0b100101
__op_sb = 0b101000
__op_sh = 0b101001
__op_sw = 0b101011

# shift
__funct_sll = 0b000000
__funct_srl = 0b000010
__funct_sra = 0b000011
__funct_sllv = 0b000100
__funct_srlv = 0b000110
__funct_srav = 0b000111

# jump
__funct_jr = 0b001000
__funct_jalr = 0b001001

# interruption
__funct_syscall = 0b001100
__funct_break = 0b001101

# HI & LO
__funct_mfhi = 0b010000
__funct_mthi = 0b010001
__funct_mflo = 0b010010
__funct_mtlo = 0b010011

# multiplication & division
__funct_mult = 0b011000
__funct_multu = 0b011001
__funct_div = 0b011010
__funct_divu = 0b011011

# arithmetic
__funct_add = 0b100000
__funct_addu = 0b100001
__funct_sub = 0b100010
__funct_subu = 0b100011

# logic
__funct_and = 0b100100
__funct_or = 0b100101
__funct_xor = 0b100110
__funct_nor = 0b100111

# comparison
__funct_slt = 0b101010
__funct_sltu = 0b101011

# some branch instructions
__regimm_bltz = 0b00000
__regimm_bltzal = 0b10000
__regimm_bgez = 0b00001
__regimm_bgezal = 0b10001

# coprocessor instructions
__cp0_mfc0 = 0b00000
__cp0_mtc0 = 0b00100
__cp0_eret = 0b10000

# lookup table definitions
op_table = {
    __op_special: 'special',
    __op_regimm: 'regimm',
    __op_j: 'j',
    __op_jal: 'jal',
    __op_beq: 'beq',
    __op_bne: 'bne',
    __op_blez: 'blez',
    __op_bgtz: 'bgtz',
    __op_addi: 'addi',
    __op_addiu: 'addiu',
    __op_slti: 'slti',
    __op_sltiu: 'sltiu',
    __op_andi: 'andi',
    __op_ori: 'ori',
    __op_xori: 'xori',
    __op_lui: 'lui',
    __op_cp0: 'cp0',
    __op_lb: 'lb',
    __op_lh: 'lh',
    __op_lw: 'lw',
    __op_lbu: 'lbu',
    __op_lhu: 'lhu',
    __op_sb: 'sb',
    __op_sh: 'sh',
    __op_sw: 'sw'
}

funct_table = {
    __funct_sll: 'sll',
    __funct_srl: 'srl',
    __funct_sra: 'sra',
    __funct_sllv: 'sllv',
    __funct_srlv: 'srlv',
    __funct_srav: 'srav',
    __funct_jr: 'jr',
    __funct_jalr: 'jalr',
    __funct_syscall: 'syscall',
    __funct_break: 'break',
    __funct_mfhi: 'mfhi',
    __funct_mthi: 'mthi',
    __funct_mflo: 'mflo',
    __funct_mtlo: 'mtlo',
    __funct_mult: 'mult',
    __funct_multu: 'multu',
    __funct_div: 'div',
    __funct_divu: 'divu',
    __funct_add: 'add',
    __funct_addu: 'addu',
    __funct_sub: 'sub',
    __funct_subu: 'subu',
    __funct_and: 'and',
    __funct_or: 'or',
    __funct_xor: 'xor',
    __funct_nor: 'nor',
    __funct_slt: 'slt',
    __funct_sltu: 'sltu'
}

regimm_table = {
    __regimm_bltz: 'bltz',
    __regimm_bltzal: 'bltzal',
    __regimm_bgez: 'bgez',
    __regimm_bgezal: 'bgezal'
}

cp0_table = {
    __cp0_mfc0: 'mfc0',
    __cp0_mtc0: 'mtc0',
    __cp0_eret: 'eret'
}

reg_table = {
    0: 'zero', 1: 'at', 2: 'v0', 3: 'v1', 4: 'a0', 5: 'a1', 6: 'a2',
    7: 'a3', 8: 't0', 9: 't1', 10: 't2', 11: 't3', 12: 't4', 13: 't5',
    14: 't6', 15: 't7', 16: 's0', 17: 's1', 18: 's2', 19: 's3', 20: 's4',
    21: 's5', 22: 's6', 23: 's7', 24: 't8', 25: 't9', 26: 'k0', 27: 'k1',
    28: 'gp', 29: 'sp', 30: 'fp', 31: 'ra'
}

# segment type definitions
r_type = [
    __op_special, __op_cp0
]

i_type = [
    __op_regimm, __op_beq, __op_bne, __op_blez, __op_bgtz, __op_addi,
    __op_addiu, __op_slti, __op_sltiu, __op_andi, __op_ori, __op_xori,
    __op_lui, __op_lb, __op_lh, __op_lw, __op_lbu, __op_lhu, __op_sb,
    __op_sh, __op_sw
]

j_type = [
    __op_j, __op_jal
]

# segment representation definitions
@unique
class Repr(Enum):
    Imm = 0
    Reg = 1
    RegInt = 2
    Offset = 3
    Addr = 4
    Sel = 5
    Base = 6
    MemOff = 7

seg_rep = [
    (['sll', 'srl', 'sra'], [(2, Repr.Reg), (1, Repr.Reg), (3, Repr.Imm)]),
    (['sllv',
            'srlv', 'srav'], [(2, Repr.Reg), (1, Repr.Reg), (0, Repr.Reg)]),
    (['jr', 'jalr', 'add', 'addu', 'sub',
            'subu', 'and', 'or', 'xor', 'nor',
            'slt', 'sltu'], [(2, Repr.Reg), (0, Repr.Reg), (1, Repr.Reg)]),
    (['syscall', 'break', 'eret'], []),
    (['mfhi', 'mthi', 'mflo', 'mtlo'], [(2, Repr.Reg)]),
    (['mult', 'multu', 'div', 'divu'], [(0, Repr.Reg), (1, Repr.Reg)]),
    (['bltz', 'bltzal', 'bgez', 'bgezal',
            'blez', 'bgtz'], [(0, Repr.Reg), (2, Repr.Offset)]),
    (['j', 'jal'], [(0, Repr.Addr)]),
    (['beq', 'bne'], [(0, Repr.Reg), (1, Repr.Reg), (2, Repr.Offset)]),
    (['addi', 'addiu', 'slti', 'sltiu', 'andi',
            'ori', 'xori'], [(1, Repr.Reg), (0, Repr.Reg), (2, Repr.Imm)]),
    (['lui'], [(1, Repr.Reg), (2, Repr.Imm)]),
    (['mfc0', 'mtc0'], [(1, Repr.Reg), (2, Repr.RegInt), (4, Repr.Sel)]),
    (['lb', 'lh', 'lw', 'lbu', 'lhu', 'sb',
            'sh', 'sw'], [(1, Repr.Reg), (2, Repr.MemOff), (0, Repr.Base)])
]
