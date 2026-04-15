-- Bootstrap for the in-game UI. This is the one place we call tolk.output
-- directly; the central announcement pipeline (future task) will replace it.
print("[CivVAccess] in-game boot")
tolk.output("Civilization V accessibility loaded in-game.", true)
