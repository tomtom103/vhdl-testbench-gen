library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.all;

entity feux_circulation_labo3_tb is
	generic (
		DUREE_ROUGE_PARTOUT : positive := 3;
		DUREE_JAUNE : positive := 1;
		DUREE_VERT_BOULEVARD : positive := 15;
		DUREE_VERT_RUE : positive := 15;
		DUREE_AUTOBUS : positive := 15;
		DUREE_PIETONS : positive := 20;
		DUREE_PRIORITE_PIETONS : positive := 20
	);
end feux_circulation_labo3_tb;

architecture arch of feux_circulation_labo3_tb is

signal clk_1_Hz_tb : std_logic;
signal reset_tb : std_logic;
signal activer_tb : std_logic;
signal mode_pietons_tb : std_logic;
signal feux_boulevard_tb : std_logic_vector(6 downto 0);
signal decompte_boulevard_tb : BCD1;
signal decompte_boulevard_allume_tb : std_logic;
signal feux_rue_tb : std_logic_vector(5 downto 0);
signal decompte_rue_tb : BCD1;
signal decompte_rue_allume_tb : std_logic;

begin

	UUT: entity feux_circulation_labo3(arch)
	generic map (
		DUREE_ROUGE_PARTOUT => DUREE_ROUGE_PARTOUT_tb,
		DUREE_JAUNE => DUREE_JAUNE_tb,
		DUREE_VERT_BOULEVARD => DUREE_VERT_BOULEVARD_tb,
		DUREE_VERT_RUE => DUREE_VERT_RUE_tb,
		DUREE_AUTOBUS => DUREE_AUTOBUS_tb,
		DUREE_PIETONS => DUREE_PIETONS_tb,
		DUREE_PRIORITE_PIETONS => DUREE_PRIORITE_PIETONS_tb
	)
	port map (
		clk_1_Hz => clk_1_Hz_tb,
		reset => reset_tb,
		activer => activer_tb,
		mode_pietons => mode_pietons_tb,
		feux_boulevard => feux_boulevard_tb,
		decompte_boulevard => decompte_boulevard_tb,
		decompte_boulevard_allume => decompte_boulevard_allume_tb,
		feux_rue => feux_rue_tb,
		decompte_rue => decompte_rue_tb,
		decompte_rue_allume => decompte_rue_allume_tb
	);

	process(all)
	begin



	end process;

	
end arch;