"""Offline tests for civ5_geometry.py against synthetic dumps.

Run: py tools/mcp/test_geometry.py
Exit code 0 on success; assertion failure otherwise.

The builder takes a compact picture of the map: one string per row,
y = 0 (map south) FIRST in the list, chars:
    ?  unrevealed
    .  ocean water        c  coast water (same plot type, other terrain)
    g  flat grass         p  flat plains
    h  grass hills        m  mountain
    d  flat desert
An optional owner picture (same shape, '-' none, digit = player id) and
sparse city / resource lists complete the dump.
"""

import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import civ5_geometry as geo  # noqa: E402

LAND = {"g": "F", "p": "F", "h": "H", "m": "M", "d": "F"}
TERRAIN_CHAR = {"g": "a", "h": "a", "m": "a", "p": "b", ".": "c", "c": "d", "d": "e"}
TERRAIN_LEGEND = {
    "a": {"type": "TERRAIN_GRASS", "name": "Grassland"},
    "b": {"type": "TERRAIN_PLAINS", "name": "Plains"},
    "c": {"type": "TERRAIN_OCEAN", "name": "Ocean"},
    "d": {"type": "TERRAIN_COAST", "name": "Coast"},
    "e": {"type": "TERRAIN_DESERT", "name": "Desert"},
}


def make_dump(picture, owners=None, wrap_x=False, capital=None, cities=None,
              resources=None, players=None, fogged=None, cursor=None,
              rivers=None):
    height = len(picture)
    width = len(picture[0])
    fogged = fogged or set()
    rivers = rivers or set()
    vis, plot, terrain, feature, river, owner = [], [], [], [], [], []
    for y in range(height):
        vrow, prow, trow, frow, rrow, orow = [], [], [], [], [], []
        for x in range(width):
            ch = picture[y][x]
            if ch == "?":
                vrow.append("?"); prow.append("?"); trow.append("?")
                frow.append("?"); rrow.append("?"); orow.append("?")
                continue
            vrow.append("0" if (x, y) in fogged else "1")
            prow.append(LAND.get(ch, "W"))
            trow.append(TERRAIN_CHAR[ch])
            frow.append("-")
            rrow.append("1" if (x, y) in rivers else "0")
            oc = owners[y][x] if owners else "-"
            orow.append(oc)
        vis.append("".join(vrow)); plot.append("".join(prow))
        terrain.append("".join(trow)); feature.append("".join(frow))
        river.append("".join(rrow)); owner.append("".join(orow))

    owner_legend = {}
    if owners:
        for row in owners:
            for ch in row:
                if ch not in "-?":
                    owner_legend[ch] = {"player": int(ch)}

    if players is None:
        players = [{"id": 0, "civ": "Testia", "minor": False, "alive": True,
                    "you": True}]
    return {
        "width": width,
        "height": height,
        "wrapX": wrap_x,
        "capital": capital,
        "cursor": cursor,
        "layers": {
            "visibility": vis, "plotType": plot, "terrain": terrain,
            "feature": feature, "river": river, "owner": owner,
        },
        "legends": {
            "terrain": TERRAIN_LEGEND, "feature": {}, "owner": owner_legend,
        },
        "cities": cities or [],
        "resources": resources or [],
        "resourceTypes": {
            # 2 = RESOURCEUSAGE_LUXURY, 1 = STRATEGIC (enum: bonus,
            # strategic, luxury -- CvEnums.h).
            "RESOURCE_WINE": {"name": "Wine", "usage": 2},
            "RESOURCE_IRON": {"name": "Iron", "usage": 1},
        },
        "naturalWonders": [],
        "players": players,
    }


def city(x, y, name, owner=0, capital=False, visible=True):
    return {"x": x, "y": y, "name": name, "owner": owner,
            "capital": capital, "visible": visible}


def major(pid, name, you=False, **extra):
    return {"id": pid, "civ": name, "minor": False, "alive": True,
            "you": you, **extra}


def minor(pid, name, **extra):
    return {"id": pid, "civ": name, "minor": True, "alive": True,
            "you": False, **extra}


