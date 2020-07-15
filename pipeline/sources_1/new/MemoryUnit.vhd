
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MemoryUnit is
  Port (
    en: in std_logic;
    CLK:in STD_LOGIC;
    MEM_WRITE:in STD_LOGIC; -- adica enable
    ALU_RES:in STD_LOGIC_VECTOR(15 downto 0); --adresa
    RD2:in STD_LOGIC_VECTOR(15 downto 0); -- datele pe care le scriem
    enable:in STD_LOGIC;
    
    MEM_DATA:out STD_LOGIC_VECTOR(15 downto 0);
    ALU_RES_OUT:out STD_LOGIC_VECTOR(15 downto 0)
    
   );
end MemoryUnit;

architecture Behavioral of MemoryUnit is

type ram_type is array(0 to 255) of STD_LOGIC_VECTOR(15 downto 0);
--signal RAM: ram_type:=(x"0001",x"0002",x"0003",x"0004",x"0005",x"0006",x"0007",x"0008",x"0009",x"0010",others=>x"1000");
    signal RAM: ram_type:=(x"0001",others=>x"0001");

begin

ALU_RES_OUT <= ALU_RES;
MEM_DATA<=RAM(conv_integer(ALU_RES(7 downto 0)));

process(clk)
    begin
        if rising_edge(clk) then
            if MEM_WRITE = '1' then
                    if en ='1' then
                    RAM(conv_integer(ALU_RES(7 downto 0))) <= RD2;
                end if;
            end if;
        end if;
end process;


end Behavioral;
