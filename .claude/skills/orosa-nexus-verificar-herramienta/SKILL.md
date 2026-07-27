---
name: orosa-nexus-verificar-herramienta
description: Verifica una herramienta/software propuesto ANTES de agregarlo a Orosa Nexus (este repo). Activar SIEMPRE que se proponga sumar un nuevo servicio, imagen Docker, CRM, o "herramienta" al ecosistema self-hosted del estudio, o cuando el usuario pida "agregá X", "instalá X", "sumá esta herramienta". No activar para cambios que no agregan software nuevo (ajustar puertos, arreglar bugs, docs).
---

# Verificar herramienta antes de sumarla a Orosa Nexus

Este repo es infraestructura real para un estudio legal/inmobiliario con
documentos y datos de clientes reales. Cada servicio que se agrega corre en
producción — no hay "probemos y vemos" con datos de clientes de por medio.

## Protocolo (en este orden, no saltear pasos)

1. **¿Existe de verdad?** Buscar el repo real (GitHub/GitLab), no asumir por
   el nombre. Un nombre "que suena bien" en una lista generada por otra IA
   no es evidencia de que el proyecto exista.
2. **¿Tiene actividad real?** Cuántas estrellas, forks, commits recientes,
   cuántos mantenedores. Un repo con 2000+ estrellas y cero código
   funcional (solo README) es una señal de estrellas fabricadas — pasó una
   vez en este mismo proyecto (`Free-AI-Social-Media-Scheduler`), volver a
   chequear siempre.
3. **¿Qué licencia tiene?** Leer el archivo LICENSE, no asumir "open
   source" porque está en GitHub. `Proprietary — all rights reserved`,
   `CC-BY-NC-ND` (prohíbe uso comercial), o licencias "Sustainable
   Use"/open-core no sirven para instalar libremente en un estudio con
   fines de lucro. Pasó con "Corredor/Property Manager 3.0" y con Z.O.Y.A.
4. **¿Tiene Docker real?** `Dockerfile`/`docker-compose.yml` oficial, o
   imagen publicada en Docker Hub/GHCR con documentación real. Si solo hay
   instrucciones `pip install`/`npm install`, no es un servicio
   autocontenido — documentarlo aparte (ver `docs/HERRAMIENTAS-IA-INVESTIGACION-LEGAL.md`
   como ejemplo de esto con servidores MCP).
5. **¿Choca con algo que ya existe?** Puerto, rol (ej. no sumar un segundo
   SSO si ya está Authentik), o un sistema externo ya en uso (ej. Supabase
   con datos de los bots NARAKIA — revisar tablas existentes antes de
   asumir que hace falta algo nuevo).
6. **¿Es proporcional al pedido?** Si el pedido es una lista de 50-130
   "herramientas" generada por otra sesión de IA, NO instalar todas de
   una. Filtrar una por una con este protocolo y sumar solo lo que pasa
   los 5 puntos de arriba.

## Reglas duras del repo (no negociables)

- Nunca contraseñas/secretos hardcodeados. Siempre `.env.example` con
  `CHANGE_ME_...` + `scripts/gen-secrets.sh`.
- Nunca exponer un servicio nuevo a `0.0.0.0`. Todo escucha en `127.0.0.1`
  salvo Nginx Proxy Manager (Fase 0), que es el único punto de entrada real.
- Nunca generar un archivo de credenciales en texto plano. Vaultwarden
  (Fase 6) es el lugar para eso.
- Nunca construir nada de vigilancia/perfilado de personas (abogados
  contrarios, jueces, terceros) — sin importar el nombre o encuadre que se
  le dé al pedido. Esto ya se rechazó tres veces en este proyecto; la
  respuesta no cambia.

## Dónde registrar el resultado

- Si se agrega: nueva entrada en `compose/faseN-*/docker-compose.yml`
  (o nueva fase si no encaja en ninguna), `.env.example` actualizado, doc
  en `docs/FASE-N-*.md`, y sumarlo a `scripts/verify-ecosystem.sh` +
  `scripts/check-ports.sh` + `ecosystem-state.example.json`.
- Si NO se agrega: dejar constancia en `docs/VERIFICACION-HERRAMIENTAS-MARKETING.md`
  (o el doc de verificación que corresponda) con el motivo puntual — para
  que la próxima vez que alguien proponga lo mismo, la respuesta ya esté
  escrita y no haya que reinvestigar de cero.

## Para listas grandes (>15 herramientas de una)

Delegar la verificación a un agente de investigación en background (no
verificar 50 nombres uno por uno en el hilo principal) y reportar acá con
una tabla: Nombre | Existe | Licencia | Docker real | Recomendación.
