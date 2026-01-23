@echo off
setlocal enabledelayedexpansion
echo ================================================
echo      LEVANTANDO API CON PAQUETE MALICIOSO
echo ================================================
echo.

REM
cd /d "%~dp0.."

echo [1/3] Activando entorno virtual...
call .venv\Scripts\activate.bat
echo Entorno virtual activado correctamente
echo.

echo [2/3] Instalando dependencias...
pip install -r assets\requirements.txt
echo.

echo [3/3] Levantando API...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4" ^| findstr /v "127.0.0.1"') do (
    set "localIP=%%a"
    goto :foundIP
)
:foundIP
set "localIP=!localIP:~1!"
echo La API estara disponible en: http://!localIP!:8000
echo Documentacion en: http://!localIP!:8000/docs
echo Presiona Ctrl+C para detener el servidor
echo.
uvicorn src.main.enpoints:app --host 0.0.0.0 --port 8000 --reload