library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_TX_BLOCK is
    generic (
        -- Количество отсчётов тактовой частоты внутри одного бита UART
        g_CLKS_PER_BIT	: integer := 18;
        g_BIT_NUM		: integer := 15
    );
    Port (
        -- =====================
        -- Входные сигналы
        -- =====================
        i_Clk			: in	STD_LOGIC;						-- Тактовая частота
        i_TxDV			: in	STD_LOGIC;						-- Сигнал готовности данных для передачи
        i_Data			: in	STD_LOGIC_VECTOR(7 downto 0);	-- Данные для передачи

        -- =====================
        -- Выходные сигналы
        -- =====================
        o_Tx			: out	STD_LOGIC;						-- Линия передачи UART
        --o_TX_Active		: out	STD_LOGIC;					-- Активность передачи (не используется)
        o_Ready			: out	STD_LOGIC						-- Готовность к новой передаче
    );
end UART_TX_BLOCK;

architecture Behavioral of UART_TX_BLOCK is

    -- Конечный автомат передачи
    TYPE state IS (
        s_Idle,		-- Ожидание передачи
        s_TxOut		-- Передача данных
    );
    SIGNAL r_State		: state := s_Idle;		-- Текущее состояние автомата
    
    -- Внутренние сигналы
    signal r_Tx			: STD_LOGIC := '1';		-- Внутренний сигнал TX
    signal r_Tx_Active	: STD_LOGIC := '0';		-- Внутренний сигнал активности передачи
    signal r_Ready		: STD_LOGIC := '1';		-- Внутренний сигнал готовности

    SIGNAL r_ClkCnt		: INTEGER RANGE 0 TO g_CLKS_PER_BIT - 1 := 0;	-- Счётчик тактов внутри бита
    SIGNAL r_BitCnt		: INTEGER RANGE 0 TO g_BIT_NUM := 0;			-- Счётчик битов в посылке
    SIGNAL r_CntEn		: STD_LOGIC := '0';								-- Разрешение счёта

begin

    -- Процесс формирования тайминга передачи
    PROCESS (i_Clk)
    BEGIN
        IF rising_edge(i_Clk) THEN
            IF (r_CntEn = '0') THEN
                r_ClkCnt <= 0;		-- Сброс счётчика тактов
                r_BitCnt <= 0;		-- Сброс счётчика битов
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

    -- Процесс управления состояниями передачи
    PROCESS (i_Clk)
    BEGIN
        IF falling_edge(i_Clk) THEN
            CASE (r_State) IS
				-------------------------
                -- Ожидание передачи
				-------------------------
                WHEN s_Idle =>
                    o_Tx <= '1';	-- Линия TX в неактивном состоянии
                    IF (i_TxDV = '1') THEN
                        r_Ready <= '0';		-- Модуль занят
                        r_CntEn <= '1';		-- Запуск передачи
                        r_State <= s_TxOut;	-- Переход к передаче
                    END IF;
				-------------------------
                -- Передача данных
				-------------------------
                WHEN s_TxOut =>
                    CASE (r_BitCnt) IS
                        WHEN 0		=> r_Tx <= '1';		-- Пауза перед выдачей
                        WHEN 1		=> r_Tx <= '0';		-- Стартовый бит
                        WHEN 2		=> r_Tx <= i_Data(0);	-- Бит 0
                        WHEN 3		=> r_Tx <= i_Data(1);	-- Бит 1
                        WHEN 4		=> r_Tx <= i_Data(2);	-- Бит 2
                        WHEN 5		=> r_Tx <= i_Data(3);	-- Бит 3
                        WHEN 6		=> r_Tx <= i_Data(4);	-- Бит 4
                        WHEN 7		=> r_Tx <= i_Data(5);	-- Бит 5
                        WHEN 8		=> r_Tx <= i_Data(6);	-- Бит 6
                        WHEN 9		=> r_Tx <= i_Data(7);	-- Бит 7
                        WHEN 10		=> r_Tx <= i_Data(0) XOR i_Data(1) XOR i_Data(2) XOR i_Data(3) XOR i_Data(4) XOR i_Data(5) XOR i_Data(6) XOR i_Data(7); -- Бит четности
                        WHEN 11		=> r_Tx <= '1';		-- Стоп-бит
                        WHEN 12 =>
                            r_Ready <= '1';		-- Модуль готов
                            r_CntEn <= '0';		-- Остановка передачи
                            r_State <= s_Idle;	-- Переход в ожидание
                        WHEN OTHERS => r_Tx <= '1';	-- Остальные биты
                    END CASE;
                WHEN OTHERS => NULL;
            END CASE;
        END IF;
    END PROCESS;

    -- Присвоение выходных сигналов
    o_TX		<= r_TX;			-- Линия передачи UART
    --o_TX_Active	<= r_TX_Active;		-- Разрешение на выдачу для микросхемы RS-485
    o_Ready		<= r_Ready;			-- Готовность к новой передаче

end Behavioral;