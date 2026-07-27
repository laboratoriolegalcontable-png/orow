# Fase 3 — IA y automatización local

## Orden de arranque (importante)

Ollama tiene que estar corriendo y con el modelo descargado **antes** de que
Open WebUI intente conectarse, si no, Open WebUI queda sin backend.

```bash
docker compose up -d ollama
docker compose exec ollama ollama pull llama3.2:3b
docker compose up -d open-webui langflow
```

Si Open WebUI no detecta Ollama al reiniciar (pasa si Ollama tardó en levantar):

```bash
docker compose restart open-webui
```

## Límites de memoria

Ambos servicios traen `deploy.resources.limits.memory` para evitar que
compitan por toda la RAM del host. Ajustar según el servidor real.

## Dify: no incluido por defecto

Dify es una plataforma completa (requiere su propio Postgres, Redis, Weaviate
y varios workers) — mucho más pesada que Langflow. Se deja **fuera del
compose por defecto**, tal como pedía el plan original ("preguntame si lo
instalamos"). Si se decide instalar, usar el
[docker-compose oficial de Dify](https://github.com/langgenius/dify/tree/main/docker)
como stack aparte, no mezclado con este repo, y confirmar antes que el
servidor tiene >4GB RAM libres reales (`free -h`).

## Validación

```bash
# Ollama responde
curl -sf http://localhost:11434/api/tags

# Open WebUI carga y puede listar modelos de Ollama
curl -sf http://localhost:3000/ -o /dev/null && echo "Open WebUI OK"
# (la prueba de chat real se hace desde el navegador, no por curl)

# Langflow carga el panel visual
curl -sf http://localhost:7860/health -o /dev/null && echo "Langflow OK"
```
