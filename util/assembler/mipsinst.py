import mipsdef, re


class TagUndefError(Exception):
    def __init__(self, tag):
        super().__init__()
        self.tag = tag

class _InstBuilder(object):
    def __init__(self, opcode, body, position):
        self.opcode = opcode
        self.body = body
        self.position = position

    def _get_op(self):
        return mipsdef.op_table[self.opcode] << 26
    
    def _get_funct(self):
        return mipsdef.funct_table.get(self.opcode)

    def _get_reg(self, reg: str):
        reg_str = reg.lstrip('$')
        value = mipsdef.reg_table.get(reg_str)
        if value is None:
            try:
                value = int(reg_str)
            except ValueError:
                self._raise_error()
        return value & 0b11111

    def _get_imm(self, imm, wide=False):
        try:
            value = eval(imm)
            if not isinstance(value, int):
                self._raise_error()
        except:
            self._raise_error()
        return value & (0xffff if not wide else 0x03ffffff)

    @staticmethod
    def _get_byte(inst):
        chars = '0123456789abcdef'
        k = inst
        s = ''
        for i in range(8):
            s = (' ' if i % 2 else '') + chars[k & 15] + s
            k >>= 4
        return s.strip()

    def _raise_error(self, tag=None):
        if tag:
            raise TagUndefError(tag)
        else:
            msg = 'illegal instruction "' + self.inst()
            msg += '" in position %d' % self.position
            raise RuntimeError(msg)

    def _trim_body(self, size):
        if len(self.body) < size:
            self._raise_error()
        self.body = self.body[:size]

    def inst(self):
        return self.opcode + ' ' + ', '.join(self.body)

    def build(self, tags):
        raise NotImplementedError

class RTypeInstBuilder(_InstBuilder):
    def build(self, tags):
        self._trim_body(3)
        inst = self._get_op()
        rd = self._get_reg(self.body[0])
        if self.opcode in mipsdef.r_type_normal:
            rs = self._get_reg(self.body[1])
            rt = self._get_reg(self.body[2])
        else:   # r_type_shift
            rt = self._get_reg(self.body[1])
            rs = self._get_reg(self.body[2])
        inst += rs << 21
        inst += rt << 16
        inst += rd << 11
        inst += 0b00000 << 6
        inst += self._get_funct()
        return self._get_byte(inst)

class ITypeInstBuilder(_InstBuilder):
    def build(self, tags):
        self._trim_body(3)
        inst = self._get_op()
        rt = self._get_reg(self.body[0])
        rs = self._get_reg(self.body[1])
        try:
            imm = self._get_imm(self.body[2])
        except:
            self._raise_error()
        inst += rs << 21
        inst += rt << 16
        inst += imm
        return self._get_byte(inst)

class MulDivInstBuilder(_InstBuilder):
    def build(self, tags):
        self._trim_body(2)
        inst = self._get_op()
        rs = self._get_reg(self.body[0])
        rt = self._get_reg(self.body[1])
        inst += rs << 21
        inst += rt << 16
        inst += 0b0000000000 << 6
        inst += self._get_funct()
        return self._get_byte(inst)

class ShiftInstBuilder(_InstBuilder):
    def build(self, tags):
        self._trim_body(3)
        inst = self._get_op()
        inst += 0b00000 << 21
        rd = self._get_reg(self.body[0])
        rt = self._get_reg(self.body[1])
        sa = self._get_imm(self.body[2]) & 0b11111
        inst += rt << 16
        inst += rd << 11
        inst += sa << 6
        inst += self._get_funct()
        return self._get_byte(inst)

