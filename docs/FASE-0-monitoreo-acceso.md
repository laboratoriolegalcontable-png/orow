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
en los puertos 80/443.** Para exponer, por ejemplo, Paperless-ngx en
`documentos.estudiooro.com.ar`:

1. Apuntar el DNS de ese subdominio a la IP del servidor
2. En la UI de NPM (puerto 81): "Proxy Hosts" → nuevo host → dominio +
   destino `paperless:8000` (nombre del contenedor en `oro-net`, puerto
   interno, no el puerto mapeado a localhost)
3. Pedir certificado Let's Encrypt desde la misma pantalla

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
