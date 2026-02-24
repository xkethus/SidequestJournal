# MVP — Sidequest Journal (iOS 17)

## Objetivo
App iOS offline‑first para jóvenes adultos: cada día a una **hora fija configurable** (default 07:00) se asigna un **reto aleatorio** (Sidequest) desde una base local. El usuario lo completa subiendo **evidencia obligatoria** (texto/foto/video/audio) con visibilidad **Privada/Pública**. Al completar desbloquea **medallas por reto** y colección por **categorías**.

## Reglas del sistema (definidas)
- **Hora diaria configurable**: onboarding sugiere 07:00.
- **Día de la app**: ventana de 24h que inicia en la hora configurada (ej. 07:00→06:59).
- **Anti-repetición**: un reto no puede reasignarse si fue asignado en los últimos **30 días**.
- **Evidencia obligatoria**: mínimo 1 evidencia por reto completado.
- **Visibilidad**: private/public (en MVP solo estado local; social/feeds después).
- **Medallas**: por reto (badge único), agrupadas por categorías.

## Alcance MVP (incluye)
### Pantallas
1. **Hoy**: reto del día + estado.
2. **Completar**: capturar evidencia + visibilidad.
3. **Historial (Journal)**: lista por día.
4. **Detalle**: ver evidencia.
5. **Medallas**: grid por categoría.
6. **Settings**: hora diaria + notificaciones (si se implementa) + export/debug (opcional).

### Funcional
- Base de retos local (JSON) + motor de asignación.
- Persistencia local (SwiftData) + archivos en Documents para multimedia.

## Fuera de alcance (por ahora)
- Login/cuentas/sincronización multi‑device.
- Feed público real / social.
- Moderación / reportes.
- Monetización.

## Criterios de éxito (MVP)
- El usuario puede: ver reto del día → completar con evidencia → ver en historial → ver medalla desbloqueada.
