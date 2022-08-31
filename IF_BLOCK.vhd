LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY IF_BLOCK IS
generic
    (
        INSTR_LEN   : INTEGER := 3;
        LEN         : INTEGER := 16;
        DATA_LEN    : INTEGER := 3 + 16 + 16 -- INSTR_LEN + LEN + LEN
    );
    PORT (
        clk         : IN    STD_LOGIC;
        rst         : IN    STD_LOGIC;
        -- test
        valid_r     : IN    STD_LOGIC;
        data_in     : IN    STD_LOGIC_VECTOR(DATA_LEN - 1 DOWNTO 0);
        ready_w     : OUT   STD_LOGIC;
        -- ID
        ready_r     : IN    STD_LOGIC;
        valid_w     : OUT   STD_LOGIC;
        data_out    : OUT   STD_LOGIC_VECTOR(LEN + LEN - 1 DOWNTO 0);
        instruction : OUT   STD_LOGIC_VECTOR(INSTR_LEN - 1 DOWNTO 0)
    );
END IF_BLOCK;

ARCHITECTURE rtl OF IF_BLOCK IS

BEGIN
    if_main : PROCESS (clk, rst)
        VARIABLE valid_map  : STD_LOGIC;
        VARIABLE ready_map  : STD_LOGIC;
        VARIABLE data       : STD_LOGIC_VECTOR(DATA_LEN - 1 DOWNTO 0);
        -- check flag
        variable ready : STD_LOGIC;
    BEGIN
        IF (rst = '1') THEN
            ready := '0';
            valid_w <= '0';
            ready_w <= '1';
            data := (OTHERS => '0');
            valid_map := '0';
            ready_map := '1';
        ELSIF (rising_edge(clk)) THEN
            IF valid_map = '1' AND ready_r = '1' THEN
                valid_map := '0';
                ready := '0';
            END IF;

            IF valid_r = '1' AND ready_map = '1' and ready = '0' THEN
                ready_map := '0';
                ready := '1';
                data := data_in;--forming write data
            END IF;
            
            IF valid_map = '0' AND ready_r = '1' and ready = '1' THEN
                instruction <= data(DATA_LEN - 1 DOWNTO DATA_LEN - INSTR_LEN);
                data_out <= data(LEN + LEN - 1 DOWNTO 0);
                valid_map := '1';
                ready_map := '1';
            END IF;
            valid_w <= valid_map;
            ready_w <= ready_map;
        END IF;
    END PROCESS if_main; -- main
END rtl; -- rtl