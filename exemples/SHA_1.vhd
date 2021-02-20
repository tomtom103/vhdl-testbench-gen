-------------------------------------------------------------------------------
--
-- SHA_1.vhd
--
-- v. 1.0 2020-10-30 Pierre Langlois
-- version à compléter, labo #4 INF3500, automne 2020
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.SHA_1_utilitaires_pkg.all;

entity SHA_1 is  
	port (
		clk, reset : in std_logic;
        bloc : in bloc_type;            -- le bloc à traiter, 16 mots de 32 bits
        charge_et_go : in std_logic;    -- '1' indique qu'il faut charger le bloc à traiter et débuter les calculs
        empreinte : out empreinte_type; -- empreinte numérique (= haché, valeur de hachage, message digest, digest, hash)
        fini : out std_logic            -- '0' pendant le traitement, '1' quand on a terminé le traitement du bloc, que l'empreinte est valide et qu'on est prêts à recommencer
	);
end SHA_1;

architecture iterative of SHA_1 is

signal W : bloc_type;                   -- mémoire circulaire de 16 registres de 32 mots pour le bloc et son expansion
signal A, B, C, D, E : mot32bits;       -- 5 tampons A, B, C, D, E utilisés pour 80 étapes du traitement d'un bloc
signal t : natural range 0 to 80;       -- le compteur d'étapes, 80 étapes pour traiter un bloc

begin

    process(all)
    begin
        if reset = '1' then
            t <= 80;
			fini <= '1';
        elsif rising_edge(clk) then
            -- votre code ici	
			if(t = 80) then
				fini <= '1';
				empreinte <= (A + H0_init) & (B + H1_init) & (C + H2_init) & (D + H3_init) & (E + H4_init);
				if (charge_et_go = '1') then
					A <= H0_init;
					B <= H1_init;
					C <= H2_init;
					D <= H3_init;
					E <= H4_init;
					W <= bloc;
					t <= 0;
					fini <= '0';
					
				end if;
			else
				if (t >= 15) then
					W((t + 1) MOD 16) <= rotate_left(W((t + 14) MOD 16)	xor W((t + 9) mod 16) xor W((t + 3) mod 16) xor W((t + 1) mod 16), 1);
				end if;	 
				
				A <= rotate_left(A, 5) + f(B, C, D, t) + E + W(t mod 16) + k(t);
				B <= A;
				C <= rotate_left(B, 30);
				D <= C;
				E <= D;		
				
				t <= t + 1;
			end if;
        end if;
    end process;

end iterative;