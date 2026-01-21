# Proyecto de Escaneo de Red WiFi

## Descripción
Script en Batch para Windows que detecta la red WiFi conectada, escanea dispositivos activos en la red local y ordena los resultados por tiempo de respuesta de ping.

## Funcionalidades Implementadas

### ✅ Funcionalidades Completadas
- **Detección de Red WiFi**: Identifica automáticamente la red WiFi conectada usando `netsh wlan show interfaces`
- **Obtención de IP Local**: Extrae la dirección IP local usando `ipconfig`
- **Cálculo de Subred**: Determina el rango de red (subnet) para el escaneo
- **Escaneo de Dispositivos**: Busca dispositivos activos mediante ping en el rango 1-254 de la subred
- **Límite de Dispositivos**: Configurable para mostrar máximo N dispositivos (actualmente 10)
- **Medición de Tiempos de Ping**: Mide el tiempo de respuesta de cada dispositivo encontrado
- **Ordenamiento por Ping**: Ordena los dispositivos de menor a mayor tiempo de respuesta y guarda en archivo
- **Interfaz de Usuario**: Mensajes claros y coloridos para mejor experiencia


## Desarrollo del Script - Paso a Paso

### Versión 1: Detección Básica de Red
```batch
@echo off
setlocal enabledelayedexpansion

echo Conectando a red WiFi...
for /f "tokens=2 delims=:" %%a in ('netsh wlan show interfaces ^| findstr /i "SSID"') do (
    set "ssid=%%a"
    goto :foundSSID
)
:foundSSID
set "ssid=!ssid:~1!"
echo Red: !ssid!
```

**Explicación:**
- `netsh wlan show interfaces`: Comando para mostrar información de interfaces WiFi
- `findstr /i "SSID"`: Busca la línea que contiene "SSID" (case insensitive)
- `tokens=2 delims=:`: Extrae el segundo token separado por `:`
- `!ssid:~1!`: Remueve el primer carácter (espacio) del nombre de la red

### Versión 2: Obtención de IP Local
```batch
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4" ^| findstr /v "127.0.0.1"') do (
    set "localIP=%%a"
    goto :foundIP
)
:foundIP
set "localIP=!localIP:~1!"
echo Tu IP: !localIP!
```

**Explicación:**
- `ipconfig`: Muestra configuración de red
- `findstr /i "IPv4"`: Busca líneas con "IPv4"
- `findstr /v "127.0.0.1"`: Excluye la IP de loopback
- `tokens=2 delims=:`: Extrae la dirección IP

### Versión 3: Cálculo de Subred
```batch
for /f "tokens=1,2,3 delims=." %%a in ("!localIP!") do (
    set subnet=%%a.%%b.%%c
)
```

**Explicación:**
- Divide la IP en octetos usando `.` como delimitador
- Crea la subred tomando los primeros 3 octetos

### Versión 4: Escaneo de Dispositivos
```batch
set count=0
for /L %%i in (1,1,254) do (
    if !count! lss !maxIPs! (
        ping -n 1 -w 100 !subnet!.%%i >nul 2>&1
        if !errorlevel! equ 0 (
            set /a count+=1
            set "foundIPs=!foundIPs! !subnet!.%%i"
            echo !subnet!.%%i
        )
    )
)
```

**Pasos detallados:**
1. **Inicialización del contador**: Establece `count=0` para rastrear dispositivos encontrados.
2. **Bucle de escaneo**: Itera desde 1 hasta 254 para cubrir todas las IPs posibles en la subred.
3. **Verificación de límite**: Comprueba si el contador es menor que `maxIPs` (10) antes de continuar.
4. **Envío de ping**: Ejecuta `ping -n 1 -w 100` a la IP actual (`!subnet!.%%i`) con 1 paquete y timeout de 100ms.
5. **Redirección de salida**: `>nul 2>&1` suprime la salida del ping para no mostrar en pantalla.
6. **Verificación de respuesta**: Si `errorlevel` es 0 (ping exitoso), incrementa contador y guarda la IP.
7. **Almacenamiento de IPs**: Agrega la IP a la variable `foundIPs` para uso posterior.
8. **Salida en pantalla**: Muestra la IP encontrada al usuario.
9. **Condición de salida**: Si se alcanza el límite, sale del bucle con `goto :scan_complete`.

**Explicación:**
- `for /L %%i in (1,1,254)`: Itera del 1 al 254
- `ping -n 1 -w 100`: Un ping con 1 paquete y timeout de 100ms
- `>nul 2>&1`: Redirige salida estándar y errores a null
- `!errorlevel! equ 0`: Verifica si el ping fue exitoso
- `set "foundIPs=!foundIPs! !subnet!.%%i"`: Concatena IPs encontradas

