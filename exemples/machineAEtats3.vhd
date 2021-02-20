library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity machineAEtats3 is
    port (
        reset, CLK : in STD_LOGIC;
        x : in STD_LOGIC_VECTOR(1 downto 0);
        sortie : out unsigned(2 downto 0)
    );
end;

architecture arch of machineAEtats3 is
type type_etat is (S1, S2, S3, S4, S5);
signal etat : type_etat := S1;
begin

    sortie <= to_unsigned(type_etat'pos(etat), sortie'length);

    process(CLK, reset) is
    begin
        if (reset = '1') then
            etat <= S1;
        elsif (rising_edge(CLK)) then
            case etat is
                when S1 =>
                    if x = "01" then
                        etat <= S2;
                    elsif x = "10" then
                        etat <= S4;
                    elsif x = "11" then
                        etat <= S5;
                    end if;
                when S2 =>
                    if x = "00" then
                        etat <= S4;
                    elsif x = "11" then
                        etat <= S3;
                    end if;
                when S3 =>
                    if x = "10" then
                        etat <= S4;
                    elsif x = "11" then
                        etat <= S5;
                    end if;
                when S4 | S5 =>
                    etat <= S1;
            end case;
        end if;
    end process;
    
end;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity machineaetats_tb is
end;

architecture TB_ARCHITECTURE of machineaetats_tb is

signal reset, clk : std_logic := '0';
signal x : std_logic_vector(1 downto 0);
signal sortie : unsigned(2 downto 0);

--alias temp_tb is << signal uut.temp : std_logic_vector(4 downto 0) >> ;

type tableauSLV2 is array (natural range <>) of std_logic_vector(1 downto 0);
constant vecteurs : tableauSLV2 :=
--("11", "--", "00", "11", "--", "00", "--", "--", "XX");
("01", "00", "--", "01", "11", "10", "--", "01", "11", "11", "--", "10", "--", "11", "--", "XX");

constant periode : time := 10 ns;

begin

    reset <= '1' after 0 ns, '0' after 7 * periode / 4;
    clk <= not(clk) after periode / 2;

    -- Unit Under Test port map
    UUT : entity machineaetats3(arch) port map (reset, clk, x, sortie);
        
    process(all)
    variable compte : natural := 0;
    begin
        
        if reset = '1' then
            compte := 0;
            x <= vecteurs(compte);
        elsif rising_edge(clk) then
            compte := compte + 1;
            report "coucou : " & to_string(compte);
            if compte = vecteurs'length then
                report "simulation terminée" severity failure;
            end if;
            x <= vecteurs(compte);
--            report to_string(compte) & ": " & to_string(temp_tb);
        end if;
        
    end process;

end;



