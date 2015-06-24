@echo off

set CONFIG_PATH=%CD%

pushd ..\..\tools\make\
python make.py "%CONFIG_PATH%"
popd

pause