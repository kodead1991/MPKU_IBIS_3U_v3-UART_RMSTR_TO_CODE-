LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY REG_X32_BLOCK IS

    PORT (
        i_Clk : IN STD_LOGIC;
        i_En : IN STD_LOGIC;
        i_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        o_Mode : OUT STD_LOGIC := '0';
        o_Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS=>'0')
    );
END REG_X32_BLOCK;

ARCHITECTURE arch OF REG_X32_BLOCK IS

	SIGNAL r_REG : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS=>'0');

BEGIN

    PROCESS (i_Clk)
    BEGIN

        IF falling_edge(i_Clk) THEN

            IF (i_En = '1') THEN
                r_REG <= i_Data;
                o_Mode <= '1';
            ELSE
                o_Mode <= '0';
            END IF;

        END IF;

    END PROCESS;

--	r_REG <= i_Data WHEN (i_En = '1') ELSE NULL;
    
    o_Data <= r_REG;

END arch;