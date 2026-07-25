-- Migracion PENDIENTE para el proyecto Supabase moljmujlfvtsgkjbtwss.
-- NO APLICADA TODAVIA. Ver docs/FASE-4-inmobiliaria.md.
--
-- Contexto: la tabla `propiedades` en produccion (bots NARAKIA) no tiene
-- ninguna columna de embeddings. Esto agrega busqueda semantica sobre la
-- descripcion de cada propiedad, sin tocar ninguna columna existente ni
-- ninguna de las otras tablas inmobiliarias (inmuebles, megan_properties,
-- oroprop_*, real_estate_leads).
--
-- Antes de correr esto en produccion:
--   1. Confirmar que `propiedades` es efectivamente la tabla que Orosa Nexus
--      Fase 4 va a usar (pendiente de confirmacion del Doctor).
--   2. Correr esto primero en un branch de Supabase (create_branch), nunca
--      directo en produccion.
--   3. El modelo de embeddings a usar (dimension 1536 asume OpenAI
--      text-embedding-3-small u Ollama con un modelo compatible) debe
--      confirmarse antes de generar los vectores reales.

create extension if not exists vector;

alter table public.propiedades
    add column if not exists descripcion_embedding vector(1536);

create index if not exists idx_propiedades_embedding
    on public.propiedades
    using ivfflat (descripcion_embedding vector_cosine_ops)
    with (lists = 100);

-- Function de ejemplo para busqueda semantica (ajustar segun como se generen
-- los embeddings - Ollama local vs API externa):
--
-- select id, titulo, zona, precio_usd
-- from public.propiedades
-- where descripcion_embedding is not null
-- order by descripcion_embedding <=> '[...]'::vector
-- limit 10;
