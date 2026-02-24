@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Verificacion Completa del Sistema (Evidencia)
color 0A

:: ======= Archivo de evidencia =======
set "LOG=%~dp0evidencia_%COMPUTERNAME%.txt"

echo Guardando evidencia en: "%LOG%"
echo.

(
echo =====================================
echo        VERIFICACION DEL SISTEMA
echo =====================================
echo Fecha/Hora: %DATE% %TIME%
echo Equipo: %COMPUTERNAME%
echo.
) > "%LOG%"

echo Usuario actual:
whoami
whoami >> "%LOG%"
echo.

:: Verificar privilegios
net session >nul 2>&1
if %errorlevel%==0 (
    set "ADMIN=ADMINISTRADOR"
) else (
    set "ADMIN=USUARIO NORMAL"
)

echo Privilegios detectados: %ADMIN%
echo Privilegios detectados: %ADMIN%>> "%LOG%"
echo.

echo =====================================
echo        BUSQUEDA DE CMD.EXE
echo =====================================
echo.

echo Procesos cmd.exe activos:
tasklist /FI "IMAGENAME eq cmd.exe"
tasklist /FI "IMAGENAME eq cmd.exe" >> "%LOG%"
echo.

set /p pid=Ingresa el numero de PID que quieres verificar: 

tasklist /FI "PID eq %pid%" | find "%pid%" >nul
if %errorlevel%==0 (
    set "PID_STATUS=EXISTE"
    echo El PID %pid% SI existe.
) else (
    set "PID_STATUS=NO EXISTE"
    echo El PID %pid% NO existe.
)

echo PID verificado: %pid% - %PID_STATUS%>> "%LOG%"
echo.

echo =====================================
echo        LISTA GENERAL DE PROCESOS
echo =====================================
echo.

tasklist >> "%LOG%"

:: ==========================
::   EVIDENCIA FINAL
:: ==========================

echo.
echo =====================================
echo           EVIDENCIA FINAL
echo =====================================
echo Usuario: 
whoami
echo Nivel de privilegio: %ADMIN%
echo PID consultado: %pid%
echo Estado del PID: %PID_STATUS%
echo =====================================

(
echo.
echo =====================================
echo           RESUMEN FINAL
echo =====================================
echo Usuario: 
whoami
echo Nivel de privilegio: %ADMIN%
echo PID consultado: %pid%
echo Estado del PID: %PID_STATUS%
echo =====================================
) >> "%LOG%"

echo.
echo Evidencia guardada en: "%LOG%"
pause