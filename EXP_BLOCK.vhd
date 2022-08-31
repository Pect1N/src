LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY EXP_BLOCK IS
    generic
    (
        INSTR_LEN       : INTEGER := 3;
        LEN             : INTEGER := 16;
        SUB_DATA_LEN    : INTEGER := 2
    );
	PORT (
		clk 			: IN 	STD_LOGIC;
		rst 			: IN 	STD_LOGIC;
		Overflow 		: OUT 	STD_LOGIC;
		-- MEM
		valid_r 		: IN 	STD_LOGIC;
		data_in 		: IN 	STD_LOGIC_VECTOR(LEN + LEN - 1 DOWNTO 0);
		instruction_in 	: IN 	STD_LOGIC_VECTOR(INSTR_LEN - 1 DOWNTO 0);
		sub_data_in 	: IN 	STD_LOGIC_VECTOR(SUB_DATA_LEN - 1 DOWNTO 0);
		load_adr_in 	: IN 	STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
		ready_w 		: OUT 	STD_LOGIC;
		-- WR
		ready_r 		: IN 	STD_LOGIC;
		valid_w 		: OUT 	STD_LOGIC;
		data_out 		: OUT 	STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
		sub_data_out 	: OUT 	STD_LOGIC_VECTOR(SUB_DATA_LEN - 1 DOWNTO 0);
		load_adr_out 	: OUT 	STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0)
	);
END EXP_BLOCK;

ARCHITECTURE rtl OF EXP_BLOCK IS
	constant  add : STD_LOGIC_VECTOR (LEN - 1 DOWNTO 0)  := "0000000000000001";
BEGIN
	exp_main : PROCESS (clk, rst)
		VARIABLE valid_map 	: STD_LOGIC;
		VARIABLE ready_map 	: STD_LOGIC;
		VARIABLE data 		: STD_LOGIC_VECTOR(LEN + LEN - 1 DOWNTO 0);
		VARIABLE instr 		: STD_LOGIC_VECTOR(INSTR_LEN - 1 DOWNTO 0);
		VARIABLE arg1 		: STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
		VARIABLE arg2 		: STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
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

			IF ready_map = '1' AND valid_r = '1' and ready = '0' THEN
				ready_map := '0';
				ready := '1';
				data := data_in;--forming write data
				instr := instruction_in;
				arg1 := data(LEN + LEN - 1 DOWNTO LEN);
				arg2 := data(LEN - 1 DOWNTO 0);
			END IF;

			IF valid_map = '0' AND ready_r = '1' and ready = '1' THEN
				sub_data_out <= sub_data_in;
				load_adr_out <= load_adr_in;
				if instr = "110" then
					if arg1(LEN - 1) = '0' and arg2(LEN - 1) = '0' then -- bouth > 0
						arg1 := arg1 + arg2;
						if arg1(LEN - 1) = '1' then
							Overflow <= '1';
							arg1(LEN - 1) := '0';
						end if;
					elsif arg1(LEN - 1 ) = '1' and arg2(LEN - 1) = '1' then -- оба отрицательные
						arg1 := arg1 + arg2;
						if arg1(LEN - 1) = '1' then
							Overflow <= '1';
						else
							arg1(LEN - 1) := '1';
						end if;
					else -- один отрицательный
						if arg1(LEN - 1) = '1' then -- первый отрицательный
							arg1(LEN - 2 DOWNTO 0) := not(arg1(LEN - 2 DOWNTO 0));
							arg1 := arg1 + arg2;
							if arg1(LEN - 1) = '1' then
								arg1(LEN - 2 DOWNTO 0) := not(arg1(LEN - 2 DOWNTO 0));
							else
								arg1 := arg1 + add;
							end if;
						else -- второй отрицательный
							arg2(LEN - 2 DOWNTO 0) := not(arg2(LEN - 2 DOWNTO 0));
							arg1 := arg1 + arg2;
							if arg1(LEN - 1) = '1' then
								arg1(LEN - 2 DOWNTO 0) := not(arg1(LEN - 2 DOWNTO 0));
							else
								arg1 := arg1 + add;
							end if;
						end if;
					end if;
				elsif instr = "101" then
					if arg1(LEN - 1) = '0' then
						if arg2(LEN - 1) = '0' then
							arg1 := arg1((LEN / 2 - 1) DOWNTO 0) * arg2((LEN / 2 - 1) DOWNTO 0);
						else
							arg1 := arg1((LEN / 2 - 1) DOWNTO 0) * arg2((LEN / 2 - 1) DOWNTO 0);
							arg1(LEN - 1) := '1';
						end if;
					else
						if arg2(LEN - 1) = '0' then
							arg1 := arg1((LEN / 2 - 1) DOWNTO 0) * arg2((LEN / 2 - 1) DOWNTO 0);
							arg1(LEN - 1) := '1';
						else
							arg1 := arg1((LEN / 2 - 1) DOWNTO 0) * arg2((LEN / 2 - 1) DOWNTO 0);
							arg1(LEN - 1) := '0';
						end if;
					end if;
				end if;
				data_out <= arg1;
				valid_map := '1';
				ready_map := '1';
			END IF;
			valid_w <= valid_map;
			ready_w <= ready_map;
		END IF;
	END PROCESS exp_main; -- main
END rtl; -- rtl