# file vhdl_tb_gen/__main__.py
import sys
import os
import traceback
from file_parser import read_file, get_libraries, get_entitites, get_architecture_of_entity, write_file
from vhdl_types import vhdl
from generate_file import generate_library, generate_entity, generate_architecture

def main():
    if len(sys.argv) != 2:
	    print("Error: You need to specify a .vhd file")
	    sys.exit(1)
    vhdl_filename = sys.argv[1].split('.')

    if vhdl_filename[-1] != 'vhd':
	    print("Error: The file type needs to be .vhd")
	    sys.exit(1)
    
    files = [f for f in os.listdir('.')]
    print(files)

	# VHDL_tb filename
    vhdl_filename = ".".join(vhdl_filename[:-1]) + '_tb.vhd'

	# VHDL content
    vhd_file = read_file(sys.argv[1])

    [vhdl.add_library(l) for l in get_libraries(vhd_file)]
    [vhdl.set_entity(e) for e in get_entitites(vhd_file)]
    
    for entity in vhdl.get_entities():
        arch = get_architecture_of_entity(vhd_file, entity)
        if arch != "":
            vhdl.set_architecture(arch)
    
    try:
        write_file(vhdl_filename, generate_library() + generate_entity() + generate_architecture())
    except Exception as e:
        traceback.print_exc()
        print("ERROR: Could not write to file '%s'" % vhdl_filename)

if __name__ == '__main__':
    main()