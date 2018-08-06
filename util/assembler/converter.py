from io import BytesIO


class _Converter(object):
    def __init__(self):
        self._stream = BytesIO()
        # self._seg = seg

    def read(self):
        return self._stream.read()
    
    def write(self, b):
        self._stream.write(b)

    def convert(self, output_path):
        with open(output_path, 'w') as f:
            self.do_convert(f)

    # extract from convert for unittest
    def do_convert(self, f):
        raise NotImplementedError


# to *.coe file
class CoeConverter(_Converter):
    def do_convert(self, f):
        f.write('memory_initialization_radix=16;\n')
        f.write('memory_initialization_vector=\n')
        # reset to initial position
        self._stream.seek(0)
        buffer = []
        for b in self.read():
            buffer.append('{:02x}'.format(b))
            if len(buffer) == 4:
                f.write(''.join(buffer) + '\n')
                buffer.clear()

        if len(buffer) != 0:
            f.write(''.join(buffer) + '\n')
        f.write(';')


# to file that can be read by '$readmemh'
class HexConverter(_Converter):
    def do_convert(self, f):
        f.write('@00000000\n')
        self._stream.seek(0)
        buffer = []
        for b in self.read():
            buffer.append('{:02x}'.format(b))
            if len(buffer) % 16 == 0:
                f.write(' '.join(buffer) + '\n')
                buffer.clear()
        if len(buffer) != 0:
            f.write(' '.join(buffer) + '\n')


# to binary file
class BinaryConverter(_Converter):
    def do_convert(self, f):
        pass
