library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_RXDATA_BLOCK is
    port (
        i_Clk           : in  std_logic;
        i_DV            : in  std_logic;
        i_RxData        : in  std_logic_vector(7 downto 0);
        i_RxHead_WE     : in  std_logic;
        i_RxHead_Data   : in  std_logic_vector(31 downto 0);
        o_Ram_WE        : out std_logic;
        o_Ram_Addr      : out std_logic_vector(8 downto 0);
        o_Ram_Data      : out std_logic_vector(8 downto 0);
        o_Ram_ByteSel   : out std_logic_vector(8 downto 0);
        o_RxHead_Data   : out std_logic_vector(31 downto 0)
    );
end UART_RXDATA_BLOCK;

architecture behavioral of UART_RXDATA_BLOCK is
begin
    -- Add your implementation here
end behavioral;