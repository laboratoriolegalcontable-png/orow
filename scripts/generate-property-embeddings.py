#!/usr/bin/env python3
"""Genera embeddings para public.propiedades (Supabase) usando Ollama local.

Corre en el servidor (donde Ollama esta en localhost:11434) - toma cada fila
de `propiedades` con `descripcion` pero sin `descripcion_embedding`, calcula
el vector con el modelo nomic-embed-text (768 dimensiones, matching la
columna) y lo actualiza vía la REST API de Supabase.

Uso:
  export SUPABASE_URL="https://moljmujlfvtsgkjbtwss.supabase.co"
  export SUPABASE_SERVICE_ROLE_KEY="..."   # Vault/Vaultwarden, nunca hardcodear
  python3 scripts/generate-property-embeddings.py

Requiere el modelo bajado una sola vez en el servidor:
  docker exec oro-ollama ollama pull nomic-embed-text
"""
import json
import os
import sys
import urllib.request

OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://localhost:11434")
EMBED_MODEL = os.environ.get("OLLAMA_EMBED_MODEL", "nomic-embed-text")
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")


def _http_json(url, method="GET", headers=None, body=None):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method, headers=headers or {})
    with urllib.request.urlopen(req, timeout=60) as resp:
        raw = resp.read()
        return json.loads(raw) if raw else None


def fetch_pending_properties():
    url = (
        f"{SUPABASE_URL}/rest/v1/propiedades"
        "?select=id,descripcion&descripcion_embedding=is.null&descripcion=not.is.null"
    )
    headers = {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
    }
    return _http_json(url, headers=headers)


def embed(text):
    result = _http_json(
        f"{OLLAMA_URL}/api/embeddings",
        method="POST",
        headers={"Content-Type": "application/json"},
        body={"model": EMBED_MODEL, "prompt": text},
    )
    return result["embedding"]


def update_embedding(property_id, vector):
    url = f"{SUPABASE_URL}/rest/v1/propiedades?id=eq.{property_id}"
    headers = {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
    }
    req = urllib.request.Request(
        url,
        data=json.dumps({"descripcion_embedding": vector}).encode(),
        method="PATCH",
        headers=headers,
    )
    with urllib.request.urlopen(req, timeout=60):
        pass


def main():
    if not SUPABASE_URL or not SUPABASE_KEY:
        print("Falta SUPABASE_URL o SUPABASE_SERVICE_ROLE_KEY en el entorno.", file=sys.stderr)
        sys.exit(1)

    pending = fetch_pending_properties()
    if not pending:
        print("Nada pendiente: todas las propiedades con descripcion ya tienen embedding.")
        return

    print(f"{len(pending)} propiedad(es) sin embedding. Generando con {EMBED_MODEL}...")
    for row in pending:
        vector = embed(row["descripcion"])
        update_embedding(row["id"], vector)
        print(f"  OK: {row['id']}")

    print("Listo.")


if __name__ == "__main__":
    main()
