# Verificación de herramientas de marketing/CRM/IA propuestas fuera de las Fases 1-7

Este documento registra la verificación puntual de un conjunto de ~50
herramientas de marketing, generación de leads, CRM y "modo Dios por voz"
propuestas en una sesión de planificación, antes de considerar agregarlas a
Orosa Nexus. Ninguna de las herramientas listadas acá está incluida en
`compose/` todavía — esto es solo el resultado de la verificación, no una
instalación.

## Seguras (Docker oficial, mantenidas, uso conocido)

Mautic, Documenso, Postiz, Matomo, Revive Adserver, EspoCRM, Twenty CRM,
Django CRM, Authelia, Netdata, Nginx Proxy Manager, Plunk, LetterSpace.

## No instalar bajo ningún concepto

- **"Free AI Social Media Scheduler"** (`Anil-matcha/Free-AI-Social-Media-Scheduler`):
  repo con 2000+ estrellas y **cero líneas de código funcional**, solo un
  README. Fuerte indicio de estrellas fabricadas / repo señuelo.
- **Corredor / "Property Manager 3.0"** (`martinmarquez/property-manager-3.0`):
  licencia **"Proprietary — all rights reserved"**. No es open source —
  corrección respecto a lo asumido en `docs/FASE-4-inmobiliaria.md`.
- **NetSendo**: licencia open-core/propietaria, no 100% libre.
- **Z.O.Y.A. / "God Mode"** (`IamCOD3X/ZOYA-AI-3.0`): licencia CC-BY-NC-ND,
  prohíbe uso comercial. No aplica a un estudio con fines de lucro.
- **Linki**: automatiza LinkedIn con fingerprinting de navegador — riesgo de
  ban de cuenta e incumplimiento de los Términos de Servicio de LinkedIn.
  Licencia "Sustainable Use", no OSI.

## No encontrados / evidencia insuficiente

RealtorsPal AI, LawLink, "CRM Jurídico" (genérico), Promora Suna,
MarketingOS MCP, EmaReach, Insight (analytics sin cookies), Infinite OS,
GrowthClaw, Gedoong, Outreach OS, OpenFlow, OpenCRM (nombre genérico,
posible confusión con openCRX). No instalar sin que el Doctor aporte el
repo real y verificable.

## Con matices — usables con precaución, no para datos críticos día uno

- **WeGIA**: real y mantenido, pero es un sistema para ONGs/instituciones
  asistenciales, no un CRM jurídico — no encaja con el uso previsto.
- **AdClaw, OpenOutreach, Prospex**: existen, tienen Docker real, pero son
  proyectos chicos/jóvenes de un solo mantenedor.
- **SAIJ-MCP / JUBA-MCP**: no son proyectos sueltos — son conectores dentro
  del hub `Probanza-ar/mcp-legal-ar`. Instalar ese hub completo si se
  necesita, no repos "SAIJ-MCP" sueltos de autores desconocidos.

## Explícitamente descartado (no es una cuestión de verificación de software)

Se propuso además un módulo "Modo Espionaje / Inteligencia Legal" para
perfilar psicológicamente a abogados contrarios y jueces, mapear su red de
contactos, y sugerir cómo "explotar sus debilidades" o manipularlos
emocionalmente. Esto no se evalúa ni se construye bajo ningún nombre o
encuadre — no es un problema de qué software usar, es una conducta que
expone al estudio a responsabilidad ética y civil real.
