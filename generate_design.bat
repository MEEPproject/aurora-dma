@echo off
@set VIVADO_PATH=D:\Xilinx\Vivado\2020.1
echo .
%VIVADO_PATH%\bin\vivado -mode batch -nolog -nojournal -notrace -source ./tcl/gen_project.tcl
PAUSE
