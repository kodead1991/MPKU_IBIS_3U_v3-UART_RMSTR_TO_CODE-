LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ONE_WIRE_BLOCK_v2_5 IS

	PORT (
		i_NAME0 : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
		i_NAME1 : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
		i_NAME2 : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
		i_NAME3 : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
		i_NAME4 : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
		i_NAME5 : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
		i_NAME6 : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
		i_NAME7 : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
		i_NAME8 : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
		i_NAME9 : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
		i_NAME10 : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
		i_NAME11 : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
		i_NAME12 : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
		i_NAME13 : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
		i_NAME14 : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
		i_NAME15 : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');

		o_TEMP0 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
		o_TEMP1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
		o_TEMP2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
		o_TEMP3 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
		o_TEMP4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
		o_TEMP5 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
		o_TEMP6 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
		o_TEMP7 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
		o_TEMP8 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
		o_TEMP9 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
		o_TEMP10 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
		o_TEMP11 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
		o_TEMP12 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
		o_TEMP13 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
		o_TEMP14 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
		o_TEMP15 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
		i_Clk : IN STD_LOGIC;
		i_1MHz : IN STD_LOGIC;
		i_1kHz : IN STD_LOGIC;

		i_1WIRE : IN STD_LOGIC;
		o_1WIRE : OUT STD_LOGIC := '1';

		o_Test : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')
	);
END ONE_WIRE_BLOCK_v2_5;

ARCHITECTURE arch OF ONE_WIRE_BLOCK_v2_5 IS

	--CONSTANTS
	CONSTANT c_CntMhz_Div : INTEGER := 25;--clock divider coefficient
	CONSTANT c_SensorNum : INTEGER := 2; --sensor's amount
	CONSTANT c_WaitTime : INTEGER := 188; --wait statement's lenght

	--STATE MACHINES
	TYPE state_type IS (
		RESET_CONTROL,
		SKIP_ROM,
		CONV_TEMP,
		WAIT_800ms,
		RESET_FUNC,
		MATCH_ROM,
		ID_ROM0,
		ID_ROM1,
		ID_ROM2,
		ID_ROM3,
		ID_ROM4,
		ID_ROM5,
		ID_ROM6,
		ID_ROM7,
		READ_ROM,
		RECIEVE
	);
	SIGNAL r_State_1WIRE : state_type := RESET_CONTROL;

	----REGS----
	--1WIRE BUS
	SIGNAL r_1WIRE_Reset : STD_LOGIC := '1';
	SIGNAL r_1WIRE_Tx : STD_LOGIC := '1';
	SIGNAL r_1WIRE_Rx : STD_LOGIC := '1';

	--FLAGS
	SIGNAL r_ResetStart : STD_LOGIC := '0';
	SIGNAL r_ResetEnd : STD_LOGIC := '0';
	SIGNAL r_TxStart : STD_LOGIC := '0';
	SIGNAL r_TxEnd : STD_LOGIC := '0';
	SIGNAL r_WaitStart : STD_LOGIC := '0';
	SIGNAL r_WaitEnd : STD_LOGIC := '0';
	SIGNAL r_RxStart : STD_LOGIC := '0';
	SIGNAL r_RxEnd : STD_LOGIC := '0';

	--SENS's COUNTER
	SIGNAL r_CntSensor : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');

	--1 MHz TIMER
	SIGNAL r_Cnt_Time1MHz : INTEGER RANGE 0 TO 855 := 0; --main timer, delta = 1 us, max value 851 ms
	--1MHz COUNTER RESET ('1' to reset)
	SIGNAL r_Reset_1MHz_Reset : STD_LOGIC := '1';
	SIGNAL r_Reset_1MHz_Tx : STD_LOGIC := '1';
	SIGNAL r_Reset_1MHz_Rx : STD_LOGIC := '1';

	--4 kHz TIMER
	SIGNAL r_Cnt_Time1kHz : INTEGER RANGE 0 TO 188 := 0; --main timer, delta = 4 ms
	SIGNAL r_Reset_1kHz : STD_LOGIC := '1'; --reset r_Cnt_Time1kHz ('1' to reset)

	--BIT/BYTE COUNTERS		
	SIGNAL r_Cnt_Bit_Tx : INTEGER RANGE 0 TO 8 := 0; --tx bit count
	SIGNAL r_Cnt_Bit_Rx : INTEGER RANGE 0 TO 16 := 0; --rx bit count

	--SENS DATA
	SIGNAL r_SensID : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
	SIGNAL r_RxData : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); --9 Byte from DS18B20 
	SIGNAL r_SendBufer : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); --tx buffer

	SIGNAL r_Write_Low : INTEGER RANGE 0 TO 1 := 0; --tx bit '0'
	SIGNAL r_Write_High : INTEGER RANGE 0 TO 1 := 0; --tx bit '1'
	SIGNAL r_BitRecieve : INTEGER RANGE 0 TO 3 := 0; --rx bit
	SIGNAL r_State : INTEGER RANGE 0 TO 7 := 0; --flag for send command