def test_hex_math():
    h = geo.HexMap(10, 10, wrap_x=False)
    assert h.distance(0, 0, 1, 0) == 1
    assert h.distance(0, 0, 0, 1) == 1  # NE step from an even row
    assert h.distance(2, 2, 2, 4) == 2  # two rows straight north
    assert h.compass(0, 0, 3, 0) == "east"
    assert h.compass(3, 0, 0, 0) == "west"
    assert h.compass(2, 2, 2, 6) == "north"
    assert h.compass(2, 6, 2, 2) == "south"
    assert h.compass(0, 0, 3, 3) in ("northeast", "east")  # NE-ish
    assert h.compass(5, 5, 5, 5) is None

    wrapped = geo.HexMap(10, 10, wrap_x=True)
    assert wrapped.distance(0, 0, 9, 0) == 1, "wrap makes far-x adjacent"
    assert wrapped.compass(0, 0, 9, 0) == "west", "shortest way is west"
    assert wrapped.distance(0, 0, 5, 0) == 5, "antipode unaffected"


def test_landmass_detection_and_fog():
    picture = [
        "..........",
        ".ggg...g..",
        ".ggg......",
        "....??????",
        "....??????",
    ]
    m = geo.MapData(make_dump(picture))
    masses = geo.landmasses(m)
    assert len(masses) == 2, masses
    assert masses[0]["tiles"] == 6
    assert masses[1]["tiles"] == 1
    assert masses[0]["surveyedCompletely"], "big island is fully surveyed"
    # Every landmass tile must be revealed land; '?' cells never join.
    total_land_tiles = sum(mm["tiles"] for mm in masses)
    assert total_land_tiles == 7


def test_landmass_across_wrap_seam():
    picture = [
        "..........",
        "gg......gg",
        "..........",
    ]
    m = geo.MapData(make_dump(picture, wrap_x=True))
    masses = geo.landmasses(m)
    assert len(masses) == 1, "seam-straddling land is one landmass"
    assert masses[0]["tiles"] == 4
    assert masses[0]["spanEastWest"] == 4, "extent measured across the seam"


def test_water_classification():
    picture = [
        "ggggggggg?",
        "g.g...ggg?",
        "ggggggggg?",
        "ccccccccc?",
    ]
    m = geo.MapData(make_dump(picture))
    water = geo.water_bodies(m)
    kinds = sorted((w["kind"], w["tiles"]) for w in water)
    # 1-tile and 3-tile enclosed ponds are lakes; the bottom strip touches
    # unrevealed cells so its extent is unknown.
    assert ("lake", 1) in kinds, kinds
    assert ("lake", 3) in kinds, kinds
    assert any(k.startswith("water, extent unknown") for k, _ in kinds), kinds


def test_mountain_range():
    picture = [
        "..........",
        ".mmmm.....",
        "..........",
    ]
    m = geo.MapData(make_dump(picture))
    masses = geo.landmasses(m)
    ranges = masses[0]["mountainRanges"]
    assert len(ranges) == 1
    assert ranges[0]["peaks"] == 4
    assert ranges[0]["lengthTiles"] == 4
    assert ranges[0]["running"] in ("east", "west")


def test_resolve_anchor_and_places():
    picture = [
        "ggggg",
        "ggggg",
    ]
    dump = make_dump(picture, capital={"x": 1, "y": 1},
                     cities=[city(1, 1, "Home", capital=True)],
                     cursor={"x": 3, "y": 0})
    m = geo.MapData(dump)
    a = geo.resolve_anchor(m)
    assert (a["x"], a["y"], a["name"]) == (1, 1, "Home")
    c = geo.resolve_anchor(m, "cursor")
    assert (c["x"], c["y"], c["name"]) == (3, 0, "the cursor")
    byname = geo.resolve_anchor(m, "home")  # case-insensitive
    assert (byname["x"], byname["y"]) == (1, 1)
    xy = geo.resolve_anchor(m, "2,1")
    assert (xy["x"], xy["y"]) == (2, 1)
    try:
        geo.resolve_place(m, "atlantis")
        raise AssertionError("unknown place must raise")
    except geo.PlaceError as e:
        assert "atlantis" in str(e)
    no_cursor = geo.MapData(make_dump(picture, capital={"x": 1, "y": 1}))
    try:
        geo.resolve_anchor(no_cursor, "cursor")
        raise AssertionError("unset cursor must raise")
    except geo.PlaceError:
        pass


