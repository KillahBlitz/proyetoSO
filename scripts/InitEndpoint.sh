#!/usr/bin/env sh

set -e

echo "================================================"
echo "     LEVANTANDO API CON PAQUETE MALICIOSO"
echo "================================================"
echo

# Ir a la raíz del proyecto (desde scripts/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "[1/3] Activando entorno virtual..."
if [ -f ".venv/bin/activate" ]; then
	# shellcheck disable=SC1091
	. ".venv/bin/activate"
	echo "Entorno virtual activado correctamente"
else
	echo "No se encontro .venv/bin/activate. Crea el entorno virtual primero." >&2
	exit 1
fi
echo

echo "[2/3] Instalando dependencias..."
pip install -r assets/requirements.txt
echo

echo "[3/3] Levantando API..."
local_ip="$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for (i=1; i<=NF; i++) if ($i=="src") {print $(i+1); exit}}')"

if [ -z "$local_ip" ]; then
	local_ip="127.0.0.1"
fi

echo "La API estara disponible en: http://$local_ip:8000"
echo "Documentacion en: http://$local_ip:8000/docs"
echo "Presiona Ctrl+C para detener el servidor"
echo

uvicorn src.main.enpoints:app --host 0.0.0.0 --port 8000 --reload
