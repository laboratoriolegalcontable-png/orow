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

## backup-watchdog.json — Alerta autónoma si Duplicati falla

Esto es un **recurso autónomo real**, no algo que haya que ejecutar a
mano: corre solo cada vez que Duplicati termina un backup (Fase 6), sin
intervención humana, y solo genera una acción (avisar) cuando algo salió
mal. Si el backup salió bien, no hace nada — el punto es no tener que
revisar Duplicati todos los días para saber si anduvo.

### Cómo conectarlo (dos pasos, ambos en el servidor real)

1. **Importar el workflow** en n8n igual que el anterior, y activarlo.
2. **Configurar Duplicati** para que avise a este webhook al terminar cada
   backup. Duplicati tiene esto nativo (no hay que programar nada nuevo):
   en cada trabajo de backup → "Opciones avanzadas" → agregar:
   - `--send-http-url=http://n8n:5678/webhook/duplicati-resultado`
   - `--send-http-result-output-format=json`

   (`n8n` es el nombre del contenedor dentro de `oro-net` — no hace falta
   IP ni exponer nada a internet, es tráfico interno entre contenedores).

3. En el `.env` de Fase 5, agregar `ALERTA_WHATSAPP_WEBHOOK_URL` apuntando
   al webhook de Make.com que ya usan los bots para alertas urgentes (el
   mismo canal que usa Lucrecia/NARAKIA para avisarle a Diego), o a
   cualquier otro medio de alerta que se prefiera — este workflow no asume
   cuál, solo llama a la URL que se configure.

### Por qué así y no con un script separado

Duplicati ya tiene esta función de notificación por HTTP incorporada —
construir un script aparte que lea sus logs o revise archivos por
timestamp sería reinventar algo que el propio Duplicati ya hace de forma
más confiable.
