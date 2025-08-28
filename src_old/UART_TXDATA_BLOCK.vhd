LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY UART_TXDATA_BLOCK IS

	PORT (
		i_Clk : IN STD_LOGIC;
		i_TxStart : IN STD_LOGIC;
		i_TxHead : IN STD_LOGIC_VECTOR(10 DOWNTO 0);

		i_RamData : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		i_DriverReady : IN STD_LOGIC;

		i_MPU_RE : IN STD_LOGIC;
		i_Addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		i_DataReadyWE : IN STD_LOGIC;
		i_MPU_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		
		i_Reset	: IN STD_LOGIC;

		o_RamRE : OUT STD_LOGIC := '0';
		o_RamAddr : OUT STD_LOGIC_VECTOR(8 DOWNTO 0) := (OTHERS => '0');

		o_DV : OUT STD_LOGIC := '0';
		o_TxData : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

		o_TxTail : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0')

	);
END UART_TXDATA_BLOCK;

ARCHITECTURE arch OF UART_TXDATA_BLOCK IS

	--STATE MACHINES
	TYPE state IS (
		s_Idle,
		s_CheckPtr,
		s_SetRE,
		s_WaitData1,
		s_WaitData2,
		s_GetData,
		s_SetDV,
		s_ResetDV,
		s_Wait
	);
	SIGNAL r_State : state := s_Idle;

	--REGS
	SIGNAL r_TxTail : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0');
	SIGNAL r_RamData : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

BEGIN

	PROCESS (i_Reset,i_Clk)
	BEGIN

		IF (i_Reset = '1') THEN
			
			--FSM set to IDLE (RESET)
			r_State <= s_Idle;
			
			--TX TAIL DATA UPDATE
			IF (i_DataReadyWE = '1') THEN
				r_TxTail <= (others=>'0');
			END IF;
			
		ELSIF rising_edge(i_Clk) THEN

			--FSM
			CASE r_State IS
					------------------------------------------------
				WHEN s_Idle =>
					IF (i_TxStart = '1') THEN
						r_State <= s_CheckPtr;
					END IF;
					------------------------------------------------
				WHEN s_CheckPtr =>
					IF (r_TxTail = i_TxHead) THEN
						r_State <= s_Idle;
					ELSE
						r_State <= s_SetRE;
					END IF;
					------------------------------------------------
				WHEN s_SetRE =>
					o_RamAddr <= r_TxTail(10 DOWNTO 2);
					o_RamRE <= '1';
					r_State <= s_WaitData1;
					------------------------------------------------
				WHEN s_WaitData1 =>
					o_RamRE <= '0';
					r_State <= s_GetData;
					------------------------------------------------
				WHEN s_GetData =>
					r_RamData <= i_RamData;
					r_State <= s_SetDV;
					------------------------------------------------
				WHEN s_SetDV =>
					CASE (r_TxTail(1 DOWNTO 0)) IS
						WHEN "00" => o_TxData <= r_RamData(7 DOWNTO 0);
						WHEN "01" => o_TxData <= r_RamData(15 DOWNTO 8);
						WHEN "10" => o_TxData <= r_RamData(23 DOWNTO 16);
						WHEN OTHERS => o_TxData <= r_RamData(31 DOWNTO 24);
					END CASE;

					IF (i_DriverReady = '1') THEN
						o_DV <= '1';
						r_State <= s_ResetDV;
					END IF;
					------------------------------------------------
				WHEN s_ResetDV =>
					o_DV <= '0';

					r_State <= s_Wait;
					------------------------------------------------
				WHEN s_Wait =>
					IF (i_DriverReady = '1') THEN
						r_TxTail <= r_TxTail + 1;
						r_State <= s_CheckPtr;
					END IF;
					------------------------------------------------
				WHEN OTHERS => NULL;
			END CASE;
				
		END IF;

	END PROCESS;

	o_TxTail <= (31 downto 11 => '0') & r_TxTail;
	
END arch;