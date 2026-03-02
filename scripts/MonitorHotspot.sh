#!/bin/bash

# Script para monitorear dispositivos conectados al hotspot de NetworkManager
# NO requiere permisos de root para monitorear

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "========================================"
echo "  Monitor de Hotspot WiFi - Fedora"
echo "========================================"
echo ""

# Detectar interfaz del hotspot activo
echo "Detectando hotspot activo..."
HOTSPOT_INTERFACE=$(nmcli -t -f DEVICE,TYPE,STATE device | grep "wifi:connected" | cut -d: -f1)

if [ -z "$HOTSPOT_INTERFACE" ]; then
    echo -e "${RED}ERROR: No se detectó ningún hotspot activo.${NC}"
    echo ""
    echo "Por favor:"
    echo "1. Ve a Configuración → WiFi"
    echo "2. Activa 'Punto de Acceso' / 'Hotspot'"
    echo "3. Ejecuta este script nuevamente"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ Hotspot detectado en interfaz: $HOTSPOT_INTERFACE${NC}"
echo ""

# Función para obtener información de dispositivos conectados
show_connected_devices() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Dispositivos conectados al hotspot:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Contador de clientes
    CLIENT_COUNT=0
    
    # Obtener lista de estaciones (dispositivos conectados)
    STATIONS=$(sudo iw dev $HOTSPOT_INTERFACE station dump 2>/dev/null | grep "^Station" | awk '{print $2}')
    
    if [ -z "$STATIONS" ]; then
        echo -e "${YELLOW}No hay dispositivos conectados actualmente.${NC}"
        echo ""
        return
    fi
    
    # Para cada dispositivo conectado
    for MAC in $STATIONS; do
        CLIENT_COUNT=$((CLIENT_COUNT + 1))
        
        # Buscar IP en tabla ARP
        IP=$(arp -an | grep -i "$MAC" | awk '{print $2}' | tr -d '()')
        
        if [ -z "$IP" ]; then
            IP="Esperando IP..."
        fi
        
        # Obtener información adicional del dispositivo
        SIGNAL=$(sudo iw dev $HOTSPOT_INTERFACE station get $MAC 2>/dev/null | grep "signal:" | awk '{print $2}')
        RX_BYTES=$(sudo iw dev $HOTSPOT_INTERFACE station get $MAC 2>/dev/null | grep "rx bytes:" | awk '{print $3}')
        TX_BYTES=$(sudo iw dev $HOTSPOT_INTERFACE station get $MAC 2>/dev/null | grep "tx bytes:" | awk '{print $3}')
        
        # Convertir bytes a formato legible
        if [ -n "$RX_BYTES" ] && [ "$RX_BYTES" -gt 0 ]; then
            RX_MB=$(echo "scale=2; $RX_BYTES / 1048576" | bc 2>/dev/null)
            [ -z "$RX_MB" ] && RX_MB="0"
        else
            RX_MB="0"
        fi
        
        if [ -n "$TX_BYTES" ] && [ "$TX_BYTES" -gt 0 ]; then
            TX_MB=$(echo "scale=2; $TX_BYTES / 1048576" | bc 2>/dev/null)
            [ -z "$TX_MB" ] && TX_MB="0"
        else
            TX_MB="0"
        fi
        
        # Mostrar información del cliente
        echo -e "${GREEN}Cliente #$CLIENT_COUNT${NC}"
        echo -e "  MAC:    ${BLUE}$MAC${NC}"
        echo -e "  IP:     ${YELLOW}$IP${NC}"
        [ -n "$SIGNAL" ] && echo -e "  Señal:  $SIGNAL dBm"
        echo -e "  RX:     ${RX_MB} MB"
        echo -e "  TX:     ${TX_MB} MB"
        echo ""
    done
    
    echo -e "${GREEN}Total de dispositivos conectados: $CLIENT_COUNT${NC}"
    echo ""
}

# Verificar si tenemos permisos para iw
if ! sudo -n iw dev &>/dev/null; then
    echo -e "${YELLOW}Nota: Este script necesita permisos sudo para obtener información detallada.${NC}"
    echo "Por favor ingresa tu contraseña cuando se solicite."
    echo ""
    sudo -v
fi

# Modo monitor continuo (Presiona Ctrl+C para salir)
echo -e "${GREEN}Modo monitor continuo activado. Presiona Ctrl+C para salir.${NC}"
echo ""
sleep 2

while true; do
    clear
    echo "========================================"
    echo "  Monitor de Hotspot - Actualización en tiempo real"
    echo "========================================"
    echo -e "Interfaz: ${BLUE}$HOTSPOT_INTERFACE${NC}"
    echo -e "Última actualización: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    show_connected_devices
    sleep 3
done
