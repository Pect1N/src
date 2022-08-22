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
            flag : in std_logic;
            ready : OUT std_logic;
            read_mem : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- element adres (read)
            mem_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) -- element value (read)
		);
	END component MEMORY;

	COMPONENT REGISTERS IS
		PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            flag : in std_logic;
            ready : OUT std_logic;
            read_mem : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- element adres (read)
            regs_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- element value (read)
		);
	END component REGISTERS;

    signal result : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal adres : STD_LOGIC_VECTOR(3 DOWNTO 0);
    
    signal result_regs : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal adres_regs : STD_LOGIC_VECTOR(7 DOWNTO 0);

    signal memory_data_ready : std_logic;
    signal registers_data_ready : std_logic;
    signal question_memory : std_logic;
    signal question_registers : std_logic;

BEGIN
	myMEMORY : MEMORY port map (
        clk => clk,
        rst => rst,
        flag => question_memory,
        ready => memory_data_ready,
        read_mem => adres,
        mem_out => result
    );

    myREGISTERS : REGISTERS port map (
        clk => clk,
        rst => rst,
        flag => question_registers,
        ready => registers_data_ready,
        read_mem => adres_regs,
        regs_out => result_regs
    );

	mem_main : PROCESS (clk, rst)
        variable ready : std_logic;
		-- id/exe
        VARIABLE valid_map : STD_LOGIC;
        VARIABLE ready_map : STD_LOGIC;
        VARIABLE data : STD_LOGIC_VECTOR(7 DOWNTO 0);
		variable sub_data : STD_LOGIC_VECTOR(1 DOWNTO 0); -- 0 - regs 1 - memory
        -- memory / registers

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
                adres <= data(7 downto 4);
                adres_regs <= data;
                question_memory <= '1';
                question_registers <= '1';
            END IF;
            
            IF valid_map = '0' AND ready_r = '1' and ready = '1' and (memory_data_ready = '1' or registers_data_ready = '1') THEN
                instruction_out <= instruction_in;
                sub_data_out <= sub_data;
                data_out <= data;
                if sub_data = "10" OR sub_data = "01" then -- Load and Store
                    load_adr <= data(3 downto 0);
                    data(7 downto 4) := result;
                else -- Expression
                    load_adr <= data(7 downto 4);
                    data := result_regs;
                end if;
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