def test_spatial_clusters_primitive():
    picture = [
        "ggggggggg",
        "ghhgggghg",
        "ghhgggghg",
        "ggggggggg",
    ]
    m = geo.MapData(make_dump(picture, capital={"x": 0, "y": 0},
                              cities=[city(0, 0, "Home", capital=True)]))
    anchor = geo.resolve_anchor(m)
    hills = {(x, y) for x, y in m.tiles() if m.plot[y][x] == "H"}
    clusters = geo.spatial_clusters(m, hills, anchor)
    assert len(clusters) == 2, clusters
    assert clusters[0]["tiles"] == 4 and clusters[1]["tiles"] == 2
    assert "distanceFromAnchor" in clusters[0]
    assert "directionFromAnchor" in clusters[0]
    assert clusters[0]["nearestYourCity"] == "Home"
    # The landmass entry lists only clusters of 4+ as hill regions.
    masses = geo.landmasses(m, anchor)
    assert len(masses[0]["hillRegions"]) == 1, masses[0]["hillRegions"]


def test_landmass_zones_desert_belt():
    picture = ["gggggddggggg"] * 6
    m = geo.MapData(make_dump(picture, capital={"x": 1, "y": 2},
                              cities=[city(1, 2, "Home", capital=True)]))
    anchor = geo.resolve_anchor(m)
    entry = geo.landmasses(m, anchor)[0]
    deserts = [z for z in entry["terrainZones"] if z["terrain"] == "Desert"]
    assert len(deserts) == 1, entry["terrainZones"]
    assert deserts[0]["tiles"] == 12
    assert deserts[0]["directionFromAnchor"] == "east"
    # Grassland is the background (>60%); it must not appear as a zone.
    assert not any(z["terrain"] == "Grassland" for z in entry["terrainZones"])
    assert entry["relief"] == "mostly flat"


def test_empire_constellation():
    picture = [
        "cccccccccccc",
        "gggggggggggg",
        "gggggggggggg",
    ]
    m = geo.MapData(make_dump(
        picture, capital={"x": 0, "y": 1},
        cities=[city(0, 1, "Home", capital=True), city(4, 1, "East")],
    ))
    cities = geo.empire_constellation(m)
    assert cities[0]["name"] == "Home" and cities[0]["capital"]
    assert cities[0]["coastal"], "capital touches the 12-tile sea"
    east = cities[1]
    assert east["fromCapital"]["distance"] == 4
    assert east["fromCapital"]["direction"] == "east"
    assert cities[0]["nearestOtherCity"]["name"] == "East"
    assert cities[0]["nearestOtherCity"]["distance"] == 4


def test_politics_and_contact():
    picture = [
        "gggggggggg",
        "gggggggggg",
    ]
    owners = [
        "0011------",
        "0011------",
    ]
    players = [
        major(0, "Testia", you=True, atWarWith=[1]),
        major(1, "Rivalia", atWarWith=[0]),
        major(2, "Amity", friendsWith=[3], defensivePactsWith=[3]),
        major(3, "Concord", friendsWith=[2], defensivePactsWith=[2]),
        minor(4, "Georgetown", allyId=2),
        minor(5, "Mystery", hasUnmetAlly=True),
    ]
    m = geo.MapData(make_dump(
        picture, owners=owners, players=players, capital={"x": 0, "y": 0},
        cities=[city(0, 0, "Home", capital=True)],
    ))
    pol = geo.politics(m)
    assert pol["yourWars"] == ["Rivalia"]
    assert ["Rivalia", "Testia"] in pol["wars"]
    assert len(pol["friendshipBlocs"]) == 1
    bloc = pol["friendshipBlocs"][0]
    assert bloc["members"] == ["Amity", "Concord"]
    assert bloc["defensivePacts"] == [["Amity", "Concord"]]
    assert bloc["internalWars"] == []
    allies = {a["cityState"]: a["ally"] for a in pol["cityStateAllies"]}
    assert allies["Georgetown"] == "Amity"
    assert allies["Mystery"] == "an unmet civilization"

    anchor = geo.resolve_anchor(m)
    pos = geo.civ_positions(m, anchor)
    rival = next(e for e in pos if e["civ"] == "Rivalia")
    assert rival["bordersYou"] is True
    assert rival["borderWithYou"]["tiles"] >= 2
    assert rival["borderWithYou"]["terrain"] == ["open ground"]
    assert rival["atWarWith"] == ["Testia"]


