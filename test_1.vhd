LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

entity test is
    generic
    (
        TICK            : time := 200 ns;
        COM_MEM_LEN     : INTEGER := 48; -- 32/48
        DATA_MEM_LEN    : INTEGER := 16;
        INSTR_LEN       : INTEGER := 3;
        LEN             : INTEGER := 16;
        DATA_LEN        : INTEGER := 3 + 16 + 16 -- INSTR_LEN + LEN + LEN
    );
end entity test;

architecture main of test is
    component conv is
        port
        (
            clk                     : IN STD_LOGIC;
            rst                     : IN STD_LOGIC;
            -- connect if
            valid_test              : IN    STD_LOGIC;
            ready_if                : OUT   STD_LOGIC;
            data                    : IN    STD_LOGIC_VECTOR(DATA_LEN - 1 DOWNTO 0);
            -- connect memory/mem
            adres_mem_memory        : OUT   STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
            data_memory_mem         : IN    STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
            question_mem_memory     : OUT   STD_LOGIC;
            data_ready_memory_mem   : IN    STD_LOGIC;
            -- connect memory/wr
            adres_wr_memory         : OUT   STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
            data_memory_wr          : OUT   STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
            question_wr_memory      : OUT   STD_LOGIC;
            data_ready_memory_wr    : IN    STD_LOGIC
        );
    end component conv;

    type mas is array(INTEGER range <>) of INTEGER;

    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal test_completed : boolean := false;

    signal valid_w1         : STD_LOGIC := '0';
    signal ready_r1         : STD_LOGIC;
    signal data_out1        : STD_LOGIC_VECTOR(DATA_LEN - 1 downto 0);

    signal adres_mem1       : STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
    signal data_mem_out1    : STD_LOGIC_VECTOR(LEN - 1 downto 0);
    signal flag_mem1        : STD_LOGIC;
    signal data_ready_mem1  : STD_LOGIC;

    signal adres_wr1        : STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
    signal data_wr_in1      : STD_LOGIC_VECTOR(LEN - 1 downto 0);
    signal flag_wr1         : STD_LOGIC;
    signal data_ready_wr1   : STD_LOGIC;

    signal valid_w2         : STD_LOGIC := '0';
    signal ready_r2         : STD_LOGIC;
    signal data_out2        : STD_LOGIC_VECTOR(DATA_LEN - 1 downto 0);

    signal adres_mem2       : STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
    signal data_mem_out2    : STD_LOGIC_VECTOR(LEN - 1 downto 0);
    signal flag_mem2        : STD_LOGIC;
    signal data_ready_mem2  : STD_LOGIC;

    signal adres_wr2        : STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
    signal data_wr_in2      : STD_LOGIC_VECTOR(LEN - 1 downto 0);
    signal flag_wr2         : STD_LOGIC;
    signal data_ready_wr2   : STD_LOGIC;
    
