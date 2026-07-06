"""Offline tests for civ5_render.py against synthetic dumps.

Run: py tools/mcp/test_render.py
Requires Pillow (like the renderer itself). Visual quality is checked by
eye during development; these tests pin the contract: valid PNG out,
honest view bounds, stable color assignment, wrap and clamp behavior.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import civ5_geometry as geo  # noqa: E402
import civ5_render as render  # noqa: E402
from test_geometry import make_dump, city, major, minor  # noqa: E402

PNG_MAGIC = b"\x89PNG\r\n\x1a\n"


def _demo_dump(wrap_x=False):
    picture = [
        "cccccccccccc",
        "cgghmgggggcc",
        "cggggggghgcc",
        "cgpppgggggcc",
        "cccccc?????c",
    ]
    owners = [
        "------------",
        "-0011-------",
        "-0011-------",
        "-00112------",
        "------?????-",
    ]
    players = [
        major(0, "Testia", you=True),
        major(1, "Rivalia"),
        minor(2, "Georgetown"),
    ]
    cities = [
        city(2, 1, "Home", owner=0, capital=True),
        city(4, 2, "Rivalton", owner=1, capital=True),
        city(5, 3, "Georgetown", owner=2, capital=True),
    ]
    dump = make_dump(
        picture, owners=owners, players=players, cities=cities,
        capital={"x": 2, "y": 1}, cursor={"x": 7, "y": 2},
        rivers={(3, 2), (4, 2)}, wrap_x=wrap_x,
        resources=[{"x": 6, "y": 1, "t": "RESOURCE_IRON"}],
        fogged={(8, 2)},
    )
    dump["naturalWonders"] = [{"name": "Old Faithful", "x": 8, "y": 3}]
    return dump


def test_full_map_render():
    m = geo.MapData(_demo_dump())
    png, meta = render.render_png(m)
    assert png[:8] == PNG_MAGIC
    assert meta["view"]["wholeMap"] is True
    assert meta["view"]["xFrom"] == 0 and meta["view"]["xTo"] == 11
    assert meta["view"]["yFrom"] == 0 and meta["view"]["yTo"] == 4
    assert meta["view"]["crossesWrapSeam"] is False
    assert meta["civColors"]["Testia"] == "#ffffff", "you render white"
    assert len(set(meta["civColors"].values())) == 3, "colors distinct"
    assert "hexSizePx" in meta and "reading" in meta


def test_zoom_clamps_at_map_edge():
    m = geo.MapData(_demo_dump())
    png, meta = render.render_png(m, center=(1, 1), radius=4)
    assert png[:8] == PNG_MAGIC
    v = meta["view"]
    assert v["wholeMap"] is False
    assert v["xFrom"] == 0 and v["yFrom"] == 0, "clamped, no negative tiles"
    assert v["xTo"] == 5 and v["yTo"] == 4


def test_zoom_across_wrap_seam():
    m = geo.MapData(_demo_dump(wrap_x=True))
    png, meta = render.render_png(m, center=(0, 2), radius=3)
    assert png[:8] == PNG_MAGIC
    v = meta["view"]
    assert v["crossesWrapSeam"] is True
    assert v["xFrom"] == 9 and v["xTo"] == 3, "window folds across the seam"

    # A radius so large the window covers the wrapped width collapses to
    # the full width instead of duplicating columns.
    _, meta2 = render.render_png(m, center=(0, 2), radius=30)
    assert meta2["view"]["xFrom"] == 0 and meta2["view"]["xTo"] == 11
    assert meta2["view"]["crossesWrapSeam"] is False


TESTS = [v for k, v in sorted(globals().items()) if k.startswith("test_")]


def main():
    for t in TESTS:
        t()
        print(f"{t.__name__} ok")
    print(f"RENDER PASS ({len(TESTS)} tests)")


if __name__ == "__main__":
    main()
