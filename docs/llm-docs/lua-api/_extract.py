"""Extract Civ V Lua API from shipped game source.

Scans all .lua files under the game's Assets folder, strips comments and string
literals, then collects method calls whose receiver can be confidently binned
by name to a known class. Writes one markdown file per class plus an index.
"""
from __future__ import annotations

import os
import re
import sys
from collections import defaultdict
from pathlib import Path

GAME_ROOT = Path(r"C:\Program Files (x86)\Steam\steamapps\common\Sid Meier's Civilization V\Assets")
OUT_DIR = Path(r"C:\Users\rasha\Documents\Civ-V-Mod\docs\llm-docs\lua-api")

# Receiver name -> class
# Colon receivers (method calls on handles).
COLON_RECEIVERS = {
    # Hungarian prefixes
    "pPlayer": "Player", "pUnit": "Unit", "pCity": "City", "pPlot": "Plot",
    "pTeam": "Team", "pArea": "Area", "pReligion": "Religion", "pDeal": "Deal",
    "pLeague": "League",
    # Unprefixed but conventional
    "player": "Player", "unit": "Unit", "city": "City", "plot": "Plot",
    "team": "Team", "area": "Area", "religion": "Religion", "deal": "Deal",
    "league": "League",
    # Other common handle names
    "otherPlayer": "Player", "activePlayer": "Player", "targetPlayer": "Player",
    "fromPlayer": "Player", "toPlayer": "Player", "owner": "Player",
    "pActivePlayer": "Player", "pOtherPlayer": "Player",
    "pTargetPlayer": "Player", "pFromPlayer": "Player", "pToPlayer": "Player",
    "pOwner": "Player", "pLoopPlayer": "Player", "pMinor": "Player",
    "pAIPlayer": "Player", "pMyPlayer": "Player", "g_pPlayer": "Player",
    "g_pUs": "Player", "g_pThem": "Player", "pGiftedPlayer": "Player",
    "pVoteCastPlayer": "Player", "pThirdPartyPlayer": "Player",
    "pOriginalOwner": "Player", "loopPlayer": "Player", "minorPlayer": "Player",
    "humanPlayer": "Player", "pHuman": "Player", "pHumanPlayer": "Player",
    "pPlayer1": "Player", "pPlayer2": "Player",
    "otherUnit": "Unit", "pOtherUnit": "Unit", "targetUnit": "Unit",
    "pMyUnit": "Unit", "pTheirUnit": "Unit", "theirUnit": "Unit", "myUnit": "Unit",
    "pHeadSelectedUnit": "Unit", "pSelectedUnit": "Unit", "pPlotUnit": "Unit",
    "pLoopUnit": "Unit", "loopUnit": "Unit", "selectedUnit": "Unit",
    "otherCity": "City", "pOtherCity": "City", "capitalCity": "City", "pCapital": "City",
    "capital": "City", "pHeadSelectedCity": "City", "pSelectedCity": "City",
    "pLoopCity": "City", "loopCity": "City", "pCity2": "City", "pCity1": "City",
    "pTargetCity": "City", "targetCity": "City",
    "adjacentPlot": "Plot", "pAdjacentPlot": "Plot",
    "riverPlot": "Plot", "adjPlot": "Plot", "startPlot": "Plot",
    "playerStartPlot": "Plot", "searchPlot": "Plot", "res_plot": "Plot",
    "pTargetPlot": "Plot", "pToPlot": "Plot", "pFromPlot": "Plot",
    "otherPlot": "Plot", "targetPlot": "Plot", "forcePlot": "Plot",
    "currentPlot": "Plot", "pCurrentPlot": "Plot", "pStartPlot": "Plot",
    "pSelectedPlot": "Plot", "selectedPlot": "Plot", "pLoopPlot": "Plot",
    "loopPlot": "Plot", "thisPlot": "Plot", "pThisPlot": "Plot",
    "otherTeam": "Team", "pOtherTeam": "Team",
    "g_pTeam": "Team", "g_pUsTeam": "Team", "g_pThemTeam": "Team",
    "activeTeam": "Team", "pActiveTeam": "Team", "pLoopTeam": "Team",
    "myTeam": "Team", "pMyTeam": "Team",
    "g_Deal": "Deal",
    "ContextPtr": "ContextPtr",
    "InstanceManager": "InstanceManager",
}

# Dot receivers (static tables). Access is `Table.Func(...)`.
DOT_RECEIVERS = {
    "Game": "Game", "Map": "Map", "UI": "UI", "Locale": "Locale",
    "UIManager": "UIManager", "ContentManager": "ContentManager",
    "Modding": "Modding", "OptionsManager": "OptionsManager",
    "PreGame": "PreGame", "Network": "Network", "Steam": "Steam",
    "Mouse": "Mouse", "Matchmaking": "Matchmaking",
}

