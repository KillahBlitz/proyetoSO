@echo off
setlocal enabledelayedexpansion

cls
color 0B
echo ================================================
echo   MONITOR DE MOBILE HOTSPOT
echo   Compatible con Intel Wi-Fi 6 AX200
echo ================================================
echo.
echo INSTRUCCIONES:
echo.
echo 1. Abre Configuracion de Windows (Win + I)
echo 2. Ve a: Red e Internet ^> Zona con cobertura inalambrica movil
echo 3. Activa: "Compartir mi conexion a Internet"
echo 4. Configura el nombre de red y contrasena
echo.
echo Una vez activado el hotspot, presiona cualquier tecla...
pause >nul

cls
color 0A
echo ================================================
echo   MONITOREANDO IPs CONECTADAS
echo   (Actualizando cada 5 segundos)
echo   Presiona Ctrl+C para detener
echo ================================================
echo.

:MONITOR
cls
echo ================================================
echo   MONITOR ACTIVO - %date% %time%
echo ================================================
echo.

echo [INFO] Detectando configuracion del hotspot...
ipconfig | findstr /C:"192.168.137" /C:"192.168.173"
echo.

echo [Tabla ARP completa - Todas las IPs detectadas:]
echo.
arp -a
echo.

echo ================================================
echo [DISPOSITIVOS CONECTADOS AL HOTSPOT:]
echo ================================================
echo.

set "count=0"

for /f "tokens=1,2" %%a in ('arp -a ^| findstr /R "192\.168\. 172\."') do (
    echo %%a | findstr /V "192.168.137.1 192.168.173.1 224.0.0 255.255" >nul
    if !errorlevel! equ 0 (
        echo   [DISPOSITIVO] IP: %%a   MAC: %%b
        set /a count+=1
    )
)

echo.
if !count! equ 0 (
    echo   [Sin dispositivos conectados aun]
    echo   [Esperando conexiones...]
    echo.
    echo   NOTA: Conecta un dispositivo a tu hotspot WiFi
) else (
    echo   Total de dispositivos: !count!
)

echo.
echo ================================================
echo Proxima actualizacion en 5 segundos...
timeout /t 5 /nobreak >nul
goto MONITOR
