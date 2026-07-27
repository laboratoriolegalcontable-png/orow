---
name: orosa-nexus-estado
description: Diagnostica el estado real del ecosistema Orosa Nexus (que fases estan instaladas, que servicios responden, que falta). Activar cuando el usuario pregunte "como esta el servidor", "que tengo instalado", "anda todo bien", "revisá el sistema", o antes de agregar una fase nueva (para no asumir que algo ya esta arriba sin chequear).
---

# Diagnosticar el estado de Orosa Nexus

No asumir nunca el estado por lo que dice `ecosystem-state.json` sin
verificar — ese archivo puede estar desactualizado. El estado real se mide
así, en este orden:

## 1. Correr la verificación real

```bash
cd /ruta/al/repo/orow   # o donde este clonado en el servidor
./scripts/verify-ecosystem.sh
```

Esto da el estado real de cada servicio (OK/FALLO), no lo que alguien
anotó a mano. Si el script no existe o el repo no está clonado en el
servidor, **el ecosistema no está instalado todavía** — no inventar un
estado intermedio.

## 2. Contrastar con `docker ps`

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

Si `verify-ecosystem.sh` marca algo como FALLO pero el contenedor figura
"Up" en `docker ps`, el problema es de red/puerto, no de que el servicio
esté caído — revisar el `.env` de esa fase antes de asumir que hay que
reinstalar.

## 3. Espacio y memoria reales

```bash
df -h /
free -h
```

Antes de sugerir agregar una fase nueva o activar Mautic/Dify (marcados
como "solo si sobra RAM" en `docs/FASE-3-ia-local.md` y
`docs/FASE-5-marketing.md`), correr esto y decidir con el número real, no
con el estimado de 64GB de la compra del servidor.

## 4. Actualizar `ecosystem-state.json` (no el `.example`)

Si el estado real difiere del archivo, actualizarlo — es la única forma de
que la próxima sesión no tenga que volver a correr todo esto desde cero.
Nunca commitear ese archivo (está en `.gitignore`).

## Reportar al Doctor

Formato corto: qué fases están arriba (OK), cuáles fallan y por qué (si se
pudo determinar), y qué recursos quedan libres (RAM/disco) para decisiones
futuras. No un volcado crudo del output de los scripts.
