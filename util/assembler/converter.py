from io import BytesIO


# TODO: implement this file

class _Converter(object):
    def __init__(self):
        self.__stream = BytesIO()

    def read(self):
        return self.__stream.read()
    
    def write(self, path):
        with open(path, 'wb') as f:
            self.__stream.write(f)

    def convert(self):
        raise NotImplementedError


class CoeConverter(_Converter):
    def convert(self):
        pass


class HexConverter(_Converter):
    def convert(self):
        pass


class BinaryConverter(_Converter):
    def convert(self):
        pass
