library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
USE IEEE.numeric_std.all;

	-- Add your library and packages declaration here ...

entity top_tb is
end top_tb;

architecture TB_ARCHITECTURE of top_tb is
	-- Component declaration of the tested unit
	component top
	port(
		A0 : in STD_LOGIC;
		A1 : in STD_LOGIC;
		A2 : in STD_LOGIC;
		A3 : in STD_LOGIC;
		A4 : in STD_LOGIC;
		A5 : in STD_LOGIC;
		A6 : in STD_LOGIC;
		A7 : in STD_LOGIC;
		A8 : in STD_LOGIC;
		A9 : in STD_LOGIC;
		A10 : in STD_LOGIC;
		A11 : in STD_LOGIC;
		A12 : in STD_LOGIC;
		A13 : in STD_LOGIC;
		A14 : in STD_LOGIC;
		IO29 : in STD_LOGIC;
		IO30 : in STD_LOGIC;
		IO31 : in STD_LOGIC;
		IO32 : in STD_LOGIC;
		IO33 : in STD_LOGIC;
		IO34 : in STD_LOGIC;
		IO35 : in STD_LOGIC;
		IO36 : in STD_LOGIC;
		IO37 : in STD_LOGIC;
		IO38 : in STD_LOGIC;
		IO39 : in STD_LOGIC;
		IO40 : in STD_LOGIC;
		IO41 : in STD_LOGIC;
		IO42 : in STD_LOGIC;
		IO43 : in STD_LOGIC;
		IO44 : in STD_LOGIC;
		IO45 : in STD_LOGIC;
		IO46 : in STD_LOGIC;
		IO47 : in STD_LOGIC;
		IO48 : in STD_LOGIC;
		IO49 : in STD_LOGIC;
		IO50 : in STD_LOGIC;
		IO53 : in STD_LOGIC;
		RO6 : in STD_LOGIC;
		CLK_1 : in STD_LOGIC;
		MOSI_1 : in STD_LOGIC;
		SS_1 : in STD_LOGIC;
		RO5 : in STD_LOGIC;
		RO1 : in STD_LOGIC;
		RO2 : in STD_LOGIC;
		RO3 : in STD_LOGIC;
		RO4 : in STD_LOGIC;
		RO9 : in STD_LOGIC;
		RO10 : in STD_LOGIC;
		S1 : in STD_LOGIC;
		S2 : in STD_LOGIC;
		A0_MARK_SEC : in STD_LOGIC;
		A1_MARK_SEC : in STD_LOGIC;
		MHz_36_864 : in STD_LOGIC;
		DEV_Cle : in STD_LOGIC;
		DEV_OE : in STD_LOGIC;
		RDY_An : in STD_LOGIC;
		MHz_18_432 : in STD_LOGIC;
		EXT_CLK : in STD_LOGIC;
		CLK_25MHz2 : in STD_LOGIC;
		WE_An : in STD_LOGIC;
		OE : in STD_LOGIC;
		CS3 : in STD_LOGIC;
		DQMBn0 : in STD_LOGIC;
		DQMBn1 : in STD_LOGIC;
		DQMBn2 : in STD_LOGIC;
		DQMBn3 : in STD_LOGIC;
		RO7 : in STD_LOGIC;
		RO8 : in STD_LOGIC;
		NRE5 : in STD_LOGIC;
		IO54 : in STD_LOGIC;
		IO27 : in STD_LOGIC;
		IO28 : in STD_LOGIC;
		D1 : in STD_LOGIC;
		D2 : in STD_LOGIC;
		D3 : in STD_LOGIC;
		D0 : in STD_LOGIC;
		D4 : in STD_LOGIC;
		D5 : in STD_LOGIC;
		D6 : in STD_LOGIC;
		D7 : in STD_LOGIC;
		D8 : in STD_LOGIC;
		D9 : in STD_LOGIC;
		D10 : in STD_LOGIC;
		D11 : in STD_LOGIC;
		D12 : in STD_LOGIC;
		D13 : in STD_LOGIC;
		D14 : in STD_LOGIC;
		D15 : in STD_LOGIC;
		D16 : in STD_LOGIC;
		D17 : in STD_LOGIC;
		D18 : in STD_LOGIC;
		D19 : in STD_LOGIC;
		D20 : in STD_LOGIC;
		D21 : in STD_LOGIC;
		D22 : in STD_LOGIC;
		D23 : in STD_LOGIC;
		D24 : in STD_LOGIC;
		D25 : in STD_LOGIC;
		D26 : in STD_LOGIC;
		D27 : in STD_LOGIC;
		D28 : in STD_LOGIC;
		D29 : in STD_LOGIC;
		D30 : in STD_LOGIC;
		D31 : in STD_LOGIC;
		SW_1_W_I : in STD_LOGIC;
		SW_2_W_I : in STD_LOGIC;
		DI6 : out STD_LOGIC;
		INT0 : out STD_LOGIC;
		INT1 : out STD_LOGIC;
		INT2 : out STD_LOGIC;
		INT3 : out STD_LOGIC;
		INT4 : out STD_LOGIC;
		INT5 : out STD_LOGIC;
		MISO_1 : out STD_LOGIC;
		IRQ_1 : out STD_LOGIC;
		ResetP : out STD_LOGIC;
		DI5 : out STD_LOGIC;
		DI1 : out STD_LOGIC;
		DI2 : out STD_LOGIC;
		NRE1 : out STD_LOGIC;
		DI3 : out STD_LOGIC;
		DI4 : out STD_LOGIC;
		NRE2 : out STD_LOGIC;
		DI9 : out STD_LOGIC;
		DI10 : out STD_LOGIC;
		NRE3 : out STD_LOGIC;
		GAP : out STD_LOGIC;
		GA0 : out STD_LOGIC;
		GA1 : out STD_LOGIC;
		GA2 : out STD_LOGIC;
		GA3 : out STD_LOGIC;
		GA4 : out STD_LOGIC;
		SM1P_OR_1WIRE_O : out STD_LOGIC;
		SM2P_OR_1WIRE_O : out STD_LOGIC;
		IO1 : out STD_LOGIC;
		IO2 : out STD_LOGIC;
		IO3 : out STD_LOGIC;
		IO4 : out STD_LOGIC;
		IO5 : out STD_LOGIC;
		IO6 : out STD_LOGIC;
		IO7 : out STD_LOGIC;
		IO8 : out STD_LOGIC;
		IO26 : out STD_LOGIC;
		DI7 : out STD_LOGIC;
		NRE4 : out STD_LOGIC;
		DI8 : out STD_LOGIC;
		IO25 : out STD_LOGIC;
		IO55 : out STD_LOGIC;
		IO56 : out STD_LOGIC;
		IO57 : out STD_LOGIC;
		IO58 : out STD_LOGIC;
		IO51 : out STD_LOGIC;
		IO52 : out STD_LOGIC;
		IO60 : out STD_LOGIC;
		IO59 : out STD_LOGIC;
		IO17 : out STD_LOGIC;
		IO18 : out STD_LOGIC;
		IO15 : out STD_LOGIC;
		IO16 : out STD_LOGIC;
		IO9 : out STD_LOGIC;
		IO10 : out STD_LOGIC;
		IO23 : out STD_LOGIC;
		IO24 : out STD_LOGIC;
		IO19 : out STD_LOGIC;
		IO20 : out STD_LOGIC;
		IO13 : out STD_LOGIC;
		IO14 : out STD_LOGIC;
		IO21 : out STD_LOGIC;
		IO22 : out STD_LOGIC;
		IO11 : out STD_LOGIC;
		IO12 : out STD_LOGIC;
		SW_1_W_O : out STD_LOGIC;
		SW_2_W_O : out STD_LOGIC );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal A0 : STD_LOGIC;
	signal A1 : STD_LOGIC;
	signal A2 : STD_LOGIC;
	signal A3 : STD_LOGIC;
	signal A4 : STD_LOGIC;
	signal A5 : STD_LOGIC;
	signal A6 : STD_LOGIC;
	signal A7 : STD_LOGIC;
	signal A8 : STD_LOGIC;
	signal A9 : STD_LOGIC;
	signal A10 : STD_LOGIC;
	signal A11 : STD_LOGIC;
	signal A12 : STD_LOGIC;
	signal A13 : STD_LOGIC;
	signal A14 : STD_LOGIC;
	signal IO29 : STD_LOGIC;
	signal IO30 : STD_LOGIC;
	signal IO31 : STD_LOGIC;
	signal IO32 : STD_LOGIC;
	signal IO33 : STD_LOGIC;
	signal IO34 : STD_LOGIC;
	signal IO35 : STD_LOGIC;
	signal IO36 : STD_LOGIC;
	signal IO37 : STD_LOGIC;
	signal IO38 : STD_LOGIC;
	signal IO39 : STD_LOGIC;
	signal IO40 : STD_LOGIC;
	signal IO41 : STD_LOGIC;
	signal IO42 : STD_LOGIC;
	signal IO43 : STD_LOGIC;
	signal IO44 : STD_LOGIC;
	signal IO45 : STD_LOGIC;
	signal IO46 : STD_LOGIC;
	signal IO47 : STD_LOGIC;
	signal IO48 : STD_LOGIC;
	signal IO49 : STD_LOGIC;
	signal IO50 : STD_LOGIC;
	signal IO53 : STD_LOGIC;
	signal RO6 : STD_LOGIC;
	signal CLK_1 : STD_LOGIC;
	signal MOSI_1 : STD_LOGIC;
	signal SS_1 : STD_LOGIC;
	signal RO5 : STD_LOGIC;
	signal RO1 : STD_LOGIC;
	signal RO2 : STD_LOGIC;
	signal RO3 : STD_LOGIC;
	signal RO4 : STD_LOGIC;
	signal RO9 : STD_LOGIC;
	signal RO10 : STD_LOGIC;
	signal S1 : STD_LOGIC;
	signal S2 : STD_LOGIC;
	signal A0_MARK_SEC : STD_LOGIC;
	signal A1_MARK_SEC : STD_LOGIC;
	signal MHz_36_864 : STD_LOGIC;
	signal DEV_Cle : STD_LOGIC;
	signal DEV_OE : STD_LOGIC;
	signal RDY_An : STD_LOGIC;
	signal MHz_18_432 : STD_LOGIC;
	signal EXT_CLK : STD_LOGIC;
	signal CLK_25MHz2 : STD_LOGIC;
	signal WE_An : STD_LOGIC;
	signal OE : STD_LOGIC;
	signal CS3 : STD_LOGIC;
	signal DQMBn0 : STD_LOGIC;
	signal DQMBn1 : STD_LOGIC;
	signal DQMBn2 : STD_LOGIC;
	signal DQMBn3 : STD_LOGIC;
	signal RO7 : STD_LOGIC;
	signal RO8 : STD_LOGIC;
	signal NRE5 : STD_LOGIC;
	signal IO54 : STD_LOGIC;
	signal IO27 : STD_LOGIC;
	signal IO28 : STD_LOGIC;
	signal D1 : STD_LOGIC;
	signal D2 : STD_LOGIC;
	signal D3 : STD_LOGIC;
	signal D0 : STD_LOGIC;
	signal D4 : STD_LOGIC;
	signal D5 : STD_LOGIC;
	signal D6 : STD_LOGIC;
	signal D7 : STD_LOGIC;
	signal D8 : STD_LOGIC;
	signal D9 : STD_LOGIC;
	signal D10 : STD_LOGIC;
	signal D11 : STD_LOGIC;
	signal D12 : STD_LOGIC;
	signal D13 : STD_LOGIC;
	signal D14 : STD_LOGIC;
	signal D15 : STD_LOGIC;
	signal D16 : STD_LOGIC;
	signal D17 : STD_LOGIC;
	signal D18 : STD_LOGIC;
	signal D19 : STD_LOGIC;
	signal D20 : STD_LOGIC;
	signal D21 : STD_LOGIC;
	signal D22 : STD_LOGIC;
	signal D23 : STD_LOGIC;
	signal D24 : STD_LOGIC;
	signal D25 : STD_LOGIC;
	signal D26 : STD_LOGIC;
	signal D27 : STD_LOGIC;
	signal D28 : STD_LOGIC;
	signal D29 : STD_LOGIC;
	signal D30 : STD_LOGIC;
	signal D31 : STD_LOGIC;
	signal SW_1_W_I : STD_LOGIC;
	signal SW_2_W_I : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal DI6 : STD_LOGIC;
	signal INT0 : STD_LOGIC;
	signal INT1 : STD_LOGIC;
	signal INT2 : STD_LOGIC;
	signal INT3 : STD_LOGIC;
	signal INT4 : STD_LOGIC;
	signal INT5 : STD_LOGIC;
	signal MISO_1 : STD_LOGIC;
	signal IRQ_1 : STD_LOGIC;
	signal ResetP : STD_LOGIC;
	signal DI5 : STD_LOGIC;
	signal DI1 : STD_LOGIC;
	signal DI2 : STD_LOGIC;
	signal NRE1 : STD_LOGIC;
	signal DI3 : STD_LOGIC;
	signal DI4 : STD_LOGIC;
	signal NRE2 : STD_LOGIC;
	signal DI9 : STD_LOGIC;
	signal DI10 : STD_LOGIC;
	signal NRE3 : STD_LOGIC;
	signal GAP : STD_LOGIC;
	signal GA0 : STD_LOGIC;
	signal GA1 : STD_LOGIC;
	signal GA2 : STD_LOGIC;
	signal GA3 : STD_LOGIC;
	signal GA4 : STD_LOGIC;
	signal SM1P_OR_1WIRE_O : STD_LOGIC;
	signal SM2P_OR_1WIRE_O : STD_LOGIC;
	signal IO1 : STD_LOGIC;
	signal IO2 : STD_LOGIC;
	signal IO3 : STD_LOGIC;
	signal IO4 : STD_LOGIC;
	signal IO5 : STD_LOGIC;
	signal IO6 : STD_LOGIC;
	signal IO7 : STD_LOGIC;
	signal IO8 : STD_LOGIC;
	signal IO26 : STD_LOGIC;
	signal DI7 : STD_LOGIC;
	signal NRE4 : STD_LOGIC;
	signal DI8 : STD_LOGIC;
	signal IO25 : STD_LOGIC;
	signal IO55 : STD_LOGIC;
	signal IO56 : STD_LOGIC;
	signal IO57 : STD_LOGIC;
	signal IO58 : STD_LOGIC;
	signal IO51 : STD_LOGIC;
	signal IO52 : STD_LOGIC;
	signal IO60 : STD_LOGIC;
	signal IO59 : STD_LOGIC;
	signal IO17 : STD_LOGIC;
	signal IO18 : STD_LOGIC;
	signal IO15 : STD_LOGIC;
	signal IO16 : STD_LOGIC;
	signal IO9 : STD_LOGIC;
	signal IO10 : STD_LOGIC;
	signal IO23 : STD_LOGIC;
	signal IO24 : STD_LOGIC;
	signal IO19 : STD_LOGIC;
	signal IO20 : STD_LOGIC;
	signal IO13 : STD_LOGIC;
	signal IO14 : STD_LOGIC;
	signal IO21 : STD_LOGIC;
	signal IO22 : STD_LOGIC;
	signal IO11 : STD_LOGIC;
	signal IO12 : STD_LOGIC;
	signal SW_1_W_O : STD_LOGIC;
	signal SW_2_W_O : STD_LOGIC;

	-- constants   
	CONSTANT CLK_period 	: time := 40 ns; 	--25 MHz	
	CONSTANT UART_period 	: time := 1.08506 us; --921'600 Baud	
	CONSTANT UART_period_115: time := 8.68055 us; --115'200 Baud	
	
	CONSTANT c_ADDR_U0_Base	: std_logic_vector(15 downto 0) := x"0000";
	CONSTANT c_ADDR_RxData	: std_logic_vector(15 downto 0) := x"0000";
	CONSTANT c_ADDR_TxData	: std_logic_vector(15 downto 0) := x"0200";	
	CONSTANT c_ADDR_TxHead	: std_logic_vector(15 downto 0) := x"0403";
	CONSTANT c_ADDR_TxTail	: std_logic_vector(15 downto 0) := x"0402";
	CONSTANT c_ADDR_Ctrl	: std_logic_vector(15 downto 0) := x"0408";
	CONSTANT c_ADDR_RxHead	: std_logic_vector(15 downto 0) := x"0401";	
	
	CONSTANT c_ADDR_PK_Base		: std_logic_vector(15 downto 0) := x"2800";
	CONSTANT c_ADDR_PK_List		: std_logic_vector(15 downto 0) := x"0018";	
	CONSTANT c_ADDR_Pk0_Len		: std_logic_vector(15 downto 0) := x"0000";
	CONSTANT c_ADDR_Pk1_Len		: std_logic_vector(15 downto 0) := x"0001";
	CONSTANT c_ADDR_Pk2_Len		: std_logic_vector(15 downto 0) := x"0002";
	CONSTANT c_ADDR_Pk3_Len		: std_logic_vector(15 downto 0) := x"0003";
	CONSTANT c_ADDR_Pk4_Len		: std_logic_vector(15 downto 0) := x"0004";
	CONSTANT c_ADDR_Pk5_Len		: std_logic_vector(15 downto 0) := x"0005";
	CONSTANT c_ADDR_Pk6_Len		: std_logic_vector(15 downto 0) := x"0006";
	CONSTANT c_ADDR_Pk7_Len		: std_logic_vector(15 downto 0) := x"0007";
	CONSTANT c_ADDR_Pk8_Len		: std_logic_vector(15 downto 0) := x"0008";
	CONSTANT c_ADDR_Pk9_Len		: std_logic_vector(15 downto 0) := x"0009";
	CONSTANT c_ADDR_Pk10_Len	: std_logic_vector(15 downto 0) := x"000A";
	CONSTANT c_ADDR_Pk11_Len	: std_logic_vector(15 downto 0) := x"000B";	
	
	CONSTANT c_ADDR_PKU_Base	: std_logic_vector(15 downto 0) := x"3000";	
	CONSTANT c_ADDR_PKU0		: std_logic_vector(15 downto 0) := x"0000";
	CONSTANT c_ADDR_PKU1		: std_logic_vector(15 downto 0) := x"0001";
	CONSTANT c_ADDR_PKU2		: std_logic_vector(15 downto 0) := x"0002";
	CONSTANT c_ADDR_PKU3		: std_logic_vector(15 downto 0) := x"0003";
	CONSTANT c_ADDR_PKU4		: std_logic_vector(15 downto 0) := x"0004";
	CONSTANT c_ADDR_PKU5		: std_logic_vector(15 downto 0) := x"0005";
	CONSTANT c_ADDR_PKU6		: std_logic_vector(15 downto 0) := x"0006";
	CONSTANT c_ADDR_PKU7		: std_logic_vector(15 downto 0) := x"0007";
	CONSTANT c_ADDR_PKU8		: std_logic_vector(15 downto 0) := x"0008";
	CONSTANT c_ADDR_PKU9		: std_logic_vector(15 downto 0) := x"0009";
	CONSTANT c_ADDR_PKU10		: std_logic_vector(15 downto 0) := x"000A";
	CONSTANT c_ADDR_PKU11		: std_logic_vector(15 downto 0) := x"000B";
	CONSTANT c_ADDR_PKU12		: std_logic_vector(15 downto 0) := x"000C";
	CONSTANT c_ADDR_PKU13		: std_logic_vector(15 downto 0) := x"000D";
	CONSTANT c_ADDR_PKU14		: std_logic_vector(15 downto 0) := x"000E";
	CONSTANT c_ADDR_PKU15		: std_logic_vector(15 downto 0) := x"000F";
	CONSTANT c_ADDR_PKU16		: std_logic_vector(15 downto 0) := x"0010";
	CONSTANT c_ADDR_PKU17		: std_logic_vector(15 downto 0) := x"0011";
	CONSTANT c_ADDR_PKU18		: std_logic_vector(15 downto 0) := x"0012";
	CONSTANT c_ADDR_PKU19		: std_logic_vector(15 downto 0) := x"0013";
	CONSTANT c_ADDR_PKU20		: std_logic_vector(15 downto 0) := x"0014";
	CONSTANT c_ADDR_PKU21		: std_logic_vector(15 downto 0) := x"0015";
	CONSTANT c_ADDR_PKU22		: std_logic_vector(15 downto 0) := x"0016";
	CONSTANT c_ADDR_PKU23		: std_logic_vector(15 downto 0) := x"0017";	  
	CONSTANT c_ADDR_PKU_LIST	: std_logic_vector(15 downto 0) := x"0018";
	
	CONSTANT c_ADDR_1WIRE_BASE	: std_logic_vector(15 downto 0) := x"3900";
	CONSTANT c_ADDR_1WIRE_NAME01: std_logic_vector(15 downto 0) := x"0000";
	CONSTANT c_ADDR_1WIRE_NAME02: std_logic_vector(15 downto 0) := x"0001";
	CONSTANT c_ADDR_1WIRE_NAME11: std_logic_vector(15 downto 0) := x"0002";
	CONSTANT c_ADDR_1WIRE_NAME12: std_logic_vector(15 downto 0) := x"0003";
	
	signal DATA : std_logic_vector(31 downto 0);
	signal ADDR : std_logic_vector(15 downto 0);
	
	signal NCS : std_logic;
	signal NWE : std_logic;
	signal NRE : std_logic;

