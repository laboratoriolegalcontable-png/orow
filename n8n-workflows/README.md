# Workflows de n8n para Orosa Nexus

## el-gran-juicio.json — Simulador de argumentos multi-fuero

Herramienta de **preparación interna**: recibe los hechos de un caso y
devuelve un memo con el análisis desde tres perspectivas (Civil/Comercial,
Penal, Laboral), sintetizado por un cuarto paso neutral que señala qué
fuero aplica y qué falta verificar.

**No incluye** el módulo de vigilancia/perfilado de abogados o jueces que
se propuso en otra sesión y que no se construyó — ver
`docs/VERIFICACION-HERRAMIENTAS-MARKETING.md`, sección final. Esto es
exclusivamente análisis del caso en sí (los hechos que se le pasan), nunca
de personas.

### Cómo importar

1. Con n8n corriendo (Fase 5), entrar a `http://localhost:5678`
2. "Import from File" → seleccionar `el-gran-juicio.json`
3. Activar el workflow

### Cómo usar

```bash
curl -X POST http://localhost:5678/webhook/el-gran-juicio \
  -H "Content-Type: application/json" \
  -d '{"caso": "Descripcion de los hechos del caso, en texto plano, sin nombres reales de terceros si se puede evitar."}'
```

Devuelve un JSON con el campo `memo` (el análisis sintetizado).

### Advertencia sobre el contenido generado

Ollama con `llama3.2:3b` (modelo chico, local) **puede alucinar artículos o
jurisprudencia que no existen**. Este workflow es un punto de partida para
pensar el caso, no un research jurídico verificado — cualquier cita legal
que devuelva hay que confirmarla con una fuente real (SAIJ, JUBA, o el
propio Código) antes de usarla en un escrito.
