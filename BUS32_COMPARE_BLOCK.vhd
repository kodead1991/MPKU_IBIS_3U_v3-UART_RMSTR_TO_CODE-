library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
USE IEEE.numeric_std.all;	

entity BUS32_COMPARE_BLOCK is
	
    port (
            i_Bus	   		:in std_logic_vector(31 downto 0);
            i_Base	   		:in std_logic_vector(31 downto 0);

            o_Res		    :out std_logic            
        );
    end BUS32_COMPARE_BLOCK;



    architecture arch of BUS32_COMPARE_BLOCK  is

	begin

		o_Res <= '1' when (i_Bus = i_Base) else '0';
        
    end arch;