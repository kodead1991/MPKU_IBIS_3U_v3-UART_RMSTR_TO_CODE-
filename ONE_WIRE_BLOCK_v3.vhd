library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
USE IEEE.numeric_std.all;	

entity ONE_WIRE_BLOCK_v3 is
	
    port (
            i_Clk	        :in std_logic; 	
            i_MHz	        :in std_logic; 
            i_kHz	        :in std_logic;		
            
            i_DataRD	    :in std_logic_vector(63 downto 0)  	:= (others=>'0');
            o_AddrRD      	:out std_logic_vector(3 downto 0)  	:= (others=>'0');
            
            
            o_DataWR	    :out std_logic_vector(31 downto 0)  := (others=>'0');
            o_AddrWR      	:out std_logic_vector(3 downto 0) 	:= (others=>'0');
            o_WR	    	:out std_logic 						:= '0';
            
            o_Test	      :out std_logic_vector(7 downto 0)   	:= (others=>'0');
            
			i_1WIRE			:in std_logic;
			o_1WIRE	    	:out std_logic 						:= '1'
			
            
        );
    end ONE_WIRE_BLOCK_v3;

    architecture arch of ONE_WIRE_BLOCK_v3 is

		constant c_Addr_NAME0_1 	:std_logic_vector(15 downto 0) 	:= x"0000";
		constant c_Addr_NAME0_2 	:std_logic_vector(15 downto 0) 	:= x"0001";
		constant c_Addr_NAME1_1 	:std_logic_vector(15 downto 0) 	:= x"0002";
		constant c_Addr_NAME1_2 	:std_logic_vector(15 downto 0) 	:= x"0003";
		constant c_Addr_NAME2_1 	:std_logic_vector(15 downto 0) 	:= x"0004";
		constant c_Addr_NAME2_2 	:std_logic_vector(15 downto 0) 	:= x"0005";
		constant c_Addr_NAME3_1 	:std_logic_vector(15 downto 0) 	:= x"0006";
		constant c_Addr_NAME3_2 	:std_logic_vector(15 downto 0) 	:= x"0007";
		constant c_Addr_NAME4_1 	:std_logic_vector(15 downto 0) 	:= x"0008";
		constant c_Addr_NAME4_2 	:std_logic_vector(15 downto 0) 	:= x"0009";
		constant c_Addr_NAME5_1 	:std_logic_vector(15 downto 0) 	:= x"000A";
		constant c_Addr_NAME5_2 	:std_logic_vector(15 downto 0) 	:= x"000B";
		constant c_Addr_NAME6_1 	:std_logic_vector(15 downto 0) 	:= x"000C";
		constant c_Addr_NAME6_2 	:std_logic_vector(15 downto 0) 	:= x"000D";
		constant c_Addr_NAME7_1 	:std_logic_vector(15 downto 0) 	:= x"000E";
		constant c_Addr_NAME7_2 	:std_logic_vector(15 downto 0) 	:= x"000F";
		constant c_Addr_NAME8_1 	:std_logic_vector(15 downto 0) 	:= x"0010";
		constant c_Addr_NAME8_2 	:std_logic_vector(15 downto 0) 	:= x"0011";
		constant c_Addr_NAME9_1 	:std_logic_vector(15 downto 0) 	:= x"0012";
		constant c_Addr_NAME9_2 	:std_logic_vector(15 downto 0) 	:= x"0013";
		constant c_Addr_NAME10_1 	:std_logic_vector(15 downto 0) 	:= x"0014";
		constant c_Addr_NAME10_2 	:std_logic_vector(15 downto 0) 	:= x"0015";
		constant c_Addr_NAME11_1 	:std_logic_vector(15 downto 0) 	:= x"0016";
		constant c_Addr_NAME11_2 	:std_logic_vector(15 downto 0) 	:= x"0017";
		constant c_Addr_NAME12_1 	:std_logic_vector(15 downto 0) 	:= x"0018";
		constant c_Addr_NAME12_2 	:std_logic_vector(15 downto 0) 	:= x"0019";
		constant c_Addr_NAME13_1 	:std_logic_vector(15 downto 0) 	:= x"001A";
		constant c_Addr_NAME13_2 	:std_logic_vector(15 downto 0) 	:= x"001B";
		constant c_Addr_NAME14_1 	:std_logic_vector(15 downto 0) 	:= x"001C";
		constant c_Addr_NAME14_2 	:std_logic_vector(15 downto 0) 	:= x"001D";
		constant c_Addr_NAME15_1 	:std_logic_vector(15 downto 0) 	:= x"001E";
		constant c_Addr_NAME15_2 	:std_logic_vector(15 downto 0) 	:= x"001F";
		constant c_Addr_TEMP0  		:std_logic_vector(15 downto 0) 	:= x"0020";
		constant c_Addr_TEMP1  		:std_logic_vector(15 downto 0) 	:= x"0021";
		constant c_Addr_TEMP2  		:std_logic_vector(15 downto 0) 	:= x"0022";
		constant c_Addr_TEMP3  		:std_logic_vector(15 downto 0) 	:= x"0023";
		constant c_Addr_TEMP4  		:std_logic_vector(15 downto 0) 	:= x"0024";
		constant c_Addr_TEMP5  		:std_logic_vector(15 downto 0) 	:= x"0025";
		constant c_Addr_TEMP6  		:std_logic_vector(15 downto 0) 	:= x"0026";
		constant c_Addr_TEMP7  		:std_logic_vector(15 downto 0) 	:= x"0027";
		constant c_Addr_TEMP8  		:std_logic_vector(15 downto 0) 	:= x"0028";
		constant c_Addr_TEMP9  		:std_logic_vector(15 downto 0) 	:= x"0029";
		constant c_Addr_TEMP10 		:std_logic_vector(15 downto 0) 	:= x"002A";
		constant c_Addr_TEMP11 		:std_logic_vector(15 downto 0) 	:= x"002B";
		constant c_Addr_TEMP12 		:std_logic_vector(15 downto 0) 	:= x"002C";
		constant c_Addr_TEMP13 		:std_logic_vector(15 downto 0) 	:= x"002D";
		constant c_Addr_TEMP14 		:std_logic_vector(15 downto 0) 	:= x"002E";
		constant c_Addr_TEMP15 		:std_logic_vector(15 downto 0) 	:= x"002F";


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
			STORE_TEMP			--store temprature to DPRAM
			);
		signal r_State_1WIRE	:state_type:= RESET;																--state machine status
		
		signal r_TempData			: std_logic_vector(63 downto 0)			:= (others=>'0');
		
		signal r_1WIRE_RESET		: std_logic								:= '1';
		signal r_1WIRE_WRITE_LOW	: std_logic								:= '1';
		signal r_1WIRE_WRITE_HIGH	: std_logic								:= '1';
		signal r_1WIRE_GET_DATA		: std_logic								:= '1';
		signal r_1WIRE_READ_BIT		: std_logic								:= '1';
		
		signal r_AddrSensorName		: std_logic_vector(3 downto 0)			:= (others=>'0');
		signal r_AddrSensorTemp		: std_logic_vector(3 downto 0)			:= (others=>'0');
	
		signal r_Cnt_us				: integer range 0 to 850					:= 0;
		signal r_Cnt_ms				: integer range 0 to 800					:= 0;		
		signal r_Cnt_Bit_Tx			: integer range 0 to 9					:= 0;									--counter bit for tx byte
		signal r_Cnt_Bit_Rx			: integer range 0 to 72					:= 0;									--counter bit for rx byte
		signal r_CntDataTemp		: integer range 0 to 8					:= 0;									--counter tx byte rom code
	
		signal r_SensorTempBuf		: std_logic_vector(71 downto 0)			:= (others=>'0');						--9 Byte from DS18B20 
		signal r_Reset				: std_logic								:= '0';									--reset r_Cnt_us (1 for reset)
