# SidequestJournal — mockups_web

Maquetas rápidas en HTML/CSS para validar layout/jerarquía visual (especialmente la pantalla **Hoy** con templates A/B/C/D) antes de implementarlo en SwiftUI.

## Cómo abrir
Opción simple (Finder):
- Abre `index.html` en el navegador.

Opción con server (recomendado para evitar temas de rutas/seguridad del navegador):
```bash
cd ~/Desktop/Projects/SidequestJournal/mockups_web
python3 -m http.server 5173
```
Luego abre: http://localhost:5173

## Qué puedes editar rápido
- Texto: Título / Prompt / Categoría
- Nivel: 0–3 (tint warm-gray ultra sutil)
- Template: A/B/C/D

## Nota
Estas maquetas intentan reflejar el `DesignSystem.swift` (spacing, hairline, B/N editorial + acento warm-gray) sin ser pixel-perfect.
La idea es aprobar estructura/jerarquía primero y luego traducir a SwiftUI.
