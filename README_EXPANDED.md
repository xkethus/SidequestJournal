# SidequestJournal — README ampliado

## 1) Concepto
SidequestJournal es una app iOS (iOS 17) de hábitos/journal. Cada día a una hora fija configurable, el usuario recibe un reto (“Sidequest”) tomado de un catálogo local, lo completa con evidencia y desbloquea medallas.

## 2) Loop diario
1. A la hora elegida (default 07:00) se fija el reto del día (offline-first; se consolida al abrir la app).
2. Usuario completa el reto.
3. Sube evidencia (mínimo 1): texto/foto/video/audio (MVP inicial: texto).
4. Elige visibilidad: privada/pública.
5. Se guarda la entrada en Journal y se desbloquea la medalla correspondiente.

## 3) Sistema de nivel (global)
- Nivel 1: 5 completados
- Nivel 2: 15 completados
- Nivel 3: 30 completados

El nivel impacta tint/tono de UI de forma ultra sutil (B/N editorial con acento warm-gray).

## 4) Implementación
- SwiftUI + SwiftData.
- Catálogo en JSON (seed) + persistencia del estado del usuario.
- Multimedia se guardará como archivos locales en Documents/ (Sprint 2).

## 5) Archivos
- `docs/` documentación
- `data/challenges.json` catálogo fuente
- `PROJECT_MEMORY.md` índice de contexto

## 6) Próximo sprint
- UI Hoy (templates A/B/C/D) refinados + jerarquía final
- Evidencia multimedia (foto/audio/video)
- Completar Sidequest: selector de tipo de evidencia con estilo editorial
- Medallas en grid + estados locked/unlocked más ricos
