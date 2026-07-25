# Runbook de recuperación ante desastres

Qué hacer si el servidor Kimsufi muere, se corrompe, o hay que migrar a
otro host. **Sin este documento, tener backups no sirve de nada** — un
backup que nadie sabe restaurar es solo un archivo grande sin uso.

## Orden de prioridad para restaurar (no es arbitrario)

El problema del huevo y la gallina: **Vaultwarden guarda las contraseñas
de todo lo demás, pero Vaultwarden en sí también hay que restaurarlo
primero.** Por eso:

1. **Vaultwarden** (sus datos están en el backup de Duplicati como
   cualquier otro volumen — `oro-fase6-seguridad_vaultwarden-data`)
2. Con Vaultwarden arriba, sacar de ahí todas las contraseñas de las
   demás fases (por eso `scripts/gen-secrets.sh` insiste en cargarlas ahí
   apenas se generan — si nunca se cargaron, este paso 1 no sirve)
3. **Bases de datos** (Postgres/MySQL de cada fase) antes que las apps que
   dependen de ellas
4. El resto de las apps

## Requisito previo (que hay que tener ANTES de que algo se rompa)

- Duplicati configurado con destino externo real (S3/Drive/Backblaze —
  no alcanza con backups solo en el mismo disco del servidor que se rompió)
- Syncthing (Fase 6) sincronizando esos backups a una segunda máquina
  física, no solo al mismo datacenter
- **Un export periódico de Vaultwarden** (Vaultwarden tiene función de
  exportar el vault cifrado desde su propia UI) guardado *fuera* de
  Vaultwarden mismo — si Vaultwarden se corrompe sin este export aparte,
  se pierde el acceso a todo lo demás. Programar esto como tarea manual
  mensual hasta que se automatice.

## Procedimiento paso a paso

### 1. Provisionar el servidor nuevo

Mismo proceso que la instalación original (ver README.md raíz): Ubuntu
24.04, Docker + Docker Compose, clonar este repo.

### 2. Restaurar Duplicati primero

```bash
# Instalar Duplicati standalone temporalmente (fuera de docker-compose)
# apuntando al MISMO destino (S3/Drive/etc) que ya estaba configurado,
# y restaurar los volúmenes de Docker ANTES de levantar cualquier compose.
```

Restaurar en este orden los volúmenes nombrados:
`oro-fase6-seguridad_vaultwarden-data` primero, después las bases de
datos (`*-db`), después el resto.

### 3. Levantar Fase 6 primero (Vaultwarden + Authentik)

```bash
cd compose/fase6-seguridad
cp .env.example .env
# Los secretos reales salen de lo restaurado, NO se regeneran con
# gen-secrets.sh (eso crearía secretos nuevos que no matchean los datos
# restaurados)
docker compose up -d vaultwarden
```

Entrar a Vaultwarden, confirmar que las contraseñas de las demás fases
están ahí (o restaurar desde el export periódico si Vaultwarden mismo se
perdió).

### 4. Levantar el resto de las fases en orden (0 → 9)

Con las contraseñas reales ya recuperadas de Vaultwarden, seguir el
`README.md` normal, pero usando esas contraseñas en cada `.env` en vez de
generar nuevas con `gen-secrets.sh`.

### 5. Verificar

```bash
./scripts/verify-ecosystem.sh
```

## Qué NO se puede recuperar así

- Datos generados entre el último backup exitoso y el momento de la
  falla (la ventana de pérdida depende de cada cuánto corre Duplicati —
  revisar la frecuencia configurada).
- Si nunca se hizo el export manual de Vaultwarden y Vaultwarden se
  corrompió al mismo tiempo que todo lo demás: hay que regenerar todos los
  secretos desde cero (`gen-secrets.sh` en cada fase) y reconfigurar cada
  servicio de nuevo — por eso el export periódico de Vaultwarden no es
  opcional.

## Probar esto ANTES de necesitarlo

Un runbook que nunca se probó es una suposición, no un plan. Apenas el
ecosistema esté estable en producción, hacer un simulacro: levantar un
segundo servidor de prueba y restaurar ahí un backup real, cronometrando
cuánto tarda todo el proceso.
