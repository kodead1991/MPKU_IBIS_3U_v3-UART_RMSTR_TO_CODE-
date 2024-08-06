LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY PKU_DATA_BLOCK IS

    PORT (
        i_Addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        i_BaseAddr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        i_PKU0_LEN : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        i_PKU1_LEN : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        i_PKU2_LEN : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        i_PKU3_LEN : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        i_PKU4_LEN : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        i_PKU5_LEN : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        i_PKU6_LEN : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        i_PKU7_LEN : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        i_PKU8_LEN : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        i_PKU9_LEN : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        i_PKU10_LEN : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        i_PKU11_LEN : IN STD_LOGIC_VECTOR(6 DOWNTO 0);

        i_PKU_LIST : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        o_Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_RE : OUT STD_LOGIC := '0'
    );
END PKU_DATA_BLOCK;

ARCHITECTURE arch OF PKU_DATA_BLOCK IS

    CONSTANT c_Addr_PKU0 : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    CONSTANT c_Addr_PKU1 : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0001";
    CONSTANT c_Addr_PKU2 : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0002";
    CONSTANT c_Addr_PKU3 : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0003";
    CONSTANT c_Addr_PKU4 : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0004";
    CONSTANT c_Addr_PKU5 : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0005";
    CONSTANT c_Addr_PKU6 : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0006";
    CONSTANT c_Addr_PKU7 : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0007";
    CONSTANT c_Addr_PKU8 : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0008";
    CONSTANT c_Addr_PKU9 : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0009";
    CONSTANT c_Addr_PKU10 : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"000A";
    CONSTANT c_Addr_PKU11 : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"000B";
    CONSTANT c_Addr_PKU_LIST : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0018";

    SIGNAL r_Data : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');

BEGIN

    r_Data <=
        "00" & i_PKU0_LEN & "000" WHEN (i_Addr = i_BaseAddr + c_Addr_PKU0) ELSE
        "00" & i_PKU1_LEN & "000" WHEN (i_Addr = i_BaseAddr + c_Addr_PKU1) ELSE
        "00" & i_PKU2_LEN & "000" WHEN (i_Addr = i_BaseAddr + c_Addr_PKU2) ELSE
        "00" & i_PKU3_LEN & "000" WHEN (i_Addr = i_BaseAddr + c_Addr_PKU3) ELSE
        "00" & i_PKU4_LEN & "000" WHEN (i_Addr = i_BaseAddr + c_Addr_PKU4) ELSE
        "00" & i_PKU5_LEN & "000" WHEN (i_Addr = i_BaseAddr + c_Addr_PKU5) ELSE
        "00" & i_PKU6_LEN & "000" WHEN (i_Addr = i_BaseAddr + c_Addr_PKU6) ELSE
        "00" & i_PKU7_LEN & "000" WHEN (i_Addr = i_BaseAddr + c_Addr_PKU7) ELSE
        "00" & i_PKU8_LEN & "000" WHEN (i_Addr = i_BaseAddr + c_Addr_PKU8) ELSE
        "00" & i_PKU9_LEN & "000" WHEN (i_Addr = i_BaseAddr + c_Addr_PKU9) ELSE
        "00" & i_PKU10_LEN & "000" WHEN (i_Addr = i_BaseAddr + c_Addr_PKU10) ELSE
        "00" & i_PKU11_LEN & "000" WHEN (i_Addr = i_BaseAddr + c_Addr_PKU11) ELSE
        i_PKU_LIST(11 DOWNTO 0) WHEN (i_Addr = i_BaseAddr + c_Addr_PKU_LIST) ELSE
        (OTHERS => '0');

    o_Data <= x"0000" & "0000" & r_Data;

    o_RE <= '1' WHEN (i_Addr(15 DOWNTO 5) = i_BaseAddr(15 DOWNTO 5)) ELSE
        '0';

END arch;