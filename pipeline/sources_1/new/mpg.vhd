library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mpg is
    Port ( clk : in STD_LOGIC;
           btnn : in STD_LOGIC;
           enable: out STD_LOGIC);
end mpg;

architecture Behavioral of mpg is

signal count: STD_LOGIC_VECTOR(31 downto 0):=x"00000000";
signal Q1:STD_LOGIC;
signal Q2:STD_LOGIC;
signal Q3:STD_LOGIC;

begin
enable<= Q2 and not(Q3);

process(clk)
begin
    if rising_edge(clk) then
        count <= count+1;
    end if;
end process;

process(clk)
begin
    if rising_edge(clk) then
       if count(15 downto 0) = "1111111111111111" then
            Q1<=btnn;
        end if;
    end if;
end process;

process(clk)
begin
    if rising_edge(clk) then
        Q2<=Q1;
        Q3<=Q2;
    end if;
end process;



end Behavioral;