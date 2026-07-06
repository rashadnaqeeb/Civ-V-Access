"""Render a dump_map reply to a PNG for the consuming agent's eyes.

The image is a gestalt aid: it shows the shapes -- coastlines, how a
border winds, where an empire wraps around a bay -- that the structured
payloads describe numerically. It is deliberately NOT a data source: the
agent guide requires every number, distance, and direction spoken to the
player to come from the data tools' hex-math fields, never read off the
image.

Geometry matches civ5_geometry.HexMap: pointy-top hexes, odd rows shifted
right by half a hex, column step sqrt(3) * s, row step 1.5 * s. Map north
(higher y) is the top of the image.

Requires Pillow; the server imports this module lazily so everything else
works without it.
"""

import io
import math

from PIL import Image, ImageDraw, ImageFont

SQRT3 = math.sqrt(3)

TERRAIN_COLORS = {
    "TERRAIN_GRASS": (104, 156, 72),
    "TERRAIN_PLAINS": (198, 178, 110),
    "TERRAIN_DESERT": (238, 214, 160),
    "TERRAIN_TUNDRA": (148, 148, 132),
    "TERRAIN_SNOW": (238, 240, 244),
    "TERRAIN_COAST": (110, 170, 214),
    "TERRAIN_OCEAN": (46, 86, 150),
}
UNKNOWN_TERRAIN = (150, 150, 150)
UNREVEALED = (30, 30, 34)
MOUNTAIN_COLOR = (78, 64, 56)
RIVER_COLOR = (28, 88, 205)
CURSOR_COLOR = (255, 40, 40)
WONDER_COLOR = (235, 60, 235)
FOG_GRAY = 112
FOG_KEEP = 0.45  # fraction of the tile's own color kept under fog

FEATURE_COLORS = {
    "FEATURE_FOREST": (30, 88, 38),
    "FEATURE_JUNGLE": (18, 62, 24),
    "FEATURE_MARSH": (72, 112, 92),
    "FEATURE_ICE": (222, 236, 246),
    "FEATURE_FLOOD_PLAINS": (168, 188, 92),
    "FEATURE_OASIS": (56, 172, 122),
    "FEATURE_ATOLL": (120, 210, 190),
}

YOU_COLOR = (255, 255, 255)
CIV_PALETTE = [
    (225, 40, 40),
    (255, 145, 0),
    (155, 60, 205),
    (0, 205, 225),
    (235, 60, 180),
    (245, 225, 40),
    (145, 92, 40),
    (255, 155, 175),
    (125, 235, 60),
    (0, 150, 130),
    (0, 0, 0),  # never blue: rivers own that hue on the map
    (170, 170, 170),
]

# Pointy-top corner offsets in image coords (y down; map north = image
# top), unit circumradius: TOP, UPPER-RIGHT, LOWER-RIGHT, BOTTOM,
# LOWER-LEFT, UPPER-LEFT.
_CORNERS = [
    (0.0, -1.0),
    (SQRT3 / 2, -0.5),
    (SQRT3 / 2, 0.5),
    (0.0, 1.0),
    (-SQRT3 / 2, 0.5),
    (-SQRT3 / 2, -0.5),
]
# River bits from the dump (east / southeast / southwest edge) -> the
# corner pair bounding that edge. South is toward larger image y.
_RIVER_EDGES = {1: (1, 2), 2: (2, 3), 4: (3, 4)}

MAX_LONG_SIDE = 1600
MIN_HEX = 5
MAX_HEX = 34


def _font(size):
    try:
        return ImageFont.load_default(size=size)
    except TypeError:  # older Pillow: fixed-size bitmap font only
        return ImageFont.load_default()


def _blend(a, b, keep):
    return tuple(round(keep * ca + (1 - keep) * cb) for ca, cb in zip(a, b))


def _scale(color, factor):
    return tuple(min(255, round(c * factor)) for c in color)


def _fog(color):
    return _blend(color, (FOG_GRAY, FOG_GRAY, FOG_GRAY), FOG_KEEP)


def civ_colors(m):
    """Stable player-id -> color assignment; you are always white."""
    owned_ids = sorted(
        {pid for pid in m.owner_legend.values() if pid is not None}
    )
    city_owner_ids = sorted({c["owner"] for c in m.cities})
    colors = {}
    i = 0
    for pid in owned_ids + [p for p in city_owner_ids if p not in owned_ids]:
        if pid in colors:
            continue
        if pid == m.me:
            colors[pid] = YOU_COLOR
        else:
            colors[pid] = CIV_PALETTE[i % len(CIV_PALETTE)]
            i += 1
    return colors


def _view_window(m, center, radius):
    """(virtual columns, rows, crosses_seam). Virtual columns can run
    past the seam on a wrapping map; the caller folds them with % width."""
    if center is None:
        return list(range(m.width)), list(range(m.height)), False
    cx, cy = center
    cx %= m.width
    if m.hex.wrap_x and 2 * radius + 1 < m.width:
        cols = list(range(cx - radius, cx + radius + 1))
        crosses = cols[0] < 0 or cols[-1] >= m.width
    else:
        cols = list(range(max(0, cx - radius), min(m.width, cx + radius + 1)))
        crosses = False
    rows = list(range(max(0, cy - radius), min(m.height, cy + radius + 1)))
    return cols, rows, crosses


