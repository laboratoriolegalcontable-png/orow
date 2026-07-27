-- Migracion APLICADA al proyecto Supabase moljmujlfvtsgkjbtwss. Ver
-- docs/FASE-4-inmobiliaria.md ("Recomendador de propiedades") para el
-- contexto completo.
--
-- RPC publica: dada una propiedad, devuelve las N mas parecidas por
-- similitud de coseno sobre descripcion_embedding (nomic-embed-text via
-- Ollama, ver propiedades-embeddings.sql). Reemplaza al "OpenAdServer"
-- del plan original (motor de ML para ads) por un recomendador de
-- contenido propio para las webs del estudio.
--
-- security definer a proposito: `propiedades` no tiene politica RLS para
-- anon/authenticated (solo service_role) - sin security definer esta
-- funcion devolveria 0 filas siempre para un visitante publico. Solo
-- expone id/titulo/zona/precio_usd/similitud, nunca due_diligence ni otros
-- campos internos. El linter de seguridad de Supabase marca esto como
-- advertencia esperada (cualquier funcion security definer ejecutable por
-- anon se señala) - es intencional.

create or replace function public.recomendar_propiedades_similares(
    propiedad_id uuid,
    limite int default 5
)
returns table (
    id uuid,
    titulo text,
    zona text,
    precio_usd numeric,
    similitud double precision
)
language sql
stable
security definer
set search_path = public
as $$
    select
        p.id,
        p.titulo,
        p.zona,
        p.precio_usd,
        1 - (p.descripcion_embedding <=> origen.descripcion_embedding) as similitud
    from public.propiedades p
    cross join (
        select descripcion_embedding
        from public.propiedades
        where id = propiedad_id
    ) as origen
    where p.id != propiedad_id
      and p.descripcion_embedding is not null
      and origen.descripcion_embedding is not null
      and p.estado = 'disponible'
    order by p.descripcion_embedding <=> origen.descripcion_embedding
    limit limite;
$$;

grant execute on function public.recomendar_propiedades_similares(uuid, int) to anon, authenticated, service_role;
