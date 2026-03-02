#!/usr/bin/env bash

# Script para enviar mensaje a una máquina Windows o dispositivo Android

if [ $# -ne 2 ]; then
    echo "Uso: $0 <server_ip> <port>"
    exit 1
fi

server_ip=$1
port=$2

echo "Selecciona el tipo de dispositivo:"
echo "1. Windows"
echo "2. Android"
read -r choice

if [ "$choice" = "1" ]; then
    echo "Ingresa la IP de la máquina Windows a la que quieres enviar el mensaje:"
    read -r target_ip

    # Asumiendo usuario por defecto 'user', puedes cambiarlo si es necesario
    user="user"

    echo "Enviando mensaje 'HOLA MUNDO' a $target_ip (Windows)..."

    # Comando para mostrar notificación en Windows usando PowerShell y BurntToast con botón
    ssh "$user@$target_ip" "powershell -Command \"
try {
    Import-Module BurntToast -ErrorAction Stop;
    \$button = New-BTButton -Content 'Aceptar' -Arguments 'powershell.exe -Command \\\"Invoke-WebRequest -Uri http://$server_ip:$port/ -Method Get\\\"';
    New-BurntToastNotification -Text 'HOLA MUNDO' -Button \$button
} catch {
    Install-Module BurntToast -Force -Confirm:\$false -Scope CurrentUser;
    \$button = New-BTButton -Content 'Aceptar' -Arguments 'powershell.exe -Command \\\"Invoke-WebRequest -Uri http://$server_ip:$port/ -Method Get\\\"';
    New-BurntToastNotification -Text 'HOLA MUNDO' -Button \$button
}
\""

elif [ "$choice" = "2" ]; then
    echo "Ingresa la IP del dispositivo Android a la que quieres enviar el mensaje:"
    read -r target_ip

    # Asumiendo usuario por defecto 'user', puedes cambiarlo si es necesario
    user="user"

    echo "Enviando mensaje 'HOLA MUNDO' a $target_ip (Android)..."

    # Comando para mostrar notificación en Android usando Termux
    ssh "$user@$target_ip" "termux-notification -t 'HOLA MUNDO' -c 'Mensaje de alerta' --button1 'Aceptar' --button1-action 'curl http://$server_ip:$port/'"

else
    echo "Opción inválida. Saliendo."
    exit 1
fi

echo "Mensaje enviado."
