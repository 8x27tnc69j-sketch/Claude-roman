---
name: metal-shelving-designer
description: End-to-end designer for a custom welded metal shelving unit (этажерка). Use when the user wants to design, plan cuts, or prepare welding drawings for a shelving rack made of steel square tube + sheet panels. Drives the parametric script in metal-shelving/scripts/etazherka.py and produces STEP, DXF, cut list, and welding notes.
---

# Metal Shelving Designer

Use this skill whenever the user asks to design, redesign, cut-list, or prepare fabrication drawings for a welded metal shelving unit.

## Typical intake questions (ask the user, one pass)

1. **Envelope** - width × depth × height in mm.
2. **Shelf count** and whether load is heavy (books, tools) or light (craft supplies).
3. **Frame profile** - square tube 20×20×1.5, 25×25×2, or 30×30×2 (default: 25×25×2).
4. **Shelf material** - 3 mm steel sheet / 10 mm plywood / 18 mm MDF.
5. **Joinery** - butt weld (simplest) or mitered 45° (cleaner).
6. **Extras** - rear diagonal brace, shelf lip, wheels, wall-mount holes.
7. **Finish** - primer + enamel, powder coat, raw + wax.

## Workflow

1. Open `metal-shelving/scripts/etazherka.py`, edit the `Params` dataclass to match the user's answers.
2. Run: `metal-shelving/venv/bin/python metal-shelving/scripts/etazherka.py`.
3. Inspect `metal-shelving/output/etazherka.step` (open in FreeCAD / online STEP viewer).
4. Review `metal-shelving/output/cut_list.md` with the user before fabrication.
5. If the user has FreeCAD MCP installed, open the STEP file and generate TechDraw 2D sheets with dimensions + welding symbols from `metal-shelving/welding-symbols/`.

## Fabrication rules of thumb

- **Weld sequence**: bottom frame → 4 legs → top frame → intermediate rails → shelves last.
- **Tack first**: 4 tacks per joint, check diagonals, then full weld.
- **Butt weld on 25×25×2**: 3 mm fillet, ~70-80 A MMA or short-arc MIG at 15-18 V.
- **Flatness**: weld on a steel plate or cast-iron table; opposite-corner tacks first reduce warp.
- **Grind & finish**: flap disc on welds → phosphate wipe → zinc primer → enamel.
- **Craft-supply load**: 20-30 kg per shelf is safe for 25×25×2 with 600 mm span.

## Output contract

Every design run should produce and reference:
- `output/etazherka.step` - 3D model
- `output/cut_list.md` - linear cut list with miter angles, sheet panels, BOM totals, weld notes
- Optional: DXF per shelf for laser/plasma cutting (use `ezdxf` if asked)

## What NOT to do

- Don't invent load ratings beyond the rules above - say "verify with engineer" for >50 kg/shelf.
- Don't omit the back brace unless the user says the unit will be wall-anchored.
- Don't round dimensions silently - always echo final numbers back to the user before exporting.