class BranchInstBuilder(_InstBuilder):
    def build(self, tags):
        inst = self._get_op()
        if self.opcode in mipsdef.branch_type_i:
            self._trim_body(3)
            imm_str = self.body[2]
            rs = self._get_reg(self.body[0])
            rt = self._get_reg(self.body[1])
        elif self.opcode in mipsdef.branch_type_ii:
            self._trim_body(2)
            imm_str = self.body[1]
            rs = self._get_reg(self.body[0])
            rt = 0b00000
        else:   # branch_type_regimm
            self._trim_body(2)
            imm_str = self.body[1]
            rs = self._get_reg(self.body[0])
            rt = mipsdef.regimm_table[self.opcode]
        try:
            imm = self._get_imm(imm_str)
        except:
            pos = tags.get(imm_str)
            if pos is not None:
                imm = pos - (self.position + 1)
            else:
                self._raise_error(imm_str)
        inst += rs << 21
        inst += rt << 16
        inst += imm
        return self._get_byte(inst)

class JumpInstBuilder(_InstBuilder):
    def build(self, tags):
        self._trim_body(2 if self.opcode == 'jalr' else 1)
        inst = self._get_op()
        if self.opcode in mipsdef.jump_type_i:
            imm_str = self.body[0]
            try:
                imm = self._get_imm(imm_str, wide=True)
            except:
                imm = tags.get(imm_str)
                if imm is None:
                    self._raise_error(imm_str)
            inst += imm
        else:   # jump_type_r
            if self.opcode == 'jalr':
                rd = self._get_reg(self.body[0])
                rs = self._get_reg(self.body[1])
            else:   # jr
                rd = 0b00000
                rs = self._get_reg(self.body[0])
            inst += rs << 21
            inst += 0b00000 << 16
            inst += rd << 11
            inst += 0b00000 << 6
            inst += self._get_funct()
        return self._get_byte(inst)

class MoveInstBuilder(_InstBuilder):
    def build(self, tags):
        self._trim_body(1)
        inst = self._get_op()
        if self.opcode in mipsdef.move_type_t:
            rs = self._get_reg(self.body[0])
            rd = 0b00000
        else:   # move_type_f
            rs = 0b00000
            rd = self._get_reg(self.body[0])
        inst += rs << 21
        inst += 0b00000 << 16
        inst += rd << 11
        inst += 0b00000 << 6
        inst += self._get_funct()
        return self._get_byte(inst)

class TrapInstBuilder(_InstBuilder):
    def build(self, tags):
        self._trim_body(0)
        code0 = 0b00111000001001011000   # F@CKU in T9 keyboard
        code1 = 0b01100100011101110000   # MIPS  in T9 keyboard
        inst = self._get_op()
        inst += (code0 if self.opcode == 'break' else code1) << 6
        inst += self._get_funct()
        return self._get_byte(inst)

class MemInstBuilder(_InstBuilder):
    def build(self, tags):
        self._trim_body(2)
        inst = self._get_op()
        rt = self._get_reg(self.body[0])
        # parse offset and base
        addr = self.body[1]
        result = addr.rstrip(')').split('(')
        result.append('')
        offset = result[0]
        base = result[1]
        if not offset and not base:
            self._raise_error()
        # get value of offset and base
        # NOTE: offset can be a tag of address,
        #       but it's not implemented yet here
        offset = self._get_imm(offset) if offset else 0x0000
        base = self._get_reg(base) if base else 0b00000
        # assembly instruction field
        inst += base << 21
        inst += rt << 16
        inst += offset
        return self._get_byte(inst)

class CP0InstBuilder(_InstBuilder):
    def build(self, tags):
        if len(self.body) < 2:
            self._raise_error()
        inst = self._get_op()
        inst += mipsdef.cp0_table[self.opcode] << 21
        rt = self._get_reg(self.body[0])
        rd = self._get_reg(self.body[1])
        # get 'sel' field
        if len(self.body) >= 3:
            try:
                self._trim_body(3)
                sel = self._get_imm(self.body[2]) & 0b111
            except:
                self._trim_body(2)
                sel = 0b000
        else:
            self._trim_body(2)
            sel = 0b000
        # assembly instruction field
        inst += rt << 16
        inst += rd << 11
        inst += 0b00000000 << 3
        inst += sel
        return self._get_byte(inst)

