LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY UART_TX_BLOCK IS

	PORT (
		i_Clk : IN STD_LOGIC;
		i_TxDV : IN STD_LOGIC;
		i_Data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

		o_TX : OUT STD_LOGIC := '1';
		o_TX_Active : OUT STD_LOGIC := '0';
		o_Ready : OUT STD_LOGIC := '1'
	);
END UART_TX_BLOCK;

ARCHITECTURE arch OF UART_TX_BLOCK IS

	--CONSTANTS
	CONSTANT c_BIT_TICKS : INTEGER := 18;
	CONSTANT c_BIT_NUM : INTEGER := 15;
	
	--STATE MACHINES
	TYPE state IS (
		s_Idle,
		s_TxOut
	);
	SIGNAL r_State : state := s_Idle;

	--REGS
	SIGNAL r_ClkCnt : INTEGER RANGE 0 TO c_BIT_TICKS - 1 := 0;
	SIGNAL r_BitCnt : INTEGER RANGE 0 TO c_BIT_NUM := 0;
	SIGNAL r_CntEn : STD_LOGIC := '0';

BEGIN

	PROCESS (i_Clk)
	BEGIN

		IF rising_edge(i_Clk) THEN
			IF (r_CntEn = '0') THEN --NO TRASNMITION
				r_ClkCnt <= 0;
				r_BitCnt <= 0;
			ELSE --TRASNMITION IS GOING
				IF (r_ClkCnt = c_BIT_TICKS - 1) THEN
					r_ClkCnt <= 0;
					r_BitCnt <= r_BitCnt + 1;
				ELSE
					r_ClkCnt <= r_ClkCnt + 1;
				END IF;
			END IF;
		END IF;

	END PROCESS;
	PROCESS (i_Clk)
	BEGIN

		IF falling_edge(i_Clk) THEN

			CASE (r_State) IS
					-------------------------------------------------------------
				WHEN s_Idle =>
					o_TX <= '1';

					IF (i_TxDV = '1') THEN
						o_Ready <= '0';
						r_CntEn <= '1';
						r_State <= s_TxOut;
					END IF;
					-------------------------------------------------------------	
				WHEN s_TxOut =>
					CASE (r_BitCnt) IS
						WHEN 0 => o_TX_ACtive <= '1';
						WHEN 1 => o_Tx <= '0';
						WHEN 2 => o_Tx <= i_Data(0);
						WHEN 3 => o_Tx <= i_Data(1);
						WHEN 4 => o_Tx <= i_Data(2);
						WHEN 5 => o_Tx <= i_Data(3);
						WHEN 6 => o_Tx <= i_Data(4);
						WHEN 7 => o_Tx <= i_Data(5);
						WHEN 8 => o_Tx <= i_Data(6);
						WHEN 9 => o_Tx <= i_Data(7);
						WHEN 10 => o_Tx <= i_Data(0) XOR i_Data(1) XOR i_Data(2) XOR i_Data(3) XOR i_Data(4) XOR i_Data(5) XOR i_Data(6) XOR i_Data(7);
						WHEN 11 => o_Tx <= '1';
						WHEN 12 =>
							o_TX_Active <= '0';
						WHEN 15 =>
							o_Ready <= '1';
							r_CntEn <= '0';
							r_State <= s_Idle;
						WHEN OTHERS => NULL;
					END CASE;
					-------------------------------------------------------------	
				WHEN OTHERS => NULL;
					-------------------------------------------------------------	
			END CASE;

		END IF;

	END PROCESS;
END arch;