### Versión 5: Medición y Ordenamiento por Ping
```batch
if !count! gtr 0 (
    echo Midiendo tiempos de ping a los dispositivos encontrados...
    set "tempFile=%scriptDir%temp_ping.txt"
    set "sortedFile=%scriptDir%sorted_ping.txt"
    for %%p in (!foundIPs!) do (
        for /f "tokens=5 delims== " %%t in ('ping -n 1 -w 1000 %%p ^| find "tiempo="') do (
            set "pingTime=%%t"
            set "pingTime=!pingTime:ms=!"
            echo !pingTime! %%p >> "!tempFile!"
        )
    )
    powershell -command "Get-Content '!tempFile!' | Sort-Object {[int]($_.Split()[0])} | Out-File '!sortedFile!' -Encoding ASCII"
    echo IPs ordenadas por tiempo de ping ^(menor a mayor^): > "!outputFile!"
    for /f "tokens=*" %%l in (!sortedFile!) do (
        for /f "tokens=1,*" %%a in ("%%l") do (
            echo %%b - %%a ms >> "!outputFile!"
        )
    )
    del "!tempFile!" 2>nul
    del "!sortedFile!" 2>nul
    echo Resultados guardados en !outputFile!
)
```

**Pasos detallados:**
1. **Verificación de dispositivos encontrados**: Solo ejecuta si `count > 0`.
2. **Mensaje de progreso**: Informa al usuario que se están midiendo tiempos.
3. **Definición de archivos temporales**: Establece rutas para `tempFile` y `sortedFile`.
4. **Bucle de medición por IP**: Itera sobre cada IP en `foundIPs`.
5. **Envío de ping de medición**: Ejecuta `ping -n 1 -w 1000` con timeout de 1 segundo.
6. **Filtrado de salida**: Usa `find "tiempo="` para localizar la línea con el tiempo (en español).
7. **Extracción del tiempo**: `tokens=5 delims== ` obtiene el valor del tiempo.
8. **Limpieza del tiempo**: Remueve "ms" del final para obtener solo el número.
9. **Almacenamiento temporal**: Escribe "tiempo IP" en `tempFile`.
10. **Ordenamiento con PowerShell**: Usa `Sort-Object` para ordenar numéricamente por tiempo.
11. **Preparación del archivo de salida**: Escribe encabezado en `outputFile`.
12. **Formateo de resultados**: Lee `sortedFile` y escribe "IP - tiempo ms" en `outputFile`.
13. **Limpieza**: Elimina archivos temporales.
14. **Confirmación**: Muestra mensaje de que los resultados están guardados.

## Comandos y Equivalentes en Bash

| Comando Batch | Equivalente Bash | Descripción |
|---------------|------------------|-------------|
| `netsh wlan show interfaces` | `iwconfig` o `nmcli device wifi` | Mostrar interfaces WiFi |
| `ipconfig` | `ip addr` o `ifconfig` | Configuración de red |
| `ping -n 1 -w 100` | `ping -c 1 -W 1` | Ping con count y timeout |
| `for /L %%i in (1,1,254)` | `for i in {1..254}` | Bucle numérico |
| `setlocal enabledelayedexpansion` | N/A (Bash expande automáticamente) | Expansión retardada de variables |
| `!variable!` | `$variable` | Expansión de variable |

## Mejoras Implementadas

### 1. **Límite de Dispositivos**
- **Problema**: Escanear 254 IPs toma mucho tiempo
- **Solución**: Límite configurable (actualmente 10 dispositivos)
- **Beneficio**: Respuesta más rápida, mejor UX
- **Implementación**: Variable `maxIPs` y condición `if !count! lss !maxIPs!`

### 2. **Detección Robusta de Red**
- **Problema**: Nombres de red con espacios o caracteres especiales
- **Solución**: Limpieza de espacios y caracteres problemáticos
- **Beneficio**: Compatibilidad con diferentes nombres de red
- **Implementación**: `!ssid:~1!` para remover espacios iniciales

### 3. **Timeout Optimizado**
- **Problema**: Ping lento bloquea el escaneo
- **Solución**: Timeout de 100ms por dispositivo
- **Beneficio**: Escaneo más rápido
- **Implementación**: `ping -n 1 -w 100`

### 4. **Interfaz Colorida**
- **Problema**: Salida monótona difícil de leer
- **Solución**: `color 0A` (fondo negro, texto verde)
- **Beneficio**: Mejor experiencia visual

### 5. **Medición y Ordenamiento por Ping**
- **Problema**: Lista de IPs sin información de rendimiento
- **Solución**: Medir tiempo de respuesta y ordenar de menor a mayor
- **Beneficio**: Identificar dispositivos más cercanos/rápidos
- **Implementación**: Ping adicional, parsing de tiempo, ordenamiento con PowerShell
- **Pasos**:
  - Recopilar IPs durante escaneo
  - Medir ping con timeout extendido (1000ms)
  - Extraer tiempo usando `find "tiempo="` (compatible con español)
  - Ordenar numéricamente usando PowerShell `Sort-Object`
  - Formatear y guardar en archivo de texto

