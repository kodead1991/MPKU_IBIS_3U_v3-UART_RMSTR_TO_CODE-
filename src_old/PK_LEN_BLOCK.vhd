LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY PK_LEN_BLOCK IS

    PORT (
        i_Clk : IN STD_LOGIC;
        i_En : IN STD_LOGIC;
        i_Addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        i_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_BaseAddr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        o_Pk0_Len : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
        o_Pk1_Len : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
        o_Pk2_Len : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
        o_Pk3_Len : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
        o_Pk4_Len : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
        o_Pk5_Len : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
        o_Pk6_Len : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
        o_Pk7_Len : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
        o_Pk8_Len : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
        o_Pk9_Len : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
        o_Pk10_Len : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
        o_Pk11_Len : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0')
    );
END PK_LEN_BLOCK;

ARCHITECTURE arch OF PK_LEN_BLOCK IS

    CONSTANT c_Addr_Pk0_Len : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    CONSTANT c_Addr_Pk1_Len : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0001";
    CONSTANT c_Addr_Pk2_Len : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0002";
    CONSTANT c_Addr_Pk3_Len : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0003";
    CONSTANT c_Addr_Pk4_Len : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0004";
    CONSTANT c_Addr_Pk5_Len : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0005";
    CONSTANT c_Addr_Pk6_Len : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0006";
    CONSTANT c_Addr_Pk7_Len : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0007";
    CONSTANT c_Addr_Pk8_Len : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0008";
    CONSTANT c_Addr_Pk9_Len : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0009";
    CONSTANT c_Addr_Pk10_Len : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"000A";
    CONSTANT c_Addr_Pk11_Len : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"000B";

BEGIN

    PROCESS (i_Clk)
    BEGIN

        IF falling_edge(i_Clk) THEN

            IF (i_En = '1') THEN
                IF (i_Addr = i_BaseAddr + c_Addr_Pk0_Len) THEN
                    o_Pk0_Len <= i_Data(9 DOWNTO 3);
                END IF;

                IF (i_Addr = i_BaseAddr + c_Addr_Pk1_Len) THEN
                    o_Pk1_Len <= i_Data(9 DOWNTO 3);
                END IF;

                IF (i_Addr = i_BaseAddr + c_Addr_Pk2_Len) THEN
                    o_Pk2_Len <= i_Data(9 DOWNTO 3);
                END IF;

                IF (i_Addr = i_BaseAddr + c_Addr_Pk3_Len) THEN
                    o_Pk3_Len <= i_Data(9 DOWNTO 3);
                END IF;

                IF (i_Addr = i_BaseAddr + c_Addr_Pk4_Len) THEN
                    o_Pk4_Len <= i_Data(9 DOWNTO 3);
                END IF;

                IF (i_Addr = i_BaseAddr + c_Addr_Pk5_Len) THEN
                    o_Pk5_Len <= i_Data(9 DOWNTO 3);
                END IF;

                IF (i_Addr = i_BaseAddr + c_Addr_Pk6_Len) THEN
                    o_Pk6_Len <= i_Data(9 DOWNTO 3);
                END IF;

                IF (i_Addr = i_BaseAddr + c_Addr_Pk7_Len) THEN
                    o_Pk7_Len <= i_Data(9 DOWNTO 3);
                END IF;

                IF (i_Addr = i_BaseAddr + c_Addr_Pk8_Len) THEN
                    o_Pk8_Len <= i_Data(9 DOWNTO 3);
                END IF;

                IF (i_Addr = i_BaseAddr + c_Addr_Pk9_Len) THEN
                    o_Pk9_Len <= i_Data(9 DOWNTO 3);
                END IF;

                IF (i_Addr = i_BaseAddr + c_Addr_Pk10_Len) THEN
                    o_Pk10_Len <= i_Data(9 DOWNTO 3);
                END IF;

                IF (i_Addr = i_BaseAddr + c_Addr_Pk11_Len) THEN
                    o_Pk11_Len <= i_Data(9 DOWNTO 3);
                END IF;
            END IF;

        END IF;

    END PROCESS;

END arch;