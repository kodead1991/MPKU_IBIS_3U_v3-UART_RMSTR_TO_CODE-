LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY UART_RX_BLOCK IS

	PORT (
		i_Clk : IN STD_LOGIC;
		i_Rx : IN STD_LOGIC;

		o_RxDV : OUT STD_LOGIC := '0';
		o_RxData : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
		o_Breakline : OUT STD_LOGIC := '0';

		o_Test : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')
	);
END UART_RX_BLOCK;

ARCHITECTURE arch OF UART_RX_BLOCK IS

	--CONSTANTS
	CONSTANT c_CntPerBit : INTEGER := 26;
	CONSTANT c_DataStorePiont : INTEGER := 13;

	--STATE MACHINES
	TYPE t_state IS (
		s_Idle,
		s_StartBit,
		s_RxIn
	);
	SIGNAL r_State : t_state := s_Idle;

	--INPUT BUFFER
	SIGNAL r_RX : STD_LOGIC := '1';

	--ACCUMULATOR OF '1' IN i_RX
	SIGNAL r_Acc : INTEGER RANGE 0 TO c_CntPerBit := 0;

	--STORAGE OF RECIEVED BIT
	SIGNAL r_RxBitBuffer : STD_LOGIC := '1';

	--COUNTERS
	SIGNAL r_CntClk : INTEGER RANGE 0 TO 26 := 0;
	SIGNAL r_CntBit : INTEGER RANGE 0 TO 10 := 0;

	--RECIEVED DATA BUS
	SIGNAL r_RxData : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

	--CALCULATED PARITY
	SIGNAL r_RxDataParity : STD_LOGIC := '0';

	--FLAGS
	SIGNAL r_FlagBreakLine : STD_LOGIC := '0';
	SIGNAL r_RxDataValid : STD_LOGIC := '0';

BEGIN

	PROCESS (i_Clk)
	BEGIN

		IF rising_edge(i_Clk) THEN
			IF (r_State = s_RxIn) THEN
				IF (r_CntClk = 26) THEN
					r_CntClk <= 0;
					r_CntBit <= r_CntBit + 1;
				ELSE
					r_CntClk <= r_CntClk + 1;
				END IF;
			ELSE
				r_CntClk <= 0;
				r_CntBit <= 0;
			END IF;

		END IF;

	END PROCESS;

	PROCESS (i_Clk)
	BEGIN

		IF falling_edge(i_Clk) THEN

			r_Rx <= i_Rx;

			IF (r_Rx = '1') THEN
				r_FlagBreakLine <= '0';
			END IF;

			r_RxDataValid <= '0';

			--**************************UART WORD RECIEVER****************************************************
			CASE (r_State) IS
					------------------------------------------------------------		 
				WHEN s_Idle =>

					IF (r_Rx = '0' AND r_FlagBreakLine = '0') THEN
						--r_State <= s_StartBit;
						r_State <= s_RxIn;
					END IF;
					------------------------------------------------------------ 	   
				WHEN s_RxIn =>

					IF (r_CntClk < c_CntPerBit - 1) THEN --counting until border
						IF (r_Rx = '1') THEN --accumulating '1'
							r_Acc <= r_Acc + 1;
						END IF;
					ELSIF (r_CntClk = c_CntPerBit - 1) THEN --MAKE A DECISION
						IF (r_Acc >= c_DataStorePiont) THEN
							r_RxBitBuffer <= '1';
						ELSE
							r_RxBitBuffer <= '0';
						END IF;
					ELSE --STORE A DECISION's RESULT
						r_Acc <= 0;

						CASE (r_CntBit) IS
							WHEN 0 =>
								IF (r_RxBitBuffer = '1') THEN
									r_State <= s_Idle;
								END IF;
							WHEN 1 => r_RxData(0) <= r_RxBitBuffer;
							WHEN 2 => r_RxData(1) <= r_RxBitBuffer;
							WHEN 3 => r_RxData(2) <= r_RxBitBuffer;
							WHEN 4 => r_RxData(3) <= r_RxBitBuffer;
							WHEN 5 => r_RxData(4) <= r_RxBitBuffer;
							WHEN 6 => r_RxData(5) <= r_RxBitBuffer;
							WHEN 7 => r_RxData(6) <= r_RxBitBuffer;
							WHEN 8 => r_RxData(7) <= r_RxBitBuffer;
							WHEN 9 => r_RxDataParity <=
								r_RxBitBuffer XOR (
								(
								(r_RxData(0) XOR r_RxData(1))
								XOR
								(r_RxData(2) XOR r_RxData(3))
								)
								XOR
								(
								(r_RxData(4) XOR r_RxData(5))
								XOR
								(r_RxData(6) XOR r_RxData(7))
								)
								);
							WHEN 10 => --STOP BIT ANALISYS

								IF (r_RxBitBuffer = '1') THEN
									r_RxDataValid <= NOT r_RxDataParity;
								ELSE
									r_FlagBreakLine <= '1';
								END IF;

								r_State <= s_Idle;

							WHEN OTHERS => r_State <= s_Idle;
						END CASE;
					END IF;
					------------------------------------------------------------
				WHEN OTHERS => r_State <= s_Idle;
					------------------------------------------------------------
			END CASE;

		END IF;
	END PROCESS;

	o_RxDV <= r_RxDataValid;
	o_RxData <= r_RxData WHEN (r_RxDataValid = '1');
	o_Breakline <= r_FlagBreakLine;

END arch;