import mipsdef, re
from mipsinst import *
from enum import Enum, unique
from seg_def import Segment

# TODO: implement this class
class SegmentManager(object):
    def __init__(self):
        self.cur_seg = Segment.Data
        self.rom = []
        self.ram = []

    def switch(self, segment: str):
        if segment.lower() == '.text':
            self.cur_seg = Segment.Text
        elif segment.lower() == '.text':
            self.cur_seg = Segment.Data
        else:
            raise RuntimeError('unknown segment: ' + segment)
    
    pass


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
            (mipsdef.pseudo_type, PseudoInstBuilder)
        ]
        self.__pattern = '{byte}   // {inst}'
        self.__content = []
        self.__ram = []
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
            unfilled = self.__undef_tags.get(tag)
            if unfilled:
                for builder in unfilled:
                    byte = builder.build(self.__tags)
                    self.__append(byte, builder.inst(), builder.position)
                self.__undef_tags.pop(tag)
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
                    except PseudoError as e:
                        self.__append(e.byte0, e.inst)
                        self.__append(e.byte1, '(pseudo-inst ext)')
                    return True
        return False
    
    def clear(self):
        self.__content.clear()
        self.__tags.clear()
        self.__undef_tags.clear()

    def generate(self):
        if self.__undef_tags:
            msg_list = []
            for tag, l in self.__undef_tags.items():
                text = '"%s" in ' % tag
                insts = map(lambda x: '"%s"' % x.inst(), l)
                msg_list.append(text + ', '.join(insts))
            raise RuntimeError('undefined tags: %s' % ', '.join(msg_list))
        return '\n'.join(self.__content)

