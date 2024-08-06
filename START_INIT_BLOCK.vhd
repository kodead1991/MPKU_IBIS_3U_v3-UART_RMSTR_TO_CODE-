library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
USE IEEE.numeric_std.all;	

entity START_INIT_BLOCK is
	
    port (
                i_Clk	    	:in std_logic; 
				o_EN			:out std_logic := '0'						   
        );
    end START_INIT_BLOCK;

    architecture arch of START_INIT_BLOCK is

		signal r_Cnt : integer range 0 to 25000000 := 0;
		

	begin

		process(i_Clk)
		begin
			
			if rising_edge(i_Clk) then
				if (r_Cnt /= 25000000) then
					r_Cnt <= r_Cnt + 1;
				end if;
			end if;
			
		end process;
		
		o_En <= i_Clk when (r_Cnt = 25000000) else '0';

    end arch;