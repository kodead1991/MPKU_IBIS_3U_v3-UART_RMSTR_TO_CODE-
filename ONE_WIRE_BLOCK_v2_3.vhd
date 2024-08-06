library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
USE IEEE.numeric_std.all;	

entity ONE_WIRE_BLOCK_v2_3 is
	
    port (
            			
            
            i_NAME0			:in std_logic_vector(63 downto 0) 	:= x"FF01229266D86628";--(OTHERS => '0');
            i_NAME1			:in std_logic_vector(63 downto 0) 	:= (others=>'0');
            i_NAME2			:in std_logic_vector(63 downto 0) 	:= (others=>'0');
            i_NAME3			:in std_logic_vector(63 downto 0) 	:= (others=>'0');
            i_NAME4			:in std_logic_vector(63 downto 0) 	:= (others=>'0');
            i_NAME5			:in std_logic_vector(63 downto 0) 	:= (others=>'0');
            i_NAME6			:in std_logic_vector(63 downto 0) 	:= (others=>'0');
            i_NAME7			:in std_logic_vector(63 downto 0) 	:= (others=>'0');
            i_NAME8			:in std_logic_vector(63 downto 0) 	:= (others=>'0');
            i_NAME9			:in std_logic_vector(63 downto 0) 	:= (others=>'0');
            i_NAME10		:in std_logic_vector(63 downto 0) 	:= (others=>'0');
            i_NAME11		:in std_logic_vector(63 downto 0) 	:= (others=>'0');
            i_NAME12		:in std_logic_vector(63 downto 0) 	:= (others=>'0');
            i_NAME13		:in std_logic_vector(63 downto 0) 	:= (others=>'0');
            i_NAME14		:in std_logic_vector(63 downto 0) 	:= (others=>'0');
            i_NAME15		:in std_logic_vector(63 downto 0) 	:= (others=>'0');
            
            o_TEMP0	      	:out std_logic_vector(31 downto 0)  := x"12345678";--(others=>'0');
            o_TEMP1	      	:out std_logic_vector(31 downto 0)  := (others=>'0');
            o_TEMP2	      	:out std_logic_vector(31 downto 0)  := (others=>'0');
            o_TEMP3	      	:out std_logic_vector(31 downto 0)  := (others=>'0');
            o_TEMP4	      	:out std_logic_vector(31 downto 0)  := (others=>'0');
            o_TEMP5	      	:out std_logic_vector(31 downto 0)  := (others=>'0');
            o_TEMP6	      	:out std_logic_vector(31 downto 0)  := (others=>'0');
            o_TEMP7	      	:out std_logic_vector(31 downto 0)  := (others=>'0');
            o_TEMP8	      	:out std_logic_vector(31 downto 0)  := (others=>'0');
            o_TEMP9	      	:out std_logic_vector(31 downto 0)  := (others=>'0');
            o_TEMP10      	:out std_logic_vector(31 downto 0)  := (others=>'0');
            o_TEMP11      	:out std_logic_vector(31 downto 0)  := (others=>'0');
            o_TEMP12      	:out std_logic_vector(31 downto 0)  := (others=>'0');
            o_TEMP13      	:out std_logic_vector(31 downto 0)  := (others=>'0');
            o_TEMP14      	:out std_logic_vector(31 downto 0)  := (others=>'0');
            o_TEMP15      	:out std_logic_vector(31 downto 0)  := (others=>'0');


			i_Clk	        :in std_logic; 
			i_1MHz	        :in std_logic; 
			i_1kHz	        :in std_logic; 

			i_1WIRE			:in std_logic;
			o_1WIRE	    	:out std_logic 							:= '1';
			
            o_Test	      :out std_logic_vector(7 downto 0)   := (others=>'0')
        );
    end ONE_WIRE_BLOCK_v2_3;

    architecture arch of ONE_WIRE_BLOCK_v2_3 is

		--CONSTANTS
		constant c_CntMhz_Div	: integer	:= 25;--clock divider coefficient
		constant c_SensorNum	: integer 	:= 1; --sensor's amount

		--STATE MACHINES
		type state_type is (
			WAIT_800ms, 		--wait conv time
			RESET, 				--tx reset impulse
			PRESENCE, 			--rx presence impulse 
			SEND, 				--prepare byte for tx
			WRITE_BYTE, 		--analysis bit = 0 or 1
			WRITE_LOW, 			--tx impulse for bit = 0
			WRITE_HIGH, 		--tx impulse for bit = 1
			GET_DATA,			--counting data bit
			READ_BIT			--rx bit slot
			);
		signal r_State_1WIRE	: state_type	:= RESET;
		