begin

	-- Unit Under Test port map
	UUT : top
		port map (
			A0 => A0,
			A1 => A1,
			A2 => A2,
			A3 => A3,
			A4 => A4,
			A5 => A5,
			A6 => A6,
			A7 => A7,
			A8 => A8,
			A9 => A9,
			A10 => A10,
			A11 => A11,
			A12 => A12,
			A13 => A13,
			A14 => A14,
			IO29 => IO29,
			IO30 => IO30,
			IO31 => IO31,
			IO32 => IO32,
			IO33 => IO33,
			IO34 => IO34,
			IO35 => IO35,
			IO36 => IO36,
			IO37 => IO37,
			IO38 => IO38,
			IO39 => IO39,
			IO40 => IO40,
			IO41 => IO41,
			IO42 => IO42,
			IO43 => IO43,
			IO44 => IO44,
			IO45 => IO45,
			IO46 => IO46,
			IO47 => IO47,
			IO48 => IO48,
			IO49 => IO49,
			IO50 => IO50,
			IO53 => IO53,
			RO6 => RO6,
			CLK_1 => CLK_1,
			MOSI_1 => MOSI_1,
			SS_1 => SS_1,
			RO5 => RO5,
			RO1 => RO1,
			RO2 => RO2,
			RO3 => RO3,
			RO4 => RO4,
			RO9 => RO9,
			RO10 => RO10,
			S1 => S1,
			S2 => S2,
			A0_MARK_SEC => A0_MARK_SEC,
			A1_MARK_SEC => A1_MARK_SEC,
			MHz_36_864 => MHz_36_864,
			DEV_Cle => DEV_Cle,
			DEV_OE => DEV_OE,
			RDY_An => RDY_An,
			MHz_18_432 => MHz_18_432,
			EXT_CLK => EXT_CLK,
			CLK_25MHz2 => CLK_25MHz2,
			WE_An => WE_An,
			OE => OE,
			CS3 => CS3,
			DQMBn0 => DQMBn0,
			DQMBn1 => DQMBn1,
			DQMBn2 => DQMBn2,
			DQMBn3 => DQMBn3,
			RO7 => RO7,
			RO8 => RO8,
			NRE5 => NRE5,
			IO54 => IO54,
			IO27 => IO27,
			IO28 => IO28,
			D1 => D1,
			D2 => D2,
			D3 => D3,
			D0 => D0,
			D4 => D4,
			D5 => D5,
			D6 => D6,
			D7 => D7,
			D8 => D8,
			D9 => D9,
			D10 => D10,
			D11 => D11,
			D12 => D12,
			D13 => D13,
			D14 => D14,
			D15 => D15,
			D16 => D16,
			D17 => D17,
			D18 => D18,
			D19 => D19,
			D20 => D20,
			D21 => D21,
			D22 => D22,
			D23 => D23,
			D24 => D24,
			D25 => D25,
			D26 => D26,
			D27 => D27,
			D28 => D28,
			D29 => D29,
			D30 => D30,
			D31 => D31,
			SW_1_W_I => SW_1_W_I,
			SW_2_W_I => SW_2_W_I,
			DI6 => DI6,
			INT0 => INT0,
			INT1 => INT1,
			INT2 => INT2,
			INT3 => INT3,
			INT4 => INT4,
			INT5 => INT5,
			MISO_1 => MISO_1,
			IRQ_1 => IRQ_1,
			ResetP => ResetP,
			DI5 => DI5,
			DI1 => DI1,
			DI2 => DI2,
			NRE1 => NRE1,
			DI3 => DI3,
			DI4 => DI4,
			NRE2 => NRE2,
			DI9 => DI9,
			DI10 => DI10,
			NRE3 => NRE3,
			GAP => GAP,
			GA0 => GA0,
			GA1 => GA1,
			GA2 => GA2,
			GA3 => GA3,
			GA4 => GA4,
			SM1P_OR_1WIRE_O => SM1P_OR_1WIRE_O,
			SM2P_OR_1WIRE_O => SM2P_OR_1WIRE_O,
			IO1 => IO1,
			IO2 => IO2,
			IO3 => IO3,
			IO4 => IO4,
			IO5 => IO5,
			IO6 => IO6,
			IO7 => IO7,
			IO8 => IO8,
			IO26 => IO26,
			DI7 => DI7,
			NRE4 => NRE4,
			DI8 => DI8,
			IO25 => IO25,
			IO55 => IO55,
			IO56 => IO56,
			IO57 => IO57,
			IO58 => IO58,
			IO51 => IO51,
			IO52 => IO52,
			IO60 => IO60,
			IO59 => IO59,
			IO17 => IO17,
			IO18 => IO18,
			IO15 => IO15,
			IO16 => IO16,
			IO9 => IO9,
			IO10 => IO10,
			IO23 => IO23,
			IO24 => IO24,
			IO19 => IO19,
			IO20 => IO20,
			IO13 => IO13,
			IO14 => IO14,
			IO21 => IO21,
			IO22 => IO22,
			IO11 => IO11,
			IO12 => IO12,
			SW_1_W_O => SW_1_W_O,
			SW_2_W_O => SW_2_W_O
		);

	-- Add your stimulus here ...
	-- Add your stimulus here ... 
	CLK1_proc : PROCESS
	BEGIN 
		CLK_25MHz2 <= '0';
		WAIT FOR CLK_period/2;
		CLK_25MHz2 <= '1';
		WAIT FOR CLK_period/2;
	end process; 
	
	D0 <= DATA(0);	
	D1 <= DATA(1);
	D2 <= DATA(2);
	D3 <= DATA(3);
	D4 <= DATA(4);
	D5 <= DATA(5);
	D6 <= DATA(6);
	D7 <= DATA(7);
	D8 <= DATA(8);
	D9 <= DATA(9);
	D10 <= DATA(10);
	D11 <= DATA(11);
	D12 <= DATA(12);
	D13 <= DATA(13);
	D14 <= DATA(14);
	D15 <= DATA(15);
	D16 <= DATA(16);
	D17 <= DATA(17);
	D18 <= DATA(18);
	D19 <= DATA(19);
	D20 <= DATA(20);
	D21 <= DATA(21);
	D22 <= DATA(22);
	D23 <= DATA(23);
	D24 <= DATA(24);
	D25 <= DATA(25);
	D26 <= DATA(26);
	D27 <= DATA(27);
	D28 <= DATA(28);
	D29 <= DATA(29);
	D30 <= DATA(30);
	D31 <= DATA(31);
	
	A0 <= ADDR(0);
	A1 <= ADDR(1);
	A2 <= ADDR(2);
	A3 <= ADDR(3);
	A4 <= ADDR(4);
	A5 <= ADDR(5);
	A6 <= ADDR(6);
	A7 <= ADDR(7);
	A8 <= ADDR(8);
	A9 <= ADDR(9);
	A10 <= ADDR(10);
	A11 <= ADDR(11);
	A12 <= ADDR(12);
	A13 <= ADDR(13);
	A14 <= ADDR(14);
	
	CS3 <= NCS;
	WE_An <= NWE;
	OE <= NRE;	
	
	process		
	begin
		
		--START INIT
		ADDR <= x"0000";
		DATA <= x"00000000";
		NCS <= '1';	
		NWE <= '1';
		NRE <= '1';	
		DQMBn0 <= '1'; DQMBn1 <= '1'; DQMBn2 <= '1'; DQMBn3 <= '1';
		WAIT FOR 10 us;
		
		--1-WIRE NAME01 WRITE
		NCS <= '0';
		DATA <= x"01020304";
		ADDR <= c_ADDR_1WIRE_BASE + c_ADDR_1WIRE_NAME01;
		WAIT FOR 20 ns;	
		NWE <= '0';	  
		WAIT FOR 140 ns;
		NWE <= '1';	 
		WAIT FOR 20 ns;	  
		NCS <= '1';	
		
		WAIT FOR 10 us;
		
		--1-WIRE NAME02 WRITE
		NCS <= '0';
		DATA <= x"05060708";
		ADDR <= c_ADDR_1WIRE_BASE + c_ADDR_1WIRE_NAME02;
		WAIT FOR 20 ns;	
		NWE <= '0';	  
		WAIT FOR 140 ns;
		NWE <= '1';	 
		WAIT FOR 20 ns;	  
		NCS <= '1';	 
		
		WAIT FOR 10 us;
		
		--1-WIRE NAME01 READ
		NCS <= '0';
		ADDR <= c_ADDR_1WIRE_BASE + c_ADDR_1WIRE_NAME01;
		WAIT FOR 20 ns;	
		NRE <= '0';	  
		WAIT FOR 140 ns;
		NRE <= '1';	 
		WAIT FOR 20 ns;	  
		NCS <= '1';	
		
		WAIT FOR 10 us;
		
		--1-WIRE NAME02 READ
		NCS <= '0';
		ADDR <= c_ADDR_1WIRE_BASE + c_ADDR_1WIRE_NAME02;
		WAIT FOR 20 ns;	
		NRE <= '0';	  
		WAIT FOR 140 ns;
		NRE <= '1';	 
		WAIT FOR 20 ns;	  
		NCS <= '1';	 
		
		WAIT FOR 10 us;
		
		
		WAIT;-- FOR 1 ms;
		
		
	end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_top of top_tb is
	for TB_ARCHITECTURE
		for UUT : top
			use entity work.top(bdf_type);
		end for;
	end for;
end TESTBENCH_FOR_top;