class SingleInstBuilder(_InstBuilder):
    def build(self, tags):
        inst = self._get_op()
        if self.opcode == 'lui':
            self._trim_body(2)
            rt = self._get_reg(self.body[0])
            imm = self._get_imm(self.body[1])
            inst += 0b00000 << 21
        else:   # eret
            self._trim_body(0)
            rt = 0b00000
            imm = 0b0000000000 << 6
            imm += mipsdef.cp0_table[self.opcode]
            inst += 0b10000 << 21
        inst += rt << 16
        inst += imm
        return self._get_byte(inst)

class PsudoInstBuilder(_InstBuilder):
    def build(self, tags):
        if self.opcode == 'nop':
            self._trim_body(0)
            return self._get_byte(0x00000000)
        else:
            self._trim_body(2)
            new_body = [self.body[0], '$0', self.body[1]]
            if self.opcode == 'li':
                op = 'ori'
            elif self.opcode == 'move':
                op = 'or'
            else:   # mov
                try:
                    self._get_imm(new_body[2])
                    op = 'ori'
                except:
                    op = 'or'
            builder = ITypeInstBuilder(op, new_body, self.position)
            try:
                return builder.build(tags)
            except RuntimeError:
                self._raise_error()


class AsmGenerator(object):
    def __init__(self):
        self.__builders = [
            (mipsdef.r_type, RTypeInstBuilder),
            (mipsdef.i_type, ITypeInstBuilder),
            (mipsdef.mul_div_type, MulDivInstBuilder),
            (mipsdef.mul_div_type, MulDivInstBuilder),
            (mipsdef.shift_type, ShiftInstBuilder),
            (mipsdef.branch_type, BranchInstBuilder),
            (mipsdef.jump_type, JumpInstBuilder),
            (mipsdef.move_type, MoveInstBuilder),
            (mipsdef.trap_type, TrapInstBuilder),
            (mipsdef.mem_type, MemInstBuilder),
            (mipsdef.cp0_type, CP0InstBuilder),
            (mipsdef.single_type, SingleInstBuilder),
            (mipsdef.psudo_type, PsudoInstBuilder)
        ]
        self.__pattern = '{byte}   // {inst}'
        self.__content = []
        self.__tags = {}
        self.__undef_tags = {}

    def __append(self, byte, inst, pos=None):
        text = self.__pattern.format(byte=byte, inst=inst)
        if pos is None:
            self.__content.append(text)
        else:
            self.__content[pos] = text

    def __get_pos(self):
        return len(self.__content)

    def update(self, inst: str):
        body = re.split(r',\s*|\s+', inst.lower())
        opcode = body.pop(0)
        if not opcode or opcode.startswith('#'):
            # blank or comment
            return True
        elif opcode.endswith(':'):
            # position tag definition
            tag = opcode[:-1]
            self.__tags[tag] = self.__get_pos()
            for builder in self.__undef_tags.get(tag, []):
                byte = builder.build(self.__tags)
                self.__append(byte, builder.inst(), builder.position)
            return True
        else:
            # other instructions
            for type_list, builder in self.__builders:
                if opcode in type_list:
                    b = builder(opcode, body, self.__get_pos())
                    try:
                        self.__append(b.build(self.__tags), inst)
                    except TagUndefError as e:
                        self.__append('00 00 00 00', 'TAG UNDEF')
                        l = self.__undef_tags.get(e.tag, [])
                        l.append(b)
                        self.__undef_tags[e.tag] = l
                    return True
        return False
    
    def clear(self):
        self.__content.clear()
        self.__tags.clear()
        self.__undef_tags.clear()

    def generate(self):
        if self.__undef_tags:
            msg_list = []
            for tag, l in self.__undef_tags.values():
                text = '"%s" in ' % tag
                insts = map(lambda x: '"%s"' % x.inst(), l)
                msg_list.append(text + ', '.join(insts))
            raise RuntimeError('undefined tags: %s' % ', '.join(msg_list))
        return '\n'.join(self.__content)


if __name__ == '__main__':
    # NOTE: write test code here
    pass
