"""MCP server bridging an MCP client (Claude Code, Claude Desktop) to a live
Civ V Access game session.

Transport: MCP stdio (newline-delimited JSON-RPC 2.0). Stdlib only -- no MCP
SDK dependency -- so the server runs on any Python 3.8+ via the py launcher.

Game link: a file mailbox under Documents\\My Games\\Sid Meier's Civilization
5\\CivVAccess\\rpc\\. Each tool call writes request.txt (atomically, temp +
os.replace); the proxy-injected `rpc` Lua binding inside the running game
consumes it on the next frame, CivVAccess_Rpc.lua executes the query against
live game state, and the reply lands atomically at response.json. Every
request carries a fresh id that the reply must echo, so a stale response
from an abandoned earlier request is never mistaken for the current one.

Register in an MCP client as: command "py", args [this file]. See .mcp.json
at the repo root for the project-scoped registration.

The consuming-agent guide lives in INSTRUCTIONS below (served through the
MCP initialize handshake); the fuller copy is docs/llm-docs/mcp-agent-guide.md.
"""

import base64
import ctypes
import json
import os
import sys
import time
import uuid

import civ5_geometry as geometry

PROTOCOL_FALLBACK = "2024-11-05"
SERVER_INFO = {"name": "civ5-access", "version": "0.2.0"}
RESPONSE_TIMEOUT_SECONDS = 10.0
POLL_INTERVAL_SECONDS = 0.05

NO_GAME_MESSAGE = (
    "No response from the game after {timeout:.0f} seconds. This usually means "
    "Civilization V is not running, Civ V Access is not deployed, or no game is "
    "in progress yet (the bridge only answers after the load screen closes)."
)

INSTRUCTIONS = """\
You are talking to a live Civilization V game through Civ V Access, an
accessibility layer for blind players. You are the sighted friend sitting
next to the player, looking at their screen. The player is blind,
experienced with screen readers, and well equipped at the tile level (the
mod gives them a hex cursor, a scanner, and per-tile speech), so they do
not need tiles read out one at a time. What they come to you for is what a
glance gives a sighted player: the shape of the world, how the pieces
relate, what is going on.

The conversation: match the answer's detail and level of focus to the
question, the way a friend at the screen would. "Where is the iron?" wants
a sentence. "What's going on in this game?" wants a detailed but high-level
answer -- the sweep of the world, the powers, where the player stands.
"What's happening west of my borders?" wants real detail, focused there.
"Where are all the natural wonders relative to everyone?" invites a
thorough enumeration. Answers are narrative, not inventory: a confused
player's problem is how the facts connect, so fold them into prose where
one fact leads into the next, and let follow-up questions steer rather
than front-loading everything you know. Well-supported inference is part
of a good description (a shrunken civ whose city names appear under a
rival's flag has probably lost a war); state inferences with the
confidence the evidence supports -- flag thin ones, don't hedge strong
ones.

Call order: civ5_ping first to confirm the game is reachable. For "tell me
about the map" start with civ5_map_overview, then drill down: civ5_landmass_tour
for the structure of one continent, civ5_civ_positions for neighbors and
politics, civ5_borders_report for what is just beyond the borders,
civ5_settle_scan for expansion room, civ5_war_report during wars,
civ5_describe_region for tile-level detail. civ5_point_cursor moves the
player's in-game map cursor to a location and announces it -- use it to
physically point at what you are describing, but only when the player asks
or clearly benefits, since it moves their working position. Point at a real
member tile, never a "center": cluster and zone centers are centroids and
can land on a tile that belongs to nothing, even open water between two
units. To point at a force, use one unit's own x,y from the payload.

civ5_render_map draws the revealed map, or a zoomed region of it (place or
x/y plus radius), as an image for YOU to look at -- the player cannot see
it. Use it for the gestalt judgments the structured data only
approximates: the shape of a coastline or continent, how a border winds,
how empires sit around a sea. Zoom before describing a specific area -- a
render centered on a shared border shows exactly how the two territories
meet. The image is never a data source: every number, distance, or
direction you speak comes from the data tools' hex-math fields, not from
counting pixels.

Anchors: every spatial tool accepts an optional "anchor" argument --
"capital" (default), "cursor" (the player's own map cursor), any known city
name, or "x,y". All distanceFromAnchor / directionFromAnchor fields are
relative to it. Distances are in tiles (hex steps); directions are 8-point
compass words matching what the in-game scanner speaks.

Coordinates: every x/y in payloads, in tool arguments, and on rendered
axis labels is the PLAYER's coordinate system -- relative to their
original capital, exactly what the in-game cursor's coordinate readout
speaks. y counts rows north of the capital (negative = south); x counts
columns east (negative = west) and ends in .5 on rows whose parity
differs from the capital's row. These numbers are safe to speak: they
mean the same thing to the player, and coordinates the player gives you
can be passed straight back in. Before the first city exists there is no
capital to measure from; payloads then carry raw map-grid coordinates and
say so in a coordinateSystem field.

Honesty rules, non-negotiable: the data already respects fog of war, and
your narration must too. surveyedCompletely=false means "at least this many
tiles, it continues into unexplored territory" -- never state its size as
final. "fogged": remembered but not currently visible; may be stale.
"water, extent unknown" may be lake or ocean. An ally of "an unmet
civilization" must stay unnamed. Never present absence of data as known
absence ("no iron revealed yet", not "there is no iron"). Distances and
directions you speak come from the payload's own distance / direction
fields (the mod's exact hex math) -- don't derive or sharpen them
yourself: "two tiles southeast" must actually be two tiles southeast, not
one east and one southeast eyeballed together.

Phrasing: prefer relational descriptions ("iron two tiles southeast of
Helsinki") -- a place's relation to somewhere the player knows carries
more meaning than a number pair -- but coordinates are the player's own,
so speak them when they help: pinning down an exact tile, or answering a
player who navigates by them. Pick a reference point the player knows and
describe from it consistently. Lead with the distinguishing fact. Keep
every gameplay-relevant number (distances, unit counts, city health,
resource quantities); drop filler and meta-commentary.
"""


