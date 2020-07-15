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


signal IF_ID:std_logic_vector(31 downto 0);
signal ID_EX:std_logic_vector(81 downto 0);
signal EX_MEM:std_logic_vector(56 downto 0);
signal MEM_WB:std_logic_vector(37 downto 0);

signal mux_aux:std_logic_vector(2 downto 0);

begin

--LAB 5
mpgg1: mpg port map(clk,btn(0),en);
mpgg2: mpg port map(clk,btn(1),reset);
mpgg3: mpg port map(clk,btn(3),reset_memory);


instrfetch: instructionFetch port map(en,clk,jump,EX_MEM(51 downto 36),PC_SRC_AUX,jump_aux,reset,PCout_aux,Instruction_aux);

cu: controlUnit port map(IF_ID(15 downto 13),aluop_aux,regdst_aux,extop_aux,alusrc_aux,branch_aux,jump_aux,memwrite_aux,memtoreg_aux,regwrite_aux);

LAB6: instructionDecode port map(en,clk,IF_ID(31 downto 16),EX_MEM(54),ID_EX(73),extop_aux,mem_to_reg_mux_out,ExtImm_aux,ReadData1_aux,ReadData2_aux,SA_aux,FUNCT_aux);

lab7_alu : executionUnit port map(IF_ID(31 downto 16) ,ID_EX(56 downto 41),ID_EX(40 downto 25),ID_EX(24 downto 9),ID_EX(8 downto 6),SA_aux,ID_EX(74),ID_EX(77 downto 75),EX_MEM(51 downto 36),ALU_RES_AUX,ZERO_AUX);

lab7_memory_unit: MemoryUnit port map(en,clk,ID_EX(79),EX_MEM(34 downto 19) ,EX_MEM(34 downto 19),reset_memory,MEM_DATA_OUT_AUX,ALU_RES_OUT_AUX);

jump <= PCout_aux(15 downto 13) & Instruction_aux(12 downto 0);
PC_SRC_AUX <= ZERO_AUX and branch_aux;

memtoreg_mux:process(mem_to_reg_mux_out)
begin
    if memtoreg_aux = '1' then 
        mem_to_reg_mux_out <= MEM_WB(34 downto 19);
    else
        mem_to_reg_mux_out <= MEM_WB(18 downto 3);
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
led(9 downto 7)<=aluop_aux;
led(6)<=memwrite_aux;
led(5)<=memtoreg_aux;
led(4)<=regwrite_aux;
     
IF_ID_proc:process(clk)
begin
    if rising_edge(clk) then
        if en = '1' then
            IF_ID(31 downto 16) <= PCout_aux;
            IF_ID(15 downto 0) <= Instruction_aux;
        end if;
    end if;
end process IF_ID_proc;

ID_EX_proc:process(clk)
begin
    if rising_edge(clk) then
        if en = '1' then
            ID_EX(81) <= memtoreg_aux;
            ID_EX(80) <= regwrite_aux;
            ID_EX(79) <= memwrite_aux;
            ID_EX(78) <= branch_aux;
            ID_EX(77 downto 75) <= aluop_aux;
            ID_EX(74) <= alusrc_aux;
            ID_EX(73) <= regdst_aux;
            ID_EX(72 downto 57) <= IF_ID(31 downto 16);
            ID_EX(56 downto 41) <= ReadData1_aux;
            ID_EX(40 downto 25) <= ReadData2_aux;
            ID_EX(24 downto 9) <= ExtImm_aux;
            ID_EX(8 downto 6) <= FUNCT_aux;
            ID_EX(5 downto 3) <= Instruction_aux(9 downto 7);
            ID_EX(2 downto 0) <= Instruction_aux(6 downto 4);
        end if;
    end if;
end process ID_EX_proc;

mux_auxx:process(clk,en)
begin
    if regdst_aux = '0' then
        mux_aux <=ID_EX(5 downto 3);
    else mux_aux <= ID_EX(2 downto 0);
    end if;
end process mux_auxx;

EX_MEM_proc:process(clk)
begin
    if rising_edge(clk) then
        if en='1' then
            EX_MEM(55) <= ID_EX(81);
            EX_MEM(54) <= ID_EX(80);
            EX_MEM(53) <= ID_EX(79);
            EX_MEM(52) <= ID_EX(78);
            EX_MEM(51 downto 36) <= branchadd_aux;
            EX_MEM(35) <= ZERO_AUX;
            EX_MEM(34 downto 19) <= ALU_RES_AUX;
            EX_MEM(18 downto 3) <= ID_EX(40 downto 25);
            EX_MEM(2 downto 0) <= mux_aux;
        end if;
    end if;
end process EX_MEM_proc;

MEM_WB_proc:process(clk)
begin
    if rising_edge(clk) then
        if en='1' then
            MEM_WB(36) <= EX_MEM(55);
            MEM_WB(35) <= EX_MEM(54);
            MEM_WB(34 downto 19) <= MEM_DATA_OUT_AUX;
            MEM_WB(18 downto 3) <= ALU_RES_OUT_AUX;
            MEM_WB(2 downto 0) <= EX_MEM(2 downto 0);
        end if;
    end if;
end process MEM_WB_proc;
                        
           
ssdd:ssd port map(clk,afisare(15 downto 12),afisare(11 downto 8),afisare(7 downto 4),afisare(3 downto 0),  cat,an); 

end Behavioral;
