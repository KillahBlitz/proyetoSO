#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[ERROR]${NC} Ejecuta como root: sudo $0"
    exit 1
fi

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  HOTSPOT WIFI - Wifi-IPN${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Limpiar procesos previos
killall hostapd dnsmasq 2>/dev/null
systemctl stop systemd-resolved 2>/dev/null
sleep 1

# Detectar interfaz WiFi
WIFI=$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}' | head -n1)

if [ -z "$WIFI" ]; then
    WIFI=$(ls /sys/class/net/ | grep -E "^wlan|^wlp" | head -n1)
fi

if [ -z "$WIFI" ]; then
    echo -e "${RED}[ERROR]${NC} No se encontró interfaz WiFi"
    exit 1
fi

echo -e "${GREEN}[OK]${NC} Interfaz WiFi: ${WIFI}"
echo ""
echo -e "${GREEN}[OK]${NC} Verificación AP omitida (prueba)"
echo ""

# Configurar hostapd (red abierta)
cat > /tmp/hostapd.conf << EOF
interface=${WIFI}
driver=nl80211
ssid=Wifi-IPN
hw_mode=g
channel=1
auth_algs=1
wmm_enabled=0
ignore_broadcast_ssid=0
macaddr_acl=0
EOF

# Configurar dnsmasq (DHCP)
cat > /tmp/dnsmasq.conf << EOF
interface=${WIFI}
port=0
dhcp-range=192.168.50.50,192.168.50.150,255.255.255.0,1h
dhcp-option=3,192.168.50.1
dhcp-option=6,8.8.8.8
dhcp-authoritative
EOF

# Configurar interfaz
if command -v nmcli &> /dev/null; then
    nmcli device set ${WIFI} managed no 2>/dev/null
fi

killall wpa_supplicant 2>/dev/null

ip link set ${WIFI} down
ip addr flush ${WIFI}
ip addr add 192.168.50.1/24 dev ${WIFI}
ip link set ${WIFI} up
sleep 1

echo -e "${GREEN}[OK]${NC} IP configurada: 192.168.50.1"
echo ""

# Habilitar forwarding de IP y compartir internet
echo 1 > /proc/sys/net/ipv4/ip_forward
INTERFAZ_INET=$(ip route | grep default | awk '{print $5}' | head -n1)
if [ -n "$INTERFAZ_INET" ] && [ "$INTERFAZ_INET" != "$WIFI" ]; then
    iptables -t nat -A POSTROUTING -o $INTERFAZ_INET -j MASQUERADE
    iptables -A FORWARD -i $WIFI -o $INTERFAZ_INET -j ACCEPT
    iptables -A FORWARD -i $INTERFAZ_INET -o $WIFI -m state --state RELATED,ESTABLISHED -j ACCEPT
    echo -e "${GREEN}[OK]${NC} Internet compartido desde $INTERFAZ_INET"
else
    echo -e "${YELLOW}[INFO]${NC} No se detectó interfaz con internet para compartir"
fi
echo ""

# Abrir puerto DHCP
iptables -I INPUT -p udp --dport 67 -j ACCEPT 2>/dev/null
iptables -I OUTPUT -p udp --dport 68 -j ACCEPT 2>/dev/null

# Iniciar servicios
echo ""
echo -e "${YELLOW}Iniciando servicios...${NC}"

# Detener cualquier instancia previa
killall dnsmasq hostapd 2>/dev/null
sleep 1

# Liberar puerto DHCP si está ocupado
fuser -k 67/udp 2>/dev/null

# Iniciar dnsmasq
dnsmasq -C /tmp/dnsmasq.conf
sleep 1

# Verificar que dnsmasq inició
if ! pidof dnsmasq > /dev/null; then
    echo -e "${RED}[ERROR]${NC} No se pudo iniciar dnsmasq (DHCP)"
    exit 1
fi

# Iniciar hostapd
hostapd /tmp/hostapd.conf > /tmp/hostapd.log 2>&1 &
sleep 3

# Verificar que hostapd inició
if ! pidof hostapd > /dev/null; then
    echo -e "${RED}[ERROR]${NC} No se pudo iniciar hostapd"
    echo -e "${YELLOW}Log de hostapd:${NC}"
    cat /tmp/hostapd.log 2>/dev/null || echo "No hay log disponible"
    exit 1
else
    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}  ✓ RED ACTIVA${NC}"
    echo -e "${GREEN}================================${NC}"
    echo -e "📡 Red: ${GREEN}Wifi-IPN${NC}"
    echo -e "🔓 Tipo: ${GREEN}Pública (sin contraseña)${NC}"
    echo -e "🌐 IP: ${GREEN}192.168.50.1${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    echo -e "${BLUE}Conéctate desde cualquier dispositivo${NC}"
    echo -e "${BLUE}Presiona Ctrl+C para detener${NC}"
    echo ""
fi

# Función de limpieza
cleanup() {
    echo ""
    echo "Deteniendo..."
    killall hostapd dnsmasq 2>/dev/null
    ip addr flush ${WIFI}
    ip link set ${WIFI} down
    nmcli device set ${WIFI} managed yes 2>/dev/null
    systemctl start systemd-resolved 2>/dev/null
    iptables -t nat -D POSTROUTING -o $INTERFAZ_INET -j MASQUERADE 2>/dev/null
    iptables -D FORWARD -i $WIFI -o $INTERFAZ_INET -j ACCEPT 2>/dev/null
    iptables -D FORWARD -i $INTERFAZ_INET -o $WIFI -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null
    echo 0 > /proc/sys/net/ipv4/ip_forward
    echo "Finalizado"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Monitor de conexiones
while true; do
    CLIENTES=$(iw dev ${WIFI} station dump 2>/dev/null | grep -c "Station")
    echo -e "${BLUE}Clientes conectados: ${CLIENTES}${NC}"
    if [ "$CLIENTES" -gt 0 ]; then
        echo -e "${GREEN}MACs conectadas:${NC}"
        iw dev ${WIFI} station dump 2>/dev/null | grep "Station" | awk '{print $2}'
    fi
    sleep 10
done
