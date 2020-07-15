

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity test_env is 
    Port(
    clk:in STD_LOGIC;
    btn: in STD_LOGIC_VECTOR(4 downto 0);
    sw: in STD_LOGIC_VECTOR(15 downto 0);
    led: out STD_LOGIC_VECTOR(15 downto 0);
    an: out STD_LOGIC_VECTOR(3 downto 0);
    cat: out STD_LOGIC_VECTOR(6 downto 0)
);
end test_env;

architecture Behavioral of test_env is

component  mpg is
    Port ( 
    clk : in STD_LOGIC;
    btnn : in STD_LOGIC;
    enable: out STD_LOGIC
    );
end component;
    
component SSD is
    Port(
    clk: in STD_LOGIC;
    digit3: in STD_LOGIC_VECTOR(3 downto 0);
    digit2: in STD_LOGIC_VECTOR(3 downto 0);
    digit1: in STD_LOGIC_VECTOR(3 downto 0);
    digit0: in STD_LOGIC_VECTOR(3 downto 0);
    cat: out STD_LOGIC_VECTOR(6 downto 0);
    an: out STD_LOGIC_VECTOR(3 downto 0)
    );  
end component SSD;

component blocRegistre is
  Port (
  clk:in STD_LOGIC;
  ra1:in std_logic_vector(3 downto 0);
  ra2:in std_logic_vector(3 downto 0);
  wa : in std_logic_vector (3 downto 0);
  wd : in std_logic_vector (15 downto 0);
  wen: in STD_LOGIC;
  rd1:out STD_LOGIC_VECTOR(15 downto 0);
  rd2:out STD_LOGIC_VECTOR(15 downto 0)
  );
end component blocRegistre;

component InstructionFetch is
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
end component InstructionFetch;


component InstructionDecode is
    Port(
        enable: in std_logic;
        clk:in STD_LOGIC;
        instr:in STD_LOGIC_VECTOR(15 downto 0);
        RegWrite: in STD_LOGIC; -- adica enable
        RegDest: in STD_LOGIC;
        ExtOp: in STD_LOGIC;
        WriteData: in STD_LOGIC_VECTOR(15 downto 0);
       -- WriteAddress:in STD_LOGIC_VECTOR(15 downto 0);
        
        ExtImm : out STD_LOGIC_VECTOR(15 downto 0);
        ReadData1: out STD_LOGIC_VECTOR(15 downto 0);
        ReadData2: out STD_LOGIC_VECTOR(15 downto 0);
        SA: out STD_LOGIC;
        FUNCT:out STD_LOGIC_VECTOR(2 downto 0)
        );

end component InstructionDecode;


component controlUnit is
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
 end component controlUnit;  
   
component executionUnit is
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
end component executionUnit;
   
   
component MemoryUnit is
  Port (
  en: in std_logic;
    CLK:in STD_LOGIC;
    MEM_WRITE:in STD_LOGIC; 
    ALU_RES:in STD_LOGIC_VECTOR(15 downto 0);
    RD2:in STD_LOGIC_VECTOR(15 downto 0); 
    enable:in STD_LOGIC;
    
    MEM_DATA:out STD_LOGIC_VECTOR(15 downto 0);
    ALU_RES_OUT:out STD_LOGIC_VECTOR(15 downto 0)
   );
end component MemoryUnit;


signal en:STD_LOGIC;
signal reset:STD_LOGIC;
signal branch:STD_LOGIC_VECTOR(15 downto 0):=x"1111";
signal jump:STD_LOGIC_VECTOR(15 downto 0):=x"0000";
signal PCout_aux:STD_LOGIC_VECTOR(15 downto 0);
signal Instruction_aux:STD_LOGIC_VECTOR(15 downto 0);
signal outt:STD_LOGIC_VECTOR(15 downto 0);
signal aluop_aux:STD_LOGIC_VECTOR(2 downto 0);
signal regdst_aux,extop_aux,alusrc_aux,branch_aux,jump_aux,memwrite_aux,memtoreg_aux,regwrite_aux:STD_LOGIC;
signal WriteData_aux:STD_LOGIC_VECTOR(15 downto 0);
signal ExtImm_aux :STD_LOGIC_VECTOR(15 downto 0);
signal ReadData1_aux,ReadData2_aux:STD_LOGIC_VECTOR(15 downto 0);
signal SA_aux:STD_LOGIC;
signal FUNCT_aux:STD_LOGIC_VECTOR(2 downto 0);

