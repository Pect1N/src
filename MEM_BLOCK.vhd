LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY MEM_BLOCK IS
    generic
    (
        INSTR_LEN       : INTEGER := 3;
        LEN             : INTEGER := 16;
        SUB_DATA_LEN    : INTEGER := 2;
        REG_MEM_LEN     : INTEGER := 16
    );
	PORT (
		clk                 : IN    STD_LOGIC;
		rst                 : IN    STD_LOGIC;
        -- ID   
		valid_r             : IN    STD_LOGIC;
		data_in             : IN    STD_LOGIC_VECTOR(LEN + LEN - 1 DOWNTO 0);
		instruction_in      : IN    STD_LOGIC_VECTOR(INSTR_LEN - 1 DOWNTO 0);
		sub_data_in         : IN    STD_LOGIC_VECTOR(SUB_DATA_LEN - 1 DOWNTO 0);
		ready_w             : OUT   STD_LOGIC;
        -- EXP
		ready_r             : IN    STD_LOGIC;
		valid_w             : OUT   STD_LOGIC;
		data_out            : OUT   STD_LOGIC_VECTOR(LEN + LEN - 1 DOWNTO 0);
		instruction_out     : OUT   STD_LOGIC_VECTOR(INSTR_LEN - 1 DOWNTO 0);
		sub_data_out        : OUT   STD_LOGIC_VECTOR(SUB_DATA_LEN - 1 DOWNTO 0);
        load_adr            : OUT   STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
        -- memory   
        memory_data         : IN    STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
        memory_data_ready   : IN    STD_LOGIC;
        adres_memory        : OUT   STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
        question_memory     : OUT   STD_LOGIC;
        -- registers
        registers_data      : IN    STD_LOGIC_VECTOR(LEN * REG_MEM_LEN - 1 DOWNTO 0)
	);
END MEM_BLOCK;

ARCHITECTURE rtl OF MEM_BLOCK IS

BEGIN
	mem_main : PROCESS (clk, rst)
		-- id/exe
        VARIABLE valid_map              : STD_LOGIC;
        VARIABLE ready_map              : STD_LOGIC;
        VARIABLE data                   : STD_LOGIC_VECTOR(LEN + LEN - 1 DOWNTO 0);
		VARIABLE sub_data               : STD_LOGIC_VECTOR(SUB_DATA_LEN - 1 DOWNTO 0); -- 0 - regs 1 - memory
        -- memory / registers
        VARIABLE reg_data               : STD_LOGIC_VECTOR(LEN * REG_MEM_LEN - 1 DOWNTO 0);
        -- check flag
        VARIABLE ready                  : STD_LOGIC;
        VARIABLE registers_data_ready   : STD_LOGIC;
        VARIABLE nop_ready              : STD_LOGIC;
        VARIABLE ind1                   : INTEGER;
        VARIABLE ind2                   : INTEGER;
	BEGIN
        IF (rst = '1') THEN
            ready := '0';
            nop_ready := '0';
            valid_w <= '0';
            ready_w <= '1';
            data := (OTHERS => '0');
            valid_map := '0';
            ready_map := '1';
        ELSIF (rising_edge(clk)) THEN
            IF valid_map = '1' AND ready_r = '1' THEN
                valid_map := '0';
                ready := '0';
                registers_data_ready := '0';
            END IF;

            IF valid_r = '1' AND ready_map = '1' AND ready = '0' THEN
                ready_map := '0';
                ready := '1';
                data := data_in;--forming write data
				sub_data := sub_data_in;
                ind1 := to_integer(unsigned(data(LEN + LEN - 1 DOWNTO LEN)));
                ind2 := to_integer(unsigned(data(LEN - 1 DOWNTO 0)));
                if sub_data = "10" THEN
                    adres_memory <= data(LEN + LEN - 1 DOWNTO LEN);
                    question_memory <= '1';
                elsif sub_data = "00" THEN
                    data(LEN + LEN - 1 DOWNTO LEN) := reg_data((LEN * REG_MEM_LEN - 1) - ind1 * LEN DOWNTO (LEN * REG_MEM_LEN - 1) - ind1 * LEN - LEN + 1);
                    data(LEN - 1 DOWNTO 0) := reg_data((LEN * REG_MEM_LEN - 1) - ind2 * LEN DOWNTO (LEN * REG_MEM_LEN - 1) - ind2 * LEN - LEN + 1);
                    registers_data_ready := '1';
                elsif sub_data = "01" THEN
                    data(LEN + LEN - 1 DOWNTO LEN) := reg_data((LEN * REG_MEM_LEN - 1) - ind2 * LEN DOWNTO (LEN * REG_MEM_LEN - 1) - ind2 * LEN - LEN + 1);
                    registers_data_ready := '1';
                else
                    nop_ready := '1';
                end if;
            END IF;
            
            IF valid_map = '0' AND ready_r = '1' AND ready = '1' AND (memory_data_ready = '1' OR registers_data_ready = '1' OR nop_ready = '1') THEN
                if sub_data = "10" THEN -- Load and Store
                    load_adr <= data(LEN - 1 DOWNTO 0);
                    data(LEN + LEN - 1 DOWNTO LEN) := memory_data;
                else -- Expression
                    load_adr <= STD_LOGIC_VECTOR(to_unsigned(ind1, LEN));
                end if;
                instruction_out <= instruction_in;
                sub_data_out <= sub_data;
                data_out <= data;
                question_memory <= '0';
                nop_ready := '0';
                valid_map := '1';
                ready_map := '1';
            END IF;
            valid_w <= valid_map;
            ready_w <= ready_map;
            reg_data := registers_data;
        END IF;
	END PROCESS; -- main
END rtl; -- rtl