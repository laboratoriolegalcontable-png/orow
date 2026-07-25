# Fase 9 — Agenda de turnos

## Por qué EasyAppointments y no Cal.com

Se evaluaron ambas. **Cal.com** es más conocida y con más funciones, pero:
- Su soporte Docker es **mantenido por la comunidad, no oficial** de
  Cal.com Inc. ("use at your own risk", según el propio repo).
- No hay imagen prearmada — hay que clonar el repo y **compilar** un
  monorepo Next.js completo (proceso pesado, más lento, más frágil).
- Necesita credenciales SMTP configuradas desde el arranque.

**EasyAppointments** (`alextselegidis/easyappointments`) tiene imagen
oficial real en Docker Hub, publicada por el propio mantenedor del
proyecto, con MySQL. Consistente con el resto de Orosa Nexus (imagen
oficial, sin compilar nada). Tiene menos funciones que Cal.com pero cubre
lo esencial: agenda pública, disponibilidad por profesional, notificación
por email.

## Uso

Sirve para las tres áreas que mencionó el Doctor: consulta penal, visita a
propiedad, o reunión general con el estudio — todo desde un único link
público de reserva, sin coordinar a mano por WhatsApp.

Primer login: `http://localhost:8070` — el instalador web pide crear el
usuario admin en el primer acceso (no hay uno por defecto). Ahí se
configuran los servicios (tipos de consulta), profesionales, y el SMTP para
las notificaciones de turno (puede completarse después, no es obligatorio
al arrancar el contenedor como en Cal.com).

## Validación

```bash
curl -sf http://localhost:8070/ -o /dev/null && echo "EasyAppointments OK"
```
