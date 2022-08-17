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
        load_adr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END MEM_BLOCK;

ARCHITECTURE rtl OF MEM_BLOCK IS
	COMPONENT MEMORY IS
		PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            read_mem : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- element adres (read)
            mem_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) -- element value (read)
		);
	END component MEMORY;

    signal result : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal adres : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN
	myMEMORY : MEMORY port map (
        clk => clk,
        rst => rst,
        read_mem => adres,
        mem_out => result
    );

	mem_main : PROCESS (clk, rst)
		-- id/exe
        VARIABLE valid_map : STD_LOGIC;
        VARIABLE ready_map : STD_LOGIC;
        VARIABLE data : STD_LOGIC_VECTOR(7 DOWNTO 0);
		variable sub_data : STD_LOGIC_VECTOR(1 DOWNTO 0); -- 0 - regs 1 - memory
		-- memory/registers
	BEGIN
        IF (rst = '1') THEN
            valid_w <= '0';
            ready_w <= '1';
            data_out <= (OTHERS => '0');
            data := (OTHERS => '0');
            valid_map := '0';
            ready_map := '1';
        ELSIF (rising_edge(clk)) THEN
            IF valid_map = '1' AND ready_r = '1' THEN
                valid_map := '0';
            END IF;

            IF valid_r = '1' AND ready_map = '1' THEN
                ready_map := '0';
                data := data_in;--forming write data
				sub_data := sub_data_in;
                adres <= data(7 downto 4);
                if sub_data = "10" OR sub_data = "01" then -- Load and Store
                    load_adr <= data(3 downto 0);
                    data(7 downto 4) := result;
                else -- Expression
                    load_adr <= data(7 downto 4);
                    data(7 downto 4) := result;
                    data(3 downto 0) := result;
                end if;
            END IF;
            
            IF valid_map = '0' AND ready_r = '1' THEN -- AND ready_memory = '1' THEN
                instruction_out <= instruction_in;
                sub_data_out <= sub_data;
                data_out <= data;
                valid_map := '1';
                ready_map := '1';
            END IF;
            valid_w <= valid_map;
            ready_w <= ready_map;
        END IF;
	END PROCESS; -- main
END rtl; -- rtl