def documents_dir():
    """The shell's Documents folder (CSIDL_PERSONAL), honoring redirection --
    same call the proxy DLL makes, so both ends agree on the mailbox."""
    buf = ctypes.create_unicode_buffer(260)
    result = ctypes.windll.shell32.SHGetFolderPathW(None, 5, None, 0, buf)
    if result != 0:
        raise OSError(f"SHGetFolderPathW(CSIDL_PERSONAL) failed: {result:#x}")
    return buf.value


# Overridable so offline harnesses can run a fake game in a scratch mailbox
# without racing a real session.
RPC_DIR = os.environ.get("CIVVACCESS_RPC_DIR") or os.path.join(
    documents_dir(), "My Games", "Sid Meier's Civilization 5", "CivVAccess", "rpc"
)
REQUEST_PATH = os.path.join(RPC_DIR, "request.txt")
RESPONSE_PATH = os.path.join(RPC_DIR, "response.json")


def game_query(name, *args, timeout=RESPONSE_TIMEOUT_SECONDS):
    """Send one query to the running game; return the reply envelope dict,
    or None on timeout (game not running / not in a game)."""
    os.makedirs(RPC_DIR, exist_ok=True)
    request_id = uuid.uuid4().hex[:12]
    line = "\t".join([request_id, name, *[str(a) for a in args]])

    # A response left over from an abandoned request would be re-read and
    # discarded by the id check anyway, but clearing it keeps the mailbox
    # tidy and the polling loop simple.
    _remove_quietly(RESPONSE_PATH)

    tmp = REQUEST_PATH + ".tmp"
    with open(tmp, "w", encoding="utf-8", newline="") as f:
        f.write(line)
    _replace_with_retry(tmp, REQUEST_PATH)

    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        envelope = _read_response()
        if envelope is not None:
            if envelope.get("id") == request_id:
                _remove_quietly(RESPONSE_PATH)
                return envelope
            _remove_quietly(RESPONSE_PATH)  # stale reply from an earlier request
        time.sleep(POLL_INTERVAL_SECONDS)

    # Withdraw the request if the game never picked it up, so it doesn't
    # fire minutes later when a game finally loads.
    _remove_quietly(REQUEST_PATH)
    return None


