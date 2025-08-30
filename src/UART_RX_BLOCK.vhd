library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_RX_BLOCK is
    generic (
        g_CLKS_PER_BIT : integer := 18    -- Number of clock cycles per UART bit
    );
    port (
        i_Clk       : in  std_logic;                          -- Clock signal
        i_Reset     : in  std_logic;                          -- Reset signal
        i_Rx        : in  std_logic;                          -- UART RX input
        o_RxDV      : out std_logic;                          -- RX data valid flag
        o_RxData    : out std_logic_vector(7 downto 0);       -- Received data byte
        o_Breakline : out std_logic;                          -- Break line detected
        o_Test      : out std_logic_vector(7 downto 0)        -- Test/debug output
    );
end UART_RX_BLOCK;

architecture behavioral of UART_RX_BLOCK is

    -- Number of bits per UART word
    constant c_BIT_PER_WORD      : integer := 11;
    -- Point to sample data in the middle of the bit
    constant c_DATA_STORE_POINT  : integer := g_CLKS_PER_BIT / 2;

    -- State machine for UART RX process
    type t_state is (s_Idle, s_StartBit, s_DataBits, s_ParityBit, s_StopBit);
    signal r_State : t_state := s_Idle;

    -- Synchronization and RX signals
    signal r_RxSync         : std_logic_vector(2 downto 0) := "111";
    signal r_Rx             : std_logic := '1';
    signal r_CntClk         : integer range 0 to g_CLKS_PER_BIT-1 := 0;
    signal r_CntBit         : integer range 0 to 7 := 0;
    signal r_RxData         : std_logic_vector(7 downto 0) := (others => '0');
    signal r_RxDataValid    : std_logic := '0';
    signal r_FlagBreakLine  : std_logic := '0';

begin

    -- RX input synchronization process
    process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            r_RxSync <= r_RxSync(1 downto 0) & i_Rx;
            if (r_RxSync(2) = r_RxSync(1) and r_RxSync(1) = r_RxSync(0)) then
                r_Rx <= r_RxSync(2);
            end if;
        end if;
    end process;

    -- UART RX state machine process
    process (i_Clk)
        variable v_Parity : std_logic := '0';
    begin
        if rising_edge(i_Clk) then
            if (i_Reset = '1') then
                r_State <= s_Idle;
                r_CntClk <= 0;
                r_CntBit <= 0;
                r_RxDataValid <= '0';
                r_FlagBreakLine <= '0';
            else
                r_RxDataValid <= '0';

                case (r_State) is
                    -------------------------
                    -- Wait for start bit
                    -------------------------
                    when s_Idle =>
                        r_CntClk <= 0;
                        r_CntBit <= 0;
                        if (r_Rx = '0') then
                            r_State <= s_StartBit;
                        end if;
                    -------------------------
                    -- Check start bit
                    -------------------------
                    when s_StartBit =>
                        if (r_CntClk = (g_CLKS_PER_BIT-1)/2) then -- Sample in the middle of start bit
                            if (r_Rx = '0') then
                                r_State <= s_DataBits;
                                r_CntClk <= 0;
                            else
                                r_State <= s_Idle;
                            end if;
                        else
                            r_CntClk <= r_CntClk + 1;
                        end if;
                    -------------------------
                    -- Receive data bits
                    -------------------------
                    when s_DataBits =>
                        if (r_CntClk = g_CLKS_PER_BIT-1) then
                            r_CntClk <= 0;
                            r_RxData(r_CntBit) <= r_Rx;

                            if (r_CntBit = 7) then
                                r_State <= s_ParityBit;
                                r_CntBit <= 0;
                            else
                                r_CntBit <= r_CntBit + 1;
                            end if;

                        else
                            r_CntClk <= r_CntClk + 1;
                        end if;
                    -------------------------
                    -- Check parity bit
                    -------------------------
                    when s_ParityBit =>
                        if (r_CntClk = g_CLKS_PER_BIT-1) then
                            r_CntClk <= 0;

                            v_Parity := r_RxData(0) xor r_RxData(1) xor r_RxData(2) xor r_RxData(3) xor
                                       r_RxData(4) xor r_RxData(5) xor r_RxData(6) xor r_RxData(7);

                            if (r_Rx = v_Parity) then
                                r_State <= s_StopBit;
                            else
                                r_State <= s_Idle;
                            end if;
                        else
                            r_CntClk <= r_CntClk + 1;
                        end if;
                    -------------------------
                    -- Check stop bit and set valid flag
                    -------------------------
                    when s_StopBit =>
                        if (r_CntClk = g_CLKS_PER_BIT-1) then
                            r_CntClk <= 0;

                            if (r_Rx = '1') then
                                r_RxDataValid <= '1';
                            else
                                r_FlagBreakLine <= '1';
                            end if;

                            r_State <= s_Idle;

                        else
                            r_CntClk <= r_CntClk + 1;
                        end if;
                    -------------------------
                    when others =>
                        r_State <= s_Idle;
                end case;
            end if;
        end if;
    end process;

    -- Output assignments
    o_RxDV      <= r_RxDataValid;
    o_RxData    <= r_RxData when r_RxDataValid = '1' else (others => '0');
    o_Breakline <= r_FlagBreakLine;
    o_Test      <= (others => '0');

end behavioral;