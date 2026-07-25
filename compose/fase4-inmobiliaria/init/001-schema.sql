-- Esquema minimo funcional para probar el stack inmobiliario mientras se
-- define el CRM real (ver docs/FASE-4-inmobiliaria.md). No es un CRM completo,
-- es lo suficiente para validar que Postgres + pgvector guardan y buscan datos.

CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS propiedades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    titulo TEXT NOT NULL,
    zona TEXT NOT NULL,
    precio_usd NUMERIC(12, 2) NOT NULL,
    tipo TEXT NOT NULL CHECK (tipo IN ('casa', 'departamento', 'ph', 'terreno', 'local', 'oficina')),
    descripcion TEXT,
    descripcion_embedding VECTOR(1536),
    lat DOUBLE PRECISION,
    lng DOUBLE PRECISION,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_propiedades_zona ON propiedades (zona);
CREATE INDEX IF NOT EXISTS idx_propiedades_precio ON propiedades (precio_usd);

-- Propiedad de ejemplo para validar el flujo (Fase 4, paso de validacion)
INSERT INTO propiedades (titulo, zona, precio_usd, tipo, descripcion, lat, lng)
VALUES (
    'Departamento 2 ambientes de prueba',
    'Palermo',
    120000.00,
    'departamento',
    'Propiedad de prueba insertada al validar la Fase 4. Borrar en produccion.',
    -34.5875,
    -58.4306
)
ON CONFLICT DO NOTHING;
