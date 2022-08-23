LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY IF_BLOCK IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        valid_w : OUT STD_LOGIC;
        ready_w : OUT STD_LOGIC;
        valid_r : IN STD_LOGIC;
        ready_r : IN STD_LOGIC;
        data_in : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        instruction : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END IF_BLOCK;

ARCHITECTURE rtl OF IF_BLOCK IS

BEGIN
    if_main : PROCESS (clk, rst)
        VARIABLE valid_map : STD_LOGIC;
        VARIABLE ready_map : STD_LOGIC;
        VARIABLE data : STD_LOGIC_VECTOR(9 DOWNTO 0);
        -- check flag
        variable ready : std_logic;
    BEGIN
        IF (rst = '1') THEN
            ready := '0';
            valid_w <= '0';
            ready_w <= '1';
            --instruction <= (OTHERS => '1');
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
                instruction <= data(9 downto 8);
                data_out <= data(7 downto 0);
                valid_map := '1';
                ready_map := '1';
            END IF;
            valid_w <= valid_map;
            ready_w <= ready_map;
        END IF;
    END PROCESS if_main; -- main
END rtl; -- rtl