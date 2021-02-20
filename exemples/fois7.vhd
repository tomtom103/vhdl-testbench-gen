-------------------------------------------------------------------------------
--
-- module combinatoire qui multiplie le nombre en entrée par 7
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fois7 is 	 
port (
	n : in unsigned(3 downto 0);
	produit : out unsigned(6 downto 0)
);
end fois7;

architecture arch1 of fois7 is
signal produit_t : natural range 0 to 105;
begin						 
	
	with to_integer(n) select
	produit_t <=
		0 when 0,
		7 when 1,
		14 when 2,
		21 when 3,
		28 when 4,
		35 when 5,
		42 when 6,
		49 when 7,
		56 when 8,
		63 when 9,
		70 when 10,
		77 when 11,
		84 when 12,
		91 when 13,
		98 when 14,
		105 when 15,
		0 when others;
	
	produit <= to_unsigned(produit_t, produit'length);

end arch1;


-------------------------------------------------------------------------------
--
-- banc d'essai avec vérification
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity fois7_tb is 	 
end fois7_tb;

architecture arch of fois7_tb is
	
signal n_tb : unsigned(3 downto 0);
signal produit_tb : unsigned(6 downto 0);

begin

--	UUT : entity fois7(arch1) port map (n_tb, produit_tb);
    UUT : entity mul7(multiplpar7) port map (n_tb, produit_tb);
        

    process
	constant kmax : integer := 2 ** n_tb'length - 1;
	begin
		for k in 0 to kmax loop  -- application exhaustive des vecteurs de test
			n_tb <= to_unsigned(k, n_tb'length);
			wait for 10 ns;
			assert (to_integer(produit_tb) = 7 * k)
				report "erreur pour l'entrée " & integer'image(k) severity warning;
		end loop;
		report "simulation terminée" severity failure;
	end process;
	
end arch;

