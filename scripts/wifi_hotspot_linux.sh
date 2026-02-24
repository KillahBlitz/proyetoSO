#!/bin/bash
################################################################################
# Script para crear un hotspot WiFi en Linux Fedora
# Propósito educativo - Monitoreo de conexiones
################################################################################

# Colores para la salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

# Verificar que se ejecuta como root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[ERROR]${NC} Este script debe ejecutarse como root (sudo)"
    exit 1
fi

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   CREADOR DE HOTSPOT WIFI - LINUX FEDORA${NC}"
echo -e "${BLUE}   Propósito educativo${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Paso 1: Detectar interfaz WiFi
echo -e "${YELLOW}[PASO 1]${NC} Detectando interfaz WiFi..."
WIFI_INTERFACE=$(iw dev | awk '$1=="Interface"{print $2}' | head -n1)

if [ -z "$WIFI_INTERFACE" ]; then
    echo -e "${RED}[ERROR]${NC} No se encontró ninguna interfaz WiFi"
    exit 1
fi

echo -e "${GREEN}[OK]${NC} Interfaz WiFi detectada: ${WIFI_INTERFACE}"
echo ""

# Paso 2: Configuración del hotspot
echo -e "${YELLOW}[PASO 2]${NC} Configuración del hotspot"
read -p "Nombre de la red WiFi (SSID): " SSID
read -p "Contraseña (mínimo 8 caracteres): " PASSWORD

if [ ${#PASSWORD} -lt 8 ]; then
    echo -e "${RED}[ERROR]${NC} La contraseña debe tener al menos 8 caracteres"
    exit 1
fi

echo ""
echo -e "${YELLOW}[PASO 3]${NC} Instalando paquetes necesarios (si no están instalados)..."

# Instalar hostapd y dnsmasq si no están instalados
dnf install -y hostapd dnsmasq >/dev/null 2>&1

echo -e "${GREEN}[OK]${NC} Paquetes verificados"
echo ""

# Paso 4: Configurar hostapd
echo -e "${YELLOW}[PASO 4]${NC} Configurando hostapd..."

cat > /tmp/hostapd.conf << EOF
interface=${WIFI_INTERFACE}
driver=nl80211
ssid=${SSID}
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=${PASSWORD}
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

echo -e "${GREEN}[OK]${NC} Configuración de hostapd creada"
echo ""

# Paso 5: Configurar dnsmasq (servidor DHCP)
echo -e "${YELLOW}[PASO 5]${NC} Configurando servidor DHCP..."

cat > /tmp/dnsmasq.conf << EOF
interface=${WIFI_INTERFACE}
dhcp-range=192.168.50.10,192.168.50.50,255.255.255.0,24h
dhcp-option=3,192.168.50.1
dhcp-option=6,8.8.8.8,8.8.4.4
server=8.8.8.8
log-queries
log-dhcp
bind-interfaces
EOF

echo -e "${GREEN}[OK]${NC} Configuración de DHCP creada"
echo ""

# Paso 6: Configurar interfaz de red
echo -e "${YELLOW}[PASO 6]${NC} Configurando interfaz de red..."

# Detener NetworkManager para esta interfaz
nmcli device set ${WIFI_INTERFACE} managed no 2>/dev/null

# Levantar interfaz y asignar IP
ip link set dev ${WIFI_INTERFACE} down
ip addr flush dev ${WIFI_INTERFACE}
ip addr add 192.168.50.1/24 dev ${WIFI_INTERFACE}
ip link set dev ${WIFI_INTERFACE} up

echo -e "${GREEN}[OK]${NC} Interfaz configurada con IP 192.168.50.1"
echo ""

# Paso 7: Habilitar forwarding (opcional, para compartir Internet)
echo 1 > /proc/sys/net/ipv4/ip_forward

# Paso 8: Iniciar servicios
echo -e "${YELLOW}[PASO 7]${NC} Iniciando hotspot WiFi..."
echo ""

# Detener instancias previas
killall hostapd dnsmasq 2>/dev/null
sleep 1

# Iniciar dnsmasq
dnsmasq -C /tmp/dnsmasq.conf -d --log-facility=/tmp/dnsmasq.log &
DNSMASQ_PID=$!

sleep 2

# Iniciar hostapd
hostapd /tmp/hostapd.conf -B -P /tmp/hostapd.pid

if [ $? -eq 0 ]; then
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}   HOTSPOT WIFI ACTIVO${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo -e "Nombre de red: ${GREEN}${SSID}${NC}"
    echo -e "Contraseña: ${GREEN}${PASSWORD}${NC}"
    echo -e "IP del servidor: ${GREEN}192.168.50.1${NC}"
    echo -e "Rango DHCP: ${GREEN}192.168.50.10 - 192.168.50.50${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo -e "${BLUE}Los dispositivos ya pueden conectarse.${NC}"
    echo -e "${BLUE}Presiona Ctrl+C para detener el monitoreo${NC}"
    echo ""
else
    echo -e "${RED}[ERROR]${NC} No se pudo iniciar hostapd"
    echo "Verifica que tu adaptador WiFi soporte modo AP"
    kill $DNSMASQ_PID 2>/dev/null
    exit 1
fi

# Paso 9: Monitorear conexiones
echo -e "${YELLOW}[MONITOREANDO CONEXIONES EN TIEMPO REAL]${NC}"
echo ""

# Función para limpiar al salir
cleanup() {
    echo ""
    echo -e "${YELLOW}[INFO]${NC} Deteniendo hotspot..."
    kill $DNSMASQ_PID 2>/dev/null
    killall hostapd 2>/dev/null
    ip addr flush dev ${WIFI_INTERFACE}
    ip link set dev ${WIFI_INTERFACE} down
    nmcli device set ${WIFI_INTERFACE} managed yes 2>/dev/null
    echo -e "${GREEN}[OK]${NC} Hotspot detenido"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Monitor infinito
while true; do
    clear
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}   MONITOR DE CONEXIONES - $(date '+%H:%M:%S')${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    echo -e "${GREEN}Hotspot activo:${NC} ${SSID}"
    echo ""
    echo -e "${YELLOW}[DISPOSITIVOS CONECTADOS]${NC}"
    echo ""
    
    # Leer el archivo de leases de dnsmasq
    if [ -f /var/lib/misc/dnsmasq.leases ]; then
        count=0
        while IFS= read -r line; do
            timestamp=$(echo $line | awk '{print $1}')
            mac=$(echo $line | awk '{print $2}')
            ip=$(echo $line | awk '{print $3}')
            hostname=$(echo $line | awk '{print $4}')
            
            if [ ! -z "$ip" ]; then
                echo -e "  ${GREEN}●${NC} IP: ${BLUE}$ip${NC}  |  MAC: $mac  |  Nombre: $hostname"
                count=$((count + 1))
            fi
        done < /var/lib/misc/dnsmasq.leases
        
        if [ $count -eq 0 ]; then
            echo "  [Sin dispositivos conectados aún]"
        else
            echo ""
            echo -e "  ${GREEN}Total: $count dispositivo(s)${NC}"
        fi
    else
        echo "  [Sin dispositivos conectados aún]"
    fi
    
    echo ""
    echo -e "${BLUE}================================================${NC}"
    echo -e "Actualizando cada 3 segundos... (Ctrl+C para salir)"
    
    sleep 3
done
