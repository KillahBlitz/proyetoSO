#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIFI_SCRIPT="$SCRIPT_DIR/WifiPortLinux.sh"
ENDPOINT_SCRIPT="$SCRIPT_DIR/InitEndpoint.sh"

if [[ ! -f "$WIFI_SCRIPT" ]]; then
	echo "[ERROR] No existe: $WIFI_SCRIPT"
	exit 1
fi

if [[ ! -f "$ENDPOINT_SCRIPT" ]]; then
	echo "[ERROR] No existe: $ENDPOINT_SCRIPT"
	exit 1
fi

chmod +x "$WIFI_SCRIPT" "$ENDPOINT_SCRIPT"

echo "==============================================="
echo "  INICIANDO WifiPortLinux + InitEndpoint"
echo "==============================================="
echo

echo "[1/2] Levantando hotspot (requiere sudo)..."
if [[ "${EUID}" -eq 0 ]]; then
	"$WIFI_SCRIPT" &
else
	sudo "$WIFI_SCRIPT" &
fi
WIFI_PID=$!

sleep 2
if ! kill -0 "$WIFI_PID" 2>/dev/null; then
	echo "[ERROR] WifiPortLinux no pudo iniciar."
	exit 1
fi

cleanup() {
	echo
	echo "Deteniendo procesos..."
	if kill -0 "$WIFI_PID" 2>/dev/null; then
		kill -TERM "$WIFI_PID" 2>/dev/null || true
		wait "$WIFI_PID" 2>/dev/null || true
	fi
}

trap cleanup EXIT INT TERM

echo "[2/2] Levantando API..."
"$ENDPOINT_SCRIPT"