def test_bloc_internal_war_flag():
    # A friendship chain linking two civs that are themselves at war is a
    # web, not a bloc; internalWars must expose the war inside it.
    players = [
        major(0, "Testia", you=True, friendsWith=[2]),
        major(1, "Farland", friendsWith=[2], atWarWith=[0]),
        major(2, "Middle", friendsWith=[0, 1]),
    ]
    m = geo.MapData(make_dump(
        ["gggg"], players=players, capital={"x": 0, "y": 0},
        cities=[city(0, 0, "Home", capital=True)],
    ))
    pol = geo.politics(m)
    assert len(pol["friendshipBlocs"]) == 1
    bloc = pol["friendshipBlocs"][0]
    assert bloc["members"] == ["Farland", "Middle", "Testia"]
    assert bloc["internalWars"] == [["Farland", "Testia"]]


def test_overland_routes():
    picture = [
        "ggmgg......",
        "ggmgg..gg..",
        "ggmgg......",
    ]
    owners = [
        "--m--......".replace("m", "-").replace(".", "-"),
        "0-m-1..22..".replace("m", "-").replace(".", "-"),
        "-----......".replace(".", "-"),
    ]
    players = [
        major(0, "Testia", you=True),
        major(1, "Wallia"),
        major(2, "Islandia"),
    ]
    cities = [
        city(0, 1, "Home", owner=0, capital=True),
        city(4, 1, "Overwall", owner=1, capital=True),
        city(8, 1, "Faraway", owner=2, capital=True),
    ]
    m = geo.MapData(make_dump(picture, owners=owners, players=players,
                              cities=cities, capital={"x": 0, "y": 1}))
    anchor = geo.resolve_anchor(m)
    pos = geo.civ_positions(m, anchor)
    wallia = next(e for e in pos if e["civ"] == "Wallia")
    assert wallia["landRouteBlocked"] is True, wallia
    assert wallia["sharesYourLandmass"] is True
    islandia = next(e for e in pos if e["civ"] == "Islandia")
    assert islandia["seaOnly"] is True, islandia
    assert islandia["sharesYourLandmass"] is False


def test_settle_scan():
    picture = [
        "cccccccccccc",
        "gggggggggggg",
        "gggggggggggg",
    ]
    owners = [
        "------------",
        "00--------11",
        "00--------11",
    ]
    players = [major(0, "Testia", you=True), major(1, "Rivalia")]
    m = geo.MapData(make_dump(
        picture, owners=owners, players=players, capital={"x": 0, "y": 1},
        cities=[city(0, 1, "Home", capital=True)],
        rivers={(6, 1)},
        resources=[{"x": 5, "y": 2, "t": "RESOURCE_WINE"}],
    ))
    anchor = geo.resolve_anchor(m)
    result = geo.settle_scan(m, anchor)
    areas = result["settleableAreas"]
    assert len(areas) == 1, areas
    area = areas[0]
    assert area["tiles"] == 16
    assert area["freshWater"] is True
    assert area["coastal"] is True
    assert area["walkingDistanceFromYourBorder"] == 1
    assert area["closestRival"] == {"civ": "Rivalia", "distance": 1}
    assert area["resources"][0]["resource"] == "Wine"
    assert area["resources"][0]["usage"] == "luxury"


def test_tour_lobes():
    picture = [
        ".............",
        ".gggg..ggggg.",
        ".ggggggggggg.",
        ".gggg..ggggg.",
        ".............",
    ]
    m = geo.MapData(make_dump(
        picture, capital={"x": 2, "y": 2},
        cities=[city(2, 2, "Home", capital=True)],
    ))
    anchor = geo.resolve_anchor(m)
    tour = geo.landmass_tour(m, anchor)
    assert tour["regionCount"] == 2, tour
    first = tour["regions"][0]
    assert first["containsAnchor"] is True
    assert "Home" in first["yourCities"]
    conns = first.get("connections") or []
    assert conns and conns[0]["narrowNeck"] is True, first


def test_tour_mountain_divider():
    water = "." * 24
    land_row = ".." + "g" * 10 + "m" + "g" * 9 + ".."
    picture = [water, water] + [land_row] * 6 + [water, water]
    m = geo.MapData(make_dump(
        picture, capital={"x": 4, "y": 4},
        cities=[city(4, 4, "Home", capital=True)],
    ))
    anchor = geo.resolve_anchor(m)
    tour = geo.landmass_tour(m, anchor)
    assert tour["regionCount"] == 2, tour
    first = tour["regions"][0]
    assert first["containsAnchor"] is True
    conns = first.get("connections") or []
    assert conns and conns[0].get("separatedBy") == "mountains", tour


