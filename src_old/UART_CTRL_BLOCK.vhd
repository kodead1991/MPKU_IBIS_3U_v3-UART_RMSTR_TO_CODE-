library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY UART_CTRL_BLOCK IS

    PORT (
        i_Clk : IN STD_LOGIC;
        i_En : IN STD_LOGIC;
        i_Addr : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        i_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_BaseAddr : IN STD_LOGIC_VECTOR(17 DOWNTO 0);

        o_Mode : OUT STD_LOGIC := '0';
        o_Reset : OUT STD_LOGIC := '0';
        o_Loopback : OUT STD_LOGIC := '0';
        o_Channel : OUT STD_LOGIC := '0'; -- 0-OSN, 1-RES
        o_TxStart : OUT STD_LOGIC := '0';
        o_CtrlReg : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_Test : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')
    );
END UART_CTRL_BLOCK;

ARCHITECTURE arch OF UART_CTRL_BLOCK IS

    --CONSTANTS
    CONSTANT c_Addr_UartCtrl : unsigned(17 DOWNTO 0) := "000001000000100000"; --1020

    --REGS
    SIGNAL r_TxStart1 : STD_LOGIC := '0';
    SIGNAL r_TxStart2 : STD_LOGIC := '0';
	 SIGNAL r_Ctrl : STD_LOGIC_VECTOR(31 downto 0) := x"00000003";

BEGIN

    PROCESS (i_Clk)
    BEGIN

        IF falling_edge(i_Clk) THEN

            IF (i_En = '1' AND (unsigned(i_Addr) = unsigned(i_BaseAddr) + c_Addr_UartCtrl)) THEN
                r_TxStart1 <= i_Data(6);
                r_Ctrl <= i_Data;
            ELSE
                r_TxStart1 <= '0';
            END IF;

            r_TxStart2 <= r_TxStart1;

        END IF;

    END PROCESS;

    o_TxStart <= r_TxStart1 AND NOT r_TxStart2;
	 
	 o_Mode <= r_Ctrl(0);
	 o_Reset <= r_Ctrl(1);
	 o_Loopback <= r_Ctrl(4);
	 o_Channel <= r_Ctrl(5);
	 
	 o_CtrlReg <= r_Ctrl;
	 
--	 o_CtrlReg(0) <= '1' when (i_En = '1' AND i_Addr = i_BaseAddr + c_Addr_UartCtrl) else '0';
--	 o_CtrlReg(1) <= i_Data(0);
--	 o_CtrlReg(2) <= i_Data(1);
--	 o_CtrlReg(3) <= i_Data(2);
--	 o_CtrlReg(4) <= i_Data(3);
--	 o_CtrlReg(5) <= i_Data(4);
--	 o_CtrlReg(6) <= i_Data(5);
--	 o_CtrlReg(7) <= i_Data(6);
--	 o_CtrlReg(8) <= i_Data(7);
	 
END arch;