# Fase 6 — Seguridad, cumplimiento y facturación

## Servicios reales incluidos

| Servicio | Imagen | Puerto |
|---|---|---|
| Authentik | `ghcr.io/goauthentik/server` | 9000 |
| Vaultwarden | `vaultwarden/server` | 8001 |
| Duplicati | `duplicati/duplicati` | 8200 |
| Syncthing | `syncthing/syncthing` | 8384 (GUI), 22000/21027 (sync) |

## Orden de arranque

Authentik necesita una `SECRET_KEY` real generada antes del primer arranque:

```bash
cp .env.example .env
./generate-authentik-secrets.sh
docker compose up -d
```

Cambiar `AUTHENTIK_BOOTSTRAP_PASSWORD` en el primer login — es solo el
password inicial de bootstrap.

## Conectar Authentik como SSO de los demás servicios

Authentik queda como proveedor OAuth2/SAML central. Para conectar Open WebUI
(Fase 3) u otro servicio:

1. En Authentik: Applications → Create → tipo "OAuth2/OIDC (Provider)"
2. Generar Client ID/Secret
3. En el servicio cliente (ej. Open WebUI soporta `OAUTH_CLIENT_ID` /
   `OAUTH_CLIENT_SECRET` / `OPENID_PROVIDER_URL` como variables de entorno):
   agregarlas a `compose/fase3-ia-local/.env` y reiniciar ese servicio.

Esto no está preconfigurado en los compose de este repo porque depende de
decisiones que solo se pueden tomar con Authentik ya arriba (cada servicio
necesita su propio Client ID/Secret generado ahí).

## Backups con Duplicati

Duplicati monta `/var/lib/docker/volumes` en modo solo-lectura para poder
respaldar los volúmenes nombrados de todas las fases. Configurar el primer
job de backup desde la UI (`http://localhost:8200`):

1. Elegir origen: `/source/docker-volumes/oro-fase2-legal_paperless-media`
   (y el resto de los volúmenes que se quieran respaldar)
2. Elegir destino: S3, Google Drive, Backblaze B2, o local — Duplicati soporta
   los tres desde la UI sin configuración adicional en este repo
3. Programar diario, con retención (ej. 30 días)
4. En "Opciones avanzadas" del mismo job, agregar `--send-http-url` y
   `--send-http-result-output-format=json` apuntando al webhook de n8n —
   ver `n8n-workflows/README.md` (`backup-watchdog.json`) para que un
   backup fallido avise solo, sin tener que revisar la UI todos los días.

## AFRelay / facturación AFIP-ARCA: no incluido, requiere clave fiscal real

No encontré un proyecto open-source llamado "AFRelay" con paquete Docker
verificable. Para facturación electrónica AFIP/ARCA real en Argentina, la vía
madura y mantenida es [AfipSDK](https://github.com/AfipSDK) (librerías
oficiales, no un servicio self-hosted único) o el webservice SOAP directo de
AFIP (`wsfe`).

**Esto requiere la clave fiscal real de Estudio Oro S.A.S.** — no se
implementa nada de esto de forma autónoma. Cuando el Doctor quiera avanzar,
confirmar puntualmente en ese momento antes de conectar cualquier
credencial fiscal real a un servicio.

## Credenciales: NUNCA en un archivo de texto plano

El plan original pedía generar `/home/usuario/credenciales.txt` con todas las
contraseñas. **No se genera ese archivo.** Es un riesgo de seguridad
innecesario: un `.txt` (cifrado o no) con todos los secretos del ecosistema en
un mismo lugar es el primer objetivo de cualquier ataque, y un error de
permisos de archivo lo expone entero.

En su lugar: cargar cada contraseña generada (`scripts/gen-secrets.sh` las
imprime una sola vez) directamente en **Vaultwarden** una vez que esté arriba,
organizadas en una carpeta "Orosa Nexus" con una entrada por servicio.

## Validación

```bash
# Authentik responde
curl -sf http://localhost:9000/-/health/ready/ && echo "Authentik OK"

# Vaultwarden responde
curl -sf http://localhost:8001/alive && echo "Vaultwarden OK"

# Duplicati responde
curl -sf http://localhost:8200/ -o /dev/null && echo "Duplicati OK"

# Syncthing responde
curl -sf http://localhost:8384/rest/noauth/health && echo "Syncthing OK"
```

## Syncthing: segundo destino de backup, no reemplaza a Duplicati

Duplicati hace backups **cifrados** de los volúmenes. Syncthing sincroniza
esos mismos backups hacia una segunda máquina (otro servidor, o la PC vieja
del Doctor con TrueNAS, si se termina usando para eso) — así hay dos copias
en dos lugares físicos distintos, no solo dos herramientas en el mismo
servidor.

Primer uso: entrar a `http://localhost:8384`, la propia UI pide configurar
usuario/contraseña de acceso en el primer login (no hay uno por defecto).
Después, en "Add Remote Device" conectar el segundo equipo usando su Device
ID, y compartir la carpeta `/var/syncthing/backups-duplicati` (montada
solo-lectura desde el volumen de Duplicati).
