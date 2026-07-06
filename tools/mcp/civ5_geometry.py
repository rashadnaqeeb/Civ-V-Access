"""Spatial analysis over the Lua bridge's dump_map reply.

Turns the raw layer grids into the structures a map narration needs:
landmasses, terrain zones, structural regions, water bodies, civ positions
and politics, border neighborhoods, settleable land, war reports, and local
region descriptions. All hex math mirrors the mod's CivVAccess_HexGeom.lua
exactly -- odd-row offset coordinates, cube distance, X-wrap folding to the
shortest delta, and a pointy-top pixel bearing binned to the 8-point
compass -- so distances and directions here agree with what the in-game
scanner speaks.

Everything is described relationally: each result carries an `anchor`
(the player's capital by default; the mod's cursor, any known city, or a
raw coordinate on request) and items carry distanceFromAnchor /
directionFromAnchor plus, where useful, the player's nearest own city.
Raw x/y stay in payloads only so follow-up calls can target them.

Fog honesty: "?" cells (unrevealed) are never analyzed. Components that
touch unrevealed cells are flagged, so a landmass reads "at least N tiles,
continuing into unexplored territory" rather than a false exact size.
"""

import math
from collections import Counter, deque

COMPASS = [
    "east", "northeast", "north", "northwest",
    "west", "southwest", "south", "southeast",
]

# Water bodies smaller than this are lakes (the engine's own threshold:
# MIN_WATER_SIZE_FOR_OCEAN = 10).
LAKE_MAX_TILES = 9

LAND_CHARS = frozenset("FHM")


# === Hex math (mirrors CivVAccess_HexGeom.lua) ===


def _offset_to_axial(col, row):
    return col - (row - (row % 2)) // 2, row


def _axial_to_offset(q, r):
    return q + (r - (r % 2)) // 2, r


# Axial neighbor steps: E, NE, NW, W, SW, SE.
_AXIAL_STEPS = ((1, 0), (0, 1), (-1, 1), (-1, 0), (0, -1), (1, -1))


class HexMap:
    """Coordinate services for one map's dimensions and wrap mode."""

    def __init__(self, width, height, wrap_x):
        self.width = width
        self.height = height
        self.wrap_x = wrap_x

    def fold(self, from_x, from_y, to_x, to_y):
        """Nearest virtual (to_x, to_y) relative to (from_x, from_y)
        across X wrap; the delta from the fold is the shortest one."""
        dx = to_x - from_x
        if self.wrap_x:
            half = self.width / 2
            if dx > half:
                dx -= self.width
            elif dx < -half:
                dx += self.width
        return from_x + dx, to_y

    def distance(self, from_x, from_y, to_x, to_y):
        to_x, to_y = self.fold(from_x, from_y, to_x, to_y)
        aq, ar = _offset_to_axial(from_x, from_y)
        bq, br = _offset_to_axial(to_x, to_y)
        dq, dr = bq - aq, br - ar
        return (abs(dq) + abs(dr) + abs(dq + dr)) // 2

    def displacement(self, from_x, from_y, to_x, to_y):
        """Row-parity-corrected (dcol, drow), wrap-folded."""
        to_x, to_y = self.fold(from_x, from_y, to_x, to_y)
        dcol = (to_x + 0.5 * (to_y % 2)) - (from_x + 0.5 * (from_y % 2))
        return dcol, to_y - from_y

    def compass(self, from_x, from_y, to_x, to_y):
        """8-point compass word for the bearing, or None at zero delta.
        Pointy-top pixel scaling (col step sqrt(3) wide, row step 1.5
        tall) puts each hex direction on its true angle."""
        dcol, drow = self.displacement(from_x, from_y, to_x, to_y)
        if dcol == 0 and drow == 0:
            return None
        angle = math.atan2(drow * 1.5, dcol * math.sqrt(3))
        if angle < 0:
            angle += 2 * math.pi
        return COMPASS[int(math.floor(angle / (math.pi / 4) + 0.5)) % 8]

    def neighbors(self, x, y):
        q, r = _offset_to_axial(x, y)
        for dq, dr in _AXIAL_STEPS:
            nq, nr = q + dq, r + dr
            if not 0 <= nr < self.height:
                continue
            nx, ny = _axial_to_offset(nq, nr)
            if self.wrap_x:
                nx %= self.width
            elif not 0 <= nx < self.width:
                continue
            yield nx, ny


def _as_dict(value):
    """Lua's encoder emits empty tables as []; normalize to {}."""
    return value if isinstance(value, dict) else {}


def _as_list(value):
    """Lua's encoder emits empty tables as []; a missing list is []."""
    return value if isinstance(value, list) else []


class MapData:
    """Decoded dump_map reply plus derived lookup tables."""

    def __init__(self, dump):
        self.hex = HexMap(dump["width"], dump["height"], dump["wrapX"])
        self.width = dump["width"]
        self.height = dump["height"]
        layers = dump["layers"]
        self.vis = layers["visibility"]
        self.plot = layers["plotType"]
        self.terrain = layers["terrain"]
        self.feature = layers["feature"]
        self.river = layers["river"]
        self.owner = layers["owner"]
        self.terrain_legend = _as_dict(dump["legends"]["terrain"])
        self.feature_legend = _as_dict(dump["legends"]["feature"])
        # owner legend: char -> player id
        self.owner_legend = {
            c: info["player"] for c, info in _as_dict(dump["legends"]["owner"]).items()
        }
        self.owner_char = {pid: c for c, pid in self.owner_legend.items()}
        self.cities = dump.get("cities") or []
        self.resources = dump.get("resources") or []
        self.resource_types = _as_dict(dump.get("resourceTypes"))
        self.natural_wonders = dump.get("naturalWonders") or []
        self.players = dump.get("players") or []
        self.capital = dump.get("capital")  # {x, y} or None
        self.cursor = dump.get("cursor")  # {x, y} or None

        self.me = next((p["id"] for p in self.players if p.get("you")), None)
        self.player_by_id = {p["id"]: p for p in self.players}
        self.city_at = {(c["x"], c["y"]): c for c in self.cities}
        self.resource_at = {(r["x"], r["y"]): r for r in self.resources}
        self.wonder_at = {(w["x"], w["y"]): w for w in self.natural_wonders}
        self.my_cities = [c for c in self.cities if c["owner"] == self.me]

    def at(self, layer, x, y):
        return layer[y][x]

    def revealed(self, x, y):
        return self.vis[y][x] != "?"

    def is_land(self, x, y):
        return self.plot[y][x] in LAND_CHARS

    def owner_id(self, x, y):
        c = self.owner[y][x]
        return self.owner_legend.get(c)

    def civ_name(self, player_id):
        p = self.player_by_id.get(player_id)
        return p["civ"] if p else "unknown civilization"

    def tiles(self):
        for y in range(self.height):
            for x in range(self.width):
                yield x, y

    def counts(self):
        total = self.width * self.height
        revealed = visible = 0
        for y in range(self.height):
            revealed += sum(1 for c in self.vis[y] if c != "?")
            visible += sum(1 for c in self.vis[y] if c == "1")
        return total, revealed, visible


# === Anchors and place names ===


class PlaceError(ValueError):
    """Raised when a place / anchor spec can't be resolved; the message
    is written for the calling agent."""


