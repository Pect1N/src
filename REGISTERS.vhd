LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY REGISTERS IS
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
        adres_mem : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- data to MEM
        flag_mem : IN std_logic;
        data_ready_mem : OUT std_logic;
        adres_wr : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        data_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- data from WR
        flag_wr : IN std_logic;
        reg_rd : out std_logic_vector(32*16 - 1 downto 0) ;
        reg_wr : in std_logic_vector(32*16 - 1 downto 0) ;
                data_ready_wr : OUT std_logic
	);
END REGISTERS;

ARCHITECTURE rtl OF REGISTERS IS
    constant REG_NUM : integer := 16;
    type mas is array(integer range <>) of integer;
    signal reg : std_logic_vector(16*32 - 1 downto 0) ;
BEGIN
    reg <= reg_wr;
    reg_rd <= reg;



    registers_main : PROCESS (clk, rst)
        variable registers : mas(REG_NUM - 1 downto 0);
        variable index : INTEGER;
        variable ready_mem_map : std_logic;
        variable ready_wr_map : std_logic;
    BEGIN
        IF (rst = '1') THEN
            ready_mem_map := '0';
            ready_wr_map := '0';
            for i in 0 to REG_NUM - 1 loop
                registers(i) := i + 10;
            end loop;
        ELSIF (rising_edge(clk)) THEN
            ready_mem_map := '0';
            ready_wr_map := '0';
            if flag_mem = '1' then
                index := to_integer(unsigned(adres_mem(7 downto 4)));
                data_out(7 downto 4) <= std_logic_vector(to_unsigned(registers(index), 4));
                index := to_integer(unsigned(adres_mem(3 downto 0)));
                data_out(3 downto 0) <= std_logic_vector(to_unsigned(registers(index), 4));
                ready_mem_map := '1';
            end if;
            if flag_wr = '1' then
                index := to_integer(unsigned(adres_wr));
                registers(index) := to_integer(unsigned(data_in));
                ready_wr_map := '1';
            end if;
            data_ready_mem <= ready_mem_map;
            data_ready_wr <= ready_wr_map;
        END IF;
    END PROCESS; -- main
END rtl; -- rtl