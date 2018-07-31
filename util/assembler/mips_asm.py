import sys

if len(sys.argv) != 2:
    exit(1)

path = sys.argv[1]
asm_list = []
with open(path, 'r') as file:
    asm_list = file.readlines()

def getReg(reg):
    return int(reg.replace('$', ''))

def getImm(imm, wide=0):
    return int(imm) & (0xffff if not wide else 0x03ffffff)

def get32BitHex(num):
    chr_list = '0123456789abcdef'
    k = num
    s = ''
    for _ in range(8):
        s = chr_list[k & 15] + s
        k >>= 4
    return s

def encodeRTypeInst(l):
    op = 0b000000
    fill = 0b00000   # shamt or rs
    normal = {
        'add': 0b100000,
        'addu': 0b100001,
        'sub': 0b100010,
        'subu': 0b100011,
        'and': 0b100100,
        'or': 0b100101,
        'xor': 0b100110,
        'nor': 0b100111,
        'slt': 0b101010,
        'sltu': 0b101000,
        'sllv': 0b000100,
        'srlv': 0b000110,
        'srav': 0b000111
    }
    shift = {
        'sll': 0b000000,
        'srl': 0b000010,
        'sra': 0b000011
    }
    jump = {
        'jr': 0b001000
    }
    if l[0] in normal:
        inst = op << 26
        inst += getReg(l[2]) << 21
        inst += getReg(l[3]) << 16
        inst += getReg(l[1]) << 11
        inst += fill << 6
        inst += normal[l[0]]
    elif l[0] in shift:
        inst = op << 26
        inst += fill << 21
        inst += getReg(l[2]) << 16
        inst += getReg(l[1]) << 11
        inst += getImm(l[3]) << 6
        inst += shift[l[0]]
    else:
        inst = op << 26
        inst += getReg(l[1]) << 21
        inst += fill << 16
        inst += fill << 11
        inst += fill << 6
        inst += jump[l[0]]
    return get32BitHex(inst)

def encodeITypeInst(l):
    op = {
        'addi': 0b001000,
        'addiu': 0b001001,
        'andi': 0b001100,
        'ori': 0b001101,
        'xori': 0b001110,
        'lw': 0b100011,
        'sw': 0b101011,
        'beq': 0b000100,
        'bne': 0b000101,
        'slti': 0b001010,
        'sltiu': 0b001011
    }
    if l[0] == 'lui':
        inst = 0b001111 << 26
        inst += 0 << 21
        inst += getReg(l[1]) << 16
        inst += getImm(l[2])
    else:
        inst = op[l[0]] << 26
        inst += getReg(l[2]) << 21
        inst += getReg(l[1]) << 16
        inst += getImm(l[3])
    return get32BitHex(inst)

def encodeJTypeInst(l):
    op = {
        'j': 0b000010,
        'jal': 0b000011
    }
    inst = op[l[0]] << 26
    inst += getImm(l[1], 1)
    return get32BitHex(inst)

def getHexAssembly(l):
    rtype = [
        'add', 'addu', 'sub', 'subu', 'and', 'or',
        'xor', 'nor', 'slt', 'sltu', 'sll', 'srl',
        'sra', 'sllv', 'srlv', 'srav', 'jr'
    ]
    jtype = [
        'j', 'jal'
    ]
    if l[0] == 'nop':
        return '00000000'
    elif l[0] in rtype:
        return encodeRTypeInst(l)
    elif l[0] in jtype:
        return encodeJTypeInst(l)
    else:
        return encodeITypeInst(l)

for i in asm_list:
    asm = i.strip().lower().replace(',', ' ').split()
    asm_str = ' '.join(asm)
    asm = asm_str.split(' ')
    print(getHexAssembly(asm) + '   // ' + asm_str)
