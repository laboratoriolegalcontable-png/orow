# Fase 2 — Legal y gestión documental

## Servicios reales incluidos

| Servicio | Imagen | Puerto | Necesita DB |
|---|---|---|---|
| Paperless-ngx | `ghcr.io/paperless-ngx/paperless-ngx` | 8010 | Postgres + Redis (incluidos en el compose) |
| Stirling-PDF | `frooodle/s-pdf` | 8011 | No |
| DocuSeal | `docuseal/docuseal` | 3005 | Postgres (incluido en el compose) |

## Gestión de expedientes (OpenLex / Justicia 360): pendiente de definición real

El plan original proponía **OpenLex (PyAr)** como opción A y **Justicia 360**
como fallback. No pude confirmar un paquete Docker oficial y mantenido
públicamente para ninguno de los dos con esos nombres exactos — puede que
sean proyectos internos, muy nuevos, o el nombre no sea exacto.

**Antes de instalar esto**, el Doctor debería confirmar:
1. La URL del repo real (GitHub) de la herramienta que quiere.
2. Si tiene `Dockerfile` o `docker-compose.yml` propio, o hay que armarlo.

Mientras tanto, el Postgres 16 + pgvector de **Fase 4** queda preparado para
conectar cualquiera de las dos apenas se confirme — no hace falta levantar
otro Postgres para esto.

## Validación post-instalación

```bash
# Paperless: subir un PDF de prueba y verificar OCR
# 1. Login en http://localhost:8010 con PAPERLESS_ADMIN_USER/PASSWORD
# 2. Arrastrar un PDF escaneado a la UI (o copiarlo al volumen paperless-consume)
docker cp ./prueba.pdf oro-paperless:/usr/src/paperless/consume/
# Esperar ~30s y refrescar la UI: el documento debe aparecer con texto OCR extraído

# Stirling-PDF: confirmar que carga
curl -sf http://localhost:8011/ -o /dev/null && echo "Stirling-PDF OK"

# DocuSeal: confirmar que carga y crear cuenta admin en el primer login
curl -sf http://localhost:3005/ -o /dev/null && echo "DocuSeal OK"
```
