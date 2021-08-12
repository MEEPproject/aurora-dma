@echo off
@set VIVADO_PATH=%VIVADO_2020_1%
%VIVADO_PATH%\bin\vivado -mode batch -nolog -nojournal -notrace -source ./tcl/gen_project.tcl
PAUSE
