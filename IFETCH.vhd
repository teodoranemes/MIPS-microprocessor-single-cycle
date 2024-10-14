

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IFETCH is
    Port ( clk : in STD_LOGIC;
           PCsrc : in STD_LOGIC;
           Jump : in STD_LOGIC;
           Reset: in STD_LOGIC;
           BrAdd : in STD_LOGIC_VECTOR (31 downto 0);
           JAdd : in STD_LOGIC_VECTOR (31 downto 0);
           Instr : out STD_LOGIC_VECTOR (31 downto 0);
           PCplus : out STD_LOGIC_VECTOR (31 downto 0);
           En : in STD_LOGIC);
end IFETCH;

architecture Behavioral of IFETCH is

type ROM is array (0 to 63) of std_logic_vector(31 downto 0);
signal MEM_ROM : ROM := (  
    
    b"001000_00010_00001_0000000000000011", --addi $1 $2 3
    b"001000_00100_00011_0000000000000010", --addi $3 $4 2
    b"000000_00001_00011_00010_00000_100000", --add $2 $1 $3
    b"000000_00010_00011_00100_00000_100010", --sub $4 $2 $3
    b"000000_00010_00000_00101_00001_000001", --sll $5 $2 1
    b"000000_00001_00000_00100_00001_000010", --srl $4 $1 1
    b"000000_00010_00011_00001_00000_100100", --and $1 $2 $3
    b"000000_00001_00100_00010_00000_100101", --or $2 $1 $4
    b"000000_00010_00100_00011_00000_100111", --xor $3 $2 $4
    b"000000_00010_00001_00011_00010_101000",--sllv $3 $2 $1
    b"100011_00010_00001_0000000000000011", --lw $1 3($2)
    b"101011_00011_00101_0000000000000010", --sw $5 2($3)
    b"000100_00011_00010_0000000000000010", --beq $2 $3 2
    b"000111_00000_00000_0000000000000001", --j 1
    b"001011_00010_00001_0000000000000100",--ori $1 $2 4
    b"001001_00011_00101_0000000000000010",--xori $5 $3 2
    others => x"00000000");

signal PcAdd : STD_LOGIC_VECTOR (31 downto 0);
signal iesire_br : STD_LOGIC_VECTOR (31 downto 0);
signal iesire_jmp : STD_LOGIC_VECTOR (31 downto 0);
signal inst_add : STD_LOGIC_VECTOR (31 downto 0);


begin

Instr<= MEM_ROM(conv_integer(inst_add(7 downto 2)));
PcAdd<=inst_add + 4;
PCplus<=PcAdd;

process(clk)
begin
     if Reset = '1' then 
        inst_add <= x"00000000";
    end if;
    if rising_edge(clk) then
        if En = '1' then
                inst_add <= iesire_jmp;            
        end if;
    end if;
end process;


process(PCsrc,BrAdd,PcAdd)
begin
        if PCsrc = '1' then
              iesire_br <= BrAdd;
           else 
              iesire_br <= PcAdd;
        end if;
end process;

process(iesire_br,Jump,JAdd)
begin
        if Jump = '1' then
              iesire_jmp <= JAdd;
           else 
              iesire_jmp <= iesire_br;
        end if;
end process;

end Behavioral;
