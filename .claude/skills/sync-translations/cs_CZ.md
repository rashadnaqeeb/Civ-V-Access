# Czech (cs_CZ) translation conventions

Hand this file to any agent that writes or edits a `_cs_CZ.lua` strings file. Czech is the one locale whose game text is not on disk as a `<LOCALE>` folder, so the conventions and the vocabulary lock live here instead of being rederived from the game's XML each time.

## Where Czech comes from

Civ V ships no Czech. Czech players run the civ5_allinone_cz fan translation (Jetro's team, from hernipreklady.cz). It registers no language: it overwrites the game's `en_US` text files in place, so the engine still reports `en_US` while every base-game string is Czech. `CivVAccess_StringsLoader.lua` detects that by probing one base-game key and then loads the `cs_CZ` overlay; `CivVAccess_PluralRules.lua` follows the loader.

The patch may not be modified or redistributed, so its text is never committed. To look up how the Czech game words something, read the `en_US` text folders of an install that has the patch applied, or extract the patch's XML into a scratch folder. `tools/icon_dedup_aliases.py --dump TXT_KEY_X` on a patched install prints the Czech text under the `en_US` label.

Where a concept is not in the vocabulary lock below, look it up in the Czech game text and use the game's word. Do not invent a parallel term.

## Language rules

1. Diacritics are mandatory: á č ď é ě í ň ó ř š ť ú ů ý ž. Never strip them.
2. ASCII punctuation only. This is a separate rule from rule 1 and applies only to punctuation marks: plain apostrophe, hyphen, period, comma, colon, parentheses, percent, slash. No Czech typographic quotes, no curly quotes, no en or em dash, no ellipsis character, no non-breaking spaces. Where Czech would use typographic quotes, use plain apostrophes or reword.
3. Register: the Czech game addresses the player informally in the singular (ty): "můžeš", "vyber", "čekej, prosím". Never formal vy.
4. Buttons, menu items, action names and help-entry descriptions use the infinitive, as the Czech game's buttons do: "Uložit hru", "Zrušit", "Přesunout jednotku". Toggle labels that describe ongoing behaviour use the imperfective: "Oznamovat", "Přehrávat".
5. Do not reveal or assume the player's gender. Avoid second-person past tense and predicate adjectives about the player ("vybral jsi", "jsi připraven"). Use impersonal or passive wording: "Vybráno.", "Nelze ...", "Hotovo.".
6. Match the source's shape key by key: a lowercase fragment with no final period stays one; a full sentence keeps its capital and period; leading and trailing spaces are kept exactly.
7. Capitalisation follows the source. A value whose source starts with a capital starts with a capital in Czech too, including key labels ("Šipka nahoru nebo dolů", "Mezerník").
8. Lead with the distinguishing word where Czech grammar allows.
9. The mod speaks; it never shows. Do not introduce visual verbs. "Announce", "speak", "read" are "oznámit", "přečíst". "Preview" as a verb is "zjistit", as a noun "náhled". Use "zobrazit" or "ukázat" only where the source itself says show or display.
10. No abbreviations a speech synthesiser mangles ("např.", "tj.", "apod.", "č."). Write the words out.
11. The same English word maps to the same Czech word everywhere.

## Placeholders

A placeholder is replaced at run time by a ready-made Czech string in its dictionary form (nominative, fixed gender). Nothing around it may require a case or gender. Good shapes: `{1_Name}: ...`, `..., {1_Name}`, `label: {1_Value}`. Avoid a preposition directly before a name placeholder and avoid past-tense verbs whose ending depends on the placeholder's gender; use a noun or an impersonal form ("zničeno: {1_Unit}"). Where no neutral wording exists, prefer wording slightly awkward for some values over wording wrong for most.

## Numbers and plurals

- 1 tah, 2 to 4 tahy, 5 and more (and 0) tahů.
- A plural bundle has exactly three forms: `one` (1), `few` (2, 3, 4), `other` (0 and 5 up, genitive plural). No `many`.
- A plain string with a number next to a noun stays a plain string: use the "noun: number" shape ("tahy: {1_Num}") or the genitive plural.

## Gender of status words

Short lowercase status words appended to an announcement must agree with what they describe.

- unit: jednotka, feminine ("naloděná", "opevněná", "nečinná")
- city: město, neuter ("okupované", "loutkové")
- tile: políčko, neuter
- building: budova, feminine. wonder: div, masculine. technology: technologie, feminine. social policy: politika, feminine. policy branch: větev, feminine. tenet: princip, masculine. resource: surovina, feminine. improvement: vylepšení, neuter. great work: dílo, neuter. promotion: povýšení, neuter. slot: pozice, feminine. city-state: městský stát, masculine. religion: náboženství, neuter. notification: hlášení, neuter. squad: oddíl, masculine. player, leader, spy: masculine. civilization: civilizace, feminine.
- when the described thing varies, is a UI control, or cannot be told: the neuter impersonal -o form ("vybráno", "uzamčeno", "zablokováno", "zapnuto", "vypnuto") or a form that does not change with gender ("neaktivní", "ve frontě", "k dispozici", "bez vlastníka").

## Keyboard keys

- Unchanged: Enter, Escape, Tab, Shift, Control, Alt, Home, End, Page Up, Page Down, Backspace, Delete, Insert, F1 to F12, letters and digits.
- Space: "mezerník". Arrows: "šipka nahoru", "šipka dolů", "šipka vlevo", "šipka vpravo"; "up or down": "šipka nahoru nebo dolů"; "arrow keys": "šipky".
- "plus" between keys stays "plus". "or" is "nebo".

## Compass directions

- Long: sever, severovýchod, východ, jihovýchod, jih, jihozápad, západ, severozápad.
- Short tokens: sev, sv, vých, jv, jih, jz, záp, sz. Never the single letters s, v, z: they are Czech prepositions and a speech synthesiser misreads them.

## Vocabulary lock

These are the Czech game's own terms. Use them, inflected as the sentence requires.

Core game terms:
- turn: tah. era: éra. score: skóre. victory: vítězství. difficulty: obtížnost. map: mapa
- tile, hex, plot: políčko. territory: území. borders: hranice. fog of war: mlha války
- unit: jednotka. city: město. capital: hlavní město. city-state: městský stát. civilization: civilizace. leader: vůdce. player: hráč. team: tým. barbarians: barbaři. barbarian camp, encampment: barbarské ležení. ancient ruins, goody hut: starodávné ruiny
- gold: zlato. food: jídlo. production: výroba. culture: kultura. science: věda. faith: víra. tourism: turismus. influence: vliv. happiness: spokojenost. unhappiness: nespokojenost. happy, unhappy (citizens): spokojení, nespokojení. golden age: zlatý věk. per turn: za tah
- population: počet obyvatel. citizen: obyvatel (also a "worker" on a city tile; dělník is only the Worker unit). unemployed citizen: nezaměstnaný obyvatel. specialist: specialista. citizen management: správa obyvatel. city focus: zaměření. worked tile: obdělávané políčko
- building: budova. wonder: div. world wonder: div světa. natural wonder: přírodní div. project: projekt. unique (unit, building, improvement): unikátní
- resource: surovina (strategická, luxusní, bonusová). improvement: vylepšení. road: cesta. railroad: železnice. trade route: obchodní cesta. caravan: karavana. cargo ship: nákladní loď
- river: řeka. hills: kopce. mountain: hora. coast: pobřeží. ocean: oceán. lake: jezero
- technology: technologie. research: výzkum. tech tree: technologický strom
- social policy: sociální politika. ideology: ideologie. tenet: princip. adopt, enact: přijmout. repeal: zrušit. public opinion: veřejné mínění
- great person: výjimečná osobnost. great people: výjimeční lidé. great work: výjimečné dílo. great general, admiral, prophet, artist, writer, musician: výjimečný generál, admirál, prorok, umělec, spisovatel, hudebník. theming bonus: tematický bonus
- religion: náboženství. pantheon: pantheon. belief: přesvědčení. follower: stoupenec. holy city: svaté město. missionary: misionář. inquisitor: inkvizitor
- spy: špeh. World Congress: Světový kongres. resolution: rezoluce. delegate: delegát. votes: hlasy. host: hostitel
- diplomacy: diplomacie. war: válka. peace: mír. declare war: vyhlásit válku. ally: spojenec. friend: přítel. neutral: neutrální. friendly: přátelský. hostile: nepřátelský. denounce: odsoudit. declaration of friendship: prohlášení přátelství. open borders: otevřené hranice. defensive pact: obranný pakt. research agreement: dohoda o výzkumu. deal (diplomatic): obchodní dohoda. vassal: vazal. warmonger: válečný štváč. unmet (civilization): neznámá
- Civilopedia: Civilopedie. advisor: poradce (the economic and foreign advisors are poradkyně). notification: hlášení. notification log: záznam hlášení. demographics: demografie
- corporation: korporace. franchise: franšíza

Unit terms:
- combat strength: bojová síla. ranged combat strength: bojová síla na dálku. ranged attack: útok na dálku. range: dostřel (air units: dolet). melee: boj zblízka. movement: pohyb. movement points: pohybové body
- health, hit points: zdraví. damage: poškození. experience: zkušenosti. promotion: povýšení. promote: povýšit. upgrade: vylepšit. heal: léčit
- embark: nalodit. embarked: naloděná. disembark: vylodit. fortify: opevnit. fortified: opevněná. sleep: uspat. wake: probudit. alert, sentry: poplach. pillage: drancovat. garrison: posádka. found city: založit město. delete unit: odstranit jednotku. skip turn: přeskočit tah. automate: automatizovat. explore: prozkoumávat. interception: přepad. air sweep: průlet. rebase: změna základny
- attack: útok. defense: obrana. civilian: civilní. military: vojenský

City terms:
- puppet: loutkové město (status word: loutkové). occupied: okupované. annex: anektovat. raze: srovnat se zemí (status word: srovnávané se zemí). resistance: nepokoje. liberate: osvobodit. production queue: výrobní fronta. queued: ve frontě. purchase: koupit. sell: prodat. growth: růst. starvation: hladovění. slot (great work, specialist, queue, save, player): pozice

Menus and screens:
- main menu: hlavní nabídka. single player: jeden hráč. multiplayer: více hráčů. mods: mody. options, settings: nastavení. load game: načíst hru. save game: uložit hru. advanced setup: pokročilá nastavení. hot seat: horké křeslo. map size: velikost mapy. map type: typ mapy. game speed: rychlost hry. random: náhodně. other: jiné
- yes: ano. no: ne. cancel: zrušit. back: zpět. accept: přijmout. close: zavřít. next: další. previous: předchozí. continue: pokračovat. delete: odstranit. rename: přejmenovat
- ready (lobby): připraven. not ready: nepřipraven. open (slot): otevřeno. closed: uzavřeno. observer: pozorovatel. human: člověk. kick: vyhodit. seat: místo. draft: draft. ban (in a draft): zákaz

Status words:
- selected: vybráno. focused: zvolený. available: dostupné. unavailable: nedostupné. locked: uzamčeno. unlocked: odemčeno. blocked: zablokováno. disabled (control): neaktivní. on, off (also a mod's enabled, disabled): zapnuto, vypnuto
- empty: prázdné. full: plné. none: žádné. all: vše. unknown: neznámé. here: zde. canceled: zrušeno. paused: pozastaveno. resumed: obnoveno. filled: obsazeno. pinned: připnuto
- unexplored: neprozkoumáno. revealed: odkryté. visible: viditelné. unclaimed: bez vlastníka. idle (unit): nečinná
- my, mine: moje. yours: tvoje. theirs: jejich. enemy (adjective): nepřátelské. enemy (noun): nepřítel

Screen-reader interface words:
- button: tlačítko. toggle, checkbox: přepínač. submenu: podnabídka. combo box: rozbalovací seznam. slider: posuvník. tab: karta. list: seznam. edit box: editační pole. search: hledat. edit: upravit. checkmark: zaškrtnutí. item: položka. menu: nabídka. screen: obrazovka. popup: okno

The mod's own features:
- scanner: skener. surveyor: zeměměřič. cursor: kurzor. beacon: maják. bookmark: záložka. squad: oddíl. waypoint: trasový bod. screen reader: čtečka obrazovky. speech: řeč. hotkey: klávesová zkratka. help: nápověda. radius: poloměr. path: trasa. destination: cíl
- audio cue, earcon: zvukový signál. read me: příručka modu

## Icon words

The `TXT_KEY_CIVVACCESS_ICON_*` values are not translated here. The primaries are the Czech nominative (zlato, jídlo, výroba, kultura, věda, víra, turismus, vliv, pohyb, spokojenost, nespokojenost, bojová síla, obyvatel). The `_ALT` aliases are the inflected forms the Czech game prints next to the icon ("ke [ICON_CULTURE] kultuře", "k [ICON_STRENGTH] bojové síle"), chosen by how often each pairing occurs in the patch's text. `tools/icon_dedup_aliases.py` owns the two it tracks.
