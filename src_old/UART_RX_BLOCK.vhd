LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY UART_RX_BLOCK IS

	PORT (
		i_Clk : IN STD_LOGIC;
		i_Rx : IN STD_LOGIC;	   
		
		i_Reset : IN STD_LOGIC;

		o_RxDV : OUT STD_LOGIC := '0';
		o_RxData : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
		o_Breakline : OUT STD_LOGIC := '0';

		o_Test : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')
	);
END UART_RX_BLOCK;

ARCHITECTURE arch OF UART_RX_BLOCK IS

	--CONSTANTS
	CONSTANT c_TickPerBit : INTEGER := 27;
	CONSTANT c_BitPerWord : INTEGER := 11;
	CONSTANT c_DataStorePoint : INTEGER := c_TickPerBit/2;

	--STATE MACHINES
	TYPE t_state IS (
		s_Idle,
		s_Receive
	);
	SIGNAL r_State : t_state := s_Idle;

	--INPUT BUFFER
	SIGNAL r_Rx : STD_LOGIC := '1';

	--STORAGE OF RECIEVED BIT
	SIGNAL r_RxBitBuffer : STD_LOGIC := '1';

	--COUNTERS
	SIGNAL r_CntClk : INTEGER RANGE 0 TO c_TickPerBit := 0;
	SIGNAL r_CntBit : INTEGER RANGE 0 TO c_BitPerWord := 0;

	--RECIEVED DATA BUS
	SIGNAL r_RxData : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

	--CALCULATED PARITY
	SIGNAL r_RxDataParity : STD_LOGIC := '0';

	--FLAGS
	SIGNAL r_FlagBreakLine : STD_LOGIC := '0';
	SIGNAL r_RxDataValid : STD_LOGIC := '0';

BEGIN

	-- == CLK and BIT counters ==
	PROCESS (i_Clk)
	BEGIN

		IF rising_edge(i_Clk) THEN
			IF (r_State = s_Receive) THEN
				IF (r_CntClk = c_TickPerBit - 1) THEN
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
	
	
	-- == FSM ==
	PROCESS (i_Reset,i_Clk)
	BEGIN

		IF (i_Reset = '1') THEN	  --FMS RESET
			r_State <= s_Idle;
		ELSIF falling_edge(i_Clk) THEN

			r_Rx <= i_Rx;

			--RX Line restore
			IF (r_Rx = '1') THEN
				r_FlagBreakLine <= '0';
			END IF;

			r_RxDataValid <= '0';	

			-- === UART WORD RECIEVER ===
			--FSM TO TAKE A DESICION
			CASE (r_State) IS
					------------------------------------------------------------		 
				WHEN s_Idle =>
				
					--GOT START BIT AND LINE ISN'T BROKEN
					IF (r_Rx = '0' AND r_FlagBreakLine = '0') THEN
						r_State <= s_Receive;
					END IF;
					------------------------------------------------------------ 	   
				WHEN s_Receive =>

					--RX ACCUMULATOR
					IF (r_CntClk = c_DataStorePoint) THEN --middle of the bit
						
						--FSM RECEIVER
						CASE (r_CntBit) IS
							WHEN 0 =>
								IF (r_Rx = '1') THEN
									r_State <= s_Idle;
								END IF;
							WHEN 1 => r_RxData(0) <= r_Rx;
							WHEN 2 => r_RxData(1) <= r_Rx;
							WHEN 3 => r_RxData(2) <= r_Rx;
							WHEN 4 => r_RxData(3) <= r_Rx;
							WHEN 5 => r_RxData(4) <= r_Rx;
							WHEN 6 => r_RxData(5) <= r_Rx;
							WHEN 7 => r_RxData(6) <= r_Rx;
							WHEN 8 => r_RxData(7) <= r_Rx;
							WHEN 9 => r_RxDataParity <=	--check parity bit
								r_Rx XOR (
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

								IF (r_Rx = '1') THEN
									r_RxDataValid <= NOT r_RxDataParity; --DATA VALID
								ELSE
									r_FlagBreakLine <= '1';
								END IF;

								r_State <= s_Idle;

							WHEN OTHERS => r_State <= s_Idle;
						END CASE;
						
					END IF; --(r_CntClk = c_DataStorePoint)
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