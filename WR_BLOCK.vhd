LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY WR_BLOCK IS
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
		ready_w : OUT STD_LOGIC;
		valid_r : IN STD_LOGIC;
		data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		sub_data_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		load_adr_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END WR_BLOCK;

ARCHITECTURE rtl OF WR_BLOCK IS
	-- COMPONENT MEMORY IS
	-- 	PORT (
    --         clk : IN STD_LOGIC;
    --         rst : IN STD_LOGIC;
    --         flag : in std_logic;
    --         ready : OUT std_logic;
    --         read_mem : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- element adres (read)
    --         mem_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) -- element value (read)
	-- 	);
	-- END component MEMORY;

	-- COMPONENT REGISTERS IS
	-- 	PORT (
    --         clk : IN STD_LOGIC;
    --         rst : IN STD_LOGIC;
    --         flag : in std_logic;
    --         ready : OUT std_logic;
    --         read_mem : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- element adres (read)
    --         regs_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- element value (read)
	-- 	);
	-- END component REGISTERS;
BEGIN
	-- myMEMORYwr : MEMORY port map (
    --     clk => clk,
    --     rst => rst,
    --     flag => question_memory,
    --     ready => memory_data_ready,
    --     read_mem => adres,
    --     mem_out => result
    -- );

    -- myREGISTERSwr : REGISTERS port map (
    --     clk => clk,
    --     rst => rst,
    --     flag => question_registers,
    --     ready => registers_data_ready,
    --     read_mem => adres_regs,
    --     regs_out => result_regs
    -- );

	main : PROCESS (clk, rst)

		VARIABLE valid_map : STD_LOGIC;
		VARIABLE ready_map : STD_LOGIC;
		VARIABLE data : STD_LOGIC_VECTOR(7 DOWNTO 0);
		variable sub_data : STD_LOGIC_VECTOR(1 DOWNTO 0); -- 0 - regs 1 - memory
		variable load_adress : STD_LOGIC_VECTOR(3 DOWNTO 0);
		-- check flag
		variable ready : std_logic;
	BEGIN
		IF (rst = '1') THEN
			ready := '0';
			ready_w <= '0';
			data := (OTHERS => '0');
			valid_map := '0';
			ready_map := '1';
		ELSIF (rising_edge(clk)) THEN
			IF valid_map = '1' THEN
				valid_map := '0';
				ready := '0';
			END IF;

			IF ready_map = '1' AND valid_r = '1' and ready = '0' THEN
				ready_map := '0';
				ready := '1';
				data := data_in; --forming write data
				sub_data := sub_data_in;
				load_adress := load_adr_in;
				-- question_memory <= '1';
                -- question_registers <= '1';
			END IF;

			IF valid_map = '0' and ready = '1' THEN -- and (memory_data_ready = '1' or registers_data_ready = '1') then
				valid_map := '1';
				ready_map := '1';
			END IF;
			ready_w <= ready_map;
		END IF;
	END PROCESS; -- main
END rtl; -- rtl