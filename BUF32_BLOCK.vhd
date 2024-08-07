library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
USE IEEE.numeric_std.all;	

entity BUF32_BLOCK is
	
    port (	
            i_CLK		    :in std_logic;
            i_WE		    :in std_logic;		 
            i_Data	        :in std_logic_vector(31 downto 0);
            o_Data			:out std_logic_vector(31 downto 0)     
        );
    end BUF32_BLOCK;



    architecture arch of BUF32_BLOCK is

	begin

		process(i_Clk)
		begin

			if falling_edge(i_Clk) then
				if (i_WE = '1') then
					o_Data <= i_Data;
				end if;
			end if;
            

		end process;


    end arch;