LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY FREQ_1kHz_BLOCK IS

	PORT (
		i_Clk : IN STD_LOGIC;
		o_kHz : OUT STD_LOGIC := '0'
	);
END FREQ_1kHz_BLOCK;

ARCHITECTURE arch OF FREQ_1kHz_BLOCK IS

	--CONSTANTS
	CONSTANT c_Div : INTEGER := 25000;

	--REGS
	SIGNAL r_Cnt : INTEGER RANGE 0 TO c_Div - 1 := 0;

BEGIN

	PROCESS (i_Clk)
	BEGIN

		IF rising_edge(i_Clk) THEN
			IF (r_Cnt = c_Div - 1) THEN
				r_Cnt <= 0;
				o_kHz <= '1';
			ELSE
				r_Cnt <= r_Cnt + 1;
				o_kHz <= '0';
			END IF;
		END IF;

	END PROCESS;

END arch;