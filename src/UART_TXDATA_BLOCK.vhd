library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity UART_TXDATA_BLOCK is
    port (
        i_Clk           : in  std_logic;                      -- Clock signal
        i_TxStart       : in  std_logic;                      -- UART TX start signal
        i_TxHead        : in  std_logic_vector(10 downto 0);  -- Upper TX data boundary in memory
        i_RamData       : in  std_logic_vector(31 downto 0);  -- TX data read from memory
        i_DriverReady   : in  std_logic;                      -- UART TX driver ready flag
        i_TxTail_WE     : in  std_logic;                      -- TX tail pointer write signal
        --i_TxTail_Data   : in  std_logic_vector(31 downto 0);  -- TX tail pointer value (MPU write)
        i_Reset         : in  std_logic;                      -- Global reset signal
        o_RamRE         : out std_logic;                      -- Memory read signal
        o_RamAddr       : out std_logic_vector(8 downto 0);   -- Memory read address
        o_DV            : out std_logic;                      -- TX data ready to output
        o_TxData        : out std_logic_vector(7 downto 0);   -- TX data
        o_TxEn          : out std_logic;                      -- RS-485 output enable
        o_TxTail_Data   : out std_logic_vector(31 downto 0)   -- TX tail pointer value (MPU read)
    );
end UART_TXDATA_BLOCK;

architecture behavioral of UART_TXDATA_BLOCK is

    -- =========================================================================
    -- TX DATA PREPARATION STATE MACHINE FOR UART
    -- =========================================================================
    type state is (
        s_Idle,         -- Waiting for transmission start
        s_CheckPtr,     -- Checking TX Tail and TX Head pointers match
        s_SetTxEn,      -- Setting transmission enable
        s_SetRE,        -- Requesting memory read
        s_WaitData1,    -- Waiting for memory data
        s_WaitData2,    -- Not used (reserved)
        s_GetData,      -- Capturing data from memory
        s_SetDV,        -- Forming byte for UART
        s_ResetDV,      -- Resetting transmission signal
        s_Wait          -- Waiting for driver ready, incrementing TX Tail pointer
    );
    signal r_State : state := s_Idle;

    -- Registers
    signal r_TxTail_Data : std_logic_vector(10 downto 0) := (others => '0'); -- TX tail pointer
    signal r_RamData     : std_logic_vector(31 downto 0) := (others => '0'); -- Data buffer from memory

    signal r_TxEn        : std_logic := '0'; -- Transmission enable
    signal r_Tx_En_Cnt   : integer range 0 to 82 := 0; -- Counter for transmission enable delay

begin

    process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            if (i_Reset = '1') then
                -- State machine and register reset
                r_State <= s_Idle;
                r_TxEn  <= '0';
                -- TX Tail write from MPU during reset
                if (i_TxTail_WE = '1') then
                    r_TxTail_Data <= (others=>'0');
                end if;
            else
                -- Main UART TX data transmission state machine loop
                case r_State is
                    ------------------------------------------------
                    when s_Idle =>
                        -- Waiting for transmission start signal
                        if (i_TxStart = '1') then
                            r_State <= s_CheckPtr;
                        end if;
                    ------------------------------------------------
                    when s_CheckPtr =>
                        -- Checking TX Tail and TX Head pointers match
                        if (r_TxTail_Data = i_TxHead) then
                            r_State <= s_Idle;
                            r_TxEn  <= '0';
                        else
                            r_State <= s_SetRE;
                            r_TxEn  <= '1';
                        end if;
                    ------------------------------------------------
                    when s_SetTxEn =>
                        -- Transmission enable delay (not used)
                        if (r_Tx_En_Cnt /= 81) then
                            r_Tx_En_Cnt <= r_Tx_En_Cnt + 1;
                        else
                            r_Tx_En_Cnt <= 0;
                            r_State <= s_SetRE;
                        end if;
                    ------------------------------------------------
                    when s_SetRE =>
                        -- Setting address and requesting memory read
                        o_RamAddr <= r_TxTail_Data(10 downto 2);
                        o_RamRE   <= '1';
                        r_State   <= s_WaitData1;
                    ------------------------------------------------
                    when s_WaitData1 =>
                        -- Resetting memory read signal, waiting for data
                        o_RamRE <= '0';
                        r_State <= s_GetData;
                    ------------------------------------------------
                    when s_GetData =>
                        -- Capturing data from memory
                        r_RamData <= i_RamData;
                        r_State   <= s_SetDV;
                    ------------------------------------------------
                    when s_SetDV =>
                        -- Forming byte for UART transmission
                        case (r_TxTail_Data(1 downto 0)) is
                            when "00"   => o_TxData <= r_RamData(7 downto 0);
                            when "01"   => o_TxData <= r_RamData(15 downto 8);
                            when "10"   => o_TxData <= r_RamData(23 downto 16);
                            when others => o_TxData <= r_RamData(31 downto 24);
                        end case;
                        -- Waiting for driver ready for transmission
                        if (i_DriverReady = '1') then
                            o_DV    <= '1';
                            r_State <= s_ResetDV;
                        end if;
                    ------------------------------------------------
                    when s_ResetDV =>
                        -- Resetting data transmission signal
                        o_DV    <= '0';
                        r_State <= s_Wait;
                    ------------------------------------------------
                    when s_Wait =>
                        -- Waiting for driver ready, incrementing TX Tail pointer
                        if (i_DriverReady = '1') then
                            r_TxTail_Data <= r_TxTail_Data + 1;
                            r_State       <= s_CheckPtr;
                        end if;
                    ------------------------------------------------
                    when others => null;
                end case;
            end if;
        end if;
    end process;

    -- Output signal formation
    o_TxTail_Data <= (31 downto 11 => '0') & r_TxTail_Data; -- Output TX Tail pointer value
    o_TxEn        <= r_TxEn;                                -- Output transmission enable

end behavioral;