signal afisare:STD_LOGIC_VECTOR(15 downto 0);

signal mem_to_reg_mux_out: STD_LOGIC_VECTOR(15 downto 0);
signal reset_memory: STD_LOGIC;


signal MEM_DATA_OUT_AUX:STD_LOGIC_VECTOR(15 downto 0);
signal ALU_RES_OUT_AUX:STD_LOGIC_VECTOR(15 downto 0);


signal branchadd_aux:STD_LOGIC_VECTOR(15 downto 0);
signal ALU_RES_AUX:STD_LOGIC_VECTOR(15 downto 0);
signal ZERO_AUX:STD_LOGIC;

signal PC_SRC_AUX:STD_LOGIC;

begin

--LAB 5
mpgg1: mpg port map(clk,btn(0),en);
mpgg2: mpg port map(clk,btn(1),reset);
mpgg3: mpg port map(clk,btn(3),reset_memory);

--instrfetch: instructionFetch port map(clk,jump,branch,sw(1),sw(0),reset,en,PCout_aux,Instruction_aux);



--ssdd: ssd port map(clk,  outt(15 downto 12),  outt(11 downto 8),   outt(7 downto 4),  outt(3 downto 0),  cat,an); 


instrfetch: instructionFetch port map(en,clk,jump,branchadd_aux,PC_SRC_AUX,jump_aux,reset,PCout_aux,Instruction_aux);

cu: controlUnit port map(Instruction_aux(15 downto 13),aluop_aux,regdst_aux,extop_aux,alusrc_aux,branch_aux,jump_aux,memwrite_aux,memtoreg_aux,regwrite_aux);

--(instr decode)instr: RegWrite: RegDest: ExtOp: WriteData: WriteAddress: ExtImm : ReadData1: ReadData2: SA: FUNCT:
LAB6: instructionDecode port map(en,clk,Instruction_aux,regwrite_aux,regdst_aux,extop_aux,mem_to_reg_mux_out,ExtImm_aux,ReadData1_aux,ReadData2_aux,SA_aux,FUNCT_aux);

lab7_alu : executionUnit port map(PCout_aux ,ReadData1_aux,ReadData2_aux,ExtImm_aux,FUNCT_aux,SA_aux,alusrc_aux,aluop_aux,branchadd_aux,ALU_RES_AUX,ZERO_AUX);

lab7_memory_unit: MemoryUnit port map(en,clk,memwrite_aux,ALU_RES_AUX ,ReadData2_aux,reset_memory,MEM_DATA_OUT_AUX,ALU_RES_OUT_AUX);

jump <= PCout_aux(15 downto 13) & Instruction_aux(12 downto 0);
PC_SRC_AUX <= ZERO_AUX and branch_aux;

memtoreg_mux:process(mem_to_reg_mux_out)
begin
    if memtoreg_aux = '1' then 
        mem_to_reg_mux_out <= MEM_DATA_OUT_AUX;
    else
        mem_to_reg_mux_out <= ALU_RES_OUT_AUX;
    end if;
end process memtoreg_mux;


process(sw(7 downto 5))
begin
    case sw(7 downto 5) is
        when "000" => afisare <=Instruction_aux;
        when "001" => afisare <=PCout_aux;
        when "010" => afisare <= ReadData1_aux;
        when "011" => afisare <= ReadData2_aux;
        when "100" => afisare <= ExtImm_aux;
        when "101" => afisare <= ALU_RES_OUT_AUX;
        when "110" => afisare <= MEM_DATA_OUT_AUX;
        when "111" => afisare <= WriteData_aux;
        when others => afisare <= Instruction_aux;
    end case;
end process;

led(15)<=regdst_aux;
     led(14)<=extop_aux;
     led(13)<=alusrc_aux;
     led(12)<=branch_aux;
     led(11)<=jump_aux;
     --led(10)<= branch_not_equal;
     led(9 downto 7)<=aluop_aux;
     led(6)<=memwrite_aux;
     led(5)<=memtoreg_aux;
     led(4)<=regwrite_aux;

ssdd:ssd port map(clk,afisare(15 downto 12),afisare(11 downto 8),afisare(7 downto 4),afisare(3 downto 0),  cat,an); 

end Behavioral;
