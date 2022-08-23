LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY REGISTERS IS
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
        flag : IN std_logic;
        ready : OUT std_logic;
        read_reg : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- element adres (read)
        regs_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- element value (read)
	);
END REGISTERS;

ARCHITECTURE rtl OF REGISTERS IS
    constant REG_NUM : integer := 4;
    type mas is array(integer range <>) of integer;
BEGIN
    registers_main : PROCESS (clk, rst)
        variable registers : mas(REG_NUM - 1 downto 0);
        variable index : INTEGER;
        variable ready_map : std_logic;
    BEGIN
        IF (rst = '1') THEN
            ready_map := '0';
            for i in 0 to REG_NUM - 1 loop
                registers(i) := i + 10;
            end loop;
        ELSIF (rising_edge(clk)) THEN
            ready_map := '0';
            if flag = '1' then
                index := to_integer(unsigned(read_reg(7 downto 4)));
                regs_out(7 downto 4) <= std_logic_vector(to_unsigned(registers(index), 4));
                index := to_integer(unsigned(read_reg(3 downto 0)));
                regs_out(3 downto 0) <= std_logic_vector(to_unsigned(registers(index), 4));
                ready_map := '1';
            end if;
            ready <= ready_map;
        END IF;
    END PROCESS; -- main
END rtl; -- rtl