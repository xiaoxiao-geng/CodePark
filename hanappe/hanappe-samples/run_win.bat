cd /d %~dp0

:: setting
set MOAI_HOME=E:\ude\moai_release
set MOAI_BIN=%MOAI_HOME%\HostWin\moai.exe
set BIN_DIR=bin
set CONFIG_LUA=%MOAI_HOME%\samples\config\config.lua
set MAIN_LAU=main.lua

:: build
call ant build

:: run
cd %BIN_DIR%
%MOAI_BIN% %CONFIG_LUA% %MAIN_LAU%