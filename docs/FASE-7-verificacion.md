# Fase 7 — Verificación final y sincronización

## Cómo correrla

```bash
./scripts/verify-ecosystem.sh
```

Corre checks HTTP/CLI reales contra cada servicio de las Fases 1-6. No asume
nada instalado: lo que no responde se reporta como FALLO, no se omite en
silencio. Esto es intencional — un reporte que oculta lo que falta no sirve
para nada.

## Checklist manual (lo que el script no puede probar por curl)

- [ ] Coolify puede desplegar una app de prueba desde Git (probar desde la UI)
- [ ] Open WebUI responde preguntas usando Ollama como backend (probar un chat real en el navegador)
- [ ] Paperless-ngx hace OCR correctamente sobre un PDF escaneado real
- [ ] Las propiedades se guardan y se pueden consultar en Postgres (Fase 4)
- [ ] n8n puede enviar un email de prueba vía SMTP real
- [ ] Login en algún servicio usando Authentik como SSO (una vez conectado, ver Fase 6)
- [ ] Duplicati completó un backup de prueba sin errores
- [ ] AFRelay/facturación: no aplica todavía (ver Fase 6, pendiente de definición)

## Variables compartidas

Ver `ecosystem-state.example.json` → `variables_compartidas`. En el servidor
real, estas viven en `ecosystem-state.json` (gitignored, nunca se commitea) y
se actualizan a mano a medida que se conectan servicios entre sí (ej. cuando
se configura SMTP real para n8n, o cuando Authentik queda como SSO de un
servicio).

## Reporte de estado

En vez de un `panel-de-control.md` estático que queda desactualizado apenas
se instala algo nuevo, usar:

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

para ver el estado real y vivo de todos los contenedores, y
`./scripts/verify-ecosystem.sh` para el health-check completo. Ambos
reflejan la realidad del servidor en el momento en que se corren — un
Markdown estático no.
