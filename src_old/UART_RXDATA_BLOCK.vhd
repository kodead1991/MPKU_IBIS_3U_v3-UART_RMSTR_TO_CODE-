LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY UART_RXDATA_BLOCK IS

	PORT (
		i_Clk : IN STD_LOGIC;
		i_DV : IN STD_LOGIC;
		i_RxData : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

		i_DataReadyWE : IN STD_LOGIC;
		i_MPU_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

		o_RamWE : OUT STD_LOGIC;
		o_RamAddr : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		o_RamData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		o_ByteSel : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);

		o_RxHead : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END UART_RXDATA_BLOCK;

ARCHITECTURE arch OF UART_RXDATA_BLOCK IS

	--STATE MACHINES
	TYPE state IS (
		s_Idle,
		s_SetWE
	);
	SIGNAL r_State : state := s_Idle;

	--REGS
	SIGNAL r_RxHead : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0');

BEGIN

	PROCESS (i_Clk)
	BEGIN

		IF rising_edge(i_Clk) THEN

			CASE (r_State) IS
					------------------------------------------------
				WHEN s_Idle =>
					o_RamWE <= '0';

					--RX HEAD RESET
					IF (i_DataReadyWE = '1') THEN
						r_RxHead <= (others=>'0');
					END IF;
					
					--GOT NEW RX DATA
					IF (i_DV = '1') THEN
						o_RamAddr <= r_RxHead(10 DOWNTO 2);
						r_State <= s_SetWE;
					END IF;
					------------------------------------------------
				WHEN s_SetWE =>
					r_RxHead <= r_RxHead + 1;
					o_RamWE <= '1';
					r_State <= s_Idle;
					------------------------------------------------
				WHEN OTHERS => r_State <= s_Idle;
			END CASE;

			--PLACING RX DATA TO IT'S WORD'S PART  
			IF (r_State = s_Idle AND i_Dv = '1') THEN
				CASE (r_RxHead(1 DOWNTO 0)) IS
					WHEN "00" => o_ByteSel <= "0001";
						o_RamData(7 DOWNTO 0) <= i_RxData;
					WHEN "01" => o_ByteSel <= "0010";
						o_RamData(15 DOWNTO 8) <= i_RxData;
					WHEN "10" => o_ByteSel <= "0100";
						o_RamData(23 DOWNTO 16) <= i_RxData;
					WHEN "11" => o_ByteSel <= "1000";
						o_RamData(31 DOWNTO 24) <= i_RxData;
					WHEN OTHERS => NULL;
				END CASE;
			END IF;

		END IF;

	END PROCESS;

	o_RxHead <= (31 downto 11 => '0') & r_RxHead;
	
		--ADD PARITY BIT (CHECKSUM) FOR RX_HEAD
--	o_RxHead <=
--	(r_RxHead(10) xor r_RxHead(9) xor r_RxHead(8) xor r_RxHead(7) xor r_RxHead(6) xor r_RxHead(5) xor r_RxHead(4) xor r_RxHead(3) xor r_RxHead(2) xor r_RxHead(1) xor r_RxHead(0)) &
--	"000" &
--	x"000" & ("00000" & r_RxHead);

END arch;