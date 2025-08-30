library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.uart_package.all;

entity UART_MODULE is
    generic (
        g_CLKS_PER_BIT	: integer := 18; -- Number of clock cycles per UART bit
        g_TX_BIT_NUM	: integer := 15 -- Number of bits in TX packet
    );
    port (
        -- =====================
        -- Input signals
        -- =====================
        MHz				: in  std_logic;						-- External clock frequency
        MPU_WE			: in  std_logic;						-- MPU write signal (with CS, active high)
        MPU_RE			: in  std_logic;						-- MPU read signal (with CS, active high)
        UART_ADDR_EN	: in  std_logic;						-- MPU access signal to UART modules
        MPU_ADDR		: in  std_logic_vector(15 downto 0);	-- MPU address bus
        nBYTE_SEL		: in  std_logic_vector(3 downto 0);		-- MPU byte select bus
        DATA_FROM_MPU	: in  std_logic_vector(31 downto 0);	-- MPU data bus for write
        BASE_ADDR		: in  std_logic_vector(15 downto 0);	-- Module base address increment for address bus
        RO_OSN			: in  std_logic;						-- Data from RS-485 (main)
        RO_REZ			: in  std_logic;						-- Data from RS-485 (reserve)

        -- =====================
        -- Output signals
        -- =====================
        DATA_TO_MPU		: out std_logic_vector(31 downto 0);	-- MPU data bus for read
        DI_OSN			: out std_logic;						-- Data to RS-485 (main)
        DI_REZ			: out std_logic;						-- Data to RS-485 (reserve)
        NRE				: out std_logic;						-- RS-485 output enable
        TEST			: out std_logic_vector(31 downto 0)		-- Debug pins
    );
end UART_MODULE;

