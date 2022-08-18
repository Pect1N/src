LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY REGISTERS IS
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
        read_mem : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- element adres (read)
        mem_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- element value (read)
	);
END REGISTERS;

ARCHITECTURE rtl OF REGISTERS IS
    constant REG_NUM : integer := 4;
    type mas is array(integer range <>) of integer;
BEGIN
    memory_main : PROCESS (clk, rst)
        variable registers : mas(REG_NUM - 1 downto 0);
        variable index : INTEGER;
    BEGIN
        IF (rst = '1') THEN
            for i in 0 to REG_NUM - 1 loop
                registers(i) := 10;
            end loop;
        ELSIF (rising_edge(clk)) THEN
            index := to_integer(unsigned(read_mem(7 downto 4)));
            mem_out(7 downto 4) <= std_logic_vector(to_unsigned(registers(index), 4));
            index := to_integer(unsigned(read_mem(3 downto 0)));
            mem_out(3 downto 0) <= std_logic_vector(to_unsigned(registers(index), 4));
        END IF;
    END PROCESS; -- main
END rtl; -- rtl