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
		instruction_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		sub_data_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		arg1 : OUT INTEGER;
		load_adr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END EXP_BLOCK;

ARCHITECTURE rtl OF EXP_BLOCK IS

BEGIN

	main : PROCESS (clk, rst)

		VARIABLE valid_map : STD_LOGIC;
		VARIABLE ready_map : STD_LOGIC;
		VARIABLE data : STD_LOGIC_VECTOR(9 DOWNTO 0);
	BEGIN
		IF (rst = '1') THEN
			valid <= '0';
			ready <= '0';
			data_out <= (OTHERS => '0');
			data := (OTHERS => '0');
			valid_map := '0';
			ready_map := '0';
		ELSIF (rising_edge(clk)) THEN
			IF valid_map = '1' AND ready_mem = '1' THEN
				valid_map = '0';
			END IF;
			IF ready_map = '1' AND valid_mem = '1' THEN
				data := data_in;--forming write data

				ready_map = '0';
			END IF;
			IF valid_map = '0' THEN
				data_out <= data;
				valid_map = '1';
				ready_map = '1';
			END IF;
			valid <= valid_map;
			ready <= ready_map;
		END IF;
	END PROCESS; -- main
END rtl; -- rtl