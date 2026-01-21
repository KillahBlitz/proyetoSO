@echo off
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
echo La API estara disponible en: http://127.0.0.1:8000
echo Documentacion en: http://127.0.0.1:8000/docs
echo Presiona Ctrl+C para detener el servidor
echo.
uvicorn src.main.enpoints:app --reload