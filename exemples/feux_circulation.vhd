-------------------------------------------------------------------------------
--
-- contrôleur de feux de circulation
--
-- v. 1.0 2020-10-18 Pierre Langlois
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.inf3500_utilitaires_pkg.all;
use ieee.math_real.all;

entity feux_circulation_labo3 is
	generic (
		DUREE_ROUGE_PARTOUT : positive := 3; -- durée des feux rouges dans toutes les directions, en coups d'horloge
        DUREE_JAUNE : positive := 1; -- durée d'un feu jaune, en coups d'horloge
		DUREE_VERT_BOULEVARD : positive := 15; -- durée du feu vert sur le boulevard, en coups d'horloge
		DUREE_VERT_RUE : positive := 15; -- durée du feu vert sur sur la rue, en coups d'horloge
		DUREE_AUTOBUS : positive := 15; -- durée du feux blanc pour autobus, en coups d'horloge
		DUREE_PIETONS : positive := 20; -- en configuration simple, durée pendant laquelle tous les feux sont rouges pour laisser traverser les piétons
		DUREE_PRIORITE_PIETONS : positive := 20 -- en configuration avancée, durée de la période de priorité pour les piétons (silouhette blanche), en coups d'horloge
	);
	port (
		clk_1_Hz : in std_logic; -- horloge à 1 Hz
		reset : in std_logic;	-- actif haut: un '1' réinitialise la machine
        activer : in std_logic; -- commande pour activer la séquence des états
        mode_pietons : in std_logic; -- '0' mode de base (toutes directions); '1' mode avancé (une direction à la fois, avec période de priorité)

        feux_boulevard : out std_logic_vector(6 downto 0); -- feux du boulevard (autobus, rouge, jaune, vert, flèche-tout-droit, main, pieton)
        decompte_boulevard : out BCD1; -- le chiffre du décompte
        decompte_boulevard_allume : out std_logic;-- '1' s'il faut allumer le décompte, '0' sinon s'il faut l'éteindre (c'est le cas quand on affiche la silhouette de piéton)

        feux_rue : out std_logic_vector(5 downto 0); -- feux de larue (rouge, jaune, vert, flèche-tout-droit, main, pieton)
        decompte_rue : out BCD1; -- le chiffre du décompte
        decompte_rue_allume : out std_logic -- '1' s'il faut allumer le décompte, '0' sinon s'il faut l'éteindre (c'est le cas quand on affiche la silhouette de piéton)
	);
end feux_circulation_labo3;

architecture arch of feux_circulation_labo3 is

-- constantes pour l'assignation des valeurs de sortie
constant autobus : std_logic := '1';
constant rouge : std_logic_vector(3 downto 0) := "1000";
constant jaune : std_logic_vector(3 downto 0) := "0100";
constant vert : std_logic_vector(3 downto 0) := "0010";
constant fleche_tout_droit : std_logic_vector(3 downto 0) := "0001";
constant pieton : std_logic := '1';
constant main : std_logic := '1';

type type_etat is (Stop, VertBoulevard, JauneBoulevard, VertRue, JauneRue, PauseRue, PauseBoulevard, PrioriteAutobus, PausePieton, RougeVersRue, FlecheRue, FlecheBoulevard);

signal etat : type_etat := Stop;	
signal sg_compte: natural;
signal sg_compte_pieton: natural;		
signal avance_actif: std_logic := '0';