--		signal r_Reset_WRITE_LOW	: std_logic								:= '0';									--reset r_Cnt_us (1 for reset)
--		signal r_Reset_WRITE_HIGH	: std_logic								:= '0';									--reset r_Cnt_us (1 for reset)
		signal r_Command			: std_logic_vector(7 downto 0)			:= (others=>'0');						--command for DS18B20
		signal r_Presence			: std_logic								:= '1';									--data probe for presence

		signal r_Write_Low_Flag		: integer range 0 to 2					:= 0;									--tx bit '0'
		signal r_Write_High_Flag	: integer range 0 to 2					:= 0;									--tx bit '1'
		signal r_Read_Bit_Flag		: integer range 0 to 3					:= 0;									--rx bit
		signal r_CntSendState		: integer range 0 to 7					:= 0;									--flag for send command

		signal r_Data_Temp_Received: std_logic								:= '0';	

begin
	
	--MAIN TIMER
	process (i_Clk)								
	begin
		
		if falling_edge(i_Clk) then
			if (r_Reset = '1') then -- or r_Reset_WRITE_LOW = '1' or r_Reset_WRITE_HIGH = '1') then		
				r_Cnt_us <= 0;	
				r_Cnt_ms <= 0;					
			else
			
				--MICROSEC TIMER
				if (i_MHz = '1' and r_Cnt_us /= 850) then
					r_Cnt_us <= r_Cnt_us + 1;
				end if;
				
				--MILISEC TIMER
				if (i_kHz = '1' and r_Cnt_ms /= 800) then
					r_Cnt_ms <= r_Cnt_ms + 1;
				end if;
									
			end if;
		end if;
		
	end process;
	
		
	--1WIRE STATE MACHINE
	process(i_Clk) 
	begin
	
		if rising_edge(i_Clk) then
			
			case (r_State_1WIRE) is
				------------------------------------------------------------
				when RESET =>												--impulse reset sensor
						
					r_Reset <= '0';	
															
					if (r_Cnt_us = 1) then 									
						r_1WIRE_RESET <= '0';	--reset's start		
					elsif (r_Cnt_us = 485) then 	
						r_1WIRE_RESET <= '1';	--end reset
					elsif (r_Cnt_us = 550) then
						r_Presence <= i_1WIRE;	--save i_Data state
					elsif (r_Cnt_us = 850) then
						r_State_1WIRE <= PRESENCE;							
					end if;
				------------------------------------------------------------
				when PRESENCE =>	--verification presence from sensor
						
						r_Reset	<= '1'; --reset MAIN TIMER
					
						if (r_Presence = '0' and i_1WIRE = '1') then		
							r_State_1WIRE <= SEND;									
						else																								
							r_State_1WIRE <= WAIT_800ms;							
						end if;
				------------------------------------------------------------
				when SEND =>	--prepare byte for tx command
					
					case (r_CntSendState) is
						------------------------------------------------------------
						when 0 =>
							r_Command <= x"55";	--MATCH ROM COMMAND
							r_CntSendState <= 1;
							r_State_1WIRE <= WRITE_BYTE;
						------------------------------------------------------------
						when 1 =>
							if (r_CntDataTemp = 8) then 
								r_CntDataTemp <= 0;
								r_CntSendState <= 2;
								r_State_1WIRE <= SEND;
							else 
								case (r_CntDataTemp) is
									when 0 => r_Command <= i_DataRD(7 downto 0);
									when 1 => r_Command <= i_DataRD(15 downto 8);
									when 2 => r_Command <= i_DataRD(23 downto 16);
									when 3 => r_Command <= i_DataRD(31 downto 24);
									when 4 => r_Command <= i_DataRD(39 downto 32);
									when 5 => r_Command <= i_DataRD(47 downto 40);
									when 6 => r_Command <= i_DataRD(55 downto 48);
									when 7 => r_Command <= i_DataRD(63 downto 56);
									when OTHERS => NULL;
								end case;

								r_CntDataTemp <= r_CntDataTemp + 1;
								r_State_1WIRE <= WRITE_BYTE;	
							end if;
						------------------------------------------------------------
						when 2 =>
							r_Command <= x"44";	--CONVERT TEMPERATURE
							r_CntSendState <= 3;
							r_State_1WIRE <= WRITE_BYTE;
						------------------------------------------------------------
						when 3 =>
							if (r_AddrSensorName = x"F") then
								r_CntSendState <= 4;			--transition to (BEh - READ SCRATCHPAD)
								r_State_1WIRE <= WAIT_800ms;	--wait convertation time
							else  
								r_AddrSensorName <= r_AddrSensorName + 1;			--increment for receive next Rom_code from RAM_memory
								r_CntSendState <= 0;											--(44h - CONVERT TEMPERATURE) for next sens
								r_State_1Wire <= RESET;		 				
							end if;	
						------------------------------------------------------------
						when 4 =>
							r_Command <= x"55";	--MATCH ROM COMMAND
							r_CntSendState <= 5;
							r_State_1WIRE <= WRITE_BYTE;
						------------------------------------------------------------
						when 5 =>
							if (r_CntDataTemp = 8) then 
								r_CntDataTemp <= 0;
								r_CntSendState <= 6;
								r_State_1WIRE <= SEND;
							else 
								case (r_CntDataTemp) is
									when 0 => r_Command <= i_DataRD(7 downto 0);
									when 1 => r_Command <= i_DataRD(15 downto 8);
									when 2 => r_Command <= i_DataRD(23 downto 16);
									when 3 => r_Command <= i_DataRD(31 downto 24);
									when 4 => r_Command <= i_DataRD(39 downto 32);
									when 5 => r_Command <= i_DataRD(47 downto 40);
									when 6 => r_Command <= i_DataRD(55 downto 48);
									when 7 => r_Command <= i_DataRD(63 downto 56);
									when OTHERS => NULL;
								end case;

								r_CntDataTemp <= r_CntDataTemp + 1;
								r_State_1WIRE <= WRITE_BYTE;	
							end if;
						------------------------------------------------------------
						when 6 =>
							r_Command <= x"BE";	--READ SCRATCHPAD
							r_CntSendState <= 7;
							r_State_1WIRE <= WRITE_BYTE;
						------------------------------------------------------------
						when 7 =>
							r_State_1WIRE <= GET_DATA;
						------------------------------------------------------------
						when others =>
							r_CntSendState <= 0;
							r_State_1WIRE <= RESET;
						------------------------------------------------------------
					end case;
				------------------------------------------------------------
				when WRITE_BYTE =>
					if (r_Cnt_Bit_Tx = 8) then
						r_State_1WIRE <= SEND;
					end if;
					
					case r_Cnt_Bit_Tx is
						------------------------------------------------------------												
						when 0 to 7 =>													
							if (r_Command(r_Cnt_Bit_Tx) = '0') then		
								r_State_1WIRE <= WRITE_LOW; --tx '0'								
							else														
								r_State_1WIRE <= WRITE_HIGH;--tx '1'							
							end if;
							r_Cnt_Bit_Tx <= r_Cnt_Bit_Tx + 1;
						------------------------------------------------------------					
						when 8 =>															
							r_Cnt_Bit_Tx <= 0;											
							r_State_1WIRE <= SEND;
						------------------------------------------------------------										
						when others =>														
							r_Cnt_Bit_Tx  <= 0;										
							r_Write_Low_Flag <= 0;										
							r_Write_High_Flag <= 0;										
							r_State_1WIRE <= RESET;									
					end case;
				------------------------------------------------------------
				when WRITE_LOW =>												--tx '0'
					case (r_Write_Low_Flag) is											
						when 0 =>																
							o_1WIRE <= '0';									--start pull-down
							r_Reset <= '0';											
							if (r_Cnt_us = 59) then						--60 us
								r_Reset <='1';								
								r_Write_Low_Flag <= 1;
							end if;
						when 1 =>												--end pull-down										
							o_1WIRE <= '1';											
							r_Reset <= '0';										
							if (r_Cnt_us = 3) then						--4 us
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
							if (r_Cnt_us = 9) then						--10 us
								r_Reset <= '1';									
								r_Write_High_Flag <= 1;
							end if;
						when 1 =>												
							o_1WIRE <= '1';									--end pull-down
							r_Reset <= '0';									
							if (r_Cnt_us = 53) then						--54 us
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
				--	if (r_Cnt_ms = 799) then
					if (r_Cnt_ms = 751) then						--min conv time for 12-bit resolution 750 ms										
						r_Reset <='1';													
						r_State_1WIRE <= RESET;											
					end if;
				------------------------------------------------------------
				when GET_DATA =>											--rx data from sensor
					case (r_Cnt_Bit_rx) is											
						------------------------------------------------------------
						when 0 to 71 =>									--read 72 bit 			
							r_1WIRE_GET_DATA <= '0';														
							r_State_1WIRE <= READ_BIT;									
						------------------------------------------------------------
						when others =>											--all data rx			
							r_Cnt_Bit_Rx <= 0;													
							o_DataWR <= x"0000" & r_SensorTempBuf(15 downto 0);							
							o_WR <= '1';								
							r_State_1Wire <= STORE_TEMP;			
						------------------------------------------------------------											
					end case;
				------------------------------------------------------------
				when STORE_TEMP =>
					o_WR <= '0';
					if (r_AddrSensorTemp = x"F") then	--rx data from 16 sens - Done
						r_CntSendState <= 0;	--transition to (44h - CONVERT TEMPERATURE)
					else 					
						r_CntSendState <= 4;	--(BEh - READ SCRATCHPAD) for next sens	
					end if;	
					
					r_AddrSensorTemp <= r_AddrSensorTemp + 1;
					
					r_State_1Wire <= RESET;	
				------------------------------------------------------------
				when READ_BIT =>	--rx bit from sensor
					case r_Read_Bit_Flag is											
						------------------------------------------------------------
						when 0 =>																
							r_Read_Bit_Flag <= 1;
						------------------------------------------------------------
						when 1 =>																
							r_1WIRE_READ_BIT <= '1';											
							r_Reset <= '0';									
							if r_Cnt_us = 13 then		--14 us
								r_Reset <= '1';							
								r_Read_Bit_Flag <= 2;
							end if; 
						------------------------------------------------------------
						when 2 =>													
							r_SensorTempBuf(r_Cnt_Bit_Rx) <= i_1WIRE;					
							r_Cnt_Bit_Rx <= r_Cnt_Bit_Rx + 1;										
							r_Read_Bit_Flag <= 3;
						------------------------------------------------------------
						when others =>																
							r_Reset <= '0';											
							if (r_Cnt_us = 63) then		--62 us
								r_Reset <= '1';												
								r_Read_Bit_Flag <= 0;										
								r_State_1WIRE <= GET_DATA;							
							end if;	
						------------------------------------------------------------						
					end case;
				------------------------------------------------------------
				when OTHERS => r_State_1WIRE <= RESET;	
				------------------------------------------------------------												
			end case;
			
		end if;
	end process;
	
