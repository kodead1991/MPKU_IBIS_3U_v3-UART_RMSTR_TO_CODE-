library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
USE IEEE.numeric_std.all;

	-- Add your library and packages declaration here ...

entity pku_in_block_tb is
end pku_in_block_tb;

architecture TB_ARCHITECTURE of pku_in_block_tb is
	-- Component declaration of the tested unit
	component pku_in_block
	port(
		i_Clk : in STD_LOGIC;
		i_kHz : in STD_LOGIC;
		i_PKU : in STD_LOGIC;
		i_Rst : in STD_LOGIC;
		o_En : out STD_LOGIC;
		o_PkLen : out STD_LOGIC_VECTOR(9 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal i_Clk : STD_LOGIC;
	signal i_kHz : STD_LOGIC;
	signal i_PKU : STD_LOGIC;
	signal i_Rst : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal o_En : STD_LOGIC;
	signal o_PkLen : STD_LOGIC_VECTOR(9 downto 0);	 
	
	-- Add your code here ... 
		-- constants   
	CONSTANT CLK_period 	: time := 40 ns; 	--25 MHz	
	CONSTANT MHz_period 	: time := 1 us; --921'600 Baud	
	CONSTANT kHz_period		: time := 1 ms; --115'200 Baud

begin

	-- Unit Under Test port map
	UUT : pku_in_block
		port map (
			i_Clk => i_Clk,
			i_kHz => i_kHz,
			i_PKU => i_PKU,
			i_Rst => i_Rst,
			o_En => o_En,
			o_PkLen => o_PkLen
		);

	-- Add your stimulus here ...
	CLK1_proc : PROCESS
	BEGIN 
		i_Clk <= '0';
		WAIT FOR CLK_period/2;
		i_Clk <= '1';
		WAIT FOR CLK_period/2;
	end process;  

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_pku_in_block of pku_in_block_tb is
	for TB_ARCHITECTURE
		for UUT : pku_in_block
			use entity work.pku_in_block(arch);
		end for;
	end for;
end TESTBENCH_FOR_pku_in_block;

