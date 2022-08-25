LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY MEM_BLOCK IS
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
		valid_w : OUT STD_LOGIC;
		ready_w : OUT STD_LOGIC;
		valid_r : IN STD_LOGIC;
		ready_r : IN STD_LOGIC;
		data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		instruction_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		instruction_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		sub_data_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		sub_data_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        load_adr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        -- memory
        adres_memory : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        memory_data : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        question_memory : OUT STD_LOGIC;
        memory_data_ready : IN STD_LOGIC;
        -- registers
        adres_registers : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        registers_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        question_registers : OUT STD_LOGIC;
        registers_data_ready : IN STD_LOGIC
	);
END MEM_BLOCK;

ARCHITECTURE rtl OF MEM_BLOCK IS

BEGIN
	mem_main : PROCESS (clk, rst)
		-- id/exe
        VARIABLE valid_map : STD_LOGIC;
        VARIABLE ready_map : STD_LOGIC;
        VARIABLE data : STD_LOGIC_VECTOR(7 DOWNTO 0);
		variable sub_data : STD_LOGIC_VECTOR(1 DOWNTO 0); -- 0 - regs 1 - memory
        -- memory / registers

        -- check flag
        variable ready : std_logic;
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
				sub_data := sub_data_in;
                if sub_data = "10" then
                    adres_memory <= data(7 downto 4);
                    question_memory <= '1';
                elsif sub_data = "00" or sub_data = "01" then
                    adres_registers <= data;
                    question_registers <= '1';
                end if;
            END IF;
            
            IF valid_map = '0' AND ready_r = '1' and ready = '1' and (memory_data_ready = '1' or registers_data_ready = '1') THEN
                if sub_data = "10" then -- Load and Store
                    load_adr <= data(3 downto 0);
                    data(7 downto 4) := memory_data;
                else -- Expression
                    load_adr <= data(7 downto 4);
                    data := registers_data;
                end if;
                instruction_out <= instruction_in;
                sub_data_out <= sub_data;
                data_out <= data;
                question_memory <= '0';
                question_registers <= '0';
                valid_map := '1';
                ready_map := '1';
            END IF;
            valid_w <= valid_map;
            ready_w <= ready_map;
        END IF;
	END PROCESS; -- main
END rtl; -- rtl