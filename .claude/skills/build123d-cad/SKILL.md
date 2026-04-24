---
name: build123d-cad
description: Generate parametric 3D CAD models in Python using build123d. Exports STEP, STL, and DXF. Use when the user wants to script a CAD part or assembly (brackets, frames, enclosures, shelves) that may need to be cut, machined, or welded.
---

# build123d CAD

`build123d` is a Pythonic parametric CAD library built on Open Cascade. Prefer it over OpenSCAD/CadQuery when the user wants BREP geometry they can export to STEP for manufacturers.

## Minimum viable pattern

```python
from build123d import BuildPart, Box, Cylinder, Mode, export_step

with BuildPart() as p:
    Box(100, 50, 20)
    Cylinder(10, 30, mode=Mode.SUBTRACT)  # hole through

export_step(p.part, "output/part.step")
```

## Key idioms

- **Context managers**: `BuildPart`, `BuildSketch`, `BuildLine` - add geometry inside `with` blocks.
- **Modes**: `Mode.ADD` (default), `Mode.SUBTRACT`, `Mode.INTERSECT`.
- **Positioning**: `Pos(x, y, z)` or `Location((x,y,z), (rx,ry,rz))` placed above a shape.
- **Assemblies**: `Compound(children=[part1, part2, ...])` - export as one STEP.
- **Rotation after creation**: `part.rotate(Axis.Z, 45)` returns a new Part.
- **Translation**: `part.moved(Location((dx,dy,dz)))`.

## Exports

```python
from build123d import export_step, export_stl
export_step(part, "out.step")       # for FreeCAD, manufacturers
export_stl(part, "out.stl")         # for 3D print, mesh viewers
# DXF: flatten a face first, then use ezdxf
```

## When to reach for other tools

- Need laser-cut 2D only? Use `ezdxf` directly - faster, no BREP overhead.
- Need interactive preview? Pair with OCP CAD Viewer in VS Code, or export STEP and open in FreeCAD.
- Need drawings with dimensions + welding symbols? Export STEP, open in FreeCAD, use TechDraw.

## Installed location in this repo

Virtual env: `metal-shelving/venv/`. Run scripts with:

```
metal-shelving/venv/bin/python <script>.py
```

## References

- Main repo: https://github.com/gumyr/build123d
- Docs: https://build123d.readthedocs.io/
- Cookbook: https://github.com/khaledelhady44/Build123d-Cookbook
- Awesome list: https://github.com/phillipthelen/awesome-build123d
