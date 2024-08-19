LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ONE_WIRE_BLOCK_v3_2 IS

    PORT (
        i_LINE1_ID_DATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := x"FF01229266D86621";--(OTHERS => '0');
        i_LINE2_ID_DATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := x"FF01229266D86622";--(OTHERS => '0');
        i_LINE3_ID_DATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := x"FF01229266D86623";--(OTHERS => '0');
        i_LINE4_ID_DATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := x"FF01229266D86624";--(OTHERS => '0');

        o_ID_ADDR : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');

        o_LINE1_TEMP0 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := x"12345678";--(OTHERS => '0');
        o_LINE1_TEMP1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE1_TEMP2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE1_TEMP3 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE1_TEMP4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE1_TEMP5 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE1_TEMP6 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE1_TEMP7 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE1_TEMP8 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE1_TEMP9 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE1_TEMP10 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE1_TEMP11 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE1_TEMP12 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE1_TEMP13 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE1_TEMP14 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE1_TEMP15 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

        o_LINE2_TEMP0 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := x"12345678";--(OTHERS => '0');
        o_LINE2_TEMP1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE2_TEMP2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE2_TEMP3 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE2_TEMP4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE2_TEMP5 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE2_TEMP6 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE2_TEMP7 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE2_TEMP8 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE2_TEMP9 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE2_TEMP10 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE2_TEMP11 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE2_TEMP12 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE2_TEMP13 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE2_TEMP14 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE2_TEMP15 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

        o_LINE3_TEMP0 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := x"12345678";--(OTHERS => '0');
        o_LINE3_TEMP1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE3_TEMP2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE3_TEMP3 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE3_TEMP4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE3_TEMP5 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE3_TEMP6 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE3_TEMP7 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE3_TEMP8 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE3_TEMP9 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE3_TEMP10 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE3_TEMP11 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE3_TEMP12 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE3_TEMP13 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE3_TEMP14 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE3_TEMP15 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

        o_LINE4_TEMP0 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := x"12345678";--(OTHERS => '0');
        o_LINE4_TEMP1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE4_TEMP2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE4_TEMP3 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE4_TEMP4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE4_TEMP5 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE4_TEMP6 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE4_TEMP7 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE4_TEMP8 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE4_TEMP9 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE4_TEMP10 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE4_TEMP11 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE4_TEMP12 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE4_TEMP13 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE4_TEMP14 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE4_TEMP15 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

        i_Clk : IN STD_LOGIC;
        i_1MHz : IN STD_LOGIC;
        i_1kHz : IN STD_LOGIC;

        i_LINE1_1WIRE : IN STD_LOGIC;
        i_LINE2_1WIRE : IN STD_LOGIC;
        i_LINE3_1WIRE : IN STD_LOGIC;
        i_LINE4_1WIRE : IN STD_LOGIC;

        o_LINE1_1WIRE : OUT STD_LOGIC := '1';
        o_LINE2_1WIRE : OUT STD_LOGIC := '1';
        o_LINE3_1WIRE : OUT STD_LOGIC := '1';
        o_LINE4_1WIRE : OUT STD_LOGIC := '1';

        o_Test : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')
    );
END ONE_WIRE_BLOCK_v3_2;

