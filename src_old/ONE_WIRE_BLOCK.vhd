library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.numeric_std.all;

entity ONE_WIRE_BLOCK is
	port
	(
		i_Clk			:in			std_logic;											--clock 1MHz
		i_ROM_Code		:in			std_logic_vector(63 downto 0);						--64bit rom code
		i_Data			:in			std_logic;											--input line 1Wire
		o_Data			:out		std_logic						:= '1';				--output line 1Wire ('0'-line=0, '1'-line=Z)
		o_Crc			:out		std_logic						:= '0';				--crc valid
		o_Adr_Mem		:out 		std_logic_vector(3 downto 0)	:= (others => '0');	--address RAM_memory with 16 ROM_Code
		o_Data_Temp		:out		std_logic_vector(15 downto 0)	:= (others => '0')	--memory from DS18B20
	);
end ONE_WIRE_BLOCK;

architecture Behavioral of ONE_WIRE_BLOCK is

	CONSTANT COMMAND_MATCH_ROM			: std_logic_vector(7 downto 0)	:= x"55";
	CONSTANT COMMAND_SKIP_ROM			: std_logic_vector(7 downto 0)	:= x"CC";
	CONSTANT COMMAND_READ_ROM			: std_logic_vector(7 downto 0)	:= x"33";
	CONSTANT COMMAND_CONV_TEMP			: std_logic_vector(7 downto 0)	:= x"44";
	CONSTANT COMMAND_READ_SCRATCHPAD	: std_logic_vector(7 downto 0)	:= x"BE";

	type state_type is  (WAIT_800ms, 		--wait_800ms
						RESET, 				--tx reset impulse
						PRESENCE, 			--rx presence impulse 
						SEND, 				--prepare byte for tx
						WRITE_BYTE, 		--analysis bit = 0 or 1
						WRITE_LOW, 			--tx impulse for bit = 0
						WRITE_HIGH, 		--tx impulse for bit = 1
						GET_DATA,			--counting data bit
						READ_BIT,			--rx bit slot
						STOP); 				--test state_type

	signal r_State: state_type:= WAIT_800ms;													--state machine status

	signal r_Cnt_Time: 			integer range 0 to 799999:= 0;								--counter delta = 1 us, max value 800 ms		
	signal r_Cnt_Bit_Tx: 		integer range 0 to 8:= 0;									--counter bit for tx byte
	signal r_Cnt_Bit_Rx:		integer range 0 to 71:= 0;									--counter bit for rx byte
	signal r_Cnt_Bit: 			integer range 0 to 72:= 0;									--counter bit rx
	signal r_Cnt_Byte_Rom:		integer range 0 to 8:= 0;									--counter tx byte rom code
	signal r_Cnt_Bit_Rom:		integer range 7 to 63:= 7;									--ciunter bit rom code

	signal r_Adr_Mem:			std_logic_vector(3 downto 0):= (others => '0');		--address RAM_memory with 16 ROM_Code 
	signal r_ROM_Code:			std_logic_vector(63 downto 0):= (others => '0');	
	signal r_Data_Mem: 			std_logic_vector(71 downto 0):= (others => '0');	--9 Byte from DS18B20 
	signal r_Reset: 			std_logic:= '0';												--reset r_Cnt_Time (1 for reset)
	signal r_Command: 			std_logic_vector(7 downto 0):= (others => '0');		--command for DS18B20
	signal r_Presence:			std_logic:= '1';												--data probe for presence

	signal r_Write_Low_Flag: 	integer range 0 to 2:= 0;									--tx bit '0'
	signal r_Write_High_Flag: 	integer range 0 to 2:= 0;									--tx bit '1'
	signal r_Read_Bit_Flag: 	integer range 0 to 3:= 0;									--rx bit
	signal r_Send_Flag: 			integer range 0 to 7:= 0;									--Flag for send command

	signal o_Data_Temp_Received: std_logic:= '0';	

