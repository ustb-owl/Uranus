import mipsdef


# exception definitions
class TagUndefError(Exception):
    def __init__(self, tag):
        super().__init__()
        self.tag = tag

class PseudoError(Exception):
    def __init__(self, byte0, byte1, inst):
        super().__init__()
        self.byte0 = byte0
        self.byte1 = byte1
        self.inst = inst


# class definitions
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
                imm &= 0xffff
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

class PseudoInstBuilder(_InstBuilder):
    def build(self, tags):
        if self.opcode == 'nop':
            self._trim_body(0)
            return self._get_byte(0x00000000)
        else:
            self._trim_body(2)
            new_body = [self.body[0], '$0', self.body[1]]
            if self.opcode == 'move':
                b = RTypeInstBuilder('or', new_body, self.position)
                try:
                    return b.build(tags)
                except RuntimeError:
                    self._raise_error()
            else:   # li & la
                # try to get immediate or value of tag
                try:
                    imm = eval(self.body[1])
                    if not isinstance(imm, int):
                        self._raise_error()
                except:
                    imm = tags.get(self.body[1])
                    if imm is None:
                        # NOTE: 'la' & 'li' can only recognize tags before
                        #       current instruction, so '.data' must in front
                        #       of the '.text' segment
                        self._raise_error()
                # get the low & high part of immediate
                imm_lo = imm & 0x0000ffff
                imm_hi = (imm & 0xffff0000) >> 16
                # get the bytes of instruction
                try:
                    new_body[2] = str(imm_lo)
                    new_body[1] = new_body[0]
                    b = ITypeInstBuilder('ori', new_body, self.position)
                    lo_inst = b.build(tags)
                    new_body[1] = str(imm_hi)
                    b = SingleInstBuilder('lui', new_body, self.position)
                    hi_inst = b.build(tags)
                except RuntimeError:
                    self._raise_error()
                raise PseudoError(hi_inst, lo_inst, self.inst())