begin
    funct1 : conv port map (
        clk => clk,
        rst => rst,
        -- if/test
        valid_test => valid_w1,
        ready_if => ready_r1,
        data => data_out1,
        -- memory/mem
        adres_mem_memory => adres_mem1,
        data_memory_mem => data_mem_out1,
        question_mem_memory => flag_mem1,
        data_ready_memory_mem => data_ready_mem1,
        -- memory/wr
        adres_wr_memory => adres_wr1,
        data_memory_wr => data_wr_in1,
        question_wr_memory => flag_wr1,
        data_ready_memory_wr => data_ready_wr1
    );

    funct2 : conv port map (
        clk => clk,
        rst => rst,
        -- if/test
        valid_test => valid_w2,
        ready_if => ready_r2,
        data => data_out2,
        -- memory/mem
        adres_mem_memory => adres_mem2,
        data_memory_mem => data_mem_out2,
        question_mem_memory => flag_mem2,
        data_ready_memory_mem => data_ready_mem2,
        -- memory/wr
        adres_wr_memory => adres_wr2,
        data_memory_wr => data_wr_in2,
        question_wr_memory => flag_wr2,
        data_ready_memory_wr => data_ready_wr2
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
        variable data_mem       : mas(DATA_MEM_LEN - 1 downto 0);
        variable index1         : INTEGER;
        variable ready_mem_map1 : STD_LOGIC;
        variable ready_wr_map1  : STD_LOGIC;
        variable index2         : INTEGER;
        variable ready_mem_map2 : STD_LOGIC;
        variable ready_wr_map2  : STD_LOGIC;
    BEGIN
        IF (rst = '1') THEN
            ready_mem_map1 := '0';
            ready_wr_map1 := '0';
            ready_mem_map2 := '0';
            ready_wr_map2 := '0';
            for i in 0 to DATA_MEM_LEN - 1 loop
                data_mem(i) := i + 4;
            end loop;
        ELSIF (rising_edge(clk)) THEN
            ready_mem_map1 := '0';
            ready_wr_map1 := '0';
            ready_mem_map2 := '0';
            ready_wr_map2 := '0';

            if flag_mem1 = '1' then
                index1 := to_integer(unsigned(adres_mem1));
                data_mem_out1 <= STD_LOGIC_VECTOR(to_unsigned(data_mem(index1), data_mem_out1'length));
                ready_mem_map1 := '1';
            end if;
            if flag_wr1 = '1' then
                index1 := to_integer(unsigned(adres_wr1));
                data_mem(index1) := to_integer(unsigned(data_wr_in1));
                ready_wr_map1 := '1';
            end if;

            if flag_mem2 = '1' then
                index2 := to_integer(unsigned(adres_mem2));
                data_mem_out2 <= STD_LOGIC_VECTOR(to_unsigned(data_mem(index2), data_mem_out2'length));
                ready_mem_map2 := '1';
            end if;
            if flag_wr2 = '1' then
                index2 := to_integer(unsigned(adres_wr2));
                data_mem(index2) := to_integer(unsigned(data_wr_in2));
                ready_wr_map2 := '1';
            end if;

            data_ready_mem1 <= ready_mem_map1;
            data_ready_wr1 <= ready_wr_map1;
            data_ready_mem2 <= ready_mem_map2;
            data_ready_wr2 <= ready_wr_map2;
        END IF;
    END PROCESS; -- main

    test_iterator : process(clk, rst)
        variable valid_map1 : STD_LOGIC;
        variable valid_map2 : STD_LOGIC;
        variable nops1      : INTEGER;
        variable nops2      : INTEGER;
        variable position   : INTEGER;
        type mem is array (INTEGER range<>) of STD_LOGIC_VECTOR(DATA_LEN - 1 downto 0);
        variable com_mem    : mem(COM_MEM_LEN - 1 downto 0); -- 000 code 0000 arg1 0000 arg2
        variable nop        : STD_LOGIC_VECTOR(DATA_LEN - 1 downto 0);
    begin
        if rst = '1' then
            position := 0;
            valid_map1 := '0';
            valid_w1 <= '0';
            valid_map2 := '0';
            valid_w2 <= '0';
            nop := "00000000000000000000000000000000000";
            nops1 := 0;
            nops2 := 0;
            if COM_MEM_LEN = 32 then
                com_mem(0) := "11100000000000000010000000000000001"; -- Load (111)
                com_mem(1) := "11100000000000000000000000000000000";
                com_mem(2) := "11100000000000000100000000000000010";
                com_mem(3) := "11100000000000000110000000000000011";
                com_mem(4) := "11100000000000001000000000000000100";
                com_mem(5) := "11100000000000001010000000000000101";
                com_mem(6) := "11100000000000001100000000000000110";
                com_mem(7) := "11100000000000001110000000000000111";
                com_mem(8) := "11100000000000010000000000000001000";
                com_mem(9) := "11100000000000010010000000000001001";
                com_mem(10) := "11100000000000010100000000000001010";
                com_mem(11) := "11100000000000010110000000000001011";
                com_mem(12) := "11100000000000011000000000000001100";
                com_mem(13) := "11100000000000011010000000000001101"; 
                com_mem(14) := "11100000000000011100000000000001110";
                com_mem(15) := "11100000000000011110000000000001111";
                com_mem(16) := "11000000000000000000000000000000000"; -- + (110)
                com_mem(17) := "11000000000000000010000000000000001";
                com_mem(18) := "11000000000000000100000000000000010";
                com_mem(19) := "11000000000000000110000000000000011";
                com_mem(20) := "11000000000000000000000000000000001";
                com_mem(21) := "11000000000000000010000000000000010";
                com_mem(22) := "10100000000000000000000000000000000"; -- * (101)
                com_mem(23) := "10100000000000000010000000000000001";
                com_mem(24) := "10100000000000000100000000000000010";
                com_mem(25) := "10100000000000000110000000000000011";
                com_mem(26) := "10100000000000000000000000000000001";
                com_mem(27) := "10100000000000000010000000000000010";
                com_mem(28) := "10000000000000000000000000000000000"; -- Store (100)
                com_mem(29) := "10000000000000000010000000000000001";
                com_mem(30) := "10000000000000000100000000000000010";
                com_mem(31) := "10000000000000000110000000000000011";
            
            elsif COM_MEM_LEN = 48 then
                com_mem(0) := "11100000000000000010000000000000001"; -- Load (111)
                com_mem(1) := "11100000000000000010000000000000001"; 
                com_mem(2) := "11100000000000000000000000000000000";
                com_mem(3) := "11100000000000000000000000000000000";
                com_mem(4) := "11100000000000000100000000000000010";
                com_mem(5) := "11100000000000000100000000000000010";
                com_mem(6) := "11100000000000000110000000000000011";
                com_mem(7) := "11100000000000000110000000000000011";
                com_mem(8) := "11100000000000001000000000000000100";
                com_mem(9) := "11100000000000001000000000000000100";
                com_mem(10) := "11100000000000001010000000000000101";
                com_mem(11) := "11100000000000001010000000000000101";
                com_mem(12) := "11100000000000001100000000000000110";
                com_mem(13) := "11100000000000001100000000000000110";
                com_mem(14) := "11100000000000001110000000000000111";
                com_mem(15) := "11100000000000001110000000000000111";
                com_mem(16) := "11100000000000010000000000000001000";
                com_mem(17) := "11100000000000010000000000000001000";
                com_mem(18) := "11100000000000010010000000000001001";
                com_mem(19) := "11100000000000010010000000000001001";
                com_mem(20) := "11100000000000010100000000000001010";
                com_mem(21) := "11100000000000010100000000000001010";
                com_mem(22) := "11100000000000010110000000000001011";
                com_mem(23) := "11100000000000010110000000000001011";
                com_mem(24) := "11100000000000011000000000000001100";
                com_mem(25) := "11100000000000011000000000000001100";
                com_mem(26) := "11100000000000011010000000000001101"; 
                com_mem(27) := "11100000000000011010000000000001101"; 
                com_mem(28) := "11100000000000011100000000000001110";
                com_mem(29) := "11100000000000011100000000000001110";
                com_mem(30) := "11100000000000011110000000000001111";
                com_mem(31) := "11100000000000011110000000000001111";
                com_mem(32) := "11000000000000000000000000000000000"; -- + (10)
                com_mem(33) := "11000000000000000010000000000000001";
                com_mem(34) := "11000000000000000100000000000000010";
                com_mem(35) := "11000000000000000110000000000000011";
                com_mem(36) := "11000000000000000000000000000000001";
                com_mem(37) := "11000000000000000010000000000000010";
                com_mem(38) := "10100000000000000000000000000000000"; -- * (01)
                com_mem(39) := "10100000000000000010000000000000001";
                com_mem(40) := "10100000000000000100000000000000010";
                com_mem(41) := "10100000000000000110000000000000011";
                com_mem(42) := "10100000000000000000000000000000001";
                com_mem(43) := "10100000000000000010000000000000010";
                com_mem(44) := "10000000000000000000000000000000000"; -- Store (00)
                com_mem(45) := "10000000000000000010000000000000001";
                com_mem(46) := "10000000000000000100000000000000010";
                com_mem(47) := "10000000000000000110000000000000011";
            end if;
        elsif rising_edge(clk) then
            if position < COM_MEM_LEN then
                if valid_w1 = '1' and ready_r1 = '1' then
                    valid_map1 := '0';
                end if;
                if valid_w2 = '1' and ready_r2 = '1' then
                    valid_map2 := '0';
                end if;

                if valid_w1 = '0' and ready_r1 = '1' then
                    valid_map1 := '1';
                    if com_mem(position)(LEN + LEN - 1 downto LEN) = data_out1(LEN + LEN - 1 downto LEN) and nops1 = 0 then
                        data_out1 <= nop;
                        nops1 := nops1 + 1;
                    else
                        nops1 := 0;
                        data_out1 <= com_mem(position);
                        position := position + 1;
                    end if;
                end if;
                if valid_w2 = '0' and ready_r2 = '1' then
                    valid_map2 := '1';
                    if com_mem(position)(LEN + LEN - 1 downto LEN) = data_out2(LEN + LEN - 1 downto LEN) and nops2 = 0 then
                        data_out2 <= nop;
                        nops2 := nops2 + 1;
                    else
                        nops2 := 0;
                        data_out2 <= com_mem(position);
                        position := position + 1;
                    end if;
                end if;
            else
                position := position + 1;
                valid_map1 := '0';
                valid_map2 := '0';
            end if;
            if position = COM_MEM_LEN + 15 then
                test_completed <= true;
            end if;
            valid_w1 <= valid_map1;
            valid_w2 <= valid_map2;
        end if;
    end process test_iterator;
end architecture main;