def _read_response():
    try:
        with open(RESPONSE_PATH, "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return None
    except (OSError, json.JSONDecodeError):
        # Mid-rename or truncated observation; the next poll re-reads.
        return None


def _remove_quietly(path):
    try:
        os.remove(path)
    except OSError:
        pass


def _replace_with_retry(src, dst, attempts=20):
    """os.replace, retrying while the game holds the destination open
    exclusively (it reads request.txt with no sharing for a few ms)."""
    for attempt in range(attempts):
        try:
            os.replace(src, dst)
            return
        except PermissionError:
            if attempt == attempts - 1:
                raise
            time.sleep(0.02)


# === Tools ===

_ANCHOR_PROPERTY = {
    "anchor": {
        "type": "string",
        "description": (
            "Reference point for all distances/directions: 'capital' "
            "(default), 'cursor' (the player's in-game map cursor), a known "
            "city name, or 'x,y' in the player's capital-relative "
            "coordinates."
        ),
    }
}

_COORD_ARG = {
    "type": "number",
    "description": (
        "Player coordinate (capital-relative, as spoken in game; x may "
        "end in .5 depending on the row)."
    ),
}

TOOLS = [
    {
        "name": "civ5_ping",
        "description": (
            "Check the running Civilization V session: your civilization, era, "
            "current turn, map size, and how many major civilizations are alive. "
            "Use this first to confirm the game is reachable."
        ),
        "inputSchema": {"type": "object", "properties": {}, "required": []},
    },
    {
        "name": "civ5_find_resource",
        "description": (
            "Find every revealed tile of a resource on the map, sorted by "
            "distance from the player's nearest own city, with coordinates, "
            "quantity, ownership, whether the tile is improved, and whether it "
            "is within reach of a city's border growth or tile purchase "
            "(withinCityRange). Respects fog of war: only tiles the player has "
            "revealed (and has the tech to see) are returned."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "resource": {
                    "type": "string",
                    "description": (
                        "Resource name ('iron', 'Wine') or type "
                        "('RESOURCE_IRON'). Localized display names also work."
                    ),
                }
            },
            "required": ["resource"],
        },
    },
    {
        "name": "civ5_count_in_borders",
        "description": (
            "Count tiles matching a resource, terrain, feature, or improvement "
            "inside the player's own borders, alongside the player's total "
            "owned-tile count for context. For resources, also reports total "
            "quantity and how many of those tiles are improved."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "category": {
                    "type": "string",
                    "enum": ["resource", "terrain", "feature", "improvement"],
                },
                "type": {
                    "type": "string",
                    "description": (
                        "Name ('wine', 'grassland', 'forest', 'farm') or full "
                        "type ('RESOURCE_WINE', 'TERRAIN_GRASS', ...)."
                    ),
                },
            },
            "required": ["category", "type"],
        },
    },
    {
        "name": "civ5_map_overview",
        "description": (
            "The big picture of the known map: landmasses (size, shape, relief, "
            "terrain zones and hill regions placed relationally, mountain "
            "ranges, who lives there), water bodies, natural wonders, the "
            "player's cities as a constellation, politics (wars, friendship "
            "blocs, city-state allies), and every met civilization with "
            "distance and direction from the anchor. Respects fog of war; "
            "surveyedCompletely=false means 'at least this many tiles'. Use "
            "this first for 'tell me about the map'."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {**_ANCHOR_PROPERTY},
            "required": [],
        },
    },
    {
        "name": "civ5_landmass_tour",
        "description": (
            "One landmass split into the regions a human eye would name -- "
            "lobes joined by narrow necks, areas separated by mountain or "
            "desert bands -- each described in one chunk: relief, terrain, "
            "rivers, cities, notable resources, coastline, connections to the "
            "other regions. Defaults to the player's home landmass; pass "
            "landmassId (from civ5_map_overview) for another. A landmass with "
            "no structure honestly reports one continuous region."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "landmassId": {
                    "type": "integer",
                    "description": "Landmass id from civ5_map_overview (1 = largest).",
                },
                **_ANCHOR_PROPERTY,
            },
            "required": [],
        },
    },
    {
        "name": "civ5_civ_positions",
        "description": (
            "Where every met civilization and city-state sits relative to the "
            "anchor: known territory and cities, best known seat, distance and "
            "direction, same-landmass flag, overland walking distance (or "
            "landRouteBlocked / seaOnly), who borders whom and over what "
            "ground, wars, friendships, defensive pacts, and city-state allies."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {**_ANCHOR_PROPERTY},
            "required": [],
        },
    },
    {
        "name": "civ5_borders_report",
        "description": (
            "What lies just beyond the player's borders: unclaimed resources, "
            "foreign territory and cities (with shared-border length and the "
            "ground the border runs over), natural wonders, and how close "
            "unexplored fog is. Distances are tiles beyond the border; each "
            "item is anchored to the player's nearest city with a compass "
            "direction."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "radius": {
                    "type": "integer",
                    "description": "How many tiles beyond the border to scan (default 5, max 10).",
                }
            },
            "required": [],
        },
    },
    {
        "name": "civ5_settle_scan",
        "description": (
            "Revealed land nobody owns, clustered into settleable areas: size, "
            "position from the anchor and the player's nearest city, walking "
            "distance from the player's border, fresh water and coast flags, "
            "terrain mix, resources inside, and which rival is closest to each "
            "area. Sorted by how reachable each area is."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {**_ANCHOR_PROPERTY},
            "required": [],
        },
    },
    {
        "name": "civ5_war_report",
        "description": (
            "The map of the current war(s): every visible hostile unit "
            "(barbarians included) clustered into forces, each with "
            "composition by role, position relative to the player's nearest "
            "city, and what the player has close by -- own units with health "
            "and moves, own cities with health. Also visible enemy cities. "
            "Visible-now only: fog may hide more, and it changes as units "
            "move, so re-call rather than reuse."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {**_ANCHOR_PROPERTY},
            "required": [],
        },
    },
    {
        "name": "civ5_describe_region",
        "description": (
            "Every revealed tile within a radius of a spot, closest first: "
            "plot type, terrain, feature, river, owner, resource, city, and a "
            "fogged flag for remembered-but-not-visible tiles. Use for local "
            "detail once an overview has identified somewhere interesting. "
            "Target by place name or by x/y."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "place": {
                    "type": "string",
                    "description": (
                        "Center: 'capital', 'cursor', a known city or natural "
                        "wonder name, or 'x,y'. Alternative to x/y."
                    ),
                },
                "x": _COORD_ARG,
                "y": _COORD_ARG,
                "radius": {
                    "type": "integer",
                    "description": "Ring radius in tiles (default 3, max 8).",
                },
            },
            "required": [],
        },
    },
    {
        "name": "civ5_point_cursor",
        "description": (
            "Move the player's in-game map cursor to a location and announce "
            "the landing tile through their screen reader -- physically point "
            "at what you are describing so the player can explore from there "
            "with their own keys. Moves the player's working position, so use "
            "when asked or clearly helpful, and say where you pointed. Mod "
            "cursor only; game state is never touched."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "place": {
                    "type": "string",
                    "description": (
                        "Target: 'capital', a known city or natural wonder "
                        "name, or 'x,y'. Alternative to x/y."
                    ),
                },
                "x": _COORD_ARG,
                "y": _COORD_ARG,
            },
            "required": [],
        },
    },
    {
        "name": "civ5_render_map",
        "description": (
            "Render the revealed map -- or a zoomed region of it -- as an "
            "image for YOU to look at (the player cannot see it). Use it "
            "for gestalt judgments the structured data approximates: the "
            "shape of a coastline, how a border winds, how empires sit "
            "around a sea. With no arguments it renders the whole revealed "
            "map; pass place (or x/y) plus radius to zoom into one region, "
            "e.g. the area around a shared border. Never read numbers, "
            "distances, or directions off the image -- every figure you "
            "speak comes from the data tools' hex-math fields."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "place": {
                    "type": "string",
                    "description": (
                        "Center of a zoomed view: 'capital', 'cursor', a "
                        "known city or natural wonder name, or 'x,y'. "
                        "Alternative to x/y. Omit everything for the "
                        "whole map."
                    ),
                },
                "x": _COORD_ARG,
                "y": _COORD_ARG,
                "radius": {
                    "type": "integer",
                    "description": (
                        "Zoom radius in tiles around the center "
                        "(default 10, max 25)."
                    ),
                },
            },
            "required": [],
        },
    },
]

