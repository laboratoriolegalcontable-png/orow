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

## Pendiente: Kanban de gestión de casos (Vikunja/Planka)

Se evaluó sumar un Kanban para expedientes, pero **el estudio ya tiene
OroGest/NARAKIA para eso en Supabase** — no se agrega hasta confirmar que no
duplica ese sistema (tener el estado de un caso partido entre dos lugares
distintos es peor que no tener Kanban). Si en el futuro se decide que es
para otra cosa (tareas internas del equipo, proyectos de la inmobiliaria
separados de expedientes judiciales), se suma acá con ese alcance acotado.

## Validación

```bash
curl -sf http://localhost:3300/ -o /dev/null && echo "Wiki.js OK"
curl -sf http://localhost:8060/ -o /dev/null && echo "Firefly III OK"
```
