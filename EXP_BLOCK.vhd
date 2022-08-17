LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY EXP_BLOCK IS
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
		sub_data_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		sub_data_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		load_adr_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		load_adr_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END EXP_BLOCK;

ARCHITECTURE rtl OF EXP_BLOCK IS

BEGIN
	exp_main : PROCESS (clk, rst)

		VARIABLE valid_map : STD_LOGIC;
		VARIABLE ready_map : STD_LOGIC;
		VARIABLE data : STD_LOGIC_VECTOR(7 DOWNTO 0);
		VARIABLE instr : STD_LOGIC_VECTOR(1 DOWNTO 0);
		VARIABLE arg1 : INTEGER;
		VARIABLE arg2 : INTEGER;
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

			IF ready_map = '1' AND valid_r = '1' THEN
				ready_map := '0';
				data := data_in;--forming write data
				instr := instruction_in;
				arg1 := to_integer(unsigned(data(7 downto 4)));
				arg2 := to_integer(unsigned(data(3 downto 0)));
				if instr = "10" then
					arg1 := arg1 + arg2;
					data(7 downto 4) := std_logic_vector(to_signed(arg1, 4));
				elsif instr = "11" then
					arg1 := arg1 * arg2;
					data(7 downto 4) := std_logic_vector(to_signed(arg1, 4));
				end if;
			END IF;

			IF valid_map = '0' THEN
				sub_data_out <= sub_data_in;
				load_adr_out <= load_adr_in;
				data_out <= data;
				valid_map := '1';
				ready_map := '1';
			END IF;
			valid_w <= valid_map;
			ready_w <= ready_map;
		END IF;
	END PROCESS exp_main; -- main
END rtl; -- rtl