--		type SEND_type is (
--			SKIP_ROM, 		--wait conv time
--			CONV_TEMP, 				--tx reset impulse
--			CONV_TEMP_WAIT, 			--rx presence impulse 
--			MATCH_ROM, 				--prepare byte for tx
--			READ_SCRATCHPAD, 		--analysis bit = 0 or 1
--			GET_DATA
--			);
--		signal r_State_SEND	: SEND_type	:= SKIP_ROM;
		
		--REGS
		--Clock divider 25MHz to 1MHz (for 1-WIRE state machine)
		signal r_Cnt_1Mhz		: integer range 0 to c_CntMhz_Div-1			:= 0; 								--25.000.000/1.000.000=25 
		signal r_1MHz			: std_logic									:= '0';																
		
		--SENS's COUNTER
		signal r_CntSensor		: std_logic_vector(3 downto 0)				:= (others => '0');
	
		--1 MHz TIMER
		signal r_Cnt_Time1MHz	: integer range 0 to 851					:= 0; --main timer, delta = 1 us, max value 851 ms
		signal r_Reset_1MHz		: std_logic									:= '1'; --reset r_Cnt_Time1MHz ('1' to reset)
		
		--1 MHz TIMER
		signal r_Cnt_Time1kHz	: integer range 0 to 751					:= 0; --main timer, delta = 1 ms, max value 751 ms
		signal r_Reset_1kHz		: std_logic									:= '1'; --reset r_Cnt_Time1kHz ('1' to reset)
		
		--BIT/BYTE COUNTERS		
		signal r_Cnt_Bit_Tx		: integer range 0 to 8						:= 0; --tx bit count
		signal r_Cnt_Bit_Rx		: integer range 0 to 16						:= 0; --rx bit count
		signal r_Cnt_Byte_Rom	: integer range 0 to 8						:= 0; --tx byte rom code count

		--SENS DATA
		signal r_SensID			: std_logic_vector(63 downto 0)				:= (others => '0');	
		signal r_SensData		: std_logic_vector(71 downto 0)				:= (others => '0');				--9 Byte from DS18B20 
		signal r_SendBufer		: std_logic_vector(7 downto 0)				:= (others => '0');	--tx buffer
		
		signal r_Write_Low		: integer range 0 to 1						:= 0; --tx bit '0'
		signal r_Write_High		: integer range 0 to 1						:= 0; --tx bit '1'
		signal r_BitRecieve		: integer range 0 to 3						:= 0; --rx bit
		signal r_State			: integer range 0 to 7						:= 0; --flag for send command
		
		signal r_TEST			: std_logic_vector(7 downto 0)				:= (others => '0');	--tx buffer

begin

