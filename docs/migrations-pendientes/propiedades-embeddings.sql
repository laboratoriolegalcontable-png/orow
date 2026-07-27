-- Migracion APLICADA al proyecto Supabase moljmujlfvtsgkjbtwss. Ver
-- docs/FASE-4-inmobiliaria.md para el detalle completo de la decision.
--
-- Contexto: la tabla `propiedades` en produccion (bots NARAKIA) no tenia
-- ninguna columna de embeddings. Esto agrega busqueda semantica sobre la
-- descripcion de cada propiedad, sin tocar ninguna columna existente ni
-- ninguna de las otras tablas inmobiliarias (inmuebles, megan_properties,
-- oroprop_*, real_estate_leads).
--
-- Historial: se aplico primero en vector(1536) (asumiendo OpenAI
-- text-embedding-3-small), y despues se confirmo Ollama local
-- (nomic-embed-text, 768 dimensiones) como modelo real - se ajusto la
-- columna a vector(768) mientras la tabla seguia en 0 filas (cambio
-- seguro, sin datos en riesgo). Este archivo refleja el estado final.

create extension if not exists vector;

alter table public.propiedades
    add column if not exists descripcion_embedding vector(768);

create index if not exists idx_propiedades_embedding
    on public.propiedades
    using ivfflat (descripcion_embedding vector_cosine_ops)
    with (lists = 100);

-- Generacion de los vectores: scripts/generate-property-embeddings.py
-- (Ollama local, modelo nomic-embed-text).

-- Busqueda de propiedades similares por descripcion: ver la funcion RPC
-- recomendar-propiedades-similares.sql en esta misma carpeta.
