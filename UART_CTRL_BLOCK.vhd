LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY UART_CTRL_BLOCK IS

    PORT (
        i_Clk : IN STD_LOGIC;
        i_En : IN STD_LOGIC;
        i_Addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        i_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_BaseAddr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        o_Mode : OUT STD_LOGIC := '0';
        o_Loopback : OUT STD_LOGIC := '0';
        o_Channel : OUT STD_LOGIC := '0'; -- 0-OSN, 1-RES
        o_TxStart : OUT STD_LOGIC := '0';
        o_CtrlReg : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0')

    );
END UART_CTRL_BLOCK;

ARCHITECTURE arch OF UART_CTRL_BLOCK IS

    --CONSTANTS
    CONSTANT c_Addr_UartCtrl : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0408";

    --REGS
    SIGNAL r_TxStart1 : STD_LOGIC := '0';
    SIGNAL r_TxStart2 : STD_LOGIC := '0';

BEGIN

    PROCESS (i_Clk)--i_En, i_Addr)
    BEGIN

        IF falling_edge(i_Clk) THEN

            IF (i_En = '1' AND i_Addr = i_BaseAddr + c_Addr_UartCtrl) THEN
                o_Mode <= i_Data(0);
                o_Loopback <= i_Data(4);
                o_Channel <= i_Data(5);
                r_TxStart1 <= i_Data(6);
                o_CtrlReg <= i_Data;
            ELSE
                r_TxStart1 <= '0';
            END IF;

            r_TxStart2 <= r_TxStart1;

        END IF;

    END PROCESS;

    o_TxStart <= r_TxStart1 AND NOT r_TxStart2;
END arch;