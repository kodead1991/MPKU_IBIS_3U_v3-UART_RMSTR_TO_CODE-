library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
USE IEEE.numeric_std.all;	

entity UART_TXTAIL_EN_BLOCK is
	
    port (
            i_Addr	        :in std_logic_vector(15 downto 0);		 
            i_BaseAddr		:in std_logic_vector(15 downto 0);

            o_En	    	:out std_logic := '0'         
        );
    end UART_TXTAIL_EN_BLOCK;



    architecture arch of UART_TXTAIL_EN_BLOCK is

		CONSTANT UART0		: std_logic_vector(15 downto 0) := x"0000";
		CONSTANT UART1		: std_logic_vector(15 downto 0) := x"0800";
		CONSTANT UART2		: std_logic_vector(15 downto 0) := x"1000";
		CONSTANT UART3		: std_logic_vector(15 downto 0) := x"1800";
		CONSTANT UART4		: std_logic_vector(15 downto 0) := x"2000";
		CONSTANT UART5		: std_logic_vector(15 downto 0) := x"2800";

		CONSTANT RXDATA		: std_logic_vector(15 downto 0) := x"0000";
		CONSTANT TXDATA		: std_logic_vector(15 downto 0) := x"0200";
		CONSTANT RXTAIL		: std_logic_vector(15 downto 0) := x"0400";
		CONSTANT RXHEAD		: std_logic_vector(15 downto 0) := x"0401";
		CONSTANT TXTAIL		: std_logic_vector(15 downto 0) := x"0402";
		CONSTANT TXHEAD		: std_logic_vector(15 downto 0) := x"0403"; 
		CONSTANT CTRL		: std_logic_vector(15 downto 0) := x"0408";

	begin

		o_En <= '1' when (i_Addr = i_BaseAddr + TXTAIL) else '0';

        
    end arch;