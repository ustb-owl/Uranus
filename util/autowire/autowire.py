import sys
from xml.parsers.expat import ParserCreate


# define verilog file template
file_template = '''
`timescale 1ns / 1ps

module {module_name}(
{ports}
);

{wires}

{modules}

endmodule
'''.strip('\n')
port_def_template = '{direction} {type}{bus} {name}'
wire_def_template = 'wire {bus} {name}{reference};'
module_instance_template = '{module_name} {instance_name}(\n{io});'
io_connection_template = '.{port}({wire})'
template_tab_size = 4


# define verilog AST objects
class VerilogBaseAST(object):
    def __init__(self):
        self._indent = ' ' * template_tab_size

    @staticmethod
    def _generate_map(ast_list, indent):
        return map(lambda obj: obj.generate(indent), ast_list)

    def generate(self, indent=0):
        raise NotImplementedError

class VerilogFileAST(VerilogBaseAST):
    def __init__(self):
        super().__init__()
        self.module_name = ''
        self.ports = {}
        self.wires = []
        self.modules = {}

    def generate(self, indent=0):
        for wire in self.wires:
            if wire.reference:
                wire.bus = self.ports[wire.reference].bus
        ports = ',\n'.join(self._generate_map(self.ports.values(), indent + 1))
        wires = '\n'.join(self._generate_map(self.wires, indent + 1))
        modules = '\n\n'.join(self._generate_map(self.modules.values(), indent + 1))
        return file_template.format(module_name=self.module_name,
                ports=ports, wires=wires, modules=modules)

class VerilogPortAST(VerilogBaseAST):
    def __init__(self):
        super().__init__()
        self.__dir_map = {
            'in': 'input',
            'out': 'output',
            'inout': 'inout'
        }
        self.direction = ''
        self.type = ''
        self.bus = [0, 0]
        self.name = ''

    def generate(self, indent=0):
        indent_str = self._indent * indent
        bus_str = '[%d:%d]' % (self.bus[0], self.bus[1])
        return indent_str + port_def_template.format(type=self.type,
                name=self.name, direction=self.__dir_map[self.direction],
                bus=bus_str if sum(self.bus) else '').replace('  ', ' ')

class VerilogWireAST(VerilogBaseAST):
    def __init__(self):
        super().__init__()
        self.bus = []
        self.name = ''
        self.reference = ''

    def generate(self, indent=0):
        indent_str = self._indent * indent
        bus_str = ''
        if sum(self.bus):
            bus_str = '[%d:%d]' % (self.bus[0], self.bus[1])
        ref_str = ' = ' + self.reference if self.reference else ''
        return indent_str + wire_def_template.format(reference=ref_str,
                name=self.name, bus=bus_str).replace('  ', ' ')

class VerilogModuleAST(VerilogBaseAST):
    def __init__(self):
        super().__init__()
        self.module_name = ''
        self.instance_name = ''
        self.connections = []

    def generate(self, indent=0):
        indent_str = self._indent * indent
        io = ',\n'.join(self._generate_map(self.connections, indent + 1))
        io += '\n' + indent_str
        self.instance_name = self.instance_name.lower()
        return indent_str + module_instance_template.format(io=io,
                module_name=self.module_name, instance_name=self.instance_name)

class VerilogIOConnectionAST(VerilogBaseAST):
    def __init__(self):
        super().__init__()
        self.port_name = ''
        self.wire_name = ''

    def generate(self, indent=0):
        indent_str = self._indent * indent
        return indent_str + io_connection_template.format(port=self.port_name,
                wire=self.wire_name)