GEOMETRY_TOOLS = {
    "civ5_map_overview",
    "civ5_landmass_tour",
    "civ5_civ_positions",
    "civ5_borders_report",
    "civ5_settle_scan",
    "civ5_war_report",
    "civ5_describe_region",
    "civ5_point_cursor",
}


def _fresh_map():
    """One fresh dump per tool call -- the map changes mid-turn as units
    move and tiles reveal, so nothing is ever cached across calls."""
    envelope = game_query("dump_map")
    if envelope is None:
        return None, (NO_GAME_MESSAGE.format(timeout=RESPONSE_TIMEOUT_SECONDS), True)
    if not envelope.get("ok"):
        return None, (json.dumps(envelope, ensure_ascii=False, indent=2), True)
    return envelope, None


def _target_from_args(m, arguments, default=None):
    """Engine (x, y) from a `place` string or explicit x/y args; explicit
    args arrive in the player's capital-relative coordinates (raw grid
    only before a capital exists)."""
    if arguments.get("place") is not None:
        x, y, _label = geometry.resolve_place(m, arguments["place"])
        return x, y
    if arguments.get("x") is not None and arguments.get("y") is not None:
        px, py = float(arguments["x"]), float(arguments["y"])
        if m.coord_origin is not None:
            return geometry.engine_coords(m.coord_origin, px, py)
        return int(px), int(py)
    if default is not None:
        return default
    raise geometry.PlaceError("pass either place or x and y")