architecture behavioral of UART_MODULE is

    -- =========================================================================
    -- INTERNAL SIGNALS AND CONSTANTS
    -- =========================================================================
    constant c_BASE_UART0 : unsigned(22 downto 0) := to_unsigned(16#0000#, 23);	-- UART0 module base address for address bus
    constant c_BASE_UART1 : unsigned(22 downto 0) := to_unsigned(16#2000#, 23);	-- UART1 module base address for address bus
    constant c_BASE_UART2 : unsigned(22 downto 0) := to_unsigned(16#4000#, 23);	-- UART2 module base address for address bus
    constant c_BASE_UART3 : unsigned(22 downto 0) := to_unsigned(16#6000#, 23);	-- UART3 module base address for address bus
    constant c_BASE_UART4 : unsigned(22 downto 0) := to_unsigned(16#8000#, 23);	-- UART4 module base address for address bus
    constant c_BASE_UART5 : unsigned(22 downto 0) := to_unsigned(16#A000#, 23);	-- UART5 module base address for address bus

    constant c_RXDATA : unsigned(15 downto 0) := to_unsigned(16#0000#, 16);	-- RX_DATA area increment for address bus
    constant c_TXDATA : unsigned(15 downto 0) := to_unsigned(16#0800#, 16);	-- TX_DATA area increment for address bus
    constant c_RXTAIL : unsigned(15 downto 0) := to_unsigned(16#1000#, 16);	-- RX_TAIL register area increment for address bus
    constant c_RXHEAD : unsigned(15 downto 0) := to_unsigned(16#1004#, 16);	-- RX_HEAD register area increment for address bus
    constant c_TXTAIL : unsigned(15 downto 0) := to_unsigned(16#1008#, 16);	-- TX_TAIL register area increment for address bus
    constant c_TXHEAD : unsigned(15 downto 0) := to_unsigned(16#100C#, 16);	-- TX_HEAD register area increment for address bus
    constant c_CTRL   : unsigned(15 downto 0) := to_unsigned(16#1020#, 16);	-- CTRL register area increment for address bus

    signal r_CLK				: std_logic;						-- Clock frequency

    signal r_DATA_FROM_MPU		: std_logic_vector(31 downto 0);	-- Data from MPU
    signal r_UART_DATA_EN		: std_logic;						-- Flag for address bus upper bits match with UART area start

    signal r_TX_RAM_RE			: std_logic;						-- TX data read signal from memory block
    signal r_TX_RAM_RE_ADDR		: std_logic_vector(8 downto 0);		-- TX data read address bus from memory block
    signal r_TX_RAM_RE_DATA		: std_logic_vector(31 downto 0);	-- TX memory block data bus (for read)
    signal r_TX_DV				: std_logic;						-- TX data ready signal for UART_BLOCK output
    signal r_TX_DATA			: std_logic_vector(8 downto 0);		-- TX data bus for UART_BLOCK output
    
    signal r_TX_HEAD_DATA		: std_logic_vector(31 downto 0);	-- TX data upper boundary pointer in memory block
    signal r_TX_TAIL_DATA		: std_logic_vector(31 downto 0);	-- TX data upper boundary pointer in memory block
    signal r_RX_HEAD_DATA		: std_logic_vector(31 downto 0);	-- RX data upper boundary pointer in memory block

    signal r_CTRL_ADDR_EN		: std_logic;						-- MPU access signal to CTRL register address
    signal r_TX_HEAD_ADDR_EN	: std_logic;						-- MPU access signal to TX_HEAD pointer address
    signal r_TX_TAIL_ADDR_EN	: std_logic;						-- MPU access signal to TX_TAIL pointer address
    signal r_RX_HEAD_ADDR_EN	: std_logic;						-- MPU access signal to RX_HEAD pointer address

    signal r_DI					: std_logic;						-- UART TX output signal
    signal r_NRE				: std_logic;						-- UART TX output enable signal
    signal r_DRIVER_READY		: std_logic;						-- UART_TX block ready

    signal r_RX_DV				: std_logic;						-- RX received data ready signal for memory write
    signal r_RX_DATA			: std_logic_vector(7 downto 0);		-- RX received data bus for memory write

    signal r_RX_RAM_WE			: std_logic;						-- RX data write signal to memory block
    signal r_RX_RAM_WE_ADDR		: std_logic_vector(8 downto 0);		-- RX data write address bus to memory block
    signal r_RX_RAM_WE_DATA		: std_logic_vector(31 downto 0);	-- RX memory block data bus (for write)
    signal r_RX_RAM_BYTE_SEL	: std_logic_vector(3 downto 0);		-- RX data byte select bus for memory write
    
    signal r_RX_RAM_RE_DATA		: std_logic_vector(31 downto 0);	-- RX memory block data bus (for read)
    
    signal r_MODE				: std_logic;						-- Module mode state signal (1-ON/0-OFF)
    signal r_RESET				: std_logic;						-- Module reset signal (1-ON/0-OFF)
    signal r_CHANNEL			: std_logic;						-- UART line select signal (1-RES/0-MAIN)
    signal r_TX_START			: std_logic;						-- TX data start signal for UART_BLOCK output
    signal r_CTRL_DATA			: std_logic_vector(31 downto 0);	-- CTRL register data bus
    

begin

    -- =========================================================================
    -- INTERNAL SIGNAL ASSIGNMENTS
    -- =========================================================================
    r_CLK <= MHz;
    r_DATA_FROM_MPU <= DATA_FROM_MPU;
    r_UART_DATA_EN <= '1' when (MPU_ADDR(15 downto 12) = BASE_ADDR(15 downto 12)) else '0';	-- MPU access flag to RX_DATA (0x0000) and TX_DATA (0x0800) areas
    
    DI_OSN <= r_DI or r_CHANNEL;
    DI_REZ <= r_DI or not r_CHANNEL;

    -- =========================================================================
    -- TRI-STATE BUFFER BLOCK
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
            enabledt 	=> MPU_RE and r_UART_DATA_EN and not MPU_ADDR(11),	-- MPU access flag to RX_DATA area
            tridata		=> DATA_TO_MPU
        );
    
    -- =========================================================================
    -- ADDRESS ENABLE BLOCK
    -- =========================================================================
    CTRL_ADDR_EN : ADDR_EN_BLOCK
        generic map (
            g_BASE_ADDR => std_logic_vector(unsigned(BASE_ADDR) + c_CTRL)
        )
        port map (
            i_Addr	=> MPU_ADDR,
            o_En	=> r_CTRL_ADDR_EN
        );
    TX_HEAD_ADDR_EN : ADDR_EN_BLOCK
        generic map (
            g_BASE_ADDR => std_logic_vector(unsigned(BASE_ADDR) + c_TXHEAD)
        )
        port map (
            i_Addr	=> MPU_ADDR,
            o_En	=> r_TX_HEAD_ADDR_EN
        );

    TX_TAIL_ADDR_EN : ADDR_EN_BLOCK
        generic map (
            g_BASE_ADDR => std_logic_vector(unsigned(BASE_ADDR) + c_TXTAIL)
        )
        port map (
            i_Addr	=> MPU_ADDR,
            o_En	=> r_TX_TAIL_ADDR_EN
        );
    
    RX_HEAD_ADDR_EN : ADDR_EN_BLOCK
        generic map (
            g_BASE_ADDR => std_logic_vector(unsigned(BASE_ADDR) + c_RXHEAD)
        )
        port map (
            i_Addr	=> MPU_ADDR,
            o_En	=> r_RX_HEAD_ADDR_EN
        );
    -- =========================================================================
    -- UART MODULE CONTROL REGISTER BLOCK
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
    -- DPRAM_2k MEMORY BLOCK FOR TX DATA STORAGE
    -- =========================================================================
    DPRAM_TX_DATA : DPRAM_2k
        port map (
            byteena_a	=> nBYTE_SEL,
            data		=> DATA_FROM_MPU,
            wraddress	=> MPU_ADDR(8 downto 0),
            wren		=> MPU_WE and r_UART_DATA_EN and not MPU_ADDR(10) and MPU_ADDR(9), -- access to TX_DATA area
            rdaddress	=> r_TX_RAM_RE_ADDR,
            rden		=> r_TX_RAM_RE,
            inclock		=> not MHz,        -- Inverted clock frequency
            outclock	=> not MHz,        -- Inverted clock frequency
            q			=> r_TX_RAM_RE_DATA
        );
    
    -- =========================================================================
    -- TX DATA PREPARATION BLOCK FOR UART_TX
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
    -- TX DATA OUTPUT BLOCK BY UART PROTOCOL
    -- =========================================================================
    UART_TX_BLOCK_INST : UART_TX_BLOCK
        generic map (
            g_CLKS_PER_BIT	=> g_CLKS_PER_BIT,
            g_BIT_NUM		=> g_TX_BIT_NUM
        )
        port map (
            i_Clk			=> MHz,
            i_TxDV			=> r_TX_DV,
            i_Data			=> r_TX_DATA,
            o_Tx			=> r_DI,
            --o_Tx_Active		=> open,
            o_Ready			=> r_DRIVER_READY
        );
    
    -- =========================================================================
    -- RX DATA INPUT BLOCK BY UART PROTOCOL
    -- =========================================================================
    UART_RX_BLOCK_INST : UART_RX_BLOCK
        generic map (
            g_CLKS_PER_BIT	=> g_CLKS_PER_BIT
        )
        port map (
            i_Clk			=> MHz and r_MODE,
            i_Reset			=> r_RESET,
            i_Rx			=> (RO_OSN or r_CHANNEL) and (RO_REZ or not r_CHANNEL), -- considering channel selection
            o_RxDV			=> r_RX_DV,
            o_RxData		=> r_RX_DATA,
            o_Breakline		=> open, -- not used
            o_Test			=> open  -- not used
        );
    
    -- =========================================================================
    -- RX DATA PREPARATION BLOCK FOR MEMORY WRITE
    -- =========================================================================
    UART_RXDATA_BLOCK_INST : UART_RXDATA_BLOCK
        generic map (
            g_RAM_ADDR_WIDTH => 11    -- RX byte address width
        )
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
    -- DPRAM_2k MEMORY BLOCK FOR RX DATA STORAGE
    -- =========================================================================
    DPRAM_RX_DATA : DPRAM_2k
        port map (
            byteena_a	=> r_RX_RAM_BYTE_SEL,
            data		=> r_RX_RAM_WE_DATA,
            wraddress	=> r_RX_RAM_WE_ADDR,
            wren		=> r_RX_RAM_WE,
            rdaddress	=> MPU_ADDR(10 downto 2),
            rden		=> MPU_RE and r_UART_DATA_EN and not MPU_ADDR(11),	-- MPU access flag to RX_DATA area
            inclock		=> not MHz,        -- Inverted clock frequency
            outclock	=> not MHz,        -- Inverted clock frequency
            q			=> r_RX_RAM_RE_DATA
        );

end behavioral;