# define the SAX handler of block design file
class BlockDesignSaxHandler(object):
    def __init__(self):
        self.__prefix = 'spirit:'
        self.__tag_stack = []
        self.__cur_attrs = {}
        self.__file_ast = VerilogFileAST()
        self.__cur_ast = None

    def __tag_test(self, *args, back=False):
        if back:
            slice_pos = len(self.__tag_stack) - len(args)
            return self.__tag_stack[slice_pos:] == list(args)
        else:
            return self.__tag_stack[:len(args)] == list(args)

    def __attr_test(self, name, value=None):
        name = self.__prefix + name
        if not value:
            return self.__cur_attrs.get(name)
        else:
            return self.__cur_attrs[name] == value

    def start_element(self, name: str, attrs: dict):
        tag_test = self.__tag_test
        attr_test = self.__attr_test
        if name.startswith(self.__prefix):
            self.__tag_stack.append(name[len(self.__prefix):])
            self.__cur_attrs = attrs
            if tag_test('design', 'adHocConnections', 'adHocConnection'):
                if tag_test('externalPortReference', back=True):
                    self.__cur_ast.reference = attr_test('portRef')
                if tag_test('internalPortReference', back=True):
                    con_ast = VerilogIOConnectionAST()
                    con_ast.port_name = attr_test('portRef')
                    con_ast.wire_name = self.__cur_ast.name
                    mod_ref = attr_test('componentRef')
                    mod_ast = self.__file_ast.modules[mod_ref]
                    mod_ast.connections.append(con_ast)


    def end_element(self, name: str):
        tag_test = self.__tag_test
        if name.startswith(self.__prefix):
            if tag_test('component', 'model', 'ports', 'port', back=True):
                self.__file_ast.ports[self.__cur_ast.name] = self.__cur_ast
                self.__cur_ast = None
            elif tag_test('design', 'componentInstances', 'componentInstance', back=True):
                self.__file_ast.modules[self.__cur_ast.instance_name] = self.__cur_ast
                self.__cur_ast = None
            elif tag_test('design', 'adHocConnections', 'adHocConnection', back=True):
                self.__file_ast.wires.append(self.__cur_ast)
                self.__cur_ast = None
            self.__tag_stack.pop()

    def char_data(self, text: str):
        tag_test = self.__tag_test
        attr_test = self.__attr_test
        try:
            if tag_test('component', 'name'):
                self.__file_ast.module_name = text
            elif tag_test('component', 'model', 'ports', 'port'):
                self.__cur_ast = self.__cur_ast or VerilogPortAST()
                if tag_test('name', back=True):
                    self.__cur_ast.name = text
                elif tag_test('wire', 'direction', back=True):
                    self.__cur_ast.direction = text
                elif tag_test('wire', 'vector', 'left', back=True):
                    self.__cur_ast.bus[0] = int(text)
                elif tag_test('wire', 'vector', 'right', back=True):
                    self.__cur_ast.bus[1] = int(text)
            elif tag_test('design', 'componentInstances', 'componentInstance'):
                self.__cur_ast = self.__cur_ast or VerilogModuleAST()
                if tag_test('instanceName', back=True):
                    self.__cur_ast.instance_name = text
                elif tag_test('configurableElementValues',
                        'configurableElementValue', back=True):
                    if attr_test('referenceId', 'bd:referenceName'):
                        self.__cur_ast.module_name = text
            elif tag_test('design', 'adHocConnections', 'adHocConnection'):
                self.__cur_ast = self.__cur_ast or VerilogWireAST()
                if tag_test('name', back=True):
                    self.__cur_ast.name = text
        except IndexError:
            pass
    
    def generate(self):
        return self.__file_ast.generate()


def main():
    # judge the count of arguments
    if len(sys.argv) < 2:
        exit(1)

    # read arguments
    path = sys.argv[1]
    if len(sys.argv) >= 3:
        out_path = sys.argv[2]
    else:
        out_path = path[:path.rfind('.')] + '.v'

    # initialize parser
    handler = BlockDesignSaxHandler()
    parser = ParserCreate()
    parser.StartElementHandler = handler.start_element
    parser.EndElementHandler = handler.end_element
    parser.CharacterDataHandler = handler.char_data

    # parse block design file
    with open(path, 'rb') as f:
        parser.ParseFile(f)

    # output to verilog source file
    with open(out_path, 'w') as f:
        f.write(handler.generate() + '\n')

if __name__ == '__main__':
    main()
