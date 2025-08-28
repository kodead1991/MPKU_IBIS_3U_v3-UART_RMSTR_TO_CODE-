LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY PKU_IN_BLOCK_v2 IS

    PORT (
        i_Clk : IN STD_LOGIC;
        i_kHz : IN STD_LOGIC; --125Hz
        i_PKU : IN STD_LOGIC;
        i_Rst : IN STD_LOGIC;

        o_PkuFlag : OUT STD_LOGIC := '0';
        o_PkuLen : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0')
    );
END PKU_IN_BLOCK_v2;

ARCHITECTURE arch OF PKU_IN_BLOCK_v2 IS

    --COUNTERS
    SIGNAL r_CntkHz : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');

BEGIN

    PROCESS (i_Clk)
    BEGIN
        IF falling_edge(i_Clk) THEN

            --MCU read PLU_LIST, PKU's reciece status reset
            IF (i_Rst = '1') THEN
                o_PkuFlag <= '0';
                r_CntkHz <= (OTHERS => '0');
                o_PkuLen <=  (OTHERS => '0');
            END IF;

            IF (i_kHz = '1') THEN
                IF (i_PKU = '1') THEN
                    r_CntkHz <= r_CntkHz + 1;
                    --signals get their values updated only at the end of the process.
                    --thats why I have to add '1' to temp before assigning it as output.
                ELSE

                    IF (r_CntkHz > 3) THEN -- PKU is recieved only if lenght higher then 32 ms
                        o_PkuFlag <= '1';
                        o_PkuLen <= r_CntkHz;
                    END IF;

                    r_CntkHz <= (OTHERS => '0');

                END IF;
            END IF;
        END IF;
    END PROCESS;

END arch;