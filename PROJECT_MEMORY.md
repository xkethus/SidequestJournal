# PROJECT_MEMORY — SidequestJournal (fuente rápida de contexto)

Este archivo existe para que el asistente pueda re‑cargar el contexto del proyecto sin depender de memoria conversacional.

## TL;DR
App iOS (iOS 17) offline‑first: cada día a una **hora fija configurable** (default sugerido 07:00) asigna un **reto aleatorio** (Sidequest) desde catálogo local. Usuario completa con **evidencia obligatoria** (texto/foto/video/audio) y define visibilidad **Privada/Pública**. Al completar, desbloquea **medalla por reto** y ve catálogo completo de medallas.

## Reglas núcleo
- “Día de la app” inicia a la hora configurada (ej. 07:00→06:59).
- Anti-repetición: no reasignar reto en < 30 días.
- Evidencia obligatoria (Sprint 1: texto).
- Nivel global: 5/15/30 completados → niveles 1/2/3 con tint ultra sutil.
- Portada Hoy usa **templates** (4 maquetados) para variar layout.

## Dev UX (solo DEBUG)
En la pantalla Hoy aparece un control **colapsable** (botón “DEV”) para previsualizar:
- **Random Reto** (ver diferentes prompts)
- Botones A/B/C/D (forzar template)
- **Auto** (volver a comportamiento normal)

Nota: se quitó “Random Estilo” porque ahora el template se asigna por challenge desde el catálogo.

## Rutas importantes
- Proyecto raíz: `~/Desktop/Projects/SidequestJournal/`
- Xcode: `app/SidequestJournal/SidequestJournal.xcodeproj`
- Código: `app/SidequestJournal/SidequestJournal/`
- Catálogo (bundle): `app/SidequestJournal/SidequestJournal/Resources/challenges.json`
  - Extensiones recientes: `categories[].shortName`, `challenges[].durationMinutes`, `challenges[].cover { template, imageName }`.
- Assets covers (placeholders): `app/SidequestJournal/SidequestJournal/Assets.xcassets/CoverA-D.imageset`
- Documentación MVP: `docs/`

## Documentación (lee esto primero)
- `docs/MVP.md`
- `docs/Arquitectura.md`
- `docs/ModeloDeDatos.md`
- `docs/Backlog.md`

## Nota
Si falta contexto, busca primero en `docs/` y en el catálogo JSON. Este archivo es el índice.
