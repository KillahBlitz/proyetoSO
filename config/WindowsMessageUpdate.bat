@echo off
echo Mostrando notificacion toast...
powershell -Command "try { Import-Module BurntToast -ErrorAction Stop; $header = New-BTHeader -Id 'defender' -Title 'Windows Defender'; New-BurntToastNotification -Header $header -Text 'actualizacion URGENTE, pulsa aqui...' } catch { Install-Module BurntToast -Force -Confirm:$false -Scope CurrentUser; $header = New-BTHeader -Id 'defender' -Title 'Windows Defender'; New-BurntToastNotification -Header $header -Text 'Windows Defender requiere una actualización URGENTE, pulsa aquí...' }"
echo Notificación enviada.