def test_tour_structureless():
    picture = [
        "......",
        ".gggg.",
        ".gggg.",
        "......",
    ]
    m = geo.MapData(make_dump(picture))
    tour = geo.landmass_tour(m)
    assert tour["regionCount"] == 1
    assert tour["note"].startswith("one continuous region")


def test_war_report():
    picture = [
        "gggggggggg",
        "gggggggggg",
        "gggggggggg",
        "gggggggggg",
    ]
    players = [major(0, "Testia", you=True, atWarWith=[1]),
               major(1, "Rivalia", atWarWith=[0])]
    m = geo.MapData(make_dump(
        picture, players=players, capital={"x": 2, "y": 1},
        cities=[city(2, 1, "Home", capital=True)],
    ))
    anchor = geo.resolve_anchor(m)
    data = {
        "hostileUnits": [
            {"x": 5, "y": 1, "name": "Rivalian Warrior", "role": "melee",
             "hp": 70, "maxHp": 100, "embarked": False, "civ": "Rivalia",
             "barbarian": False},
            {"x": 6, "y": 1, "name": "Rivalian Archer", "role": "ranged",
             "hp": 100, "maxHp": 100, "embarked": False, "civ": "Rivalia",
             "barbarian": False},
            {"x": 9, "y": 3, "name": "Brute", "role": "barbarians",
             "hp": 100, "maxHp": 100, "embarked": False, "civ": "Barbarians",
             "barbarian": True},
        ],
        "yourUnits": [
            {"x": 4, "y": 1, "name": "Archer", "role": "ranged", "hp": 100,
             "maxHp": 100, "embarked": False, "movesLeft": 2},
        ],
        "yourCities": [
            {"name": "Home", "x": 2, "y": 1, "damage": 25, "maxHp": 100},
        ],
        "visibleEnemyCities": [],
    }
    report = geo.war_report(m, data, anchor)
    assert report["atWarWith"] == ["Rivalia"]
    assert report["visibleHostileUnits"] == 3
    assert len(report["clusters"]) == 2, report["clusters"]
    force = report["clusters"][0]
    assert force["units"] == 2
    assert force["composition"] == {"ranged": 1, "melee": 1}
    assert force["nearestYourCity"] == "Home"
    assert force["yourUnitsNearby"][0]["name"] == "Archer"
    assert force["yourCitiesNearby"][0]["hpPercent"] == 75
    assert force["allBarbarian"] is False
    barb = report["clusters"][1]
    assert barb["allBarbarian"] is True

    quiet = geo.war_report(
        geo.MapData(make_dump(picture, players=[major(0, "Testia", you=True)])),
        {"hostileUnits": [], "yourUnits": [], "yourCities": [],
         "visibleEnemyCities": []},
    )
    assert quiet["clusters"] == []
    assert "at war with no one" in quiet["note"]


def test_civ_positions_and_landmass_sharing():
    picture = [
        "gggg...ggg",
        "gggg...ggg",
    ]
    owners = [
        "00------11",
        "00------1-",
    ]
    players = [
        major(0, "Testia", you=True),
        major(1, "Rivalia"),
    ]
    cities = [
        city(0, 0, "Home", owner=0, capital=True),
        city(8, 0, "Far", owner=1, capital=True, visible=False),
    ]
    m = geo.MapData(make_dump(picture, owners=owners, players=players,
                              cities=cities, capital={"x": 0, "y": 0}))
    anchor = geo.resolve_anchor(m)
    pos = geo.civ_positions(m, anchor)
    assert pos[0]["you"] is True
    rival = next(e for e in pos if e["civ"] == "Rivalia")
    assert rival["knownTerritoryTiles"] == 3
    assert rival["knownSeat"] == {"x": 8, "y": 0}
    assert rival["sharesYourLandmass"] is False, "separate islands"
    assert rival["directionFromAnchor"] == "east"
    assert rival["knownCities"][0]["currentlyVisible"] is False
    assert rival["seaOnly"] is True


