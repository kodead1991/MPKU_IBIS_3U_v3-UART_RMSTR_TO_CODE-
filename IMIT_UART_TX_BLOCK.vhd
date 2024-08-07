library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
USE IEEE.numeric_std.all;	

entity IMIT_UART_TX_BLOCK is
	
    port (
            i_Clk	        :in std_logic; 			
            i_DriverReady   :in std_logic;			 

            o_DV		    :out std_logic                      := '1';
            o_TxData        :out std_logic_vector(7 downto 0) 	:= (others=>'0')
        );
    end IMIT_UART_TX_BLOCK;



    architecture arch of IMIT_UART_TX_BLOCK is

		type state is (
            s_Idle,
			s_CntIncr
            );				
        signal r_State                  :state 		                := s_Idle;

		signal r_Cnt					:std_logic_vector(7 downto 0)	:= (others=>'0');

	begin

	process(i_Clk)
		begin

			if falling_edge(i_Clk) then
				
				case r_State is
					------------------------------------------------
					when s_Idle =>
						if (i_DriverReady = '1') then
							o_TxData <= r_Cnt;
							o_DV <= '1';
							r_State <= s_CntIncr;
						end if;
					------------------------------------------------
					when s_CntIncr =>
						o_DV <= '0';
						r_Cnt <= r_Cnt + 1;
						r_State <= s_Idle;
					------------------------------------------------
					when others => NULL;
				end case;

			end if;

		end process; 

        
    end arch;