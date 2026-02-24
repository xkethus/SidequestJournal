# Modelo de datos (MVP)

## Catálogo (seed)
### Category
- `id: String` (ej. "salud")
- `name: String`
- `order: Int`

### Challenge
- `id: String`
- `title: String`
- `prompt: String`
- `categoryId: String`
- `badgeId: String`
- `isActive: Bool`

### Badge
- `id: String`
- `name: String`
- `categoryId: String`
- `icon: String` (SF Symbol sugerido, ej. "seal.fill")

## Persistencia (SwiftData)
### AppSettings (single row)
- `dailyResetHour: Int` (0-23)
- `dailyResetMinute: Int` (0-59)

### DailyAssignment
- `appDay: String` (YYYY-MM-DD)
- `challengeId: String`
- `assignedAt: Date`

### JournalEntry
- `id: UUID`
- `appDay: String`
- `challengeId: String`
- `createdAt: Date`
- `visibility: String` ("private"|"public")
- `note: String?`

### Evidence
- `id: UUID`
- `entryId: UUID`
- `type: String` ("text"|"photo"|"video"|"audio")
- `text: String?` (solo si type=text)
- `filePath: String?` (relativo a Documents)
- `createdAt: Date`

### BadgeUnlock
- `badgeId: String`
- `challengeId: String`
- `unlockedAt: Date`

Nota: el catálogo (Challenge/Category/Badge) se puede mantener en JSON para el MVP y solo persistir el estado del usuario.
