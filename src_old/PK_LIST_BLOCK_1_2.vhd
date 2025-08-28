LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY PK_LIST_BLOCK_1_2 IS

    PORT (
        i_Clk : IN STD_LOGIC;
        i_En : IN STD_LOGIC;
        i_Addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        i_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_BaseAddr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        o_En : OUT STD_LOGIC := '0';
        o_A1 : OUT STD_LOGIC := '0';
        o_A2 : OUT STD_LOGIC := '0';
        o_A3 : OUT STD_LOGIC := '0';
        o_A4 : OUT STD_LOGIC := '0';
        o_OSN : OUT STD_LOGIC := '0';
        o_REZ : OUT STD_LOGIC := '0';
        
        o_Pk_Len : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0')
    );
END ENTITY;

ARCHITECTURE arch OF PK_LIST_BLOCK_1_2 IS

    --CONTANTS
    CONSTANT c_Addr_PkLen : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    CONSTANT c_Addr_PkList : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0018";

BEGIN

    PROCESS (i_Clk)
    BEGIN

        IF falling_edge(i_Clk) THEN
            IF (i_En = '1' AND i_Addr = i_BaseAddr + c_Addr_PkList) THEN
                o_A1 <= i_Data(0);
                o_A2 <= i_Data(1);
                o_A3 <= i_Data(2);
                o_A4 <= i_Data(3);
                o_OSN <= i_Data(4);
                o_REZ <= i_Data(5);
                o_En <= '1';
            ELSE
                o_En <= '0';
            END IF;
            
            IF (i_En = '1' AND i_Addr = i_BaseAddr + c_Addr_PkLen) THEN
				o_Pk_Len <= i_Data(9 DOWNTO 3);
            END IF;
        END IF;

    END PROCESS;

END arch;