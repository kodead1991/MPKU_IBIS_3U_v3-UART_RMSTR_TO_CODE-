library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY UART_TXHEAD_EN_BLOCK IS

    PORT (
        i_Addr : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        i_BaseAddr : IN STD_LOGIC_VECTOR(17 DOWNTO 0);

        o_En : OUT STD_LOGIC := '0'
    );
END UART_TXHEAD_EN_BLOCK;

ARCHITECTURE arch OF UART_TXHEAD_EN_BLOCK IS

    CONSTANT UART0 : unsigned(17 DOWNTO 0) := to_unsigned(16#0000#, 18);
    CONSTANT UART1 : unsigned(17 DOWNTO 0) := to_unsigned(16#2000#, 18);
    CONSTANT UART2 : unsigned(17 DOWNTO 0) := to_unsigned(16#4000#, 18);
    CONSTANT UART3 : unsigned(17 DOWNTO 0) := to_unsigned(16#6000#, 18);
    CONSTANT UART4 : unsigned(17 DOWNTO 0) := to_unsigned(16#8000#, 18);
    CONSTANT UART5 : unsigned(17 DOWNTO 0) := to_unsigned(16#A000#, 18);

    CONSTANT RXDATA : unsigned(17 DOWNTO 0) := to_unsigned(16#0000#, 18);
    CONSTANT TXDATA : unsigned(17 DOWNTO 0) := to_unsigned(16#0800#, 18);
    CONSTANT RXTAIL : unsigned(17 DOWNTO 0) := to_unsigned(16#1000#, 18);
    CONSTANT RXHEAD : unsigned(17 DOWNTO 0) := to_unsigned(16#1004#, 18);
    CONSTANT TXTAIL : unsigned(17 DOWNTO 0) := to_unsigned(16#1008#, 18);
    CONSTANT TXHEAD : unsigned(17 DOWNTO 0) := to_unsigned(16#100C#, 18);
    CONSTANT CTRL   : unsigned(17 DOWNTO 0) := to_unsigned(16#1020#, 18);

BEGIN

    o_En <= '1' when (unsigned(i_Addr) = unsigned(i_BaseAddr) + TXHEAD) else '0';

END arch;