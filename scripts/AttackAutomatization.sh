#!/bin/bash

# Script de automatización de ataque
# Abre dos ventanas de kitty: una para monitorear el hotspot y otra para el endpoint

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "========================================"
echo "  Automatización de Ataque"
echo "========================================"
echo ""

# Verificar que kitty esté instalado
if ! command -v kitty &> /dev/null; then
    echo -e "${RED}ERROR: kitty no está instalado.${NC}"
    echo "Instala kitty con: sudo dnf install kitty"
    exit 1
fi

# Obtener el directorio del script actual
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Verificar que los scripts existen
if [ ! -f "$SCRIPT_DIR/MonitorHotspot.sh" ]; then
    echo -e "${RED}ERROR: No se encontró MonitorHotspot.sh${NC}"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/InitEndpoint.sh" ]; then
    echo -e "${RED}ERROR: No se encontró InitEndpoint.sh${NC}"
    exit 1
fi

# Verificar permisos de ejecución
chmod +x "$SCRIPT_DIR/MonitorHotspot.sh" 2>/dev/null
chmod +x "$SCRIPT_DIR/InitEndpoint.sh" 2>/dev/null

echo -e "${GREEN}✓ Scripts encontrados${NC}"
echo ""
echo -e "${YELLOW}Abriendo ventanas...${NC}"
echo ""
echo "1. Monitor de Hotspot (ventana 1)"
echo "2. Endpoint (ventana 2)"
echo ""

# Abrir ventana 1: Monitor de Hotspot
echo -e "${BLUE}Iniciando MonitorHotspot.sh...${NC}"
kitty --title "Monitor Hotspot" -e bash -c "cd '$PROJECT_ROOT' && sudo '$SCRIPT_DIR/MonitorHotspot.sh'" &
MONITOR_PID=$!
sleep 1

# Abrir ventana 2: InitEndpoint
echo -e "${BLUE}Iniciando InitEndpoint.sh...${NC}"
kitty --title "Endpoint" -e bash -c "cd '$PROJECT_ROOT' && '$SCRIPT_DIR/InitEndpoint.sh'; exec bash" &
ENDPOINT_PID=$!
sleep 1

echo ""
echo -e "${GREEN}✓ Ventanas abiertas exitosamente${NC}"
echo ""
echo "PIDs:"
echo "  Monitor Hotspot: $MONITOR_PID"
echo "  Endpoint: $ENDPOINT_PID"
echo ""
echo -e "${YELLOW}Presiona Ctrl+C para cerrar este script (las ventanas permanecerán abiertas)${NC}"
echo ""

# Esperar a que termine (opcional)
wait
