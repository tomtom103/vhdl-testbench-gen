#! /usr/bin/python
# -*- coding: utf-8 -*-
import sys, os
from vhdl_types import *

def read_file(filename):
    if not os.path.isfile(filename):
        print("Error: This file  '%s' doesn't exist" %filename)
        sys.exit(1)
    
    try:
        with open(filename, 'r') as f:
            content = f.read()
        return content
    except Exception as e:
        print("Could not read the file '%s'" % filename)
        sys.exit(1)

def write_file(filename, content):
    with open(filename, 'w') as f:
        f.write(content)

def get_between(s, pref, suf):
    try:
        start = 0 if pref == "" else s.index(pref)
        end = len(s) if suf == "" else s[start:].index(suf)
        return (s[start + len(pref):start+end], end)
    except Exception:
        return("", -1)

def get_libraries(vhdl_file):
    libs = {}
    if "library" not in vhdl_file:
        return []
    
    last_pos = 0

    while True:
        value = get_between(vhdl_file[last_pos:], "library ", ";")
        ignore_line = False

        for i in range(last_pos, value[1] + len(value[0]))[::-1]:
            if vhdl_file[i] == '\n':
                break
            if vhdl_file[i] == '-' and vhdl_file[i-1] == '-':
                ignore_line = True
                break
        
        last_pos += value[1]

        if value == ("", -1):
            break
        
        lib_name = value[0].strip().lower()

        if lib_name in libs:
            break

        if not ignore_line:
            libs[lib_name] = Library(lib_name)
    
    last_pos = 0

    while True:
        value = get_between(vhdl_file[last_pos:], "use ", ";")

        ignore_line = False

        for i in range(last_pos, value[1] + len(value[0]))[::-1]:
            if vhdl_file[i] == "\n":
                break

            if vhdl_file[i] == '-' and vhdl_file[i-1] == '-':
                ignore_line = True
                break
        
        last_pos += value[1]

        if value == ("", -1):
            break

        use_statement = value[0].strip().lower().split(".")
        lib, package = use_statement[0], ".".join(use_statement[1:])

        if(lib == "work" and lib not in libs.keys()):
            libs[lib] = Library("work")

        if lib in libs.keys():
            if not ignore_line:
                libs[lib].add_package(package)
        else:
            print("Error: Using the library '%s' in package '%s.%s' without adding it" % (lib, lib, package))
            break
    return libs.values()

def get_ports(s) -> str:
    port = ""
    bracket_counter = 0
    is_counting = False
    for i in range(len(s)):
        if s[i:i+4] == "port":
            is_counting = True
        if is_counting:
            port += s[i];
            if s[i] == "(":
                bracket_counter += 1
            elif s[i] == ")":
                bracket_counter -= 1
            elif s[i] == ";" and bracket_counter == 0:
                break
    return port

def get_generics(s) -> str:
    generic = ""
    bracket_counter = 0
    is_counting = False
    for i in range(len(s)):
        if s[i:i+7] == "generic":
            is_counting = True
        if is_counting:
            generic += s[i];
            if s[i] == "(":
                bracket_counter += 1
            elif s[i] == ")":
                bracket_counter -= 1
            elif s[i] == ";" and bracket_counter == 0:
                break
    return generic

def get_entitites(vhdl_file):
    entities = []
    last_pos = 0

    while True:
        value = get_between(vhdl_file[last_pos:], "entity", " is")
        entity = Entity(value[0].strip())

        if value == ("", -1) or entity in entities:
            break
        
        last_pos += value[1]
        between_entity = get_between(vhdl_file, entity.get_name() + " is", "end ")[0].strip()
        generic_str = get_generics(between_entity)
        port_str = get_ports(between_entity)

        if generic_str != "":
            entity.set_generic_list(GenericList(generic_str))
        else: 
            print("Error: The generics defined in the entity could not be read '%s'" % entity.get_name())

        if port_str != "":
            entity.set_port_list(PortList(port_str))
        else: 
            print("Error: The ports defined in the entity could not be read '%s'" % entity.get_name())
        
        entities += [entity]
    return entities

def get_architecture_of_entity(vhdl_file, entity):
    last_pos = 0

    while True:
        value = get_between(vhdl_file[last_pos:], "architecture ", "begin")
        last_pos += value[1]
        arch_name = get_between(value[0], "", " of")[0].strip()
        ent_name = get_between(value[0], "of ", "is")[0].strip()

        if arch_name == "" or ent_name == "":
            break
        if ent_name != entity.get_name():
            continue

        arch = Architecture(arch_name, entity)
        signals = get_between(value[0], "is", "")[0].strip()

        if signals != "":
            arch.set_signal_list(SignalList(signals))
        
        return arch
    print("Error: No Architecture of the Entity was found '%s'" % entity.get_name())
    sys.exit(1)

### MAIN

if __name__ == "__main__":
    if len(sys.argv) != 2:
	    print("Error: You need to specify a .vhd file")
	    sys.exit(1)

    vhdl_filename = sys.argv[1].split('.')

    if vhdl_filename[-1] != 'vhd':
	    print("Error: The file type needs to be .vhd")
	    sys.exit(1)

	# VHDL_tb filename
    vhdl_filename = ".".join(vhdl_filename[:-1]) + '_tb.vhd'

	# VHDL content
    vhd_file = read_file(sys.argv[1])

    vhdl = VHDL()
    [vhdl.add_library(l) for l in get_libraries(vhd_file)]
    [vhdl.set_entity(e) for e in get_entitites(vhd_file)]
    print("\n\n")
    for entity in vhdl.get_entities():
        arch = get_architecture_of_entity(vhd_file, entity)
        if arch != "":
            vhdl.set_architecture(arch)
            print(arch)
            signals = arch.get_signal_list()
            for signal in signals:
                print(signals[signal])
        ports = entity.get_ports()
        generics = entity.get_generics()
        for port in ports:
            print(ports[port])
        for generic in generics:
            print(generics[generic])
        
