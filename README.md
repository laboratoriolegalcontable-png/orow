# Orosa Nexus

Ecosistema open-source self-hosted para **Estudio Oro S.A.S.** (legal penal +
inmobiliaria + marketing). Cada fase es un stack de Docker Compose independiente,
pensado para desplegarse en orden sobre un mismo host Linux con Docker instalado.

> Este repo define infraestructura como código (compose files, variables de
> entorno de ejemplo, scripts de utilidad). **No incluye contraseñas reales ni
> despliega nada por sí solo** — hay que clonarlo en un servidor real, generar
> los `.env` a partir de los `.env.example`, y levantar cada fase con
> `docker compose up -d`.

## Por qué por fases

Cada fase vive en `compose/faseN-*/docker-compose.yml` y es independiente de las
demás salvo por una red Docker externa compartida (`oro-net`) y, donde aplica,
un Postgres compartido. Esto permite instalar solo lo que hace falta, en el
orden que convenga, sin arrastrar todo el stack de una.

| Fase | Carpeta | Contenido |
|---|---|---|
| 0 | `compose/fase0-monitoreo-acceso` | Nginx Proxy Manager (único punto de entrada con TLS), Netdata (monitoreo), Dozzle (logs), Watchtower (auto-actualización) |
| 1 | `compose/fase1-infraestructura` | Red Docker compartida + Portainer (UI de gestión). Coolify se instala aparte (ver abajo). |
| 2 | `compose/fase2-legal` | Paperless-ngx (gestión documental + OCR), Stirling-PDF (edición de PDF), DocuSeal (firma digital) |
| 3 | `compose/fase3-ia-local` | Ollama (modelos locales), Open WebUI (chat), Langflow (flujos visuales de IA) |
| 4 | `compose/fase4-inmobiliaria` | Postgres 16 + pgvector compartido para CRM inmobiliario |
| 5 | `compose/fase5-marketing` | n8n (automatización), Matomo (analytics), Mautic (email marketing, opcional/pesado) |
| 6 | `compose/fase6-seguridad` | Authentik (SSO), Vaultwarden (contraseñas), Duplicati (backups cifrados), Syncthing (sincronización a segundo destino) |
| 7 | `scripts/verify-ecosystem.sh` | Script de verificación cruzada de todos los servicios activos |
| 8 | `compose/fase8-productividad` | Wiki.js (base de conocimiento interna), Firefly III (finanzas propias del estudio) |
| 9 | `compose/fase9-agenda-turnos` | EasyAppointments (agenda de turnos para consultas/visitas/reuniones) |

**Antes de que algo se rompa, leer `docs/RECUPERACION-DESASTRES.md`** — el
runbook de qué hacer si el servidor muere. Un backup que nadie sabe
restaurar no sirve de nada.

## Herramientas de la propuesta original que NO están incluidas como Docker Compose

Estas herramientas aparecían en el plan original pero **no encontré un paquete
Docker oficial y mantenido verificable públicamente** para ellas (nombre poco
específico, proyecto discontinuado, o no es un producto real self-hostable).
Incluirlas como compose files habría significado inventar nombres de imagen que
fallarían al hacer `docker pull`. En vez de eso quedan documentadas como
pendiente de definición — si el Doctor tiene el repo/imagen real de alguna,
se agrega en una fase posterior:

- **OpenLex (PyAr)** / **Justicia 360** — gestión de expedientes. Se deja el
  Postgres de Fase 4 listo para conectar cualquiera de las dos apenas se
  confirme el repo real.
