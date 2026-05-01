# `src/dlc/UI/InGame/CivVAccess_ScannerCore.lua`

189 lines · Defines the scanner's static category/subcategory taxonomy, the ScanEntry shape contract, and the backend self-registration registry.

## Header comment

```
-- Scanner taxonomy, entry shape, and backend-registration registry.
-- No game calls -- this file defines only the static ordering tables and
-- the contract every backend implements.
--
-- Hierarchy (design section 1):
--   category -> subcategory -> item -> instance.
-- Every category has an implicit `all` subcategory at index 1 that
-- shares item references with its named siblings; removing an instance
-- from a named subcategory automatically drops it from `all` because
-- items are shared, not copied. Snapshot building (ScannerSnap) owns
-- the merge; this file just declares the named subcategories.
--
-- Categories with no meaningful split declare `subcategories = {}` and
-- backends emit entries with `subcategory = "all"` directly. Snap adds
-- them once into the implicit `all` sub without the named-sib share
-- step. Sub-cycle in Nav then degenerates to a no-op on those
-- categories (only one sub with items).
--
-- ScanEntry shape (emitted by every backend's Scan):
--   plotIndex   number      Map.GetPlotByIndex index.
--   backend     table       ScannerCore-registered backend; Snap uses
--                           this for ValidateEntry / FormatName dispatch.
--   data        opaque      Backend-specific handle (city ID, unit ID,
--                           plot coords, etc.) that ValidateEntry and
--                           FormatName read -- never game state cached
--                           off it, always re-queried at announce time.
--   category    string      Key from ScannerCore.CATEGORIES.
--   subcategory string      Key of a named subcategory beneath category.
--                           `all` is never emitted; Snap assembles it.
--   itemName    string      Already-localised label; the "collapse by
--                           name" key for grouping instances into items.
--   key         string      Stable identifier for the underlying entity
--                           (unit ID, city ID, plot + kind, ...) that
--                           survives rebuilds. Nav uses it to re-find
--                           the user's cursor across an identity-
--                           preserving rebuild so a resort doesn't move
--                           them off whatever they were on. Two entries
--                           produced by the same backend for the same
--                           entity must emit the same key; distinct
--                           entries (e.g. base terrain + feature on the
--                           same plot) must emit distinct keys.
--   sortKey     number      Optional secondary sort; falls through to
--                           PlotDistance on tie. Backends that don't
--                           need one can leave it 0.
```

## Outline

- L46: `ScannerCore = {}`
- L51: `ScannerCore.CATEGORIES = { ... }`
- L167: `ScannerCore.CATEGORIES_BY_KEY = {}`
- L175: `ScannerCore.BACKENDS = {}`
- L177: `function ScannerCore.registerBackend(backend)`
