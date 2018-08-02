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
    'sll': __op_special,
    'srl': __op_special,
    'sra': __op_special,
    'sllv': __op_special,
    'srlv': __op_special,
    'srav': __op_special,
    'jr': __op_special,
    'jalr': __op_special,
    'syscall': __op_special,
    'break': __op_special,
    'mfhi': __op_special,
    'mthi': __op_special,
    'mflo': __op_special,
    'mtlo': __op_special,
    'mult': __op_special,
    'multu': __op_special,
    'div': __op_special,
    'divu': __op_special,
    'add': __op_special,
    'addu': __op_special,
    'sub': __op_special,
    'subu': __op_special,
    'and': __op_special,
    'or': __op_special,
    'xor': __op_special,
    'nor': __op_special,
    'slt': __op_special,
    'sltu': __op_special,
    'bltz': __op_regimm,
    'bltzal': __op_regimm,
    'bgez': __op_regimm,
    'bgezal': __op_regimm,
    'j': __op_j,
    'jal': __op_jal,
    'beq': __op_beq,
    'bne': __op_bne,
    'blez': __op_blez,
    'bgtz': __op_bgtz,
    'addi': __op_addi,
    'addiu': __op_addiu,
    'slti': __op_slti,
    'sltiu': __op_sltiu,
    'andi': __op_andi,
    'ori': __op_ori,
    'xori': __op_xori,
    'lui': __op_lui,
    'mfc0': __op_cp0,
    'mtc0': __op_cp0,
    'eret': __op_cp0,
    'lb': __op_lb,
    'lh': __op_lh,
    'lw': __op_lw,
    'lbu': __op_lbu,
    'lhu': __op_lhu,
    'sb': __op_sb,
    'sh': __op_sh,
    'sw': __op_sw
}

funct_table = {
    'sll': __funct_sll,
    'srl': __funct_srl,
    'sra': __funct_sra,
    'sllv': __funct_sllv,
    'srlv': __funct_srlv,
    'srav': __funct_srav,
    'jr': __funct_jr,
    'jalr': __funct_jalr,
    'syscall': __funct_syscall,
    'break': __funct_break,
    'mfhi': __funct_mfhi,
    'mthi': __funct_mthi,
    'mflo': __funct_mflo,
    'mtlo': __funct_mtlo,
    'mult': __funct_mult,
    'multu': __funct_multu,
    'div': __funct_div,
    'divu': __funct_divu,
    'add': __funct_add,
    'addu': __funct_addu,
    'sub': __funct_sub,
    'subu': __funct_subu,
    'and': __funct_and,
    'or': __funct_or,
    'xor': __funct_xor,
    'nor': __funct_nor,
    'slt': __funct_slt,
    'sltu': __funct_sltu
}

regimm_table = {
    'bltz': __regimm_bltz,
    'bltzal': __regimm_bltzal,
    'bgez': __regimm_bgez,
    'bgezal': __regimm_bgezal
}

cp0_table = {
    'mfc0': __cp0_mfc0,
    'mtc0': __cp0_mtc0,
    'eret': __cp0_eret
}

reg_table = {
    'zero': 0, 'at': 1, 'v0': 2, 'v1': 3, 'a0': 4, 'a1': 5,
    'a2': 6, 'a3': 7, 't0': 8, 't1': 9, 't2': 10, 't3': 11,
    't4': 12, 't5': 13, 't6': 14, 't7': 15, 's0': 16, 's1': 17,
    's2': 18, 's3': 19, 's4': 20, 's5': 21, 's6': 22, 's7': 23,
    't8': 24, 't9': 25, 'k0': 26, 'k1': 27, 'gp': 28, 'sp': 29,
    's8': 30, 'fp': 30, 'ra': 31
}

# instruction type definitions
r_type_normal = [
    'add', 'addu', 'sub', 'subu', 'and',
    'or', 'xor', 'nor', 'slt', 'sltu'
]

r_type_shift = [
    'sllv', 'srlv', 'srav'
]

r_type = r_type_normal + r_type_shift

i_type = [
    'addi', 'addiu', 'slti', 'sltiu',
    'andi', 'ori', 'xori'
]

mul_div_type = [
    'mult', 'multu', 'div', 'divu'
]

shift_type = [
    'sll', 'srl', 'sra'
]

branch_type_i = [
    'beq', 'bne'
]

branch_type_ii = [
    'blez', 'bgtz'
]

branch_type_regimm = [
    'bltz', 'bltzal', 'bgez', 'bgezal'
]

branch_type = branch_type_i + branch_type_ii + branch_type_regimm

jump_type_i = [
    'j', 'jal'
]

jump_type_r = [
    'jr', 'jalr'
]

jump_type = jump_type_i + jump_type_r

move_type_t = [
    'mthi', 'mtlo'
]

move_type_f = [
    'mfhi', 'mflo'
]

move_type = move_type_t + move_type_f

trap_type = [
    'syscall', 'break'
]

mem_type = [
    'lb', 'lh', 'lw', 'lbu', 'lhu', 'sb', 'sh', 'sw'
]

cp0_type = [
    'mfc0', 'mtc0'
]

single_type = [
    'lui', 'eret'
]

psudo_type = [
    'li', 'move', 'mov', 'nop'
]
