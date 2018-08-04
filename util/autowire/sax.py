from verilog_ast import *

# define the SAX handler of block design file
class BlockDesignSaxHandler(object):
    def __init__(self):
        self.__prefix = 'spirit:'
        self.__tag_stack = []
        self.__cur_attrs = {}
        self.__file_ast = VerilogFileAST()
        self.__cur_ast = None
        self.scanner = None

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
                    port_name = attr_test('portRef')
                    if self.__file_ast.ports[port_name].direction == 'in':
                        self.__cur_ast.reference = port_name
                    else:   # out & inout
                        assign = VerilogAssignAST()
                        assign.name = port_name
                        assign.reference = self.__cur_ast.name
                        self.__file_ast.assigns.append(assign)
                if tag_test('internalPortReference', back=True):
                    con_ast = VerilogIOConnectionAST()
                    con_ast.port_name = attr_test('portRef')
                    con_ast.wire_name = self.__cur_ast.name
                    mod_ref = attr_test('componentRef')
                    mod_ast = self.__file_ast.modules[mod_ref]
                    mod_ast.connections.append(con_ast)
                    bus = self.scanner.get_bus(mod_ast.module_name, con_ast.port_name)
                    if self.__cur_ast.bus != bus:
                        self.__cur_ast.bus = bus


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
                        # TODO: an inappropriate implementation
                        if not self.__cur_ast.module_name:
                            self.__cur_ast.module_name = text
                        else:
                            self.__cur_ast.module_name += text
            elif tag_test('design', 'adHocConnections', 'adHocConnection'):
                self.__cur_ast = self.__cur_ast or VerilogWireAST()
                if tag_test('name', back=True):
                    # TODO: an inappropriate implementation
                    if not self.__cur_ast.name:
                        self.__cur_ast.name = text.lower()
                    else:
                        self.__cur_ast.name += text.lower()
        except IndexError:
            pass
    
    def generate(self, bd_name):
        content = self.__file_ast.generate()
        return content.format(bd_name=bd_name)
