# Arquitectura (propuesta) — iOS 17

## Stack
- UI: **SwiftUI**
- Persistencia: **SwiftData**
- Multimedia: archivos locales en **Documents/** + referencias en SwiftData
- Notificaciones (opcional MVP): **UserNotifications** (local)

## Capas
- **Domain**: modelos lógicos (Challenge, Category, Assignment, Entry, Evidence, Badge)
- **Persistence**: SwiftData models + repositorios
- **Services**:
  - `DailyAssignmentService` (asignación diaria + anti-repetición)
  - `EvidenceStore` (guardar/leer archivos)
  - `NotificationService` (programar recordatorios)
- **UI**: Views + ViewModels

## Regla: “día de la app”
Definimos `appDayKey` basado en la hora configurada:
- Si hora = 07:00
- entonces cualquier timestamp entre 2026-02-21 07:00 y 2026-02-22 06:59 pertenece al **appDay = 2026-02-21**.

Esto evita inconsistencias con medianoche.

## Anti-repetición 30 días
Para asignar:
1) Construir lista de retos activos.
2) Excluir los que tengan `lastAssignedAppDay` dentro de los últimos 30 appDays.
3) Elegir aleatorio uniforme.
4) Persistir `DailyAssignment(appDay, challengeId, assignedAt)`.

Fallback: si el pool filtrado queda vacío (pocos retos), permitir el más antiguo.
