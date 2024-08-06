LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY UART_TXHEAD_BLOCK IS

    PORT (
        i_Clk : IN STD_LOGIC;
        i_En : IN STD_LOGIC;
        i_Addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        i_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_BaseAddr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        o_TxHead : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0')
    );
END UART_TXHEAD_BLOCK;

ARCHITECTURE arch OF UART_TXHEAD_BLOCK IS

    --CONTANTS
    CONSTANT c_Addr_UartTxHead : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0403";

BEGIN

    PROCESS (i_Clk)
    BEGIN

        IF falling_edge(i_Clk) THEN
            IF (i_En = '1' AND i_Addr = i_BaseAddr + c_Addr_UartTxHead) THEN
                o_TxHead <= i_Data;
            END IF;
        END IF;

    END PROCESS;

END arch;