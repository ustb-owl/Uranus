import sys
from xml.parsers.expat import ParserCreate

from sax import BlockDesignSaxHandler
from projscan import ProjectScanner

'''
usage:
    $ python3 autowire.py project_base_path bd_file [output]
'''

def main():
    # judge the count of arguments
    if len(sys.argv) < 3:
        print('invalid argument')
        exit(1)

    # read arguments
    base_path = sys.argv[1]
    path = sys.argv[2]
    if len(sys.argv) >= 4:
        out_path = sys.argv[3]
    else:
        out_path = path[:path.rfind('.')] + '.v'

    # initialize project scanner
    scanner = ProjectScanner()
    if not scanner.scan(base_path):
        print('bad project base path')
        exit(1)
    scanner.parse()

    # initialize SAX handler
    handler = BlockDesignSaxHandler()
    handler.scanner = scanner

    # initialize parser
    parser = ParserCreate()
    parser.StartElementHandler = handler.start_element
    parser.EndElementHandler = handler.end_element
    parser.CharacterDataHandler = handler.char_data

    # parse block design file
    with open(path, 'rb') as f:
        parser.ParseFile(f)

    # output to verilog source file
    with open(out_path, 'w') as f:
        bd_name = path[path.rfind('/') + 1:]
        f.write(handler.generate(bd_name))

if __name__ == '__main__':
    main()