def resolve_place(m, spec):
    """Resolve a place spec into (x, y, label). Accepts "capital",
    "cursor", any known city name, any known natural wonder name, or an
    "x,y" coordinate string / (x, y) pair."""
    if isinstance(spec, (tuple, list)) and len(spec) == 2:
        return int(spec[0]), int(spec[1]), f"({spec[0]}, {spec[1]})"
    s = str(spec).strip()
    low = s.lower()
    if low == "capital":
        if m.capital is None:
            raise PlaceError("you have no capital yet")
        label = next(
            (c["name"] for c in m.my_cities if c.get("capital")), "your capital"
        )
        return m.capital["x"], m.capital["y"], label
    if low == "cursor":
        if m.cursor is None:
            raise PlaceError(
                "the in-game cursor has not been placed yet this session"
            )
        return m.cursor["x"], m.cursor["y"], "the cursor"
    for c in m.cities:
        if c["name"].lower() == low:
            return c["x"], c["y"], c["name"]
    for w in m.natural_wonders:
        if w["name"].lower() == low:
            return w["x"], w["y"], w["name"]
    if "," in s:
        parts = s.split(",")
        try:
            return int(parts[0]), int(parts[1]), f"({int(parts[0])}, {int(parts[1])})"
        except ValueError:
            pass
    known = sorted({c["name"] for c in m.cities})
    raise PlaceError(
        f"unknown place: {spec!r}. Known: 'capital', 'cursor', an x,y "
        f"coordinate, a natural wonder, or a city name ({', '.join(known[:20])})"
    )


def resolve_anchor(m, spec=None):
    """Anchor dict {"x", "y", "name"} for relational description. Default
    is the capital; falls back to the cursor when no capital exists."""
    if spec is None:
        spec = "capital" if m.capital is not None else "cursor"
    x, y, label = resolve_place(m, spec)
    return {"x": x, "y": y, "name": label}


def _rel(m, anchor, x, y):
    """distanceFromAnchor / directionFromAnchor fields, or {} without an
    anchor."""
    if not anchor:
        return {}
    d = m.hex.distance(anchor["x"], anchor["y"], x, y)
    out = {"distanceFromAnchor": d}
    word = m.hex.compass(anchor["x"], anchor["y"], x, y)
    if word:
        out["directionFromAnchor"] = word
    return out


def _nearest_own_city(m, x, y):
    """The player's own city closest to (x, y), with distance and compass
    direction from that city to the point."""
    best, best_d = None, None
    for c in m.my_cities:
        d = m.hex.distance(c["x"], c["y"], x, y)
        if best_d is None or d < best_d:
            best, best_d = c, d
    if best is None:
        return {}
    out = {"nearestYourCity": best["name"], "distanceFromThatCity": best_d}
    word = m.hex.compass(best["x"], best["y"], x, y)
    if word:
        out["direction"] = word
    return out


# === Connected components ===


def _components(m, member):
    """BFS partition of {(x, y): member(x, y)} into components. Returns a
    list of dicts: {tiles: set, frontier: count of adjacent unrevealed
    cells (0 means fully surveyed)}."""
    seen = set()
    out = []
    for start in m.tiles():
        if start in seen or not member(*start):
            continue
        tiles = set()
        frontier = 0
        queue = deque([start])
        seen.add(start)
        while queue:
            x, y = queue.popleft()
            tiles.add((x, y))
            for nx, ny in m.hex.neighbors(x, y):
                if not m.revealed(nx, ny):
                    frontier += 1
                elif (nx, ny) not in seen and member(nx, ny):
                    seen.add((nx, ny))
                    queue.append((nx, ny))
        out.append({"tiles": tiles, "frontier": frontier})
    return out


def _cluster_sets(m, tile_set):
    """Hex-connected components within an explicit tile set, largest
    first."""
    seen = set()
    out = []
    for start in sorted(tile_set):
        if start in seen:
            continue
        tiles = set()
        queue = deque([start])
        seen.add(start)
        while queue:
            x, y = queue.popleft()
            tiles.add((x, y))
            for n in m.hex.neighbors(x, y):
                if n in tile_set and n not in seen:
                    seen.add(n)
                    queue.append(n)
        out.append(tiles)
    out.sort(key=len, reverse=True)
    return out


def _unwrapped_xs(m, tiles):
    """X coordinates folded to the neighborhood of the first tile, so a
    component straddling the wrap seam gets a contiguous extent."""
    it = iter(tiles)
    x0, _ = next(it)
    xs = [x0]
    for x, y in it:
        fx, _ = m.hex.fold(x0, 0, x, 0)
        xs.append(fx)
    return xs


def _centroid(m, tiles):
    xs = _unwrapped_xs(m, tiles)
    cx = sum(xs) / len(xs)
    cy = sum(y for _, y in tiles) / len(tiles)
    if m.hex.wrap_x:
        cx %= m.width
    return int(round(cx)), int(round(cy))


def _extent(m, tiles):
    xs = _unwrapped_xs(m, tiles)
    ys = [y for _, y in tiles]
    return max(xs) - min(xs) + 1, max(ys) - min(ys) + 1


def _shape_word(span_x, span_y):
    ratio = span_x / max(span_y, 1)
    if ratio >= 1.6:
        return "elongated east-west"
    if ratio <= 0.625:
        return "elongated north-south"
    return "roughly round"


def _farthest_from(m, tiles, start):
    best, best_d = start, -1
    for t in tiles:
        d = m.hex.distance(start[0], start[1], t[0], t[1])
        if d > best_d:
            best, best_d = t, d
    return best, best_d


# === Spatial-cluster primitive ===


def describe_cluster(m, tiles, anchor):
    """One cluster of tiles as a relational fact: size, where it sits
    relative to the anchor and the player's nearest city, extent."""
    cx, cy = _centroid(m, tiles)
    span_x, span_y = _extent(m, tiles)
    entry = {
        "tiles": len(tiles),
        "center": {"x": cx, "y": cy},
        "spanEastWest": span_x,
        "spanNorthSouth": span_y,
    }
    entry.update(_rel(m, anchor, cx, cy))
    entry.update(_nearest_own_city(m, cx, cy))
    return entry


def spatial_clusters(m, tile_set, anchor, min_size=1, max_clusters=None):
    """The describe-a-tile-set-spatially primitive: hex-connected clusters
    of `tile_set`, each described relationally, largest first."""
    out = [
        describe_cluster(m, c, anchor)
        for c in _cluster_sets(m, tile_set)
        if len(c) >= min_size
    ]
    if max_clusters is not None:
        out = out[:max_clusters]
    return out


def _relief_word(tiles, m):
    hills = sum(1 for x, y in tiles if m.plot[y][x] == "H")
    mountains = sum(1 for x, y in tiles if m.plot[y][x] == "M")
    n = max(len(tiles), 1)
    if mountains / n > 0.10:
        return "mountainous"
    if hills / n > 0.40:
        return "hilly"
    if hills / n > 0.15:
        return "rolling"
    return "mostly flat"


def _rivers_word(tiles, m):
    river = sum(1 for x, y in tiles if m.river[y][x] not in "0?")
    n = max(len(tiles), 1)
    if river == 0:
        return "none"
    if river / n < 0.08:
        return "sparse"
    if river / n < 0.20:
        return "several"
    return "extensive"


# Zones smaller than this never make a landmass description; larger
# thresholds scale with the landmass so a big continent doesn't drown in
# 5-tile patches.
_ZONE_MIN_TILES = 4
# A terrain covering more than this share of a landmass is the background,
# already conveyed by terrainMix; its "zone" would just re-describe the
# whole landmass.
_BACKGROUND_TERRAIN_SHARE = 0.60


