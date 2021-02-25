library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity machineAEtats3_tb is
end machineAEtats3_tb;

architecture arch of machineAEtats3_tb is

signal reset_tb : STD_LOGIC;
signal CLK_tb : STD_LOGIC;
signal x_tb : STD_LOGIC_VECTOR(1 downto 0);
signal sortie_tb : unsigned(2 downto 0);

begin

	UUT: entity machineAEtats3(arch)
	port map (
		reset => reset_tb,
		CLK => CLK_tb,
		x => x_tb,
		sortie => sortie_tb
	);

	process(all)
	begin



	end process;

	
end arch;