LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY REGISTERS IS
    generic
    (
        REG_NUM         : INTEGER := 16;
        LEN             : INTEGER := 16;
        REG_MEM_LEN     : INTEGER := 16
    );
	PORT (
		clk     : IN    STD_LOGIC;
		rst     : IN    STD_LOGIC;
        reg_wr  : IN    STD_LOGIC_VECTOR(LEN * REG_MEM_LEN - 1 DOWNTO 0);
        reg_rd  : OUT   STD_LOGIC_VECTOR(LEN * REG_MEM_LEN - 1 DOWNTO 0)
	);
END REGISTERS;

ARCHITECTURE rtl OF REGISTERS IS
    type mas is array(INTEGER range <>) of INTEGER;
    signal reg : STD_LOGIC_VECTOR(LEN * REG_MEM_LEN - 1 DOWNTO 0);
BEGIN
    reg <= reg_wr;
    reg_rd <= reg;
END rtl; -- rtl