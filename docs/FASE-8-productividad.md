# Fase 8 — Productividad interna

Agregada a pedido, fuera del plan original de 7 fases — dos herramientas de
uso interno del estudio, sin relación con expedientes de clientes.

## Wiki.js — base de conocimiento interna

Para procedimientos internos, plantillas de escritos, protocolos de
atención al cliente, onboarding de empleados nuevos. Imagen oficial
`ghcr.io/requarks/wiki:2` + Postgres.

Primer login: `http://localhost:3300`, el wizard de instalación pide crear
el usuario admin ahí (no hay uno por defecto).

## Firefly III — finanzas propias del estudio

**Ojo: esto es para la contabilidad interna de Estudio Oro S.A.S. (gastos,
ingresos, presupuesto del estudio como negocio) — no es facturación a
clientes ni reemplaza un sistema contable/impositivo formal.** Imagen
oficial `fireflyiii/core` + Postgres.

Requiere una `APP_KEY` con formato específico (heredado de Laravel), no un
secreto genérico:

```bash
echo "base64:$(openssl rand -base64 32)"
# copiar el resultado completo (incluyendo "base64:") a FIREFLYIII_APP_KEY en .env
```

Primer login: `http://localhost:8060`, crear cuenta de administrador ahí.

## Planka — Kanban de proyectos inmobiliarios (alcance acotado)

Se evaluó sumar un Kanban y se descartó para expedientes: **el estudio ya
tiene OroGest/NARAKIA para eso en Supabase**, y tener el estado de un caso
partido entre dos lugares distintos es peor que no tener Kanban. Confirmado
el alcance con el Doctor: Planka acá es **solo para proyectos/desarrollos
inmobiliarios** (seguimiento de obra, gestiones de una propiedad en curso,
tareas del equipo de la inmobiliaria) — nunca para el estado de una causa
judicial ni de un expediente. Imagen oficial `ghcr.io/plankanban/planka` +
Postgres.

Se eligió Planka en vez de Vikunja por ser más simple (tableros estilo
Trello: listas + tarjetas), que alcanza para este uso acotado sin traer
el resto de las funciones de gestión de tareas de Vikunja.

`PLANKA_SECRET_KEY` es un secreto de sesión genérico (no un formato
especial como el de Firefly III) — generarlo con
`openssl rand -hex 64` vía `scripts/gen-secrets.sh`.

Primer login: `http://localhost:3400`. El admin inicial se crea con las
variables `PLANKA_ADMIN_*` del `.env` (Planka las lee como
`DEFAULT_ADMIN_EMAIL/USERNAME/NAME/PASSWORD` al arrancar) — **una vez
loggeado, sacar `PLANKA_ADMIN_PASSWORD` del `.env` y reiniciar el
contenedor**, porque si queda esa variable Planka la reaplica en cada
arranque y pisa cualquier cambio de contraseña hecho desde la UI.

## Validación

```bash
curl -sf http://localhost:3300/ -o /dev/null && echo "Wiki.js OK"
curl -sf http://localhost:8060/ -o /dev/null && echo "Firefly III OK"
curl -sf http://localhost:3400/ -o /dev/null && echo "Planka OK"
```
