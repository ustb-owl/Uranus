import mipsdef, sys
from mipsdef import Repr

def get_seg(inst):
    opcode = (inst >> 26) & 0b111111
    if opcode in mipsdef.r_type:
        rs = (inst >> 21) & 0b11111
        rt = (inst >> 16) & 0b11111
        rd = (inst >> 11) & 0b11111
        shamt = (inst >> 6) & 0b11111
        funct = inst & 0b111111
        op = mipsdef.op_table[opcode]
        if op == 'special':
            op = mipsdef.funct_table[funct]
        else:   # 'cp0'
            op = mipsdef.cp0_table[rs]
        seg_list = [rs, rt, rd, shamt, funct]
    elif opcode in mipsdef.j_type:
        offset = inst & 0x3ffffff
        op = mipsdef.op_table[opcode]
        seg_list = [offset]
    elif opcode in mipsdef.i_type:
        rs = (inst >> 21) & 0b11111
        rt = (inst >> 16) & 0b11111
        imm = inst & 0xffff
        op = mipsdef.op_table[opcode]
        if op == 'regimm':
            op = mipsdef.regimm_table[rt]
        seg_list = [rs, rt, imm]
    else:
        op = 'unknown'
        seg_list = []
    return op, seg_list

def get_str(data, rep: Repr, addr):
    s = ''
    if rep == Repr.Imm:
        s += str(data) if data < 1024 else hex(data)
    elif rep == Repr.Reg:
        s = '$' + mipsdef.reg_table[data] + ', '
    elif rep == Repr.RegInt:
        s = '$' + str(data) + ', '
    elif rep == Repr.Offset:
        s = hex((((data << 2) | 0xfffc0000) + addr) & 0xffffffff)
    elif rep == Repr.Addr:
        s = hex(((addr + 4) & 0xf0000000) | (data << 2))
    elif rep == Repr.Sel:
        s = str(data) if rep else ''
    elif rep == Repr.Base:
        s = '(%s)' % ('$' + mipsdef.reg_table[data])
    elif rep == Repr.MemOff:
        s = hex(data)
    return s

def get_inst(op, seg_list, addr):
    inst = op
    for op_list, repr_list in mipsdef.seg_rep:
        if op in op_list:
            if repr_list:
                inst += ' '
                for index, rep in repr_list:
                    inst += get_str(seg_list[index], rep, addr)
                inst = inst.rstrip(', ')
            break
    return inst

def get_asm(infile, outfile, base):
    with open(infile, 'r') as fr:
        addr = base
        with open(outfile, 'w') as fw:
            for line in fr.readlines():
                if not line:
                    continue
                pattern = '%-30s # %s\n'
                inst_byte = int(line.replace(' ', ''), 16)
                if inst_byte:
                    op, seg_list = get_seg(inst_byte)
                    inst = get_inst(op, seg_list, addr)
                else:
                    inst = 'nop'
                fw.write(pattern % (inst, hex(addr)))
                addr += 4


def main():
    args = sys.argv
    if len(args) < 2:
        exit(1)
    args.pop(0)
    
    infile = args[0]
    if len(args) >= 2:
        outfile = args[1]
    else:
        outfile = infile[:infile.rfind('.')] + '.s'
    
    if len(args) >= 3:
        base = args[2]
    else:
        base = 0xbfc00000

    get_asm(infile, outfile, base)


if __name__ == '__main__':
    main()