begin

    -- vérifications de base pour les valeurs des paramètres generics
    assert DUREE_PRIORITE_PIETONS <= minimum(DUREE_VERT_BOULEVARD, DUREE_VERT_RUE) report "valeur incorrecte pour DUREE_PRIORITE_PIETONS";

	-- processus pour la séquence des états
    process(all)
	variable compte : natural range 0 to maximum(DUREE_PIETONS, maximum(DUREE_VERT_RUE, DUREE_VERT_BOULEVARD)); -- bogue potentiel, il faudrait faire max(DUREE_***)
	variable compte_pieton: natural range 0 to DUREE_PRIORITE_PIETONS + DUREE_VERT_RUE + DUREE_JAUNE;
	begin
		if (reset = '1') then
			etat <= Stop;
		elsif rising_edge(clk_1_Hz) then
			case etat is 
				
                when Stop =>	   
					if mode_pietons = '1' then
						avance_actif <= '1';
					elsif mode_pietons = '0' then
						avance_actif <= '0';
					end if;
                    if activer = '1' then
                        etat <= PrioriteAutobus;
                        compte := DUREE_AUTOBUS;
                    end if;	 
				when FlecheBoulevard =>
					compte := compte - 1;  
					if avance_actif = '1' AND compte_pieton > 0 then 
						compte_pieton := compte_pieton - 1;
					end if;
					if compte = 0 then
						etat <= VertBoulevard;
						compte := DUREE_VERT_BOULEVARD;
					end if;
					
				when VertBoulevard =>
					compte := compte - 1;
					if avance_actif = '1' AND compte_pieton > 0 then 
						compte_pieton := compte_pieton - 1;
					end if;
					if compte = 0 then
						etat <= JauneBoulevard;
						compte := DUREE_JAUNE;
					end if;
					
				when JauneBoulevard =>	
					compte := compte - 1;
					if avance_actif = '1' AND compte_pieton > 0 then 
						compte_pieton := compte_pieton - 1;
					end if;
					if compte = 0 then
						etat <= PauseBoulevard;
						compte := DUREE_ROUGE_PARTOUT;
					end if;	
					
				when VertRue =>
					if avance_actif = '1' AND compte_pieton > 0 then 
						compte_pieton := compte_pieton - 1;
					end if;
					compte := compte - 1;
					if compte = 0 then
						etat <= JauneRue;
						compte := DUREE_JAUNE;
					end if;
					
				when JauneRue =>
					if avance_actif = '1' AND compte_pieton > 0 then 
						compte_pieton := compte_pieton - 1;
					end if;
					compte := compte - 1;
					if compte = 0 then
						etat <= PauseRue;
						compte := DUREE_ROUGE_PARTOUT; 
					end if;
					
				when PauseRue =>
					compte := compte - 1;  
					if mode_pietons = '1' then
						avance_actif <= '1';
					elsif mode_pietons = '0' then
						avance_actif <= '0';
					end if;
					if compte = 0 then
						etat <= PrioriteAutobus;
						compte := DUREE_AUTOBUS;
					end if;	
					
				when PauseBoulevard =>
					compte := compte - 1;  
					if mode_pietons = '1' then
						avance_actif <= '1';
					elsif mode_pietons = '0' then
						avance_actif <= '0';
					end if;
					if compte = 0 then
						if avance_actif = '1' then
							etat <= FlecheRue;
							compte := DUREE_PRIORITE_PIETONS; 
							compte_pieton := DUREE_PRIORITE_PIETONS + DUREE_VERT_RUE + DUREE_JAUNE;
						else
							etat <= PausePieton;
							compte := DUREE_PIETONS;
						end if;
					end if;	 
				
				when FlecheRue =>
				   	compte := compte - 1;  
					if avance_actif = '1' AND compte_pieton > 0 then 
						compte_pieton := compte_pieton - 1;
					end if;
					if compte = 0 then
						etat <= VertRue;
						compte := DUREE_VERT_RUE;
					end if;
					
				when PausePieton =>	   
					compte := compte - 1;
					if compte = 0 then
						etat <= RougeVersRue;
						compte := DUREE_ROUGE_PARTOUT;
					end if;
				when RougeVersRue =>
					compte := compte - 1;
					if compte = 0 then
						etat <= VertRue;
						compte := DUREE_VERT_RUE;
					end if;
				
				when PrioriteAutobus =>
					compte := compte - 1;
					if mode_pietons = '1' then
						avance_actif <= '1';
					elsif mode_pietons = '0' then
						avance_actif <= '0';
					end if;
					if compte = 0 then
						if avance_actif = '1' then
							etat <= FlecheBoulevard;
							compte := DUREE_PRIORITE_PIETONS; 
							compte_pieton := DUREE_PRIORITE_PIETONS + DUREE_VERT_BOULEVARD + DUREE_JAUNE;
						else
							etat <= VertBoulevard;
							compte := DUREE_VERT_BOULEVARD;	
						end if;	
					end if;
				when others =>
					etat <= Stop;
			end case;
		end if;
        sg_compte <= compte;
		sg_compte_pieton <= compte_pieton;
	end process; 
	
	process(etat)
	begin
    
        -- valeurs par défaut pour les décomptes
        decompte_boulevard <= to_unsigned(0, decompte_boulevard'length);
        decompte_rue <= to_unsigned(0, decompte_rue'length);
        decompte_boulevard_allume <= '1';
        decompte_rue_allume <= '1';
    
		case etat is
			
			when FlecheRue =>
				feux_boulevard <= not(autobus) & rouge & main & not(pieton);
				feux_rue <= fleche_tout_droit & not(main) & pieton;	
				decompte_rue_allume <= '0';
			
			when FlecheBoulevard =>
				feux_boulevard <= not(autobus) & fleche_tout_droit & not(main) & pieton;
				feux_rue <= rouge & main & not(pieton);
			 	decompte_boulevard_allume <= '0';
        
			when VertBoulevard =>  
				if avance_actif = '1' then
					if(sg_compte_pieton < 10) then
						decompte_boulevard_allume <= '1';
						decompte_boulevard <= to_unsigned(sg_compte_pieton, decompte_boulevard'length);
					else
						decompte_boulevard_allume <= '0';
					end if;
					feux_boulevard <= not(autobus) & vert & (main and clk_1_Hz) & not(pieton);
					feux_rue <= rouge & main & not(pieton);
				else  
					feux_boulevard <= not(autobus) & vert & main & not(pieton);
					feux_rue <= rouge & main & not(pieton);
				end if;
                
			when JauneBoulevard =>
				if avance_actif = '1' then
					if(sg_compte_pieton < 10) then
						decompte_boulevard_allume <= '1';
						decompte_boulevard <= to_unsigned(sg_compte_pieton, decompte_boulevard'length);
					else
						decompte_rue_allume <= '0';
					end if;	  
					feux_boulevard <= not(autobus) & jaune & (main and clk_1_Hz) & not(pieton);
					feux_rue <= rouge & main & not(pieton);
				else
					feux_boulevard <= not(autobus) & jaune & main & not(pieton);
					feux_rue <= rouge & main & not(pieton);
				end if;
                
            when VertRue =>
				if avance_actif = '1' then
					if(sg_compte_pieton < 10) then
						decompte_rue_allume <= '1';
						decompte_rue <= to_unsigned(sg_compte_pieton, decompte_rue'length);
					else
						decompte_rue_allume <= '0';
					end if;
					feux_boulevard <= not(autobus) & rouge & main & not(pieton);
					feux_rue <= vert & (main and clk_1_Hz) & not(pieton);
				else
					feux_boulevard <= not(autobus) & rouge & main & not(pieton);
					feux_rue <= vert & main & not(pieton);
				end if;
                
			when JauneRue =>  
				if avance_actif = '1' then
					if(sg_compte_pieton < 10) then
						decompte_rue_allume <= '1';
						decompte_rue <= to_unsigned(sg_compte_pieton, decompte_rue'length);
					else
						decompte_rue_allume <= '0';
					end if;
					feux_boulevard <= not(autobus) & rouge & main & not(pieton);
					feux_rue <= jaune & (main and clk_1_Hz) & not(pieton);
				else
					feux_boulevard <= not(autobus) & rouge & main & not(pieton);
					feux_rue <= jaune & main & not(pieton);
				end if;
                
			when Stop =>
				feux_boulevard <= not(autobus) & (rouge and clk_1_Hz) & main & not(pieton);
				feux_rue <= (rouge and clk_1_Hz) & main & not(pieton);	   
			
			when PauseRue => 
				feux_boulevard <= not(autobus) & rouge & main & not(pieton);
				feux_rue <= rouge & main & not(pieton);	
			
			when RougeVersRue =>
				feux_boulevard <= not(autobus) & rouge & main & not(pieton);
				feux_rue <= rouge & main & not(pieton);
				
			when PauseBoulevard => 
				feux_boulevard <= not(autobus) & rouge & main & not(pieton);
				feux_rue <= rouge & main & not(pieton);	  
			
			when PrioriteAutobus =>
				feux_boulevard <= autobus & rouge & main & not(pieton);
			 	feux_rue <= rouge & main & not(pieton);	
			
			when PausePieton => 		 							 
				if(sg_compte < 10) then		  
					decompte_boulevard_allume <= '1';
        			decompte_rue_allume <= '1';
					decompte_boulevard <= to_unsigned(sg_compte, decompte_boulevard'length);
					decompte_rue <= to_unsigned(sg_compte, decompte_rue'length);
					feux_boulevard <= not(autobus) & rouge & (main and clk_1_Hz) & not(pieton);
					feux_rue <= rouge & (main and clk_1_Hz) & not(pieton);
					
				else
					feux_boulevard <= not(autobus) & rouge & not(main) & pieton;
					feux_rue <= rouge & not(main) & pieton;
					decompte_boulevard_allume <= '0';
        			decompte_rue_allume <= '0';
				end if;
                
			when others =>
				feux_boulevard <= not(autobus) & (rouge and clk_1_Hz) & main & not(pieton);
				feux_rue <= (rouge and clk_1_Hz) & main & not(pieton);
                
		end case;
		
	end process;
	
end arch;