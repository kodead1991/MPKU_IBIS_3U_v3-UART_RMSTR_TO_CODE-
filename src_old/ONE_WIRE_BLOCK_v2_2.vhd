library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
USE IEEE.numeric_std.all;	

entity ONE_WIRE_BLOCK_v2_2 is
	
    port (
            			
            
            i_NAME0			:in std_logic_vector(63 downto 0) 	:= (others=>'0');
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
            
            o_TEMP0	      	:out std_logic_vector(31 downto 0)  := (others=>'0');
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

			i_1WIRE			:in std_logic;
			o_1WIRE	    	:out std_logic 							:= '1';
			
            o_Test	      :out std_logic_vector(7 downto 0)   := (others=>'0')
        );
    end ONE_WIRE_BLOCK_v2_2;

    architecture arch of ONE_WIRE_BLOCK_v2_2 is

		type state_type is (
			WAIT_800ms, 		--wait conv time
			RESET, 				--tx reset impulse
			PRESENCE, 			--rx presence impulse 
			SEND, 				--prepare byte for tx
			WRITE_BYTE, 		--analysis bit = 0 or 1
			WRITE_LOW, 			--tx impulse for bit = 0
			WRITE_HIGH, 		--tx impulse for bit = 1
			GET_DATA,			--counting data bit
			READ_BIT,			--rx bit slot
			STOP					--stop 1Wire state_machine
			);
		signal r_State_1WIRE	:state_type:= RESET;										--state machine status
		
--		type RamType1 is array(0 to 15) of std_logic_vector(63 downto 0);		--(crc & rom_code & family_code)
--		signal RAM_NAME :RamType1 		  	  := (0  => x"E308227136067228", 	--Sens_1 x"BC3C50F6482BDF28" 
--															1  => x"013C50F6482BDF01",		--Sens_2 x"003CF7F648317728"
--															2  => x"023C50F6482BDF02",
--															3  => x"033C50F6482BDF03",
--															4  => x"043C50F6482BDF04",
--															5  => x"053C50F6482BDF05",
--															6  => x"063C50F6482BDF06",
--															7  => x"073C50F6482BDF07",
--															8  => x"083C50F6482BDF08",
--															9  => x"093C50F6482BDF09",
--															10 => x"103C50F6482BDF10",
--															11 => x"113C50F6482BDF11",
--															12 => x"123C50F6482BDF12",
--															13 => x"133C50F6482BDF13",
--															14 => x"143C50F6482BDF14",
--															15 => x"153C50F6482BDF15");																				
		
		signal r_Data:				std_logic_vector(63 downto 0)				:= (others => '0');
		
		signal r_CntMhz:			integer range 0 to 25						:= 0; 								--25.000.000/1.000.000=25 
		signal r_1MHz:				std_logic									:= '0';
		
		signal c_SensorNum:			integer										:= 4;
		signal r_CntSensorName:		std_logic_vector(3 downto 0)				:= (others => '0');
		signal r_CntSensorTemp:		std_logic_vector(3 downto 0)				:= (others => '0');
	
		signal r_Cnt_Time: 			integer range 0 to 799999					:= 0;									--counter delta = 1 us, max value 800 ms		
		signal r_Cnt_Bit_Tx: 		integer range 0 to 8						:= 0;									--counter bit for tx byte
		signal r_Cnt_Bit_Rx:		integer range 0 to 71						:= 0;									--counter bit for rx byte
		signal r_Cnt_Bit: 			integer range 0 to 72						:= 0;									--counter bit rx
		signal r_Cnt_Byte_Rom:		integer range 0 to 8						:= 0;									--counter tx byte rom code
		signal r_Cnt_Bit_Rom:		integer range 7 to 63						:= 7;									--counter bit rom code

		signal r_RomCode:			std_logic_vector(63 downto 0)				:= (others => '0');	
		signal r_Data_Mem: 			std_logic_vector(71 downto 0)				:= (others => '0');				--9 Byte from DS18B20 
		signal r_Reset: 			std_logic									:= '0';								--reset r_Cnt_Time (1 for reset)
		signal r_Command: 			std_logic_vector(7 downto 0)				:= (others => '0');				--command for DS18B20
		signal r_Presence:			std_logic									:= '1';								--data probe for presence

		signal r_Write_Low_Flag: 	integer range 0 to 2						:= 0;									--tx bit '0'
		signal r_Write_High_Flag: 	integer range 0 to 2						:= 0;									--tx bit '1'
		signal r_Read_Bit_Flag: 	integer range 0 to 3						:= 0;									--rx bit
		signal r_Send_Flag: 		integer range 0 to 7						:= 0;									--flag for send command

		signal r_Data_Temp_Received: std_logic									:= '0';	

