-- library IEEE;
-- use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.STD_LOGIC_ARITH.ALL;
-- use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- USE ieee.numeric_std.ALL;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

entity test is
    generic
    (
        TICK : time := 200 ns
    );
end entity test;

architecture main of test is
    component conv is
        port
        (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            -- connect if
            valid_test : IN STD_LOGIC;
            ready_if : OUT STD_LOGIC;
            data : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            -- connect memory/mem
            adres_mem_memory : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            data_memory_mem : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            question_mem_memory : OUT STD_LOGIC;
            data_ready_memory_mem : IN STD_LOGIC;
            -- connect memory/wr
            adres_wr_memory : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            data_memory_wr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            question_wr_memory : OUT STD_LOGIC;
            data_ready_memory_wr : IN STD_LOGIC
        );
    end component conv;

    constant DATA_MEM_LEN : integer := 4;
    type mas is array(integer range <>) of integer;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal test_completed : boolean := false;

    signal valid_w : std_logic := '0';
    signal ready_r : std_logic;
    signal data_out : std_logic_vector(9 downto 0);

    signal adres_mem : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal data_mem_out : std_logic_vector(3 downto 0);
    signal flag_mem : std_logic;
    signal data_ready_mem : std_logic;

    signal adres_wr : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal data_wr_in : std_logic_vector(3 downto 0);
    signal flag_wr : std_logic;
    signal data_ready_wr : std_logic;
    
begin
    funct : conv port map (
        clk => clk,
        rst => rst,
        -- if/test
        valid_test => valid_w,
        ready_if => ready_r,
        data => data_out,
        -- memory/mem
        adres_mem_memory => adres_mem,
        data_memory_mem => data_mem_out,
        question_mem_memory => flag_mem,
        data_ready_memory_mem => data_ready_mem,
        -- memory/wr
        adres_wr_memory => adres_wr,
        data_memory_wr => data_wr_in,
        question_wr_memory => flag_wr,
        data_ready_memory_wr => data_ready_wr
    );

    reset: process
    begin
        rst <= '1', '0' after TICK;
        wait;
    end process reset;

    clock : process(clk)
    begin
        if test_completed = false then
            if rst = '1' then
                clk <= '0';
            elsif clk = '1' then
                clk <= '0' after TICK;
            else
                clk <= '1' after TICK;
            end if;
        end if;
    end process clock;

    memory_main : PROCESS (clk, rst)
        variable data_mem : mas(DATA_MEM_LEN - 1 downto 0);
        variable index : INTEGER;
        variable ready_mem_map : std_logic;
        variable ready_wr_map : std_logic;
    BEGIN
        IF (rst = '1') THEN
            ready_mem_map := '0';
            ready_wr_map := '0';
            for i in 0 to DATA_MEM_LEN - 1 loop
                data_mem(i) := i + 4;
            end loop;
        ELSIF (rising_edge(clk)) THEN
            ready_mem_map := '0';
            ready_wr_map := '0';
            if flag_mem = '1' then
                index := to_integer(unsigned(adres_mem));
                data_mem_out <= std_logic_vector(to_unsigned(data_mem(index), data_mem_out'length));
                ready_mem_map := '1';
            end if;
            if flag_wr = '1' then
                index := to_integer(unsigned(adres_wr));
                data_mem(index) := to_integer(unsigned(data_wr_in));
                ready_wr_map := '1';
            end if;
            data_ready_mem <= ready_mem_map;
            data_ready_wr <= ready_wr_map;
        END IF;
    END PROCESS; -- main

    test_iterator : process(clk, rst)
        variable valid_map : std_logic;
        variable position : integer;
        type mem is array (integer range<>) of std_logic_vector(9 downto 0);
        variable com_mem : mem(19 downto 0); -- 00 code 0000 arg1 0000 arg2
    begin
        if rst = '1' then
            position := 0;
            valid_map := '0';
            valid_w <= '0';
            com_mem(0) := "1100010001"; -- Load (11)
            com_mem(1) := "1100000000";
            com_mem(2) := "1100100010";
            com_mem(3) := "1100110011";
            com_mem(4) := "1000000000"; -- + (10)
            com_mem(5) := "1000010001";
            com_mem(6) := "1000100010";
            com_mem(7) := "1000110011";
            com_mem(8) := "1000000001";
            com_mem(9) := "1000010010";
            com_mem(10) := "0100000000"; -- * (01)
            com_mem(11) := "0100010001";
            com_mem(12) := "0100100010";
            com_mem(13) := "0100110011";
            com_mem(14) := "0100000001";
            com_mem(15) := "0100010010";
            com_mem(16) := "0000000000"; -- Store (00)
            com_mem(17) := "0000010001";
            com_mem(18) := "0000100010";
            com_mem(19) := "0000110011";
        elsif rising_edge(clk) then
            if valid_w = '1' and ready_r = '1' then
                valid_map := '0';
            end if;

            if valid_w = '0' and ready_r = '1' then
                valid_map := '1';
                data_out <= com_mem(position);
                position := position + 1;
            end if;
            if position = 20 then
                test_completed <= true;
            end if;
            valid_w <= valid_map;
        end if;
    end process test_iterator;
end architecture main;