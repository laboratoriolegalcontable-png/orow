# Integración con los skills legales existentes

Estudio Oro ya tiene skills de Claude Code para el trabajo legal
(`escritos-penales-cppn`, `defensa-penal-integral`, `habeas-corpus-urgente`,
`due-diligence-inmobiliario`, `jurisprudencia-argentina`,
`laboral-liquidaciones`, entre otros). Viven a **nivel de cuenta**
(`~/.claude/skills/`), no dentro de este repo — están disponibles en
cualquier sesión de Claude Code sin necesidad de copiarlos acá. Copiarlos
crearía dos versiones que se desincronizan apenas se edite una.

Lo que documenta este archivo es **cómo esos skills usan la infraestructura
de Orosa Nexus** una vez que esté arriba — no una reimplementación de nada.

## Escritos judiciales (`escritos-penales-cppn`, `defensa-penal-integral`, `habeas-corpus-urgente`)

Estos skills generan el **texto** del escrito y, según el skill, un `.docx`.
Con Orosa Nexus arriba:

- Guardar el `.docx` final en **Paperless-ngx** (Fase 2) en vez de solo en
  el disco local — queda con OCR, buscable, y con historial de versiones.
- Usar **DocuSeal** (Fase 2) cuando el escrito necesite firma del cliente
  antes de presentarlo (ej. poder, convenio de honorarios).
- `habeas-corpus-urgente` es, por definición, algo que se necesita ya —
  no depende de ninguna pieza de este repo, se redacta y se presenta
  directo. No hace falta ninguna integración especial ahí, la urgencia del
  skill no se toca.

## `jurisprudencia-argentina`

Este skill ya busca en fuentes oficiales verificables (CSJN, SCBA, CNCP,
etc.) — no depende de Orosa Nexus para funcionar. La única pieza
relacionada de este repo es el **Legal Hub MCP**
(`docs/HERRAMIENTAS-IA-INVESTIGACION-LEGAL.md`, pendiente de definir cómo
se integra) — si en el futuro se conecta, sería una fuente adicional de
consulta (SAIJ/JUBA), no un reemplazo de este skill.

## `due-diligence-inmobiliario`

Este es el que más se conecta con la Fase 4. El checklist de compraventa
que arma este skill (verificación de títulos, cargas, gravámenes) es
exactamente el tipo de dato que encaja en el campo `due_diligence` (jsonb)
que ya existe en la tabla `propiedades` de Supabase — confirmado como la
tabla real (ver `docs/FASE-4-inmobiliaria.md`). El resultado de este skill
se puede guardar directamente ahí en vez de en un documento suelto.

## `laboral-liquidaciones`

Calcula indemnizaciones y genera cartas documento. Con **DocuSeal** (Fase 2)
se podría enviar la carta documento a firma/notificación fehaciente en vez
de solo generarla como texto. No requiere ninguna otra pieza del
ecosistema — el cálculo en sí no usa Ollama ni ninguna IA local, usa la
normativa (LCT, RIPTE de fuente oficial) directamente.

## Regla general para todos

**Ningún skill legal debe reemplazarse por Ollama/IA local para el cálculo
o la cita de normativa.** Los skills existentes ya tienen las reglas
anti-alucinación (nunca inventar jurisprudencia, siempre indicar fuente
oficial del RIPTE, etc.) bien definidas — Ollama corriendo en el servidor
sirve para tareas de apoyo (el simulador de argumentos de
`n8n-workflows/el-gran-juicio.json`, por ejemplo, que ya advierte
explícitamente que puede alucinar y que todo hay que verificarlo), no para
reemplazar la fuente de verdad de estos skills.
