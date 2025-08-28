library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
USE IEEE.numeric_std.all;	

entity DATA_OUT_BUS_ARBITR_BLOCK is
	
    port (
            i_Clk	        :in std_logic; 			
            i_RE		    :in std_logic;	
            i_Addr	        :in std_logic_vector(15 downto 0);		 

            o_Permit	    :out std_logic_vector(31 downto 0)	:= (others=>'0')
        );
    end DATA_OUT_BUS_ARBITR_BLOCK;



    architecture arch of DATA_OUT_BUS_ARBITR_BLOCK is

	begin

		process(i_Clk)
		begin

			if rising_edge(i_Clk) then
				
				if (i_RE = '1') then
					case (conv_integer(i_Addr)) is
						when 0 to 511 => o_Permit(0) <= '1'; -- [x"0000" to x"01FF"] UART0_RX_DATA
						when 4100 => o_Permit(1) <= '1'; -- [x"1004"] UART0_RX_HEAD
						when 4104 => o_Permit(2) <= '1'; -- [x"1008"] UART0_TX_TAIL
						when others => o_Permit <= (others=>'0');
					end case;
				else
					o_Permit <= (others=>'0');
				end if;

			end if;

		end process; 

        
    end arch;