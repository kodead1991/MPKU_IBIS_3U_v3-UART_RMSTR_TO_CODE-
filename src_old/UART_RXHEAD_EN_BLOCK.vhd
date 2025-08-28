library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_RXHEAD_EN_BLOCK is
	
    port (
            i_Addr		:in std_logic_vector(17 downto 0);		 
            i_BaseAddr	:in std_logic_vector(17 downto 0);

            o_En	    	:out std_logic := '0'         
        );
    end UART_RXHEAD_EN_BLOCK;



    architecture arch of UART_RXHEAD_EN_BLOCK is

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

    o_En <= '1' when (unsigned(i_Addr) = unsigned(i_BaseAddr) + RXHEAD) else '0';

        
    end arch;