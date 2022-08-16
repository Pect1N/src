LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY MEMORY IS
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
        read_mem : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- element adres (read)
        mem_out : OUT INTEGER -- element value (read)
	);
END MEMORY;

ARCHITECTURE rtl OF MEMORY IS
    constant DATA_MEM_LEN : integer := 4;
    type mas is array(integer range <>) of integer;
BEGIN
    memory_main : PROCESS (clk, rst)
        variable data_mem : mas(DATA_MEM_LEN - 1 downto 0);
    BEGIN
        IF (rst = '1') THEN
            for i in 0 to DATA_MEM_LEN - 1 loop
                data_mem(i) := i;
            end loop;
        ELSIF (rising_edge(clk)) THEN
            mem_out <= data_mem(to_integer(unsigned(read_mem(3 downto 0))));
        END IF;
    END PROCESS; -- main
END rtl; -- rtl