def render_png(m, center=None, radius=None):
    """Render the revealed map (or the region around center) to PNG.
    Returns (png_bytes, meta) where meta carries the view bounds and the
    color legend the agent needs to read the image."""
    cols, rows, crosses_seam = _view_window(m, center, radius)

    margin_l, margin_r, margin_t, margin_b = 34, 12, 12, 26
    avail = MAX_LONG_SIDE
    s = min(
        (avail - margin_l - margin_r) / (SQRT3 * (len(cols) + 0.5)),
        (avail - margin_t - margin_b) / (1.5 * len(rows) + 0.5),
        MAX_HEX,
    )
    s = max(MIN_HEX, s)
    img_w = math.ceil(SQRT3 * s * (len(cols) + 0.5)) + margin_l + margin_r
    img_h = math.ceil(1.5 * s * len(rows) + 0.5 * s) + margin_t + margin_b
    img = Image.new("RGB", (img_w, img_h), (12, 12, 14))
    draw = ImageDraw.Draw(img)

    y_top = rows[-1]

    def pixel_center(vx, y):
        px = margin_l + SQRT3 * s * ((vx - cols[0]) + 0.5 * (y % 2) + 0.5)
        py = margin_t + 1.5 * s * (y_top - y) + s
        return px, py

    def fold_x(vx):
        return vx % m.width if m.hex.wrap_x else vx

    def corners(px, py):
        return [(px + s * dx, py + s * dy) for dx, dy in _CORNERS]

    colors = civ_colors(m)

    # Pass 1: tile fills, feature glyphs, terrain relief marks.
    for y in rows:
        for vx in cols:
            x = fold_x(vx)
            px, py = pixel_center(vx, y)
            poly = corners(px, py)
            if not m.revealed(x, y):
                draw.polygon(poly, fill=UNREVEALED)
                continue
            info = m.terrain_legend.get(m.terrain[y][x])
            fill = TERRAIN_COLORS.get(info["type"], UNKNOWN_TERRAIN) if info else UNKNOWN_TERRAIN
            plot = m.plot[y][x]
            if plot == "M":
                fill = _blend(MOUNTAIN_COLOR, fill, 0.75)
            elif plot == "H":
                fill = _scale(fill, 0.78)
            fogged = m.vis[y][x] == "0"
            if fogged:
                fill = _fog(fill)
            draw.polygon(poly, fill=fill)
            feat = m.feature_legend.get(m.feature[y][x])
            if feat:
                glyph = FEATURE_COLORS.get(feat["type"], (60, 60, 60))
                if fogged:
                    glyph = _fog(glyph)
                r = s * 0.32
                draw.ellipse([px - r, py - r, px + r, py + r], fill=glyph)
            if plot == "M" and s >= 8:
                peak = (255, 255, 255) if not fogged else _fog((255, 255, 255))
                draw.polygon(
                    [(px, py - s * 0.45), (px - s * 0.35, py + s * 0.3),
                     (px + s * 0.35, py + s * 0.3)],
                    outline=peak,
                )

    # Pass 2: rivers along their exact edges. Deliberately thinner than
    # territory borders so the two families of colored edges can't be
    # confused at any zoom level.
    river_w = max(2, round(s / 9))
    for y in rows:
        for vx in cols:
            x = fold_x(vx)
            if not m.revealed(x, y):
                continue
            bits = m.river[y][x]
            if bits in ("?", "0"):
                continue
            px, py = pixel_center(vx, y)
            pts = corners(px, py)
            for bit, (a, b) in _RIVER_EDGES.items():
                if int(bits) & bit:
                    draw.line([pts[a], pts[b]], fill=RIVER_COLOR, width=river_w)

    # Pass 3: ownership borders on edges where the owner changes.
    border_w = max(2, round(s * 0.22))
    for y in rows:
        for vx in cols:
            x = fold_x(vx)
            if not m.revealed(x, y):
                continue
            owner = m.owner_id(x, y)
            if owner is None:
                continue
            ax, ay = pixel_center(vx, y)
            for nx, ny in m.hex.neighbors(x, y):
                if m.revealed(nx, ny) and m.owner_id(nx, ny) == owner:
                    continue
                dcol, drow = m.hex.displacement(x, y, nx, ny)
                bx, by = ax + SQRT3 * s * dcol, ay - 1.5 * s * drow
                mx, my = (ax + bx) / 2, (ay + by) / 2
                # pull the edge slightly toward the owner's side
                mx += (ax - mx) * 0.16
                my += (ay - my) * 0.16
                vx_, vy_ = bx - ax, by - ay
                norm = math.hypot(vx_, vy_) or 1.0
                ex, ey = -vy_ / norm * s / 2, vx_ / norm * s / 2
                draw.line(
                    [(mx - ex, my - ey), (mx + ex, my + ey)],
                    fill=colors.get(owner, UNKNOWN_TERRAIN),
                    width=border_w,
                )

    label_font = _font(max(10, min(14, round(s))))
    small_font = _font(max(8, min(11, round(s * 0.7))))

    # Pass 4: resources (zoomed views only -- they need room to read).
    if s >= 14:
        for r in m.resources:
            if not _in_view(m, r["x"], r["y"], cols, rows):
                continue
            name = m.resource_types.get(r.get("t"), {}).get("name")
            if not name:
                continue
            vx = _virtual_col(m, r["x"], cols)
            px, py = pixel_center(vx, r["y"])
            draw.text(
                (px, py - s * 0.55), name[:4], fill=(120, 20, 20),
                font=small_font, anchor="mm", stroke_width=1,
                stroke_fill=(255, 255, 255),
            )

    # Pass 5: natural wonders, cities, cursor.
    for w in m.natural_wonders:
        if not _in_view(m, w["x"], w["y"], cols, rows):
            continue
        vx = _virtual_col(m, w["x"], cols)
        px, py = pixel_center(vx, w["y"])
        r = s * 0.4
        draw.polygon(
            [(px, py - r), (px + r, py + r), (px - r, py + r)],
            fill=WONDER_COLOR, outline=(0, 0, 0),
        )
    for c in m.cities:
        if not _in_view(m, c["x"], c["y"], cols, rows):
            continue
        vx = _virtual_col(m, c["x"], cols)
        px, py = pixel_center(vx, c["y"])
        r = s * 0.42
        color = colors.get(c["owner"], UNKNOWN_TERRAIN)
        draw.ellipse([px - r, py - r, px + r, py + r], fill=color,
                     outline=(0, 0, 0), width=2)
        if c.get("capital"):
            r2 = r * 0.45
            draw.ellipse([px - r2, py - r2, px + r2, py + r2],
                         fill=(0, 0, 0))
        if s >= 8:
            draw.text((px, py + s * 0.95), c["name"], fill=(255, 255, 255),
                      font=label_font, anchor="mm", stroke_width=2,
                      stroke_fill=(0, 0, 0))
    if m.cursor and _in_view(m, m.cursor["x"], m.cursor["y"], cols, rows):
        vx = _virtual_col(m, m.cursor["x"], cols)
        px, py = pixel_center(vx, m.cursor["y"])
        arm = s * 1.1
        for dx, dy in ((arm, 0), (0, arm)):
            draw.line([(px - dx, py - dy), (px + dx, py + dy)],
                      fill=CURSOR_COLOR, width=max(2, round(s / 7)))

    # Axis labels: map coordinates so the image and the payloads line up.
    step = 2 if len(cols) <= 24 else 5
    axis_font = _font(10)
    for vx in cols:
        x = fold_x(vx)
        if x % step:
            continue
        px = margin_l + SQRT3 * s * ((vx - cols[0]) + 0.5)
        draw.text((px, img_h - margin_b / 2), str(x), fill=(170, 170, 170),
                  font=axis_font, anchor="mm")
    for y in rows:
        if y % step:
            continue
        _, py = pixel_center(cols[0], y)
        draw.text((margin_l / 2, py), str(y), fill=(170, 170, 170),
                  font=axis_font, anchor="mm")

    buf = io.BytesIO()
    img.save(buf, format="PNG")

    meta = {
        "view": {
            "xFrom": fold_x(cols[0]),
            "xTo": fold_x(cols[-1]),
            "yFrom": rows[0],
            "yTo": rows[-1],
            "crossesWrapSeam": crosses_seam,
            "wholeMap": center is None,
        },
        "hexSizePx": round(s, 1),
        "civColors": {
            m.civ_name(pid): "#%02x%02x%02x" % col
            for pid, col in colors.items()
        },
        "reading": (
            "North is the top of the image; odd rows sit half a hex right "
            "of even rows. Dark charcoal is unexplored; grayed tiles are "
            "fogged (remembered, possibly stale). Colored hex edges are "
            "territory borders (see civColors; white is the player). "
            "Circles are cities (black core = capital), blue edge lines "
            "are rivers, white-outlined peaks are mountains, dark round "
            "glyphs are forest or jungle, magenta triangles are natural "
            "wonders, a red crosshair is the player's cursor. Axis "
            "numbers are map coordinates for follow-up data calls. Use "
            "the image only for shapes and layout; every number, "
            "distance, or direction spoken must come from the data tools."
        ),
    }
    return buf.getvalue(), meta


def _virtual_col(m, x, cols):
    """The virtual column in `cols` that folds to map column x."""
    if not m.hex.wrap_x:
        return x
    for vx in (x, x - m.width, x + m.width):
        if cols[0] <= vx <= cols[-1]:
            return vx
    return x


def _in_view(m, x, y, cols, rows):
    if not rows[0] <= y <= rows[-1]:
        return False
    if m.hex.wrap_x:
        return any(cols[0] <= vx <= cols[-1]
                   for vx in (x, x - m.width, x + m.width))
    return cols[0] <= x <= cols[-1]
