library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_TX_BLOCK is
    generic (
        -- ������⢮ �����⮢ ⠪⮢�� ����� ����� ������ ��� UART
        g_CLKS_PER_BIT	: integer := 18;
        g_BIT_NUM		: integer := 15
    );
    Port (
        -- =====================
        -- �室�� ᨣ����
        -- =====================
        i_Clk			: in	STD_LOGIC;						-- ���⮢�� ����
        i_TxDV			: in	STD_LOGIC;						-- ������ ��⮢���� ������ ��� ��।��
        i_Data			: in	STD_LOGIC_VECTOR(7 downto 0);	-- ����� ��� ��।��

        -- =====================
        -- ��室�� ᨣ����
        -- =====================
        o_Tx			: out	STD_LOGIC;						-- ����� ��।�� UART
        --o_TX_Active		: out	STD_LOGIC;					-- ��⨢����� ��।�� (�� �ᯮ������)
        o_Ready			: out	STD_LOGIC						-- ��⮢����� � ����� ��।��
    );
end UART_TX_BLOCK;

architecture Behavioral of UART_TX_BLOCK is

    -- ������ ��⮬�� ��।��
    TYPE state IS (
        s_Idle,		-- �������� ��।��
        s_TxOut		-- ��।�� ������
    );
    SIGNAL r_State		: state := s_Idle;		-- ����饥 ���ﭨ� ��⮬��
    
    -- ����७��� ᨣ����
    signal r_Tx			: STD_LOGIC := '1';		-- ����७��� ᨣ��� TX
    signal r_Tx_Active	: STD_LOGIC := '0';		-- ����७��� ᨣ��� ��⨢���� ��।��
    signal r_Ready		: STD_LOGIC := '1';		-- ����७��� ᨣ��� ��⮢����

    SIGNAL r_ClkCnt		: INTEGER RANGE 0 TO g_CLKS_PER_BIT - 1 := 0;	-- ����稪 ⠪⮢ ����� ���
    SIGNAL r_BitCnt		: INTEGER RANGE 0 TO g_BIT_NUM := 0;			-- ����稪 ��⮢ � ���뫪�
    SIGNAL r_CntEn		: STD_LOGIC := '0';								-- ����襭�� ����

begin

    -- ����� �ନ஢���� ⠩����� ��।��
    PROCESS (i_Clk)
    BEGIN
        IF rising_edge(i_Clk) THEN
            IF (r_CntEn = '0') THEN
                r_ClkCnt <= 0;		-- ���� ����稪� ⠪⮢
                r_BitCnt <= 0;		-- ���� ����稪� ��⮢
            ELSE
                IF (r_ClkCnt = g_CLKS_PER_BIT - 1) THEN
                    r_ClkCnt <= 0;				
                    r_BitCnt <= r_BitCnt + 1;	
                ELSE
                    r_ClkCnt <= r_ClkCnt + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- ����� �ࠢ����� ���ﭨﬨ ��।��
    PROCESS (i_Clk)
    BEGIN
        IF falling_edge(i_Clk) THEN
            CASE (r_State) IS
				-------------------------
                -- �������� ��।��
				-------------------------
                WHEN s_Idle =>
                    o_Tx <= '1';	-- ����� TX � ����⨢��� ���ﭨ�
                    IF (i_TxDV = '1') THEN
                        r_Ready <= '0';		-- ����� �����
                        r_CntEn <= '1';		-- ����� ��।��
                        r_State <= s_TxOut;	-- ���室 � ��।��
                    END IF;
				-------------------------
                -- ��।�� ������
				-------------------------
                WHEN s_TxOut =>
                    CASE (r_BitCnt) IS
                        WHEN 0		=> r_Tx <= '1';		-- ��㧠 ��। �뤠祩
                        WHEN 1		=> r_Tx <= '0';		-- ���⮢� ���
                        WHEN 2		=> r_Tx <= i_Data(0);	-- ��� 0
                        WHEN 3		=> r_Tx <= i_Data(1);	-- ��� 1
                        WHEN 4		=> r_Tx <= i_Data(2);	-- ��� 2
                        WHEN 5		=> r_Tx <= i_Data(3);	-- ��� 3
                        WHEN 6		=> r_Tx <= i_Data(4);	-- ��� 4
                        WHEN 7		=> r_Tx <= i_Data(5);	-- ��� 5
                        WHEN 8		=> r_Tx <= i_Data(6);	-- ��� 6
                        WHEN 9		=> r_Tx <= i_Data(7);	-- ��� 7
                        WHEN 10		=> r_Tx <= i_Data(0) XOR i_Data(1) XOR i_Data(2) XOR i_Data(3) XOR i_Data(4) XOR i_Data(5) XOR i_Data(6) XOR i_Data(7); -- ��� �⭮��
                        WHEN 11		=> r_Tx <= '1';		-- �⮯-���
                        WHEN 12 =>
                            r_Ready <= '1';		-- ����� ��⮢
                            r_CntEn <= '0';		-- ��⠭���� ��।��
                            r_State <= s_Idle;	-- ���室 � ��������
                        WHEN OTHERS => r_Tx <= '1';	-- ��⠫�� ����
                    END CASE;
                WHEN OTHERS => NULL;
            END CASE;
        END IF;
    END PROCESS;

    -- ��᢮���� ��室��� ᨣ�����
    o_TX		<= r_TX;			-- ����� ��।�� UART
    --o_TX_Active	<= r_TX_Active;		-- ����襭�� �� �뤠�� ��� �����奬� RS-485
    o_Ready		<= r_Ready;			-- ��⮢����� � ����� ��।��

end Behavioral;