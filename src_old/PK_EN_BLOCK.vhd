LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;	

entity PK_EN_BLOCK is
	
    port (
            i_Status    	:in std_logic := '0'; 
            i_PkLen	        :in std_logic_vector(6 downto 0);
            
            i_Addr	        :in std_logic_vector(15 downto 0);		 
            i_BaseAddr		:in std_logic_vector(15 downto 0);

			o_Status		:out std_logic_vector(31 downto 0) := (others=>'0');
            o_En	    	:out std_logic := '0'         
        );
    end ENTITY;



    architecture arch of PK_EN_BLOCK is

	begin

		o_En <= '1' when (i_Addr(15 downto 0) = i_BaseAddr(15 downto 0)) else '0';
		o_Status <= x"00_00_0" & i_Status & "0" & i_PkLen & "000";

    end arch;