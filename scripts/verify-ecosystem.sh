#!/usr/bin/env bash
# Fase 7: verificacion cruzada real de todos los servicios activos.
# Corre checks HTTP/CLI reales contra los puertos definidos en cada fase.
# No asume que algo esta instalado: si un servicio no responde, lo reporta
# como FALLO en vez de omitirlo silenciosamente.
set -uo pipefail

pass=0
fail=0

check() {
    local name="$1"
    local cmd="$2"
    printf '%-45s' "$name"
    if eval "$cmd" >/dev/null 2>&1; then
        echo "OK"
        pass=$((pass + 1))
    else
        echo "FALLO (servicio no responde o no esta instalado)"
        fail=$((fail + 1))
    fi
}

echo "=== Fase 0: Monitoreo y acceso ==="
check "Nginx Proxy Manager"  "curl -sf http://localhost:81/"
check "Netdata"              "curl -sf http://localhost:19999/api/v1/info"
check "Dozzle"               "curl -sf http://localhost:8888/"

echo ""
echo "=== Fase 1: Infraestructura ==="
check "Portainer"            "curl -skf https://localhost:9443"

echo ""
echo "=== Fase 2: Legal ==="
check "Paperless-ngx"        "curl -sf http://localhost:8010/api/"
check "Stirling-PDF"         "curl -sf http://localhost:8011/"
check "DocuSeal"             "curl -sf http://localhost:3005/"

echo ""
echo "=== Fase 3: IA local ==="
check "Ollama API"           "curl -sf http://localhost:11434/api/tags"
check "Open WebUI"           "curl -sf http://localhost:3000/"
check "Langflow"             "curl -sf http://localhost:7860/health"

echo ""
echo "=== Fase 4: Inmobiliaria ==="
check "Postgres+pgvector"    "docker exec oro-inmobiliaria-db pg_isready -U inmobiliaria"

echo ""
echo "=== Fase 5: Marketing ==="
check "n8n"                  "curl -sf http://localhost:5678/healthz"
check "Matomo"               "curl -sf http://localhost:8050/"
check "Mautic (opcional)"    "curl -sf http://localhost:8012/"

echo ""
echo "=== Fase 6: Seguridad ==="
check "Authentik"            "curl -sf http://localhost:9000/-/health/ready/"
check "Vaultwarden"          "curl -sf http://localhost:8001/alive"
check "Duplicati"            "curl -sf http://localhost:8200/"
check "Syncthing"            "curl -sf http://localhost:8384/rest/noauth/health"

echo ""
echo "=== Fase 8: Productividad interna ==="
check "Wiki.js"               "curl -sf http://localhost:3300/"
check "Firefly III"           "curl -sf http://localhost:8060/"
check "Planka"                "curl -sf http://localhost:3400/"

echo ""
echo "=== Fase 9: Agenda de turnos ==="
check "EasyAppointments"      "curl -sf http://localhost:8070/"

echo ""
echo "======================================"
echo "Resultado: ${pass} OK / ${fail} fallo(s)"
echo "======================================"

if [ "$fail" -gt 0 ]; then
    echo ""
    echo "Los servicios en FALLO pueden ser: (a) no instalados todavia,"
    echo "(b) instalados en otro puerto, o (c) caidos. Revisar con:"
    echo "  docker ps -a"
    echo "  docker logs <nombre-del-contenedor>"
fi

exit "$fail"
