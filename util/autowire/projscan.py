import re, os
from os.path import realpath

class Util(object):
    re_inc = re.compile(r'`include "(.*?)"')
    re_macro_def = re.compile(r'`define ([A-Za-z_][A-Za-z0-9_]*)\s+(.*)')
    re_macro = re.compile(r'(`[A-Za-z_][A-Za-z0-9_]*)')
    re_comment = re.compile(r'//.*\n')
    re_module = re.compile(r'module\s+([A-Za-z_][A-Za-z0-9_]*).*?\((.*?)\);')
    re_ports = re.compile(r'\s?(input|output|inout)\s?(reg|wire)?\s?(\[.*?\])?\s([A-Za-z_][A-Za-z0-9_]*)\s?,?\s?')
    re_space = re.compile(r'\s\s+')

    @staticmethod
    def read_file(path):
        try:
            with open(path, 'r') as f:
                return f.read()
        except UnicodeDecodeError:
            try:
                with open(path, 'r', encoding='gb2312') as f:
                    return f.read()
            except UnicodeDecodeError:
                return ''

class VerilogFileObject(object):
    def __init__(self):
        self.path = ''
        self.includes = []

    def parse_includes(self):
        base_path = self.path[:self.path.rfind('/') + 1]
        content = Util.read_file(self.path)
        self.includes.clear()
        for inc in Util.re_inc.findall(content):
            self.includes.append(realpath(base_path + inc))

class VerilogModuleObject(object):
    def __init__(self):
        self.name = ''
        self.port_def = ''
        self.ports = {}

    def parse(self, macro_man, includes):
        defs = Util.re_ports.findall(self.port_def)
        for i in defs:
            bus = i[2]
            if bus:
                macros = Util.re_macro.findall(bus)
                for m in macros:
                    bus = bus.replace(m, macro_man.get(includes, m[1:]))
                l = bus.strip('[]').split(':')
                try:
                    l[0] = eval(l[0])
                    l[1] = eval(l[1])
                except NameError:
                    l = [0, 0]
                self.ports[i[3]] = l
            else:
                self.ports[i[3]] = [0, 0]

class VerilogMacroObject(object):
    def __init__(self):
        self.path = ''
        self.macros = {}
    
    def parse(self):
        content = Util.read_file(self.path)
        for name, value in Util.re_macro_def.findall(content):
            self.macros[name] = value

class MacroManager(object):
    def __init__(self):
        self.macro_files = {}
    
    def scan_macros(self, includes):
        for inc in includes:
            if not self.macro_files.get(inc):
                macro = VerilogMacroObject()
                macro.path = inc
                macro.parse()
                self.macro_files[inc] = macro
    
    def get(self, includes, macro_name):
        for inc in includes:
            macro = self.macro_files[inc]
            value = macro.macros.get(macro_name)
            if value:
                return value
        return None

class ProjectScanner(object):
    def __init__(self):
        self.files = []
        self.modules = {}
    
    def scan(self, base_path):
        if not os.path.exists(base_path) or not os.path.isdir(base_path):
            return False
        for f in os.listdir(base_path):
            if not f.startswith('.'):
                path = base_path
                path += ('' if base_path.endswith('/') else '/') + f
                if os.path.isfile(path):
                    if f.endswith('.v'):
                        file_obj = VerilogFileObject()
                        file_obj.path = realpath(path)
                        file_obj.parse_includes()
                        self.files.append(file_obj)
                elif not self.scan(path):
                    return False
        return True
 
    def parse(self):
        macro_man = MacroManager()
        for obj in self.files:
            macro_man.scan_macros(obj.includes)
            content = Util.read_file(obj.path)
            # remove comments and newlines
            content = Util.re_comment.sub('\n', content).replace('\n', '')
            for i in Util.re_module.findall(content):
                mod_obj = VerilogModuleObject()
                mod_obj.name = i[0]
                mod_obj.port_def = Util.re_space.sub(' ', i[1])
                mod_obj.parse(macro_man, obj.includes)
                self.modules[i[0]] = mod_obj
    
    def get_bus(self, module_name, port_name):
        try:
            return self.modules[module_name].ports[port_name]
        except KeyError:
            # print(module_name, port_name)
            return None
