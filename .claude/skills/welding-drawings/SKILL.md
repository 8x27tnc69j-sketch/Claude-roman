---
name: welding-drawings
description: Produce fabrication drawings for welded steel assemblies - cut lists, weld symbols (ISO 2553 / AWS A2.4), part callouts, and fitter instructions. Use when the user needs drawings a welder can actually work from.
---

# Welding Drawings

This skill produces drawings a workshop welder can use without follow-up questions.

## Required elements on every welding drawing

1. **Overall views**: front + side + top + isometric.
2. **Overall dimensions**: outer envelope W × D × H.
3. **Part callout balloons**: number each piece (matches cut list).
4. **Weld symbols** per ISO 2553 or AWS A2.4:
   - Fillet weld: triangle on reference line, size on left (e.g. `a3` = 3 mm throat).
   - All-around: circle at the arrow/reference junction.
   - Field weld: flag at the junction.
   - Intermittent: `a3 ▲ 40-100` = 3 mm fillet, 40 mm long, every 100 mm.
5. **Weld sequence** notes (numbered 1, 2, 3…).
6. **Material list** (BOM) with profile, length, quantity.
7. **Finish notes**: grind flush / leave proud / prime + paint.
8. **Tolerance block**: ±1 mm linear, ±0.5° angular (default for hand-welded frames).

## Symbol library

Pre-vendored at `metal-shelving/welding-symbols/` (from github.com/88blazer88/Welding-Symbols):
- `weld symbols project.dxf` - main symbol block library
- `aux weld symbols.tar.gz` - auxiliary/supplemental symbols
- `Weld Symbol Position Chart.dxf` - cheat sheet showing arrow/reference placement

Insert as DXF blocks into FreeCAD TechDraw or LibreCAD.

## Shorthand welder can read

```
a3 ▲ - 3 mm fillet, continuous
a3 ▲ 40-100 - 3 mm fillet, 40 mm stitches at 100 mm pitch
a4 ▽ ○ - 4 mm fillet, all around
a3 ▽ ▲ - 3 mm fillet both sides
```

## Typical flow for this repo

1. Generate STEP from `etazherka.py`.
2. Open STEP in FreeCAD.
3. Switch to TechDraw workbench, create a page (ISO A3 landscape recommended).
4. Drop 4 projections (front / top / side / iso).
5. Add dimensions - double-click each to clean up arrows.
6. Use File → Insert DXF to bring in weld symbols from `welding-symbols/`.
7. Place symbols on joints, write lengths.
8. Export page as PDF - hand to the welder.

## Do not

- Do not use AWS and ISO symbols on the same sheet - pick one.
- Do not omit weld size - a bare triangle is ambiguous.
- Do not specify full-penetration welds on 2 mm wall tube - it will burn through.
