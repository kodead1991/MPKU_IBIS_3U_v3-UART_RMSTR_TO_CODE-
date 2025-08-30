library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package uart_package is

    -- DPRAM_2k memory block
    component DPRAM_2k
        port (
            byteena_a : in  std_logic_vector(3 downto 0); 
            data      : in  std_logic_vector(31 downto 0);
            wraddress : in  std_logic_vector(8 downto 0);
            wren      : in  std_logic;
            rdaddress : in  std_logic_vector(8 downto 0);
            rden      : in  std_logic;
            inclock   : in  std_logic;
            outclock  : in  std_logic;
            q         : out std_logic_vector(31 downto 0)
        );
    end component;

    -- TX DATA PREPARATION BLOCK FOR UART_TX
    component UART_TXDATA_BLOCK
        port (
            i_Clk			: in std_logic;
            i_TxStart		: in std_logic;
            i_TxHead		: in std_logic_vector(10 downto 0);
            i_RamData		: in std_logic_vector(31 downto 0);
            i_DriverReady	: in std_logic;
            i_TxTail_WE		: in std_logic;
            i_TxTail_Data	: in std_logic_vector(31 downto 0);
            i_Reset			: in std_logic;
            o_RamRE			: out std_logic;
            o_RamAddr		: out std_logic_vector(8 downto 0);
            o_DV			: out std_logic;
            o_TxData		: out std_logic_vector(7 downto 0);
            o_TxEn			: out std_logic;
            o_TxTail		: out std_logic_vector(31 downto 0)
        );
    end component;

    -- RX DATA PREPARATION BLOCK FOR MEMORY WRITE
    component UART_RXDATA_BLOCK
        generic (
            g_RAM_ADDR_WIDTH  : integer := 11    -- RX byte address width
        );
        port (
            i_Clk			: in std_logic;
            i_DV			: in std_logic;
            i_RxData		: in std_logic_vector(7 downto 0);
            i_RxHead_WE		: in std_logic;
            i_RxHead_Data	: in std_logic_vector(31 downto 0);
            o_Ram_WE		: out std_logic;
            o_Ram_Addr		: out std_logic_vector(8 downto 0);
            o_Ram_Data		: out std_logic_vector(31 downto 0);
            o_Ram_ByteSel	: out std_logic_vector(3 downto 0);
            o_RxHead_Data	: out std_logic_vector(31 downto 0)
        );
    end component;

    -- TX DATA OUTPUT BLOCK BY UART PROTOCOL
    component UART_TX_BLOCK
        generic (
            g_CLKS_PER_BIT	: integer := 18;
            g_BIT_NUM		: integer := 15
        );
        port (
            i_Clk			: in  std_logic;
            i_TxDV			: in  std_logic;
            i_Data			: in  std_logic_vector(7 downto 0);
            o_Tx			: out std_logic;
            --o_TX_Active		: out std_logic;
            o_Ready			: out std_logic
        );
    end component;

    -- RX DATA INPUT BLOCK BY UART PROTOCOL
    component UART_RX_BLOCK
        generic (
            g_CLKS_PER_BIT	: integer := 18
        );
        port (
            i_Clk			: in  std_logic;
            i_Reset			: in  std_logic;
            i_Rx			: in  std_logic;
            o_RxDV			: out std_logic;
            o_RxData		: out std_logic_vector(7 downto 0);
            o_Breakline		: out std_logic;
            o_Test			: out std_logic_vector(7 downto 0)
        );
    end component;

    -- ADDRESS ENABLE BLOCK
    component ADDR_EN_BLOCK
        generic (
            g_BASE_ADDR			: std_logic_vector(15 downto 0)
        );
        port (
            i_Addr				: in  std_logic_vector(15 downto 0);
            o_En 				: in  std_logic
        );
    end component;

    -- TRI-STATE BUFFER BLOCK
    component TRI31_1
        port (
            data				: in  std_logic_vector(31 downto 0);
            enabledt 			: in  std_logic;
            tridata				: inout std_logic_vector(31 downto 0)
        );
    end component;

    -- UART MODULE CONTROL REGISTER BLOCK
    component UART_CTRL_BLOCK
        port (
            i_Clk				: in  std_logic;
            i_We				: in  std_logic;
            i_Data				: in  std_logic_vector(31 downto 0);
            o_Mode				: out std_logic;
            o_Reset				: out std_logic;
            o_Channel			: out std_logic;
            o_TxStart			: out std_logic;
            o_Data				: out std_logic_vector(31 downto 0)
        );
    end component;

end package;