begin

	--1 MHz GEN
	process(i_Clk)
	begin
	
		if falling_edge(i_Clk) then 
			if (r_CntMhz = 24) then 
				r_1MHz <= '1';
				r_CntMhz <= 0; 	
			else 
				r_CntMhz <= r_CntMhz + 1; 
				r_1MHz <= '0';
			end if;
		end if;
		
	end process;
	
	--TIMER
	process (i_Clk)								
	begin
		
		if rising_edge(i_Clk) then
			if (r_Reset = '1') then
				r_Cnt_Time <= 0;						
			else
				if (r_1MHz = '1') then
					r_Cnt_Time <= r_Cnt_Time + 1;
				end if;					
			end if;
		end if;
		
	end process;

	--1-Wire State Machine
	process(i_Clk)
	begin
	
		if rising_edge(i_Clk) then
		if (r_1MHz = '1') then
			
			case (r_State_1WIRE) is
				------------------------------------------------------------
				when RESET =>												--impulse reset sensor
						
					r_Reset <= '0';											
					if (r_Cnt_Time = 1) then 									
						o_1WIRE <= '0';									--begin reset line pull-down		
					elsif (r_Cnt_Time = 485) then 					--484 us
						o_1WIRE <= '1';									--end reset line pull-up
					elsif (r_Cnt_Time = 550) then						--550 us 
						r_Presence <= i_1WIRE;							--save value i_Data 
					elsif (r_Cnt_Time = 850) then 					--850 us 
						r_State_1WIRE <= PRESENCE;							
					end if;
				------------------------------------------------------------
				when PRESENCE =>											--verification presence from sensor
					r_Reset <= '1';									--reset r_Cnt_Time
					
					if (r_Presence = '0' and i_1WIRE = '1') then		
						r_State_1WIRE <= SEND;									
					else																							
						r_State_1WIRE <= WAIT_800ms;							
					end if;
				------------------------------------------------------------
				when SEND =>												--prepare byte for tx command
					------------------------------------------------------------
					--MATCH ROM COMMAND
					if (r_Send_Flag = 0) then												
						r_Send_Flag <= 1;
						r_Command <= x"55"; 								--55h - MATCH ROM COMMAND
						r_State_1WIRE <= WRITE_BYTE;
					------------------------------------------------------------
					--SEND ROM CODE
					elsif (r_Send_Flag = 1) then
						if (r_Cnt_Byte_Rom = 8) then 
							r_Send_Flag <= 2;
							r_Cnt_Byte_Rom <= 0;
							r_State_1WIRE <= SEND;
						else 
							case (r_Cnt_Byte_Rom) is
								when 0 => r_Command <= r_RomCode(7 downto 0);
								when 1 => r_Command <= r_RomCode(15 downto 8);
								when 2 => r_Command <= r_RomCode(23 downto 16);
								when 3 => r_Command <= r_RomCode(31 downto 24);
								when 4 => r_Command <= r_RomCode(39 downto 32);
								when 5 => r_Command <= r_RomCode(47 downto 40);
								when 6 => r_Command <= r_RomCode(55 downto 48);
								when 7 => r_Command <= r_RomCode(63 downto 56);
								when OTHERS => NULL;
							end case;
							
							r_Cnt_Byte_Rom <= r_Cnt_Byte_Rom + 1;
							r_State_1WIRE <= WRITE_BYTE;	
						end if;
					------------------------------------------------------------
					--CONVERT TEMPERATURE COMAND		
					elsif (r_Send_Flag = 2) then												
						r_Send_Flag <= 3;
						r_Command <= x"44";		 									
						r_State_1WIRE <= WRITE_BYTE;
					------------------------------------------------------------									
					elsif (r_Send_Flag = 3) then										
						if ((conv_integer(r_CntSensorTemp)) = c_SensorNum-1) then		--(44h - CONVERT TEMPERATURE) for 16 sens - Done
							r_Send_Flag <= 4;											--transition to (BEh - READ SCRATCHPAD)
							r_CntSensorTemp <= (others=>'0');				--reset addr ROM_CODE
							r_State_1WIRE <= WAIT_800ms;				 			--wait conv time
						else  
							r_CntSensorTemp <= r_CntSensorTemp + 1;			--increment for receive next Rom_code from RAM_memory
							r_Send_Flag <= 0;											--(44h - CONVERT TEMPERATURE) for next sens
							r_State_1Wire <= RESET;		 				
						end if;			
					------------------------------------------------------------	
					elsif (r_Send_Flag = 4) then											
						r_Send_Flag <= 5;
						r_Command <= x"55"; 											--55h - MATCH ROM COMMAND
						r_State_1WIRE <= WRITE_BYTE;
					------------------------------------------------------------
					elsif (r_Send_Flag = 5) then									--rom code
						if (r_Cnt_Byte_Rom = 8) then 
							r_Send_Flag <= 6;
							r_Cnt_Byte_Rom <= 0;
							r_State_1WIRE <= SEND;
						else 
							case (r_Cnt_Byte_Rom) is
								when 0 => r_Command <= r_RomCode(7 downto 0);
								when 1 => r_Command <= r_RomCode(15 downto 8);
								when 2 => r_Command <= r_RomCode(23 downto 16);
								when 3 => r_Command <= r_RomCode(31 downto 24);
								when 4 => r_Command <= r_RomCode(39 downto 32);
								when 5 => r_Command <= r_RomCode(47 downto 40);
								when 6 => r_Command <= r_RomCode(55 downto 48);
								when 7 => r_Command <= r_RomCode(63 downto 56);
								when OTHERS => NULL;
							end case;

							r_Cnt_Byte_Rom <= r_Cnt_Byte_Rom + 1;
							r_State_1WIRE <= WRITE_BYTE;	
						end if;
					------------------------------------------------------------	
					elsif (r_Send_Flag = 6) then							
						r_Send_Flag <= 7;
						r_Command <= x"BE"; 									--BEh - READ SCRATCHPAD
						r_State_1WIRE <= WRITE_BYTE;
					------------------------------------------------------------									
					elsif (r_Send_Flag = 7) then																										
						r_State_1WIRE <= GET_DATA;									
					end if;
				------------------------------------------------------------
				when WRITE_BYTE =>												
				
					if (r_Cnt_Bit_Tx = 8) then
						r_Cnt_Bit_Tx <= 0;											
						r_State_1WIRE <= SEND;
					else
						if (r_Command(r_Cnt_Bit_Tx) = '0') then		--tx '0'
							r_State_1WIRE <= WRITE_LOW; 								
						else										--tx '1'
							r_State_1WIRE <= WRITE_HIGH;							
						end if;
						
						r_Cnt_Bit_Tx <= r_Cnt_Bit_Tx + 1;
					end if;
				------------------------------------------------------------
				when WRITE_LOW =>												--tx '0'
					case (r_Write_Low_Flag) is
						------------------------------------------------------------										
						when 0 =>																
							o_1WIRE <= '0';									--start pull-down
							r_Reset <= '0';											
							if (r_Cnt_Time = 59) then						--60 us
								r_Reset <='1';								
								r_Write_Low_Flag <= 1;
							end if;
						------------------------------------------------------------
						when 1 =>												--end pull-down										
							o_1WIRE <= '1';											
							r_Reset <= '0';										
							if (r_Cnt_Time = 3) then						--4 us
								r_Reset <= '1';									
								r_Write_Low_Flag <= 2;
							end if;
						------------------------------------------------------------
						when others =>					--end slot		
							r_Write_Low_Flag <= 0;											
							r_State_1WIRE <= WRITE_BYTE;															
					end case;
				------------------------------------------------------------
				when WRITE_HIGH =>											--tx '1'
					case (r_Write_High_Flag) is	
						------------------------------------------------------------
						when 0 =>																
							o_1WIRE <= '0';									--start pull-down
							r_Reset <= '0';												
							if (r_Cnt_Time = 9) then						--10 us
								r_Reset <= '1';									
								r_Write_High_Flag <= 1;
							end if;
						------------------------------------------------------------
						when 1 =>												
							o_1WIRE <= '1';									--end pull-down
							r_Reset <= '0';									
							if (r_Cnt_Time = 53) then						--54 us
								r_Reset <= '1';									
								r_Write_High_Flag <= 2;
							end if;
						------------------------------------------------------------
						when others =>												--end slot
							r_Write_High_Flag <= 0;										
							r_State_1WIRE <= WRITE_BYTE;														
					end case;
				------------------------------------------------------------
				when WAIT_800ms =>	
																	
					r_Data_Temp_Received <= '0';			
					r_Reset <= '0';
																
					if (r_Cnt_Time = 751000) then						--min conv time for 12-bit resolution 750 ms										
						r_Reset <= '1';													
						r_State_1WIRE <= RESET;											
					end if;
				------------------------------------------------------------
				when GET_DATA =>											--rx data from sensor
					case (r_Cnt_Bit) is
						------------------------------------------------------------
						when 0 to 71 =>									--read 72 bit 			
							o_1WIRE <= '0';											
							r_Cnt_Bit <= r_Cnt_Bit + 1;				
							r_State_1WIRE <= READ_BIT;
						------------------------------------------------------------									
						when others =>											--all data rx			
							r_Cnt_Bit_Rx <= 0;													
							r_Cnt_Bit <= 0;	
							r_Read_Bit_Flag <= 0;
							
							case conv_integer(r_CntSensorTemp) is
								when 0 => o_TEMP0 <= x"0000" & r_Data_Mem(15 downto 0);
								when 1 => o_TEMP1 <= x"0000" & r_Data_Mem(15 downto 0);
								when 2 => o_TEMP2 <= x"0000" & r_Data_Mem(15 downto 0);
								when 3 => o_TEMP3 <= x"0000" & r_Data_Mem(15 downto 0);
								when 4 => o_TEMP4 <= x"0000" & r_Data_Mem(15 downto 0);
								when 5 => o_TEMP5 <= x"0000" & r_Data_Mem(15 downto 0);
								when 6 => o_TEMP6 <= x"0000" & r_Data_Mem(15 downto 0);
								when others => o_TEMP7 <= x"0000" & r_Data_Mem(15 downto 0);
							end case;
							
							--o_Data <= x"0000" & r_Data_Mem(15 downto 0);							
							
							if ((conv_integer(r_CntSensorTemp)) = c_SensorNum-1) then		--rx data from 16 sens - Done
								r_Send_Flag <= 0;											--transition to (44h - CONVERT TEMPERATURE)
								r_CntSensorTemp <= (others => '0');				--reset addr ROM_CODE
							else 					
								r_CntSensorTemp <= r_CntSensorTemp + 1;			--increment for receive next Rom_code from RAM_memory
								r_Send_Flag <= 4;											--(BEh - READ SCRATCHPAD) for next sens				
							end if;	
							
							r_State_1Wire <= RESET;
																		
					end case;
				------------------------------------------------------------
				when READ_BIT =>							--rx bit from sensor
					case (r_Read_Bit_Flag) is											
						------------------------------------------------------------
						when 0 =>																
							r_Read_Bit_Flag <= 1;
						------------------------------------------------------------
						when 1 =>																
							o_1WIRE <= '1';											
							r_Reset <= '0';									
							if r_Cnt_Time = 13 then		--14 us
								r_Reset <= '1';							
								r_Read_Bit_Flag <= 2;
							end if; 
						------------------------------------------------------------
						when 2 =>													
							r_Data_Mem(r_Cnt_Bit_Rx) <= i_1WIRE;					
							r_Cnt_Bit_Rx <= r_Cnt_Bit_Rx + 1;										
							r_Read_Bit_Flag <= 3;
						------------------------------------------------------------
						when others =>																
							r_Reset <= '0';											
							if r_Cnt_Time = 63 then		--62 us
								r_Reset <= '1';												
								r_Read_Bit_Flag <= 0;										
								r_State_1WIRE <= GET_DATA;							
							end if;							
					end case;
				------------------------------------------------------------
				when STOP => 
					r_State_1WIRE <= Stop;
					o_1WIRE <= '1';
				------------------------------------------------------------
				when OTHERS => 
					r_State_1WIRE <= RESET;	
				------------------------------------------------------------												
			end case;
			
		end if;
		end if;
	end process;

	with (r_CntSensorTemp) select
		r_RomCode <= 	i_NAME0 when "0000",
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