# Indirect colon patterns: `Players[...]:Foo(...)` etc.
INDEXED_COLON_RECEIVERS = {
    "Players": "Player", "Teams": "Team",
}

# ---------- stripping comments and strings ----------

def strip_lua(src: str) -> str:
    """Replace Lua comments and string literals with blanks of equal length,
    preserving line numbers. Handles long brackets `[[...]]` / `[=[...]=]`.
    """
    out = []
    i = 0
    n = len(src)
    while i < n:
        c = src[i]
        c2 = src[i:i+2]
        # long comment --[=*[ ... ]=*]
        if c2 == "--":
            # check long bracket opening
            j = i + 2
            if j < n and src[j] == "[":
                # count equals
                k = j + 1
                eq = 0
                while k < n and src[k] == "=":
                    eq += 1
                    k += 1
                if k < n and src[k] == "[":
                    # long comment
                    close = "]" + ("=" * eq) + "]"
                    end = src.find(close, k + 1)
                    if end == -1:
                        end = n
                    else:
                        end += len(close)
                    # blank out preserving newlines
                    for ch in src[i:end]:
                        out.append("\n" if ch == "\n" else " ")
                    i = end
                    continue
            # short comment: to end of line
            end = src.find("\n", i)
            if end == -1:
                end = n
            for ch in src[i:end]:
                out.append(" ")
            i = end
            continue
        # long string [=*[ ... ]=*]
        if c == "[":
            k = i + 1
            eq = 0
            while k < n and src[k] == "=":
                eq += 1
                k += 1
            if k < n and src[k] == "[":
                close = "]" + ("=" * eq) + "]"
                end = src.find(close, k + 1)
                if end == -1:
                    end = n
                else:
                    end += len(close)
                for ch in src[i:end]:
                    out.append("\n" if ch == "\n" else " ")
                i = end
                continue
        # short string: preserve content but sanitize so that parens/commas/quotes
        # inside the string can't break our paren-balancing arg extractor. Wrap in
        # double quotes so the result still parses as a Lua string literal in the
        # extracted argument text. Multi-line short strings aren't valid Lua, so
        # this stays single-line.
        if c == '"' or c == "'":
            quote = c
            out.append('"')
            i += 1
            while i < n:
                ch = src[i]
                if ch == "\\" and i + 1 < n:
                    nxt = src[i+1]
                    if nxt == "\n":
                        # escaped newline inside string: preserve newline, drop esc
                        out.append("_")
                        out.append("\n")
                    elif nxt in 'nrt':
                        out.append("_")
                        out.append("_")
                    elif nxt == quote or nxt == "\\":
                        out.append("_")
                        out.append("_")
                    else:
                        out.append("_")
                        out.append("_")
                    i += 2
                    continue
                if ch == quote:
                    out.append('"')
                    i += 1
                    break
                if ch == "\n":
                    out.append("\n")
                elif ch.isalnum() or ch in "_./:-":
                    out.append(ch)
                else:
                    out.append("_")
                i += 1
            continue
        out.append(c)
        i += 1
    return "".join(out)

# ---------- method call extraction ----------

# Match `Receiver:Method(` or `Receiver.Method(` where Receiver is a bare identifier
# or an indexed form `Ident[...]`. We also allow trailing `)` for Players[i]:Foo etc.
# Two separate patterns, then we parse args by tracking parens / brackets / braces.

IDENT = r"[A-Za-z_][A-Za-z0-9_]*"
# Simple receiver at start: identifier OR identifier[...] (non-nested brackets OK for our purposes;
# but we allow nested by balanced matching below).
CALL_RE = re.compile(
    r"(?:(?<![A-Za-z0-9_\)\]\.:])"                # not preceded by name/call/index/member
    r"(" + IDENT + r")"                            # 1: bare ident receiver
    r"(?:\[([^\[\]]*)\])?"                          # 2: optional [index]
    r")"
    r"([\.:])"                                      # 3: . or :
    r"(" + IDENT + r")"                             # 4: method name
    r"\("                                            # open paren
)

# `Controls.<Name>:<Method>(` — direct Controls method calls.
CONTROLS_RE = re.compile(
    r"(?<![A-Za-z0-9_])Controls\.(" + IDENT + r"):(" + IDENT + r")\("
)

# Method names that always indicate InstanceManager regardless of receiver.
INSTANCE_MANAGER_METHODS = {"new", "GetInstance", "ResetInstances", "ReleaseInstance"}

