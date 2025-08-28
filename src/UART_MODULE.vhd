library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_MODULE is
<<<<<<< Updated upstream
	generic (
        g_CLKS_PER_BIT	: integer := 18; -- ������⢮ �����⮢ ⠪⮢�� ����� ����� ������ ��� UART
        g_TX_BIT_NUM	: integer := 15 -- ������⢮ ��� � ���뫪� TX
    );
=======
>>>>>>> Stashed changes
	Port (
		-- =====================
		-- �室�� ᨣ����
		-- =====================
		MHz				: in  STD_LOGIC;						-- ������ ⠪⮢�� ����
		MPU_WE			: in  STD_LOGIC;						-- ������ ����� MPU (� ���⮬ CS, ��⨢�� �஢��� - 1)
		MPU_RE			: in  STD_LOGIC;						-- ������ �⥭�� MPU (� ���⮬ CS, ��⨢�� �஢��� - 1)
		UART_ADDR_EN	: in  STD_LOGIC;						-- ������ ���饭�� � ����� UART �� MPU
		MPU_ADDR		: in  STD_LOGIC_VECTOR(15 downto 0);	-- ���� ���� MPU
		nBYTE_SEL		: in  STD_LOGIC_VECTOR(3 downto 0);		-- ���� �롮� ���� MPU
		DATA_FROM_MPU	: in  STD_LOGIC_VECTOR(31 downto 0);	-- ���� ������ MPU �� ������
		BASE_ADDR		: in  STD_LOGIC_VECTOR(15 downto 0);	-- ���६��� ��砫� ������ ����� ��� 設� ����
		RO_OSN			: in  STD_LOGIC;						-- ����� �� RS-485 (�᭮����)
		RO_REZ			: in  STD_LOGIC;						-- ����� �� RS-485 (१�ࢭ��)

		-- =====================
		-- ��室�� ᨣ����
		-- =====================
		DATA_TO_MPU		: out STD_LOGIC_VECTOR(31 downto 0);	-- ���� ������ MPU �� �⥭��
		DI_OSN			: out STD_LOGIC;						-- ����� �� RS-485 (�᭮����)
		DI_REZ			: out STD_LOGIC;						-- ����� �� RS-485 (१�ࢭ��)
		NRE				: out STD_LOGIC;						-- ����襭�� �뤠� RS-485
		TEST			: out STD_LOGIC_VECTOR(31 downto 0)		-- �⫠���� ���⠪��
	);
end UART_MODULE;

