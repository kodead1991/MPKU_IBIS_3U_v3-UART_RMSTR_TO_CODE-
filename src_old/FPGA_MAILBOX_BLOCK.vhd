library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
USE IEEE.numeric_std.all;	

entity FPGA_MAILBOX_BLOCK is
	
    port (
            i_Clk	        :in std_logic; 			
            i_En		    :in std_logic;	
            i_Addr	        :in std_logic_vector(15 downto 0);		 
            i_Data	        :in std_logic_vector(31 downto 0);

            o_Delegate	    :out std_logic_vector(31 downto 0)	:= (others=>'0')
        );
    end FPGA_MAILBOX_BLOCK;



    architecture arch of FPGA_MAILBOX_BLOCK is

--		signal r_EnBuf1	:	std_logic := '0';
--		signal r_EnBuf2	:	std_logic := '0';
		constant c_Addr_RegControl	:	std_logic_vector := x"3FFE";

	begin

		process(i_Clk)
		begin

			if falling_edge(i_Clk) then
				
				if (i_En = '1' and i_Addr = c_Addr_RegControl) then
					o_Delegate <= i_Data;
				else
					o_Delegate <= (others=>'0');
				end if;

			end if;

		end process; 

        
    end arch;