def extract_args(src: str, open_paren_idx: int) -> str | None:
    """Given index of '(' in stripped source, return the argument text (without
    outer parens), collapsing whitespace. Returns None if unbalanced.
    """
    depth = 0
    i = open_paren_idx
    n = len(src)
    start = i + 1
    while i < n:
        c = src[i]
        if c == "(":
            depth += 1
        elif c == ")":
            depth -= 1
            if depth == 0:
                raw = src[start:i]
                # collapse whitespace
                return re.sub(r"\s+", " ", raw).strip()
        i += 1
    return None

def line_of(src: str, idx: int) -> int:
    return src.count("\n", 0, idx) + 1

# ---------- main scan ----------

def iter_lua_files(root: Path):
    for p in root.rglob("*.lua"):
        if p.is_file():
            yield p

# Per-class: method name -> {signature_str: [callsites]}
class_data: dict[str, dict[str, dict[str, list[str]]]] = defaultdict(lambda: defaultdict(lambda: defaultdict(list)))
# Total callsites per class/method
method_counts: dict[str, dict[str, int]] = defaultdict(lambda: defaultdict(int))
# Unbinned: method name -> count, sample callsite
unbinned_counts: dict[str, int] = defaultdict(int)
unbinned_sample: dict[str, str] = {}
# Track unbinned receiver names (first occurrence sample) so we can learn about missed classes.
unbinned_receivers: dict[str, int] = defaultdict(int)
# Per-unbinned-method, full call shapes for post-pass reassignment to Controls / InstanceManager.
# method -> {sig: [callsites]}
unbinned_calls: dict[str, dict[str, list[str]]] = defaultdict(lambda: defaultdict(list))
# Method names ever observed on a `Controls.<X>:` call. Populated during scan; used in post-pass
# to reassign other receivers' calls of the same methods (e.g. `button:SetText(...)`,
# `iconControl:SetTexture(...)`) into the Controls bin, since Control userdata methods are
# the same across all receivers.
controls_methods: set[str] = set()

total_files = 0
total_calls = 0

def rel_path(p: Path) -> str:
    try:
        return str(p.relative_to(GAME_ROOT)).replace("\\", "/")
    except ValueError:
        return str(p).replace("\\", "/")

def process_file(path: Path):
    global total_calls
    try:
        src = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return
    stripped = strip_lua(src)
    rp = rel_path(path)
    # First: pick up `Controls.<X>:<Method>(` direct calls.
    for m in CONTROLS_RE.finditer(stripped):
        ctrl_name = m.group(1)
        method = m.group(2)
        paren_idx = m.end() - 1
        args = extract_args(stripped, paren_idx)
        if args is None:
            continue
        ln = line_of(stripped, m.start())
        callsite = f"{rp}:{ln}"
        sig = f"Controls.{ctrl_name}:{method}({args})"
        class_data["Controls"][method][sig].append(callsite)
        method_counts["Controls"][method] += 1
        controls_methods.add(method)
    for m in CALL_RE.finditer(stripped):
        recv = m.group(1)
        index_expr = m.group(2)
        sep = m.group(3)
        method = m.group(4)
        paren_idx = m.end() - 1  # position of '('
        args = extract_args(stripped, paren_idx)
        if args is None:
            continue
        global_count_key = None
        ln = line_of(stripped, m.start())
        callsite = f"{rp}:{ln}"
        total_calls_local = 1

        # Classify
        cls = None
        recv_display = recv
        if sep == ":":
            # colon call
            if index_expr is not None:
                # indexed receiver
                if recv in INDEXED_COLON_RECEIVERS:
                    cls = INDEXED_COLON_RECEIVERS[recv]
                    recv_display = f"{recv}[{index_expr.strip() or 'i'}]"
            else:
                if recv in COLON_RECEIVERS:
                    cls = COLON_RECEIVERS[recv]
                    recv_display = recv
                elif recv in DOT_RECEIVERS:
                    # Static table called with colon syntax (common for Game: / Map: / UIManager:)
                    cls = DOT_RECEIVERS[recv]
                    recv_display = recv
        else:
            # dot call
            if index_expr is None and recv in DOT_RECEIVERS:
                cls = DOT_RECEIVERS[recv]
                recv_display = recv

        global total_calls
        total_calls += 1
        if cls is None:
            # Only count colon calls as unbinned (dot calls on unknown tables are noise).
            if sep == ":":
                key = method
                unbinned_counts[key] += 1
                unbinned_receivers[recv] += 1
                recv_for_sig = f"{recv}[{index_expr}]" if index_expr else recv
                full_sig = f"{recv_for_sig}:{method}({args})"
                unbinned_calls[key][full_sig].append(callsite)
                if key not in unbinned_sample:
                    unbinned_sample[key] = f"{recv_for_sig}:{method}({args[:60]}) @ {callsite}"
        else:
            sig = f"{recv_display}{sep}{method}({args})"
            class_data[cls][method][sig].append(callsite)
            method_counts[cls][method] += 1

