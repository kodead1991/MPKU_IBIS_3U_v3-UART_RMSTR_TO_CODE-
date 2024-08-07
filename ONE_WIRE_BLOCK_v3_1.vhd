LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ONE_WIRE_BLOCK_v3_1 IS

    PORT (
        i_ID_DATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');

        o_ID_ADDR : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');

        o_TEMP_DATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_TEMP_ADDR : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
        o_TEMP_WR : OUT STD_LOGIC := '0';

        i_Clk : IN STD_LOGIC;
        i_1MHz : IN STD_LOGIC;
        i_1kHz : IN STD_LOGIC;

        i_1WIRE : IN STD_LOGIC;
        o_1WIRE : OUT STD_LOGIC := '1';

        o_Test : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')
    );
END ONE_WIRE_BLOCK_v3_1;

ARCHITECTURE arch OF ONE_WIRE_BLOCK_v3_1 IS

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
        WRITE_LOW, --tx impulse for bit = 0
        WRITE_HIGH, --tx impulse for bit = 1
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

    --SENS's COUNTER
    SIGNAL r_CntSensor : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');

    --1 MHz TIMER
    SIGNAL r_Cnt_Time1MHz : INTEGER RANGE 0 TO 851 := 0; --main timer, delta = 1 us, max value 851 ms
    SIGNAL r_Reset_1MHz : STD_LOGIC := '0'; --reset r_Cnt_Time1MHz ('1' to reset)

    --8 kHz TIMER
    SIGNAL r_Cnt_Time125Hz : INTEGER RANGE 0 TO 94 := 0; --main timer, delta = 8 ms
    SIGNAL r_Reset_125Hz : STD_LOGIC := '0'; --reset r_Cnt_Time125Hz ('1' to reset)

    --BIT/BYTE COUNTERS		
    SIGNAL r_Cnt_Bit_Tx : INTEGER RANGE 0 TO 8 := 0; --tx bit count
    SIGNAL r_Cnt_Bit_Rx : INTEGER RANGE 0 TO 17 := 0; --rx bit count
    SIGNAL r_Cnt_Byte_Rom : INTEGER RANGE 0 TO 8 := 0; --tx byte rom code count

    --SENS DATA
    SIGNAL r_SensID : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
    SIGNAL r_SensData : STD_LOGIC_VECTOR(71 DOWNTO 0) := (OTHERS => '0'); --9 Byte from DS18B20 
    SIGNAL r_SendBufer : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); --tx buffer

    SIGNAL r_Write_Low : INTEGER RANGE 0 TO 1 := 0; --tx bit '0'
    SIGNAL r_Write_High : INTEGER RANGE 0 TO 1 := 0; --tx bit '1'
    SIGNAL r_BitRecieve : INTEGER RANGE 0 TO 3 := 0; --rx bit
    SIGNAL r_State : INTEGER RANGE 0 TO 7 := 0; --(SKIP ROM COMMAND, CONVERT TEMPERATURE COMAND, WAIT 800ms, MATCH ROM COMMAND, SET ROM COMMAND, READ SCRATCHPAD, GET SENS DATA)

