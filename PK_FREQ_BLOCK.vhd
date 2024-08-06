library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
USE IEEE.numeric_std.all;	

entity PK_FREQ_BLOCK is
	
    port (
            i_Clk	        :in std_logic; 			

            o_kHz	    	:out std_logic 						:= '0' 
        );
    end PK_FREQ_BLOCK ;



    architecture arch of PK_FREQ_BLOCK  is

		constant c_Div				: integer 					:= 25000;
		
		signal r_Cnt 				: integer range 0 to c_Div 	:= 0;
		signal r_kHz				: std_logic					:= '0';

	begin

		process(i_Clk)
		begin

			if rising_edge(i_Clk) then
				if (r_Cnt = c_Div/2) then
					r_Cnt <= 0;
					r_kHz <= not r_kHz;
				else
					r_Cnt <= r_Cnt + 1;
				end if;
			end if;

		end process;
        
        o_kHz <= r_kHz;
        
    end arch;