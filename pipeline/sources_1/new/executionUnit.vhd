
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity executionUnit is
  Port (
    PC:in STD_LOGIC_VECTOR(15 downto 0);
    RD1:in STD_LOGIC_VECTOR(15 downto 0);
    RD2:in STD_LOGIC_VECTOR(15 downto 0);
    Ext_imm:in STD_LOGIC_VECTOR(15 downto 0);
    funct:in STD_LOGIC_VECTOR(2 downto 0);
    sa:in STD_LOGIC;
    ALU_SRC:in STD_LOGIC;
    ALU_OP:in STD_LOGIC_VECTOR(2 downto 0);     
    
    BranchAddress:out STD_LOGIC_VECTOR(15 downto 0);
    ALU_RES:out STD_LOGIC_VECTOR(15 downto 0);
    ZERO: out STD_LOGIC
    
   );
end executionUnit;

architecture Behavioral of executionUnit is

signal mux_out:STD_LOGIC_VECTOR(15 downto 0);
signal ALU_CONTROL:STD_LOGIC_VECTOR(2 downto 0);
signal alu_rezultat_aux:STD_LOGIC_VECTOR(15 downto 0);

begin

alu_src_mux:process(ALU_SRC)
    begin
        if ALU_SRC = '0' then
            mux_out <= RD2;
        else mux_out <= Ext_imm;
        end if;
end process alu_src_mux;
 
 
alu_ctrl:process(ALU_OP)
    begin
        case ALU_OP is
            when "000" => ALU_CONTROL<=funct;
                when "001" => ALU_CONTROL <= "000"; --addi,lw,sw folosim adunare
                when "010" => ALU_CONTROL <= "001"; --beq folosim scadere
                when "011" => ALU_CONTROL <= "101"; --ori
                when others => ALU_CONTROL <="000";
            end case;
end process alu_ctrl;


ALU:process(ALU_CONTROL,rd1,mux_out,sa)
begin
   case ALU_CONTROL is
         when "000" => alu_rezultat_aux <= RD1 + mux_out;
         when "001" => alu_rezultat_aux <= RD1 - mux_out;
         when "010" =>  if sa='1' then
                           alu_rezultat_aux<=RD1(14 downto 0) & '0';
                        else alu_rezultat_aux<=RD1;
                        end if;
         when "011" =>  if sa='1' then
                            alu_rezultat_aux<='0' & RD1(15 downto 1);
                        else alu_rezultat_aux<=RD1;
                        end if;
         when "100" => alu_rezultat_aux <= RD1 and mux_out;
         when "101" => alu_rezultat_aux <= RD1 or mux_out;
         when "110" => alu_rezultat_aux <= RD1 xor mux_out;
         when others => 
                    if RD1<mux_out then
                        alu_rezultat_aux <= x"0001";
                   else alu_rezultat_aux <= x"0000";
                    end if;
         end case;
             
end process ALU;

ZERO <= '1' when alu_rezultat_aux = x"0000" else '0';
ALU_RES <=alu_rezultat_aux;

BranchAddress <= PC + Ext_imm;

end Behavioral;