def _zones(m, tiles, anchor):
    """Terrain / feature / hill / river zones of a landmass, each placed
    relationally. This is what replaces bare counts like 'hillTiles'."""
    n = len(tiles)
    zone_min = max(_ZONE_MIN_TILES, round(n * 0.06))

    by_terrain = {}
    for x, y in tiles:
        by_terrain.setdefault(m.terrain[y][x], set()).add((x, y))
    terrain_zones = []
    for char, group in by_terrain.items():
        info = m.terrain_legend.get(char)
        if not info or len(group) / n > _BACKGROUND_TERRAIN_SHARE:
            continue
        for cluster in spatial_clusters(m, group, anchor, min_size=zone_min):
            cluster["terrain"] = info["name"]
            terrain_zones.append(cluster)
    terrain_zones.sort(key=lambda z: -z["tiles"])

    by_feature = {}
    for x, y in tiles:
        c = m.feature[y][x]
        if c not in "-?":
            by_feature.setdefault(c, set()).add((x, y))
    feature_zones = []
    for char, group in by_feature.items():
        info = m.feature_legend.get(char)
        if not info:
            continue
        for cluster in spatial_clusters(m, group, anchor, min_size=zone_min):
            cluster["feature"] = info["name"]
            feature_zones.append(cluster)
    feature_zones.sort(key=lambda z: -z["tiles"])

    hills = {(x, y) for x, y in tiles if m.plot[y][x] == "H"}
    river = {(x, y) for x, y in tiles if m.river[y][x] not in "0?"}
    return {
        "terrainZones": terrain_zones[:5],
        "featureZones": feature_zones[:5],
        "hillRegions": spatial_clusters(
            m, hills, anchor, min_size=_ZONE_MIN_TILES, max_clusters=4
        ),
        "riverValleys": spatial_clusters(
            m, river, anchor, min_size=_ZONE_MIN_TILES, max_clusters=4
        ),
    }


# === Landmasses and water ===


def _mountain_ranges(m, land_tiles, anchor):
    ranges = []
    mountain = {(x, y) for x, y in land_tiles if m.plot[y][x] == "M"}
    for tiles in _cluster_sets(m, mountain):
        if len(tiles) < 3:
            continue
        # Approximate diameter: farthest tile from an arbitrary start,
        # then farthest from that -- good enough for narration.
        u, _ = _farthest_from(m, tiles, next(iter(tiles)))
        v, length = _farthest_from(m, tiles, u)
        heading = m.hex.compass(u[0], u[1], v[0], v[1])
        entry = {
            "peaks": len(tiles),
            "lengthTiles": length + 1,
            "from": {"x": u[0], "y": u[1]},
            "to": {"x": v[0], "y": v[1]},
        }
        if heading:
            entry["running"] = heading
        cx, cy = _centroid(m, tiles)
        entry.update(_rel(m, anchor, cx, cy))
        entry.update(_nearest_own_city(m, cx, cy))
        ranges.append(entry)
    ranges.sort(key=lambda r: -r["peaks"])
    return ranges


# Landmasses below this size get the terse treatment: no zones, no
# structural analysis -- a 6-tile island doesn't have regions.
_LANDMASS_DETAIL_MIN = 25


def landmasses(m, anchor=None):
    """All revealed landmasses, largest first. Each carries enough for a
    one-paragraph description; ids are size ranks, stable within a dump."""
    comps = _components(m, m.is_land)
    comps.sort(key=lambda c: -len(c["tiles"]))
    capital_tile = (m.capital["x"], m.capital["y"]) if m.capital else None
    out = []
    for rank, comp in enumerate(comps, start=1):
        tiles = comp["tiles"]
        span_x, span_y = _extent(m, tiles)
        cx, cy = _centroid(m, tiles)
        terrain_counts = Counter(m.terrain[y][x] for x, y in tiles)
        terrain_mix = []
        for char, n in terrain_counts.most_common(3):
            info = m.terrain_legend.get(char)
            if info:
                terrain_mix.append(
                    {"terrain": info["name"], "percent": round(100 * n / len(tiles))}
                )
        owners = Counter(
            m.owner_id(x, y) for x, y in tiles if m.owner_id(x, y) is not None
        )
        cities = [c for c in m.cities if (c["x"], c["y"]) in tiles]
        wonders = [w for w in m.natural_wonders if (w["x"], w["y"]) in tiles]
        entry = {
            "id": rank,
            "tiles": len(tiles),
            "surveyedCompletely": comp["frontier"] == 0,
            "shape": _shape_word(span_x, span_y),
            "spanEastWest": span_x,
            "spanNorthSouth": span_y,
            "center": {"x": cx, "y": cy},
            "relief": _relief_word(tiles, m),
            "rivers": _rivers_word(tiles, m),
            "terrainMix": terrain_mix,
            "mountainRanges": _mountain_ranges(m, tiles, anchor),
            "civsPresent": [
                {"civ": m.civ_name(pid), "tiles": n} for pid, n in owners.most_common()
            ],
            "cityCount": len(cities),
            "naturalWonders": [w["name"] for w in wonders],
        }
        if len(tiles) >= _LANDMASS_DETAIL_MIN:
            entry.update(_zones(m, tiles, anchor))
        if capital_tile and capital_tile in tiles:
            entry["yourHomeLandmass"] = True
        else:
            entry.update(_rel(m, anchor, cx, cy))
        out.append(entry)
    return out


def water_bodies(m, anchor=None):
    """Revealed water, largest first, honestly classified: a small body
    still open to fog might be an ocean bay, so it stays 'unknown'."""
    comps = _components(m, lambda x, y: m.revealed(x, y) and not m.is_land(x, y))
    comps.sort(key=lambda c: -len(c["tiles"]))
    out = []
    for comp in comps:
        tiles = comp["tiles"]
        surveyed = comp["frontier"] == 0
        if len(tiles) > LAKE_MAX_TILES:
            kind = "ocean or sea"
        elif surveyed:
            kind = "lake"
        else:
            kind = "water, extent unknown"
        cx, cy = _centroid(m, tiles)
        entry = {
            "kind": kind,
            "tiles": len(tiles),
            "surveyedCompletely": surveyed,
            "center": {"x": cx, "y": cy},
        }
        entry.update(_rel(m, anchor, cx, cy))
        out.append(entry)
    return out


def _water_comp_sets(m):
    """(big_water, lake) tile sets -- big_water is any water component
    that is or may be sea (ocean-sized or fog-open)."""
    big, lakes = set(), set()
    for comp in _components(m, lambda x, y: m.revealed(x, y) and not m.is_land(x, y)):
        if len(comp["tiles"]) > LAKE_MAX_TILES or comp["frontier"] > 0:
            big |= comp["tiles"]
        else:
            lakes |= comp["tiles"]
    return big, lakes


# === Land routes ===


def _passable(m, x, y):
    """Land a unit can walk: revealed, land, not mountain."""
    return m.revealed(x, y) and m.plot[y][x] in "FH"


def _land_bfs(m, starts):
    """Multi-source BFS distances over walkable land. `starts` may include
    impassable tiles (a capital is walkable by definition, but a generic
    anchor might sit on a mountain); they seed at 0 and expansion happens
    only through passable tiles."""
    dist = {}
    queue = deque()
    for s in starts:
        if s not in dist:
            dist[s] = 0
            queue.append(s)
    while queue:
        x, y = queue.popleft()
        for n in m.hex.neighbors(x, y):
            if n not in dist and _passable(m, *n):
                dist[n] = dist[(x, y)] + 1
                queue.append(n)
    return dist


