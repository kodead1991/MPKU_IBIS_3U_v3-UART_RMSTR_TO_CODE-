library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
USE IEEE.numeric_std.all;	

entity ONE_WIRE_BLOCK_v2_2 is
	
    port (
            i_Clk	        :in std_logic; 			

            i_RE    		:in std_logic                      := '0';
            i_WE    		:in std_logic                      := '0';
            
            i_BaseAddr	    :in std_logic_vector(15 downto 0)  := (others=>'0');
            i_Addr	      	:in std_logic_vector(15 downto 0)  := (others=>'0');
            i_Data	      	:in std_logic_vector(31 downto 0)  := (others=>'0');
            o_Data	      	:out std_logic_vector(31 downto 0)  := (others=>'Z');


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
		
		type RamType1 is array(0 to 15) of std_logic_vector(63 downto 0);		--(crc & rom_code & family_code)
		signal RAM_NAME :RamType1 		  	  := (0  => x"003CF7F648317700", 	--Sens_1 x"BC3C50F6482BDF28" 
															1  => x"013C50F6482BDF01",		--Sens_2 x"003CF7F648317728"
															2  => x"023C50F6482BDF02",
															3  => x"033C50F6482BDF03",
															4  => x"043C50F6482BDF04",
															5  => x"053C50F6482BDF05",
															6  => x"063C50F6482BDF06",
															7  => x"073C50F6482BDF07",
															8  => x"083C50F6482BDF08",
															9  => x"093C50F6482BDF09",
															10 => x"103C50F6482BDF10",
															11 => x"113C50F6482BDF11",
															12 => x"123C50F6482BDF12",
															13 => x"133C50F6482BDF13",
															14 => x"143C50F6482BDF14",
															15 => x"153C50F6482BDF15");																				
	--	signal RAM_NAME :RamType1 				:= (others=>x"283C50F6482BDFBC"); 
	
		type RamType2 is array(0 to 15) of std_logic_vector(31 downto 0);
		signal RAM_TEMP: 				RamType2 									:= (others=>x"CCDDEEFF");
		
		signal r_Data:					std_logic_vector(63 downto 0)			:= (others => '0');
		
		signal r_CntMhz:				integer range 0 to 25					:= 0; 								--25.000.000/1.000.000=25 
		signal r_1MHz:					std_logic									:= '0';
		
		signal r_CntSensorName:		std_logic_vector(4 downto 0)			:= (others => '0');
		signal r_CntSensorTemp1:	std_logic_vector(3 downto 0)			:= (others => '0');
		signal r_CntSensorTemp2:	std_logic_vector(3 downto 0)			:= (others => '0');
	
		signal r_Cnt_Time: 			integer range 0 to 799999				:= 0;									--counter delta = 1 us, max value 800 ms		
		signal r_Cnt_Bit_Tx: 		integer range 0 to 8						:= 0;									--counter bit for tx byte
		signal r_Cnt_Bit_Rx:			integer range 0 to 71					:= 0;									--counter bit for rx byte
		signal r_Cnt_Bit: 			integer range 0 to 72					:= 0;									--counter bit rx
		signal r_Cnt_Byte_Rom:		integer range 0 to 8						:= 0;									--counter tx byte rom code
		signal r_Cnt_Bit_Rom:		integer range 7 to 63					:= 7;									--counter bit rom code

		signal r_ROM_Code:			std_logic_vector(63 downto 0)			:= (others => '0');	
		signal r_Data_Mem: 			std_logic_vector(71 downto 0)			:= (others => '0');				--9 Byte from DS18B20 
		signal r_Reset: 				std_logic									:= '0';								--reset r_Cnt_Time (1 for reset)
		signal r_Command: 			std_logic_vector(7 downto 0)			:= (others => '0');				--command for DS18B20
		signal r_Presence:			std_logic									:= '1';								--data probe for presence

		signal r_Write_Low_Flag: 	integer range 0 to 2						:= 0;									--tx bit '0'
		signal r_Write_High_Flag: 	integer range 0 to 2						:= 0;									--tx bit '1'
		signal r_Read_Bit_Flag: 	integer range 0 to 3						:= 0;									--rx bit
		signal r_Send_Flag: 			integer range 0 to 7						:= 0;									--flag for send command

		signal r_Data_Temp_Received: std_logic									:= '0';	

begin

	process(i_Clk)								--clock 1MHz
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
	
	process (i_Clk)								--reset cnt_time
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
	
--	process(i_Clk)
--	begin
--		
--		if rising_edge(i_Clk) then
--
--			if (i_WE = '1') then
--				if (i_Addr = i_BaseAddr	+ c_Addr_NAME0_1) then
--					RAM_NAME(0)(31 downto 0) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME0_2) then
--					RAM_NAME(0)(63 downto 32) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME1_1) then
--					RAM_NAME(1)(31 downto 0) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME1_2) then
--					RAM_NAME(1)(63 downto 32) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME2_1) then
--					RAM_NAME(2)(31 downto 0) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME2_2) then
--					RAM_NAME(2)(63 downto 32) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME3_1) then
--					RAM_NAME(3)(31 downto 0) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME3_2) then
--					RAM_NAME(3)(63 downto 32) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME4_1) then
--					RAM_NAME(4)(31 downto 0) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME4_2) then
--					RAM_NAME(4)(63 downto 32) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME5_1) then
--					RAM_NAME(5)(31 downto 0) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME5_2) then
--					RAM_NAME(5)(63 downto 32) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME6_1) then
--					RAM_NAME(6)(31 downto 0) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME6_2) then
--					RAM_NAME(6)(63 downto 32) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME7_1) then
--					RAM_NAME(7)(31 downto 0) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME7_2) then
--					RAM_NAME(7)(63 downto 32) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME8_1) then
--					RAM_NAME(8)(31 downto 0) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME8_2) then
--					RAM_NAME(8)(63 downto 32) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME9_1) then
--					RAM_NAME(9)(31 downto 0) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME9_2) then
--					RAM_NAME(9)(63 downto 32) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME10_1) then
--					RAM_NAME(10)(31 downto 0) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME10_2) then
--					RAM_NAME(10)(63 downto 32) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME11_1) then
--					RAM_NAME(11)(31 downto 0) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME11_2) then
--					RAM_NAME(11)(63 downto 32) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME12_1) then
--					RAM_NAME(12)(31 downto 0) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME12_2) then
--					RAM_NAME(12)(63 downto 32) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME13_1) then
--					RAM_NAME(13)(31 downto 0) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME13_2) then
--					RAM_NAME(13)(63 downto 32) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME14_1) then
--					RAM_NAME(14)(31 downto 0) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME14_2) then
--					RAM_NAME(14)(63 downto 32) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME15_1) then
--					RAM_NAME(15)(31 downto 0) <= i_Data;
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_NAME15_2) then
--					RAM_NAME(15)(63 downto 32) <= i_Data;
--				end if;
--			end if;
--			
--			if (i_RE = '1') then
--				if (i_Addr = i_BaseAddr	+ c_Addr_TEMP0) then
--					o_Data <= RAM_TEMP(0);
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_TEMP1) then
--					o_Data <= RAM_TEMP(1);
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_TEMP2) then
--					o_Data <= RAM_TEMP(2);
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_TEMP3) then
--					o_Data <= RAM_TEMP(3);
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_TEMP4) then
--					o_Data <= RAM_TEMP(4);
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_TEMP5) then
--					o_Data <= RAM_TEMP(5);
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_TEMP6) then
--					o_Data <= RAM_TEMP(6);
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_TEMP7) then
--					o_Data <= RAM_TEMP(7);
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_TEMP8) then
--					o_Data <= RAM_TEMP(8);
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_TEMP9) then
--					o_Data <= RAM_TEMP(9);
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_TEMP10) then
--					o_Data <= RAM_TEMP(10);
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_TEMP11) then
--					o_Data <= RAM_TEMP(11);
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_TEMP12) then
--					o_Data <= RAM_TEMP(12);
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_TEMP13) then
--					o_Data <= RAM_TEMP(13);
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_TEMP14) then
--					o_Data <= RAM_TEMP(14);
--				elsif (i_Addr = i_BaseAddr	+ c_Addr_TEMP15) then
--					o_Data <= RAM_TEMP(15);
--				else
--					o_Data <= (others=>'Z');
--				end if;
--			end if;
--			
--		end if;
--		
--	end process; 
	
	o_TEST(7) <= i_Clk;
	o_TEST(6) <= r_1MHz;
	
	
	process(i_Clk) --main process 1WIRE
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
					if (r_Presence = '0' and i_1WIRE = '1') then		
						r_Reset <= '1';									--reset r_Cnt_Time
						r_State_1WIRE <= SEND;									
					else																		
						r_Reset	<= '1';									
						r_State_1WIRE <= WAIT_800ms;							
					end if;
				------------------------------------------------------------
				when SEND =>												--prepare byte for tx command
					if (r_Send_Flag = 0) then												
						r_Send_Flag <= 1;
						r_Command <= x"55"; 								--55h - MATCH ROM COMMAND
						r_State_1WIRE <= WRITE_BYTE;
					elsif (r_Send_Flag = 1) then						--rom code
						if r_Cnt_Byte_Rom = 8 then 
							r_Send_Flag <= 2;
							r_Cnt_Byte_Rom <= 0;
							--r_Cnt_Bit_Rom <= 7;
							r_State_1WIRE <= SEND;
						else 
							case (r_Cnt_Byte_Rom) is
								when 0 => r_Command <= RAM_NAME(conv_integer(r_CntSensorTemp2))(7 downto 0);
								when 1 => r_Command <= RAM_NAME(conv_integer(r_CntSensorTemp2))(15 downto 8);
								when 2 => r_Command <= RAM_NAME(conv_integer(r_CntSensorTemp2))(23 downto 16);
								when 3 => r_Command <= RAM_NAME(conv_integer(r_CntSensorTemp2))(31 downto 24);
								when 4 => r_Command <= RAM_NAME(conv_integer(r_CntSensorTemp2))(39 downto 32);
								when 5 => r_Command <= RAM_NAME(conv_integer(r_CntSensorTemp2))(47 downto 40);
								when 6 => r_Command <= RAM_NAME(conv_integer(r_CntSensorTemp2))(55 downto 48);
								when 7 => r_Command <= RAM_NAME(conv_integer(r_CntSensorTemp2))(63 downto 56);
								when OTHERS => NULL;
							end case;

							--r_Cnt_Bit_Rom <= r_Cnt_Bit_Rom + 8;
							r_Cnt_Byte_Rom <= r_Cnt_Byte_Rom + 1;
							r_State_1WIRE <= WRITE_BYTE;	
						end if;
						
					--	r_Send_Flag <= 1;
					--	r_Command <= x"CC"; 											--CCh - SKIP ROM
					--	r_Command <= x"33";											--33h - Read ROM 
					--	r_State <= WRITE_BYTE;									
					elsif (r_Send_Flag = 2) then												
						r_Send_Flag <= 3;
						r_Command <= x"44";		 									--44h - CONVERT TEMPERATURE
						r_State_1WIRE <= WRITE_BYTE;									
					elsif (r_Send_Flag = 3) then										
					--	r_Send_Flag <= 4;	
					--	r_State_1WIRE <= WAIT_800ms; 								--delay for sensor convert
						
						if ((conv_integer(r_CntSensorTemp2)) = 15) then		--(44h - CONVERT TEMPERATURE) for 16 sens - Done
							r_Send_Flag <= 4;											--transition to (BEh - READ SCRATCHPAD)
							r_CntSensorTemp2 <= (others => '0');				--reset addr ROM_CODE
							r_State_1WIRE <= WAIT_800ms;				 			--wait conv time
						else  
							r_CntSensorTemp2 <= r_CntSensorTemp2 + 1;			--increment for receive next Rom_code from RAM_memory
							r_Send_Flag <= 0;											--(44h - CONVERT TEMPERATURE) for next sens
							r_State_1Wire <= RESET;		 				
						end if;			
						
					elsif	(r_Send_Flag = 4) then											
						r_Send_Flag <= 5;
						r_Command <= x"55"; 											--55h - MATCH ROM COMMAND
						r_State_1WIRE <= WRITE_BYTE;
					elsif (r_Send_Flag = 5) then									--rom code
						if r_Cnt_Byte_Rom = 8 then 
							r_Send_Flag <= 6;
							r_Cnt_Byte_Rom <= 0;
							--r_Cnt_Bit_Rom <= 7;
							r_State_1WIRE <= SEND;
						else 
							case (r_Cnt_Byte_Rom) is
								when 0 => r_Command <= RAM_NAME(conv_integer(r_CntSensorTemp2))(7 downto 0);
								when 1 => r_Command <= RAM_NAME(conv_integer(r_CntSensorTemp2))(15 downto 8);
								when 2 => r_Command <= RAM_NAME(conv_integer(r_CntSensorTemp2))(23 downto 16);
								when 3 => r_Command <= RAM_NAME(conv_integer(r_CntSensorTemp2))(31 downto 24);
								when 4 => r_Command <= RAM_NAME(conv_integer(r_CntSensorTemp2))(39 downto 32);
								when 5 => r_Command <= RAM_NAME(conv_integer(r_CntSensorTemp2))(47 downto 40);
								when 6 => r_Command <= RAM_NAME(conv_integer(r_CntSensorTemp2))(55 downto 48);
								when 7 => r_Command <= RAM_NAME(conv_integer(r_CntSensorTemp2))(63 downto 56);
								when OTHERS => NULL;
							end case;
							
							--r_Cnt_Bit_Rom <= r_Cnt_Bit_Rom + 8;
							r_Cnt_Byte_Rom <= r_Cnt_Byte_Rom + 1;
							r_State_1WIRE <= WRITE_BYTE;	
						end if;
						
					--	r_Send_Flag <= 5;
					--	r_Command <= x"CC"; 									--CCh - SKIP ROM
					--	r_State <= WRITE_BYTE;								
					elsif (r_Send_Flag = 6) then							
						r_Send_Flag <= 7;
						r_Command <= x"BE"; 									--BEh - READ SCRATCHPAD
					--	r_CntSensorTemp2 <= r_CntSensorTemp2 + 1; 	--increment for receive next Rom_code from RAM_memory
						r_State_1WIRE <= WRITE_BYTE;									
					elsif (r_Send_Flag = 7) then												
					--	r_Send_Flag <= 0;															
						r_State_1WIRE <= GET_DATA;									
					end if;
				------------------------------------------------------------
				when WRITE_BYTE =>												
				
					case r_Cnt_Bit_Tx is												
						when 0 to 7 =>													
							if (r_Command(r_Cnt_Bit_Tx) = '0') then		--tx '0'
								r_State_1WIRE <= WRITE_LOW; 								
							else														--tx '1'
								r_State_1WIRE <= WRITE_HIGH;							
							end if;
							r_Cnt_Bit_Tx <= r_Cnt_Bit_Tx + 1;					
						when 8 =>															
							r_Cnt_Bit_Tx <= 0;											
							r_State_1WIRE <= SEND;										
						when others =>														
							r_Cnt_Bit_Tx  <= 0;										
							r_Write_Low_Flag <= 0;										
							r_Write_High_Flag <= 0;										
							r_State_1WIRE <= RESET;									
						end case;
				------------------------------------------------------------
				when WRITE_LOW =>												--tx '0'
					case r_Write_Low_Flag is											
						when 0 =>																
							o_1WIRE <= '0';									--start pull-down
							r_Reset <= '0';											
							if (r_Cnt_Time = 59) then						--60 us
								r_Reset <='1';								
								r_Write_Low_Flag <= 1;
							end if;
						when 1 =>												--end pull-down										
							o_1WIRE <= '1';											
							r_Reset <= '0';										
							if (r_Cnt_Time = 3) then						--4 us
								r_Reset <= '1';									
								r_Write_Low_Flag <= 2;
							end if;
						when 2 =>												--end slot		
							r_Write_Low_Flag <= 0;											
							r_State_1WIRE <= WRITE_BYTE;								
						when others=>											
							r_Cnt_Bit_Tx <= 0;										
							r_Write_Low_Flag <= 0;									
							r_State_1WIRE <= RESET;								
					end case;
				------------------------------------------------------------
				when WRITE_HIGH =>											--tx '1'
					case r_Write_High_Flag is										
						when 0 =>																
							o_1WIRE <= '0';									--start pull-down
							r_Reset <= '0';												
							if (r_Cnt_Time = 9) then						--10 us
								r_Reset <= '1';									
								r_Write_High_Flag <= 1;
							end if;
						when 1 =>												
							o_1WIRE <= '1';									--end pull-down
							r_Reset <= '0';									
							if (r_Cnt_Time = 53) then						--54 us
								r_Reset <= '1';									
								r_Write_High_Flag <= 2;
							end if;
						when 2 =>												--end slot
							r_Write_High_Flag <= 0;										
							r_State_1WIRE <= WRITE_BYTE;							
						when others =>												
							r_Cnt_Bit_Tx <= 0;									
							r_Write_High_Flag <= 0;										
							r_State_1WIRE <= RESET;									
					end case;
				------------------------------------------------------------
				when WAIT_800ms =>														
					r_Data_Temp_Received	<= '0';			
					r_Reset <= '0';												
				--	if (r_Cnt_Time = 799999) then
					if (r_Cnt_Time = 751000) then						--min conv time for 12-bit resolution 750 ms										
						r_Reset <='1';													
						r_State_1WIRE <= RESET;											
					end if;
				------------------------------------------------------------
				when GET_DATA =>											--rx data from sensor
					case r_Cnt_Bit is											
						when 0 to 71 =>									--read 72 bit 			
							o_1WIRE <= '0';											
							r_Cnt_Bit <= r_Cnt_Bit + 1;				
							r_State_1WIRE <= READ_BIT;									
						when 72 =>											--all data rx			
							r_Cnt_Bit_Rx <= 0;													
							r_Cnt_Bit <=0;	
							RAM_TEMP(conv_integer(r_CntSensorTemp2)) <= x"0000" & r_Data_Mem(15 downto 0);							
							r_Data_Temp_Received <= '1';								--flag data RAM_TEMP update
							
							if ((conv_integer(r_CntSensorTemp2)) = 15) then		--rx data from 16 sens - Done
								r_Send_Flag <= 0;											--transition to (44h - CONVERT TEMPERATURE)
								r_CntSensorTemp2 <= (others => '0');				--reset addr ROM_CODE
								r_State_1WIRE <= RESET;						 			--wait conv time
							else 					
								r_CntSensorTemp2 <= r_CntSensorTemp2 + 1;			--increment for receive next Rom_code from RAM_memory
								r_Send_Flag <= 4;											--(BEh - READ SCRATCHPAD) for next sens
								r_State_1Wire <= RESET;		 				
							end if;	
							
							--	r_State_1WIRE <= WAIT_800ms;								
						when others =>	 												
							r_Read_Bit_Flag <= 0;											
							r_Cnt_Bit <= 0; 											
					end case;
				------------------------------------------------------------
				when READ_BIT =>							--rx bit from sensor
					case r_Read_Bit_Flag is											
						when 0 =>																
							r_Read_Bit_Flag <= 1;
						when 1 =>																
							o_1WIRE <= '1';											
							r_Reset <= '0';									
							if r_Cnt_Time = 13 then		--14 us
								r_Reset <= '1';							
								r_Read_Bit_Flag <= 2;
							end if; 
						when 2 =>													
							r_Data_Mem(r_Cnt_Bit_Rx) <= i_1WIRE;					
							r_Cnt_Bit_Rx <= r_Cnt_Bit_Rx + 1;										
							r_Read_Bit_Flag <= 3;
						when 3 =>																
							r_Reset <= '0';											
							if r_Cnt_Time = 63 then		--62 us
								r_Reset <= '1';												
								r_Read_Bit_Flag <= 0;										
								r_State_1WIRE <= GET_DATA;							
							end if;
						when others => 													
							r_Read_Bit_Flag <= 0;										
							r_Cnt_Bit_Rx <= 0;											
							r_Cnt_Bit <= 0;										
							r_State_1WIRE <= RESET;								
					end case;
				------------------------------------------------------------
				when STOP => 
					
					r_State_1WIRE <= Stop;
					o_1WIRE <= '1';
				------------------------------------------------------------
				when OTHERS => r_State_1WIRE <= RESET;	
				------------------------------------------------------------												
			end case;
			
		end if;
		end if;
	end process;
  
    end arch;