ARCHITECTURE arch OF ONE_WIRE_BLOCK_v3_2 IS

    --CONSTANTS
    CONSTANT c_CntMhz_Div : INTEGER := 25;--clock divider coefficient
    CONSTANT c_SensorNum : INTEGER := 4; --sensor's amount

    --STATE MACHINES
    TYPE state_type IS (
        WAIT_800ms, --wait conv time
        RESET, --tx reset impulse
        PRESENCE, --rx presence impulse 
        SEND, --prepare byte for tx
        WRITE_BYTE, --analysis bit = 0 or 1
        WRITE_BIT, --tx bit slot
        GET_DATA, --counting data bit
        READ_BIT --rx bit slot
    );
    SIGNAL r_State_1WIRE : state_type := RESET;

    --		type SEND_type is (
    --			SKIP_ROM, 		--wait conv time
    --			CONV_TEMP, 				--tx reset impulse
    --			CONV_TEMP_WAIT, 			--rx presence impulse 
    --			MATCH_ROM, 				--prepare byte for tx
    --			READ_SCRATCHPAD, 		--analysis bit = 0 or 1
    --			GET_DATA
    --			);
    --		signal r_State_SEND	: SEND_type	:= SKIP_ROM;

    --REGS
    --Clock divider 25MHz to 1MHz (for 1-WIRE state machine)
    SIGNAL r_Cnt_1Mhz : INTEGER RANGE 0 TO c_CntMhz_Div - 1 := 0; --25.000.000/1.000.000=25 
    SIGNAL r_1MHz : STD_LOGIC := '0';

    --1WIRE OUTPUT FROM MAIN STATE MACHINE
    SIGNAL r_1WIRE_Main : STD_LOGIC := '1';

    --1WIRE OUTPUTs FROM TX
    SIGNAL r_1WIRE_BitLow : STD_LOGIC := '1';
    SIGNAL r_1WIRE_BitHigh : STD_LOGIC := '1';
    SIGNAL r_LINE1_1WIRE_WriteBit : STD_LOGIC := '1';
    SIGNAL r_LINE2_1WIRE_WriteBit : STD_LOGIC := '1';
    SIGNAL r_LINE3_1WIRE_WriteBit : STD_LOGIC := '1';
    SIGNAL r_LINE4_1WIRE_WriteBit : STD_LOGIC := '1';

    --SENS's COUNTER
    SIGNAL r_CntSensor : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');

    --1 MHz TIMER
    SIGNAL r_Cnt_Time1MHz_BitLow : INTEGER RANGE 0 TO 852 := 0; --main timer, delta = 1 us, max value 851 ms
    SIGNAL r_Cnt_Time1MHz_BitHigh : INTEGER RANGE 0 TO 59 := 0; --main timer, delta = 1 us, max value 851 ms
    SIGNAL r_Reset_1MHz_BitLow : STD_LOGIC := '1'; --reset r_Cnt_Time1MHz ('1' to reset)
    SIGNAL r_Reset_1MHz_BitHigh : STD_LOGIC := '1'; --reset r_Cnt_Time1MHz ('1' to reset)

    --8 kHz TIMER
    SIGNAL r_Cnt_Time125Hz : INTEGER RANGE 0 TO 94 := 0; --main timer, delta = 8 ms
    SIGNAL r_Reset_125Hz : STD_LOGIC := '0'; --reset r_Cnt_Time125Hz ('1' to reset)

    --BIT/BYTE COUNTERS		
    SIGNAL r_Cnt_Bit_Tx : INTEGER RANGE 0 TO 8 := 0; --tx bit count
    SIGNAL r_Cnt_Bit_Rx : INTEGER RANGE 0 TO 16 := 0; --rx bit count
    SIGNAL r_Cnt_Byte_Rom : INTEGER RANGE 0 TO 8 := 0; --tx byte rom code count

    --SENS DATA
    SIGNAL r_LINE1_SensID : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
    SIGNAL r_LINE2_SensID : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
    SIGNAL r_LINE3_SensID : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
    SIGNAL r_LINE4_SensID : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
    SIGNAL r_LINE1_SensData : STD_LOGIC_VECTOR(71 DOWNTO 0) := (OTHERS => '0'); --9 Byte from DS18B20 
    SIGNAL r_LINE2_SensData : STD_LOGIC_VECTOR(71 DOWNTO 0) := (OTHERS => '0'); --9 Byte from DS18B20 
    SIGNAL r_LINE3_SensData : STD_LOGIC_VECTOR(71 DOWNTO 0) := (OTHERS => '0'); --9 Byte from DS18B20 
    SIGNAL r_LINE4_SensData : STD_LOGIC_VECTOR(71 DOWNTO 0) := (OTHERS => '0'); --9 Byte from DS18B20 
    SIGNAL r_LINE1_SendBufer : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); --tx buffer
    SIGNAL r_LINE2_SendBufer : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); --tx buffer
    SIGNAL r_LINE3_SendBufer : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); --tx buffer
    SIGNAL r_LINE4_SendBufer : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); --tx buffer

    --SMALL STATE MACHINE FOR TX
    SIGNAL r_Write_BitLow : INTEGER RANGE 0 TO 1 := 0; --tx bit '0'
    SIGNAL r_Write_BitHigh : INTEGER RANGE 0 TO 1 := 0; --tx bit '1'

    SIGNAL r_BitRecieve : INTEGER RANGE 0 TO 3 := 0; --rx bit
    SIGNAL r_State : INTEGER RANGE 0 TO 7 := 0; --(SKIP ROM COMMAND, CONVERT TEMPERATURE COMAND, WAIT 800ms, MATCH ROM COMMAND, SET ROM COMMAND, READ SCRATCHPAD, GET SENS DATA)

