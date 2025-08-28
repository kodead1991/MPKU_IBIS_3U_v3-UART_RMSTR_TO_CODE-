library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.numeric_std.all;

entity UART is
    port (
        i_Clk		: in  STD_LOGIC;                    	-- Clock signal
        i_Data		: in  STD_LOGIC_VECTOR(7 downto 0);   	-- Input data (8 bits)
        i_En		: in  STD_LOGIC;                      	-- Transmission enable
        o_Tx		: out STD_LOGIC := '0';               	-- UART output signal
        o_Test		: out STD_LOGIC_VECTOR(7 downto 0) := (others => '0') -- Test output
    );
end UART;

architecture UART_arch of UART is

    signal r_State	: STD_LOGIC_VECTOR(13 downto 0) := (others => '0'); -- State counter
    signal r_Tx		: STD_LOGIC := '1';                                -- Internal transmission signal

begin

    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            case conv_integer(r_State) is
				-------------------------------------
                when 0 =>
                    if (i_En = '1') then  -- If transmission is enabled, start
                        r_State <= conv_std_logic_vector(1, 14);
                    end if;
				-------------------------------------
                when 16 =>
                    r_Tx <= '0';                -- Start bit
                    r_State <= r_State + 1;
				-------------------------------------
                when 32 =>
                    r_Tx <= i_Data(0);         -- Bit 0
                    r_State <= r_State + 1;
				-------------------------------------
                when 48 =>
                    r_Tx <= i_Data(1);         -- Bit 1
                    r_State <= r_State + 1;
				-------------------------------------
                when 64 =>
                    r_Tx <= i_Data(2);         -- Bit 2
                    r_State <= r_State + 1;
				-------------------------------------
                when 80 =>
                    r_Tx <= i_Data(3);         -- Bit 3
                    r_State <= r_State + 1;
				-------------------------------------
                when 96 =>
                    r_Tx <= i_Data(4);         -- Bit 4
                    r_State <= r_State + 1;
				-------------------------------------
                when 112 =>
                    r_Tx <= i_Data(5);         -- Bit 5
                    r_State <= r_State + 1;
				-------------------------------------
                when 128 =>
                    r_Tx <= i_Data(6);         -- Bit 6
                    r_State <= r_State + 1;
				-------------------------------------
                when 144 =>
                    r_Tx <= i_Data(7);         -- Bit 7
                    r_State <= r_State + 1;
				-------------------------------------
                when 160 =>
                    r_Tx <= '0';               -- Stop bit (0)
                    r_State <= r_State + 1;
				-------------------------------------
                when 176 =>
                    r_Tx <= '1';               -- End of transmission
                    r_State <= r_State + 1;
				-------------------------------------
                when 404 =>
                    r_State <= conv_std_logic_vector(0, 14);  -- Reset state
				-------------------------------------
                when others =>
                    r_State <= r_State + 1;    -- Move to the next state
				-------------------------------------
            end case;
        end if;
    end process;

    -- Assign the internal signal to the output
    o_Tx <= r_Tx;

end UART_arch;