def _route_fields(m, land_dist, landmass_of, from_tile, to_tile):
    """Overland-route description from a precomputed BFS: the walking
    distance when one exists, otherwise why not."""
    if to_tile in land_dist:
        return {"overlandDistance": land_dist[to_tile]}
    a, b = landmass_of.get(from_tile), landmass_of.get(to_tile)
    if a is not None and a == b:
        return {"landRouteBlocked": True}
    return {"seaOnly": True}


# === Politics ===


def _diplo_names(m, entry, key):
    return [m.civ_name(pid) for pid in _as_list(entry.get(key))]


def contact_graph(m):
    """Which revealed territories touch: {(a, b) sorted pid pair ->
    boundary tile set (both sides)}."""
    pairs = {}
    for x, y in m.tiles():
        pid = m.owner_id(x, y)
        if pid is None:
            continue
        for nx, ny in m.hex.neighbors(x, y):
            if not m.revealed(nx, ny):
                continue
            qid = m.owner_id(nx, ny)
            if qid is None or qid == pid:
                continue
            key = (pid, qid) if pid < qid else (qid, pid)
            pairs.setdefault(key, set()).update([(x, y), (nx, ny)])
    return pairs


def _border_traits(m, boundary_tiles):
    """What the ground along a shared border is like -- the fact a sighted
    player absorbs at a glance."""
    total = max(len(boundary_tiles), 1)
    water = sum(1 for x, y in boundary_tiles if not m.is_land(x, y))
    hills = sum(1 for x, y in boundary_tiles if m.plot[y][x] == "H")
    river = any(m.river[y][x] not in "0?" for x, y in boundary_tiles)
    mountains = any(
        m.revealed(nx, ny) and m.plot[ny][nx] == "M"
        for x, y in boundary_tiles
        for nx, ny in m.hex.neighbors(x, y)
    )
    traits = []
    if water / total > 0.5:
        traits.append("mostly across water")
    if hills / total >= 0.4:
        traits.append("hilly ground")
    if river:
        traits.append("river along the border")
    if mountains:
        traits.append("mountains nearby")
    if not traits:
        traits.append("open ground")
    return traits


def politics(m):
    """Wars, friendship / pact blocs, and city-state alignments among met
    players -- all public in-game knowledge once both parties are met."""
    majors = [p for p in m.players if not p.get("minor") and p.get("alive")]
    by_id = {p["id"]: p for p in majors}

    wars = set()
    for p in m.players:
        for other in _as_list(p.get("atWarWith")):
            wars.add(tuple(sorted((p["id"], other))))

    # Blocs: connected components of the friendship + defensive-pact graph.
    parent = {p["id"]: p["id"] for p in majors}

    def find(a):
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a

    ties = Counter()
    for p in majors:
        for key in ("friendsWith", "defensivePactsWith"):
            for other in _as_list(p.get(key)):
                if other in parent:
                    ra, rb = find(p["id"]), find(other)
                    if ra != rb:
                        parent[ra] = rb
                    ties[tuple(sorted((p["id"], other)))] += 0  # mark pair
    groups = {}
    for p in majors:
        groups.setdefault(find(p["id"]), []).append(p["id"])
    blocs = []
    for members in groups.values():
        if len(members) < 2:
            continue
        names = sorted(m.civ_name(i) for i in members)
        pacts = sorted(
            [m.civ_name(a), m.civ_name(b)]
            for a in members
            for b in _as_list(by_id[a].get("defensivePactsWith"))
            if a < b
        )
        # Friendship chains can link two civs that are themselves at war
        # (A-B friends, B-C friends, A at war with C). Such a component is
        # a web, not a bloc; internalWars lets the reader tell them apart.
        member_set = set(members)
        internal = sorted(
            sorted([m.civ_name(a), m.civ_name(b)])
            for a, b in wars
            if a in member_set and b in member_set
        )
        blocs.append(
            {"members": names, "defensivePacts": pacts, "internalWars": internal}
        )
    blocs.sort(key=lambda b: -len(b["members"]))

    allies = []
    for p in m.players:
        if not p.get("minor") or not p.get("alive"):
            continue
        if p.get("allyId") is not None:
            allies.append({"cityState": p["civ"], "ally": m.civ_name(p["allyId"])})
        elif p.get("hasUnmetAlly"):
            allies.append({"cityState": p["civ"], "ally": "an unmet civilization"})

    me_entry = m.player_by_id.get(m.me, {})
    return {
        "yourWars": _diplo_names(m, me_entry, "atWarWith"),
        "yourFriends": _diplo_names(m, me_entry, "friendsWith"),
        "yourDefensivePacts": _diplo_names(m, me_entry, "defensivePactsWith"),
        "wars": sorted(
            sorted([m.civ_name(a), m.civ_name(b)]) for a, b in wars
        ),
        "friendshipBlocs": blocs,
        "cityStateAllies": allies,
    }


# === Civ positions ===


def civ_positions(m, anchor=None):
    """Every met player: known territory, known cities, diplomacy, who
    they border, and where they sit relative to the anchor."""
    land_comps = _components(m, m.is_land)
    landmass_of = {}
    for rank, comp in enumerate(
        sorted(land_comps, key=lambda c: -len(c["tiles"])), start=1
    ):
        for t in comp["tiles"]:
            landmass_of[t] = rank
    my_landmass = None
    if m.capital:
        my_landmass = landmass_of.get((m.capital["x"], m.capital["y"]))

    territory = {}
    for x, y in m.tiles():
        pid = m.owner_id(x, y)
        if pid is not None:
            territory.setdefault(pid, []).append((x, y))

    contacts = contact_graph(m)
    anchor_tile = (anchor["x"], anchor["y"]) if anchor else None
    land_dist = _land_bfs(m, [anchor_tile]) if anchor_tile else {}

    out = []
    for p in m.players:
        pid = p["id"]
        tiles = territory.get(pid, [])
        cities = [c for c in m.cities if c["owner"] == pid]
        entry = {
            "civ": p["civ"],
            "cityState": bool(p.get("minor")),
            "alive": bool(p.get("alive")),
            "you": bool(p.get("you")),
            "knownTerritoryTiles": len(tiles),
            "knownCities": [
                {
                    "name": c["name"],
                    "x": c["x"],
                    "y": c["y"],
                    "capital": bool(c.get("capital")),
                    "currentlyVisible": bool(c.get("visible")),
                    **_nearest_own_city(m, c["x"], c["y"]),
                }
                for c in cities
            ],
        }
        if not p.get("minor") and p.get("alive"):
            entry["atWarWith"] = _diplo_names(m, p, "atWarWith")
            entry["friendsWith"] = _diplo_names(m, p, "friendsWith")
            entry["defensivePactsWith"] = _diplo_names(m, p, "defensivePactsWith")
        if p.get("minor") and p.get("alive"):
            if p.get("allyId") is not None:
                entry["ally"] = m.civ_name(p["allyId"])
            elif p.get("hasUnmetAlly"):
                entry["ally"] = "an unmet civilization"
        if not p.get("you"):
            borders = []
            for (a, b), btiles in contacts.items():
                if pid not in (a, b):
                    continue
                other = b if a == pid else a
                item = {
                    "civ": "you" if other == m.me else m.civ_name(other),
                    "borderTiles": len(btiles) // 2,
                }
                if other == m.me:
                    entry["bordersYou"] = True
                    entry["borderWithYou"] = {
                        "tiles": len(btiles) // 2,
                        "terrain": _border_traits(m, btiles),
                    }
                else:
                    borders.append(item)
            if borders:
                entry["alsoBorders"] = sorted(
                    borders, key=lambda i: -i["borderTiles"]
                )
        # Best known seat: their capital if seen, else territory centroid.
        seat = next(
            ((c["x"], c["y"]) for c in cities if c.get("capital")),
            None,
        )
        if seat is None and tiles:
            seat = _centroid(m, set(tiles))
        if seat is not None:
            entry["knownSeat"] = {"x": seat[0], "y": seat[1]}
            entry.update(_rel(m, anchor, seat[0], seat[1]))
            seat_landmass = landmass_of.get(seat)
            if seat_landmass is not None:
                entry["landmassId"] = seat_landmass
                if my_landmass is not None and not p.get("you"):
                    entry["sharesYourLandmass"] = seat_landmass == my_landmass
            if anchor_tile and not p.get("you"):
                entry.update(
                    _route_fields(m, land_dist, landmass_of, anchor_tile, seat)
                )
        out.append(entry)
    # You first, then majors by distance, then city-states by distance.
    out.sort(
        key=lambda e: (
            not e["you"],
            e["cityState"],
            e.get("distanceFromAnchor", 10**6),
        )
    )
    return out