BEGIN

    --TIMER 1MHz
    PROCESS (i_Clk)
    BEGIN

        IF rising_edge(i_Clk) THEN
            IF (r_Reset_1MHz_BitLow = '1') THEN
                r_Cnt_Time1MHz_BitLow <= 0;
            ELSE
                IF (i_1MHz = '1') THEN
                    r_Cnt_Time1MHz_BitLow <= r_Cnt_Time1MHz_BitLow + 1;
                END IF;
            END IF;
        END IF;

        IF rising_edge(i_Clk) THEN
            IF (r_Reset_1MHz_BitHigh = '1') THEN
                r_Cnt_Time1MHz_BitHigh <= 0;
            ELSE
                IF (i_1MHz = '1') THEN
                    r_Cnt_Time1MHz_BitHigh <= r_Cnt_Time1MHz_BitHigh + 1;
                END IF;
            END IF;
        END IF;

    END PROCESS;

    --TIMER 1kHz
    PROCESS (i_Clk)
    BEGIN

        IF rising_edge(i_Clk) THEN
            IF (r_Reset_125Hz = '1') THEN
                r_Cnt_Time125Hz <= 0;
            ELSE
                IF (i_1kHz = '1') THEN
                    r_Cnt_Time125Hz <= r_Cnt_Time125Hz + 1;
                END IF;
            END IF;
        END IF;

    END PROCESS;

    --1-Wire State Machine
    PROCESS (i_Clk)
    BEGIN

        IF rising_edge(i_Clk) THEN
            IF (i_1MHz = '1') THEN

                ------------------------------------------------------------
                --RESET
                IF (r_State_1WIRE = RESET) THEN
                    r_Reset_1MHz_BitLow <= '0'; --START MAIN TIMER										
                    IF (r_Cnt_Time1MHz_BitLow = 1) THEN --START STATE "RESET/LINE PULL-DOWN"							
                        r_1WIRE_Main <= '0';
                    ELSIF (r_Cnt_Time1MHz_BitLow = 485) THEN --END STATE "RESET/LINE PULL-DOWN"
                        r_1WIRE_Main <= '1';
                    ELSIF (r_Cnt_Time1MHz_BitLow = 851) THEN --SEND COMMANDS
                        r_Reset_1MHz_BitLow <= '1'; --END MAIN TIMER
                        r_State_1WIRE <= SEND;
                    END IF;
                END IF;
                ------------------------------------------------------------
                --SEND COMMAND
                IF (r_State_1WIRE = SEND) THEN
                    CASE (r_State) IS
                            ------------------------------------------------------------
                            --SKIP ROM COMMAND
                        WHEN 0 =>
                            r_State <= 1;
                            r_LINE1_SendBufer <= x"CC";
                            r_LINE2_SendBufer <= x"CC";
                            r_LINE3_SendBufer <= x"CC";
                            r_LINE4_SendBufer <= x"CC";
                            r_State_1WIRE <= WRITE_BYTE;
                            ------------------------------------------------------------
                            --CONVERT TEMPERATURE COMAND
                        WHEN 1 =>
                            r_State <= 2;
                            r_LINE1_SendBufer <= x"44";
                            r_LINE2_SendBufer <= x"44";
                            r_LINE3_SendBufer <= x"44";
                            r_LINE4_SendBufer <= x"44";
                            r_State_1WIRE <= WRITE_BYTE;
                            ------------------------------------------------------------
                            --WAIT 800ms
                        WHEN 2 =>
                            r_State <= 3;
                            r_State_1WIRE <= WAIT_800ms;
                            ------------------------------------------------------------	
                            --MATCH ROM COMMAND
                        WHEN 3 =>
                            r_State <= 4;
                            r_LINE1_SendBufer <= x"55";
                            r_LINE2_SendBufer <= x"55";
                            r_LINE3_SendBufer <= x"55";
                            r_LINE4_SendBufer <= x"55";
                            r_State_1WIRE <= WRITE_BYTE;
                            ------------------------------------------------------------
                            --SET ROM COMMAND
                        WHEN 4 =>
                            IF (r_Cnt_Byte_Rom = 8) THEN
                                r_Cnt_Byte_Rom <= 0;
                                r_State <= 5;
                            ELSE
                                CASE (r_Cnt_Byte_Rom) IS
                                    WHEN 0 => r_LINE1_SendBufer <= r_LINE1_SensID(7 DOWNTO 0);
                                        r_LINE2_SendBufer <= r_LINE2_SensID(7 DOWNTO 0);
                                        r_LINE3_SendBufer <= r_LINE3_SensID(7 DOWNTO 0);
                                        r_LINE4_SendBufer <= r_LINE4_SensID(7 DOWNTO 0);
                                    WHEN 1 => r_LINE1_SendBufer <= r_LINE1_SensID(15 DOWNTO 8);
                                        r_LINE2_SendBufer <= r_LINE2_SensID(15 DOWNTO 8);
                                        r_LINE3_SendBufer <= r_LINE3_SensID(15 DOWNTO 8);
                                        r_LINE4_SendBufer <= r_LINE4_SensID(15 DOWNTO 8);
                                    WHEN 2 => r_LINE1_SendBufer <= r_LINE1_SensID(23 DOWNTO 16);
                                        r_LINE2_SendBufer <= r_LINE2_SensID(23 DOWNTO 16);
                                        r_LINE3_SendBufer <= r_LINE3_SensID(23 DOWNTO 16);
                                        r_LINE4_SendBufer <= r_LINE4_SensID(23 DOWNTO 16);
                                    WHEN 3 => r_LINE1_SendBufer <= r_LINE1_SensID(31 DOWNTO 24);
                                        r_LINE2_SendBufer <= r_LINE2_SensID(31 DOWNTO 24);
                                        r_LINE3_SendBufer <= r_LINE3_SensID(31 DOWNTO 24);
                                        r_LINE4_SendBufer <= r_LINE4_SensID(31 DOWNTO 24);
                                    WHEN 4 => r_LINE1_SendBufer <= r_LINE1_SensID(39 DOWNTO 32);
                                        r_LINE2_SendBufer <= r_LINE2_SensID(39 DOWNTO 32);
                                        r_LINE3_SendBufer <= r_LINE3_SensID(39 DOWNTO 32);
                                        r_LINE4_SendBufer <= r_LINE4_SensID(39 DOWNTO 32);
                                    WHEN 5 => r_LINE1_SendBufer <= r_LINE1_SensID(47 DOWNTO 40);
                                        r_LINE2_SendBufer <= r_LINE2_SensID(47 DOWNTO 40);
                                        r_LINE3_SendBufer <= r_LINE3_SensID(47 DOWNTO 40);
                                        r_LINE4_SendBufer <= r_LINE4_SensID(47 DOWNTO 40);
                                    WHEN 6 => r_LINE1_SendBufer <= r_LINE1_SensID(55 DOWNTO 48);
                                        r_LINE2_SendBufer <= r_LINE2_SensID(55 DOWNTO 48);
                                        r_LINE3_SendBufer <= r_LINE3_SensID(55 DOWNTO 48);
                                        r_LINE4_SendBufer <= r_LINE4_SensID(55 DOWNTO 48);
                                    WHEN 7 => r_LINE1_SendBufer <= r_LINE1_SensID(63 DOWNTO 56);
                                        r_LINE2_SendBufer <= r_LINE2_SensID(63 DOWNTO 56);
                                        r_LINE3_SendBufer <= r_LINE3_SensID(63 DOWNTO 56);
                                        r_LINE4_SendBufer <= r_LINE4_SensID(63 DOWNTO 56);
                                    WHEN OTHERS => NULL;
                                END CASE;

                                r_Cnt_Byte_Rom <= r_Cnt_Byte_Rom + 1;
                                r_State_1WIRE <= WRITE_BYTE;
                            END IF;
                            ------------------------------------------------------------
                            --READ SCRATCHPAD	
                        WHEN 5 =>
                            r_State <= 6;
                            r_LINE1_SendBufer <= x"BE";
                            r_LINE2_SendBufer <= x"BE";
                            r_LINE3_SendBufer <= x"BE";
                            r_LINE4_SendBufer <= x"BE";
                            r_State_1WIRE <= WRITE_BYTE;
                            ------------------------------------------------------------
                            --GET SENS DATA									
                        WHEN 6 =>
                            r_State_1WIRE <= GET_DATA;
                            ------------------------------------------------------------
                        WHEN OTHERS =>
                            r_State_1WIRE <= RESET;
                    END CASE;
                END IF;

                ------------------------------------------------------------
                --WAIT 800 ms
                IF (r_State_1WIRE = WAIT_800ms) THEN
                    r_Reset_125Hz <= '0';
                    IF (r_Cnt_Time125Hz = 94) THEN --min conv time for 12-bit resolution 750 ms										
                        r_Reset_125Hz <= '1';
                        r_State_1WIRE <= RESET;
                    END IF;
                END IF;
                ------------------------------------------------------------
                --SEND BYTE
                IF (r_State_1WIRE = WRITE_BYTE) THEN
                    IF (r_Cnt_Bit_Tx = 8) THEN
                        r_Cnt_Bit_Tx <= 0;
                        r_State_1WIRE <= SEND;
                    ELSE
                        r_State_1WIRE <= WRITE_BIT;
                        r_Cnt_Bit_Tx <= r_Cnt_Bit_Tx + 1;
                    END IF;
                END IF;
                ------------------------------------------------------------
                --SEND BIT
                IF (r_State_1WIRE = WRITE_BIT) THEN

                    CASE (r_Write_BitLow) IS
                            ------------------------------------------------------------										
                        WHEN 0 =>
                            --start pull-down
                            r_1WIRE_BitLow <= '0';
                            r_Reset_1MHz_BitLow <= '0';
                            IF (r_Cnt_Time1MHz_BitLow = 59) THEN
                                r_Reset_1MHz_BitLow <= '1';
                                r_Write_BitLow <= 1;
                            END IF;
                            ------------------------------------------------------------										
                        WHEN OTHERS =>
                            r_1WIRE_BitLow <= '1';
                            r_Reset_1MHz_BitLow <= '0';
                            IF (r_Cnt_Time1MHz_BitLow = 3) THEN
                                r_Reset_1MHz_BitLow <= '1';
                                r_Write_BitLow <= 0;
                                r_State_1WIRE <= WRITE_BYTE;
                            END IF;
                            ------------------------------------------------------------														
                    END CASE;

                    CASE (r_Write_BitHigh) IS
                            ------------------------------------------------------------										
                        WHEN 0 =>
                            --start pull-down
                            r_1WIRE_BitHigh <= '0';
                            r_Reset_1MHz_BitHigh <= '0';
                            IF (r_Cnt_Time1MHz_BitHigh = 9) THEN
                                r_Reset_1MHz_BitHigh <= '1';
                                r_Write_BitHigh <= 1;
                            END IF;
                            ------------------------------------------------------------										
                        WHEN OTHERS =>
                            r_1WIRE_BitHigh <= '1';
                            r_Reset_1MHz_BitHigh <= '0';
                            IF (r_Cnt_Time1MHz_BitHigh = 53) THEN
                                r_Reset_1MHz_BitHigh <= '1';
                                r_Write_BitHigh <= 0;
                            END IF;
                            ------------------------------------------------------------														
                    END CASE;

                END IF;
                ------------------------------------------------------------
                --RECIEVE TEMPR DATA			
                IF (r_State_1WIRE = GET_DATA) THEN
                    CASE (r_Cnt_Bit_Rx) IS
                            ------------------------------------------------------------
                        WHEN 0 TO 15 => --read 72 bit 			
                            r_1WIRE_Main <= '0';
                            r_State_1WIRE <= READ_BIT;
                            ------------------------------------------------------------									
                        WHEN OTHERS => --all data rx			
                            r_Cnt_Bit_Rx <= 0;

                            IF ((conv_integer(r_CntSensor)) = c_SensorNum - 1) THEN --ALL SENS HAVE BEEN CHECKED 
                                r_State <= 0; --RESET SEND-STATE-MACHINE
                                r_CntSensor <= (OTHERS => '0'); --RESET SENS NAME's COUNTER
                            ELSE
                                r_CntSensor <= r_CntSensor + 1; --SET NEXT SENS NAME
                                r_State <= 3; --REPEAT THE TEMPREATURE READING CYCLE (MATCH >> READ >> GET DATA)			
                            END IF;

                            r_State_1Wire <= RESET;
                    END CASE;
                END IF;

                ------------------------------------------------------------
                --RECIEVE TEMPR BIT			
                IF (r_State_1WIRE = READ_BIT) THEN
                    CASE (r_BitRecieve) IS
                            ------------------------------------------------------------
                        WHEN 0 =>
                            r_1WIRE_Main <= '1';
                            r_Reset_1MHz_BitLow <= '0';
                            IF (r_Cnt_Time1MHz_BitLow = 13) THEN --14 us
                                r_LINE1_SensData(r_Cnt_Bit_Rx) <= i_LINE1_1WIRE;
                                r_LINE2_SensData(r_Cnt_Bit_Rx) <= i_LINE2_1WIRE;
                                r_LINE3_SensData(r_Cnt_Bit_Rx) <= i_LINE3_1WIRE;
                                r_LINE4_SensData(r_Cnt_Bit_Rx) <= i_LINE4_1WIRE;
                                r_Cnt_Bit_Rx <= r_Cnt_Bit_Rx + 1;
                                r_BitRecieve <= 1;
                            END IF;
                            ------------------------------------------------------------
                        WHEN OTHERS =>
                            r_Reset_1MHz_BitLow <= '0';
                            IF (r_Cnt_Time1MHz_BitLow = 75) THEN --62 us
                                r_Reset_1MHz_BitLow <= '1';
                                r_BitRecieve <= 0;
                                r_State_1WIRE <= GET_DATA;
                            END IF;
                    END CASE;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    PROCESS (i_Clk)
    BEGIN

        IF rising_edge(i_Clk) THEN
            IF (i_1MHz = '1') THEN

                IF (r_Cnt_Bit_Rx = 16) THEN
                    CASE conv_integer(r_CntSensor) IS --SAVE SENS DATA TO OUTPUT BUSES
                        WHEN 0 =>
                            o_LINE1_TEMP0 <= x"0000" & r_LINE1_SensData(15 DOWNTO 0);
                            o_LINE2_TEMP0 <= x"0000" & r_LINE2_SensData(15 DOWNTO 0);
                            o_LINE3_TEMP0 <= x"0000" & r_LINE3_SensData(15 DOWNTO 0);
                            o_LINE4_TEMP0 <= x"0000" & r_LINE4_SensData(15 DOWNTO 0);
                        WHEN 1 =>
                            o_LINE1_TEMP1 <= x"0000" & r_LINE1_SensData(15 DOWNTO 0);
                            o_LINE2_TEMP1 <= x"0000" & r_LINE2_SensData(15 DOWNTO 0);
                            o_LINE3_TEMP1 <= x"0000" & r_LINE3_SensData(15 DOWNTO 0);
                            o_LINE4_TEMP1 <= x"0000" & r_LINE4_SensData(15 DOWNTO 0);
                        WHEN 2 =>
                            o_LINE1_TEMP2 <= x"0000" & r_LINE1_SensData(15 DOWNTO 0);
                            o_LINE2_TEMP2 <= x"0000" & r_LINE2_SensData(15 DOWNTO 0);
                            o_LINE3_TEMP2 <= x"0000" & r_LINE3_SensData(15 DOWNTO 0);
                            o_LINE4_TEMP2 <= x"0000" & r_LINE4_SensData(15 DOWNTO 0);
                        WHEN 3 =>
                            o_LINE1_TEMP3 <= x"0000" & r_LINE1_SensData(15 DOWNTO 0);
                            o_LINE2_TEMP3 <= x"0000" & r_LINE2_SensData(15 DOWNTO 0);
                            o_LINE3_TEMP3 <= x"0000" & r_LINE3_SensData(15 DOWNTO 0);
                            o_LINE4_TEMP3 <= x"0000" & r_LINE4_SensData(15 DOWNTO 0);
                        WHEN 4 =>
                            o_LINE1_TEMP4 <= x"0000" & r_LINE1_SensData(15 DOWNTO 0);
                            o_LINE2_TEMP4 <= x"0000" & r_LINE2_SensData(15 DOWNTO 0);
                            o_LINE3_TEMP4 <= x"0000" & r_LINE3_SensData(15 DOWNTO 0);
                            o_LINE4_TEMP4 <= x"0000" & r_LINE4_SensData(15 DOWNTO 0);
                        WHEN 5 =>
                            o_LINE1_TEMP5 <= x"0000" & r_LINE1_SensData(15 DOWNTO 0);
                            o_LINE2_TEMP5 <= x"0000" & r_LINE2_SensData(15 DOWNTO 0);
                            o_LINE3_TEMP5 <= x"0000" & r_LINE3_SensData(15 DOWNTO 0);
                            o_LINE4_TEMP5 <= x"0000" & r_LINE4_SensData(15 DOWNTO 0);
                        WHEN 6 =>
                            o_LINE1_TEMP6 <= x"0000" & r_LINE1_SensData(15 DOWNTO 0);
                            o_LINE2_TEMP6 <= x"0000" & r_LINE2_SensData(15 DOWNTO 0);
                            o_LINE3_TEMP6 <= x"0000" & r_LINE3_SensData(15 DOWNTO 0);
                            o_LINE4_TEMP6 <= x"0000" & r_LINE4_SensData(15 DOWNTO 0);
                        WHEN 7 =>
                            o_LINE1_TEMP7 <= x"0000" & r_LINE1_SensData(15 DOWNTO 0);
                            o_LINE2_TEMP7 <= x"0000" & r_LINE2_SensData(15 DOWNTO 0);
                            o_LINE3_TEMP7 <= x"0000" & r_LINE3_SensData(15 DOWNTO 0);
                            o_LINE4_TEMP7 <= x"0000" & r_LINE4_SensData(15 DOWNTO 0);
                        WHEN 8 =>
                            o_LINE1_TEMP8 <= x"0000" & r_LINE1_SensData(15 DOWNTO 0);
                            o_LINE2_TEMP8 <= x"0000" & r_LINE2_SensData(15 DOWNTO 0);
                            o_LINE3_TEMP8 <= x"0000" & r_LINE3_SensData(15 DOWNTO 0);
                            o_LINE4_TEMP8 <= x"0000" & r_LINE4_SensData(15 DOWNTO 0);
                        WHEN 9 =>
                            o_LINE1_TEMP9 <= x"0000" & r_LINE1_SensData(15 DOWNTO 0);
                            o_LINE2_TEMP9 <= x"0000" & r_LINE2_SensData(15 DOWNTO 0);
                            o_LINE3_TEMP9 <= x"0000" & r_LINE3_SensData(15 DOWNTO 0);
                            o_LINE4_TEMP9 <= x"0000" & r_LINE4_SensData(15 DOWNTO 0);
                        WHEN 10 =>
                            o_LINE1_TEMP10 <= x"0000" & r_LINE1_SensData(15 DOWNTO 0);
                            o_LINE2_TEMP10 <= x"0000" & r_LINE2_SensData(15 DOWNTO 0);
                            o_LINE3_TEMP10 <= x"0000" & r_LINE3_SensData(15 DOWNTO 0);
                            o_LINE4_TEMP10 <= x"0000" & r_LINE4_SensData(15 DOWNTO 0);
                        WHEN 11 =>
                            o_LINE1_TEMP11 <= x"0000" & r_LINE1_SensData(15 DOWNTO 0);
                            o_LINE2_TEMP11 <= x"0000" & r_LINE2_SensData(15 DOWNTO 0);
                            o_LINE3_TEMP11 <= x"0000" & r_LINE3_SensData(15 DOWNTO 0);
                            o_LINE4_TEMP11 <= x"0000" & r_LINE4_SensData(15 DOWNTO 0);
                        WHEN 12 =>
                            o_LINE1_TEMP12 <= x"0000" & r_LINE1_SensData(15 DOWNTO 0);
                            o_LINE2_TEMP12 <= x"0000" & r_LINE2_SensData(15 DOWNTO 0);
                            o_LINE3_TEMP12 <= x"0000" & r_LINE3_SensData(15 DOWNTO 0);
                            o_LINE4_TEMP12 <= x"0000" & r_LINE4_SensData(15 DOWNTO 0);
                        WHEN 13 =>
                            o_LINE1_TEMP13 <= x"0000" & r_LINE1_SensData(15 DOWNTO 0);
                            o_LINE2_TEMP13 <= x"0000" & r_LINE2_SensData(15 DOWNTO 0);
                            o_LINE3_TEMP13 <= x"0000" & r_LINE3_SensData(15 DOWNTO 0);
                            o_LINE4_TEMP13 <= x"0000" & r_LINE4_SensData(15 DOWNTO 0);
                        WHEN 14 =>
                            o_LINE1_TEMP14 <= x"0000" & r_LINE1_SensData(15 DOWNTO 0);
                            o_LINE2_TEMP14 <= x"0000" & r_LINE2_SensData(15 DOWNTO 0);
                            o_LINE3_TEMP14 <= x"0000" & r_LINE3_SensData(15 DOWNTO 0);
                            o_LINE4_TEMP14 <= x"0000" & r_LINE4_SensData(15 DOWNTO 0);
                        WHEN OTHERS =>
                            o_LINE1_TEMP15 <= x"0000" & r_LINE1_SensData(15 DOWNTO 0);
                            o_LINE2_TEMP15 <= x"0000" & r_LINE2_SensData(15 DOWNTO 0);
                            o_LINE3_TEMP15 <= x"0000" & r_LINE3_SensData(15 DOWNTO 0);
                            o_LINE4_TEMP15 <= x"0000" & r_LINE4_SensData(15 DOWNTO 0);
                    END CASE;
                END IF;

            END IF;
        END IF;
    END PROCESS;

    r_LINE1_SensID <= i_LINE1_ID_DATA;
    r_LINE2_SensID <= i_LINE2_ID_DATA;
    r_LINE3_SensID <= i_LINE3_ID_DATA;
    r_LINE4_SensID <= i_LINE4_ID_DATA;
    o_ID_ADDR <= r_CntSensor;

    r_LINE1_1WIRE_WriteBit <=
        r_1WIRE_BitLow WHEN r_LINE1_SendBufer(r_Cnt_Bit_Tx) = '0' ELSE
        r_1WIRE_BitHigh;

    r_LINE2_1WIRE_WriteBit <=
        r_1WIRE_BitLow WHEN r_LINE2_SendBufer(r_Cnt_Bit_Tx) = '0' ELSE
        r_1WIRE_BitHigh;

    r_LINE3_1WIRE_WriteBit <=
        r_1WIRE_BitLow WHEN r_LINE3_SendBufer(r_Cnt_Bit_Tx) = '0' ELSE
        r_1WIRE_BitHigh;

    r_LINE4_1WIRE_WriteBit <=
        r_1WIRE_BitLow WHEN r_LINE4_SendBufer(r_Cnt_Bit_Tx) = '0' ELSE
        r_1WIRE_BitHigh;

    o_LINE1_1WIRE <= r_1WIRE_Main AND r_LINE1_1WIRE_WriteBit;
    o_LINE2_1WIRE <= r_1WIRE_Main AND r_LINE2_1WIRE_WriteBit;
    o_LINE3_1WIRE <= r_1WIRE_Main AND r_LINE3_1WIRE_WriteBit;
    o_LINE4_1WIRE <= r_1WIRE_Main AND r_LINE4_1WIRE_WriteBit;

END arch;