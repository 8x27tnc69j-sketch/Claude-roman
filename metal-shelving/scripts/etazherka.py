"""Parametric metal shelving unit (этажерка) generator.

Outputs:
  output/etazherka.step        - 3D model for FreeCAD/KiCad/online viewers
  output/etazherka_frame.dxf   - flat frame layout for reference
  output/cut_list.md           - linear cut list (lengths + miter angles) + BOM

Run:  ../venv/bin/python scripts/etazherka.py

Edit PARAMS below. All dimensions are in millimeters.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from build123d import (
    Axis,
    BuildPart,
    Box,
    Compound,
    Location,
    Mode,
    Part,
    Pos,
    export_step,
)


# -----------------------------------------------------------------------------
# PARAMETERS - edit these, rerun the script
# -----------------------------------------------------------------------------
@dataclass
class Params:
    # Overall envelope (outer)
    width: float = 600.0       # ширина (X)
    depth: float = 400.0       # глубина (Y)
    height: float = 1500.0     # высота (Z)

    # Shelves
    shelf_count: int = 4                    # включая нижнюю и верхнюю
    shelf_thickness: float = 3.0            # толщина полки (лист 3 мм)
    shelf_material: str = "steel_sheet_3mm"

    # Frame profile (square tube)
    tube_size: float = 25.0          # 25x25 мм профильная труба
    tube_wall: float = 2.0           # стенка 2 мм (для BOM)
    tube_material: str = "steel_square_tube_25x25x2"

    # Assembly options
    include_back_brace: bool = True   # диагональ жёсткости сзади
    include_shelf_lip: bool = False   # бортик на полках (для баночек)
    lip_height: float = 15.0


P = Params()


# -----------------------------------------------------------------------------
# PART LIBRARY - each function returns (Part, metadata dict)
# -----------------------------------------------------------------------------
def sq_tube(length: float) -> Part:
    """Square tube modelled as a solid box (для визуализации/раскроя достаточно)."""
    with BuildPart() as p:
        Box(P.tube_size, P.tube_size, length)
    return p.part


def shelf_panel(width: float, depth: float) -> Part:
    with BuildPart() as p:
        Box(width, depth, P.shelf_thickness)
    return p.part


# -----------------------------------------------------------------------------
# ASSEMBLY
# -----------------------------------------------------------------------------
def build() -> tuple[Compound, list[dict]]:
    cut_list: list[dict] = []
    parts: list[Part] = []

    # 4 vertical legs (stoyki)
    leg_len = P.height
    for i, (x, y) in enumerate([(-1, -1), (1, -1), (1, 1), (-1, 1)]):
        leg = sq_tube(leg_len)
        px = x * (P.width / 2 - P.tube_size / 2)
        py = y * (P.depth / 2 - P.tube_size / 2)
        parts.append(leg.moved(Location((px, py, 0))))
        cut_list.append({
            "part": f"leg_{i+1}",
            "profile": P.tube_material,
            "length_mm": leg_len,
            "cut_ends": "straight",
            "qty": 1,
        })

    # Horizontal frame at each shelf level
    z_levels = [
        -P.height / 2 + P.shelf_thickness / 2 + (i * (P.height - P.shelf_thickness) / (P.shelf_count - 1))
        for i in range(P.shelf_count)
    ]

    rail_len_x = P.width - 2 * P.tube_size   # between legs, X direction
    rail_len_y = P.depth - 2 * P.tube_size   # between legs, Y direction

    for level, z in enumerate(z_levels):
        # 2 rails along X (front + back)
        for y_sign in (-1, 1):
            r = sq_tube(rail_len_x)
            # rotate to lie along X
            r = r.rotate(Axis.Y, 90)
            py = y_sign * (P.depth / 2 - P.tube_size / 2)
            parts.append(r.moved(Location((0, py, z))))
            cut_list.append({
                "part": f"rail_x_lvl{level+1}_{'front' if y_sign < 0 else 'back'}",
                "profile": P.tube_material,
                "length_mm": rail_len_x,
                "cut_ends": "straight (butt weld to legs)",
                "qty": 1,
            })
        # 2 rails along Y (left + right)
        for x_sign in (-1, 1):
            r = sq_tube(rail_len_y)
            r = r.rotate(Axis.X, 90)
            px = x_sign * (P.width / 2 - P.tube_size / 2)
            parts.append(r.moved(Location((px, 0, z))))
            cut_list.append({
                "part": f"rail_y_lvl{level+1}_{'left' if x_sign < 0 else 'right'}",
                "profile": P.tube_material,
                "length_mm": rail_len_y,
                "cut_ends": "straight (butt weld to legs)",
                "qty": 1,
            })

        # Shelf panel lying on rails
        panel_w = P.width - 2 * P.tube_size
        panel_d = P.depth - 2 * P.tube_size
        panel = shelf_panel(panel_w, panel_d)
        panel_z = z + P.tube_size / 2 + P.shelf_thickness / 2
        parts.append(panel.moved(Location((0, 0, panel_z))))
        cut_list.append({
            "part": f"shelf_panel_lvl{level+1}",
            "profile": P.shelf_material,
            "length_mm": panel_w,
            "width_mm": panel_d,
            "cut_ends": "laser/plasma DXF",
            "qty": 1,
        })

    # Optional rear diagonal brace
    if P.include_back_brace:
        from math import atan2, degrees, hypot
        brace_dx = P.width - 2 * P.tube_size
        brace_dz = P.height - P.tube_size
        brace_len = hypot(brace_dx, brace_dz)
        angle = degrees(atan2(brace_dz, brace_dx))
        brace = sq_tube(brace_len)
        brace = brace.rotate(Axis.Y, 90 - angle)
        py = P.depth / 2 - P.tube_size / 2
        parts.append(brace.moved(Location((0, py, 0))))
        cut_list.append({
            "part": "rear_diagonal_brace",
            "profile": P.tube_material,
            "length_mm": round(brace_len, 1),
            "cut_ends": f"both ends mitered ~{round(angle, 1)}°",
            "qty": 1,
        })

    asm = Compound(children=parts)
    return asm, cut_list


# -----------------------------------------------------------------------------
# EXPORTERS
# -----------------------------------------------------------------------------
def export_cut_list_md(cut_list: list[dict], out_path: Path) -> None:
    lines = [
        "# Карта раскроя и ведомость материалов",
        "",
        f"**Габариты этажерки:** {P.width} × {P.depth} × {P.height} мм (Ш × Г × В)",
        f"**Полок:** {P.shelf_count}",
        f"**Профиль рамы:** {P.tube_material}",
        f"**Материал полок:** {P.shelf_material}",
        "",
        "## Ведомость элементов",
        "",
        "| # | Деталь | Профиль/Материал | Длина, мм | Ширина, мм | Тип реза | Кол-во |",
        "|---|--------|------------------|-----------|------------|----------|--------|",
    ]
    for i, it in enumerate(cut_list, 1):
        lines.append(
            f"| {i} | {it['part']} | {it['profile']} | "
            f"{it['length_mm']} | {it.get('width_mm', '-')} | "
            f"{it['cut_ends']} | {it['qty']} |"
        )

    # Totals
    total_tube_mm = sum(
        it["length_mm"] for it in cut_list if it["profile"] == P.tube_material
    )
    total_sheet_area = sum(
        it["length_mm"] * it.get("width_mm", 0)
        for it in cut_list
        if it["profile"] == P.shelf_material
    )
    lines += [
        "",
        "## Итого",
        "",
        f"- **Профильная труба:** {total_tube_mm:.0f} мм = {total_tube_mm/1000:.2f} м",
        f"- **Листовая сталь 3 мм:** {total_sheet_area/1_000_000:.3f} м²",
        "",
        "## Рекомендации по сварке",
        "",
        "- Все стыки рамы — прихватка в 4 точках, затем сплошной шов по периметру.",
        "- Угловые соединения: стыковой шов с катетом 3 мм (профиль 25×25×2).",
        "- Перед сваркой выставить раму на ровной плите, зафиксировать струбцинами.",
        "- Последовательность: нижняя рамка → 4 стойки → верхняя рамка → промежуточные → полки.",
        "- После сварки: болгаркой снять наплывы, обезжирить, грунт + эмаль.",
        "",
    ]
    out_path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    out_dir = Path(__file__).parent.parent / "output"
    out_dir.mkdir(exist_ok=True)

    asm, cut_list = build()

    step_path = out_dir / "etazherka.step"
    export_step(asm, str(step_path))
    print(f"[ok] STEP: {step_path}")

    cut_list_path = out_dir / "cut_list.md"
    export_cut_list_md(cut_list, cut_list_path)
    print(f"[ok] Cut list: {cut_list_path}")

    print()
    print(f"Parts total: {len(cut_list)}")
    print(f"Envelope: {P.width} x {P.depth} x {P.height} mm")


if __name__ == "__main__":
    main()
