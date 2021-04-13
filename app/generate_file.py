from vhdl_types import vhdl

"""
FUNCTIONS USED TO WRITE TESTBENCH TO FILE
"""

def generate_library():
    libs, uses = [], []
    for l in vhdl.get_libs():
        if(l.get_name() != "work"):
            libs += ['library %s;\n' % l.get_name()]
        for p in l.get_packages():
            if "work" not in p:
                uses += ['use %s;' % p]
    uses += ['use work.all;']
    return "%s%s\n\n" % ("\n".join(libs), "\n".join(uses))

def generate_entity():
    result = ""
    for a in vhdl.get_architectures():
        entity = a.get_entity()
        result += 'entity %s_tb is\n' % entity.get_name()
        if entity.get_generics():
            result += "\tgeneric (\n"
            for g in entity.get_generics().values():
                result += '\t\t{0}_TB : {1} := {2};\n'.format(g.get_name(), g.get_type(), g.get_value())
            result = result[:-2] + "\n\t);\n"
        result += "end %s_tb;\n\n" % entity.get_name()
    return result

def generate_architecture():
    result = ""
    for architecture in vhdl.get_architectures():
        entity = architecture.get_entity()
        if(vhdl.has_clk):
            result += generate_constant_period() + "\n\n"
        result += "architecture arch of %s_tb is\n\n" % (entity.get_name())
        result += generate_uut_signals() + generate_uut() + generate_process()
        result += '\t\nend arch;'
    return result

def generate_process():
    result = "\n\tprocess(all)\n\tbegin\n\n"
    if vhdl.has_clk:
        result += "\t\t" + generate_async_clk()
    result += "\n\n\tend process;\n\n"
    return result

def generate_ports() -> str:
    result = "\tport ("
    for arch in vhdl.get_architectures():
        ent = arch.get_entity()
        ports = ["\t{0} : {1} {2};\n".format(p.get_name(), p.get_port_type(), p.get_type()) for p in ent.get_ports().values()]
        result += "\t\t".join(ports)[:-2] + ');\n\tend component;'
    return result

def generate_uut_signals() -> str:
    result = ""
    for arch in vhdl.get_architectures():
        e = arch.get_entity()
        result += '\n'.join(['signal %s_tb : %s;' % (p.get_name(), p.get_type()) for p in e.get_ports().values()])
        result += '\n\nbegin\n\n'
    return result

def generate_constant_period() -> str:
    result = ""
    if vhdl.has_clk:
        clk_freq = vhdl.clk_freq 
        half_period = (1 / clk_freq) / 2. * 10**9
        result = "constant demi_periode: time := {0} ns".format(half_period)
    return result


def generate_uut() -> str:
    result = ""
    for architecture in vhdl.get_architectures():
        entity = architecture.get_entity()

        result += '\tUUT: entity %s(%s)\n' % (entity.get_name(), architecture.get_name())
        if entity.get_generics():
            result += '\tgeneric map (\n'
            for g in entity.get_generics().values():
                result += '\t\t%s => %s_TB,\n' % (g.get_name(), g.get_name())
            result = result[:-2] + "\n\t)\n"
        result += '\tport map (\n'
        for p in entity.get_ports().values():
            result += '\t\t%s => %s_tb,\n' % (p.get_name(), p.get_name())
        result = result[:-2] + "\n\t);\n"
    return result

def generate_async_clk() -> str:
    return "clk <= not clk after demi_periode;"
