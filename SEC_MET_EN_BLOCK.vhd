library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
USE IEEE.numeric_std.all;	

entity SEC_MET_EN_BLOCK is
	
    port (
            i_Addr	        :in std_logic_vector(15 downto 0);		 
            i_BaseAddr		:in std_logic_vector(15 downto 0);

            o_En	    	:out std_logic := '0'         
        );
    end SEC_MET_EN_BLOCK;



    architecture arch of SEC_MET_EN_BLOCK is

	begin

		o_En <= '1' when (i_Addr(15 downto 0) = i_BaseAddr(15 downto 0)) else '0';

    end arch;