"""
VHDL Classes

"""
import re

class VHDL(object):
    def __init__(self) -> None:
        self.libs = []
        self.entities = {}
        self.archs = {}
    
    def set_entity(self, ent):
        if isinstance(ent, Entity):
            self.entities[ent.get_name()] = ent
    
    def get_entities(self):
        return self.entities.values()
    
    def get_entity_by_name(self, ent_name):
        if ent_name in self.entities.keys():
            return self.entities[ent_name]
        return False
    
    def set_architecture(self, arch):
        if isinstance(arch, Architecture):
            self.archs[arch.get_name()] = arch
    
    def get_architectures(self):
        return self.archs.values()
    
    def get_architecture_by_name(self, arch_name):
        if arch_name in self.archs.keys():
            return self.archs[arch_name]
        return False
    
    def add_library(self, lib) -> bool:
        if isinstance(lib, Library):
            if lib not in self.libs:
                self.libs += [lib]
                return True
        return False
    
    def remove_library(self, lib) -> bool:
        try:
            self.libs.remove(lib)
            return True
        except Exception:
            return False
    
    def get_libs(self) -> list:
        return self.libs

    def __str__(self) -> str:
        return "\n".join([str(l) for l in self.libs])

class Library(object):
    def __init__(self, value) -> None:
        self.lib = value
        self.packages = []
    
    def add_package(self, package_name):
        if self.lib + "." + package_name not in self.packages:
            self.packages += [self.lib + "." + package_name]
    
    def get_packages(self):
        return self.packages
    
    def get_name(self):
        return self.lib

    def __eq__(self, o: object) -> bool:
        if isinstance(o, Library):
            return self.lib == o.get_name()
        return False
    
    def __str__(self) -> str:
        return "<Library %s>" % self.lib

class Entity(object):
    def __init__(self, name) -> None:
        self.name = name
        self.port = {}
        self.generic = {}

    def get_name(self):
        return self.name

    def set_generic_list(self, g):
        if isinstance(g, GenericList):
            self.generic = g.get_generics()
            return True
        return False

    def get_generics(self):
        return self.generic

    def set_port_list(self, p):
        if isinstance(p, PortList):
            self.port = p.get_ports()
            return True
        return False
    
    def get_ports(self):
        return self.port

    def __str__(self) -> str:
        return "<Entity %s>" % self.name

    def __eq__(self, o: object) -> bool:
        return self.name == o.get_name() if isinstance(o, Entity) else False

class Signal(object):
    obj_name = "signal"
    name = ""
    type = ""
    value = ""

    def __init__(self, name, type) -> None:
        self.set_name(name)
        self.set_type(type)
    
    def get_name(self):
        return self.name
    
    def set_name(self, name):
        if isinstance(name, str):
            self.name = name
        else:
            print("Error: The name '%s' has to be a string" % self.obj_name)
    
    def set_value(self, val):
        self.value = val
    
    def get_value(self):
        return self.value
    
    def get_type(self):
        return self.type
    
    def set_type(self, t):
        if isinstance(t, str):
            self.type = t
        else:
            print("Error: The type '%s' has to be a string" % self.obj_name)

    def __eq__(self, o: object) -> bool:
        if isinstance(o, Signal):
            return self.name == o.get_name() and self.type == o.get_type()
        return False
    
    def __str__(self) -> str:
        if self.value == "":
            return "<%s %s : %s>" % (self.obj_name.capitalize(), self.name, self.type)
        else:
            return "<%s %s : %s := %s>" % (self.obj_name.capitalize(), self.name, self.type, self.value)

class SignalList(object):
    def __init__(self, signal_str) -> None:
        self.signals = self.get_signal_from_string(signal_str.strip())
    
    def get_signals(self):
        return self.signals
    
    def get_signal_from_string(self, s):
        signals = {}
        try:
            no_comments = re.sub(r"([-\-$])(.*)", "", s)
            signal = no_comments.strip()[1:].replace("\n", "").replace("\t", "")
            for sig in signal.split(";"):
                sig = sig.strip()
                if sig == "":
                    break
                is_signal_with_assignation = ":=" in sig
                if is_signal_with_assignation:
                    left, assignation = sig.split(":=")
                else:
                    left = sig
                if ":" not in left:
                    print("Attention, the following line has been ignored : %s" % left.strip())
                    continue
                port_prefix, t = left.strip().split(":")
                port_prefix = port_prefix.strip()
                for i in range(len(port_prefix)):
                    if port_prefix[i] == " ":
                        variable_type = port_prefix[:i].strip()
                        port_prefix = port_prefix[i+1:].strip()
                        break
                else:
                    print("The following signal is invalid: %s", sig)
                    return signals
                if variable_type == "type" or variable_type == "constant":
                    continue
                t = t.strip()
                if "," in port_prefix:
                    for n in port_prefix.split(","):
                        n = n.strip();
                        sig = Signal(n, t)
                        if is_signal_with_assignation:
                            sig.set_value(assignation)
                        signals[n] = sig
                else:
                    sig = Signal(port_prefix, t)
                    if is_signal_with_assignation:
                        sig.set_value(assignation)
                    signals[port_prefix] = sig
        except Exception as e:
            print("Error: Cannot read the 'signal' : %s" % e)
        return signals