def main():
    global total_files
    if not GAME_ROOT.exists():
        print(f"Game root not found: {GAME_ROOT}", file=sys.stderr)
        sys.exit(1)
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    for lua in iter_lua_files(GAME_ROOT):
        total_files += 1
        process_file(lua)

    # Post-pass: reassign unbinned methods to Controls / InstanceManager based on
    # method-name fingerprints. Controls method set was learned from `Controls.<X>:`
    # calls during scan; InstanceManager has a small fixed method set.
    reassigned_to_controls = 0
    reassigned_to_im = 0
    methods_to_drop: list[str] = []
    for method, sigs in unbinned_calls.items():
        target_cls = None
        if method in INSTANCE_MANAGER_METHODS:
            target_cls = "InstanceManager"
        elif method in controls_methods:
            target_cls = "Controls"
        if target_cls is None:
            continue
        for sig, sites in sigs.items():
            class_data[target_cls][method][sig].extend(sites)
            method_counts[target_cls][method] += len(sites)
            if target_cls == "Controls":
                reassigned_to_controls += len(sites)
            else:
                reassigned_to_im += len(sites)
        methods_to_drop.append(method)
    for method in methods_to_drop:
        # Remove from unbinned reports so they don't double-show.
        unbinned_calls.pop(method, None)
        unbinned_counts.pop(method, None)
        unbinned_sample.pop(method, None)

    print(f"Reassigned {reassigned_to_controls} unbinned calls to Controls, {reassigned_to_im} to InstanceManager.")

    # Write per-class files
    class_summaries = []
    for cls in sorted(class_data):
        methods = class_data[cls]
        total_cs = sum(method_counts[cls].values())
        class_summaries.append((cls, len(methods), total_cs))
        lines = [f"# {cls}", ""]
        lines.append(_class_blurb(cls))
        lines.append("")
        lines.append(f"Extracted from {total_cs} call sites across {len(methods)} distinct methods in the shipped game Lua.")
        lines.append("")
        lines.append("## Methods")
        lines.append("")
        for method in sorted(methods, key=str.lower):
            sigs = methods[method]
            count = method_counts[cls][method]
            lines.append(f"### {method}")
            # Pick representative example: first signature's first callsite.
            # If multiple distinct sigs, list up to 5.
            sig_items = sorted(sigs.items(), key=lambda kv: -len(kv[1]))
            shown = sig_items[:5]
            for sig, sites in shown:
                lines.append(f"- `{sig}`")
            if len(sig_items) > 5:
                lines.append(f"- ...and {len(sig_items) - 5} more distinct call shapes")
            example = shown[0][1][0]
            lines.append(f"- {count} callsite{'s' if count != 1 else ''}. Example: `{example}`")
            lines.append("")
        out_path = OUT_DIR / f"{cls}.md"
        out_path.write_text("\n".join(lines), encoding="utf-8")

    # Index
    idx = ["# Civ V Lua API reference (extracted from game source)", ""]
    idx.append("Generated by scanning every `.lua` file under the game's `Assets/` tree, stripping comments and string literals, then binning every method call by receiver name. Signatures below are the literal argument expressions the game's own code passes at real call sites -- they are not from any official spec, so argument names reflect what the game's authors chose (usually descriptive, occasionally just `x` or `_`).")
    idx.append("")
    idx.append("When a method appears with multiple distinct argument shapes, all shapes are listed (real overloads or variadic / optional-argument usage).")
    idx.append("")
    idx.append(f"Source: `{GAME_ROOT}` ({total_files} Lua files, {total_calls} classified method calls).")
    idx.append("")
    idx.append("## Classes")
    idx.append("")
    for cls, nm, cs in class_summaries:
        idx.append(f"- [{cls}]({cls}.md) - {nm} methods, {cs} callsites")
    idx.append("")
    idx.append("## Unbinned calls")
    idx.append("")
    idx.append("See [_unbinned.md](_unbinned.md) for the top 100 most-common `:Method(` calls whose receiver variable name did not match any known class. Useful for spotting classes we missed.")
    (OUT_DIR / "README.md").write_text("\n".join(idx), encoding="utf-8")

    # Unbinned report
    top = sorted(unbinned_counts.items(), key=lambda kv: -kv[1])[:100]
    u = ["# Unbinned method calls", ""]
    u.append("Top 100 `:Method(` calls in the shipped game Lua whose receiver name did not match a known class. If a method here is very common, consider adding its typical receiver name to the extractor's receiver map and re-running.")
    u.append("")
    u.append("Format: `count  method   sample`")
    u.append("")
    for meth, cnt in top:
        sample = unbinned_sample.get(meth, "")
        u.append(f"- {cnt}  `:{meth}`  -- {sample}")
    u.append("")
    u.append("## Top unbinned receiver names")
    u.append("")
    top_recv = sorted(unbinned_receivers.items(), key=lambda kv: -kv[1])[:50]
    for r, c in top_recv:
        u.append(f"- {c}  `{r}`")
    (OUT_DIR / "_unbinned.md").write_text("\n".join(u), encoding="utf-8")

    # Console summary
    print(f"Files scanned: {total_files}")
    print(f"Classified calls: {total_calls - sum(unbinned_counts.values())}")
    print(f"Unbinned calls: {sum(unbinned_counts.values())}")
    print(f"Classes: {len(class_data)}")
    print(f"Total distinct methods: {sum(len(m) for m in class_data.values())}")
    for cls, nm, cs in class_summaries:
        print(f"  {cls}: {nm} methods, {cs} callsites")