architecture Behavioral of UART_MODULE is

    -- =========================================================================
    -- ���������� ������� � ���������
    -- =========================================================================
	constant c_BASE_UART0 : unsigned(22 DOWNTO 0) := to_unsigned(16#0000#, 23);	-- ��砫� ������ ����� UART0 ��� 設� ����
    constant c_BASE_UART1 : unsigned(22 DOWNTO 0) := to_unsigned(16#2000#, 23);	-- ��砫� ������ ����� UART1 ��� 設� ����
    constant c_BASE_UART2 : unsigned(22 DOWNTO 0) := to_unsigned(16#4000#, 23);	-- ��砫� ������ ����� UART2 ��� 設� ����
    constant c_BASE_UART3 : unsigned(22 DOWNTO 0) := to_unsigned(16#6000#, 23);	-- ��砫� ������ ����� UART3 ��� 設� ����
    constant c_BASE_UART4 : unsigned(22 DOWNTO 0) := to_unsigned(16#8000#, 23);	-- ��砫� ������ ����� UART4 ��� 設� ����
    constant c_BASE_UART5 : unsigned(22 DOWNTO 0) := to_unsigned(16#A000#, 23);	-- ��砫� ������ ����� UART5 ��� 設� ����

    constant c_RXDATA : unsigned(15 DOWNTO 0) := to_unsigned(16#0000#, 16);	-- ���६��� ������ RX_DATA ��� 設� ����
    constant c_TXDATA : unsigned(15 DOWNTO 0) := to_unsigned(16#0800#, 16);	-- ���६��� ������ TX_DATA ��� 設� ����
    constant c_RXTAIL : unsigned(15 DOWNTO 0) := to_unsigned(16#1000#, 16);	-- ���६��� ������ ॣ���� RX_TAIL ��� 設� ����
    constant c_RXHEAD : unsigned(15 DOWNTO 0) := to_unsigned(16#1004#, 16);	-- ���६��� ������ ॣ���� RX_HEAD ��� 設� ����
    constant c_TXTAIL : unsigned(15 DOWNTO 0) := to_unsigned(16#1008#, 16);	-- ���६��� ������ ॣ���� TX_TAIL ��� 設� ����
    constant c_TXHEAD : unsigned(15 DOWNTO 0) := to_unsigned(16#100C#, 16);	-- ���६��� ������ ॣ���� TX_HEAD ��� 設� ����
    constant c_CTRL   : unsigned(15 DOWNTO 0) := to_unsigned(16#1020#, 16);	-- ���६��� ������ ॣ���� CTRL ��� 設� ����

	signal r_CLK				: STD_LOGIC;						-- ���⮢�� ����

	signal r_DATA_FROM_MPU		: STD_LOGIC_VECTOR(31 downto 0);	-- ����� �� MPU
	signal r_UART_DATA_EN		: STD_LOGIC;						-- 䫠� ᮢ������� ����� ��� 設� ���� � ��砫�� ������ UART

	signal r_TX_RAM_RE			: STD_LOGIC;						-- ������ �⥭�� ������ TX �� ����� �����
	signal r_TX_RAM_RE_ADDR		: STD_LOGIC_VECTOR(8 downto 0);		-- 設� ���� �⥭�� ������ TX �� ����� �����
	signal r_TX_RAM_RE_DATA		: STD_LOGIC_VECTOR(31 downto 0);	-- 設� ������ TX ����� ����� (��� �⥭��)
	signal r_TX_DV				: STD_LOGIC;						-- ᨣ��� ��⮢���� ������ TX ��� �뤠� �१ UART_BLOCK
	signal r_TX_DATA			: STD_LOGIC_VECTOR(8 downto 0);		-- 設� ������ TX ��� �뤠� �१ UART_BLOCK		
	
	signal r_TX_HEAD_DATA		: STD_LOGIC_VECTOR(31 downto 0);	-- 㪠��⥫� ���孥� �࠭��� ������ TX � ����� �����
	signal r_TX_TAIL_DATA		: STD_LOGIC_VECTOR(31 downto 0);	-- 㪠��⥫� ���孥� �࠭��� ������ TX � ����� �����
	signal r_RX_HEAD_DATA		: STD_LOGIC_VECTOR(31 downto 0);	-- 㪠��⥫� ���孥� �࠭��� ������ TX � ����� �����

	signal r_CTRL_ADDR_EN		: STD_LOGIC;						-- ᨣ��� ���饭�� MPU �� ����� ॣ���� CTRL
	signal r_TX_HEAD_ADDR_EN	: STD_LOGIC;						-- ᨣ��� ���饭�� MPU �� ����� 㪠��⥫� TX_HEAD
	signal r_TX_TAIL_ADDR_EN	: STD_LOGIC;						-- ᨣ��� ���饭�� MPU �� ����� 㪠��⥫� TX_TAIL
	signal r_RX_HEAD_ADDR_EN	: STD_LOGIC;						-- ᨣ��� ���饭�� MPU �� ����� 㪠��⥫� RX_HEAD

	signal r_DI					: STD_LOGIC;						-- ��室��� ᨣ��� UART TX
	signal r_NRE				: STD_LOGIC;						-- ࠧ�襭�� �뤠� ᨣ���� UART TX
	signal r_DRIVER_READY		: STD_LOGIC;						-- ��⮢����� ����� UART_TX

	signal r_RX_DV				: STD_LOGIC;						-- ᨣ��� ��⮢���� �ਭ���� ������ RX ��� ����� � ���� �����
	signal r_RX_DATA			: STD_LOGIC_VECTOR(7 downto 0);		-- 設� �ਭ���� ������ RX ��� ����� � ���� �����

	signal r_RX_RAM_WE			: STD_LOGIC;						-- c����� ����� ������ RX � ���� �����
	signal r_RX_RAM_WE_ADDR		: STD_LOGIC_VECTOR(8 downto 0);		-- 設� ���� ����� ������ RX � ���� �����
	signal r_RX_RAM_WE_DATA		: STD_LOGIC_VECTOR(31 downto 0);	-- 設� ������ RX ����� ����� (��� �����)
	signal r_RX_RAM_BYTE_SEL	: STD_LOGIC_VECTOR(3 downto 0);		-- 設� �롮� ���� ��� ����� �� 設� ������ RX
	
	signal r_RX_RAM_RE_DATA		: STD_LOGIC_VECTOR(31 downto 0);	-- 設� ������ RX ����� ����� (��� �⥭��)
	
	signal r_MODE				: STD_LOGIC;						-- c����� ���ﭨ� ०��� ����� (1-���/0-����)
	signal r_RESET				: STD_LOGIC;						-- c����� ��� ����� (1-���/0-����)
	signal r_CHANNEL			: STD_LOGIC;						-- c����� �롮� ����� UART (1-���/0-���)
	signal r_TX_START			: STD_LOGIC;						-- ᨣ��� ��砫� �뤠� ������ TX �१ UART_BLOCK
	signal r_CTRL_DATA			: STD_LOGIC_VECTOR(31 downto 0);	-- 設� ������ ॣ���� CTRL
    
    -- =========================================================================
    -- ����������
    -- =========================================================================
    
    -- ���� ����� DPRAM_2k
    component DPRAM_2k
        Port (
            byteena_a : in  STD_LOGIC_VECTOR(3 DOWNTO 0); 
            data      : in  STD_LOGIC_VECTOR(31 downto 0);
            wraddress : in  STD_LOGIC_VECTOR(8 downto 0);
            wren      : in  STD_LOGIC;
            rdaddress : in  STD_LOGIC_VECTOR(8 downto 0);
            rden      : in  STD_LOGIC;
            inclock   : in  STD_LOGIC;
            outclock  : in  STD_LOGIC;
            q         : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
	-- ���� ���������� ������ TX ��� ����� UART_TX
	component UART_TXDATA_BLOCK
		Port (
			i_Clk			: in STD_LOGIC;
			i_TxStart		: in STD_LOGIC;
			i_TxHead		: in STD_LOGIC_VECTOR(10 downto 0);
			i_RamData		: in STD_LOGIC_VECTOR(31 downto 0);
			i_DriverReady	: in STD_LOGIC;
			i_TxTail_WE		: in STD_LOGIC;
			i_TxTail_Data	: in STD_LOGIC_VECTOR(31 downto 0);
			i_Reset			: in STD_LOGIC;
			o_RamRE			: out STD_LOGIC;
			o_RamAddr		: out STD_LOGIC_VECTOR(8 downto 0);
			o_DV			: out STD_LOGIC;
			o_TxData		: out STD_LOGIC_VECTOR(7 downto 0);
			o_TxEn			: out STD_LOGIC;
			o_TxTail		: out STD_LOGIC_VECTOR(31 downto 0)
		);
	end component;

    -- ���� ���������� ������ RX ��� ������ � ���� ������
    component UART_RXDATA_BLOCK
		Port (
			i_Clk			: in STD_LOGIC;
			i_DV			: in STD_LOGIC;
			i_RxData		: in STD_LOGIC_VECTOR(7 downto 0);
			i_RxHead_WE		: in STD_LOGIC;
			i_RxHead_Data	: in STD_LOGIC_VECTOR(31 downto 0);
			o_Ram_WE		: out STD_LOGIC;
			o_Ram_Addr		: out STD_LOGIC_VECTOR(8 downto 0);
			o_Ram_Data		: out STD_LOGIC_VECTOR(8 downto 0);
			o_Ram_ByteSel	: out STD_LOGIC_VECTOR(8 downto 0);
			o_RxHead_Data	: out STD_LOGIC_VECTOR(31 downto 0)
		);
	end component;

    -- ���� ������ ������ TX �� ��������� UART
	component UART_TX_BLOCK
<<<<<<< Updated upstream
		generic (
			g_CLKS_PER_BIT	: integer := g_CLKS_PER_BIT;	-- ������⢮ �����⮢ ⠪⮢�� ����� ����� ������ ��� UART
			g_BIT_NUM		: integer := g_TX_BIT_NUM		-- ������⢮ ��� � ���뫪�
		);
=======
>>>>>>> Stashed changes
		Port (
			i_Clk			: in  STD_LOGIC;
			i_TxDV			: in  STD_LOGIC;
			i_Data			: in  STD_LOGIC_VECTOR(7 downto 0);
<<<<<<< Updated upstream
			o_Tx			: out STD_LOGIC;
			--o_TX_Active		: out STD_LOGIC;			-- �� �ᯮ������
=======
			o_TX			: out STD_LOGIC;
			o_TX_Active		: out STD_LOGIC;
>>>>>>> Stashed changes
			o_Ready			: out STD_LOGIC
		);
	end component;

	-- ���� ������ ������ RX �� ��������� UART
	component UART_RX_BLOCK
<<<<<<< Updated upstream
		generic (
			g_CLKS_PER_BIT	: integer := g_CLKS_PER_BIT		-- ������⢮ �����⮢ ⠪⮢�� ����� ����� ������ ��� UART
		);
=======
>>>>>>> Stashed changes
		Port (
			i_Clk			: in  STD_LOGIC;
			i_Reset			: in  STD_LOGIC;
			i_Rx			: in  STD_LOGIC;
			o_RxDV			: out STD_LOGIC;
			o_RxData		: out STD_LOGIC_VECTOR(7 downto 0);
			o_Breakline		: out STD_LOGIC;
			o_Test			: out STD_LOGIC_VECTOR(7 downto 0)
		);
	end component;

	-- ���� ���������� ������� �� ������
	component ADDR_EN_BLOCK
		Generic (
			g_BASE_ADDR			: STD_LOGIC_VECTOR(15 downto 0)
		);
		Port (
			i_Addr				: in  STD_LOGIC_VECTOR(15 downto 0);
			o_En 				: in  STD_LOGIC
		);
	end component;

	-- ���� �����A � ������� ����������
	component TRI31_1
		Port (
			data				: in  STD_LOGIC_VECTOR(31 downto 0);
			enabledt 			: in  STD_LOGIC;
			tridata				: inout STD_LOGIC_VECTOR(31 downto 0)
		);
	end component;

	-- ���� �������� ���������� ������� UART
	component UART_CTRL_BLOCK
		Port (
			i_Clk				: in  STD_LOGIC;
			i_We				: in  STD_LOGIC;
			i_Data				: in  STD_LOGIC_VECTOR(31 downto 0);
			o_Mode				: out STD_LOGIC;
			o_Reset				: out STD_LOGIC;
			o_Channel			: out STD_LOGIC;
			o_TxStart			: out STD_LOGIC;
			o_Data				: out STD_LOGIC_VECTOR(31 downto 0)
		);
	end component;

begin

	-- =========================================================================
	-- ���������� ���������� ��������
	-- =========================================================================
    r_CLK <= MHz;
	r_UART_DATA_EN <= '1' when (MPU_ADDR(15 downto 12) = BASE_ADDR(15 downto 12)) else '0';	-- 䫠� ���饭�� MPU � ������� RX_DATA (0x0000) � TX_DATA (0x0800)
	
	DI_OSN <= r_DI or r_CHANNEL;
	DI_REZ <= r_DI or not r_CHANNEL;
	-- =========================================================================
	-- ���� �����A � ������� ����������
	-- =========================================================================
	CTRL_TRI : TRI31_1
		port map (
			data		=> r_CTRL_DATA,
			enabledt 	=> MPU_RE and r_CTRL_ADDR_EN,
			tridata		=> DATA_TO_MPU
		);
		
	TXHEAD_TRI : TRI31_1
		port map (
			data		=> r_TX_HEAD_DATA,
			enabledt 	=> MPU_RE and r_TX_HEAD_ADDR_EN,
			tridata		=> DATA_TO_MPU
		);
	
	TXTAIL_TRI : TRI31_1
		port map (
			data		=> r_TX_TAIL_DATA,
			enabledt 	=> MPU_RE and r_TX_TAIL_ADDR_EN,
			tridata		=> DATA_TO_MPU
		);

	RXHEAD_TRI : TRI31_1
		port map (
			data		=> r_RX_HEAD_DATA,
			enabledt 	=> MPU_RE and r_RX_HEAD_ADDR_EN,
			tridata		=> DATA_TO_MPU
		);
	
	RXDATA_TRI : TRI31_1
		port map (
			data		=> r_RX_DATA,
			enabledt 	=> MPU_RE and r_UART_DATA_EN AND NOT MPU_ADDR(11),	--䫠� ���饭�� MPU � ������ RX_DATA
			tridata		=> DATA_TO_MPU
		);
	
	-- =========================================================================
	-- ���� ���������� ������� �� ������
	-- =========================================================================
	CTRL_ADDR_EN : ADDR_EN_BLOCK
		generic map (
			g_BASE_ADDR => STD_LOGIC_VECTOR(unsigned(BASE_ADDR) + c_CTRL)
		)
		port map (
			i_Addr	=> MPU_ADDR,
			o_En	=> r_CTRL_ADDR_EN
		);
	TX_HEAD_ADDR_EN : ADDR_EN_BLOCK
		generic map (
			g_BASE_ADDR => STD_LOGIC_VECTOR(unsigned(BASE_ADDR) + c_TXHEAD)
		)
		port map (
			i_Addr	=> MPU_ADDR,
			o_En	=> r_TX_HEAD_ADDR_EN
		);

	TX_TAIL_ADDR_EN : ADDR_EN_BLOCK
		generic map (
			g_BASE_ADDR => STD_LOGIC_VECTOR(unsigned(BASE_ADDR) + c_TXTAIL)
		)
		port map (
			i_Addr	=> MPU_ADDR,
			o_En	=> r_TX_TAIL_ADDR_EN
		);
    
	RX_HEAD_ADDR_EN : ADDR_EN_BLOCK
		generic map (
			g_BASE_ADDR => STD_LOGIC_VECTOR(unsigned(BASE_ADDR) + c_RXHEAD)
		)
		port map (
			i_Addr	=> MPU_ADDR,
			o_En	=> r_RX_HEAD_ADDR_EN
		);
	-- =========================================================================
    -- ���� �������� ���������� ������� UART
    -- =========================================================================
	UART_CTRL_BLOCK_INST : UART_CTRL_BLOCK
		port map (
			i_Clk		=> MHz,
			i_We		=> MPU_WE and r_CTRL_ADDR_EN,
			i_Data		=> DATA_FROM_MPU,
			o_Mode		=> r_MODE,
			o_Reset		=> r_RESET,
			o_Channel	=> r_CHANNEL,
			o_TxStart	=> r_TX_START,
			o_Data		=> r_CTRL_DATA
		);
    
	-- =========================================================================
	-- ���� ������ DPRAM_2k ��� �࠭���� ������ TX
	-- =========================================================================
	DPRAM_TX_DATA : DPRAM_2k
		port map (
			byteena_a	=> nBYTE_SEL,
			data		=> DATA_FROM_MPU,
			wraddress	=> MPU_ADDR(8 downto 0),
			wren		=> MPU_WE and r_UART_DATA_EN and not MPU_ADDR(10) and MPU_ADDR(9), -- ���饭�� � ������ TX_DATA
			rdaddress	=> r_TX_RAM_RE_ADDR,
			rden		=> r_TX_RAM_RE,
			inclock		=> not MHz,        -- �����᭠� ⠪⮢�� ����
			outclock	=> not MHz,        -- �����᭠� ⠪⮢�� ����
			q			=> r_TX_RAM_RE_DATA
		);
    
	-- =========================================================================
	-- ���� ���������� ������ TX ��� ����� UART_TX
	-- =========================================================================
	UART_TXDATA_BLOCK_INST : UART_TXDATA_BLOCK
		port map (
			i_Clk			=> MHz,
			i_TxStart		=> r_TX_START,
			i_TxHead		=> r_TX_HEAD_DATA(10 downto 0),
			i_RamData		=> r_TX_RAM_RE_DATA,
			i_DriverReady	=> r_DRIVER_READY,
			i_TxTail_WE		=> MPU_WE and r_TX_TAIL_ADDR_EN,
			i_TxTail_Data	=> DATA_FROM_MPU,
			i_Reset			=> r_RESET,
			o_RamRE			=> r_TX_RAM_RE,
			o_RamAddr		=> r_TX_RAM_RE_ADDR,
			o_DV			=> r_TX_DV,
			o_TxData		=> r_TX_DATA,
			o_TxEn			=> r_NRE,
			o_TxTail		=> r_TX_TAIL_DATA
		);

    -- =========================================================================
    -- ���� ������ ������ TX �� ��������� UART
    -- =========================================================================
	UART_TX_BLOCK_INST : UART_TX_BLOCK
		port map (
			i_Clk			=> MHz,
			i_TxDV			=> r_TX_DV,
			i_Data			=> r_TX_DATA,
<<<<<<< Updated upstream
			o_Tx			=> r_DI,
			--o_Tx_Active		=> open,
=======
			o_TX			=> r_DI,
			o_TX_Active		=> open,
>>>>>>> Stashed changes
			o_Ready			=> r_DRIVER_READY
		);
	
    -- =========================================================================
    -- ���� ������ ������ RX �� ��������� UART
    -- =========================================================================
	UART_RX_BLOCK_INST : UART_RX_BLOCK
		port map (
			i_Clk			=> MHz and r_MODE,
			i_Reset			=> r_RESET,
			i_Rx			=> (RO_OSN or r_CHANNEL) and (RO_REZ or not r_CHANNEL), -- � ���⮬ �롮� ������
			o_RxDV			=> r_RX_DV,
			o_RxData		=> r_RX_DATA,
			o_Breakline		=> open, -- �� �ᯮ������
			o_Test			=> open  -- �� �ᯮ������
		);
	
	-- =========================================================================
	-- ���� ���������� ������ RX ��� ������ � ���� ������
	-- =========================================================================
	UART_RXDATA_BLOCK_INST : UART_RXDATA_BLOCK
		port map (
			i_Clk			=> MHz,
			i_DV 			=> r_RX_DV,
			i_RxData 		=> r_RX_DATA,
			i_RxHead_WE 	=> MPU_WE and r_RX_HEAD_ADDR_EN,
			i_RxHead_Data 	=> r_DATA_FROM_MPU,
			o_Ram_WE 		=> r_RX_RAM_WE,
			o_Ram_Addr 		=> r_RX_RAM_WE_ADDR,
			o_Ram_Data 		=> r_RX_RAM_WE_DATA,
			o_Ram_ByteSel 	=> r_RX_RAM_BYTE_SEL,
			o_RxHead_Data 	=> r_RX_HEAD_DATA
		);

	-- =========================================================================
	-- ���� ������ DPRAM_2k ��� �࠭���� ������ RX
	-- =========================================================================
	DPRAM_RX_DATA : DPRAM_2k
		port map (
			byteena_a	=> r_RX_RAM_BYTE_SEL,
			data		=> r_RX_RAM_WE_DATA,
			wraddress	=> r_RX_RAM_WE_ADDR,
			wren		=> r_RX_RAM_WE,
			rdaddress	=> MPU_ADDR(10 downto 2),
			rden		=> MPU_RE and r_UART_DATA_EN AND NOT MPU_ADDR(11),	--䫠� ���饭�� MPU � ������ RX_DATA
			inclock		=> not MHz,        -- �����᭠� ⠪⮢�� ����
			outclock	=> not MHz,        -- �����᭠� ⠪⮢�� ����
			q			=> r_RX_RAM_RE_DATA
		);

end Behavioral;