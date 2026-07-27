#!/usr/bin/env bash
# Genera valores aleatorios reales para reemplazar los CHANGE_ME_* de un .env.
# Uso: ./scripts/gen-secrets.sh compose/fase2-legal/.env
set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Uso: $0 <ruta-al-.env>" >&2
    exit 1
fi

ENV_FILE="$1"

if [ ! -f "$ENV_FILE" ]; then
    echo "No existe: $ENV_FILE (copiar primero desde .env.example)" >&2
    exit 1
fi

TMP_FILE=$(mktemp)

while IFS= read -r line; do
    if [[ "$line" =~ ^([A-Z0-9_]+)=CHANGE_ME ]]; then
        key="${BASH_REMATCH[1]}"
        # Firefly III (Fase 8) usa el formato APP_KEY de Laravel, no un hex generico.
        if [ "$key" = "FIREFLYIII_APP_KEY" ]; then
            value="base64:$(openssl rand -base64 32)"
        else
            value=$(openssl rand -hex 24)
        fi
        echo "${key}=${value}" >> "$TMP_FILE"
        echo "Generado: ${key}"
    else
        echo "$line" >> "$TMP_FILE"
    fi
done < "$ENV_FILE"

mv "$TMP_FILE" "$ENV_FILE"
echo ""
echo "Listo. Copiar cada valor generado a Vaultwarden (Fase 6) antes de olvidarlos."
echo "IMPORTANTE: este .env nunca se commitea (esta en .gitignore)."
