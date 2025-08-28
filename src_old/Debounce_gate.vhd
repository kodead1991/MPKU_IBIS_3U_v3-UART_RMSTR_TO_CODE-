library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Debounce_gate is
--    Generic (
--        CLK_FREQ    : integer := 50_000_000; -- Clock frequency in Hz (default: 50 MHz)
--        DEBOUNCE_MS : integer := 20           -- Debounce time in milliseconds (default: 20 ms)
--    );
    Port (
        i_Clk    : in  STD_LOGIC; -- Clock input
        i_Signal : in  STD_LOGIC; -- Input signal with bounce
        o_Signal : out STD_LOGIC  -- Debounced output signal
    );
end Debounce_gate;

architecture Behavioral of Debounce_gate is
    
	constant CLK_FREQ    : integer := 50_000_000; -- Clock frequency in Hz (default: 50 MHz)
	constant DEBOUNCE_MS : integer := 20;         -- Debounce time in milliseconds (default: 20 ms)
    
    signal Debounce_Count : integer := 0; -- Counter to track stable signal time
    signal Debounce_Reg   : STD_LOGIC := '0'; -- Register to store the stable signal value
    signal Signal_Sync    : STD_LOGIC := '0'; -- Synchronized input signal
begin
    
    -- Process to synchronize the input signal with the clock
    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            Signal_Sync <= i_Signal; -- Synchronize the input signal
        end if;
    end process;

    -- Process to debounce the input signal
    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            if Signal_Sync /= Debounce_Reg then
                -- If the input signal changes, start counting
                Debounce_Count <= Debounce_Count + 1;
                if Debounce_Count = (CLK_FREQ / 1000) * DEBOUNCE_MS then
                    -- If the signal is stable for the debounce time, update the output
                    Debounce_Reg <= Signal_Sync;
                    Debounce_Count <= 0;
                end if;
            else
                -- If the signal is stable, reset the counter
                Debounce_Count <= 0;
            end if;
        end if;
    end process;

    -- Assign the debounced signal to the output
    o_Signal <= Debounce_Reg;
end Behavioral;