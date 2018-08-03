from io import BytesIO


# TODO: implement this file

class _Converter(object):
    def __init__(self):
        self.__stream = BytesIO()

    def read(self):
        return self.__stream.read()
    
    def write(self, b):
        self.__stream.write(b)

    def convert(self, path):
        raise NotImplementedError


# to *.coe file
class CoeConverter(_Converter):
    def convert(self, path):
        pass


# to file that can be read by '$readmemh'
class HexConverter(_Converter):
    def convert(self, path):
        pass


# to binary file
class BinaryConverter(_Converter):
    def convert(self, path):
        pass
