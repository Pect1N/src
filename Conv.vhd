LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY conv IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        valid_test : IN STD_LOGIC;
        ready_if : OUT STD_LOGIC;
        data : IN STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END ENTITY conv;

ARCHITECTURE doing OF conv IS
    COMPONENT IF_BLOCK IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            valid_r : IN STD_LOGIC;
            ready_w : OUT STD_LOGIC;
            data_in : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            ready_r : IN STD_LOGIC;
            valid_w : OUT STD_LOGIC;
            data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            instruction : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT ID_BLOCK IS
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
            sub_data_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    END component ID_BLOCK;

    COMPONENT MEM_BLOCK IS
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
    END component MEM_BLOCK;

    COMPONENT EXP_BLOCK IS
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
    END component EXP_BLOCK;

    signal valid_if_id : std_logic;
    signal valid_id_mem : std_logic;
    signal valid_mem_exe : std_logic;

    signal ready_id_if : std_logic;
    signal ready_mem_id : std_logic;
    signal ready_exe_mem : std_logic := '1';

    signal data_if_id : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal data_id_mem : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal data_mem_exe : STD_LOGIC_VECTOR(7 DOWNTO 0);

    signal instruction_if_id : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal instruction_id_mem : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal instruction_mem_exe : STD_LOGIC_VECTOR(1 DOWNTO 0);

    signal sub_data_id_mem : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal load_data_mem_exe : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal memory_value : INTEGER;

BEGIN
    myIF : IF_BLOCK port map (
        clk => clk,
        rst => rst,
        -- connect test
        valid_r => valid_test,
        ready_w => ready_if,
        data_in => data,
        -- connect id
        ready_r => ready_id_if,
        valid_w => valid_if_id,
        data_out => data_if_id,
        instruction => instruction_if_id
    );
    myID : ID_BLOCK port map (
        clk => clk,
        rst => rst,
        -- connect if
        ready_w => ready_id_if,
        valid_r => valid_if_id,
        data_in => data_if_id,
        instruction_in => instruction_if_id,
        -- connect mem
        valid_w => valid_id_mem,
        ready_r => ready_mem_id,
        data_out => data_id_mem,
        instruction_out => instruction_id_mem,
        sub_data_out => sub_data_id_mem
    );
    myMEM : MEM_BLOCK port map (
        clk => clk,
        rst => rst,
        -- connect id
        ready_w => ready_mem_id,
        valid_r => valid_id_mem,
        data_in => data_id_mem,
        instruction_in => instruction_id_mem,
        sub_data_in => sub_data_id_mem,
        -- connect exe
        valid_w => valid_mem_exe,
        ready_r => ready_exe_mem,
        data_out => data_mem_exe,
        instruction_out => instruction_mem_exe,
        load_adr => load_data_mem_exe,
        arg1 => memory_value
    );
    myEXP : MEM_BLOCK port map (
        clk => clk,
        rst => rst,
        -- connect id
        ready_w => ready_mem_id,
        valid_r => valid_id_mem,
        data_in => data_id_mem,
        instruction_in => instruction_id_mem,
        sub_data_in => sub_data_id_mem,
        -- connect exe
        valid_w => valid_mem_exe,
        ready_r => ready_exe_mem,
        data_out => data_mem_exe,
        instruction_out => instruction_mem_exe,
        load_adr => load_data_mem_exe,
        arg1 => memory_value
    );
END ARCHITECTURE doing;