def call_geometry_tool(name, arguments):
    envelope, err = _fresh_map()
    if err:
        return err
    origin = envelope.get("coordOrigin")
    m = geometry.MapData(envelope["data"], origin)
    try:
        anchor = geometry.resolve_anchor(m, arguments.get("anchor"))
    except geometry.PlaceError as e:
        if arguments.get("anchor") is None:
            anchor = None  # no capital and no cursor yet; describe unanchored
        else:
            return str(e), True

    try:
        if name == "civ5_map_overview":
            result = geometry.overview(m, anchor)
        elif name == "civ5_landmass_tour":
            landmass_id = arguments.get("landmassId")
            result = geometry.landmass_tour(
                m, anchor, int(landmass_id) if landmass_id is not None else None
            )
            result["anchor"] = anchor
        elif name == "civ5_civ_positions":
            result = geometry.civ_positions(m, anchor)
        elif name == "civ5_borders_report":
            radius = max(1, min(10, int(arguments.get("radius", 5))))
            result = geometry.borders_report(m, radius)
        elif name == "civ5_settle_scan":
            result = geometry.settle_scan(m, anchor)
            result["anchor"] = anchor
        elif name == "civ5_war_report":
            hostiles = game_query("list_hostiles")
            if hostiles is None:
                return NO_GAME_MESSAGE.format(timeout=RESPONSE_TIMEOUT_SECONDS), True
            if not hostiles.get("ok"):
                return json.dumps(hostiles, ensure_ascii=False, indent=2), True
            result = geometry.war_report(m, hostiles["data"], anchor)
            result["anchor"] = anchor
        elif name == "civ5_describe_region":
            x, y = _target_from_args(m, arguments)
            radius = max(1, min(8, int(arguments.get("radius", 3))))
            result = geometry.describe_region(m, x, y, radius)
        else:  # civ5_point_cursor
            x, y = _target_from_args(m, arguments)
            point = game_query("point_cursor", x, y)
            if point is None:
                return NO_GAME_MESSAGE.format(timeout=RESPONSE_TIMEOUT_SECONDS), True
            point.pop("coordOrigin", None)
            return (
                json.dumps(
                    geometry.convert_payload(point, origin),
                    ensure_ascii=False,
                    indent=2,
                ),
                not point.get("ok"),
            )
    except geometry.PlaceError as e:
        return str(e), True

    out = {
        "turn": envelope.get("turn"),
        "activePlayer": envelope.get("activePlayer"),
        "ok": True,
        "data": result,
    }
    if origin is None:
        out["coordinateSystem"] = (
            "raw map grid: no capital exists yet, so the capital-relative "
            "coordinates the player hears in game are unavailable"
        )
    return json.dumps(
        geometry.convert_payload(out, origin), ensure_ascii=False, indent=2
    ), False


