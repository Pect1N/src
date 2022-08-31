LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY WR_BLOCK IS
    generic
    (
        LEN             : INTEGER := 16;
        SUB_DATA_LEN    : INTEGER := 2;
        REG_MEM_LEN     : INTEGER := 16
    );
	PORT (
		clk 				: IN 	STD_LOGIC;
		rst 				: IN 	STD_LOGIC;
		-- EXP
		valid_r 			: IN 	STD_LOGIC;
		data_in 			: IN 	STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
		sub_data_in 		: IN 	STD_LOGIC_VECTOR(SUB_DATA_LEN - 1 DOWNTO 0);
		load_adr_in 		: IN 	STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
		ready_w 			: OUT 	STD_LOGIC;
		-- memory
        memory_data_ready 	: IN 	STD_LOGIC;
		adres_memory 		: OUT 	STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
        memory_data 		: OUT 	STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
        question_memory 	: OUT 	STD_LOGIC;
		-- registers
		registers_data 		: OUT 	STD_LOGIC_VECTOR(LEN * REG_MEM_LEN - 1 DOWNTO 0)
	);
END WR_BLOCK;

ARCHITECTURE rtl OF WR_BLOCK IS

BEGIN
	main : PROCESS (clk, rst)

		VARIABLE valid_map 				: STD_LOGIC;
		VARIABLE ready_map 				: STD_LOGIC;
		VARIABLE data 					: STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
		VARIABLE sub_data 				: STD_LOGIC_VECTOR(SUB_DATA_LEN - 1 DOWNTO 0); -- 0 - regs 1 - memory
		VARIABLE load_adress 			: STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
		VARIABLE reg_data 				: STD_LOGIC_VECTOR(LEN * REG_MEM_LEN - 1 DOWNTO 0);
		VARIABLE reg_adres 				: INTEGER;
		-- check flag		
		VARIABLE ready 					: STD_LOGIC;
		VARIABLE registers_data_ready 	: STD_LOGIC;
		VARIABLE nop_ready              : STD_LOGIC;
	BEGIN
		IF (rst = '1') THEN
			ready := '0';
			nop_ready := '0';
			ready_w <= '0';
			data := (OTHERS => '0');
			valid_map := '0';
			ready_map := '1';
		ELSIF (rising_edge(clk)) THEN
			IF valid_map = '1' THEN
				valid_map := '0';
				ready := '0';
				registers_data_ready := '0';
			END IF;

			IF ready_map = '1' AND valid_r = '1' and ready = '0' THEN
				ready_map := '0';
				ready := '1';
				data := data_in; --forming write data
				sub_data := sub_data_in;
				load_adress := load_adr_in;
				reg_adres := to_integer(unsigned(load_adr_in));
                if sub_data = "01" then
                    adres_memory <= load_adress;
					memory_data <= data;
                    question_memory <= '1';
                elsif sub_data = "10" OR sub_data = "00" then
					reg_data((LEN * REG_MEM_LEN - 1) - reg_adres * LEN DOWNTO (LEN * REG_MEM_LEN - 1) - reg_adres * LEN - LEN + 1) := data;
					registers_data_ready := '1';
				else
                    nop_ready := '1';
                end if;
			END IF;

			IF valid_map = '0' AND ready = '1' AND (memory_data_ready = '1' OR registers_data_ready = '1' OR nop_ready = '1') then
				valid_map := '1';
				ready_map := '1';
				nop_ready := '0';
			END IF;
			ready_w <= ready_map;
			registers_data <= reg_data;
		END IF;
	END PROCESS; -- main
END rtl; -- rtl