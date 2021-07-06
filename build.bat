@echo off

REM Merge assembly files into one, run M4 on it
python .\build\mergeasm.py .\src\main.z80 > .\bin\raw.z80
type .\bin\raw.z80 | .\build\m4 > .\bin\src.z80
if %errorlevel% neq 0 call :exit 1

REM Create graphics files
for %%f in (gfx/*.png) do rgbds\rgbgfx -h -o gfx/bin/%%f.bin gfx/%%f
if %errorlevel% neq 0 call :exit 1

REM Run assembler, linker, etc.
:: Assemble main game into an object
rgbds\rgbasm -o.\bin\game.obj .\bin\src.z80
if %errorlevel% neq 0 call :exit 1
:: Assemble the hUGEDriver source into an object
rgbds\rgbasm -o.\bin\hUGEDriver.obj .\include\hUGEDriver.asm
if %errorlevel% neq 0 call :exit 1
:: Assemble songs into an object
rgbds\rgbasm -o.\bin\sample_song.obj -i.. .\include\sample_song.asm
if %errorlevel% neq 0 call :exit 1

:: Link everything together
rgbds\rgblink -m.\bin\game.map -n.\bin\game.sym -o.\bin\game.gb .\bin\game.obj .\bin\hUGEDriver.obj .\bin\sample_song.obj
if %errorlevel% neq 0 call :exit 1
rgbds\rgbfix -p0 -v .\bin\game.gb
if %errorlevel% neq 0 call :exit 1
call :exit 0

:exit