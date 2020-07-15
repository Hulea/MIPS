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

signal ROM: rom_type:=(  B"001_000_001_0000001", --0 addi $s1,$s0,1 2081
                         B"001_000_010_0000000", --1 addi $s2,$s0,0 2100
                         B"001_000_011_0000001", --2 addi $s3,$s0,a=1 2181
                         B"001_000_100_0000100", --3 addi $s4,$s0,b=4 2204 
                         B"001_000_101_0000000", --4 addi $s5,$s0,0 2280
                         B"001_000_111_0000001", --5 addi $s7,$s0,1 2381
                         B"001_000_110_0000000", --6 addi $s6,$s0,0 2300
                         B"000_100_001_110_0_111", --7 slt $s6,$s4,$s1 10E7
			             B"001_000_000_0000000", --8 add $s0,$s0,$s0
			             B"001_000_000_0000000",--9 add $s0,$s0,$s0
			             B"001_000_000_0000000",--10 add $s0,$s0,$s0
                         B"100_110_111_0100000", --11 beq $s6,$s7,verif_prim=+32 9b93
			             B"001_000_000_0000000",--12 add $s0,$s0,$s0
			             B"001_000_000_0000000",--13 add $s0,$s0,$s0
			             B"001_000_000_0000000",--14 add $s0,$s0,$s0
                         B"001_000_110_0000000", --15 addi $s6,$s0,0 2300
                         B"000_011_001_110_0_111", --16 slt $s6,$s3,$s1 0CE7
		                 B"001_000_000_0000000",--17 add $s0,$s0,$s0
			             B"001_000_000_0000000",--18 add $s0,$s0,$s0
			             B"001_000_000_0000000",--19 add $s0,$s0,$s0
                         B"100_110_111_0001100", --20 beq $s6,$s7,add_to_sum=+12 9B8F
			             B"001_000_000_0000000",--21 add $s0,$s0,$s0
			             B"001_000_000_0000000",--22 add $s0,$s0,$s0
			             B"001_000_000_0000000",--23 add $s0,$s0,$s0
                         B"000_001_010_001_0_000", --24 add $s1,$s1,$s2 0510
			             B"001_000_000_0000000",--25 add $s0,$s0,$s0
			             B"001_000_000_0000000",--26 add $s0,$s0,$s0
			             B"001_000_000_0000000",--27 add $s0,$s0,$s0
                         B"000_001_010_010_0_001", --28 sub $s2,$s1,$s2 0521
			             B"001_000_000_0000000",--29 add $s0,$s0,$s0
			             B"001_000_000_0000000",--30 add $s0,$s0,$s0
                         B"111_0000000000110", -- 31 j loop=6 E006
			             B"001_000_000_0000000",--32 add $s0,$s0,$s0
                         B"000_001_010_001_0_000", --33 add $s1,$s1,$s2 0510
			             B"001_000_000_0000000",--34 add $s0,$s0,$s0
			             B"001_000_000_0000000",--35 add $s0,$s0,$s0
			             B"001_000_000_0000000",--36 add $s0,$s0,$s0
                         B"000_001_010_010_0_001", --37 sub $s2,$s1,$s2 0521
			             B"001_000_000_0000000",--38 add $s0,$s0,$s0
                         B"001_000_000_0000000",--39 add $s0,$s0,$s0
                         B"001_000_000_0000000",--40 add $s0,$s0,$s0
                         B"000_101_010_101_0_000", --41 add $s5,$s5,$s2 14D0
                         B"111_0000000000110", --42 j loop=6 E006--------------------
			             B"001_000_000_0000000",--43 add $s0,$s0,$s0
                         B"001_000_001_0000001", --44 addi $s1,$s0,1 2081
                         B"001_000_010_0000000", --45 addi $s2,$s0,0 2100
                         B"001_000_100_0000000", --46 addi $s4,$s0,0 2200
                         B"001_000_111_0000001", --47 addi $s7,$s0,1 2381
                         B"100_101_001_0100001", --48 beq $s5,$s1,nu_e_prim=+33 94A1
			             B"001_000_000_0000000",--49 add $s0,$s0,$s0
			             B"001_000_000_0000000",--50 add $s0,$s0,$s0
			             B"001_000_000_0000000", --51 add $s0,$s0,$s0
                         B"001_001_001_0000001", --52 addi $s1,$s1,1 2481
			             B"001_000_000_0000000",--53 add $s0,$s0,$s0
			             B"001_000_000_0000000",--54 add $s0,$s0,$s0
                         B"100_001_101_0011110", --55 beq $s1,$s5,end=+30 86A3
			             B"001_000_000_0000000",--56 add $s0,$s0,$s0
			             B"001_000_000_0000000",--57 add $s0,$s0,$s0
			             B"001_000_000_0000000",--58 add $s0,$s0,$s0
                         B"000_000_001_010_0_000", --59 add$s2,$s0,$s1 00A0
			             B"001_000_000_0000000",--60 add $s0,$s0,$s0
			             B"001_000_000_0000000",--61 add $s0,$s0,$s0
			             B"001_000_000_0000000",--62 add $s0,$s0,$s0
                         B"100_010_101_0010010", --63 beq $s2,$s5,nu_e_prim==+18 8AA1
                         B"001_000_000_0000000",--64 add $s0,$s0,$s0
                         B"001_000_000_0000000",--65 add $s0,$s0,$s0
                         B"001_000_000_0000000",--66 add $s0,$s0,$s0
                         B"000_010_001_010_0_000", --67 add $s2,$s2,$s1 08A0
			             B"001_000_000_0000000",--68 add $s0,$s0,$s0
			             B"001_000_000_0000000",--69 add $s0,$s0,$s0
                         B"001_000_110_0000000", --70 addi $s6,$s0,0 2300
			             B"001_000_000_0000000",--71 add $s0,$s0,$s0
			             B"001_000_000_0000000",--72 add $s0,$s0,$s0
                         B"000_101_010_110_0_111", --73 slt $s6,$s5,$s2 1567
                         B"100_110_000_0000101", --74 beq $s6,$s0,aici=+5 9801
			             B"001_000_000_0000000",--75 add $s0,$s0,$s0
			             B"001_000_000_0000000",--76 add $s0,$s0,$s0
			             B"001_000_000_0000000",--77 add $s0,$s0,$s0
                         B"111_0000000110100", --78 j loop2=52 E018
			             B"001_000_000_0000000",--79 add $s0,$s0,$s0
                         B"111_0000000111111", --80 j loop3=63 E01B
			             B"001_000_000_0000000",--81 add $s0,$s0,$s0
                         B"001_000_100_0000000", --82 addi $s4,$s0,0 2200 
                         B"111_0000001011001", --83 j FINAL=89 E024
			             B"001_000_000_0000000",--84 add $s0,$s0,$s0
			             B"001_000_000_0000000",--85 add $s0,$s0,$s0
                         B"001_000_100_0000001", --86 addi$s4,$s0,1 2201 
			             B"001_000_000_0000000",--87 add $s0,$s0,$s0
			             B"001_000_000_0000000",--88 add $s0,$s0,$s0
                         B"011_000_101_0001011", --89 sw $5,11($0) 
                         B"011_000_100_0001010", --90 sw $4,10($0) 
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