--	---------WRITE BYTE-----------------------------------------
--	process(i_Clk)
--	begin
--	
--		if rising_edge(i_Clk) then
--			if (r_State_1WIRE = WRITE_BYTE and r_Write_Low_Flag = 0) then
--			case (r_Cnt_Bit_Tx) is
--				------------------------------------------------------------												
--				when 0 to 7 =>													
--					r_Cnt_Bit_Tx <= r_Cnt_Bit_Tx + 1;	
--				------------------------------------------------------------				
--				when others =>														
--					r_Cnt_Bit_Tx  <= 0;																			
--				------------------------------------------------------------									
--			end case;
--			end if;
--		end if;
--
--	end process;
--	
--	---------WRITE LOW-----------------------------------------
--	process(i_Clk)
--	begin
--	
--		if rising_edge(i_Clk) then
--			if (r_State_1WIRE = WRITE_BYTE and r_Command(r_Cnt_Bit_Tx) = '0' and r_Cnt_Bit_Tx /= 8) then
--				case (r_Write_Low_Flag) is											
--					------------------------------------------------------------
--					when 0 =>	--start pull-down															
--						r_1WIRE_WRITE_LOW <= '0';									
--						r_Reset_WRITE_LOW <= '0';											
--						if (r_Cnt_us = 59) then		--60 us										
--							r_Write_Low_Flag <= 1;
--						end if;
--					------------------------------------------------------------
--					when 1 =>	--end pull-down																					
--						r_1WIRE_WRITE_LOW <= '1';																		
--						if (r_Cnt_us = 63) then		--4 us				
--							r_Reset_WRITE_LOW <= '1';									
--							r_Write_Low_Flag <= 2;
--						end if;
--					------------------------------------------------------------
--					when others =>	--end slot													
--						r_Write_Low_Flag <= 0;																		
--					------------------------------------------------------------								
--				end case;
--			else
--				r_Reset_WRITE_LOW <= '0';
--			end if;
--		end if;
--
--	end process;
--	
--	---------WRITE HIGH-----------------------------------------
--	process(i_Clk)
--	begin
--	
--		if rising_edge(i_Clk) then
--			if (r_State_1WIRE = WRITE_BYTE and r_Command(r_Cnt_Bit_Tx) = '1' and r_Cnt_Bit_Tx /= 8) then
--				case (r_Write_High_Flag) is											
--					------------------------------------------------------------
--					when 0 =>	--start pull-down															
--						r_1WIRE_WRITE_HIGH <= '0';									
--						r_Reset_WRITE_HIGH <= '0';											
--						if (r_Cnt_us = 9) then		--10 us												
--							r_Write_HIGH_Flag <= 1;
--						end if;
--					------------------------------------------------------------
--					when 1 =>	--end pull-down																					
--						r_1WIRE_WRITE_HIGH <= '1';																		
--						if (r_Cnt_us = 63) then		--54 us				
--							r_Reset_WRITE_HIGH <= '1';									
--							r_Write_High_Flag <= 2;
--						end if;
--					------------------------------------------------------------
--					when others =>	--end slot													
--						r_Write_High_Flag <= 0;																		
--					------------------------------------------------------------								
--				end case;
--			else
--				r_Reset_WRITE_HIGH <= '0';
--			end if;
--		end if;
--
--	end process;
--	
--	o_1WIRE <= r_1WIRE_RESET and r_1WIRE_WRITE_LOW and r_1WIRE_WRITE_HIGH and r_1WIRE_GET_DATA and r_1WIRE_READ_BIT;
	
	o_AddrRD <= r_AddrSensorName;
	o_AddrWR <= r_AddrSensorTemp;
  
    end arch;