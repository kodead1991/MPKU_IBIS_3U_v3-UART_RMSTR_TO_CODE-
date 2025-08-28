library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_TXDATA_BLOCK is
	Port (
		i_Clk           : in  STD_LOGIC;
		i_TxStart       : in  STD_LOGIC;
		i_TxHead        : in  STD_LOGIC_VECTOR(10 downto 0);
		i_RamData       : in  STD_LOGIC_VECTOR(31 downto 0);
		i_DriverReady   : in  STD_LOGIC;
		i_TxTail_WE     : in  STD_LOGIC;
		i_TxTail_Data   : in  STD_LOGIC_VECTOR(31 downto 0);
		i_Reset         : in  STD_LOGIC;
		o_RamRE         : out STD_LOGIC;
		o_RamAddr       : out STD_LOGIC_VECTOR(8 downto 0);
		o_DV            : out STD_LOGIC;
		o_TxData        : out STD_LOGIC_VECTOR(7 downto 0);
		o_TxEn          : out STD_LOGIC;
		o_TxTail        : out STD_LOGIC_VECTOR(31 downto 0)
	);
end UART_TXDATA_BLOCK;

architecture Behavioral of UART_TXDATA_BLOCK is

	-- =========================================================================
    -- �������� ������� ��� ���������� ������ TX � ������ �� ��������� UART
    -- =========================================================================
	TYPE state IS (
		s_Idle,
		s_CheckPtr,
		s_SetTxEn,
		s_SetRE,
		s_WaitData1,
		s_WaitData2,
		s_GetData,
		s_SetDV,
		s_ResetDV,
		s_Wait
	);
	SIGNAL r_State : state := s_Idle;

	--REGS
	SIGNAL r_TxTail : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0');
	SIGNAL r_RamData : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	
	signal r_TxEn: STD_LOGIC := '0';

	signal r_Tx_En_Cnt : integer range 0 to 82 := 0;

begin

PROCESS (i_Clk)
    BEGIN

        IF rising_edge(i_Clk) THEN
        
            IF (i_Reset = '1') THEN
                
                -- ���� ����筮�� ��⮬�� � ॣ���஢
                r_State <= s_Idle;
                
                -- ��ࠡ�⪠ ����� TX Tail �� MPU �� ���
                IF (i_TxTail_WE = '1') THEN
                    -- r_TxTail <= r_TxTail_Data(10 downto 0);
                    r_TxTail <= (others=>'0');
                END IF;
                
                r_TxEn <= '0';
                
            ELSE

                -- �᭮���� 横� ����筮�� ��⮬�� ��।�� ������ UART
                CASE r_State IS
                    ------------------------------------------------
                    WHEN s_Idle =>
                        -- �������� ᨣ���� ����᪠ ��।��
                        IF (i_TxStart = '1') THEN
                            r_State <= s_CheckPtr;
                        END IF;
                    ------------------------------------------------
                    WHEN s_CheckPtr =>
                        -- �஢�ઠ ᮢ������� 㪠��⥫�� TX Tail � TX Head
                        IF (r_TxTail = i_TxHead) THEN
                            r_State <= s_Idle;
                            r_TxEn <= '0';
                        ELSE
                            r_State <= s_SetRE;
                            r_TxEn <= '1';
                        END IF;
					------------------------------------------------
					WHEN s_SetTxEn =>
						if (r_Tx_En_Cnt /= 81) THEN
							r_Tx_En_Cnt <= r_Tx_En_Cnt + 1;
						else
							r_Tx_En_Cnt <= 0;
							r_State <= s_SetRE;
						end if;
                    ------------------------------------------------
                    WHEN s_SetRE =>
                        -- ��⠭���� ���� � ����� �⥭�� �� RAM
                        o_RamAddr <= r_TxTail(10 DOWNTO 2);
                        o_RamRE <= '1';
                        r_State <= s_WaitData1;
                    ------------------------------------------------
                    WHEN s_WaitData1 =>
                        -- ���� ᨣ���� �⥭�� RAM, �������� ������
                        o_RamRE <= '0';
                        r_State <= s_GetData;
                    ------------------------------------------------
                    WHEN s_GetData =>
                        -- ��墠� ������ �� RAM
                        r_RamData <= i_RamData;
                        r_State <= s_SetDV;
                    ------------------------------------------------
                    WHEN s_SetDV =>
                        -- ��ନ஢���� ���� ��� ��।�� �� UART
                        CASE (r_TxTail(1 DOWNTO 0)) IS
                            WHEN "00" => o_TxData <= r_RamData(7 DOWNTO 0);
                            WHEN "01" => o_TxData <= r_RamData(15 DOWNTO 8);
                            WHEN "10" => o_TxData <= r_RamData(23 DOWNTO 16);
                            WHEN OTHERS => o_TxData <= r_RamData(31 DOWNTO 24);
                        END CASE;

                        -- �������� ��⮢���� �ࠩ��� ��� ��।��
                        IF (i_DriverReady = '1') THEN
                            o_DV <= '1';
                            r_State <= s_ResetDV;
                        END IF;
                    ------------------------------------------------
                    WHEN s_ResetDV =>
                        -- ���� ᨣ���� ��।�� ������
                        o_DV <= '0';
                        r_State <= s_Wait;
                    ------------------------------------------------
                    WHEN s_Wait =>
                        -- �������� ��⮢���� �ࠩ���, ���६��� 㪠��⥫� TX Tail
                        IF (i_DriverReady = '1') THEN
                            r_TxTail <= r_TxTail + 1;
                            r_State <= s_CheckPtr;
                        END IF;
                    ------------------------------------------------
                    WHEN OTHERS => NULL;
                END CASE;
                
            END IF;
                
        END IF;

    END PROCESS;

	o_TxTail <= (31 downto 11 => '0') & r_TxTail;
	
	o_TxEn <= r_TxEn;

end Behavioral;