def call_render_tool(arguments):
    try:
        import civ5_render
    except ImportError as e:
        return (
            f"map rendering needs the Pillow package "
            f"(py -m pip install pillow): {e}",
            True,
        )
    envelope, err = _fresh_map()
    if err:
        return err
    origin = envelope.get("coordOrigin")
    m = geometry.MapData(envelope["data"], origin)
    center = None
    try:
        if any(arguments.get(k) is not None for k in ("place", "x", "y")):
            center = _target_from_args(m, arguments)
    except geometry.PlaceError as e:
        return str(e), True
    radius = None
    if center is not None:
        radius = max(2, min(25, int(arguments.get("radius") or 10)))
    png, meta = civ5_render.render_png(m, center=center, radius=radius)
    meta["turn"] = envelope.get("turn")
    return [
        {
            "type": "image",
            "data": base64.b64encode(png).decode("ascii"),
            "mimeType": "image/png",
        },
        {"type": "text", "text": json.dumps(meta, ensure_ascii=False, indent=2)},
    ], False


def call_tool(name, arguments):
    """Returns (content, is_error); content is a string (wrapped as one
    text block) or a ready content list (e.g. an image plus its legend)."""
    if name == "civ5_render_map":
        return call_render_tool(arguments)
    if name == "civ5_ping":
        envelope = game_query("ping")
    elif name == "civ5_find_resource":
        envelope = game_query("find_resource", arguments["resource"])
    elif name == "civ5_count_in_borders":
        envelope = game_query(
            "count_in_borders", arguments["category"], arguments["type"]
        )
    elif name in GEOMETRY_TOOLS:
        return call_geometry_tool(name, arguments)
    else:
        return f"unknown tool: {name}", True

    if envelope is None:
        return NO_GAME_MESSAGE.format(timeout=RESPONSE_TIMEOUT_SECONDS), True
    origin = envelope.pop("coordOrigin", None)
    envelope = geometry.convert_payload(envelope, origin)
    return json.dumps(envelope, ensure_ascii=False, indent=2), not envelope.get("ok")


# === JSON-RPC over stdio ===


def handle_request(msg):
    """Returns the result object for a request, or raises RpcError."""
    method = msg.get("method")
    params = msg.get("params") or {}
    if method == "initialize":
        return {
            "protocolVersion": params.get("protocolVersion", PROTOCOL_FALLBACK),
            "capabilities": {"tools": {}},
            "serverInfo": SERVER_INFO,
            "instructions": INSTRUCTIONS,
        }
    if method == "ping":
        return {}
    if method == "tools/list":
        return {"tools": TOOLS}
    if method == "tools/call":
        result, is_error = call_tool(params.get("name"), params.get("arguments") or {})
        content = result if isinstance(result, list) else [
            {"type": "text", "text": result}
        ]
        return {"content": content, "isError": is_error}
    raise RpcError(-32601, f"method not found: {method}")


class RpcError(Exception):
    def __init__(self, code, message):
        super().__init__(message)
        self.code = code
        self.message = message


def send(obj):
    sys.stdout.write(json.dumps(obj, ensure_ascii=False) + "\n")
    sys.stdout.flush()


def main():
    # The py launcher defaults stdio to the console codepage; MCP requires
    # UTF-8 both ways (localized civ names travel through here).
    sys.stdin.reconfigure(encoding="utf-8")
    sys.stdout.reconfigure(encoding="utf-8", newline="\n")

    for raw in sys.stdin:
        raw = raw.strip()
        if not raw:
            continue
        try:
            msg = json.loads(raw)
        except json.JSONDecodeError as e:
            send(
                {
                    "jsonrpc": "2.0",
                    "id": None,
                    "error": {"code": -32700, "message": f"parse error: {e}"},
                }
            )
            continue
        if "id" not in msg:
            continue  # notification (notifications/initialized etc.); nothing to do
        reply = {"jsonrpc": "2.0", "id": msg["id"]}
        try:
            reply["result"] = handle_request(msg)
        except RpcError as e:
            reply["error"] = {"code": e.code, "message": e.message}
        except Exception as e:  # never let one bad request kill the server
            reply["error"] = {"code": -32603, "message": f"internal error: {e}"}
        send(reply)


if __name__ == "__main__":
    main()
