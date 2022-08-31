LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY conv IS
    generic
    (
        INSTR_LEN       : INTEGER := 3;
        LEN             : INTEGER := 16;
        DATA_LEN        : INTEGER := 3 + 16 + 16; -- INSTR_LEN + LEN + LEN
        SUB_DATA_LEN    : INTEGER := 2;
        REG_MEM_LEN     : INTEGER := 16
    );
    PORT (
        clk                     : IN    STD_LOGIC;
        rst                     : IN    STD_LOGIC;
        -- connect if
        valid_test              : IN    STD_LOGIC;
        ready_if                : OUT   STD_LOGIC;
        data                    : IN    STD_LOGIC_VECTOR(DATA_LEN - 1 DOWNTO 0);
        -- connect memory/mem
        adres_mem_memory        : OUT   STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
        data_memory_mem         : IN    STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
        question_mem_memory     : OUT   STD_LOGIC;
        data_ready_memory_mem   : IN    STD_LOGIC;
        -- connect memory/wr
        adres_wr_memory         : OUT   STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
        data_memory_wr          : OUT   STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
        question_wr_memory      : OUT   STD_LOGIC;
        data_ready_memory_wr    : IN    STD_LOGIC
    );
END ENTITY conv;

ARCHITECTURE doing OF conv IS
    COMPONENT IF_BLOCK IS
        PORT (
            clk         : IN    STD_LOGIC;
            rst         : IN    STD_LOGIC;
            -- test
            valid_r     : IN    STD_LOGIC;
            data_in     : IN    STD_LOGIC_VECTOR(DATA_LEN - 1 DOWNTO 0);
            ready_w     : OUT   STD_LOGIC;
            -- ID
            ready_r     : IN    STD_LOGIC;
            valid_w     : OUT   STD_LOGIC;
            data_out    : OUT   STD_LOGIC_VECTOR(LEN + LEN - 1 DOWNTO 0);
            instruction : OUT   STD_LOGIC_VECTOR(INSTR_LEN - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT ID_BLOCK IS
        PORT (
            clk             : IN    STD_LOGIC;
            rst             : IN    STD_LOGIC;
            -- IF
            valid_r         : IN    STD_LOGIC;
            data_in         : IN    STD_LOGIC_VECTOR(LEN + LEN - 1 DOWNTO 0);
            instruction_in  : IN    STD_LOGIC_VECTOR(INSTR_LEN - 1 DOWNTO 0);
            ready_w         : OUT   STD_LOGIC;
            -- MEM
            ready_r         : IN    STD_LOGIC;
            valid_w         : OUT   STD_LOGIC;
            data_out        : OUT   STD_LOGIC_VECTOR(LEN + LEN - 1 DOWNTO 0);
            instruction_out : OUT   STD_LOGIC_VECTOR(INSTR_LEN - 1 DOWNTO 0);
            sub_data_out    : OUT   STD_LOGIC_VECTOR(SUB_DATA_LEN - 1 DOWNTO 0)
        );
    END component ID_BLOCK;

    COMPONENT MEM_BLOCK IS
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
    END component MEM_BLOCK;

    COMPONENT EXP_BLOCK IS
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
    END component EXP_BLOCK;

    COMPONENT WR_BLOCK IS
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
    END component WR_BLOCK;

    COMPONENT REGISTERS IS
        PORT (
            clk     : IN    STD_LOGIC;
            rst     : IN    STD_LOGIC;
            reg_rd  : OUT   STD_LOGIC_VECTOR(LEN * REG_MEM_LEN - 1 DOWNTO 0);
            reg_wr  : IN    STD_LOGIC_VECTOR(LEN * REG_MEM_LEN - 1 DOWNTO 0)
        );
    END component REGISTERS;

    signal valid_if_id      : STD_LOGIC;
    signal valid_id_mem     : STD_LOGIC;
    signal valid_mem_exp    : STD_LOGIC;
    signal valid_exp_wr     : STD_LOGIC;

    signal ready_id_if      : STD_LOGIC;
    signal ready_mem_id     : STD_LOGIC;
    signal ready_exp_mem    : STD_LOGIC;
    signal ready_wr_exp     : STD_LOGIC;

    signal data_if_id   : STD_LOGIC_VECTOR(LEN + LEN - 1 DOWNTO 0);
    signal data_id_mem  : STD_LOGIC_VECTOR(LEN + LEN - 1 DOWNTO 0);
    signal data_mem_exp : STD_LOGIC_VECTOR(LEN + LEN - 1 DOWNTO 0);
    signal data_exp_wr  : STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);

    signal instruction_if_id    : STD_LOGIC_VECTOR(INSTR_LEN - 1 DOWNTO 0);
    signal instruction_id_mem   : STD_LOGIC_VECTOR(INSTR_LEN - 1 DOWNTO 0);
    signal instruction_mem_exp  : STD_LOGIC_VECTOR(INSTR_LEN - 1 DOWNTO 0);

    signal sub_data_id_mem  : STD_LOGIC_VECTOR(SUB_DATA_LEN - 1 DOWNTO 0);
    signal sub_data_mem_exp : STD_LOGIC_VECTOR(SUB_DATA_LEN - 1 DOWNTO 0);
    signal sub_data_exp_wr  : STD_LOGIC_VECTOR(SUB_DATA_LEN - 1 DOWNTO 0);
    
    signal load_adres_mem_exp   : STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
    signal load_adres_exp_wr    : STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);

    signal adres_mem_registers      : STD_LOGIC_VECTOR(LEN + LEN - 1 DOWNTO 0);
    signal data_registers_mem       : STD_LOGIC_VECTOR(LEN + LEN - 1 DOWNTO 0);
    signal question_mem_registers   : STD_LOGIC;
    signal data_ready_registers_mem : STD_LOGIC;

    signal adres_wr_registers       : STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
    signal data_wr_registers        : STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
    signal question_wr_registers    : STD_LOGIC;
    signal data_ready_registers_wr  : STD_LOGIC;

    signal reg_to_mem   : STD_LOGIC_VECTOR(LEN * REG_MEM_LEN - 1 downto 0);
    signal wr_to_reg    : STD_LOGIC_VECTOR(LEN * REG_MEM_LEN - 1 downto 0);

    signal overflow_add : STD_LOGIC;

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
        -- connect exp
        valid_w => valid_mem_exp,
        ready_r => ready_exp_mem,
        data_out => data_mem_exp,
        instruction_out => instruction_mem_exp,
        sub_data_out => sub_data_mem_exp,
        load_adr => load_adres_mem_exp,
        -- connect memory
        adres_memory => adres_mem_memory,
        memory_data => data_memory_mem,
        question_memory => question_mem_memory,
        memory_data_ready => data_ready_memory_mem,
        -- connect registers
        registers_data => reg_to_mem
    );
    myEXP : EXP_BLOCK port map (
        clk => clk,
        rst => rst,
        Overflow => overflow_add,
        -- connect mem
        ready_w => ready_exp_mem,
        valid_r => valid_mem_exp,
        data_in => data_mem_exp,
        instruction_in => instruction_mem_exp,
        sub_data_in => sub_data_mem_exp,
        load_adr_in => load_adres_mem_exp,
        -- connect wr
        valid_w => valid_exp_wr,
        ready_r => ready_wr_exp,
        data_out => data_exp_wr,
        sub_data_out => sub_data_exp_wr,
        load_adr_out => load_adres_exp_wr
    );
    myWR : WR_BLOCK port map (
        clk => clk,
        rst => rst,
        -- connect exp
        valid_r => valid_exp_wr,
        ready_w => ready_wr_exp,
        data_in => data_exp_wr,
        load_adr_in => load_adres_exp_wr,
        sub_data_in => sub_data_exp_wr,
        -- connect memory
        adres_memory => adres_wr_memory,
        memory_data => data_memory_wr,
        question_memory => question_wr_memory,
        memory_data_ready => data_ready_memory_wr,
        -- connect registers
        registers_data => wr_to_reg
    );
    myREG : REGISTERS port map (
        clk => clk,
        rst => rst,
        -- mem
        reg_rd => reg_to_mem,
        -- wr
        reg_wr => wr_to_reg
    );

END ARCHITECTURE doing;