# === Border neighborhood ===


def borders_report(m, radius=5):
    """What sits within `radius` tiles of the player's borders: unclaimed
    resources, foreign territory, cities, wonders, and how close the fog
    is. Distances are tiles beyond the border (1 = adjacent)."""
    if m.me is None:
        return {"error": "player not present in dump"}
    mine = {
        (x, y) for x, y in m.tiles() if m.owner_id(x, y) == m.me
    }
    if not mine:
        return {"ownedTiles": 0, "note": "you own no territory yet"}

    contacts = contact_graph(m)

    # Multi-source BFS out from the whole territory.
    dist = {t: 0 for t in mine}
    queue = deque(mine)
    fog_adjacent = []
    reached = []
    while queue:
        x, y = queue.popleft()
        d = dist[(x, y)]
        if d >= radius:
            continue
        for nx, ny in m.hex.neighbors(x, y):
            if (nx, ny) in dist:
                continue
            if not m.revealed(nx, ny):
                fog_adjacent.append(d + 1)
                continue
            dist[(nx, ny)] = d + 1
            reached.append((nx, ny))
            queue.append((nx, ny))

    resources = []
    foreign = {}
    cities = []
    wonders = []
    for x, y in reached:
        d = dist[(x, y)]
        pid = m.owner_id(x, y)
        res = m.resource_at.get((x, y))
        if res and pid is None:
            info = m.resource_types.get(res["t"], {})
            resources.append(
                {
                    "resource": info.get("name", res["t"]),
                    "usage": {0: "bonus", 1: "strategic", 2: "luxury"}.get(
                        info.get("usage"), "unknown"
                    ),
                    "x": x,
                    "y": y,
                    "tilesBeyondBorder": d,
                    **_nearest_own_city(m, x, y),
                }
            )
        if pid is not None and pid != m.me:
            f = foreign.setdefault(pid, {"tiles": 0, "closest": d, "at": (x, y)})
            f["tiles"] += 1
            if d < f["closest"]:
                f["closest"], f["at"] = d, (x, y)
        city = m.city_at.get((x, y))
        if city and city["owner"] != m.me:
            cities.append(
                {
                    "name": city["name"],
                    "civ": m.civ_name(city["owner"]),
                    "capital": bool(city.get("capital")),
                    "x": x,
                    "y": y,
                    "tilesBeyondBorder": d,
                    **_nearest_own_city(m, x, y),
                }
            )
        wonder = m.wonder_at.get((x, y))
        if wonder:
            wonders.append(
                {
                    "name": wonder["name"],
                    "x": x,
                    "y": y,
                    "tilesBeyondBorder": d,
                    **_nearest_own_city(m, x, y),
                }
            )

    neighbors = []
    for pid, f in sorted(foreign.items(), key=lambda kv: kv[1]["closest"]):
        item = {
            "civ": m.civ_name(pid),
            "tilesWithinRadius": f["tiles"],
            "closestTilesBeyondBorder": f["closest"],
            **_nearest_own_city(m, *f["at"]),
        }
        key = tuple(sorted((m.me, pid)))
        if key in contacts:
            item["sharedBorderTiles"] = len(contacts[key]) // 2
            item["borderTerrain"] = _border_traits(m, contacts[key])
        neighbors.append(item)

    resources.sort(key=lambda r: r["tilesBeyondBorder"])
    cities.sort(key=lambda c: c["tilesBeyondBorder"])
    return {
        "radius": radius,
        "ownedTiles": len(mine),
        "unclaimedResources": resources,
        "foreignNeighbors": neighbors,
        "foreignCities": cities,
        "naturalWonders": wonders,
        "fogTilesTouchingRadius": len(fog_adjacent),
        "closestFogTilesBeyondBorder": min(fog_adjacent) if fog_adjacent else None,
    }


# === Settleable land ===


def settle_scan(m, anchor=None, max_areas=12):
    """Unowned habitable land clusters: where the empire could still
    expand, and who else is close to each spot."""
    candidates = {
        (x, y)
        for x, y in m.tiles()
        if m.revealed(x, y) and m.plot[y][x] in "FH" and m.owner_id(x, y) is None
    }
    mine = {(x, y) for x, y in m.tiles() if m.owner_id(x, y) == m.me}
    foreign_tiles = [
        ((x, y), m.owner_id(x, y))
        for x, y in m.tiles()
        if m.owner_id(x, y) not in (None, m.me)
    ]
    big_water, lakes = _water_comp_sets(m)
    my_dist = _land_bfs(m, mine) if mine else {}

    areas = []
    for cluster in _cluster_sets(m, candidates):
        if len(cluster) < 4:
            continue
        entry = describe_cluster(m, cluster, anchor)
        entry["freshWater"] = any(
            m.river[y][x] not in "0?" for x, y in cluster
        ) or any(
            n in lakes for x, y in cluster for n in m.hex.neighbors(x, y)
        )
        entry["coastal"] = any(
            n in big_water for x, y in cluster for n in m.hex.neighbors(x, y)
        )
        terrain_counts = Counter(m.terrain[y][x] for x, y in cluster)
        entry["terrainMix"] = [
            {
                "terrain": m.terrain_legend[c]["name"],
                "percent": round(100 * n / len(cluster)),
            }
            for c, n in terrain_counts.most_common(2)
            if c in m.terrain_legend
        ]
        res_counts = Counter()
        for x, y in cluster:
            r = m.resource_at.get((x, y))
            if r:
                info = m.resource_types.get(r["t"], {})
                usage = {0: "bonus", 1: "strategic", 2: "luxury"}.get(
                    info.get("usage"), "unknown"
                )
                res_counts[(info.get("name", r["t"]), usage)] += 1
        entry["resources"] = [
            {"resource": name, "usage": usage, "tiles": n}
            for (name, usage), n in res_counts.most_common()
        ]
        walk = [my_dist[t] for t in cluster if t in my_dist]
        if walk:
            entry["walkingDistanceFromYourBorder"] = min(walk)
        elif mine:
            entry["noLandRouteFromYourTerritory"] = True
        if foreign_tiles:
            best_civ, best_d = None, None
            for t, pid in foreign_tiles:
                for c in cluster:
                    d = m.hex.distance(t[0], t[1], c[0], c[1])
                    if best_d is None or d < best_d:
                        best_civ, best_d = pid, d
            entry["closestRival"] = {
                "civ": m.civ_name(best_civ),
                "distance": best_d,
            }
        areas.append(entry)

    areas.sort(
        key=lambda a: a.get(
            "walkingDistanceFromYourBorder", a.get("distanceFromAnchor", 10**6)
        )
    )
    dropped = len(areas) - max_areas
    result = {"settleableAreas": areas[:max_areas]}
    if dropped > 0:
        result["smallerAreasOmitted"] = dropped
    return result


