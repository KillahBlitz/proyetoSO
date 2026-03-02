#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}   MONITOR DE RED LOCAL${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Detectar interfaz de red principal (con gateway)
INTERFAZ_INET=$(ip route | grep default | awk '{print $5}' | head -n1)

if [ -z "$INTERFAZ_INET" ]; then
    echo -e "${RED}[ERROR]${NC} No se detectó interfaz de red conectada"
    exit 1
fi

echo -e "${GREEN}[OK]${NC} Interfaz de red: ${INTERFAZ_INET}"
echo ""

# Obtener IP local y subred
LOCAL_IP=$(ip -4 addr show $INTERFAZ_INET | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
SUBNET=$(ip -4 route show dev $INTERFAZ_INET | grep -oP '\d+(\.\d+){3}/\d+' | head -n1)

if [ -z "$LOCAL_IP" ] || [ -z "$SUBNET" ]; then
    echo -e "${RED}[ERROR]${NC} No se pudo obtener información de red"
    exit 1
fi

echo -e "${GREEN}[OK]${NC} IP local: ${LOCAL_IP}"
echo -e "${GREEN}[OK]${NC} Subred: ${SUBNET}"
echo ""

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  DISPOSITIVOS CONECTADOS${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Función de limpieza
cleanup() {
    echo ""
    echo "Monitor detenido"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Monitor de red local
while true; do
    # Limpiar pantalla para actualizar
    clear
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}   MONITOR DE RED LOCAL${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    echo -e "${GREEN}Interfaz: ${INTERFAZ_INET}${NC}"
    echo -e "${GREEN}IP local: ${LOCAL_IP}${NC}"
    echo -e "${GREEN}Subred: ${SUBNET}${NC}"
    echo ""

    # Poblar tabla ARP haciendo ping a la subred
    echo -e "${YELLOW}Escaneando red para detectar dispositivos...${NC}"
    SUBNET_BASE=$(echo $SUBNET | cut -d'/' -f1 | sed 's/\.[0-9]*$//')
    BROADCAST="${SUBNET_BASE}.255"
    ping -c 1 -b $BROADCAST > /dev/null 2>&1 &
    sleep 2  # Esperar a que se pueble la tabla ARP

    # Obtener dispositivos de la tabla ARP
    DISPOSITIVOS=$(ip neigh show dev $INTERFAZ_INET 2>/dev/null | wc -l)
    echo -e "${BLUE}Dispositivos detectados: ${DISPOSITIVOS}${NC}"
    echo ""

    if [ "$DISPOSITIVOS" -gt 0 ]; then
        echo -e "${GREEN}Lista de dispositivos:${NC}"
        echo -e "${YELLOW}IP Address\t\tMAC Address\t\tEstado${NC}"
        echo "------------------------------------------------------------"
        ip neigh show dev $INTERFAZ_INET 2>/dev/null | awk '{
            ip=$1; mac=$5; state=$6;
            if (state == "REACHABLE" || state == "STALE" || state == "DELAY" || state == "PERMANENT") {
                printf "%-20s %-20s %s\n", ip, mac, state
            }
        }'
    else
        echo -e "${YELLOW}No se detectaron dispositivos en la red local${NC}"
    fi

    echo ""
    echo -e "${BLUE}Presiona Ctrl+C para detener${NC}"
    echo -e "${BLUE}Actualización cada 10 segundos...${NC}"
    sleep 10
done