- **Corredor (Property Manager 3.0)** — CRM inmobiliario. Idem: el Postgres +
  pgvector de Fase 4 queda preparado para lo que se decida usar (alternativas
  reales verificables: [Flowfact](https://flowfact.de), o construir uno propio
  con el `estudio-oro-domain` skill).
  Ojo: **PropertyLoop es un servicio SaaS de Reino Unido, no self-hosted** —
  no aplica a este ecosistema.
- **Signal (inteligencia de ventas)**, **OpenAdServer**, **AFRelay
  (facturación AFIP/ARCA)** — no encontré proyectos open-source
  self-hosteables verificables con estos nombres exactos. Para facturación
  AFIP real en Argentina, la vía verificada y mantenida es
  [AfipSDK](https://github.com/AfipSDK) o el propio webservice de AFIP — se
  documenta en `docs/FASE-6-seguridad.md` como próximo paso, no como compose
  listo.

Real Estate MCP Server (Python 3.10+, servidor MCP para flujos de IA sobre
datos inmobiliarios) tampoco corresponde a un paquete Docker público
verificado — es un patrón de arquitectura (MCP server), no un producto
instalable. Ver `docs/FASE-4-inmobiliaria.md` para un scaffold mínimo si se
quiere construir uno propio.

## Requisitos del servidor

- Docker Engine 24+ y Docker Compose v2 (`docker compose version`)
- Mínimo 4 GB RAM libres para Fases 1-3, +2 GB si se suma Mautic en Fase 5
- Puertos libres (ver tabla de cada fase) — usar `scripts/check-ports.sh` antes
  de levantar cada fase

## Orden de instalación

Cada fase sigue el mismo patrón: copiar `.env.example` a `.env`, correr
`scripts/gen-secrets.sh` para reemplazar los `CHANGE_ME_*` por valores
aleatorios reales, y recién ahí `docker compose up -d`.

```bash
ROOT=$(pwd)   # raiz del repo clonado en el servidor

# 0. Monitoreo y acceso (primero, para tener logs/monitoreo desde el arranque)
cd compose/fase0-monitoreo-acceso && cp .env.example .env && docker compose up -d
# (Fase 0 no tiene CHANGE_ME_ en su .env.example, no necesita gen-secrets.sh)

# 1. Red compartida + Portainer
cd "$ROOT/compose/fase1-infraestructura" && cp .env.example .env && docker compose up -d

# 2. Legal y documental
cd "$ROOT/compose/fase2-legal" && cp .env.example .env
"$ROOT/scripts/gen-secrets.sh" .env
docker compose up -d

# 3. IA local (Ollama primero, Open WebUI depende de él)
cd "$ROOT/compose/fase3-ia-local" && cp .env.example .env
"$ROOT/scripts/gen-secrets.sh" .env
docker compose up -d
docker compose exec ollama ollama pull llama3.2:3b

# 4. Postgres inmobiliario
cd "$ROOT/compose/fase4-inmobiliaria" && cp .env.example .env
"$ROOT/scripts/gen-secrets.sh" .env
docker compose up -d

# 5. Marketing
cd "$ROOT/compose/fase5-marketing" && cp .env.example .env
"$ROOT/scripts/gen-secrets.sh" .env
docker compose up -d

# 6. Seguridad (Authentik necesita su propio script de claves antes del resto)
cd "$ROOT/compose/fase6-seguridad" && cp .env.example .env
./generate-authentik-secrets.sh    # completa AUTHENTIK_SECRET_KEY
"$ROOT/scripts/gen-secrets.sh" .env   # completa el resto (Vaultwarden, Duplicati)
docker compose up -d

# 7. Verificación cruzada
cd "$ROOT" && ./scripts/verify-ecosystem.sh

# 8. Productividad interna (Wiki.js + Firefly III) - opcional
cd "$ROOT/compose/fase8-productividad" && cp .env.example .env
"$ROOT/scripts/gen-secrets.sh" .env
docker compose up -d

# 9. Agenda de turnos (EasyAppointments)
cd "$ROOT/compose/fase9-agenda-turnos" && cp .env.example .env
"$ROOT/scripts/gen-secrets.sh" .env
docker compose up -d
```

## Estado y credenciales

`ecosystem-state.example.json` es la plantilla del archivo de estado. En el
servidor real, copiarlo a `ecosystem-state.json` (está en `.gitignore` — nunca
se commitea, porque termina con contraseñas reales generadas) y actualizarlo a
mano o con `scripts/state-update.sh` a medida que se instala cada fase.

**Nunca comitear `.env`, `ecosystem-state.json` ni ningún archivo con
contraseñas reales a este repo.** Usar Vaultwarden (Fase 6) como gestor de
secretos real en vez de archivos de texto plano.

## Seguridad

- Todos los `.env.example` traen contraseñas de **ejemplo** (`CHANGE_ME_...`).
  `scripts/gen-secrets.sh` genera valores aleatorios reales antes del primer
  `docker compose up`.
- Ningún servicio queda expuesto a Internet por defecto — todos escuchan en
  `127.0.0.1` en los compose files. Para exponerlos hay que poner un reverse
  proxy con TLS (Traefik/Caddy) delante, documentado en
  `docs/FASE-1-infraestructura.md`.
- Buckets/documentos con datos de clientes (Paperless, DocuSeal) usan volúmenes
  named, no bind mounts a rutas públicas.

## Optimización de recursos

- Todos los `docker-compose.yml` (Fase 0 a 9) definen un ancla `x-logging` y la
  aplican a cada servicio (`max-size: 10m`, `max-file: 3`). Sin esto, Docker
  usa el driver `json-file` sin límite por defecto — en meses de uso los logs
  de cada contenedor pueden crecer sin tope y llenar el disco sin que nadie lo
  note hasta que un servicio falla por falta de espacio.