# === Structural segmentation (the landmass tour) ===


def _touches_map_edge(m, x, y):
    if y in (0, m.height - 1):
        return True
    if not m.hex.wrap_x and x in (0, m.width - 1):
        return True
    return False


def _segment_landmass(m, tiles):
    """Split a landmass the way eyes would: coastal-erosion lobes joined
    by narrow necks, then mountain / desert dividers. Returns a list of
    (tile set, divider) pairs -- divider is "mountains" / "desert" when a
    blocker band produced the region, else None. One pair = the whole
    landmass when there is no structure."""
    # Depth from the known edge: revealed water, the map edge, or fog
    # (beyond fog is unknown, so fog-adjacent land is edge, not interior).
    depth = {}
    queue = deque()
    for x, y in tiles:
        edge = _touches_map_edge(m, x, y)
        if not edge:
            for nx, ny in m.hex.neighbors(x, y):
                if (nx, ny) not in tiles:
                    edge = True
                    break
        if edge:
            depth[(x, y)] = 1
            queue.append((x, y))
    while queue:
        t = queue.popleft()
        for n in m.hex.neighbors(*t):
            if n in tiles and n not in depth:
                depth[n] = depth[t] + 1
                queue.append(n)

    core_depth = 3 if any(d >= 3 for d in depth.values()) else 2
    cores = [
        c
        for c in _cluster_sets(m, {t for t, d in depth.items() if d >= core_depth})
        if len(c) >= 3
    ]

    if len(cores) >= 2:
        # Assign every tile to its nearest core (simultaneous BFS).
        label = {}
        queue = deque()
        for i, core in enumerate(cores):
            for t in core:
                label[t] = i
                queue.append(t)
        while queue:
            t = queue.popleft()
            for n in m.hex.neighbors(*t):
                if n in tiles and n not in label:
                    label[n] = label[t]
                    queue.append(n)
        regions = [set() for _ in cores]
        for t, i in label.items():
            regions[i].add(t)
        regions = [r for r in regions if r]
        regions = _merge_slivers(m, regions, len(tiles))
    else:
        regions = [set(tiles)]

    # Divider pass: a mountain or desert band that cuts a big region in
    # two is how a human names "north of the mountains".
    final = []
    for region in regions:
        final.extend(_divider_split(m, region))
    return final


def _divider_split(m, region):
    """Try splitting one region along a mountain, then a desert, band.
    Returns [(region, None)] untouched when no divider cleanly cuts it."""
    if len(region) < _DIVIDER_MIN_REGION:
        return [(region, None)]
    for kind, member in (
        ("mountains", lambda x, y: m.plot[y][x] == "M"),
        ("desert", lambda x, y: _terrain_type(m, x, y) == "TERRAIN_DESERT"),
    ):
        blockers = {(x, y) for x, y in region if member(x, y)}
        if len(blockers) < 3:
            continue
        remainder = region - blockers
        comps = _cluster_sets(m, remainder)
        big = [c for c in comps if len(c) >= len(region) * 0.15]
        if len(big) < 2:
            continue
        # Blockers and small fragments join the nearest big side.
        label = {}
        queue = deque()
        for i, c in enumerate(big):
            for t in c:
                label[t] = i
                queue.append(t)
        while queue:
            t = queue.popleft()
            for n in m.hex.neighbors(*t):
                if n in region and n not in label:
                    label[n] = label[t]
                    queue.append(n)
        parts = [set() for _ in big]
        for t, i in label.items():
            parts[i].add(t)
        return [(p, kind) for p in parts if p]
    return [(region, None)]


def _merge_slivers(m, regions, landmass_size):
    """Fold regions too small to narrate into the neighbor they touch
    most."""
    min_size = max(6, round(landmass_size * 0.05))
    regions = sorted(regions, key=len, reverse=True)
    changed = True
    while changed and len(regions) > 1:
        changed = False
        for i, r in enumerate(regions):
            if len(r) >= min_size:
                continue
            contact = Counter()
            for t in r:
                for n in m.hex.neighbors(*t):
                    for j, other in enumerate(regions):
                        if j != i and n in other:
                            contact[j] += 1
            if contact:
                j = contact.most_common(1)[0][0]
                regions[j] |= r
                del regions[i]
                changed = True
                break
    return regions


_DIVIDER_MIN_REGION = 100


def _terrain_type(m, x, y):
    info = m.terrain_legend.get(m.terrain[y][x])
    return info["type"] if info else None


def landmass_tour(m, anchor=None, landmass_id=None):
    """The 'walk me around the continent' answer: the landmass split into
    regions a human would name, each described in one chunk, ordered from
    the anchor outward."""
    comps = _components(m, m.is_land)
    comps.sort(key=lambda c: -len(c["tiles"]))
    if not comps:
        return {"error": "no revealed land at all"}
    target = None
    if landmass_id is not None:
        if not 1 <= landmass_id <= len(comps):
            return {"error": f"no landmass with id {landmass_id}"}
        target = comps[landmass_id - 1]
        rank = landmass_id
    elif m.capital:
        cap = (m.capital["x"], m.capital["y"])
        for i, c in enumerate(comps, start=1):
            if cap in c["tiles"]:
                target, rank = c, i
                break
    if target is None:
        target, rank = comps[0], 1

    tiles = target["tiles"]
    regions = _segment_landmass(m, tiles)

    # Connections between regions: how wide the touch is, and whether a
    # divider produced it.
    described = []
    for region, divider in regions:
        entry = describe_cluster(m, region, anchor)
        if divider:
            entry["boundedBy"] = divider
        entry["relief"] = _relief_word(region, m)
        entry["rivers"] = _rivers_word(region, m)
        terrain_counts = Counter(m.terrain[y][x] for x, y in region)
        entry["dominantTerrain"] = [
            {
                "terrain": m.terrain_legend[c]["name"],
                "percent": round(100 * n / len(region)),
            }
            for c, n in terrain_counts.most_common(2)
            if c in m.terrain_legend
        ]
        entry["yourCities"] = [
            c["name"] for c in m.my_cities if (c["x"], c["y"]) in region
        ]
        entry["foreignCities"] = [
            {"name": c["name"], "civ": m.civ_name(c["owner"])}
            for c in m.cities
            if c["owner"] != m.me and (c["x"], c["y"]) in region
        ]
        res_counts = Counter()
        for x, y in region:
            r = m.resource_at.get((x, y))
            if r:
                info = m.resource_types.get(r["t"], {})
                usage = {0: "bonus", 1: "strategic", 2: "luxury"}.get(
                    info.get("usage"), "unknown"
                )
                if usage in ("strategic", "luxury"):
                    res_counts[(info.get("name", r["t"]), usage)] += 1
        entry["notableResources"] = [
            {"resource": name, "usage": usage, "tiles": n}
            for (name, usage), n in res_counts.most_common(8)
        ]
        entry["naturalWonders"] = [
            w["name"] for w in m.natural_wonders if (w["x"], w["y"]) in region
        ]
        coast = sum(
            1
            for x, y in region
            if any(
                m.revealed(nx, ny) and not m.is_land(nx, ny)
                for nx, ny in m.hex.neighbors(x, y)
            )
        )
        entry["coastTiles"] = coast
        entry["touchesFog"] = any(
            not m.revealed(nx, ny)
            for x, y in region
            for nx, ny in m.hex.neighbors(x, y)
        )
        described.append((region, entry))

    for i, (region, entry) in enumerate(described):
        connections = []
        for j, (other, _) in enumerate(described):
            if j == i:
                continue
            width = sum(
                1
                for t in region
                if any(n in other for n in m.hex.neighbors(*t))
            )
            if width == 0:
                continue
            conn = {"toRegion": j + 1, "tilesWide": width}
            divider = described[j][1].get("boundedBy") or entry.get("boundedBy")
            if divider:
                conn["separatedBy"] = divider
            elif width <= 3:
                conn["narrowNeck"] = True
            connections.append(conn)
        if connections:
            entry["connections"] = connections
        # Structure word: a region hanging off one narrow connection is a
        # peninsula in any human description.
        if (
            len(connections) == 1
            and connections[0].get("narrowNeck")
            and entry["coastTiles"] / max(entry["tiles"], 1) > 0.4
        ):
            entry["structure"] = "peninsula"

    # Order: the region containing the anchor first, then by distance.
    anchor_tile = (anchor["x"], anchor["y"]) if anchor else None
    ordered = sorted(
        described,
        key=lambda pair: (
            0 if anchor_tile and anchor_tile in pair[0] else 1,
            pair[1].get("distanceFromAnchor", 10**6),
        ),
    )
    entries = []
    for idx, (region, entry) in enumerate(ordered, start=1):
        if anchor_tile and anchor_tile in region:
            entry["containsAnchor"] = True
        entry["region"] = idx
        entries.append(entry)
    # Renumber connections to the ordered ids.
    old_to_new = {}
    for new_idx, (region, _) in enumerate(ordered, start=1):
        for old_idx, (r2, _) in enumerate(described, start=1):
            if r2 is region:
                old_to_new[old_idx] = new_idx
    for entry in entries:
        for conn in entry.get("connections", []):
            conn["toRegion"] = old_to_new[conn["toRegion"]]

    return {
        "landmassId": rank,
        "tiles": len(tiles),
        "surveyedCompletely": target["frontier"] == 0,
        "regionCount": len(entries),
        "regions": entries,
        "note": (
            "one continuous region with no natural divisions"
            if len(entries) == 1
            else None
        ),
    }


