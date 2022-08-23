LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY test IS
    GENERIC
    (
        TICK : time := 200 ns
    );
END ENTITY test;

ARCHITECTURE main OF test IS
    COMPONENT conv IS
        PORT
        (
            clk         : IN STD_LOGIC;
            rst         : IN STD_LOGIC;
            valid_test  : IN STD_LOGIC;
            data        : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            ready_if    : OUT STD_LOGIC
        );
    END COMPONENT conv;

    signal clk              : std_logic := '0';
    signal rst              : std_logic := '0';
    signal test_completed   : boolean := false;

    signal valid_w  : std_logic := '0';
    signal ready_r  : std_logic;
    signal data_out : std_logic_vector(9 DOWNTO 0);
    
BEGIN
    funct : conv port map (
        clk => clk,
        rst => rst,
        valid_test => valid_w,
        ready_if => ready_r,
        data => data_out
    );

    reset: PROCESS
    BEGIN
        rst <= '1', '0' after TICK;
        wait;
    END PROCESS reset;

    clock : PROCESS(clk)
    BEGIN
        if test_completed = false then
            if rst = '1' then
                clk <= '0';
            elsif clk = '1' then
                clk <= '0' after TICK;
            else
                clk <= '1' after TICK;
            end if;
        end if;
    END PROCESS clock;

    test_iterator : PROCESS(clk, rst)
        type mem is array (integer range<>) of std_logic_vector(9 DOWNTO 0);

        variable valid_map  : std_logic;
        variable position   : integer;
        variable com_mem    : mem(19 DOWNTO 0); -- 00 code 0000 arg1 0000 arg2
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
    END PROCESS test_iterator;
END ARCHITECTURE main;