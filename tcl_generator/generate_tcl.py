import sys

file_name = "script.tcl"

def write_to_file(filename, content):
    with open(filename, 'w') as f:
        f.write(content)

def unset_pythonpath() -> str:
    return "unset ::env(PYTHONHOME)\nunset ::env(PYTHONPATH)\n"

def set_pythonpath(string_path) -> str:
    return 'set ::env(PYTHONPATH) "{0}"\n'.format(string_path)

def generate_proc() -> str:
    return """proc generate_testbench { fileName } {
    set output [exec python testbench.zip $fileName]
    puts $output
}
    """

def main():
    pythonpath = ':'.join(sys.path[1:])

    write_to_file(file_name, unset_pythonpath() + '\n' + set_pythonpath(pythonpath) + '\n' + generate_proc())

if __name__ == '__main__':
    main()