# === War report ===


_ROLE_ORDER = ["siege", "ranged", "melee", "mounted", "naval", "air",
               "civilian", "great_people", "barbarians"]


def war_report(m, hostiles_data, anchor=None, near_radius=6):
    """The map of the war: visible hostile forces clustered, each with
    composition, position, and what of yours is close. Visible-now only;
    fog may hide more, and the numbers change as units move."""
    hostile_units = _as_list(hostiles_data.get("hostileUnits"))
    your_units = _as_list(hostiles_data.get("yourUnits"))
    your_cities = _as_list(hostiles_data.get("yourCities"))
    enemy_cities = _as_list(hostiles_data.get("visibleEnemyCities"))

    me_entry = m.player_by_id.get(m.me, {})
    at_war_with = _diplo_names(m, me_entry, "atWarWith")

    result = {
        "atWarWith": at_war_with,
        "visibleHostileUnits": len(hostile_units),
        "yourUnitsTotal": len(your_units),
        "note": (
            "Only what is visible right now; fog of war may hide more, "
            "and positions change as units move."
        ),
    }
    if not hostile_units:
        result["clusters"] = []
        if not at_war_with:
            result["note"] = (
                "You are at war with no one (barbarians would still show "
                "here when visible)."
            )
        return result

    # Cluster hostiles: units within 2 tiles of each other are one force.
    n = len(hostile_units)
    parent = list(range(n))

    def find(a):
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a

    for i in range(n):
        for j in range(i + 1, n):
            a, b = hostile_units[i], hostile_units[j]
            if m.hex.distance(a["x"], a["y"], b["x"], b["y"]) <= 2:
                ra, rb = find(i), find(j)
                if ra != rb:
                    parent[ra] = rb
    groups = {}
    for i in range(n):
        groups.setdefault(find(i), []).append(hostile_units[i])

    clusters = []
    for units in groups.values():
        tiles = {(u["x"], u["y"]) for u in units}
        cx, cy = _centroid(m, tiles)
        by_civ = Counter(u.get("civ", "unknown") for u in units)
        comp = Counter(u.get("role", "unknown") for u in units)
        names = Counter(u.get("name", "unknown unit") for u in units)
        entry = {
            "units": len(units),
            "civs": [
                {"civ": civ, "units": k} for civ, k in by_civ.most_common()
            ],
            "composition": {
                role: comp[role] for role in _ROLE_ORDER if comp.get(role)
            },
            "unitTypes": [
                {"name": name, "count": k} for name, k in names.most_common()
            ],
            "center": {"x": cx, "y": cy},
            "spanTiles": max(_extent(m, tiles)),
            "allBarbarian": all(u.get("barbarian") for u in units),
        }
        entry.update(_rel(m, anchor, cx, cy))
        entry.update(_nearest_own_city(m, cx, cy))

        near_cities = []
        for c in your_cities:
            d = m.hex.distance(cx, cy, c["x"], c["y"])
            if d <= near_radius:
                item = {"name": c["name"], "distance": d}
                max_hp = c.get("maxHp") or 0
                if max_hp:
                    item["hpPercent"] = round(
                        100 * (max_hp - (c.get("damage") or 0)) / max_hp
                    )
                near_cities.append(item)
        near_cities.sort(key=lambda c: c["distance"])
        entry["yourCitiesNearby"] = near_cities

        near_units = []
        for u in your_units:
            d = min(
                m.hex.distance(u["x"], u["y"], t[0], t[1]) for t in tiles
            )
            if d <= near_radius:
                near_units.append(
                    {
                        "name": u.get("name"),
                        "role": u.get("role"),
                        "distance": d,
                        "hp": u.get("hp"),
                        "maxHp": u.get("maxHp"),
                        "movesLeft": u.get("movesLeft"),
                    }
                )
        near_units.sort(key=lambda u: u["distance"])
        entry["yourUnitsNearby"] = near_units[:15]
        entry["yourUnitsNearbyTotal"] = len(near_units)
        clusters.append(entry)

    clusters.sort(
        key=lambda c: c.get("distanceFromThatCity", c.get("distanceFromAnchor", 10**6))
    )
    result["clusters"] = clusters
    if enemy_cities:
        cities = []
        for c in enemy_cities:
            item = {
                "name": c["name"],
                "civ": c.get("civ"),
                "x": c["x"],
                "y": c["y"],
                **_nearest_own_city(m, c["x"], c["y"]),
            }
            max_hp = c.get("maxHp") or 0
            if max_hp:
                item["hpPercent"] = round(
                    100 * (max_hp - (c.get("damage") or 0)) / max_hp
                )
            cities.append(item)
        cities.sort(key=lambda c: c.get("distanceFromThatCity", 10**6))
        result["visibleEnemyCities"] = cities
    return result


# === Local region ===


