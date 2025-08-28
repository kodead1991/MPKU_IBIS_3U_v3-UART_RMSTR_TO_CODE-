library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package MyLibrary is
    component Debounce_gate is
		Port (
			i_Clk    : in  STD_LOGIC; -- Clock input
			i_Signal : in  STD_LOGIC; -- Input signal with bounce
			o_Signal : out STD_LOGIC  -- Debounced output signal
		);
    end component;
    
    component UART_TX_v1_CNT is
		Port (
			i_Clk    : in  STD_LOGIC; -- Clock input
			i_Data   : in  STD_LOGIC_VECTOR(7 DOWNTO 0); -- Input data
			i_En    : in  STD_LOGIC; -- Transmite enable
			o_Tx : out STD_LOGIC  -- Serial transmite
		);
    end component;
end package MyLibrary;