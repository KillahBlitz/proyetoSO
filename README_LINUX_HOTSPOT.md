# 🐧 Hotspot WiFi en Linux Fedora - Guía Completa

## ✅ Ventajas de usar Linux vs Windows:

**Linux Fedora es MUCHO mejor para esto porque:**
- ✅ `hostapd` funciona nativamente sin problemas de compatibilidad
- ✅ No hay restricciones con adaptadores WiFi 6 
- ✅ Control total sobre la configuración
- ✅ Más educativo (ves cómo funciona todo internamente)
- ✅ Monitoreo de IPs inmediato y preciso con `dnsmasq`

**En Windows 11:**
- ❌ Adaptadores WiFi 6 no soportan "hosted network"
- ❌ Mobile Hotspot tiene limitaciones
- ❌ Difícil ver las IPs en tiempo real
- ❌ Menos control sobre la configuración

---

## 🚀 Cómo usar el script en Fedora

### Paso 1: Copiar el script a tu sistema Linux

Transfiere el archivo `wifi_hotspot_linux.sh` a tu sistema Fedora.

### Paso 2: Dar permisos de ejecución

```bash
chmod +x wifi_hotspot_linux.sh
```

### Paso 3: Ejecutar como root

```bash
sudo ./wifi_hotspot_linux.sh
```

### Paso 4: Configurar

El script te pedirá:
1. **Nombre de la red WiFi (SSID)**: Por ejemplo `Mi_Hotspot_Educativo`
2. **Contraseña**: Mínimo 8 caracteres

### Paso 5: ¡Listo!

El script automáticamente:
- ✅ Crea el hotspot WiFi
- ✅ Inicia el servidor DHCP
- ✅ Asigna IPs automáticamente (192.168.50.10 - 192.168.50.50)
- ✅ Muestra las IPs conectadas en tiempo real
- ✅ Actualiza cada 3 segundos

### Paso 6: Detener

Presiona **Ctrl+C** para detener el hotspot y limpiar la configuración.

---

## 📊 ¿Qué verás en pantalla?

```
================================================
   MONITOR DE CONEXIONES - 15:30:45
================================================

Hotspot activo: Mi_Hotspot_Educativo

[DISPOSITIVOS CONECTADOS]

  ● IP: 192.168.50.10  |  MAC: aa:bb:cc:dd:ee:ff  |  Nombre: Smartphone-1
  ● IP: 192.168.50.11  |  MAC: 11:22:33:44:55:66  |  Nombre: Laptop-2

  Total: 2 dispositivo(s)

================================================
Actualizando cada 3 segundos... (Ctrl+C para salir)
```

---

## 🔧 Requisitos

- **Fedora** (cualquier versión reciente)
- **Adaptador WiFi que soporte modo AP** (la mayoría lo soportan)
- **Permisos de root** (sudo)

Los paquetes `hostapd` y `dnsmasq` se instalan automáticamente si no los tienes.

---

## 📝 Verificar si tu adaptador soporta modo AP

```bash
iw list | grep -A 10 "Supported interface modes"
```

Busca que diga `* AP` en la lista. Si aparece, tu adaptador funciona perfectamente.

---

## 🎓 Conceptos educativos que aprenderás

1. **hostapd**: Demonio que convierte tu WiFi en Access Point
2. **dnsmasq**: Servidor DHCP que asigna IPs automáticamente
3. **nl80211**: Driver moderno de WiFi en Linux
4. **DHCP leases**: Archivo donde se registran las IPs asignadas
5. **IP forwarding**: Cómo compartir la conexión a Internet (opcional)

---

## 🔍 Archivos importantes

- **Configuración hostapd**: `/tmp/hostapd.conf`
- **Configuración dnsmasq**: `/tmp/dnsmasq.conf`
- **Log de dnsmasq**: `/tmp/dnsmasq.log`
- **Leases DHCP**: `/var/lib/misc/dnsmasq.leases`

Puedes revisar estos archivos mientras el script corre para entender cómo funciona todo.

---

## 💡 Compartir Internet (opcional)

Si quieres que los dispositivos conectados tengan acceso a Internet, necesitas configurar NAT. El script ya habilita `ip_forward`, solo falta agregar reglas de iptables:

```bash
# Reemplaza eth0 con tu interfaz de Internet (ip a)
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
```

---

## 🆚 Comparación Windows vs Linux

| Característica | Windows 11 | Linux Fedora |
|---|---|---|
| Adaptadores WiFi 6 | ❌ Muchos problemas | ✅ Sin problemas |
| Configuración manual | ❌ Limitada | ✅ Total control |
| Ver IPs en tiempo real | ⚠️ Complicado | ✅ Inmediato |
| Educativo | ⚠️ Caja negra | ✅ Ves todo el proceso |
| Fácil de usar | ✅ GUI nativa | ⚠️ Requiere terminal |
| **Recomendación** | Use solo si no tiene Linux | **✅ MEJOR OPCIÓN** |

---

## ✨ Conclusión

**Para tu proyecto educativo, Linux Fedora es la mejor opción**. Aprenderás mucho más sobre cómo funcionan las redes WiFi, DHCP, y podrás ver claramente todas las IPs conectadas sin complicaciones.

Si tienes Fedora disponible, úsalo. Si solo tienes Windows, el script BAT funcionará pero con más limitaciones.
