library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
USE IEEE.numeric_std.all;	

entity SENS_TEMP_BLOCK is
	
    port (
            i_Addr	        :in std_logic_vector(15 downto 0);		 
            
            i_TEMP0			:in std_logic_vector(15 downto 0);
            i_TEMP1			:in std_logic_vector(15 downto 0);
            i_TEMP2			:in std_logic_vector(15 downto 0);
            i_TEMP3			:in std_logic_vector(15 downto 0);
            i_TEMP4			:in std_logic_vector(15 downto 0);
            i_TEMP5			:in std_logic_vector(15 downto 0);
            i_TEMP6			:in std_logic_vector(15 downto 0);
            i_TEMP7			:in std_logic_vector(15 downto 0);
            i_TEMP8			:in std_logic_vector(15 downto 0);
            i_TEMP9			:in std_logic_vector(15 downto 0);
            i_TEMP10		:in std_logic_vector(15 downto 0);
            i_TEMP11		:in std_logic_vector(15 downto 0);
            i_TEMP12		:in std_logic_vector(15 downto 0);
            i_TEMP13		:in std_logic_vector(15 downto 0);
            i_TEMP14		:in std_logic_vector(15 downto 0);
            i_TEMP15		:in std_logic_vector(15 downto 0);       
            
            o_Data			:out std_logic_vector(31 downto 0);

            o_En	    	:out std_logic := '0'         
        );
    end SENS_TEMP_BLOCK;



    architecture arch of SENS_TEMP_BLOCK is

		CONSTANT c_BASEADDR	: std_logic_vector(15 downto 0) := x"3940";

	begin

		o_En <= '1' when (i_Addr(15 downto 4) = c_BASEADDR(15 downto 4)) else '0';
		
		o_Data <= 	x"0000" & i_TEMP0 when (i_Addr(3 downto 0) = "0000") else
					x"0000" & i_TEMP1 when (i_Addr(3 downto 0) = "0001") else
					x"0000" & i_TEMP2 when (i_Addr(3 downto 0) = "0010") else
					x"0000" & i_TEMP3 when (i_Addr(3 downto 0) = "0011") else
					x"0000" & i_TEMP4 when (i_Addr(3 downto 0) = "0100") else
					x"0000" & i_TEMP5 when (i_Addr(3 downto 0) = "0101") else
					x"0000" & i_TEMP6 when (i_Addr(3 downto 0) = "0110") else
					x"0000" & i_TEMP7 when (i_Addr(3 downto 0) = "0111") else
					x"0000" & i_TEMP8 when (i_Addr(3 downto 0) = "1000") else
					x"0000" & i_TEMP9 when (i_Addr(3 downto 0) = "1001") else
					x"0000" & i_TEMP10 when (i_Addr(3 downto 0) = "1010") else
					x"0000" & i_TEMP11 when (i_Addr(3 downto 0) = "1011") else
					x"0000" & i_TEMP12 when (i_Addr(3 downto 0) = "1100") else
					x"0000" & i_TEMP13 when (i_Addr(3 downto 0) = "1101") else
					x"0000" & i_TEMP14 when (i_Addr(3 downto 0) = "1110") else
					x"0000" & i_TEMP15;
        
    end arch;