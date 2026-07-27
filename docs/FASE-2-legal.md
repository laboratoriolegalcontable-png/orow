# Fase 2 — Legal y gestión documental

## Servicios reales incluidos

| Servicio | Imagen | Puerto | Necesita DB |
|---|---|---|---|
| Paperless-ngx | `ghcr.io/paperless-ngx/paperless-ngx` | 8010 | Postgres + Redis (incluidos en el compose) |
| Stirling-PDF | `frooodle/s-pdf` | 8011 | No |
| DocuSeal | `docuseal/docuseal` | 3005 | Postgres (incluido en el compose) |

## Gestión de expedientes (OpenLex / Justicia 360): resuelto — ya existe, no se agrega

El plan original proponía **OpenLex (PyAr)** como opción A y **Justicia 360**
como fallback. No se confirmó un paquete Docker oficial y mantenido
públicamente para ninguno de los dos con esos nombres exactos.

Al revisar el Supabase de producción (`moljmujlfvtsgkjbtwss`) para decidir
esto, se encontró que **la gestión de expedientes ya existe y está en uso**:
tabla `public.expedientes` (`numero_causa`, `juzgado`, `fuero`, `caratula`,
`estado`, `cliente_id`, `proxima_fecha`, `alertas_activas`) con
`alertas_judiciales` relacionada por `expediente_id`. Esto alimenta
OroGest/NARAKIA — es el mismo sistema que ya se decidió no duplicar con un
Kanban en Fase 8 (ver `docs/FASE-8-productividad.md`).

**Conclusión: no se instala OpenLex/Justicia 360 ni ninguna otra herramienta
de gestión de expedientes en este repo.** Sumar un self-hosted nuevo
partiría el estado de una causa entre dos lugares (igual que se evitó con
el Kanban) sin ninguna ganancia real. El rol de esta Fase 2 queda acotado a
lo que ya hace bien: **almacenamiento documental + OCR (Paperless-ngx) y
firma digital (DocuSeal)** para los archivos vinculados a esos expedientes
— no el registro del expediente en sí.

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
