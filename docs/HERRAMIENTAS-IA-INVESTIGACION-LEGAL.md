# Herramientas de IA para investigación legal (MCP)

A diferencia del resto de Orosa Nexus (apps web con puerto propio, en
`compose/faseN-*`), esto es un **servidor MCP** (Model Context Protocol):
una herramienta que un agente de IA invoca para buscar información, no una
página que se abre en el navegador. Por eso no tiene su propia entrada en
`compose/` — se documenta acá aparte.

## Legal Hub MCP (`Probanza-ar/mcp-legal-ar`) — resuelto, instalación confirmada

Unifica ~15 conectores de información jurídica argentina en un solo servidor
MCP: **SAIJ**, **JUBA**, InfoLEG, BCRA, y otras fuentes públicas, más tres
portales judiciales reales si se cargan credenciales propias — ver abajo.

Verificado directo en el repo (README + código):

- **Licencia**: dual — Apache 2.0 (el hub/proxy) + MIT (conectores de
  terceros, con atribución completa en `THIRD_PARTY_NOTICES.md`). Open
  source real. 66 commits en `main`, 59 estrellas, 21 forks, desarrollo
  activo.
- **No trae Dockerfile ni docker-compose.yml** — es un servidor Node.js que
  corre por **stdio** (proceso hijo lanzado por el agente de IA), no un
  contenedor con puerto HTTP expuesto. Por eso no entra en `compose/`.
- **Instalación**: clonar el repo y correr `npm install` en la raíz y en
  `servers/legal-mcp` y `servers/saij-mcp` (o el script `setup.sh` que ya
  lo automatiza).
- **Arranque**: `node <ruta>/servers/legal-mcp/build/index.js`, registrado
  como servidor MCP tipo `stdio` en la config de Claude Code (`claude mcp
  add`), no como servicio de fondo con puerto propio.
- **Credenciales**: 12 de los ~15 conectores acceden a fuentes públicas sin
  key. Solo tres necesitan login real y son **opcionales**:
  - `MEV_USUARIO` / `MEV_CLAVE` / `MEV_DEPTO_REGISTRADO` (Portal MEV)
  - `EJE_USUARIO` / `EJE_CLAVE` / `EJE_LOGIN` (JusCABA/EJE)
  - `PJN_USER` / `PJN_PASS` (Portal PJN)

  Estas tres son credenciales reales del Poder Judicial — si se cargan, el
  hub puede consultar expedientes reales del Doctor en esos portales, no
  solo fuentes públicas. **No cargarlas sin decisión explícita** — son
  login judicial real, no una API key genérica.

### Instalado — ya conectado en la Mac del Doctor

```bash
git clone https://github.com/Probanza-ar/mcp-legal-ar.git
cd mcp-legal-ar
./setup.sh   # instala dependencias de la raiz + legal-mcp + saij-mcp

claude mcp add legal-hub-ar -- node "$(pwd)/servers/legal-mcp/build/index.js"
```

Confirmado con `claude mcp list`: `legal-hub-ar ... ✔ Connected`. El
`setup.sh` además configuró Claude Desktop automáticamente (merge en
`claude_desktop_config.json`) — quedó disponible en los dos: Claude Code y
Claude Desktop.

Sin las variables `MEV_*`/`EJE_*`/`PJN_*` en el entorno, el hub sigue
funcionando con los 12 conectores públicos (SAIJ, JUBA, InfoLEG, BCRA,
etc.) — agregar las tres de portales judiciales es un paso aparte,
posterior y opcional, no hecho todavía.

## Cómo se usaría — resuelto: se conecta a Claude Code directo

No es "instalar y ya" como Paperless — es una tool más para el agente de IA
que ya la invoca, no una página web. El punto de integración confirmado es
**Claude Code** (`claude mcp add`, ver arriba), igual que el resto de los
skills legales de la cuenta (`escritos-penales-cppn`,
`jurisprudencia-argentina`, etc. — viven a nivel de cuenta, no en un repo,
según `docs/INTEGRACION-SKILLS-LEGALES.md`). Una vez agregado con `claude
mcp add`, queda disponible en cualquier sesión de Claude Code sin volver a
instalarlo.

Conectarlo además a un flujo de n8n/Langflow (para que Ollama enriquezca una
consulta con datos del hub antes de responder) sería un paso aparte,
posterior — no hace falta para que el hub funcione desde Claude Code.

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