## Mejoras Futuras

### � Procesamiento Paralelo
**Objetivo:** Escanear múltiples IPs simultáneamente para reducir tiempo total.

**Implementación Planificada:**
- Usar `start /b` para procesos en background
- Implementar con PowerShell para mejor control de hilos
- Usar GNU Parallel si disponible en Windows

**Beneficios:**
- Reducción significativa del tiempo de escaneo
- Mejor aprovechamiento de recursos del sistema

### 📊 Exportación de Resultados
**Objetivo:** Guardar resultados en formatos estructurados (JSON/CSV).

**Implementación Planificada:**
```batch
:: Generar JSON
echo { "devices": [ >> results.json
for %%i in (!foundIPs!) do (
    echo   { "ip": "%%i", "ping": "!pingTime!" }, >> results.json
)
echo ] } >> results.json
```

**Beneficios:**
- Análisis posterior con herramientas externas
- Integración con dashboards de red
- Historial de escaneos para comparación

### 🔍 Detección de Servicios
**Objetivo:** Identificar qué servicios corren en cada IP (puertos abiertos).

**Implementación Planificada:**
- Escaneo básico de puertos comunes (80, 443, 22, etc.)
- Uso de `telnet` o herramientas externas
- Reporte de servicios detectados

### 📈 Estadísticas de Red
**Objetivo:** Proporcionar métricas adicionales de la red.

**Métricas Planificadas:**
- Latencia promedio
- Pérdida de paquetes
- Topología estimada
- Dispositivos por fabricante (basado en MAC)

## Uso del Script

1. **Ejecutar**: `ConectionWifiPort.bat`
2. **Detección de Red**: El script identifica automáticamente la red WiFi conectada y muestra su nombre
3. **Obtención de IP**: Extrae y muestra la dirección IP local del dispositivo
4. **Cálculo de Subred**: Determina el rango de red basado en la IP local
5. **Escaneo**: Busca hasta 10 dispositivos activos mediante ping en el rango 1-254
6. **Medición de Ping**: Para cada dispositivo encontrado, mide el tiempo de respuesta
7. **Ordenamiento**: Ordena los dispositivos de menor a mayor tiempo de ping
8. **Resultado**: Muestra lista en pantalla y guarda resultados ordenados en `resultados_ping.txt`
9. **Tiempo Total**: Aproximadamente 10-20 segundos (dependiendo de la red)

## Requisitos
- Windows con Command Prompt
- Conexión WiFi activa
- Permisos para ejecutar comandos de red

## Troubleshooting

### Problema: "La sintaxis del comando no es correcta"
**Causa:** Variables con caracteres especiales en redirección
**Solución:** Usar variables temporales para construir comandos
**Ejemplo:** `set "tempFile=%scriptDir%temp.txt"` en lugar de usar directamente

### Problema: Escaneo lento
**Causa:** Timeout alto por dispositivo o límite bajo
**Solución:** 
- Reducir timeout: Cambiar `-w 100` a `-w 50`
- Aumentar límite: Cambiar `set maxIPs=10` a `set maxIPs=20`

### Problema: No detecta dispositivos
**Causa:** Firewall bloqueando ping ICMP
**Solución:** 
- Verificar configuración de firewall de Windows
- Ejecutar como administrador
- Algunos dispositivos no responden a ping por configuración

### Problema: Ordenamiento no funciona
**Causa:** PowerShell no disponible o archivos temporales no creados
**Solución:** 
- Verificar que PowerShell esté instalado
- Comprobar permisos de escritura en el directorio
- Revisar que `temp_ping.txt` se cree correctamente

### Problema: Tiempos de ping inconsistentes
**Causa:** Variaciones en la red o dispositivos con respuesta lenta
**Solución:** 
- Aumentar timeout: Cambiar `-w 1000` a `-w 2000`
- Repetir medición para promediar tiempos

### Problema: Archivo de resultados vacío
**Causa:** Ningún dispositivo respondió al ping de medición
**Solución:** 
- Verificar conectividad de red
- Comprobar que los dispositivos estén activos
- Revisar firewall en dispositivos objetivo

## Contribución
Para mejoras o reportes de bugs:
1. Probar el script thoroughly en diferentes entornos de red
2. Documentar cualquier cambio en esta sección del README
3. Incluir ejemplos de uso y casos de prueba
4. Verificar compatibilidad con diferentes versiones de Windows
5. Considerar impacto en rendimiento antes de implementar paralelismo</content>
<parameter name="filePath">c:\Users\fach7\Downloads\proyetoSO\README.md
