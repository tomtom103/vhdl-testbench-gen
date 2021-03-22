# VHDL Testbench Generator for the INF3500 class

# Usage:
## How does it work:
The program currently only takes one argument, the name of the .vhd file.

To run the program, you first need to generate the ZIP file. This can be done by using the
[compile.bat](compile.bat) file.

```bash
compile.bat
```

You can then run the program just like any other python file.

Example:
```bash
python testbench.zip my_file.vhd
```
This will generate a new _tb file, which contains a basic skeleton of the TestBench

# How can I use this python program within my TCL script?

This is a bit more tricky since Vivado uses its own Python interpreter by default, and it currently doesn't work with our program.

A workaround I have found is the [following](https://forums.xilinx.com/t5/Vivado-TCL-Community/Using-Python-within-TCL-script-in-Vivado-2019-1/td-p/982047)

To do this, you need to obtain your PYTHONPATH.

I have made it relatively easy to do so with a simple [script](tcl_generator/generate_tcl.py)

To run the script:
```bash
python tcl_generator\generate_tcl.py
```

This will generate a new 'script.tcl' file.

The way this file would look if you already know your PYTHONPATH:
```tcl
unset ::env(PYTHONHOME)
unset ::env(PYTHONPATH)	 

set ::env(PYTHONPATH) "C:\\Users\\thoma\\AppData\\Local\\Programs\\Python\\Python37\\python37.zip:C:\\Users\\thoma\\AppData\\Local\\Programs\\Python\\Python37\\DLLs:C:\\Users\\thoma\\AppData\\Local\\Programs\\Python\\Python37\\lib:C:\\Users\\thoma\\AppData\\Local\\Programs\\Python\\Python37:C:\\Users\\thoma\\AppData\\Local\\Programs\\Python\\Python37\\lib\\site-packages:C:\\Users\\thoma\\AppData\\Local\\Programs\\Python\\Python37\\lib\\site-packages\\win32:C:\\Users\\thoma\\AppData\\Local\\Programs\\Python\\Python37\\lib\\site-packages\\win32\\lib:C:\\Users\\thoma\\AppData\\Local\\Programs\\Python\\Python37\\lib\\site-packages\\Pythonwin"

proc generate_testbench { fileName } {
    set output [exec python testbench.zip $fileName]
    puts $output
}			 

# Example of the proc command use
generate_testbench machineAEtats3.vhd
```

This part of the program can be copied and added into any .tcl script to generate a testbench


## Things that still need to be added:

- Automatically generate clock sensitive process
- Add code for clock and reset simulation (Frequency chosen in config)
- Add config options
- Adding code to generate exhaustive signal simulation according to signal type
- Add option to append to file instead of creating a new one

- Clean up some of the functions