BEGIN

    --TIMER 1MHz
    PROCESS (i_Clk)
    BEGIN

        IF rising_edge(i_Clk) THEN
            IF (r_Reset_1MHz = '1') THEN
                r_Cnt_Time1MHz <= 0;
            ELSE
                IF (i_1MHz = '1') THEN
                    r_Cnt_Time1MHz <= r_Cnt_Time1MHz + 1;
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
                    r_Reset_1MHz <= '0'; --START MAIN TIMER										
                    IF (r_Cnt_Time1MHz = 1) THEN --START STATE "RESET/LINE PULL-DOWN"							
                        o_1WIRE <= '0';
                    ELSIF (r_Cnt_Time1MHz = 485) THEN --END STATE "RESET/LINE PULL-DOWN"
                        o_1WIRE <= '1';
                    ELSIF (r_Cnt_Time1MHz = 851) THEN --SEND COMMANDS
                        r_Reset_1MHz <= '1'; --END MAIN TIMER
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
                            r_SendBufer <= x"CC";
                            r_State_1WIRE <= WRITE_BYTE;
                            ------------------------------------------------------------
                            --CONVERT TEMPERATURE COMAND
                        WHEN 1 =>
                            r_State <= 2;
                            r_SendBufer <= x"44";
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
                            r_SendBufer <= x"55";
                            r_State_1WIRE <= WRITE_BYTE;
                            ------------------------------------------------------------
                            --SET ROM COMMAND
                        WHEN 4 =>
                            IF (r_Cnt_Byte_Rom = 8) THEN
                                r_Cnt_Byte_Rom <= 0;
                                r_State <= 5;
                            ELSE
                                CASE (r_Cnt_Byte_Rom) IS
                                    WHEN 0 => r_SendBufer <= r_SensID(7 DOWNTO 0);
                                    WHEN 1 => r_SendBufer <= r_SensID(15 DOWNTO 8);
                                    WHEN 2 => r_SendBufer <= r_SensID(23 DOWNTO 16);
                                    WHEN 3 => r_SendBufer <= r_SensID(31 DOWNTO 24);
                                    WHEN 4 => r_SendBufer <= r_SensID(39 DOWNTO 32);
                                    WHEN 5 => r_SendBufer <= r_SensID(47 DOWNTO 40);
                                    WHEN 6 => r_SendBufer <= r_SensID(55 DOWNTO 48);
                                    WHEN 7 => r_SendBufer <= r_SensID(63 DOWNTO 56);
                                    WHEN OTHERS => NULL;
                                END CASE;

                                r_Cnt_Byte_Rom <= r_Cnt_Byte_Rom + 1;
                                r_State_1WIRE <= WRITE_BYTE;
                            END IF;
                            ------------------------------------------------------------
                            --READ SCRATCHPAD	
                        WHEN 5 =>
                            r_State <= 6;
                            r_SendBufer <= x"BE";
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
                        IF (r_SendBufer(r_Cnt_Bit_Tx) = '0') THEN --tx '0'
                            r_State_1WIRE <= WRITE_LOW;
                        ELSE --tx '1'
                            r_State_1WIRE <= WRITE_HIGH;
                        END IF;

                        r_Cnt_Bit_Tx <= r_Cnt_Bit_Tx + 1;
                    END IF;
                END IF;

                ------------------------------------------------------------
                --SEND BIT='0'
                IF (r_State_1WIRE = WRITE_LOW) THEN
                    CASE (r_Write_Low) IS
                            ------------------------------------------------------------										
                        WHEN 0 =>
                            o_1WIRE <= '0'; --start pull-down
                            r_Reset_1MHz <= '0';
                            IF (r_Cnt_Time1MHz = 59) THEN --60 us
                                r_Reset_1MHz <= '1';
                                r_Write_Low <= 1;
                            END IF;
                            ------------------------------------------------------------
                        WHEN OTHERS => --end pull-down										
                            o_1WIRE <= '1';
                            r_Reset_1MHz <= '0';
                            IF (r_Cnt_Time1MHz = 3) THEN --4 us
                                r_Reset_1MHz <= '1';
                                r_Write_Low <= 0;
                                r_State_1WIRE <= WRITE_BYTE;
                            END IF;
                            ------------------------------------------------------------														
                    END CASE;
                END IF;

                ------------------------------------------------------------
                --SEND BIT='1'
                IF (r_State_1WIRE = WRITE_HIGH) THEN
                    CASE (r_Write_High) IS
                            ------------------------------------------------------------
                        WHEN 0 =>
                            o_1WIRE <= '0'; --start pull-down
                            r_Reset_1MHz <= '0';
                            IF (r_Cnt_Time1MHz = 9) THEN --10 us
                                r_Reset_1MHz <= '1';
                                r_Write_High <= 1;
                            END IF;
                            ------------------------------------------------------------
                        WHEN OTHERS =>
                            o_1WIRE <= '1'; --end pull-down
                            r_Reset_1MHz <= '0';
                            IF (r_Cnt_Time1MHz = 53) THEN --54 us
                                r_Reset_1MHz <= '1';
                                r_Write_High <= 0;
                                r_State_1WIRE <= WRITE_BYTE;
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
                            o_1WIRE <= '0';
                            r_State_1WIRE <= READ_BIT;
                            ------------------------------------------------------------									
                        WHEN 16 => --STORE DATA TO BRAM
                            o_TEMP_ADDR <= r_CntSensor;
                            o_TEMP_DATA <= x"0000" & r_SensData(15 DOWNTO 0);
                            o_TEMP_WR <= '1';
                            r_Cnt_Bit_Rx <= 17;
                            ------------------------------------------------------------									
                        WHEN OTHERS => --all data rx			
                            r_Cnt_Bit_Rx <= 0;

                            o_TEMP_WR <= '0';

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
                            o_1WIRE <= '1';
                            r_Reset_1MHz <= '0';
                            IF (r_Cnt_Time1MHz = 13) THEN --14 us
                                r_SensData(r_Cnt_Bit_Rx) <= i_1WIRE;
                                r_Cnt_Bit_Rx <= r_Cnt_Bit_Rx + 1;
                                r_BitRecieve <= 1;
                            END IF;
                            ------------------------------------------------------------
                        WHEN OTHERS =>
                            r_Reset_1MHz <= '0';
                            IF (r_Cnt_Time1MHz = 75) THEN --62 us
                                r_Reset_1MHz <= '1';
                                r_BitRecieve <= 0;
                                r_State_1WIRE <= GET_DATA;
                            END IF;
                    END CASE;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    r_SensID <= i_ID_DATA;
    o_ID_ADDR <= r_CntSensor;

END arch;