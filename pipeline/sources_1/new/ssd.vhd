library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity SSD is
    Port(
    clk: in STD_LOGIC;
    --enable: in STD_LOGIC;
    digit3: in STD_LOGIC_VECTOR(3 downto 0);
    digit2: in STD_LOGIC_VECTOR(3 downto 0);
    digit1: in STD_LOGIC_VECTOR(3 downto 0);
    digit0: in STD_LOGIC_VECTOR(3 downto 0);
    cat: out STD_LOGIC_VECTOR(6 downto 0);
    an: out STD_LOGIC_VECTOR(3 downto 0)
    );
    
end SSD;

architecture Behavioral of SSD is

signal out_mux_1: STD_LOGIC_VECTOR(3 downto 0);
signal selec: STD_LOGIC_VECTOR(1 downto 0);
signal nr: STD_LOGIC_VECTOR(15 downto 0):=x"0000";
signal aux0:STD_LOGIC_VECTOR(3 downto 0):="1110";
signal aux1:STD_LOGIC_VECTOR(3 downto 0):="1101";
signal aux2:STD_LOGIC_VECTOR(3 downto 0):="1011";
signal aux3:STD_LOGIC_VECTOR(3 downto 0):="0111";


begin

selec(1)<=nr(15);
selec(0)<=nr(14);


mux_sus:process(selec,digit0,digit1,digit2,digit3)
begin
    case selec is
        when "00" => out_mux_1 <= digit0;
        when "01" => out_mux_1 <= digit1;
        when "10" => out_mux_1 <= digit2;
      when others => out_mux_1 <= digit3;
    end case;
 end process mux_sus;
      
mux_jos: process(selec,aux0,aux1,aux2,aux3)
begin
    case selec is
        when "00" => an <= aux0;
        when "01" => an <= aux1;
        when "10" => an <= aux2;
      when others => an <= aux3;
    end case;
 end process mux_jos;


numarator: process(clk)
begin
    if rising_edge(clk) then
       -- if enable='1' then
        nr<=nr+1;
        --end if;
    end if;
end process numarator;


hex_to_7seg: process(out_mux_1)
begin
    case out_mux_1 is
        when "0000" => cat <= "1000000";
        when "0001" => cat <= "1111001";
        when "0010" => cat <= "0100100";
        when "0011" => cat <= "0110000";
        when "0100" => cat <= "0011001";
        when "0101" => cat <= "0010010";
        when "0110" => cat <= "0000010";
        when "0111" => cat <= "1111000";
        when "1000" => cat <= "0000000";
        when "1001" => cat <= "0010000";
        when "1010" => cat <= "0001000";
        when "1011" => cat <= "0000011";
        when "1100" => cat <= "1000110";
        when "1101" => cat <= "0100001";
        when "1110" => cat <= "0000110";
        when "1111" => cat <= "0001110";
        when others => cat <= "1000000";
     end case;
end process;

end Behavioral;