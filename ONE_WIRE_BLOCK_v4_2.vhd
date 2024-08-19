LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ONE_WIRE_BLOCK_v4_2 IS

    PORT (
        i_LINE1_ID_DATA : IN STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
        i_LINE2_ID_DATA : IN STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
        i_LINE3_ID_DATA : IN STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
        i_LINE4_ID_DATA : IN STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

        o_ID_ADDR : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');

        o_LINE1_TEMP_DATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE2_TEMP_DATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE3_TEMP_DATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_LINE4_TEMP_DATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        o_TEMP_ADDR : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
        o_TEMP_WR : OUT STD_LOGIC := '0';

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
END ONE_WIRE_BLOCK_v4_2;

ARCHITECTURE arch OF ONE_WIRE_BLOCK_v4_2 IS

    --CONSTANTS
    CONSTANT c_CntMhz_Div : INTEGER := 25;--clock divider coefficient
    CONSTANT c_SensorNum : INTEGER := 16; --sensor's amount

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
    SIGNAL r_State_1WIRE : state_type := SEND;

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
    SIGNAL r_Cnt_Bit_Rx : INTEGER RANGE 0 TO 73 := 0; --rx bit count
    SIGNAL r_Cnt_Byte_Rom : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0'); --tx byte rom code count

    --SENS DATA
    SIGNAL r_LINE1_SensID : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL r_LINE2_SensID : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL r_LINE3_SensID : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL r_LINE4_SensID : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
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
    SIGNAL r_State : INTEGER RANGE 0 TO 7 := 3; --(SKIP ROM COMMAND, CONVERT TEMPERATURE COMAND, WAIT 800ms, MATCH ROM COMMAND, SET ROM COMMAND, READ SCRATCHPAD, GET SENS DATA)

    --CRC CALCULATION
    SIGNAL r_CRC0 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL r_CRC1 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL r_CRC2 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL r_CRC3 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL r_CRC0_Flag : STD_LOGIC := '0';
    SIGNAL r_CRC1_Flag : STD_LOGIC := '0';
    SIGNAL r_CRC2_Flag : STD_LOGIC := '0';
    SIGNAL r_CRC3_Flag : STD_LOGIC := '0';

BEGIN

    --TIMER 1MHz
    PROCESS (i_Clk)
    BEGIN

        IF falling_edge(i_Clk) THEN
            IF (r_Reset_1MHz_BitLow = '1') THEN
                r_Cnt_Time1MHz_BitLow <= 0;
            ELSE
                IF (i_1MHz = '1') THEN
                    r_Cnt_Time1MHz_BitLow <= r_Cnt_Time1MHz_BitLow + 1;
                END IF;
            END IF;
        END IF;

        IF falling_edge(i_Clk) THEN
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

        IF falling_edge(i_Clk) THEN
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

        IF falling_edge(i_Clk) THEN
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
                            r_State_1WIRE <= WRITE_BIT;
                            ------------------------------------------------------------
                            --CONVERT TEMPERATURE COMAND
                        WHEN 1 =>
                            r_State <= 2;
                            r_LINE1_SendBufer <= x"44";
                            r_LINE2_SendBufer <= x"44";
                            r_LINE3_SendBufer <= x"44";
                            r_LINE4_SendBufer <= x"44";
                            r_State_1WIRE <= WRITE_BIT;
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
                            r_State_1WIRE <= WRITE_BIT;
                            ------------------------------------------------------------
                            --SET ROM COMMAND
                        WHEN 4 =>
                            r_LINE1_SendBufer <= r_LINE1_SensID;
                            r_LINE2_SendBufer <= r_LINE2_SensID;
                            r_LINE3_SendBufer <= r_LINE3_SensID;
                            r_LINE4_SendBufer <= r_LINE4_SensID;

                            IF (r_Cnt_Byte_Rom(2 DOWNTO 0) = "111") THEN
                                r_State <= 5;
                            END IF;

                            r_Cnt_Byte_Rom <= r_Cnt_Byte_Rom + 1;
                            r_State_1WIRE <= WRITE_BIT;
                            ------------------------------------------------------------
                            --READ SCRATCHPAD	
                        WHEN 5 =>
                            r_State <= 6;
                            r_LINE1_SendBufer <= x"BE";
                            r_LINE2_SendBufer <= x"BE";
                            r_LINE3_SendBufer <= x"BE";
                            r_LINE4_SendBufer <= x"BE";
                            r_State_1WIRE <= WRITE_BIT;
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
                        -- IF (r_Cnt_Time125Hz = 1) THEN
                        r_Reset_125Hz <= '1';
                        r_State_1WIRE <= RESET;
                    END IF;
                END IF;
                ------------------------------------------------------------
                --SEND BYTE
                -- IF (r_State_1WIRE = WRITE_BYTE) THEN
                --     IF (r_Cnt_Bit_Tx = 7) THEN
                --         r_Cnt_Bit_Tx <= 0;
                --         r_State_1WIRE <= SEND;
                --     ELSE
                --         r_State_1WIRE <= WRITE_BIT;
                --     END IF;
                -- END IF;

                --8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
                --8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
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

                                --all rows down only here because this 2 cases (r_Write_BitLow and r_Write_BitHigh) run in parallel
                                IF (r_Cnt_Bit_Tx = 7) THEN
                                    r_Cnt_Bit_Tx <= 0;
                                    r_State_1WIRE <= SEND;
                                ELSE
                                    r_Cnt_Bit_Tx <= r_Cnt_Bit_Tx + 1;
                                END IF;
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
                --8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
                --8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
                --8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

                ------------------------------------------------------------
                --RECIEVE TEMPR DATA			
                IF (r_State_1WIRE = GET_DATA) THEN
                    CASE (r_Cnt_Bit_Rx) IS
                            ------------------------------------------------------------
                        WHEN 0 TO 71 => --read 72 bit 			
                            r_1WIRE_Main <= '0';
                            r_State_1WIRE <= READ_BIT;
                            ------------------------------------------------------------									
                        WHEN 72 => --STORE DATA TO BRAM
                            o_TEMP_ADDR <= r_CntSensor;
--                            o_LINE1_TEMP_DATA <= r_CRC0_Flag & "000" & x"000" & r_LINE1_SensData(15 DOWNTO 0);
--                            o_LINE2_TEMP_DATA <= r_CRC1_Flag & "000" & x"000" & r_LINE2_SensData(15 DOWNTO 0);
--                            o_LINE3_TEMP_DATA <= r_CRC2_Flag & "000" & x"000" & r_LINE3_SensData(15 DOWNTO 0);
--                            o_LINE4_TEMP_DATA <= r_CRC3_Flag & "000" & x"000" & r_LINE4_SensData(15 DOWNTO 0);
--                            o_LINE1_TEMP_DATA <= r_CRC0_Flag & "0000000" & r_CRC0 & r_LINE1_SensData(15 DOWNTO 0);
--                            o_LINE2_TEMP_DATA <= r_CRC1_Flag & "0000000" & r_CRC1 & r_LINE2_SensData(15 DOWNTO 0);
--                            o_LINE3_TEMP_DATA <= r_CRC2_Flag & "0000000" & r_CRC2 & r_LINE3_SensData(15 DOWNTO 0);
--                            o_LINE4_TEMP_DATA <= r_CRC3_Flag & "0000000" & r_CRC3 & r_LINE4_SensData(15 DOWNTO 0);
                            o_LINE1_TEMP_DATA <= r_CRC0_Flag & "0000000" & x"00" & r_LINE1_SensData(15 DOWNTO 0);
                            o_LINE2_TEMP_DATA <= r_CRC1_Flag & "0000000" & x"00" & r_LINE2_SensData(15 DOWNTO 0);
                            o_LINE3_TEMP_DATA <= r_CRC2_Flag & "0000000" & x"00" & r_LINE3_SensData(15 DOWNTO 0);
                            o_LINE4_TEMP_DATA <= r_CRC3_Flag & "0000000" & x"00" & r_LINE4_SensData(15 DOWNTO 0);
                            o_TEMP_WR <= '1';
                            r_Cnt_Bit_Rx <= 73;
                            ------------------------------------------------------------									
                        WHEN OTHERS => --all data rx			
                            o_TEMP_WR <= '0';
                            r_Cnt_Bit_Rx <= 0;
                            
                            r_CRC0 <= (OTHERS=>'0');
                            r_CRC1 <= (OTHERS=>'0');
                            r_CRC2 <= (OTHERS=>'0');
                            r_CRC3 <= (OTHERS=>'0');

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

                                --CRCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
                                --CRCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
                                --CRCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
                                --LINE1
                                r_CRC0(0) <= r_CRC0(1);
                                r_CRC0(1) <= r_CRC0(2);
                                r_CRC0(2) <= r_CRC0(0) XOR r_CRC0(3) XOR i_LINE1_1WIRE;
                                r_CRC0(3) <= r_CRC0(0) XOR r_CRC0(4) XOR i_LINE1_1WIRE;
                                r_CRC0(4) <= r_CRC0(5);
                                r_CRC0(5) <= r_CRC0(6);
                                r_CRC0(6) <= r_CRC0(7);
                                r_CRC0(7) <= r_CRC0(0) XOR i_LINE1_1WIRE;

                                --LINE2
                                r_CRC1(0) <= r_CRC1(1);
                                r_CRC1(1) <= r_CRC1(2);
                                r_CRC1(2) <= r_CRC1(0) XOR r_CRC1(3) XOR i_LINE2_1WIRE;
                                r_CRC1(3) <= r_CRC1(0) XOR r_CRC1(4) XOR i_LINE2_1WIRE;
                                r_CRC1(4) <= r_CRC1(5);
                                r_CRC1(5) <= r_CRC1(6);
                                r_CRC1(6) <= r_CRC1(7);
                                r_CRC1(7) <= r_CRC1(0) XOR i_LINE2_1WIRE;

                                --LINE3
                                r_CRC2(0) <= r_CRC2(1);
                                r_CRC2(1) <= r_CRC2(2);
                                r_CRC2(2) <= r_CRC2(0) XOR r_CRC2(3) XOR i_LINE3_1WIRE;
                                r_CRC2(3) <= r_CRC2(0) XOR r_CRC2(4) XOR i_LINE3_1WIRE;
                                r_CRC2(4) <= r_CRC2(5);
                                r_CRC2(5) <= r_CRC2(6);
                                r_CRC2(6) <= r_CRC2(7);
                                r_CRC2(7) <= r_CRC2(0) XOR i_LINE3_1WIRE;

                                --LINE4
                                r_CRC3(0) <= r_CRC3(1);
                                r_CRC3(1) <= r_CRC3(2);
                                r_CRC3(2) <= r_CRC3(0) XOR r_CRC3(3) XOR i_LINE4_1WIRE;
                                r_CRC3(3) <= r_CRC3(0) XOR r_CRC3(4) XOR i_LINE4_1WIRE;
                                r_CRC3(4) <= r_CRC3(5);
                                r_CRC3(5) <= r_CRC3(6);
                                r_CRC3(6) <= r_CRC3(7);
                                r_CRC3(7) <= r_CRC3(0) XOR i_LINE4_1WIRE;
                                --CRCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
                                --CRCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
                                --CRCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC			

                                r_BitRecieve <= 1;
                            END IF;
                            ------------------------------------------------------------
                        WHEN OTHERS =>
                            r_Reset_1MHz_BitLow <= '0';
                            IF (r_Cnt_Time1MHz_BitLow = 75) THEN --62 us

                                IF (r_CRC0 = x"0") THEN
                                    r_CRC0_Flag <= '0';
                                ELSE
                                    r_CRC0_Flag <= '1';
                                END IF;

                                IF (r_CRC1 = x"0") THEN
                                    r_CRC1_Flag <= '0';
                                ELSE
                                    r_CRC1_Flag <= '1';
                                END IF;

                                IF (r_CRC2 = x"0") THEN
                                    r_CRC2_Flag <= '0';
                                ELSE
                                    r_CRC2_Flag <= '1';
                                END IF;

                                IF (r_CRC3 = x"0") THEN
                                    r_CRC3_Flag <= '0';
                                ELSE
                                    r_CRC3_Flag <= '1';
                                END IF;

                                r_Reset_1MHz_BitLow <= '1';
                                r_BitRecieve <= 0;
                                r_State_1WIRE <= GET_DATA;
                            END IF;
                    END CASE;
                END IF;

            END IF; --(i_Mhz = '1')
        END IF; --rising_edge(i_Clk)
    END PROCESS;

    r_LINE1_SensID <= i_LINE1_ID_DATA;
    r_LINE2_SensID <= i_LINE2_ID_DATA;
    r_LINE3_SensID <= i_LINE3_ID_DATA;
    r_LINE4_SensID <= i_LINE4_ID_DATA;
    o_ID_ADDR <= r_Cnt_Byte_Rom;

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
    
    o_Test(0) <= r_CRC0(0);
    o_Test(1) <= r_CRC0(1);
    o_Test(2) <= r_CRC0(2);
    o_Test(3) <= r_CRC0(3);
    o_Test(4) <= r_CRC0(4);
    o_Test(5) <= r_CRC0(5);
    o_Test(6) <= r_CRC0(6);
    o_Test(7) <= '1' when (r_Cnt_Bit_Rx = 72) else '0';

END arch;