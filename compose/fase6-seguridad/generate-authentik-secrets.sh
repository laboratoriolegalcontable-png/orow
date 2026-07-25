#!/usr/bin/env bash
# Genera AUTHENTIK_SECRET_KEY real y lo escribe en .env de esta carpeta.
# Correr una sola vez, antes del primer `docker compose up` de esta fase.
set -euo pipefail

cd "$(dirname "$0")"

if [ ! -f .env ]; then
    echo "No existe .env en esta carpeta. Copia .env.example primero: cp .env.example .env" >&2
    exit 1
fi

SECRET=$(openssl rand -base64 60 | tr -d '\n')

if grep -q '^AUTHENTIK_SECRET_KEY=' .env; then
    sed -i.bak "s|^AUTHENTIK_SECRET_KEY=.*|AUTHENTIK_SECRET_KEY=${SECRET}|" .env
    rm -f .env.bak
else
    echo "AUTHENTIK_SECRET_KEY=${SECRET}" >> .env
fi

echo "AUTHENTIK_SECRET_KEY generado y escrito en .env"
