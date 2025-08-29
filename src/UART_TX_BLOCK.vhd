library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_TX_BLOCK is
    generic (
        -- Number of clock cycles per UART bit
        g_CLKS_PER_BIT	: integer := 18;
        g_BIT_NUM		: integer := 15
    );
    port (
        -- =====================
        -- Input signals
        -- =====================
        i_Clk			: in	std_logic;						-- Clock signal
        i_TxDV			: in	std_logic;						-- Data valid signal for transmission
        i_Data			: in	std_logic_vector(7 downto 0);	-- Data to transmit

        -- =====================
        -- Output signals
        -- =====================
        o_Tx			: out	std_logic;						-- UART transmit line
        --o_TX_Active		: out	std_logic;					-- Transmission activity (not used)
        o_Ready			: out	std_logic						-- Ready for new transmission
    );
end UART_TX_BLOCK;

architecture behavioral of UART_TX_BLOCK is

    -- Transmission state machine
    type state is (
        s_Idle,		-- Waiting for transmission
        s_TxOut		-- Transmitting data
    );
    signal r_State		: state := s_Idle;		-- Current state of the state machine

    -- Internal signals
    signal r_Tx			: std_logic := '1';		-- Internal TX signal
    --signal r_Tx_Active	: std_logic := '0';		-- Internal transmission activity signal
    signal r_Ready		: std_logic := '1';		-- Internal ready signal

    signal r_ClkCnt		: integer range 0 to g_CLKS_PER_BIT - 1 := 0;	-- Clock counter within bit
    signal r_BitCnt		: integer range 0 to g_BIT_NUM := 0;			-- Bit counter in packet
    signal r_CntEn		: std_logic := '0';								-- Counter enable

begin

    -- Transmission timing process
    process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            if (r_CntEn = '0') then
                r_ClkCnt <= 0;		-- Reset clock counter
                r_BitCnt <= 0;		-- Reset bit counter
            else
                if (r_ClkCnt = g_CLKS_PER_BIT - 1) then
                    r_ClkCnt <= 0;
                    r_BitCnt <= r_BitCnt + 1;
                else
                    r_ClkCnt <= r_ClkCnt + 1;
                end if;
            end if;
        end if;
    end process;

    -- Transmission state control process
    process (i_Clk)
    begin
        if falling_edge(i_Clk) then
            case (r_State) is
                -------------------------
                -- Waiting for transmission
                -------------------------
                when s_Idle =>
                    o_Tx <= '1';	-- TX line in inactive state
                    if (i_TxDV = '1') then
                        r_Ready <= '0';		-- Module busy
                        r_CntEn <= '1';		-- Start transmission
                        r_State <= s_TxOut;	-- Switch to transmission
                    end if;
                -------------------------
                -- Transmitting data
                -------------------------
                when s_TxOut =>
                    case (r_BitCnt) is
                        when 0		=> r_Tx <= '1';		-- Pause before output
                        when 1		=> r_Tx <= '0';		-- Start bit
                        when 2		=> r_Tx <= i_Data(0);	-- Bit 0
                        when 3		=> r_Tx <= i_Data(1);	-- Bit 1
                        when 4		=> r_Tx <= i_Data(2);	-- Bit 2
                        when 5		=> r_Tx <= i_Data(3);	-- Bit 3
                        when 6		=> r_Tx <= i_Data(4);	-- Bit 4
                        when 7		=> r_Tx <= i_Data(5);	-- Bit 5
                        when 8		=> r_Tx <= i_Data(6);	-- Bit 6
                        when 9		=> r_Tx <= i_Data(7);	-- Bit 7
                        when 10		=> r_Tx <= i_Data(0) xor i_Data(1) xor i_Data(2) xor i_Data(3) xor i_Data(4) xor i_Data(5) xor i_Data(6) xor i_Data(7); -- Parity bit
                        when 11		=> r_Tx <= '1';		-- Stop bit
                        when 12 =>
                            r_Ready <= '1';		-- Ready flag for new transmission
                            r_CntEn <= '0';		-- Stop transmission
                            r_State <= s_Idle;	-- Switch to waiting
                        when others => r_Tx <= '1';	-- Other bits
                    end case;
                when others => null;
            end case;
        end if;
    end process;

    -- Output signal assignments
    o_TX		<= r_TX;			-- UART transmit line
    --o_TX_Active	<= r_TX_Active;		-- Enable output for RS-485 chip
    o_Ready		<= r_Ready;			-- Ready

end behavioral;