--	--1 MHz GEN
--	process(i_Clk)
--	begin
--	
--		if falling_edge(i_Clk) then 
--			if (r_Cnt_1Mhz = 24) then 
--				r_1MHz <= '1';
--				r_Cnt_1Mhz <= 0; 	
--			else 
--				r_Cnt_1Mhz <= r_Cnt_1Mhz + 1; 
--				r_1MHz <= '0';
--			end if;
--		end if;
--		
--	end process;
	
	--TIMER 1MHz
	process (i_Clk)								
	begin
		
		if rising_edge(i_Clk) then
			if (r_Reset_1MHz = '1') then
				r_Cnt_Time1MHz <= 0;						
			else
				if (i_1MHz = '1') then
					r_Cnt_Time1MHz <= r_Cnt_Time1MHz + 1;
				end if;					
			end if;
		end if;
		
	end process;
	
	--TIMER 1kHz
	process (i_Clk)								
	begin
		
		if rising_edge(i_Clk) then
			if (r_Reset_1kHz = '1') then
				r_Cnt_Time1kHz <= 0;						
			else
				if (i_1kHz = '1') then
					r_Cnt_Time1kHz <= r_Cnt_Time1kHz + 1;
				end if;					
			end if;
		end if;
		
	end process;

	--1-Wire State Machine
	process(i_Clk)
	begin
	
		if rising_edge(i_Clk) then
		if (i_1MHz = '1') then
		
			case (r_State_1WIRE) is
				------------------------------------------------------------
				--RESET IMPULSE
				when RESET =>												--impulse reset sensor
						
					r_Reset_1MHz <= '0';					--START MAIN TIMER										
					if (r_Cnt_Time1MHz = 1) then 		--START STATE "RESET/LINE PULL-DOWN"							
						o_1WIRE <= '0';		
					elsif (r_Cnt_Time1MHz = 485) then	--END STATE "RESET/LINE PULL-DOWN"
						o_1WIRE <= '1';	
					elsif (r_Cnt_Time1MHz = 851) then --SEND COMMANDS
						r_Reset_1MHz <= '1';				--END MAIN TIMER
						r_State_1WIRE <= SEND;							
					end if;
				------------------------------------------------------------
				--SEND COMMANDS 
				when SEND =>
					------------------------------------------------------------
					--SKIP ROM COMMAND
					if (r_State = 0) then												
						r_State <= 1;
						r_SendBufer <= x"CC";
						r_State_1WIRE <= WRITE_BYTE;
					------------------------------------------------------------
					--CONVERT TEMPERATURE COMAND		
					elsif (r_State = 1) then												
						r_State <= 2;
						r_SendBufer <= x"44";					
						r_State_1WIRE <= WRITE_BYTE;
					------------------------------------------------------------
					--CONVERT TEMPERATURE COMAND		
					elsif (r_State = 2) then												
						r_State <= 3;
						r_State_1WIRE <= WAIT_800ms; 											
					------------------------------------------------------------	
					--MATCH ROM COMMAND
					elsif (r_State = 3) then											
						r_State <= 4;
						r_SendBufer <= x"55";
						r_State_1WIRE <= WRITE_BYTE;
					------------------------------------------------------------
					--SET ROM COMMAND
					elsif (r_State = 4) then
						if (r_Cnt_Byte_Rom = 8) then 
							r_Cnt_Byte_Rom <= 0;
							r_State <= 5;
						else 
							case (r_Cnt_Byte_Rom) is
								when 0 => r_SendBufer <= r_SensID(7 downto 0);
								when 1 => r_SendBufer <= r_SensID(15 downto 8);
								when 2 => r_SendBufer <= r_SensID(23 downto 16);
								when 3 => r_SendBufer <= r_SensID(31 downto 24);
								when 4 => r_SendBufer <= r_SensID(39 downto 32);
								when 5 => r_SendBufer <= r_SensID(47 downto 40);
								when 6 => r_SendBufer <= r_SensID(55 downto 48);
								when 7 => r_SendBufer <= r_SensID(63 downto 56);
								when OTHERS => NULL;
							end case;

							r_Cnt_Byte_Rom <= r_Cnt_Byte_Rom + 1;
							r_State_1WIRE <= WRITE_BYTE;	
						end if;
					------------------------------------------------------------
					--READ SCRATCHPAD	
					elsif (r_State = 5) then							
						r_State <= 6;
						r_SendBufer <= x"BE";
						r_State_1WIRE <= WRITE_BYTE;
					------------------------------------------------------------
					--GET SENS DATA									
					elsif (r_State = 6) then																										
						r_State_1WIRE <= GET_DATA;									
					end if;
				------------------------------------------------------------
				when WRITE_BYTE =>												
				
					if (r_Cnt_Bit_Tx = 8) then
						r_Cnt_Bit_Tx <= 0;											
						r_State_1WIRE <= SEND;
					else
						if (r_SendBufer(r_Cnt_Bit_Tx) = '0') then		--tx '0'
							r_State_1WIRE <= WRITE_LOW; 								
						else										--tx '1'
							r_State_1WIRE <= WRITE_HIGH;							
						end if;
						
						r_Cnt_Bit_Tx <= r_Cnt_Bit_Tx + 1;
					end if;
				------------------------------------------------------------
				when WRITE_LOW =>												--tx '0'
					case (r_Write_Low) is
						------------------------------------------------------------										
						when 0 =>																
							o_1WIRE <= '0';									--start pull-down
							r_Reset_1MHz <= '0';											
							if (r_Cnt_Time1MHz = 59) then						--60 us
								r_Reset_1MHz <='1';								
								r_Write_Low <= 1;
							end if;
						------------------------------------------------------------
						when OTHERS =>												--end pull-down										
							o_1WIRE <= '1';											
							r_Reset_1MHz <= '0';										
							if (r_Cnt_Time1MHz = 3) then						--4 us
								r_Reset_1MHz <= '1';									
								r_Write_Low <= 0;											
								r_State_1WIRE <= WRITE_BYTE;
							end if;	
						------------------------------------------------------------														
					end case;
				------------------------------------------------------------
				when WRITE_HIGH =>											--tx '1'
					case (r_Write_High) is	
						------------------------------------------------------------
						when 0 =>																
							o_1WIRE <= '0';									--start pull-down
							r_Reset_1MHz <= '0';												
							if (r_Cnt_Time1MHz = 9) then						--10 us
								r_Reset_1MHz <= '1';									
								r_Write_High <= 1;
							end if;
						------------------------------------------------------------
						when OTHERS =>												
							o_1WIRE <= '1';									--end pull-down
							r_Reset_1MHz <= '0';									
							if (r_Cnt_Time1MHz = 53) then						--54 us
								r_Reset_1MHz <= '1';									
								r_Write_High <= 0;										
								r_State_1WIRE <= WRITE_BYTE;
							end if;	
						------------------------------------------------------------													
					end case;
				------------------------------------------------------------
				when WAIT_800ms =>	
					r_Reset_1kHz <= '0';								
					if (r_Cnt_Time1kHz = 751) then						--min conv time for 12-bit resolution 750 ms										
						r_Reset_1kHz <= '1';													
						r_State_1WIRE <= RESET;											
					end if;
				------------------------------------------------------------
				when GET_DATA =>											--rx data from sensor
					case (r_Cnt_Bit_Rx) is
						------------------------------------------------------------
						when 0 to 15 =>									--read 72 bit 			
							o_1WIRE <= '0';														
							r_State_1WIRE <= READ_BIT;
						------------------------------------------------------------									
						when others =>											--all data rx			
							r_Cnt_Bit_Rx <= 0;													
							

