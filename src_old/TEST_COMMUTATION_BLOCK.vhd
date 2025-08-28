LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY TEST_COMMUTATION_BLOCK IS

    PORT (
        i_Clk : IN STD_LOGIC;
        i_WE : IN STD_LOGIC;
        i_RE : IN STD_LOGIC;
        i_ADDR : IN STD_LOGIC_VECTOR(22 DOWNTO 0);
        i_DATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        o_TEST : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS=>'0')
    );
END TEST_COMMUTATION_BLOCK;

ARCHITECTURE arch OF TEST_COMMUTATION_BLOCK IS

	SIGNAL r_REG : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS=>'0');
	SIGNAL r_cnt : STD_LOGIC_VECTOR(12 DOWNTO 0) := (OTHERS=>'0');

BEGIN

	process(i_Clk)
	begin
	
		if rising_edge(i_Clk) then
			if (i_WE = '1') then
				r_REG <= "000000000" & i_ADDR;
			end if;
			
			if (i_RE = '1') then
				o_TEST <= r_REG;
			else
				o_TEST <= (others=>'0');
			end if;
		end if;
	
	end process;

	
--    o_TEST(12) <= i_WE;
--    o_TEST(11) <= i_RE;
--    
--    o_TEST(10) <= 	
--					i_ADDR(22) and 
--					not i_ADDR(21) and 
--					not i_ADDR(20) and 
--					not i_ADDR(19) and 
--					not i_ADDR(18) and 
--					not i_ADDR(17) and 
--					not i_ADDR(16) and 
--					not i_ADDR(15) and 
--					not i_ADDR(14) and 
--					not i_ADDR(13) and
--					not i_ADDR(12) and 
--					not i_ADDR(11) and 
--					not i_ADDR(10) and 
--					not i_ADDR(9) and
--					not i_ADDR(8) and 
--					not i_ADDR(7) and 
--					not i_ADDR(6) and 
--					not i_ADDR(5) and 
--					not i_ADDR(4) and 
--					not i_ADDR(3) and 
--					not i_ADDR(2);
--	
--	o_TEST(9) <= i_DATA(7);
--	o_TEST(8) <= i_DATA(6);
--	o_TEST(7) <= i_DATA(5);
--	o_TEST(6) <= i_DATA(4);
--	o_TEST(5) <= i_DATA(3);
--	o_TEST(4) <= i_DATA(2);
--	o_TEST(3) <= i_DATA(1);
--	o_TEST(2) <= i_DATA(0);

--	process(i_Clk)
--	begin
--	
--		if rising_edge(i_Clk) then
--			r_cnt <= r_cnt + 1;
--		end if;
--	
--	end process;
--	
--	o_TEST <= r_cnt;

END arch;