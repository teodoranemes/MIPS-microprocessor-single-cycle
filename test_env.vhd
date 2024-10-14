library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

signal instr_out: STD_LOGIC_VECTOR(31 downto 0);
signal pc_out: STD_LOGIC_VECTOR(31 downto 0);
signal br_addr: STD_LOGIC_VECTOR(31 downto 0):=x"00000000";
signal bne_addr: STD_LOGIC_VECTOR(31 downto 0):=x"00000000";
signal j_addr: STD_LOGIC_VECTOR(31 downto 0):=x"00000000";
signal jump: std_logic;
signal pc_src: std_logic;
signal bne: std_logic;
signal branch_eq : std_logic;
signal branch_ne: std_logic;
signal reg_write: std_logic;
signal reg_dst: std_logic;
signal ext_op: std_logic;
signal wd: std_logic_vector(31 downto 0) := x"00000002";
signal rd1: std_logic_vector(31 downto 0);
signal rd2: std_logic_vector(31 downto 0);
signal ext_imm: std_logic_vector(31 downto 0);
signal func: std_logic_vector(5 downto 0);
signal sa: std_logic_vector(4 downto 0);
signal mem_write : std_logic;
signal alu_src : std_logic;
signal mem_to_reg : std_logic;
signal alu_res : std_logic_vector(31 downto 0);
signal zero : std_logic;
signal mem_data : std_logic_vector(31 downto 0);
signal alu_res_out : std_logic_vector(31 downto 0);
signal cnt : std_logic_vector(5 downto 0) := (others => '0');
signal enable:  STD_LOGIC;
signal in_SSD : std_logic_vector(31 downto 0) := (others => '0');
signal A : std_logic_vector(31 downto 0);
signal B : std_logic_vector(31 downto 0);
signal C : std_logic_vector(31 downto 0);
signal enable2: STD_LOGIC;

component MPG
 Port ( clk: in std_logic;
        input: in std_logic;
        en: out std_logic
 );
end component;

component SSD is
    Port ( cnt : in STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           an : OUT STD_LOGIC_VECTOR (7 downto 0);
           cat : OUT STD_LOGIC_VECTOR (6 downto 0));
end component;

component reg_file is
    Port ( 
    clk: in std_logic;
    en: in std_logic;
    ra1: in std_logic_vector(4 downto 0);
    ra2: in std_logic_vector(4 downto 0);
    regWR: in std_logic;
    wd: in std_logic_vector(31 downto 0);
    wa: in std_logic_vector(4 downto 0);
    rd1: out std_logic_vector(31 downto 0);
    rd2: out std_logic_vector(31 downto 0)
);
end component;

component IFETCH is
    Port ( clk : in STD_LOGIC;
           PCsrc : in STD_LOGIC;
           Jump : in STD_LOGIC;
           Reset: in STD_LOGIC;
           BrAdd : in STD_LOGIC_VECTOR (31 downto 0);
           JAdd : in STD_LOGIC_VECTOR (31 downto 0);
           Instr : out STD_LOGIC_VECTOR (31 downto 0);
           PCplus : out STD_LOGIC_VECTOR (31 downto 0);
           En : in STD_LOGIC
);
end component;

component ID is
    Port ( 
    clk: in std_logic;
     RegWrite: in std_logic;
     Instr: in std_logic_vector(31 downto 0);
     ExtOp: in std_logic;
     RegDst: in std_logic;
     En : in STD_LOGIC;
     WD: in std_logic_vector(31 downto 0);
     RD1: out std_logic_vector(31 downto 0);
     RD2: out std_logic_vector(31 downto 0);
     Ext_imm: out std_logic_vector(31 downto 0);
     funct: out std_logic_vector(5 downto 0);
     sa: out std_logic_vector(4 downto 0)
     );
end component;

component EX is
    Port (
      RD1: in std_logic_vector(31 downto 0);
      ALUSrc: in std_logic;
      RD2: in std_logic_vector(31 downto 0);
      Ext_Imm: in std_logic_vector(31 downto 0);
      sa: in std_logic_vector(4 downto 0);
      func: in std_logic_vector(5 downto 0);
      ALUOp: in std_logic_vector(5 downto 0);
      PC_4: in std_logic_vector(31 downto 0);
      Zero: out std_logic;
      ALURes: out std_logic_vector(31 downto 0);
      Branch_Address: out std_logic_vector(31 downto 0)
    );
end component;

component MEM is
  Port (
  MemWrite: in std_logic;
  ALUResIn: in std_logic_vector(31 downto 0);
  RD2: in std_logic_vector(31 downto 0);
  MemData: out std_logic_vector(31 downto 0);
  ALUResOut: out std_logic_vector(31 downto 0);
  Enable: in std_logic;
  Clk: in std_logic
   );
end component;


begin

