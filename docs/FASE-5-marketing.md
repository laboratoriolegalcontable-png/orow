# Fase 5 — Marketing, ventas y publicidad

## Por defecto: n8n + Matomo

`docker-compose.yml` levanta **n8n** (SQLite embebido, no necesita
Postgres/MySQL aparte — autenticación básica activada por defecto, cambiar
`N8N_BASIC_AUTH_PASSWORD` en `.env`) y **Matomo** (analytics propio,
alternativa a Google Analytics, con su MariaDB incluido). Ambos verificados
como seguros en `docs/VERIFICACION-HERRAMIENTAS-MARKETING.md`.

Primer login de Matomo: entrar a `http://localhost:8050`, completar el
wizard de instalación (crea el usuario admin ahí, no hay uno por defecto).

## Opción completa: sumar Mautic (solo si hay >4GB RAM libres)

```bash
# Verificar RAM libre real antes de decidir
free -h

docker compose -f docker-compose.yml -f docker-compose.mautic.yml up -d
```

Mautic usa el overlay `docker-compose.mautic.yml` (imagen oficial
`mautic/mautic:v5-apache` + MySQL 8). No se levanta por defecto — tal como
pedía el plan original ("Mautic solo si hay >4GB RAM libres").

## Signal (inteligencia de ventas): resuelto — ya cubierto por skills existentes

No se necesita ningún proyecto nuevo ni self-hosteado. Las tres funciones
que se buscaban con "Signal" ya están cubiertas por skills de la cuenta
(viven en `~/.claude/skills/`, no en este repo — ver
`docs/INTEGRACION-SKILLS-LEGALES.md` sobre por qué no se duplican acá):

- **Prospección** (encontrar leads nuevos) → skill `scrapling` (prioridad
  máxima, ya activo — Google Maps, scraping de negocios/contactos)
- **Enriquecimiento de datos** (completar info de un contacto) → también
  `scrapling`
- **Scoring de leads existentes** → skill `ia-para-ventas` (califica leads
  automáticamente, predice cierres, analiza llamadas)

No se instala nada de esto en `compose/` — es exactamente el mismo motivo
por el que no se sumó un Kanban de expedientes en Fase 8: ya existe, sumar
algo nuevo partiría el flujo de trabajo en dos lugares.

## OpenAdServer: descartado el ad-server tradicional, pendiente el motor de ML real

Se evaluó **Revive Adserver** (`github.com/revive-adserver/revive-adserver`,
GPL, sucesor real y open-source de OpenX Source) como alternativa
verificable — pero es un ad-server tradicional (rotación de banners,
targeting por reglas), **no** lo que pedía el plan original: un motor de
ML (FastAPI + PyTorch) para targeting/bidding inteligente. Eso no existe
como proyecto open-source verificable con ese nombre ni función exacta —
construirlo es un proyecto de desarrollo propio, no una instalación.

**Pendiente de definir antes de empezar a construirlo**: con qué plataforma
de ads se integra (¿Google Ads? ¿Meta Ads? ¿un ad-server propio para las
webs del estudio?), qué datos de entrenamiento hay disponibles, y qué
decisión de targeting/bidding tiene que tomar el modelo — sin eso, no se
puede diseñar la arquitectura real.

## Validación

```bash
# n8n responde
curl -sf http://localhost:5678/healthz && echo "n8n OK"

# Matomo responde
curl -sf http://localhost:8050/ -o /dev/null && echo "Matomo OK"

# Crear el primer workflow de prueba desde la UI:
# http://localhost:5678 -> New Workflow -> Schedule Trigger (cron "0 9 * * *")
#   -> Send Email node con las credenciales SMTP reales del estudio
```
