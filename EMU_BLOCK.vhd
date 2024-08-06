LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY EMU_BLOCK IS

    PORT (
        i_Clk : IN STD_LOGIC;
        i_WE : IN STD_LOGIC;
        i_Addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        i_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_BaseAddr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        o_EMU_Mode : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0')
    );
END EMU_BLOCK;

ARCHITECTURE arch OF EMU_BLOCK IS

    --REGS
    SIGNAL r_Key : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

BEGIN

    PROCESS (i_Clk)
    BEGIN

        IF falling_edge(i_Clk) THEN
            IF (i_WE = '1') THEN

                IF (i_Addr = i_BaseAddr) THEN
                    r_Key <= i_Data;
                END IF;

            END IF;
        END IF;

    END PROCESS;

    o_EMU_MODE(3 DOWNTO 0) <=
    "0110" WHEN (r_Key(1 DOWNTO 0) = "01") ELSE
    "1001" WHEN (r_Key(1 DOWNTO 0) = "10") ELSE
    "0000";

    o_EMU_MODE(7 DOWNTO 4) <=
    "0110" WHEN (r_Key(3 DOWNTO 2) = "01") ELSE
    "1001" WHEN (r_Key(3 DOWNTO 2) = "10") ELSE
    "0000";

    o_EMU_MODE(11 DOWNTO 8) <=
    "0110" WHEN (r_Key(5 DOWNTO 4) = "01") ELSE
    "1001" WHEN (r_Key(5 DOWNTO 4) = "10") ELSE
    "0000";

    o_EMU_MODE(15 DOWNTO 12) <=
    "0110" WHEN (r_Key(7 DOWNTO 6) = "01") ELSE
    "1001" WHEN (r_Key(7 DOWNTO 6) = "10") ELSE
    "0000";

    o_EMU_MODE(19 DOWNTO 16) <=
    "0110" WHEN (r_Key(9 DOWNTO 8) = "01") ELSE
    "1001" WHEN (r_Key(9 DOWNTO 8) = "10") ELSE
    "0000";

    o_EMU_MODE(23 DOWNTO 20) <=
    "0110" WHEN (r_Key(11 DOWNTO 10) = "01") ELSE
    "1001" WHEN (r_Key(11 DOWNTO 10) = "10") ELSE
    "0000";

END arch;