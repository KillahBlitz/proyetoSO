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
echo "IMPORTANTE: Ejecuta este script desde un terminal del SISTEMA REAL (no VS Code)"
echo "para que pueda acceder a las interfaces de red del hotspot."
echo

# Verificar si hay un hotspot activo de NetworkManager
HOTSPOT_INTERFACE=$(nmcli -t -f DEVICE,TYPE,STATE device 2>/dev/null | grep "wifi:connected" | cut -d: -f1)

if [ -n "$HOTSPOT_INTERFACE" ]; then
    # Obtener IP del hotspot de NetworkManager
    HOTSPOT_IP=$(ip -4 addr show $HOTSPOT_INTERFACE 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1)
    if [ -n "$HOTSPOT_IP" ]; then
        local_ip="$HOTSPOT_IP"
        echo "HOTSPOT DE FEDORA DETECTADO: La API escuchara en $HOTSPOT_IP (interfaz $HOTSPOT_INTERFACE)"
        echo "Accede desde dispositivos conectados al hotspot de Fedora"
    else
        local_ip="0.0.0.0"
        echo "HOTSPOT DETECTADO pero no se pudo obtener IP, usando todas las interfaces"
    fi
else
    local_ip="0.0.0.0"
    echo "HOTSPOT NO DETECTADO: La API escuchara en todas las interfaces"
    echo "Activa el hotspot desde Configuración → WiFi → Punto de Acceso"
fi

echo "La API estara disponible en: http://$local_ip:8000"
echo "Documentacion en: http://$local_ip:8000/docs"
echo "Presiona Ctrl+C para detener el servidor"
echo

uvicorn src.main.enpoints:app --host $local_ip --port 8000 --reload
