library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_TXDATA_BLOCK is
    Port (
        i_Clk           : in  STD_LOGIC;                      -- Тактовый сигнал
        i_TxStart       : in  STD_LOGIC;                      -- Сигнал запуска передачи по UART TX
        i_TxHead        : in  STD_LOGIC_VECTOR(10 downto 0);  -- Верхняя граница данных TX в памяти
        i_RamData       : in  STD_LOGIC_VECTOR(31 downto 0);  -- Данные TX, прочитанные из памяти
        i_DriverReady   : in  STD_LOGIC;                      -- Флаг готовности драйвера UART TX
        i_TxTail_WE     : in  STD_LOGIC;                      -- Сигнал записи указателя нижней границы TX
        i_TxTail_Data   : in  STD_LOGIC_VECTOR(31 downto 0);  -- Значение указателя нижней границы TX (запись MPU)
        i_Reset         : in  STD_LOGIC;                      -- Сигнал общего сброса
        o_RamRE         : out STD_LOGIC;                      -- Сигнал чтения из памяти
        o_RamAddr       : out STD_LOGIC_VECTOR(8 downto 0);   -- Адрес чтения памяти
        o_DV            : out STD_LOGIC;                      -- Готовность данных TX к выдаче
        o_TxData        : out STD_LOGIC_VECTOR(7 downto 0);   -- Данные TX
        o_TxEn          : out STD_LOGIC;                      -- Разрешение выдачи для RS-485
        o_TxTail_Data   : out STD_LOGIC_VECTOR(31 downto 0)   -- Значение указателя нижней границы TX (чтение MPU)
    );
end UART_TXDATA_BLOCK;

architecture Behavioral of UART_TXDATA_BLOCK is

    -- =========================================================================
    -- КОНЕЧНЫЙ АВТОМАТ ПОДГОТОВКИ ДАННЫХ TX ДЛЯ UART
    -- =========================================================================
    TYPE state IS (
        s_Idle,         -- Ожидание запуска передачи
        s_CheckPtr,     -- Проверка совпадения указателей TX Tail и TX Head
        s_SetTxEn,      -- Установка разрешения передачи
        s_SetRE,        -- Запрос чтения из памяти
        s_WaitData1,    -- Ожидание данных из памяти
        s_WaitData2,    -- Не используется (зарезервировано)
        s_GetData,      -- Захват данных из памяти
        s_SetDV,        -- Формирование байта для UART
        s_ResetDV,      -- Сброс сигнала передачи
        s_Wait          -- Ожидание готовности драйвера, инкремент указателя TX Tail
    );
    SIGNAL r_State : state := s_Idle;

    -- Регистры
    SIGNAL r_TxTail_Data : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0'); -- Указатель нижней границы TX
    SIGNAL r_RamData     : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); -- Буфер данных из памяти

    signal r_TxEn        : STD_LOGIC := '0'; -- Разрешение передачи
    signal r_Tx_En_Cnt   : integer range 0 to 82 := 0; -- Счетчик для задержки разрешения передачи

begin

    PROCESS (i_Clk)
    BEGIN
        IF rising_edge(i_Clk) THEN
            IF (i_Reset = '1') THEN
                -- Сброс автомата и регистров
                r_State <= s_Idle;
                r_TxEn  <= '0';
                -- Обработка записи TX Tail от MPU во время сброса
                IF (i_TxTail_WE = '1') THEN
                    r_TxTail_Data <= (others => '0');
                END IF;
            ELSE
                -- Основной цикл конечного автомата передачи данных UART
                CASE r_State IS
                    ------------------------------------------------
                    WHEN s_Idle =>
                        -- Ожидание сигнала запуска передачи
                        IF (i_TxStart = '1') THEN
                            r_State <= s_CheckPtr;
                        END IF;
                    ------------------------------------------------
                    WHEN s_CheckPtr =>
                        -- Проверка совпадения указателей TX Tail и TX Head
                        IF (r_TxTail_Data = i_TxHead) THEN
                            r_State <= s_Idle;
                            r_TxEn  <= '0';
                        ELSE
                            r_State <= s_SetRE;
                            r_TxEn  <= '1';
                        END IF;
                    ------------------------------------------------
                    WHEN s_SetTxEn =>
                        -- Задержка разрешения передачи (не используется)
                        IF (r_Tx_En_Cnt /= 81) THEN
                            r_Tx_En_Cnt <= r_Tx_En_Cnt + 1;
                        ELSE
                            r_Tx_En_Cnt <= 0;
                            r_State <= s_SetRE;
                        END IF;
                    ------------------------------------------------
                    WHEN s_SetRE =>
                        -- Установка адреса и запроса чтения из памяти
                        o_RamAddr <= r_TxTail_Data(10 DOWNTO 2);
                        o_RamRE   <= '1';
                        r_State   <= s_WaitData1;
                    ------------------------------------------------
                    WHEN s_WaitData1 =>
                        -- Сброс сигнала чтения памяти, ожидание данных
                        o_RamRE <= '0';
                        r_State <= s_GetData;
                    ------------------------------------------------
                    WHEN s_GetData =>
                        -- Захват данных из памяти
                        r_RamData <= i_RamData;
                        r_State   <= s_SetDV;
                    ------------------------------------------------
                    WHEN s_SetDV =>
                        -- Формирование байта для передачи по UART
                        CASE (r_TxTail_Data(1 DOWNTO 0)) IS
                            WHEN "00"   => o_TxData <= r_RamData(7 DOWNTO 0);
                            WHEN "01"   => o_TxData <= r_RamData(15 DOWNTO 8);
                            WHEN "10"   => o_TxData <= r_RamData(23 DOWNTO 16);
                            WHEN OTHERS => o_TxData <= r_RamData(31 DOWNTO 24);
                        END CASE;
                        -- Ожидание готовности драйвера для передачи
                        IF (i_DriverReady = '1') THEN
                            o_DV    <= '1';
                            r_State <= s_ResetDV;
                        END IF;
                    ------------------------------------------------
                    WHEN s_ResetDV =>
                        -- Сброс сигнала передачи данных
                        o_DV    <= '0';
                        r_State <= s_Wait;
                    ------------------------------------------------
                    WHEN s_Wait =>
                        -- Ожидание готовности драйвера, инкремент указателя TX Tail
                        IF (i_DriverReady = '1') THEN
                            r_TxTail_Data <= r_TxTail_Data + 1;
                            r_State       <= s_CheckPtr;
                        END IF;
                    ------------------------------------------------
                    WHEN OTHERS => NULL;
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    -- Формирование выходных сигналов
    o_TxTail_Data <= (31 downto 11 => '0') & r_TxTail_Data; -- Выходное значение указателя TX Tail
    o_TxEn        <= r_TxEn;                                -- Выход разрешения передачи

end Behavioral;