# ConectionWifiPort.py

## Lista de IPs Conectadas en Red WiFi - Versión Python

Este script Python escanea la red WiFi local para detectar dispositivos conectados, mide sus tiempos de respuesta (ping) y guarda los resultados en un archivo de texto ordenado por velocidad de respuesta.

### 🚀 Características Principales

- **Detección automática de red WiFi**: Identifica el nombre de la red WiFi conectada
- **Escaneo paralelo**: Utiliza múltiples hilos para escanear la red de manera eficiente
- **Medición de ping**: Mide el tiempo de respuesta de cada dispositivo en milisegundos
- **Ordenamiento inteligente**: Ordena los resultados por tiempo de ping (de menor a mayor)
- **Guardado automático**: Exporta los resultados a un archivo `resultados_ping.txt`
- **Compatibilidad**: Diseñado para Windows (soporte básico para otros sistemas)

### 📋 Requisitos del Sistema

- **Python**: Versión 3.6 o superior
- **Sistema Operativo**: Windows 10/11 (con soporte limitado para Linux/macOS)
- **Permisos**: Acceso a comandos del sistema (`netsh`, `ipconfig`, `ping`)

### 🛠️ Instalación

1. **Descargar el script**:
   ```bash
   # Clona o descarga ConectionWifiPort.py a tu directorio local
   ```

2. **Verificar instalación de Python**:
   ```bash
   python --version
   # Debe mostrar Python 3.6+ o superior
   ```

3. **Ejecutar el script**:
   ```bash
   python ConectionWifiPort.py
   ```

### 📖 Uso

#### Ejecución Básica
```bash
python ConectionWifiPort.py
```

#### ¿Qué hace el script?

1. **Detecta la red WiFi**: Muestra el nombre de la red conectada
2. **Obtiene tu IP local**: Identifica tu dirección IP en la red
3. **Escanea la red**: Busca hasta 10 dispositivos activos en paralelo
4. **Mide tiempos de ping**: Evalúa la latencia de cada dispositivo encontrado
5. **Ordena resultados**: Organiza los dispositivos por tiempo de respuesta
6. **Guarda archivo**: Crea `resultados_ping.txt` con los resultados

### 📊 Funcionalidades Detalladas

#### Detección de Red WiFi
- Utiliza `netsh wlan show interfaces` para obtener el SSID
- Compatible con redes WiFi de 2.4GHz y 5GHz

#### Escaneo de Red
- Escanea el rango completo de IPs (192.168.X.1-254)
- Procesamiento paralelo con hasta 50 hilos simultáneos
- Timeout configurable por dispositivo
- Límite máximo de 10 dispositivos para evitar sobrecarga

#### Medición de Ping
- Utiliza el comando `ping` nativo del sistema
- Soporte para salida en español e inglés
- Manejo de dispositivos que no responden
- Precisión en milisegundos

#### Archivo de Resultados
- Formato de texto plano legible
- Información de red y fecha de ejecución
- Lista ordenada por tiempo de ping
- Indicadores para dispositivos sin respuesta

### 📋 Ejemplo de Salida

#### Consola
```
================================================
   LISTA DE IPs CONECTADAS - RED WiFi
================================================

Conectando a red WiFi...
Red: MiRedWiFi
Tu IP: 192.168.1.100

LISTA DE IPs CONECTADAS (maximo 10):
====================================
Escaneando hasta 10 dispositivos en 192.168.1.0/24...

192.168.1.1
192.168.1.100
192.168.1.105
192.168.1.110

Midiendo tiempos de ping...
192.168.1.1 - 2 ms
192.168.1.100 - 1 ms
192.168.1.105 - 45 ms
192.168.1.110 - 156 ms

Total de dispositivos encontrados: 4

================================================
Archivo guardado: resultados_ping.txt
================================================
```

#### Archivo resultados_ping.txt
```
RESULTADOS DE PING - RED WiFi: MiRedWiFi
Total dispositivos: 4
================================================

LISTA DE IPs CONECTADAS (ordenadas por tiempo de ping):
=======================================================
1. 192.168.1.100 - 1 ms
2. 192.168.1.1 - 2 ms
3. 192.168.1.105 - 45 ms
4. 192.168.1.110 - 156 ms

Total de dispositivos encontrados: 4
```

### ⚙️ Configuración Avanzada

#### Modificar Número Máximo de Dispositivos
```python
MAX_IPS = 10  # Cambia este valor en la función main()
```

#### Ajustar Timeout de Ping
```python
# En la función measure_ping_time()
timeout = 1000  # Milisegundos
```

#### Cambiar Número de Hilos
```python
# En scan_network_parallel()
max_workers=50  # Hilos para escaneo

# En measure_ping_times()
max_workers=20  # Hilos para medición de ping
```

### 🔧 Notas Técnicas

- **Rendimiento**: El escaneo paralelo reduce significativamente el tiempo de ejecución
- **Precisión**: Los tiempos de ping pueden variar ligeramente entre ejecuciones
- **Limitaciones**: Solo funciona en redes locales (no atraviesa routers)
- **Seguridad**: No requiere permisos administrativos en Windows
- **Compatibilidad**: Optimizado para Windows; soporte básico para otros SO

### 🐛 Solución de Problemas

#### Error de Detección WiFi
- Verifica que estés conectado a una red WiFi
- Ejecuta como administrador si hay problemas de permisos

#### No se Encuentran Dispositivos
- Verifica que otros dispositivos estén encendidos y conectados
- Comprueba que no haya firewalls bloqueando ping
- Intenta ejecutar desde una terminal con privilegios elevados

#### Error de Codificación
- El script maneja automáticamente la codificación de texto
- Si hay problemas con caracteres especiales, verifica la configuración regional

### 📝 Historial de Versiones

- **v1.0**: Versión inicial con escaneo básico
- **v2.0**: Agregado procesamiento paralelo
- **v3.0**: Implementada medición de tiempos de ping y ordenamiento

### 👨‍💻 Autor

Desarrollado para análisis de redes locales.

### 📄 Licencia

Este proyecto es de uso libre para fines educativos y de diagnóstico de red.

---

**Nota**: Este script está diseñado para uso en redes locales privadas. Respeta las políticas de uso de red de tu organización.
