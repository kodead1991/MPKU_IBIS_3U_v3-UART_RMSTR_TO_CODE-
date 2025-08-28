library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY UART_TXHEAD_BLOCK IS

    PORT (
        i_Clk : IN STD_LOGIC;
        i_En : IN STD_LOGIC;
        i_Addr : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        i_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_BaseAddr : IN STD_LOGIC_VECTOR(17 DOWNTO 0);

        o_TxHead : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0')
    );
END UART_TXHEAD_BLOCK;

ARCHITECTURE arch OF UART_TXHEAD_BLOCK IS

    --CONTANTS
    CONSTANT c_Addr_UartTxHead : unsigned(17 DOWNTO 0) := to_unsigned(16#100C#, 18);
	 
	 --REGs
	 signal r_TxHead : std_logic_vector(31 downto 0) := (others=>'0');

BEGIN

    PROCESS (i_Clk)
    BEGIN

        IF falling_edge(i_Clk) THEN
            IF (i_En = '1' AND (unsigned(i_Addr) = unsigned(i_BaseAddr) + c_Addr_UartTxHead)) THEN
                r_TxHead <= i_Data;
            END IF;
        END IF;

    END PROCESS;
	 
	 o_TxHead <= r_TxHead;

END arch;