begin
	
	o_Adr_Mem <= r_Adr_Mem;
	r_Rom_Code <= i_Rom_Code;

	process(i_Clk) --main process 

	begin
		if rising_edge(i_Clk) then
			
			case	r_State is
				-------------------------------------------------------------
				when RESET =>						--impulse reset sensor
					r_Reset <= '0';											
					if (r_Cnt_Time = 1) then 									
						o_Data <= '0';				--begin reset line pull-down		
					elsif (r_Cnt_Time = 485) then 	--484 us
						o_Data <= '1';				--end reset line pull-up
					elsif (r_Cnt_Time = 550) then	--550 us 
						r_Presence <= i_Data;		--save value i_Data 
					elsif (r_Cnt_Time = 850) then	--850 us 
						r_State <= PRESENCE;							
					end if;
				-------------------------------------------------------------
				when PRESENCE =>											--verification presence from sensor
					if (r_Presence = '0' and i_Data = '1') then		
						r_Reset <= '1';									--reset r_Cnt_Time
						r_State <= SEND;									
					else																		
						r_Reset	<= '1';									
					--	o_Data_Temp	<= PRESENCE_ERROR_DATA;			
					--	o_Crc	<= '1';										
						r_State <= WAIT_800ms;							
					end if;
				-------------------------------------------------------------
				when SEND =>							--prepare byte for tx command
					if (r_Send_Flag = 0) then												
						r_Send_Flag <= 1;
						r_Command <= COMMAND_MATCH_ROM;
						r_State <= WRITE_BYTE;
					elsif (r_Send_Flag = 1) then	--rom code
						if r_Cnt_Byte_Rom = 8 then 
							r_Send_Flag <= 2;
							r_Cnt_Byte_Rom <= 0;
							r_Cnt_Bit_Rom <= 7;
							r_State <= SEND;
						else 
							r_Command <= r_ROM_Code((r_Cnt_Bit_Rom) downto (r_Cnt_Bit_Rom - 7));
							r_Cnt_Bit_Rom <= r_Cnt_Bit_Rom + 8;
							r_Cnt_Byte_Rom <= r_Cnt_Byte_Rom + 1;
							r_State <= WRITE_BYTE;	
						end if;
						
					--	r_Send_Flag <= 1;
					--	r_Command <= COMMAND_SKIP_ROM; 			--CCh - SKIP ROM
					--	r_Command <= COMMAND_READ_ROM;			--33h - Read ROM 
					--	r_State <= WRITE_BYTE;									
					elsif (r_Send_Flag = 2) then												
						r_Send_Flag <= 3;
						r_Command <= COMMAND_CONV_TEMP;
						r_State <= WRITE_BYTE;									
					elsif (r_Send_Flag = 3) then												
						r_Send_Flag <= 4;	
						r_State <= WAIT_800ms; 		--delay for sensor convert
					elsif	(r_Send_Flag = 4) then												
						r_Send_Flag <= 5;
						r_Command <= COMMAND_MATCH_ROM;
						r_State <= WRITE_BYTE;
					elsif (r_Send_Flag = 5) then	--rom code
						if r_Cnt_Byte_Rom = 8 then 
							r_Send_Flag <= 6;
							r_Cnt_Byte_Rom <= 0;
							r_Cnt_Bit_Rom <= 7;
							r_State <= SEND;
						else 
							r_Command <= r_ROM_Code((r_Cnt_Bit_Rom) downto (r_Cnt_Bit_Rom - 7));
							r_Cnt_Bit_Rom <= r_Cnt_Bit_Rom + 8;
							r_Cnt_Byte_Rom <= r_Cnt_Byte_Rom + 1;
							r_State <= WRITE_BYTE;	
						end if;
						
					--	r_Send_Flag <= 5;
					--	r_Command <= COMMAND_SKIP_ROM;; 			--CCh - SKIP ROM
					--	r_State <= WRITE_BYTE;								
					elsif (r_Send_Flag = 6) then							
						r_Send_Flag <= 7;
						r_Command <= COMMAND_READ_SCRATCHPAD;
						r_Adr_Mem <= r_Adr_Mem + 1; 	--increment for receive next Rom_code from RAM_memory
						r_State <= WRITE_BYTE;									
					elsif (r_Send_Flag = 7) then												
						r_Send_Flag <= 0;															
						r_State <= GET_DATA;									
					end if;
				-------------------------------------------------------------
				when WRITE_BYTE =>												

					case (r_Cnt_Bit_Tx) is												
						when 0 to 7 =>													
							if (r_Command(r_Cnt_Bit_Tx) = '0') then		--tx '0'
								r_State <= WRITE_LOW; 								
							else														--tx '1'
								r_State <= WRITE_HIGH;							
							end if;
							r_Cnt_Bit_Tx <= r_Cnt_Bit_Tx + 1;					
						when 8 =>															
							r_Cnt_Bit_Tx <= 0;											
							r_State <= SEND;										
						when others =>														
							r_Cnt_Bit_Tx  <= 0;										
							r_Write_Low_Flag <= 0;										
							r_Write_High_Flag <= 0;										
							r_State <= RESET;									
						end case;
				-------------------------------------------------------------
				when WRITE_LOW =>											--tx '0'
					case (r_Write_Low_Flag) is											
						when 0 =>																
							o_Data <= '0';									--start pull-down
							r_Reset <= '0';											
							if (r_Cnt_Time = 59) then					--60 us
								r_Reset <='1';								
								r_Write_Low_Flag <= 1;
							end if;
						when 1 =>											--end pull-down										
							o_Data <= '1';											
							r_Reset <= '0';										
							if (r_Cnt_Time = 3) then					--4 us
								r_Reset <= '1';									
								r_Write_Low_Flag <= 2;
							end if;
						when 2 =>											--end slot		
							r_Write_Low_Flag <= 0;											
							r_State <= WRITE_BYTE;								
						when others=>											
							r_Cnt_Bit_Tx <= 0;										
							r_Write_Low_Flag <= 0;									
							r_State <= RESET;								
					end case;
				-------------------------------------------------------------
				when WRITE_HIGH =>										--tx '1'
					case r_Write_High_Flag is										
						when 0 =>																
							o_Data <= '0';									--start pull-down
							r_Reset <= '0';												
							if (r_Cnt_Time = 9) then					--10 us
								r_Reset <= '1';									
								r_Write_High_Flag <= 1;
							end if;
						when 1 =>												
							o_Data <= '1';									--end pull-down
							r_Reset <= '0';									
							if (r_Cnt_Time = 53) then					--54 us
								r_Reset <= '1';									
								r_Write_High_Flag <= 2;
							end if;
						when 2 =>											--end slot
							r_Write_High_Flag <= 0;									
							r_State <= WRITE_BYTE;							
						when others =>												
							r_Cnt_Bit_Tx <= 0;									
							r_Write_High_Flag <= 0;										
							r_State <= RESET;									
					end case;
				-------------------------------------------------------------
				when WAIT_800ms =>														
				--	o_Crc <= '0';
					o_Data_Temp_Received	<= '0';			
					r_Reset <= '0';												
					if (r_Cnt_Time = 799999) then										
						r_Reset <='1';													
						r_State <= RESET;											
					end if;
				-------------------------------------------------------------
				when GET_DATA =>											--rx data from sensor
					case (r_Cnt_Bit) is											
						when 0 to 71 =>									--read 72 bit 			
							o_Data <= '0';											
							r_Cnt_Bit <= r_Cnt_Bit + 1;				
							r_State <= READ_BIT;									
						when 72 =>											--all data rx			
							r_Cnt_Bit_Rx <= 0;													
							r_Cnt_Bit <=0;												
							o_Data_Temp <= r_Data_Mem(15 downto 0);
							o_Data_Temp_Received <= '1'; 
						--	o_Crc <= '1';											
							r_State <= WAIT_800ms;								
						when others =>	 												
							r_Read_Bit_Flag <= 0;											
							r_Cnt_Bit <= 0; 											
					end case;
				-------------------------------------------------------------
				when READ_BIT =>								--rx bit from sensor
					case (r_Read_Bit_Flag) is											
						when 0 =>																
							r_Read_Bit_Flag <= 1;
						when 1 =>																
							o_Data <= '1';											
							r_Reset <= '0';									
							if r_Cnt_Time = 13 then			--14 us
								r_Reset <= '1';							
								r_Read_Bit_Flag <= 2;
							end if; 
						when 2 =>													
							r_Data_Mem(r_Cnt_Bit_Rx) <= i_Data;					
							r_Cnt_Bit_Rx <= r_Cnt_Bit_Rx + 1;										
							r_Read_Bit_Flag <= 3;
						when 3 =>																
							r_Reset <= '0';											
							if r_Cnt_Time = 63 then			--62 us
								r_Reset <= '1';												
								r_Read_Bit_Flag <= 0;										
								r_State <= GET_DATA;							
							end if;
						when others => 													
							r_Read_Bit_Flag <= 0;										
							r_Cnt_Bit_Rx <= 0;											
							r_Cnt_Bit <= 0;										
							r_State <= RESET;								
					end case;
				-------------------------------------------------------------
				when STOP => 
					r_State <= Stop;
					o_Data <= '1';
				-------------------------------------------------------------				
				when others =>																
					r_State <= RESET;													
				-------------------------------------------------------------					
			end case;
		end if;
	end process;

	process(i_Clk, r_Reset) --counter process
	begin
		if rising_edge(i_Clk) then
			if (r_Reset = '1') then		
				r_Cnt_Time <= 0;						
			else
				r_Cnt_Time <= r_Cnt_Time + 1;					
			end if;
		end if;
	end process;

end Behavioral;