BLURBS = {
    "Player": "Methods on Player handles. Obtain via `Players[playerID]` or `Game.GetActivePlayer()` (returns player ID, then index `Players[...]`).",
    "Unit": "Methods on Unit handles. Obtain via `pPlayer:GetUnitByID(unitID)` or iteration with `pPlayer:Units()`.",
    "City": "Methods on City handles. Obtain via `pPlayer:GetCityByID(cityID)`, `pPlot:GetPlotCity()`, or iteration with `pPlayer:Cities()`.",
    "Plot": "Methods on Plot handles. Obtain via `Map.GetPlot(x, y)`, `Map.GetPlotByIndex(i)`, or `pUnit:GetPlot()` / `pCity:Plot()`.",
    "Team": "Methods on Team handles. Obtain via `Teams[teamID]` or `pPlayer:GetTeam()` (returns team ID).",
    "Area": "Methods on Area handles (landmasses / continents). Obtain via `pPlot:Area()` or `pCity:Area()`.",
    "Religion": "Methods on Religion handles. G&K / BNW only.",
    "Deal": "Methods on Deal handles (diplomacy trade deals).",
    "League": "Methods on League handles (World Congress / United Nations). BNW only.",
    "ContextPtr": "The per-context pointer exposed in every UI Lua file. Provides lifecycle hooks (`SetShowHandler`, `SetHideHandler`, `SetUpdate`, `SetInputHandler`) and control lookup (`LookUpControl`).",
    "Game": "Global game state. Static table; call with dot syntax: `Game.GetActivePlayer()`.",
    "Map": "World / map queries. Static table.",
    "UI": "UI / presentation layer helpers. Static table.",
    "Locale": "Localization / text-key resolution. Static table.",
    "UIManager": "Screen stack and input routing. Static table.",
    "ContentManager": "DLC and content activation queries. Static table.",
    "Modding": "Mod activation and query. Static table.",
    "OptionsManager": "User options / config.ini-backed settings. Static table.",
    "PreGame": "Pre-game / setup-screen state (picked civ, map settings, players). Static table.",
    "Network": "Multiplayer networking. Static table.",
    "Steam": "Steam platform integration. Static table.",
    "Mouse": "Mouse input constants / state. Static table.",
    "Matchmaking": "Multiplayer lobby / matchmaking. Static table.",
    "Controls": "Methods on Control userdata (the engine UI widgets exposed to Lua via the `Controls` table or `instance.<X>` from InstanceManager). Receivers vary widely (`Controls.Foo`, `button`, `iconControl`, `instance.SubButton`, etc.) but call the same underlying engine API. Method set was learned from every `Controls.<X>:<Method>` call in the shipped game; calls on other receiver names with the same method names were folded in.",
    "InstanceManager": "The mod-side UI templating helper defined in `Assets/UI/InstanceManager.lua` (~150 lines, worth reading directly). Methods: `:new(instanceName, rootControlName, parentControl)` constructor, `:GetInstance()` to obtain or recycle a pooled instance, `:ResetInstances()` to free all, `:ReleaseInstance(inst)` to free one. Heavy use across the codebase for list-style UI (city list, civ list, tech tree entries, etc.).",
}

def _class_blurb(cls: str) -> str:
    return BLURBS.get(cls, "")

if __name__ == "__main__":
    main()
