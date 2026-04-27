#!/usr/bin/env sh

set -e

echo "================================================"
echo "     LEVANTANDO API Y FRONTEND EN ACCESS POINT"
echo "================================================"
echo

# Ir a la raíz del proyecto (desde scripts/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "[1/5] Desactivando firewall..."
# SI HAY PROBLEMAS CON EL FIREWALL, DESCOMENTAR ESTAS LINEAS PARA PERMITIR TODO EL TRÁFICO EN LA INTERFAZ DEL HOTSPOT
#sudo firewall-cmd --zone=trusted --add-interface=wlp1s0 --permanent
#sudo firewall-cmd --reload
#echo

echo "[2/5] Activando entorno virtual..."
if [ -f ".venv/bin/activate" ]; then
	# shellcheck disable=SC1091
	. ".venv/bin/activate"
	echo "Entorno virtual activado correctamente"
else
	echo "No se encontro .venv/bin/activate. Crea el entorno virtual primero." >&2
	exit 1
fi
echo

echo "[3/5] Instalando dependencias..."
pip install -r assets/requirements.txt
echo

echo "[4/5] Detectando Access Point activo..."
echo

# Detectar hotspot activo creado por NetworkManager
HOTSPOT_INTERFACE=$(nmcli -t -f DEVICE,TYPE,STATE device 2>/dev/null | grep "wifi:connected" | cut -d: -f1)

if [ -n "$HOTSPOT_INTERFACE" ]; then
    HOTSPOT_IP=$(ip -4 addr show "$HOTSPOT_INTERFACE" 2>/dev/null \
        | grep -oP '(?<=inet\s)\d+(\.\d+){3}' \
        | head -n1)

    if [ -n "$HOTSPOT_IP" ]; then
        local_ip="$HOTSPOT_IP"
        echo "HOTSPOT DETECTADO"
        echo "Interfaz: $HOTSPOT_INTERFACE"
        echo "IP del Access Point: $HOTSPOT_IP"
        echo "La API solo sera accesible desde dispositivos conectados a este hotspot"
    else
        echo "No se pudo obtener la IP del hotspot. Abortando por seguridad."
        exit 1
    fi
else
    echo "No hay hotspot activo."
    echo "La API solo escuchara en localhost por seguridad."
    local_ip="127.0.0.1"
fi

echo
echo "API disponible en: http://$local_ip:8000"
echo "Documentacion en: http://$local_ip:8000/docs"
echo "Presiona Ctrl+C para detener el servidor"
echo

ENDPOINT_INFO_FILE="/tmp/endpoint_info.txt"
echo "IP=$local_ip" > "$ENDPOINT_INFO_FILE"
echo "PORT=8000" >> "$ENDPOINT_INFO_FILE"
echo "URL=http://$local_ip:8000" >> "$ENDPOINT_INFO_FILE"
chmod 644 "$ENDPOINT_INFO_FILE"

echo
echo "[5/5] Iniciando frontend..."
cd "$PROJECT_ROOT/frontend"
echo "Instalando dependencias de npm..."
npm install
echo "Iniciando servidor de desarrollo en $local_ip:3000"
npm run dev -- --host 0.0.0.0 --port 3000 &
echo "Frontend disponible en: http://$local_ip:3000"
echo "FRONTEND_URL=http://$local_ip:3000" >> "$ENDPOINT_INFO_FILE"


export PYTHONPATH="$PROJECT_ROOT"
uvicorn src.main.enpoints:app --host "$local_ip" --port 8000 --reload