--							case conv_integer(r_CntSensor) is						--SAVE SENS DATA TO OUTPUT BUSES
--								when 0 => o_TEMP0 <= x"0000" & r_SensData(15 downto 0);
--								when 1 => o_TEMP1 <= x"0000" & r_SensData(15 downto 0);
--								when 2 => o_TEMP2 <= x"0000" & r_SensData(15 downto 0);
--								when 3 => o_TEMP3 <= x"0000" & r_SensData(15 downto 0);
--								when 4 => o_TEMP4 <= x"0000" & r_SensData(15 downto 0);
--								when 5 => o_TEMP5 <= x"0000" & r_SensData(15 downto 0);
--								when 6 => o_TEMP6 <= x"0000" & r_SensData(15 downto 0);
--								when others => o_TEMP7 <= x"0000" & r_SensData(15 downto 0);
--							end case;

							if ((conv_integer(r_CntSensor)) = c_SensorNum-1) then 	--ALL SENS HAVE BEEN CHECKED 
								r_State <= 0; 										--RESET SEND-STATE-MACHINE
								r_CntSensor <= (others=>'0'); 						--RESET SENS NAME's COUNTER
							else 					
								r_CntSensor <= r_CntSensor + 1;						--SET NEXT SENS NAME
								r_State <= 3;										--REPEAT THE TEMPREATURE READING CYCLE (MATCH >> READ >> GET DATA)			
							end if;	
							
							r_State_1Wire <= RESET;
																		
					end case;
				------------------------------------------------------------
				--BIT RECIEVE FROM 1-WIRE 
				when READ_BIT =>
					case (r_BitRecieve) is											
						------------------------------------------------------------
						when 0 =>																															
							o_1WIRE <= '1';											
							r_Reset_1MHz <= '0';									
							if (r_Cnt_Time1MHz = 13) then		--14 us
								--r_Reset_1MHz <= '1';
								r_SensData(r_Cnt_Bit_Rx) <= i_1WIRE;					
								r_Cnt_Bit_Rx <= r_Cnt_Bit_Rx + 1;																
								r_BitRecieve <= 1;
							end if; 
						------------------------------------------------------------
						when OTHERS =>																
							r_Reset_1MHz <= '0';											
							if (r_Cnt_Time1MHz = 75) then		--62 us
								r_Reset_1MHz <= '1';												
								r_BitRecieve <= 0;										
								r_State_1WIRE <= GET_DATA;							
							end if;							
					end case;
				------------------------------------------------------------
				when OTHERS => 
					r_State_1WIRE <= RESET;	
				------------------------------------------------------------												
			end case;
			
		end if;
		end if;
	end process;
		
	process(i_Clk)
	begin
	
		if rising_edge(i_Clk) then
		if (i_1MHz = '1') then
			
			if (r_Cnt_Bit_Rx = 16 and r_State_1WIRE = GET_DATA) then
				case conv_integer(r_CntSensor) is						--SAVE SENS DATA TO OUTPUT BUSES
					when 0 => o_TEMP0 <= x"0000" & r_SensData(15 downto 0);
					when 1 => o_TEMP1 <= x"0000" & r_SensData(15 downto 0);
					when 2 => o_TEMP2 <= x"0000" & r_SensData(15 downto 0);
					when 3 => o_TEMP3 <= x"0000" & r_SensData(15 downto 0);
					when 4 => o_TEMP4 <= x"0000" & r_SensData(15 downto 0);
					when 5 => o_TEMP5 <= x"0000" & r_SensData(15 downto 0);
					when 6 => o_TEMP6 <= x"0000" & r_SensData(15 downto 0);
					when others => o_TEMP7 <= x"0000" & r_SensData(15 downto 0);
				end case;
			end if;
			
		end if;
		end if;
	end process;
	
	o_TEST(0) <= i_1WIRE;
	o_TEST(1) <= '1' when (r_BitRecieve = 0 and r_Cnt_Time1MHz = 13) else '0';
	o_TEST(2) <= i_1WIRE;
	o_TEST(3) <= r_SensData(2);
	o_TEST(4) <= r_SensData(3);
	o_TEST(5) <= '1' when r_Cnt_Bit_Rx = 16 else '0';
	
	--o_TEST <= r_TEST;

	with (r_CntSensor) select
		r_SensID <= 	i_NAME0 when "0000",
						i_NAME1 when "0001",
						i_NAME2 when "0010",
						i_NAME3 when "0011",
						i_NAME4 when "0100",
						i_NAME5 when "0101",
						i_NAME6 when "0110",
						i_NAME7 when "0111",
						i_NAME8 when "1000",
						i_NAME9 when "1001",
						i_NAME10 when "1010",
						i_NAME11 when "1011",
						i_NAME12 when "1100",
						i_NAME13 when "1101",
						i_NAME14 when "1110",
						i_NAME15 when "1111";
  
    end arch;