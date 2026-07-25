#!/usr/bin/env bash
# Verifica si los puertos usados por el ecosistema estan libres en este host.
# Uso: ./scripts/check-ports.sh
set -euo pipefail

PORTS=(81 19999 8888 9443 8010 8011 3005 11434 3000 7860 5433 5678 8050 8012 9000 8001 8200 8384 3300 8060 8070)

echo "Chequeando puertos..."
any_busy=0
for port in "${PORTS[@]}"; do
    if (echo > "/dev/tcp/127.0.0.1/${port}") >/dev/null 2>&1; then
        echo "  OCUPADO  :${port}"
        any_busy=1
    else
        echo "  libre    :${port}"
    fi
done

if [ "$any_busy" -eq 1 ]; then
    echo ""
    echo "Hay puertos ocupados. Cambiar la variable correspondiente en el .env.example"
    echo "de la fase que corresponda antes de levantar ese servicio."
    exit 1
fi

echo "Todos los puertos por defecto estan libres."
