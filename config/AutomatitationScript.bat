@echo off

setlocal

net session >nul 2>&1
if %errorLevel% neq 0 (
    color 0C
    echo ================================================
    echo [ERROR] Este script requiere privilegios de administrador.
    echo ================================================
    echo.
    echo Ejecutando como administrador...
    echo.
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cls
color 0B
echo ================================================
echo   SCRIPT DE AUTOMATIZACION
echo   Ejecutando scripts en orden
echo ================================================
echo.
echo Este script ejecutara los siguientes archivos:
echo.
echo   1. ConectionWifiPort.bat
echo   2. EndpointExecution.bat
echo   3. WindowsMessageUpdate.bat
echo.
echo Cada uno se ejecutara como administrador.
echo.
echo ================================================
echo.
pause

set "SCRIPT_DIR=%~dp0"

echo.
color 0E
echo ================================================
echo [1/3] Ejecutando ConectionWifiPort.bat
echo ================================================
echo.
echo NOTA: Este script monitorea IPs continuamente.
echo Presiona Ctrl+C cuando termines para continuar con el siguiente.
echo.
pause

call "%SCRIPT_DIR%ConectionWifiPort.bat"

echo.
echo [INFO] ConectionWifiPort.bat finalizado.
echo.
timeout /t 3 /nobreak >nul

echo.
color 0A
echo ================================================
echo [2/3] Ejecutando EndpointExecution.bat
echo ================================================
echo.
pause

if not exist "%SCRIPT_DIR%EndpointExecution.bat" (
    if exist "%SCRIPT_DIR%EndpointExcecution.bat" (
        set "ENDPOINT_SCRIPT=%SCRIPT_DIR%EndpointExcecution.bat"
    ) else (
        color 0C
        echo [ERROR] No se encuentra EndpointExecution.bat o EndpointExcecution.bat
        pause
        exit /b 1
    )
) else (
    set "ENDPOINT_SCRIPT=%SCRIPT_DIR%EndpointExecution.bat"
)

call "%ENDPOINT_SCRIPT%"

echo.
echo [INFO] EndpointExecution.bat finalizado.
echo.
timeout /t 3 /nobreak >nul

echo.
color 0D
echo ================================================
echo [3/3] Ejecutando WindowsMessageUpdate.bat
echo ================================================
echo.
pause

call "%SCRIPT_DIR%WindowsMessageUpdate.bat"

echo.
echo [INFO] WindowsMessageUpdate.bat finalizado.
echo.
timeout /t 3 /nobreak >nul

cls
color 0A
echo ================================================
echo   PROCESO COMPLETADO
echo ================================================
echo.
echo Todos los scripts se han ejecutado correctamente:
echo.
echo   [OK] ConectionWifiPort.bat
echo   [OK] EndpointExecution.bat
echo   [OK] WindowsMessageUpdate.bat
echo.
echo ================================================
echo.
echo Presiona cualquier tecla para salir...
pause >nul
exit /b 0
