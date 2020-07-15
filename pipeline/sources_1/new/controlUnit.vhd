library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity controlUnit is
  Port (
    instr: in STD_LOGIC_VECTOR(2 downto 0);
    ALUOP : out STD_LOGIC_VECTOR(2 downto 0);
    RegDst: out STD_LOGIC;
    ExtOp: out STD_LOGIC;
    ALUSrc: out STD_LOGIC;
    Branch: out STD_LOGIC;
    Jump: out STD_LOGIC;
    MemWrite : out STD_LOGIC;
    MemtoReg: out STD_LOGIC;
    RegWrite: out STD_LOGIC
   );
end controlUnit;

architecture Behavioral of controlUnit is

begin

process(instr)
begin
    case instr is
        
        when "000" => ALUOP <= "000"; -- R    
                      RegDst <= '1';   
                      ExtOp <='0';   
                      ALUSrc <= '0';
                      Branch <= '0';
                      Jump <= '0';
                      MemWrite <= '0';
                      MemtoReg <= '0';
                      RegWrite <= '1';
                      
        when "001" => ALUOP <= "001";--addi
                      RegDst <= '0';
                      ExtOp <='1';
                      ALUSrc <= '1';
                      Branch <= '0';
                      Jump <= '0';
                      MemWrite <= '0';
                      MemtoReg <= '0';
                      RegWrite <= '1';
                      
        when "010" => ALUOP <= "001"; --lw
                      RegDst <= '0';
                      ExtOp <='1';
                      ALUSrc <= '1';
                      Branch <= '0';
                      Jump <= '0';
                      MemWrite <= '0';
                      MemtoReg <= '1';
                      RegWrite <= '1';
                      
        when "011" => ALUOP <= "001";-- sw
                      RegDst <= '0';
                      ExtOp <='1';
                      ALUSrc <= '1';
                      Branch <= '0';
                      Jump <= '0';
                      MemWrite <= '1';
                      MemtoReg <= '0';
                      RegWrite <= '0';
                      
        when "100" => ALUOP <= "010";-- beq
                      RegDst <= '0';
                      ExtOp <='1';
                      ALUSrc <= '0';
                      Branch <= '1';
                      Jump <= '0';
                      MemWrite <= '0';
                      MemtoReg <= '0';
                      RegWrite <= '0';
                      
        when "101" => ALUOP <= "011";-- ori
                      RegDst <= '0';
                      ExtOp <='1';
                      ALUSrc <= '1';
                      Branch <= '0';
                      Jump <= '0';
                      MemWrite <= '0';
                      MemtoReg <= '0';
                      RegWrite <= '1';
                      
        when "110" => ALUOP <= "110";-- lui
                      RegDst <= '0';
                      ExtOp <='1';
                      ALUSrc <= '1';
                      Branch <= '0';
                      Jump <= '0';
                      MemWrite <= '0';
                      MemtoReg <= '0';
                      RegWrite <= '1';
                      
        when "111" => ALUOP <= "111";-- jump
                      RegDst <= '0';
                      ExtOp <='1';
                      ALUSrc <= '0';
                      Branch <= '0';
                      Jump <= '1';
                      MemWrite <= '0';
                      MemtoReg <= '0';
                      RegWrite <= '0';
                      
    end case;
end process;


end Behavioral;