class Port(Signal):
    obj_name = "port"
    port_type = "in"

    def __init__(self, name, port_type, t) -> None:
        Signal.__init__(self, name, t)
        self.set_port_type(port_type)

    def set_port_type(self, t):
        if t in ["in", "out", "inout", "buffer", "linkage"]:
            self.port_type = t
        else:
            print("Error: '%s' is an invalid port_type for %s '%s'" % (str(t), self.obj_name, self.name))
    
    def get_port_type(self):
        return self.port_type
    
    def __str__(self) -> str:
        return "<%s %s : %s %s>" % (self.obj_name.capitalize(), self.name, self.port_type, self.type)

    def __eq__(self, o: object) -> bool:
        if isinstance(o, Port):
            return self.name == o.get_name() and self.type == o.get_type() and self.port_type == o.get_port_type()
        return False

class PortList(object):
    def __init__(self, port_str) -> None:
        self.ports = self.get_port_from_string(port_str.strip())
        if self.ports == None:
            self.ports = {}
    
    def get_ports(self):
        return self.ports
    
    def get_port_from_string(self, s):
        ports = {}
        counting = False
        skip_times, bracket_count = 0, 0
        between_port = ""
        for i in range(len(s)):
            if skip_times > 0:
                skip_times -= 1
                continue
            elif s[i:i+4] == "port":
                counting = True
                skip_times = 3
                continue
            elif s[i] == "(":
                bracket_count += 1
            elif s[i] == ")":
                bracket_count -= 1
                if bracket_count == 0:
                    break
            if counting:
                between_port += s[i]
        
        try:
            no_comments = re.sub(r"([-\-$])(.*)", "", between_port)
            port = no_comments.strip()[1:].replace("\n", "").replace("\t", "")
            for p in port.split(";"):
                port_name, t = p.split(":")
                port_name = port_name.strip()
                t = t.strip()
                for i in range(len(t)):
                    if t[i] == " ":
                        port_type = t[:i].strip()
                        variable_type = t[i+1:].strip()
                        break
                if "," in port_name:
                    for n in port_name.split(","):
                        n = n.strip()
                        ports[n] = Port(n, port_type, variable_type)
                else:
                    ports[port_name] = Port(port_name, port_type, variable_type)
        except Exception as e:
            print("Error: Seems like the port format isn't good")
        return ports

class Generic(Signal):
    obj_name = "generic"
    value = ""

    def __init__(self, name, t, value) -> None:
        super().__init__(name, t)
        self.value = value
    
    def set_value(self, value):
        self.value = value

    def get_value(self):
        return self.value

    def __str__(self) -> str:
        return "<%s %s : %s := %s>" % (self.obj_name.capitalize(), self.name, self.type, self.value)

    def __eq__(self, o: object) -> bool:
        if isinstance(o, Generic):
            return self.name == o.get_name() and self.type == o.get_type() and self.value == o.get_value()
        return False

class GenericList(object):
    def __init__(self, generic_str) -> None:
        self.generics = self.get_generics_from_string(generic_str.strip())
        if self.generics == None:
            self.generics = {}
    
    def get_generics(self):
        return self.generics

    def get_generics_from_string(self, s):
        generics = {}
        counting = False
        skip_times, bracket_count = 0, 0
        between_generics = ""
        for i in range(len(s)):
            if skip_times > 0:
                skip_times -= 1
                continue
            elif s[i:i+7] == "generic":
                counting = True
                skip_times = 6
                continue
            elif s[i] == "(":
                bracket_count += 1
            elif s[i] == ")":
                bracket_count -= 1
                if bracket_count == 0:
                    break
            if counting:
                between_generics += s[i]

        try:
            no_comments = re.sub(r"([-\-$])(.*)", "", between_generics)
            generic = no_comments.strip()[1:].replace("\n", "").replace("\t", "")
            for g in generic.split(";"):
                value = ""
                generic_name, right = g.split(" : ")
                generic_name = generic_name.strip()
                right = right.strip()
                if ":=" in right:
                    t, value = right.split(":=")
                else:
                    t = right
                t = t.strip()
                value = value.strip()
                if "," in generic_name:
                    for n in generic_name.split(","):
                        n = n.strip()
                        generics[n] = Generic(generic_name, t, value)
                else:
                    generics[generic_name] = Generic(generic_name, t, value)
        except Exception as e:
            print("Error: Seems like the generic format isn't good")
        return generics

class Architecture(object):
    begin = ""
    name = ""
    arch_of = ""

    def __init__(self, name, ent) -> None:
        if isinstance(name, str):
            self.name = name
        else:
            print("Error: This architecture has an invalid name")
        if isinstance(ent, Entity):
            self.arch_of = ent
        else:
            print("Error: This architecture '%s' as an invalid entity" % self.name)
    
    def get_name(self):
        return self.name
    
    def get_entity(self):
        return self.arch_of
    
    def set_signal_list(self, sl):
        if isinstance(sl, SignalList):
            self.signals = sl.get_signals()
            return True
        return False
    
    def get_signal_list(self):
        return self.signals

    def __str__(self) -> str:
        return "<Architecture %s of %s>" % (self.name, self.arch_of.get_name())