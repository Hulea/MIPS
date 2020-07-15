library IEEE;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_1164.ALL;

entity blocRegistre is
  Port (
  enable: in STD_LOGIC;
  clk:in STD_LOGIC;
  ra1:in std_logic_vector(2 downto 0);
  ra2:in std_logic_vector(2 downto 0);
  wa : in std_logic_vector (2 downto 0);
  wd : in std_logic_vector (15 downto 0);
  wen: in STD_LOGIC;
  rd1:out STD_LOGIC_VECTOR(15 downto 0);
  rd2:out STD_LOGIC_VECTOR(15 downto 0)
  );
end blocRegistre;

architecture Behavioral of blocRegistre is

type reg_array is array(0 to 15) of STD_LOGIC_VECTOR(15 downto 0);
    signal reg_file:reg_array:=(x"0000",others=>x"0000");

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if wen='1' then
                if enable='1' then
                reg_file(conv_integer(wa))<=wd;
            end if;
        end if;
        end if;
    end process;
    
    
    rd1<=reg_file(conv_integer(ra1));
    rd2<=reg_file(conv_integer(ra2));
    

end Behavioral;


