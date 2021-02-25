# VHDL Testbench Generator for the INF3500 class

## Usage:

```bash
python3 testbench_gen.py path/to/file.vhd
```

## Things that still need to be added:

- Automatically generate clock sensitive process
- Add code for clock and reset simulation (Frequency chosen in config)
- Add config options
- Adding code to generate exhaustive signal simulation according to signal type
- Add option to append to file instead of creating a new one

- Clean up some of the functions