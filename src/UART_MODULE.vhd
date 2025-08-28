library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_MODULE is
<<<<<<< Updated upstream
	generic (
        g_CLKS_PER_BIT	: integer := 18; -- Количество отсчётов тактовой частоты внутри одного бита UART
        g_TX_BIT_NUM	: integer := 15 -- Количество бит в посылке TX
    );
=======
>>>>>>> Stashed changes
	Port (
		-- =====================
		-- Входные сигналы
		-- =====================
		MHz				: in  STD_LOGIC;						-- Внешняя тактовая частота
		MPU_WE			: in  STD_LOGIC;						-- Сигнал записи MPU (с учётом CS, активный уровень - 1)
		MPU_RE			: in  STD_LOGIC;						-- Сигнал чтения MPU (с учётом CS, активный уровень - 1)
		UART_ADDR_EN	: in  STD_LOGIC;						-- Сигнал обращения к модулям UART от MPU
		MPU_ADDR		: in  STD_LOGIC_VECTOR(15 downto 0);	-- Шина адреса MPU
		nBYTE_SEL		: in  STD_LOGIC_VECTOR(3 downto 0);		-- Шина выбора байта MPU
		DATA_FROM_MPU	: in  STD_LOGIC_VECTOR(31 downto 0);	-- Шина данных MPU на запись
		BASE_ADDR		: in  STD_LOGIC_VECTOR(15 downto 0);	-- Инкремент начала области модуля для шины адреса
		RO_OSN			: in  STD_LOGIC;						-- Данные от RS-485 (основная)
		RO_REZ			: in  STD_LOGIC;						-- Данные от RS-485 (резервная)

		-- =====================
		-- Выходные сигналы
		-- =====================
		DATA_TO_MPU		: out STD_LOGIC_VECTOR(31 downto 0);	-- Шина данных MPU на чтение
		DI_OSN			: out STD_LOGIC;						-- Данные на RS-485 (основная)
		DI_REZ			: out STD_LOGIC;						-- Данные на RS-485 (резервная)
		NRE				: out STD_LOGIC;						-- Разрешение выдачи RS-485
		TEST			: out STD_LOGIC_VECTOR(31 downto 0)		-- Отладочные контакты
	);
end UART_MODULE;