def test_borders_report():
    picture = [
        "gggggg????",
        "gggggg????",
        "gggggg????",
    ]
    owners = [
        "00----????",
        "00--11????",
        "00----????",
    ]
    players = [
        major(0, "Testia", you=True),
        major(1, "Rivalia"),
    ]
    cities = [
        city(0, 1, "Home", owner=0, capital=True),
    ]
    resources = [{"x": 3, "y": 1, "t": "RESOURCE_WINE"}]
    m = geo.MapData(make_dump(picture, owners=owners, players=players,
                              cities=cities, resources=resources,
                              capital={"x": 0, "y": 1}))
    report = geo.borders_report(m, radius=5)
    assert report["ownedTiles"] == 6
    wine = report["unclaimedResources"][0]
    assert wine["resource"] == "Wine" and wine["usage"] == "luxury"
    assert wine["tilesBeyondBorder"] == 2, wine
    assert wine["nearestYourCity"] == "Home"
    rival = report["foreignNeighbors"][0]
    assert rival["civ"] == "Rivalia"
    assert rival["closestTilesBeyondBorder"] == 3
    assert report["fogTilesTouchingRadius"] > 0, "fog column is in range"
    assert report["closestFogTilesBeyondBorder"] == 5


def test_describe_region():
    picture = [
        "ggggg",
        "gg.gg",
        "gg?gg",
    ]
    m = geo.MapData(make_dump(picture, fogged={(0, 0)}))
    region = geo.describe_region(m, 2, 1, radius=1)
    assert region["unrevealedTilesInRange"] == 1
    center = region["tiles"][0]
    assert center["distance"] == 0 and center["plot"] == "water"
    assert all("direction" in t for t in region["tiles"][1:])
    fog_check = geo.describe_region(m, 0, 0, radius=1)
    assert any(t.get("fogged") for t in fog_check["tiles"]), "fogged flag set"
    assert geo.describe_region(m, 99, 0)["error"]


def test_overview_assembly():
    picture = [
        "ggggg?????",
        "ggggg?????",
        ".....?????",
    ]
    owners = [
        "0----?????",
        "-----?????",
        "-----?????",
    ]
    cities = [
        city(0, 0, "Home", owner=0, capital=True),
    ]
    m = geo.MapData(make_dump(picture, owners=owners, cities=cities,
                              capital={"x": 0, "y": 0}))
    anchor = geo.resolve_anchor(m)
    result = geo.overview(m, anchor)
    assert result["anchor"]["name"] == "Home"
    assert result["map"]["revealedPercent"] == 50
    assert result["you"]["capital"]["latitudeBand"].startswith("southern")
    assert result["you"]["homeLandmassId"] == 1
    assert result["you"]["cities"][0]["name"] == "Home"
    assert "coastal" in result["you"]["cities"][0]
    assert "politics" in result
    assert result["landmasses"][0]["yourHomeLandmass"] is True
    assert result["landmasses"][0]["surveyedCompletely"] is False, (
        "land touching fog must not claim full survey"
    )
    assert result["landmassCount"] == 1


def test_overview_islet_collapse():
    # Home mass (8 tiles), one bare islet, one islet carrying a natural
    # wonder, and a 1-tile fragment touching fog that may be a continent's
    # tip. The islets collapse into scatteredIslets; the fragment must not.
    picture = [
        "gggg........",
        "gggg...g....",
        "..........g?",
        "g...........",
    ]
    dump = make_dump(picture, capital={"x": 0, "y": 0},
                     cities=[city(0, 0, "Home", capital=True)])
    dump["naturalWonders"] = [{"name": "Krakatoa", "x": 7, "y": 1}]
    m = geo.MapData(dump)
    anchor = geo.resolve_anchor(m)
    result = geo.overview(m, anchor)
    assert result["landmassCount"] == 4
    kept = result["landmasses"]
    assert len(kept) == 2
    assert kept[0]["yourHomeLandmass"] is True
    assert kept[1]["tiles"] == 1 and kept[1]["surveyedCompletely"] is False, (
        "a small fragment open to fog must stay a full landmass entry"
    )
    islets = result["scatteredIslets"]
    assert islets["count"] == 2 and islets["totalTiles"] == 2
    assert len(islets["notable"]) == 1
    assert islets["notable"][0]["naturalWonders"] == ["Krakatoa"]
    assert "id" in islets["notable"][0]