BEGIN

	o_1WIRE <= r_1WIRE_Reset AND r_1WIRE_Tx AND r_1WIRE_Rx;

	------------------------------------------------------------
	--TIMER 1MHz
	PROCESS (i_Clk)
	BEGIN

		IF falling_edge(i_Clk) THEN
			IF (r_Reset_1MHz_Reset = '1' AND r_Reset_1MHz_Tx = '1' AND r_Reset_1MHz_Rx = '1') THEN
				r_Cnt_Time1MHz <= 0;
			ELSE
				IF (i_1MHz = '1') THEN
					r_Cnt_Time1MHz <= r_Cnt_Time1MHz + 1;
				END IF;
			END IF;
		END IF;

	END PROCESS;

	------------------------------------------------------------
	--TIMER 1kHz
	PROCESS (i_Clk)
	BEGIN

		IF falling_edge(i_Clk) THEN
			IF (r_Reset_1kHz = '1') THEN
				r_Cnt_Time1kHz <= 0;
			ELSE
				IF (i_1kHz = '1') THEN
					r_Cnt_Time1kHz <= r_Cnt_Time1kHz + 1;
				END IF;
			END IF;
		END IF;

	END PROCESS;

	------------------------------------------------------------
	--RESET BLOCK
	PROCESS (i_Clk)
	BEGIN

		IF rising_edge(i_Clk) THEN
			IF (r_ResetStart = '1') THEN
				IF (i_1MHz = '1') THEN
					r_Reset_1MHz_Reset <= '0'; --START MAIN TIMER										
					IF (r_Cnt_Time1MHz = 1) THEN --START STATE "RESET/LINE PULL-DOWN"							
						r_1WIRE_Reset <= '0';
					ELSIF (r_Cnt_Time1MHz = 485) THEN --END STATE "RESET/LINE PULL-DOWN"
						r_1WIRE_Reset <= '1';
					ELSIF (r_Cnt_Time1MHz = 851) THEN --SEND COMMANDS
						r_Reset_1MHz_Reset <= '1'; --END MAIN TIMER
						r_ResetEnd <= '1';
					END IF;
				END IF;
			ELSE
				r_ResetEnd <= '0';
				r_Reset_1MHz_Reset <= '1'; --END MAIN TIMER
			END IF;
		END IF;
	END PROCESS;

	------------------------------------------------------------
	--TRANSMIT BLOCK
	PROCESS (i_Clk)
	BEGIN

		IF rising_edge(i_Clk) THEN
			IF (r_TxStart = '1') THEN
				IF (i_1MHz = '1') THEN
					IF (r_Cnt_Bit_Tx = 8) THEN
						r_TxEnd <= '1';
					ELSE
						IF (r_SendBufer(r_Cnt_Bit_Tx) = '0') THEN
							CASE (r_Write_Low) IS
									------------------------------------------------------------										
								WHEN 0 =>
									r_1WIRE_Tx <= '0'; --start pull-down
									r_Reset_1MHz_Tx <= '0';
									IF (r_Cnt_Time1MHz = 59) THEN --60 us
										r_Reset_1MHz_Tx <= '1';
										r_Write_Low <= 1;
									END IF;
									------------------------------------------------------------
								WHEN OTHERS => --end pull-down										
									r_1WIRE_Tx <= '1';
									r_Reset_1MHz_Tx <= '0';
									IF (r_Cnt_Time1MHz = 3) THEN --4 us
										r_Reset_1MHz_Tx <= '1';
										r_Write_Low <= 0;
										r_Cnt_Bit_Tx <= r_Cnt_Bit_Tx + 1;
									END IF;
									------------------------------------------------------------														
							END CASE;
						ELSE
							CASE (r_Write_High) IS
									------------------------------------------------------------
								WHEN 0 =>
									r_1WIRE_Tx <= '0'; --start pull-down
									r_Reset_1MHz_Tx <= '0';
									IF (r_Cnt_Time1MHz = 9) THEN --10 us
										r_Reset_1MHz_Tx <= '1';
										r_Write_High <= 1;
									END IF;
									------------------------------------------------------------
								WHEN OTHERS =>
									r_1WIRE_Tx <= '1'; --end pull-down
									r_Reset_1MHz_Tx <= '0';
									IF (r_Cnt_Time1MHz = 53) THEN --54 us
										r_Reset_1MHz_Tx <= '1';
										r_Write_High <= 0;
										r_Cnt_Bit_Tx <= r_Cnt_Bit_Tx + 1;
									END IF;
									------------------------------------------------------------													
							END CASE;
						END IF;
					END IF;

				END IF;
			ELSE
				r_Cnt_Bit_Tx <= 0;
				r_TxEnd <= '0';
				r_Reset_1MHz_Tx <= '1';
			END IF;
		END IF;

	END PROCESS;

	------------------------------------------------------------
	--WAIT BLOCK
	PROCESS (i_Clk)
	BEGIN

		IF rising_edge(i_Clk) THEN
			IF (r_WaitStart = '1') THEN
				IF (i_1MHz = '1') THEN
					r_Reset_1kHz <= '0';
					IF (r_Cnt_Time1kHz = c_WaitTime) THEN --min conv time for 12-bit resolution 750 ms										
						r_Reset_1kHz <= '1';
						r_WaitEnd <= '1';
					END IF;
				END IF;
			ELSE
				r_WaitEnd <= '0';
				r_Reset_1kHz <= '1';
			END IF;
		END IF;

	END PROCESS;

	------------------------------------------------------------
	--RECIEVE TEMPREATURE DATA	
	PROCESS (i_Clk)
	BEGIN

		IF rising_edge(i_Clk) THEN
			IF (r_RxStart = '1') THEN
				IF (i_1MHz = '1') THEN
					CASE (r_Cnt_Bit_Rx) IS
							------------------------------------------------------------
						WHEN 0 TO 15 =>
							CASE (r_BitRecieve) IS
									------------------------------------------------------------
								WHEN 0 =>
									r_1WIRE_Rx <= '0';
									r_BitRecieve <= 1;
									------------------------------------------------------------
								WHEN 1 =>
									r_1WIRE_Rx <= '1';
									r_Reset_1MHz_Rx <= '0';
									IF (r_Cnt_Time1MHz = 13) THEN --14 us
										r_RxData(r_Cnt_Bit_Rx) <= i_1WIRE;
										r_Cnt_Bit_Rx <= r_Cnt_Bit_Rx + 1;
										r_BitRecieve <= 2;
									END IF;
									------------------------------------------------------------
								WHEN OTHERS =>
									r_Reset_1MHz_Rx <= '0';
									IF (r_Cnt_Time1MHz = 75) THEN --62 us
										r_Reset_1MHz_Rx <= '1';
										r_BitRecieve <= 0;
									END IF;
							END CASE;
							------------------------------------------------------------									
						WHEN OTHERS => --all data rx			
							r_Cnt_Bit_Rx <= 0;
							r_RxEnd <= '1';
					END CASE;
				END IF;
			ELSE
				r_RxEnd <= '0';
				r_BitRecieve <= 0;
				r_Reset_1MHz_Rx <= '1';
			END IF;
		END IF;

	END PROCESS;

	------------------------------------------------------------
	--MASTER BLOCK
	PROCESS (i_Clk)
	BEGIN

		IF rising_edge(i_Clk) THEN
			IF (i_1MHz = '1') THEN
				CASE (r_State_1WIRE) IS
					WHEN RESET_CONTROL =>
						r_ResetStart <= '1';
						IF (r_ResetEnd = '1') THEN
							r_ResetStart <= '0';
							r_State_1WIRE <= SKIP_ROM;
						END IF;
					WHEN SKIP_ROM =>
						r_SendBufer <= x"CC";
						r_TxStart <= '1';
						IF (r_TxEnd = '1') THEN
							r_TxStart <= '0';
							r_State_1WIRE <= CONV_TEMP;
						END IF;
					WHEN CONV_TEMP =>
						r_SendBufer <= x"44";
						r_TxStart <= '1';
						IF (r_TxEnd = '1') THEN
							r_TxStart <= '0';
							r_State_1WIRE <= WAIT_800ms;
						END IF;
					WHEN WAIT_800ms =>
						r_WaitStart <= '1';
						IF (r_WaitEnd = '1') THEN
							r_WaitStart <= '0';
							r_State_1WIRE <= RESET_FUNC;
						END IF;
					WHEN RESET_FUNC =>
						r_ResetStart <= '1';
						IF (r_ResetEnd = '1') THEN
							r_ResetStart <= '0';
							r_State_1WIRE <= MATCH_ROM;
						END IF;
					WHEN MATCH_ROM =>
						r_SendBufer <= x"55";
						r_TxStart <= '1';
						IF (r_TxEnd = '1') THEN
							r_TxStart <= '0';
							r_State_1WIRE <= ID_ROM0;
						END IF;
					WHEN ID_ROM0 =>
						r_SendBufer <= r_SensID(7 DOWNTO 0);
						r_TxStart <= '1';
						IF (r_TxEnd = '1') THEN
							r_TxStart <= '0';
							r_State_1WIRE <= ID_ROM1;
						END IF;
					WHEN ID_ROM1 =>
						r_SendBufer <= r_SensID(15 DOWNTO 8);
						r_TxStart <= '1';
						IF (r_TxEnd = '1') THEN
							r_TxStart <= '0';
							r_State_1WIRE <= ID_ROM2;
						END IF;
					WHEN ID_ROM2 =>
						r_SendBufer <= r_SensID(23 DOWNTO 16);
						r_TxStart <= '1';
						IF (r_TxEnd = '1') THEN
							r_TxStart <= '0';
							r_State_1WIRE <= ID_ROM3;
						END IF;
					WHEN ID_ROM3 =>
						r_SendBufer <= r_SensID(31 DOWNTO 24);
						r_TxStart <= '1';
						IF (r_TxEnd = '1') THEN
							r_TxStart <= '0';
							r_State_1WIRE <= ID_ROM4;
						END IF;
					WHEN ID_ROM4 =>
						r_SendBufer <= r_SensID(39 DOWNTO 32);
						r_TxStart <= '1';
						IF (r_TxEnd = '1') THEN
							r_TxStart <= '0';
							r_State_1WIRE <= ID_ROM5;
						END IF;
					WHEN ID_ROM5 =>
						r_SendBufer <= r_SensID(47 DOWNTO 40);
						r_TxStart <= '1';
						IF (r_TxEnd = '1') THEN
							r_TxStart <= '0';
							r_State_1WIRE <= ID_ROM6;
						END IF;
					WHEN ID_ROM6 =>
						r_SendBufer <= r_SensID(55 DOWNTO 48);
						r_TxStart <= '1';
						IF (r_TxEnd = '1') THEN
							r_TxStart <= '0';
							r_State_1WIRE <= ID_ROM7;
						END IF;
					WHEN ID_ROM7 =>
						r_SendBufer <= r_SensID(63 DOWNTO 56);
						r_TxStart <= '1';
						IF (r_TxEnd = '1') THEN
							r_TxStart <= '0';
							r_State_1WIRE <= READ_ROM;
						END IF;
					WHEN READ_ROM =>
						r_SendBufer <= x"BE";
						r_TxStart <= '1';
						IF (r_TxEnd = '1') THEN
							r_TxStart <= '0';
							r_State_1WIRE <= RECIEVE;
						END IF;
					WHEN RECIEVE =>
						r_RxStart <= '1';
						IF (r_RxEnd = '1') THEN
							r_RxStart <= '0';
							IF ((conv_integer(r_CntSensor)) = c_SensorNum - 1) THEN --ALL SENS HAVE BEEN CHECKED 
								r_State_1WIRE <= RESET_CONTROL; --RESET SEND-STATE-MACHINE
								r_CntSensor <= (OTHERS => '0'); --RESET SENS NAME's COUNTER
							ELSE
								r_CntSensor <= r_CntSensor + 1; --SET NEXT SENS NAME
								r_State_1WIRE <= RESET_FUNC; --REPEAT THE TEMPREATURE READING CYCLE (MATCH >> READ >> GET DATA)			
							END IF;
						END IF;
				END CASE;

			END IF;
		END IF;

	END PROCESS;

	------------------------------------------------------------
	--SENS DATA OUT
	PROCESS (i_Clk)
	BEGIN

		IF rising_edge(i_Clk) THEN
			IF (i_1MHz = '1') THEN

				IF (r_Cnt_Bit_Rx = 16) THEN
					CASE conv_integer(r_CntSensor) IS --SAVE SENS DATA TO OUTPUT BUSES
						WHEN 0 => o_TEMP0 <= x"0000" & r_RxData(15 DOWNTO 0);
						WHEN 1 => o_TEMP1 <= x"0000" & r_RxData(15 DOWNTO 0);
						WHEN 2 => o_TEMP2 <= x"0000" & r_RxData(15 DOWNTO 0);
						WHEN 3 => o_TEMP3 <= x"0000" & r_RxData(15 DOWNTO 0);
						WHEN 4 => o_TEMP4 <= x"0000" & r_RxData(15 DOWNTO 0);
						WHEN 5 => o_TEMP5 <= x"0000" & r_RxData(15 DOWNTO 0);
						WHEN 6 => o_TEMP6 <= x"0000" & r_RxData(15 DOWNTO 0);
						WHEN OTHERS => o_TEMP7 <= x"0000" & r_RxData(15 DOWNTO 0);
					END CASE;
				END IF;

			END IF;
		END IF;
	END PROCESS;

	WITH (r_CntSensor) SELECT
	r_SensID <=
		i_NAME0 WHEN "0000",
		i_NAME1 WHEN "0001",
		i_NAME2 WHEN "0010",
		i_NAME3 WHEN "0011",
		i_NAME4 WHEN "0100",
		i_NAME5 WHEN "0101",
		i_NAME6 WHEN "0110",
		i_NAME7 WHEN "0111",
		i_NAME8 WHEN "1000",
		i_NAME9 WHEN "1001",
		i_NAME10 WHEN "1010",
		i_NAME11 WHEN "1011",
		i_NAME12 WHEN "1100",
		i_NAME13 WHEN "1101",
		i_NAME14 WHEN "1110",
		i_NAME15 WHEN OTHERS;

END arch;