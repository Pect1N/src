LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY ID_BLOCK IS
    generic
    (
        INSTR_LEN       : INTEGER := 3;
        LEN             : INTEGER := 16;
        SUB_DATA_LEN    : INTEGER := 2
    );
    PORT (
        clk             : IN    STD_LOGIC;
        rst             : IN    STD_LOGIC;
        -- IF
        valid_r         : IN    STD_LOGIC;
        data_in         : IN    STD_LOGIC_VECTOR(LEN + LEN - 1 DOWNTO 0);
        instruction_in  : IN    STD_LOGIC_VECTOR(INSTR_LEN - 1 DOWNTO 0);
        ready_w         : OUT   STD_LOGIC;
        -- MEM
        ready_r         : IN    STD_LOGIC;
        valid_w         : OUT   STD_LOGIC;
        data_out        : OUT   STD_LOGIC_VECTOR(LEN + LEN - 1 DOWNTO 0);
        instruction_out : OUT   STD_LOGIC_VECTOR(INSTR_LEN - 1 DOWNTO 0);
        sub_data_out    : OUT   STD_LOGIC_VECTOR(SUB_DATA_LEN - 1 DOWNTO 0)
    );
END ID_BLOCK;

ARCHITECTURE rtl OF ID_BLOCK IS

BEGIN
    id_main : PROCESS (clk, rst)
        VARIABLE valid_map  : STD_LOGIC;
        VARIABLE ready_map  : STD_LOGIC;
        VARIABLE data       : STD_LOGIC_VECTOR(LEN + LEN - 1 DOWNTO 0);
        variable instr      : STD_LOGIC_VECTOR(INSTR_LEN - 1 DOWNTO 0);
        variable sub_data   : STD_LOGIC_VECTOR(SUB_DATA_LEN - 1 DOWNTO 0); -- 0 - regs 1 - memory
        -- check flag
        variable ready      : std_logic;
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
                instr := instruction_in;
                -- Load
                if instr = "111" then
                    sub_data := "10";
                -- Store
                elsif instr = "100" then
                    sub_data := "01";
                -- Math
                elsif instr = "101" or instr = "110" then
                    sub_data := "00";
                else -- nop
                    sub_data := "11";
                end if;
            END IF;
            
            IF valid_map = '0' AND ready_r = '1' and ready = '1' THEN
                instruction_out <= instr;
                data_out <= data;
                sub_data_out <= sub_data;
                valid_map := '1';
                ready_map := '1';
            END IF;
            valid_w <= valid_map;
            ready_w <= ready_map;
        END IF;
    END PROCESS id_main; -- main
END rtl; -- rtl