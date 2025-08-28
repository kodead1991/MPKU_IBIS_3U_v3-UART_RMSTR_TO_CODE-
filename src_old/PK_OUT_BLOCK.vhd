LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY PK_OUT_BLOCK IS

    PORT (
        i_Clk : IN STD_LOGIC;
        i_kHz : IN STD_LOGIC;
        i_En : IN STD_LOGIC;
        i_PkLen : IN STD_LOGIC_VECTOR(6 DOWNTO 0);

        o_Pk : OUT STD_LOGIC := '0'
    );
END PK_OUT_BLOCK;

ARCHITECTURE arch OF PK_OUT_BLOCK IS

    --REGS
    SIGNAL r_Cnt : STD_LOGIC_VECTOR(6 DOWNTO 0) := i_PkLen;
    SIGNAL r_PkEn : STD_LOGIC := '0';

BEGIN

    PROCESS (i_Clk)
    BEGIN

        IF falling_edge (i_Clk) THEN
            IF (r_Cnt = i_PkLen) THEN
                r_PkEn <= '0';
            ELSIF (i_EN = '1') THEN
                r_PkEn <= '1';
                r_Cnt <= (OTHERS => '0');
            END IF;

            IF (r_PkEn = '0') THEN
                r_Cnt <= (OTHERS => '0');
            ELSIF (i_kHz = '1') THEN
                r_Cnt <= r_Cnt + 1;
            END IF;
        END IF;

    END PROCESS;

    o_Pk <= r_PkEn;

END arch;