def describe_region(m, center_x, center_y, radius=3):
    """Every revealed tile within `radius` of the center, closest first,
    with all layers resolved to names."""
    if not (0 <= center_x < m.width and 0 <= center_y < m.height):
        return {"error": "center is off the map"}
    plot_words = {"M": "mountain", "H": "hills", "F": "flat", "W": "water"}
    cq, cr = _offset_to_axial(center_x, center_y)
    tiles = []
    unrevealed = 0
    for dq in range(-radius, radius + 1):
        for dr in range(
            max(-radius, -dq - radius), min(radius, -dq + radius) + 1
        ):
            x, y = _axial_to_offset(cq + dq, cr + dr)
            if not 0 <= y < m.height:
                continue
            if m.hex.wrap_x:
                x %= m.width
            elif not 0 <= x < m.width:
                continue
            if not m.revealed(x, y):
                unrevealed += 1
                continue
            d = m.hex.distance(center_x, center_y, x, y)
            entry = {
                "x": x,
                "y": y,
                "distance": d,
                "plot": plot_words.get(m.plot[y][x], "unknown"),
            }
            word = m.hex.compass(center_x, center_y, x, y)
            if word:
                entry["direction"] = word
            t_info = m.terrain_legend.get(m.terrain[y][x])
            if t_info:
                entry["terrain"] = t_info["name"]
            f_info = m.feature_legend.get(m.feature[y][x])
            if f_info:
                entry["feature"] = f_info["name"]
            if m.river[y][x] not in "0?":
                entry["river"] = True
            pid = m.owner_id(x, y)
            if pid is not None:
                entry["owner"] = m.civ_name(pid)
            res = m.resource_at.get((x, y))
            if res:
                info = m.resource_types.get(res["t"], {})
                entry["resource"] = info.get("name", res["t"])
            city = m.city_at.get((x, y))
            if city:
                entry["city"] = {
                    "name": city["name"],
                    "civ": m.civ_name(city["owner"]),
                }
            if not bool(m.vis[y][x] == "1"):
                entry["fogged"] = True
            tiles.append(entry)
    tiles.sort(key=lambda t: (t["distance"], t.get("direction", "")))
    return {
        "center": {"x": center_x, "y": center_y},
        "radius": radius,
        "tiles": tiles,
        "unrevealedTilesInRange": unrevealed,
    }


# === Empire constellation ===


def empire_constellation(m):
    """The player's cities as a shape: each placed from the capital and
    from its nearest sibling, with a coastal flag."""
    big_water, _ = _water_comp_sets(m)
    cap = (m.capital["x"], m.capital["y"]) if m.capital else None
    out = []
    for c in m.my_cities:
        entry = {
            "name": c["name"],
            "x": c["x"],
            "y": c["y"],
            "capital": bool(c.get("capital")),
            "coastal": any(
                n in big_water for n in m.hex.neighbors(c["x"], c["y"])
            ),
        }
        if cap and not c.get("capital"):
            entry["fromCapital"] = {
                "distance": m.hex.distance(cap[0], cap[1], c["x"], c["y"]),
                "direction": m.hex.compass(cap[0], cap[1], c["x"], c["y"]),
            }
        siblings = [s for s in m.my_cities if s is not c]
        if siblings:
            nearest = min(
                siblings,
                key=lambda s: m.hex.distance(s["x"], s["y"], c["x"], c["y"]),
            )
            entry["nearestOtherCity"] = {
                "name": nearest["name"],
                "distance": m.hex.distance(
                    nearest["x"], nearest["y"], c["x"], c["y"]
                ),
                "direction": m.hex.compass(
                    c["x"], c["y"], nearest["x"], nearest["y"]
                ),
            }
        out.append(entry)
    out.sort(key=lambda e: (not e["capital"], e.get("fromCapital", {}).get("distance", 0)))
    return out


# === Overview assembly ===

MAX_LANDMASSES_DETAILED = 8
MAX_WATER_BODIES = 5
# A fully-surveyed landmass this small is an islet: shape and relief words
# are meaningless at that size, so the overview folds them into one summary.
# A small *partially* revealed fragment stays a full entry -- it may be the
# visible tip of a continent.
ISLET_MAX_TILES = 5


def overview(m, anchor=None):
    total, revealed, visible = m.counts()
    masses = landmasses(m, anchor)
    water = water_bodies(m, anchor)
    positions = civ_positions(m, anchor)

    detailed = []
    islets = []
    for lm in masses:
        if (
            lm["tiles"] <= ISLET_MAX_TILES
            and lm["surveyedCompletely"]
            and not lm.get("yourHomeLandmass")
        ):
            islets.append(lm)
        else:
            detailed.append(lm)

    you = next((e for e in positions if e["you"]), None)
    you_section = {}
    if you:
        you_section = {
            "civ": you["civ"],
            "territoryTiles": you["knownTerritoryTiles"],
            "cities": empire_constellation(m),
        }
    if m.capital:
        third = ["southern", "central", "northern"][
            min(2, m.capital["y"] * 3 // max(m.height, 1))
        ]
        you_section["capital"] = {
            "x": m.capital["x"],
            "y": m.capital["y"],
            "latitudeBand": f"{third} third of the map",
        }
        home = next((l for l in masses if l.get("yourHomeLandmass")), None)
        if home:
            you_section["homeLandmassId"] = home["id"]

    lakes = [w for w in water if w["kind"] == "lake"]
    majors = [e for e in positions if not e["you"] and not e["cityState"]]
    minors = [e for e in positions if e["cityState"]]

    result = {
        "anchor": anchor,
        "map": {
            "width": m.width,
            "height": m.height,
            "wrapsEastWest": m.hex.wrap_x,
            "revealedPercent": round(100 * revealed / total),
            "currentlyVisiblePercent": round(100 * visible / total),
        },
        "you": you_section,
        "landmassCount": len(masses),
        "landmasses": detailed[:MAX_LANDMASSES_DETAILED],
        "waterBodies": water[:MAX_WATER_BODIES],
        "lakeCount": len(lakes),
        "knownNaturalWonders": [
            {
                "name": w["name"],
                "x": w["x"],
                "y": w["y"],
                **_rel(m, anchor, w["x"], w["y"]),
                **_nearest_own_city(m, w["x"], w["y"]),
            }
            for w in m.natural_wonders
        ],
        "politics": politics(m),
        "majorCivs": majors,
        "cityStates": [
            {
                "civ": e["civ"],
                "alive": e["alive"],
                **{k: e[k] for k in ("ally",) if k in e},
                **{
                    k: e[k]
                    for k in ("distanceFromAnchor", "directionFromAnchor")
                    if k in e
                },
            }
            for e in minors
        ],
    }
    if islets:
        notable = []
        for lm in islets:
            if not lm["civsPresent"] and not lm["naturalWonders"]:
                continue
            entry = {"id": lm["id"], "tiles": lm["tiles"], "center": lm["center"]}
            if lm["civsPresent"]:
                entry["civsPresent"] = [c["civ"] for c in lm["civsPresent"]]
            if lm["naturalWonders"]:
                entry["naturalWonders"] = lm["naturalWonders"]
            for k in ("distanceFromAnchor", "directionFromAnchor"):
                if k in lm:
                    entry[k] = lm[k]
            notable.append(entry)
        result["scatteredIslets"] = {
            "count": len(islets),
            "totalTiles": sum(l["tiles"] for l in islets),
            "notable": notable,
        }
    omitted = detailed[MAX_LANDMASSES_DETAILED:]
    if omitted:
        result["smallerLandmassesOmitted"] = {
            "count": len(omitted),
            "totalTiles": sum(l["tiles"] for l in omitted),
        }
    if len(water) > MAX_WATER_BODIES:
        result["smallerWaterBodiesOmitted"] = len(water) - MAX_WATER_BODIES
    return result