architecture Behavioral of UART_MODULE is

    -- =========================================================================
    -- ВНУТРЕННИЕ СИГНАЛЫ И КОНСТАНТЫ
    -- =========================================================================
	constant c_BASE_UART0 : unsigned(22 DOWNTO 0) := to_unsigned(16#0000#, 23);	-- начало области модуля UART0 для шины адреса
    constant c_BASE_UART1 : unsigned(22 DOWNTO 0) := to_unsigned(16#2000#, 23);	-- начало области модуля UART1 для шины адреса
    constant c_BASE_UART2 : unsigned(22 DOWNTO 0) := to_unsigned(16#4000#, 23);	-- начало области модуля UART2 для шины адреса
    constant c_BASE_UART3 : unsigned(22 DOWNTO 0) := to_unsigned(16#6000#, 23);	-- начало области модуля UART3 для шины адреса
    constant c_BASE_UART4 : unsigned(22 DOWNTO 0) := to_unsigned(16#8000#, 23);	-- начало области модуля UART4 для шины адреса
    constant c_BASE_UART5 : unsigned(22 DOWNTO 0) := to_unsigned(16#A000#, 23);	-- начало области модуля UART5 для шины адреса

    constant c_RXDATA : unsigned(15 DOWNTO 0) := to_unsigned(16#0000#, 16);	-- инкремент области RX_DATA для шины адреса
    constant c_TXDATA : unsigned(15 DOWNTO 0) := to_unsigned(16#0800#, 16);	-- инкремент области TX_DATA для шины адреса
    constant c_RXTAIL : unsigned(15 DOWNTO 0) := to_unsigned(16#1000#, 16);	-- инкремент области регистра RX_TAIL для шины адреса
    constant c_RXHEAD : unsigned(15 DOWNTO 0) := to_unsigned(16#1004#, 16);	-- инкремент области регистра RX_HEAD для шины адреса
    constant c_TXTAIL : unsigned(15 DOWNTO 0) := to_unsigned(16#1008#, 16);	-- инкремент области регистра TX_TAIL для шины адреса
    constant c_TXHEAD : unsigned(15 DOWNTO 0) := to_unsigned(16#100C#, 16);	-- инкремент области регистра TX_HEAD для шины адреса
    constant c_CTRL   : unsigned(15 DOWNTO 0) := to_unsigned(16#1020#, 16);	-- инкремент области регистра CTRL для шины адреса

	signal r_CLK				: STD_LOGIC;						-- Тактовая частота

	signal r_DATA_FROM_MPU		: STD_LOGIC_VECTOR(31 downto 0);	-- Данные от MPU
	signal r_UART_DATA_EN		: STD_LOGIC;						-- флаг совпадения старших бит шины адреса с началом области UART

	signal r_TX_RAM_RE			: STD_LOGIC;						-- Сигнал чтения данных TX из блока памяти
	signal r_TX_RAM_RE_ADDR		: STD_LOGIC_VECTOR(8 downto 0);		-- шина адреса чтения данных TX из блока памяти
	signal r_TX_RAM_RE_DATA		: STD_LOGIC_VECTOR(31 downto 0);	-- шина данных TX блока памяти (для чтения)
	signal r_TX_DV				: STD_LOGIC;						-- сигнал готовности данных TX для выдачи через UART_BLOCK
	signal r_TX_DATA			: STD_LOGIC_VECTOR(8 downto 0);		-- шина данных TX для выдачи через UART_BLOCK		
	
	signal r_TX_HEAD_DATA		: STD_LOGIC_VECTOR(31 downto 0);	-- указатель верхней границы данных TX в блоке памяти
	signal r_TX_TAIL_DATA		: STD_LOGIC_VECTOR(31 downto 0);	-- указатель верхней границы данных TX в блоке памяти
	signal r_RX_HEAD_DATA		: STD_LOGIC_VECTOR(31 downto 0);	-- указатель верхней границы данных TX в блоке памяти

	signal r_CTRL_ADDR_EN		: STD_LOGIC;						-- сигнал обращения MPU по адресу регистра CTRL
	signal r_TX_HEAD_ADDR_EN	: STD_LOGIC;						-- сигнал обращения MPU по адресу указателя TX_HEAD
	signal r_TX_TAIL_ADDR_EN	: STD_LOGIC;						-- сигнал обращения MPU по адресу указателя TX_TAIL
	signal r_RX_HEAD_ADDR_EN	: STD_LOGIC;						-- сигнал обращения MPU по адресу указателя RX_HEAD

	signal r_DI					: STD_LOGIC;						-- выходной сигнал UART TX
	signal r_NRE				: STD_LOGIC;						-- разрешение выдачи сигнала UART TX
	signal r_DRIVER_READY		: STD_LOGIC;						-- готовность блока UART_TX

	signal r_RX_DV				: STD_LOGIC;						-- сигнал готовности принятых данных RX для записи в блок памяти
	signal r_RX_DATA			: STD_LOGIC_VECTOR(7 downto 0);		-- шина принятых данных RX для записи в блок памяти

	signal r_RX_RAM_WE			: STD_LOGIC;						-- cигнал записи данных RX в блок памяти
	signal r_RX_RAM_WE_ADDR		: STD_LOGIC_VECTOR(8 downto 0);		-- шина адреса записи данных RX в блок памяти
	signal r_RX_RAM_WE_DATA		: STD_LOGIC_VECTOR(31 downto 0);	-- шина данных RX блока памяти (для записи)
	signal r_RX_RAM_BYTE_SEL	: STD_LOGIC_VECTOR(3 downto 0);		-- шина выбора байта для записи по шине данных RX
	
	signal r_RX_RAM_RE_DATA		: STD_LOGIC_VECTOR(31 downto 0);	-- шина данных RX блока памяти (для чтения)
	
	signal r_MODE				: STD_LOGIC;						-- cигнал состояния режима модуля (1-ВКЛ/0-ВЫКЛ)
	signal r_RESET				: STD_LOGIC;						-- cигнал сброса модуля (1-ВКЛ/0-ВЫКЛ)
	signal r_CHANNEL			: STD_LOGIC;						-- cигнал выбора линии UART (1-РЕЗ/0-ОСН)
	signal r_TX_START			: STD_LOGIC;						-- сигнал начала выдачи данных TX через UART_BLOCK
	signal r_CTRL_DATA			: STD_LOGIC_VECTOR(31 downto 0);	-- шина данных регистра CTRL
    
    -- =========================================================================
    -- КОМПОНЕНТЫ
    -- =========================================================================
    
    -- Блок памяти DPRAM_2k
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
    
	-- БЛОК ПОДГОТОВКИ ДАННЫХ TX ДЛЯ БЛОКА UART_TX
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

    -- БЛОК ПОДГОТОВКИ ДАННЫХ RX ДЛЯ ЗАПИСИ В БЛОК ПАМЯТИ
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

    -- БЛОК ВЫДАЧИ ДАННЫХ TX ПО ПРОТОКОЛУ UART
	component UART_TX_BLOCK
<<<<<<< Updated upstream
		generic (
			g_CLKS_PER_BIT	: integer := g_CLKS_PER_BIT;	-- Количество отсчётов тактовой частоты внутри одного бита UART
			g_BIT_NUM		: integer := g_TX_BIT_NUM		-- Количество бит в посылке
		);
=======
>>>>>>> Stashed changes
		Port (
			i_Clk			: in  STD_LOGIC;
			i_TxDV			: in  STD_LOGIC;
			i_Data			: in  STD_LOGIC_VECTOR(7 downto 0);
<<<<<<< Updated upstream
			o_Tx			: out STD_LOGIC;
			--o_TX_Active		: out STD_LOGIC;			-- не используется
=======
			o_TX			: out STD_LOGIC;
			o_TX_Active		: out STD_LOGIC;
>>>>>>> Stashed changes
			o_Ready			: out STD_LOGIC
		);
	end component;

	-- БЛОК ПРИЁМА ДАННЫХ RX ПО ПРОТОКОЛУ UART
	component UART_RX_BLOCK
<<<<<<< Updated upstream
		generic (
			g_CLKS_PER_BIT	: integer := g_CLKS_PER_BIT		-- Количество отсчётов тактовой частоты внутри одного бита UART
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

	-- БЛОК РАЗРЕШЕНИЯ ДОСТУПА ПО АДРЕСУ
	component ADDR_EN_BLOCK
		Generic (
			g_BASE_ADDR			: STD_LOGIC_VECTOR(15 downto 0)
		);
		Port (
			i_Addr				: in  STD_LOGIC_VECTOR(15 downto 0);
			o_En 				: in  STD_LOGIC
		);
	end component;

	-- БЛОК БУФЕРA С ТРЕТЬИМ СОСТОЯНИЕМ
	component TRI31_1
		Port (
			data				: in  STD_LOGIC_VECTOR(31 downto 0);
			enabledt 			: in  STD_LOGIC;
			tridata				: inout STD_LOGIC_VECTOR(31 downto 0)
		);
	end component;

	-- БЛОК РЕГИСТРА УПРАВЛЕНИЯ МОДУЛЕМ UART
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
	-- ПРИСВОЕНИЕ ВНУТРЕННИХ СИГНАЛОВ
	-- =========================================================================
    r_CLK <= MHz;
	r_UART_DATA_EN <= '1' when (MPU_ADDR(15 downto 12) = BASE_ADDR(15 downto 12)) else '0';	-- флаг обращения MPU к областям RX_DATA (0x0000) и TX_DATA (0x0800)
	
	DI_OSN <= r_DI or r_CHANNEL;
	DI_REZ <= r_DI or not r_CHANNEL;
	-- =========================================================================
	-- БЛОК БУФЕРA С ТРЕТЬИМ СОСТОЯНИЕМ
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
			enabledt 	=> MPU_RE and r_UART_DATA_EN AND NOT MPU_ADDR(11),	--флаг обращения MPU к области RX_DATA
			tridata		=> DATA_TO_MPU
		);
	
	-- =========================================================================
	-- БЛОК РАЗРЕШЕНИЯ ДОСТУПА ПО АДРЕСУ
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
    -- БЛОК РЕГИСТРА УПРАВЛЕНИЯ МОДУЛЕМ UART
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
	-- БЛОК ПАМЯТИ DPRAM_2k для хранения данных TX
	-- =========================================================================
	DPRAM_TX_DATA : DPRAM_2k
		port map (
			byteena_a	=> nBYTE_SEL,
			data		=> DATA_FROM_MPU,
			wraddress	=> MPU_ADDR(8 downto 0),
			wren		=> MPU_WE and r_UART_DATA_EN and not MPU_ADDR(10) and MPU_ADDR(9), -- обращение к области TX_DATA
			rdaddress	=> r_TX_RAM_RE_ADDR,
			rden		=> r_TX_RAM_RE,
			inclock		=> not MHz,        -- Инверсная тактовая частота
			outclock	=> not MHz,        -- Инверсная тактовая частота
			q			=> r_TX_RAM_RE_DATA
		);
    
	-- =========================================================================
	-- БЛОК ПОДГОТОВКИ ДАННЫХ TX ДЛЯ БЛОКА UART_TX
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
    -- БЛОК ВЫДАЧИ ДАННЫХ TX ПО ПРОТОКОЛУ UART
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
    -- БЛОК ПРИЁМА ДАННЫХ RX ПО ПРОТОКОЛУ UART
    -- =========================================================================
	UART_RX_BLOCK_INST : UART_RX_BLOCK
		port map (
			i_Clk			=> MHz and r_MODE,
			i_Reset			=> r_RESET,
			i_Rx			=> (RO_OSN or r_CHANNEL) and (RO_REZ or not r_CHANNEL), -- с учётом выбора канала
			o_RxDV			=> r_RX_DV,
			o_RxData		=> r_RX_DATA,
			o_Breakline		=> open, -- не используется
			o_Test			=> open  -- не используется
		);
	
	-- =========================================================================
	-- БЛОК ПОДГОТОВКИ ДАННЫХ RX ДЛЯ ЗАПИСИ В БЛОК ПАМЯТИ
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
	-- БЛОК ПАМЯТИ DPRAM_2k для хранения данных RX
	-- =========================================================================
	DPRAM_RX_DATA : DPRAM_2k
		port map (
			byteena_a	=> r_RX_RAM_BYTE_SEL,
			data		=> r_RX_RAM_WE_DATA,
			wraddress	=> r_RX_RAM_WE_ADDR,
			wren		=> r_RX_RAM_WE,
			rdaddress	=> MPU_ADDR(10 downto 2),
			rden		=> MPU_RE and r_UART_DATA_EN AND NOT MPU_ADDR(11),	--флаг обращения MPU к области RX_DATA
			inclock		=> not MHz,        -- Инверсная тактовая частота
			outclock	=> not MHz,        -- Инверсная тактовая частота
			q			=> r_RX_RAM_RE_DATA
		);

end Behavioral;