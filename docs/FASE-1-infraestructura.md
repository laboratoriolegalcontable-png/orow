# Fase 1 — Infraestructura base

## Qué se instala aquí

- Red Docker compartida `oro-net`, usada por todas las fases siguientes.
- [Portainer CE](https://github.com/portainer/portainer) — UI web para
  administrar contenedores, sin necesidad de memorizar comandos `docker`.

## Coolify: se instala aparte, no vía este compose

Coolify **no se empaqueta como un servicio dentro de un `docker-compose.yml`
de terceros** — su instalador oficial levanta su propio stack completo
(Postgres, Redis, proxy Traefik/Caddy, la app en sí) directamente sobre el
Docker del host. Intentar envolverlo en un compose propio rompe su forma de
autoactualizarse y de gestionar sus propios contenedores.

Instalación real (correr en el servidor, no en este repo):

```bash
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
```

Después de instalar:
- UI en `http://IP-DEL-SERVIDOR:8000`
- Cambiar el usuario/contraseña de admin en el primer login
- Conectar el servidor a sí mismo como "localhost server" en el wizard inicial

## Reverse proxy con TLS (recomendado antes de exponer cualquier servicio)

Ningún compose de este repo expone puertos fuera de `127.0.0.1` por defecto.
Para acceso remoto real, usar Traefik o Caddy delante con Let's Encrypt. Si ya
tenés Coolify instalado, Coolify trae su propio proxy Traefik y podés usarlo
para todos los demás servicios en vez de instalar uno nuevo (recomendado —
evita puertos 80/443 duplicados).

## Verificación

```bash
docker compose -f compose/fase1-infraestructura/docker-compose.yml ps
curl -k https://127.0.0.1:$(grep PORTAINER_PORT .env | cut -d= -f2)
```

Coolify: entrar a `http://IP:8000`, crear un proyecto de prueba y desplegar
una app pública simple (ej. un repo con un `Dockerfile` de ejemplo) para
confirmar que el pipeline Git → build → deploy funciona.
