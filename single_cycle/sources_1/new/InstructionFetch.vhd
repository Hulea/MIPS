library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity InstructionFetch is
  Port (
  we:in STD_LOGIC;
  clk:in STD_LOGIC;
  
  jump_address:in STD_LOGIC_VECTOR(15 downto 0);
  branch_address:in STD_LOGIC_VECTOR(15 downto 0);
  
  PCSrc:in STD_LOGIC;
  jump:in STD_LOGIC;
  
  reset:in STD_LOGIC;
  PCout:out STD_LOGIC_VECTOR(15 downto 0);
  instruction: out STD_LOGIC_VECTOR(15 downto 0)
 
   );
end InstructionFetch;



architecture Behavioral of InstructionFetch is

type rom_type is array(0 to 256) of std_logic_vector(15 downto 0);

signal ROM: rom_type:=( B"001_000_010_0000010", --0 addi $s2,$s0,3 2081
                        B"001_000_001_0000011", --0 addi $s1,$s0,2 2081
                        B"000_001_010_010_0_001", --13 sub $s2,$s1,$s2 0521
                        --
                        B"001_000_001_0000001", --0 addi $s1,$s0,1 2081
                        --B"001_000_010_1111111", --1 addi $s2,$s0,-1 217F
                        B"001_000_010_0000001", --addi $s2,$s0,1
                        B"001_000_011_0000001", --2 addi $s3,$s0,a 2181
                        B"001_000_100_0000100", --3 addi $s4,$s0,b 2204 
                        B"001_000_101_0000000", --4 addi $s5,$s0,0 2280
                        B"001_000_111_0000001", --5 addi $s7,$s0,1 2381
                        B"001_000_110_0000000", --6 addi $s6,$s0,0 2300
                        B"000_100_001_110_0_111", --7 slt $s6,$s4,$s1 10E7
                        B"100_110_111_0001010", --8 beq $s6,$s7,verif_prim=19 9b93
                        B"001_000_110_0000000", --9 addi $s6,$s0,0 2300
                        B"000_011_001_110_0_111", --10 slt $s6,$s3,$s1 0CE7
                        B"100_110_111_0000011", --11 beq $s6,$s7,add_to_sum=15 (+3) 9B8F
                        B"000_001_010_001_0_000", --12 add $s1,$s1,$s2 0510
                        B"000_001_010_010_0_001", --13 sub $s2,$s1,$s2 0521
                        B"111_0000000000110", -- 14 j loop=6 E006
                        B"000_001_010_001_0_000", --15 add $s1,$s1,$s2 0510 
                        B"000_001_010_010_0_001", --16 sub $s2,$s1,$s2 0521
                        B"000_101_001_101_0_000", --17 add $s5,$s5,$s2 14D0
                        B"111_0000000000110", --18 j loop=6 E006
                        B"001_000_001_0000001", --19 addi $s1,$s0,1 2081
                        B"001_000_010_0000000", --20 addi $s2,$s0,0 2100
                        B"001_000_100_0000000", --21 addi $s4,$s0,0 2200
                        B"001_000_111_0000001", --22 addi $s7,$s0,1 2381
                        B"100_101_001_0001001", --23 beq $s5,$s1,nu_e_prim=33 94A1
                        B"001_001_001_0000001", --24 addi $s1,$s1,1 2481
                        B"100_001_101_0001001", --25 beq $s1,$s5,end=35 86A3
                        B"000_000_001_010_0_000", --26 add$s2,$s0,$s1 00A0
                        B"100_010_101_0000101", --27 beq $s2,$s5,nu_e_prim==33 8AA1
                        B"000_010_001_010_0_000", --28 add $s2,$s2,$s1 08A0
                        B"001_000_110_0000000", --29 addi $s6,$s0,0 2300
                        B"000_101_010_110_0_111", --30 slt $s6,$s5,$s2 1567
                        B"100_110_111_0011000", --31 beq $s6,$s7,loop2=24 9B98
                        B"111_0000000011011", --32 j loop3=27 E01B
                        B"001_000_100_0000000", --33 addi $s4,$s0,0 2200
                        B"111_0000000100100", --34 j FINAL=36 E024
                        B"001_000_100_0000001", --35 addi$s4,$s0,1 2201
                        B"011_000_101_0001011", --36 sw $5,11($0) --hex: 628B
                        B"011_000_100_0001010", --37 sw $4,10($0) --hex: 628B
                        others =>"0000000000000000");
signal PC:std_logic_vector(15 downto 0);
signal next_address:std_logic_vector(15 downto 0);
signal branch_mux_aux:std_logic_vector(15 downto 0);
signal pc_after_sum:std_logic_vector(15 downto 0);

begin

PCproc:process(clk,reset)
begin
if reset = '1' then
            pc<=x"0000";
            else 
    if rising_edge(clk) then
        if we='1' then
                pc <= next_address;
        end if;
        end if;
    end if;
end process PCproc;


pc_after_sum <= pc + 1;




BranchMux:process(clk)
    begin
        case PCSrc is 
            when '0' => branch_mux_aux <= pc_after_sum;
            when '1' => branch_mux_aux <= branch_address;
        end case;
end process BranchMux;

JumpMux:process(clk)
    begin
        case jump is
            when '0' => next_address <= branch_mux_aux;
            when '1' => next_address <= jump_address;
        end case;
end process JumpMux;


PCout <= pc_after_sum;
instruction <= ROM(conv_integer(pc(7 downto 0)));
            

end Behavioral;
