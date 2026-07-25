# Fase 4 — Inmobiliaria (PropTech)

## Lo que sí se instala

Un Postgres 16 con la extensión `pgvector` habilitada (imagen oficial
`pgvector/pgvector:pg16`), con un esquema mínimo de propiedades
(`init/001-schema.sql`) que se aplica automáticamente al primer arranque.
Esto es real y funcional: se puede insertar, buscar y consultar propiedades
desde ya.

## Pendiente: conectar a Supabase en vez de este Postgres local

Se evaluó conectar esta fase directamente al proyecto Supabase existente
(`moljmujlfvtsgkjbtwss`, donde ya corren los bots NARAKIA) en vez de un
Postgres nuevo. Al revisar, ese Supabase **ya tiene un ecosistema
inmobiliario propio en producción**: tablas `propiedades`, `inmuebles`,
`megan_properties`, `oroprop_leads/favorites/shortlists`,
`real_estate_leads` — cada una sirviendo a un bot o app distinto, ninguna
con columna de embeddings todavía.

Queda pendiente confirmar **cuál de esas tablas** (probablemente
`propiedades`, que tiene los campos de due diligence) es la indicada antes
de tocar nada en producción. El script de migración ya está preparado y
revisado, sin aplicar, en
`docs/migrations-pendientes/propiedades-embeddings.sql`.

## Lo que NO se instala (y por qué)

El plan original pedía **"Corredor (Property Manager 3.0)"** como CRM
inmobiliario multi-tenant sincronizado con ZonaProp/Argenprop/Tokko, más un
**"Real Estate MCP Server"** y opcionalmente **PropertyLoop**. Verifiqué los
tres:

- **Corredor / Property Manager 3.0**: **actualización tras verificación
  puntual** — el repo existe (`martinmarquez/property-manager-3.0`), pero su
  licencia es **"Proprietary — all rights reserved"**. No es open source pese
  a como se presentó originalmente, así que no se puede autoinstalar como
  software libre. Si el Doctor consigue una licencia comercial real de ese
  proyecto, ahí sí se conecta al Postgres que ya está levantado acá — pero no
  se clona/despliega sin esa autorización.
- **PropertyLoop**: es un producto SaaS comercial del Reino Unido (no
  self-hosted, no open-source) — no aplica a un ecosistema self-hosted.
- **Real Estate MCP Server**: "MCP server" describe una arquitectura (un
  servidor Model Context Protocol), no un producto instalable con `docker
  pull`. Si lo que se quiere es exponer los datos de `propiedades` a un
  agente de IA vía MCP, hay que construirlo — es un scaffold de código, no
  una imagen Docker. Se puede armar con el skill `mcp-builder` de este mismo
  ecosistema Claude Code cuando se confirme el alcance.

Las APIs de ZonaProp/Argenprop/Tokko requieren convenio comercial propio con
cada portal (no son APIs públicas abiertas) — sincronizarlas depende de tener
esas credenciales, que no dependen de este repo.

## Validación

```bash
docker compose exec inmobiliaria-db psql -U inmobiliaria -d inmobiliaria \
  -c "SELECT titulo, zona, precio_usd FROM propiedades WHERE zona = 'Palermo' AND precio_usd < 200000;"
```

Si devuelve la fila de prueba insertada por `001-schema.sql`, Postgres +
pgvector están funcionando.
