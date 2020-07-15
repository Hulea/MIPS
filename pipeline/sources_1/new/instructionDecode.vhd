library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity InstructionDecode is
    Port(
        enable: in std_logic;
        clk:in STD_LOGIC;
        instr:in STD_LOGIC_VECTOR(15 downto 0);
        RegWrite: in STD_LOGIC; 
        RegDest: in STD_LOGIC;
        ExtOp: in STD_LOGIC;
        WriteData: in STD_LOGIC_VECTOR(15 downto 0);
        --WriteAddress:in STD_LOGIC_VECTOR(15 downto 0);
        
        ExtImm : out STD_LOGIC_VECTOR(15 downto 0);
        ReadData1: out STD_LOGIC_VECTOR(15 downto 0);
        ReadData2: out STD_LOGIC_VECTOR(15 downto 0);
        SA: out STD_LOGIC;
        FUNCT:out STD_LOGIC_VECTOR(2 downto 0)
        );

end InstructionDecode;

architecture Behavioral of InstructionDecode is
    
component blocRegistre is
  Port (
  enable: in std_logic;
  clk:in STD_LOGIC;
  ra1:in std_logic_vector(2 downto 0);
  ra2:in std_logic_vector(2 downto 0);
  wa : in std_logic_vector (2 downto 0);
  wd : in std_logic_vector (15 downto 0);
  wen: in STD_LOGIC;
  rd1:out STD_LOGIC_VECTOR(15 downto 0);
  rd2:out STD_LOGIC_VECTOR(15 downto 0)
  );
end component blocRegistre;


signal mux_out: STD_LOGIC_VECTOR(2 downto 0);


begin

--aux:blocRegistre port map(clk,instr(12 downto 10),instr(9 downto 7),WriteAddress,WriteData,RegWrite,ReadData1,ReadData2);
aux:blocRegistre port map(enable,clk,instr(12 downto 10),instr(9 downto 7),mux_out,WriteData,RegWrite,ReadData1,ReadData2);



SA <= instr(3);
FUNCT <= instr(2 downto 0);


mux:process(instr,RegDest)
    begin
        if(RegDest = '0') then
            mux_out <= instr(9 downto 7);
            else
            mux_out <= instr(6 downto 4);
        end if;
end process mux;

extension:process(ExtOp,instr)
    begin
        if ExtOp = '0' then
            ExtImm <= instr(6 downto 0)&"000000000";
        else 
            if instr(6) = '1' then
                ExtImm<="111111111"&instr(6 downto 0);
            else
                ExtImm<="000000000"&instr(6 downto 0);
            end if;
         end if;
 end process extension;


end Behavioral;