generator_monopuls : MPG port map( clk => clk, input => btn(0),  en => enable);
Seven_segment_display : SSD port map(cnt=>in_SSD, clk=>clk, an=>an, cat=>cat); 
instr_f : IFETCH port map(clk=>clk, PCSrc=>branch_eq, Jump=>jump,Reset=>btn(1), BrAdd=>br_addr, JAdd =>j_addr, Instr=>instr_out, Pcplus=>pc_out, en=>enable);
instr_d : ID port map(clk=>clk, RegWrite =>reg_write, Instr=>instr_out ,ExtOp=>ext_op, RegDst=>reg_dst, En=>enable, Wd=>wd, RD1=>rd1, RD2=>rd2, Ext_imm=>ext_imm, funct=>func, sa=>sa);
instr_e : EX port map(RD1=>rd1, ALUSrc=>alu_src, RD2=>rd2, Ext_imm=>ext_imm, sa=>sa,func=>func, ALUOp=>instr_out(31 downto 26), PC_4=>pc_out, Zero=>zero, ALURes=>alu_res,  Branch_Address=>br_addr);
mem_ram : MEM port map(MemWrite=>mem_write, ALUResIn=>alu_res, RD2 =>rd2, MemData=>mem_data, ALUResOut=>alu_res_out,  Enable =>'1', clk=>clk);

bne_addr <= br_addr;
j_addr <= pc_out(31 downto 28) & instr_out(25 downto 0) & "00";

process(sw(15 downto 13), instr_out, rd1, rd2, ext_imm, pc_out)
begin
    case sw(15 downto 13) is 
        when "000" => in_SSD <= instr_out;
        when "001" => in_SSD <= pc_out;
        when "010" => in_SSD <= rd1;
        when "011" => in_SSD <= rd2;
        when "100" => in_SSD <= ext_imm;
        when "101" => in_SSD <= alu_res;
        when "110" => in_SSD <= wd;
        when "111" => in_SSD <= mem_data;
        when others => in_SSD <= x"AAAAAAAA";
    end case;
end process;

process(instr_out)
begin
    case instr_out(31 downto 26) is
        when "000000" => pc_src <= '0';     -- operatii de tip R
                         jump <= '0';
                         bne <= '0';
                         reg_dst <= '1';
                         reg_write <= '1';
                         ext_op <= '0';
                         mem_write <= '0';
                         mem_to_reg <= '0';
                         alu_src <= '0';
        when "001000" => pc_src <= '0';     -- addi
                         jump <= '0';
                         bne <= '0';
                         reg_dst <= '0';
                         reg_write <= '1';
                         ext_op <= '1';
                         mem_write <= '0';
                         mem_to_reg <= '0'; 
                         alu_src <= '1';
        when "100011" => pc_src <= '0';     -- lw 
                         jump <= '0';
                         bne <= '0';
                         reg_dst <= '0';
                         reg_write <= '1';
                         ext_op <= '1';
                         mem_write <= '0';
                         mem_to_reg <= '1';
                         alu_src <= '1'; 
        when "101011" => pc_src <= '0';      --sw
                         jump <= '0';
                         bne <= '0';
                         reg_dst <= '0';
                         reg_write <= '0';
                         ext_op <= '1';
                         mem_write <= '1';
                         mem_to_reg <= '0';
                         alu_src <= '1'; 
        when "000100" => pc_src <= '1';     -- beq 
                         jump <= '0';
                         bne <= '0';
                         reg_dst <= '0';
                         reg_write <= '0';
                         ext_op <= '1';
                         mem_write <= '0';
                         mem_to_reg <= '0';
                         alu_src <= '0';
    
        when "000111" => pc_src <= '0';     -- j 
                         jump <= '1';
                         bne <= '0';
                         reg_dst <= '0';
                         reg_write <= '0';
                         ext_op <= '0';
                         mem_write <= '0';
                         mem_to_reg <= '0';
                         alu_src <= '0';
         
         when "001011" => pc_src <= '0';     --ori
                         jump <= '0';
                         bne <= '0';
                         reg_dst <= '1';
                         reg_write <= '1';
                         ext_op <= '0';
                         mem_write <= '0';
                         mem_to_reg <= '0';
                         alu_src <= '1';
                         
         when "001001" => pc_src <= '0';     --xori
                         jump <= '0';
                         bne <= '0';
                         reg_dst <= '1';
                         reg_write <= '1';
                         ext_op <= '0';
                         mem_write <= '0';
                         mem_to_reg <= '0';
                         alu_src <= '1';
                         
         when others => pc_src <= '0';
                         jump <= '0';
                         bne <= '0';
                         reg_dst <= '0';
                         reg_write <= '0';
                         ext_op <= '0';
                         mem_write <= '0';
                         mem_to_reg <= '0';
                         alu_src <= '0';
    end case;
                         
end process;

branch_eq <= pc_src AND zero;

process(mem_to_reg, mem_data, alu_res)
begin
    if mem_to_reg = '0' then
        wd <= alu_res;
    else 
        wd <= mem_data;
    end if; 
end process;


end Behavioral;