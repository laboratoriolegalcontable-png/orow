# Herramientas de IA para investigación legal (MCP)

A diferencia del resto de Orosa Nexus (apps web con puerto propio, en
`compose/faseN-*`), esto es un **servidor MCP** (Model Context Protocol):
una herramienta que un agente de IA invoca para buscar información, no una
página que se abre en el navegador. Por eso no tiene su propia entrada en
`compose/` — se documenta acá aparte.

## Legal Hub MCP (`Probanza-ar/mcp-legal-ar`)

Unifica ~11 fuentes de información jurídica argentina en un solo servidor
MCP, incluyendo conectores a:

- **SAIJ** (Sistema Argentino de Información Jurídica)
- **JUBA** (Jurisprudencia de Buenos Aires)
- InfoLEG, BCRA, y otras fuentes públicas

Verificado: repo real, activo, licencia MIT (open source de verdad, no
open-core). 59 estrellas al momento de la verificación.

**Lo que NO tengo confirmado**: si el repo trae un `Dockerfile`/`docker-compose.yml`
propio, o si se instala vía `pip install`/`uvx` (patrón típico de servidores
MCP, que suelen correr como proceso stdio lanzado por el agente, no como
contenedor con puerto expuesto). Esto hay que confirmarlo leyendo el
`README.md` del repo directamente una vez que el servidor esté arriba, antes
de asumir un método de instalación.

## Cómo se usaría

No es "instalar y ya" como Paperless — se conecta como una tool más al
agente de IA que ya esté corriendo en el ecosistema (por ejemplo, Claude
Code corriendo en el mismo servidor, o un flujo de n8n/Langflow que llame al
servidor MCP para enriquecer una consulta antes de pasarla a Ollama). El
punto de integración concreto (¿n8n workflow? ¿configuración directa de
Claude Code en el servidor?) se define cuando se llegue a esa fase, no antes
— instalar el conector sin tener claro quién lo va a llamar no sirve de
nada.

## Instalaciones individuales de "SAIJ-MCP" o "JUBA-MCP" sueltas

**No instalar.** Son conectores dentro del hub de arriba, no proyectos
independientes — los nombres sueltos que circulan corresponden a paquetes
de autores distintos sin relación con el hub verificado, y no se puede
confirmar su procedencia ni mantenimiento.

## No hay más candidatos legal-específicos verificados

Fuera de este hub, el resto de nombres "legales" que aparecieron en las
listas anteriores (LawLink, "CRM Jurídico" genérico, OpenLex, Justicia 360,
Corredor) ya salieron descartados en
`docs/VERIFICACION-HERRAMIENTAS-MARKETING.md` y `docs/FASE-4-inmobiliaria.md`
— no hay una segunda vuelta de nombres para revisar en esta categoría.
