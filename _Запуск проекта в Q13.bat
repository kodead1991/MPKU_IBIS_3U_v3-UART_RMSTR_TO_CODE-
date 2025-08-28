@echo off

cd /d E:\FPGA

set QUARTUS_PATH=C:\altera\13.0sp1\quartus\bin64\quartus.exe

:: Получаем путь к папке, где находится bat-файл
set BAT_DIR=%~dp0
set PROJECT_FILE=%BAT_DIR%MPKU_IBIS_RISCV.qpf

echo Quartus path = %QUARTUS_PATH%
echo Bat dir = %BAT_DIR%
echo Project path = %PROJECT_FILE%

start "" %QUARTUS_PATH% %PROJECT_FILE%

:: Очищаем переменные
set QUARTUS_PATH=
set BAT_DIR=
set PROJECT_FILE=