def test_player_coords_match_ingame_speech():
    # Mirrors hexgeom_test.lua's coordinateString cases: same origin, same
    # spoken numbers.
    origin = {"x": 0, "y": 0, "mapWidth": 80, "mapHeight": 40, "wrapX": False}
    assert geo.player_coords(origin, 0, 0) == (0, 0)
    assert geo.player_coords(origin, 1, 0) == (1, 0)
    # NE step lands on the odd (half-shifted) row: x gains the 0.5 parity
    # correction, exactly the "0.5, 1" the player hears.
    assert geo.player_coords(origin, 0, 1) == (0.5, 1)
    odd = {"x": 3, "y": 1, "mapWidth": 80, "mapHeight": 40, "wrapX": False}
    assert geo.player_coords(odd, 3, 0) == (-0.5, -1)
    wrap = {"x": 10, "y": 0, "mapWidth": 80, "mapHeight": 40, "wrapX": True}
    assert geo.player_coords(wrap, 78, 0) == (-12, 0)
    assert geo.player_coords(wrap, 40, 0) == (30, 0)


def test_engine_coords_inverts_player_coords():
    for origin in (
        {"x": 10, "y": 4, "mapWidth": 80, "mapHeight": 40, "wrapX": True},
        {"x": 3, "y": 1, "mapWidth": 80, "mapHeight": 40, "wrapX": False},
    ):
        for x in (0, 1, 39, 78):
            for y in (0, 1, 4, 39):
                px, py = geo.player_coords(origin, x, y)
                assert geo.engine_coords(origin, px, py) == (x, y), (
                    f"round trip failed at ({x}, {y}) via ({px}, {py})"
                )


def test_engine_coords_rejects_wrong_parity_and_off_map():
    origin = {"x": 10, "y": 4, "mapWidth": 80, "mapHeight": 40, "wrapX": False}
    # Row 5 differs in parity from the capital's row 4, so x must end in .5.
    try:
        geo.engine_coords(origin, 3, 1)
        raise AssertionError("wrong-parity x must raise")
    except geo.PlaceError as e:
        assert "end in .5" in str(e) and "2.5" in str(e) and "3.5" in str(e)
    try:
        geo.engine_coords(origin, 0, 100)
        raise AssertionError("off-map y must raise")
    except geo.PlaceError as e:
        assert "off the map" in str(e)
    try:
        geo.engine_coords(origin, 0, 0.5)
        raise AssertionError("fractional y must raise")
    except geo.PlaceError as e:
        assert "whole row" in str(e)


def test_convert_payload_rewrites_all_xy_pairs():
    origin = {"x": 10, "y": 4, "mapWidth": 80, "mapHeight": 40, "wrapX": False}
    payload = {
        "ok": True,
        "data": {
            "center": {"x": 12, "y": 4, "name": "spot"},
            "tiles": [{"x": 10, "y": 5, "terrain": "Grassland"}],
            "count": 3,
        },
    }
    out = geo.convert_payload(payload, origin)
    assert out["data"]["center"] == {"x": 2, "y": 0, "name": "spot"}
    assert out["data"]["tiles"][0]["x"] == 0.5
    assert out["data"]["tiles"][0]["y"] == 1
    assert out["data"]["tiles"][0]["terrain"] == "Grassland"
    assert out["data"]["count"] == 3
    # The original must be untouched (deep copy).
    assert payload["data"]["center"]["x"] == 12
    # No origin: identity.
    assert geo.convert_payload(payload, None) is payload


def test_resolve_place_parses_player_coordinates():
    picture = [
        "gggggg",
        "gggggg",
        "gggggg",
        "gggggg",
    ]
    dump = make_dump(picture, capital={"x": 2, "y": 2},
                     cities=[city(2, 2, "Home", capital=True)])
    origin = {"x": 2, "y": 2, "mapWidth": 6, "mapHeight": 4, "wrapX": False}
    m = geo.MapData(dump, origin)
    # One NE step from the capital: the player says "0.5, 1".
    x, y, label = geo.resolve_place(m, "0.5, 1")
    assert (x, y) == (2, 3), (x, y)
    assert label == "(0.5, 1)"
    # Without an origin the same string is raw grid; halves are invalid.
    m_raw = geo.MapData(dump)
    assert geo.resolve_place(m_raw, "2, 3")[:2] == (2, 3)
    try:
        geo.resolve_place(m_raw, "0.5, 1")
        raise AssertionError("half coordinate without an origin must raise")
    except geo.PlaceError:
        pass


TESTS = [v for k, v in sorted(globals().items()) if k.startswith("test_")]


def main():
    for t in TESTS:
        t()
        print(f"{t.__name__} ok")
    print(f"GEOMETRY PASS ({len(TESTS)} tests)")


if __name__ == "__main__":
    main()
