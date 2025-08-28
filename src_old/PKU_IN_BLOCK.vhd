LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY PKU_IN_BLOCK IS

    PORT (
        i_Clk : IN STD_LOGIC;
        i_kHz : IN STD_LOGIC; --125Hz
        i_PKU : IN STD_LOGIC;
        i_Rst : IN STD_LOGIC;

        o_PkuFlag : OUT STD_LOGIC := '0';
        o_PkuLen : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0')
    );
END PKU_IN_BLOCK;

ARCHITECTURE arch OF PKU_IN_BLOCK IS

    --STATE MACHINES
    TYPE state IS (
        s_Idle,
        s_PkuRecieve,
        s_DataStore
    );
    SIGNAL r_State : state := s_Idle;

    --COUNTERS
    SIGNAL r_CntkHz : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');

BEGIN

    PROCESS (i_PKU, i_Rst, i_kHz)
    BEGIN

        IF (r_State = s_Idle OR i_Rst = '1') THEN --reset reg PKU_LEN
            r_CntkHz <= (OTHERS => '0');
        ELSIF rising_edge(i_kHz) THEN
            IF (r_CntkHz /= "1111111") THEN
                r_CntkHz <= r_CntkHz + 1;
            END IF;
        END IF;

    END PROCESS;

    PROCESS (i_Clk)
    BEGIN
        IF falling_edge(i_Clk) THEN

            --MCU read PLU_LIST, PKU's reciece status reset
            IF (i_Rst = '1') THEN
                o_PkuFlag <= '0';
            END IF;

            CASE (r_State) IS
                    -------------------------------------------------------------
                WHEN s_Idle =>
                    IF (i_PKU = '1') THEN -- '0' is active state of i_PKU
                        r_State <= s_PkuRecieve;
                    END IF;
                    -------------------------------------------------------------
                WHEN s_PkuRecieve =>
                    IF (i_PKU = '0') THEN -- PKU's lenght is stored when i_PKU turns off (goes '1')
                        IF (r_CntkHz >= "0000100") THEN -- PKU is recieved only if lenght higher then 32 ms (4kHz)
                            o_PkuFlag <= '1';
                            o_PkuLen <= r_CntkHz;
                        END IF;
                        r_State <= s_Idle;
                    END IF;
                    -------------------------------------------------------------
                WHEN OTHERS => r_State <= s_Idle;
                    -------------------------------------------------------------
            END CASE;

        END IF;

    END PROCESS;

END arch;