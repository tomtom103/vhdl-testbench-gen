# The script will not work as intended if the pythonpath is not set since Vivado uses
# a custom python version by default
# To obtain the PYTHONPATH, open the CMD and run 'python'
# Once the python shell is active type the following two lines:
#	import sys
#	sys.path
# Copy the output of the array and paste it here, removing any ' ' and adding a : as a separator

# TODO: Create a small script to eventually generate this script with the right PYTHONPATH
unset ::env(PYTHONHOME)
unset ::env(PYTHONPATH)	 

set ::env(PYTHONPATH) "C:\\Users\\thoma\\AppData\\Local\\Programs\\Python\\Python37\\python37.zip:C:\\Users\\thoma\\AppData\\Local\\Programs\\Python\\Python37\\DLLs:C:\\Users\\thoma\\AppData\\Local\\Programs\\Python\\Python37\\lib:C:\\Users\\thoma\\AppData\\Local\\Programs\\Python\\Python37:C:\\Users\\thoma\\AppData\\Local\\Programs\\Python\\Python37\\lib\\site-packages:C:\\Users\\thoma\\AppData\\Local\\Programs\\Python\\Python37\\lib\\site-packages\\win32:C:\\Users\\thoma\\AppData\\Local\\Programs\\Python\\Python37\\lib\\site-packages\\win32\\lib:C:\\Users\\thoma\\AppData\\Local\\Programs\\Python\\Python37\\lib\\site-packages\\Pythonwin"

proc generate_testbench { fileName } {
    set output [exec python testbench.zip $fileName]
    puts $output
}			 

# Exemple d'utilisation de la commande
generate_testbench machineAEtats3.vhd