# Fase 0 — Monitoreo y acceso

Esta fase se instala **primero**, antes que cualquier otra — reemplaza la
recomendación genérica de "poner un reverse proxy" de `docs/FASE-1-infraestructura.md`
por algo concreto y ya armado.

## Qué se instala

| Servicio | Imagen | Puerto | Para qué |
|---|---|---|---|
| Nginx Proxy Manager | `jc21/nginx-proxy-manager` | 80/443 (público), 81 (admin) | Único punto de entrada con TLS (Let's Encrypt) hacia los servicios que se decida exponer a internet |
| Netdata | `netdata/netdata` | 19999 | Monitoreo de CPU/RAM/disco del servidor en tiempo real |
| Dozzle | `amir20/dozzle` | 8888 | Ver logs de todos los contenedores desde el navegador, sin `docker logs` por SSH |
| Watchtower | `containrrr/watchtower` | — (sin UI) | Actualiza automáticamente las imágenes cuando sale una versión nueva, de madrugada (4am) |

Estas cuatro salieron de la verificación en
`docs/VERIFICACION-HERRAMIENTAS-MARKETING.md` — proyectos conocidos, activos,
con imagen Docker oficial.

## Por qué NO se suma Authelia acá

Authelia también salió "segura" en la verificación, pero **Fase 6 ya incluye
Authentik** para SSO. Tener dos proveedores de identidad compitiendo por el
mismo rol (autenticar el acceso a los demás servicios) es redundante y
confuso — hay que elegir uno. Este repo usa Authentik porque ya está
integrado en el plan original; si en el futuro se prefiere Authelia en su
lugar (es más liviano, pero con menos funciones), habría que sacar Authentik,
no correr los dos.

## Único punto de entrada real a internet

Todas las demás fases (`docker-compose.yml` de Fase 1 a 6) publican sus
puertos solo en `127.0.0.1` — no son alcanzables desde afuera del servidor.
**Nginx Proxy Manager es el único servicio pensado para escuchar en `0.0.0.0`
en los puertos 80/443.**

### Guía completa: exponer un servicio con dominio propio

Ejemplo concreto — exponer Paperless-ngx en `documentos.estudiooro.com.ar`:

1. **DNS**: en el panel del proveedor de dominio (donde esté registrado
   `estudiooro.com.ar`), crear un registro **A** apuntando
   `documentos.estudiooro.com.ar` → la IP pública del servidor Kimsufi.
   Un registro A tarda entre minutos y unas horas en propagarse — se puede
   confirmar con `dig documentos.estudiooro.com.ar` o
   `nslookup documentos.estudiooro.com.ar` antes de seguir.
2. **Nginx Proxy Manager** (puerto 81, solo accesible desde el servidor o
   por túnel SSH — no está expuesto a internet): "Proxy Hosts" → "Add
   Proxy Host":
   - Domain Names: `documentos.estudiooro.com.ar`
   - Forward Hostname/IP: `paperless` (nombre del contenedor dentro de
     `oro-net`, **no** `localhost` ni la IP del servidor)
   - Forward Port: `8000` (el puerto **interno** del contenedor, no el
     `8010` mapeado a `127.0.0.1` — esos son dos números distintos a
     propósito, uno es para el proxy interno, el otro para acceso directo
     desde el propio servidor)
3. Pestaña "SSL" del mismo formulario: pedir certificado **Let's Encrypt**
   nuevo, marcar "Force SSL". NPM renueva el certificado solo, no hace
   falta cron ni configuración adicional.
4. Repetir por cada servicio que se decida exponer (un subdominio por
   servicio: `n8n.estudiooro.com.ar`, `wiki.estudiooro.com.ar`, etc.) —
   nunca exponer un puerto directo del `.env` de otra fase, siempre pasar
   por NPM.

### Qué NO exponer nunca a internet, aunque se pueda

Vaultwarden, Duplicati, Portainer, y Netdata **no deberían tener un
subdominio público** salvo que estén detrás de Authentik (Fase 6) como
capa adicional de autenticación — son herramientas de administración del
propio estudio, no algo que un cliente necesite abrir desde afuera.

## Alertas de Netdata (recurso autónomo, no solo dashboard)

Instalado, Netdata solo muestra gráficos si alguien entra a mirarlos — sin
alertas activas, un disco que se está llenando o una RAM al límite pasa
desapercibido hasta que algo se cae. Netdata trae alertas propias
(`health.d/*.conf`, activas por defecto para CPU/RAM/disco) — falta
conectarlas a un canal real en vez de dejarlas solo en la UI.

1. Entrar al contenedor: `docker exec -it oro-netdata sh`
2. Editar `/etc/netdata/health_alarm_notify.conf` (o crear un archivo
   propio si no existe todavía — Netdata trae un `.conf.orig` de ejemplo)
3. Configurar el método de notificación **`custom`**, apuntando a un
   script que haga `curl` al mismo webhook de n8n que ya usa
   `backup-watchdog.json` (ver `n8n-workflows/README.md`) — así una
   alerta de disco lleno avisa por el mismo canal que un backup fallido,
   sin duplicar la integración con WhatsApp/Make.com.
4. Reiniciar Netdata: `docker restart oro-netdata`

**Verificar la sintaxis exacta de `health_alarm_notify.conf` contra la
versión de Netdata instalada al momento de configurar esto** — el formato
puede variar entre versiones, no asumir que el ejemplo de acá es
copy-paste literal sin chequear la documentación oficial vigente.

## Validación

```bash
# Nginx Proxy Manager: admin UI carga (usuario/clave por defecto la primera vez: admin@example.com / changeme, CAMBIAR apenas se entra)
curl -sf http://localhost:81/ -o /dev/null && echo "NPM OK"

# Netdata responde
curl -sf http://localhost:19999/api/v1/info && echo "Netdata OK"

# Dozzle muestra los contenedores corriendo
curl -sf http://localhost:8888/ -o /dev/null && echo "Dozzle OK"

# Watchtower: confirmar que arrancó y quedó en espera del próximo horario
docker logs oro-watchtower --tail 20
```
