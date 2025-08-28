library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
USE IEEE.numeric_std.all;	

entity TEST_BLOCK is
	
    port (
            i_Clk	        :in std_logic; 			
            i_Data		    :in std_logic_vector(31 downto 0)   := (others=>'0');

            o_RamRE		    :out std_logic                      := '0';
            o_Addr		    :out std_logic_vector(8 downto 0)   := (others=>'0');
            o_Data		    :out std_logic_vector(7 downto 0)   := (others=>'0')
        );
    end TEST_BLOCK;



    architecture arch of TEST_BLOCK is

		type state is (
            s_SetAddr,
			s_Wait1,
			s_Wait2,
			s_Wait3,
			s_Data0,
			s_Data1,
			s_Data2,
			s_Data3
            );				
        signal r_State                  :state 		                  	:= s_SetAddr;
                
		signal r_Cnt		        	:std_logic_vector(0 downto 0)	:= (others=>'0');

	begin
	

	process(i_Clk)
	begin

		if rising_edge(i_Clk) then
			
			case (r_State) is
				-------------------------------------------------------------
				when s_SetAddr =>
					o_Addr <= "00000000" & r_Cnt;
					o_RamRE <= '1';
					r_State <= s_Wait1;
				-------------------------------------------------------------
				when s_Wait1 =>
					o_RamRE <= '0';
					r_State <= s_Wait2;
				-------------------------------------------------------------
				when s_Wait2 =>
					r_State <= s_Wait3;
				-------------------------------------------------------------
				when s_Wait3 =>
					r_State <= s_Data0;
				-------------------------------------------------------------	
				when s_Data0 =>
					r_Cnt <= r_Cnt + 1;
					r_State <= s_SetAddr;
				-------------------------------------------------------------	
				when OTHERS => r_State <= s_SetAddr;
				-------------------------------------------------------------	
			end case;

		end if;

	end process; 
	
	o_Data <= i_Data(7 downto 0);

        
    end arch;