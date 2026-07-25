# Fase 5 — Marketing, ventas y publicidad

## Opción ligera (por defecto): n8n

`docker-compose.yml` levanta solo n8n con SQLite embebido (no necesita
Postgres/MySQL aparte). Autenticación básica activada por defecto — cambiar
`N8N_BASIC_AUTH_PASSWORD` en `.env` antes de levantar.

## Opción completa: sumar Mautic (solo si hay >4GB RAM libres)

```bash
# Verificar RAM libre real antes de decidir
free -h

docker compose -f docker-compose.yml -f docker-compose.mautic.yml up -d
```

Mautic usa el overlay `docker-compose.mautic.yml` (imagen oficial
`mautic/mautic:v5-apache` + MySQL 8). No se levanta por defecto — tal como
pedía el plan original ("Mautic solo si hay >4GB RAM libres").

## Herramientas no incluidas (no verificadas)

- **Signal (inteligencia de ventas)** — no encontré un proyecto open-source
  self-hosteable con ese nombre y esa descripción. Si es un producto interno
  del Doctor, pasar el repo real.
- **OpenAdServer** — no encontré un proyecto público mantenido con ese nombre
  exacto (FastAPI + PyTorch para ad-serving). Si existe, se agrega apenas se
  confirme el repo/imagen.

## Validación

```bash
# n8n responde
curl -sf http://localhost:5678/healthz && echo "n8n OK"

# Crear el primer workflow de prueba desde la UI:
# http://localhost:5678 -> New Workflow -> Schedule Trigger (cron "0 9 * * *")
#   -> Send Email node con las credenciales SMTP reales del estudio
```
