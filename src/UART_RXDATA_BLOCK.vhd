library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_RXDATA_BLOCK is
    generic (
        g_RAM_ADDR_WIDTH  : integer := 11    -- RX byte address width
    );
    port (
        i_Clk           : in  std_logic;                                 -- Clock signal
        i_DV            : in  std_logic;                                 -- RX DATA valid flag
        i_RxData        : in  std_logic_vector(7 downto 0);              -- RX DATA byte
        i_RxHead_WE     : in  std_logic;                                 -- RX HEAD pointer write enable
        i_RxHead_Data   : in  std_logic_vector(31 downto 0);             -- RX HEAD pointer value (from MPU)
        o_Ram_WE        : out std_logic;                                 -- RX RAM write enable
        o_Ram_Addr      : out std_logic_vector(g_RAM_ADDR_WIDTH-3 downto 0);   -- RX RAM write address
        o_Ram_Data      : out std_logic_vector(31 downto 0);             -- RX RAM write data
        o_Ram_nByteSel  : out std_logic_vector(3 downto 0);              -- RX RAM byte select
        o_RxHead_Data   : out std_logic_vector(31 downto 0)              -- RX HEAD pointer value (to MPU)
    );
end UART_RXDATA_BLOCK;

architecture behavioral of UART_RXDATA_BLOCK is

    -- State machine for RX RAM write process
    type state is (
        s_Idle,     -- Waiting for new RX data
        s_SetWE     -- Set RAM write enable
    );
    signal r_State       : state := s_Idle;

    -- RX head pointer register
    signal r_RxHead_Data : std_logic_vector(g_RAM_ADDR_WIDTH-1 downto 0) := (others => '0');

    signal r_Ram_WE       : std_logic := '0';
    signal r_Ram_Addr     : std_logic_vector(g_RAM_ADDR_WIDTH-3 downto 0) := (others => '0');
    signal r_Ram_nByteSel : std_logic_vector(3 downto 0)                := (others => '0');
    signal r_Ram_Data     : std_logic_vector(31 downto 0)               := (others => '0');

begin
    process (i_Clk)
    begin
        if rising_edge(i_Clk) then

            -- RX head pointer reset
            if (i_RxHead_WE = '1') then
                r_RxHead_Data <= (others=>'0');
                r_Ram_nByteSel <= (others=>'0');
                r_Ram_Data <= (others=>'0');
            end if;

            case (r_State) is
                ------------------------------------------------
                when s_Idle =>
                    r_Ram_WE <= '0';     -- end of RX RAM write

                    -- New RX data received
                    if (i_DV = '1') then
                        
                        -- Place RX DATA in the correct byte position of the RX RAM word
                        case (r_RxHead_Data(1 downto 0)) is
                            when "00" =>
                                r_Ram_nByteSel <= "1110";
                                o_Ram_Data(7 downto 0) <= i_RxData;
                            when "01" =>
                                r_Ram_nByteSel <= "1101";
                                o_Ram_Data(15 downto 8) <= i_RxData;
                            when "10" =>
                                r_Ram_nByteSel <= "1011";
                                o_Ram_Data(23 downto 16) <= i_RxData;
                            when "11" =>
                                r_Ram_nByteSel <= "0111";
                                o_Ram_Data(31 downto 24) <= i_RxData;
                            when others => null;
                        end case;

                        r_Ram_Addr <= r_RxHead_Data(g_RAM_ADDR_WIDTH-1 downto 2); -- Set RAM address
                        r_State <= s_SetWE;
                    end if;
                ------------------------------------------------
                when s_SetWE =>
                    r_RxHead_Data <= r_RxHead_Data + 1;   -- Increment RX head pointer
                    r_Ram_WE <= '1';                      -- Enable RX RAM write
                    r_State <= s_Idle;
                ------------------------------------------------
                when others => r_State <= s_Idle;
            end case;

        end if;

    end process;

    -- Output RX head pointer value to MPU
    o_RxHead_Data <= (31 downto g_RAM_ADDR_WIDTH => '0') & r_RxHead_Data;

    -- Output RX RAM write enable signal
    o_Ram_WE <= r_Ram_WE;

    -- Output RX RAM write address
    o_Ram_Addr <= r_Ram_Addr;

    -- Output RX RAM byte select
    o_Ram_nByteSel <= r_Ram_nByteSel;
    
end behavioral;