# ContentManager

DLC and content activation queries. Static table.

Extracted from 9 call sites across 5 distinct methods in the shipped game Lua.

## Methods

### GetAllPackageIDs
- `ContentManager.GetAllPackageIDs()`
- 1 callsite. Example: `UI/FrontEnd/PremiumContentMenu.lua:58`

### GetPackageDescription
- `ContentManager.GetPackageDescription(v)`
- 1 callsite. Example: `UI/FrontEnd/PremiumContentMenu.lua:66`

### IsActive
- `ContentManager.IsActive("6DA07636-4123-4018-B643-6575B4EC336B", ContentType.GAMEPLAY)`
- `ContentManager.IsActive("0E3751A1-F840-4e1b-9706-519BF484E59D", ContentType.GAMEPLAY)`
- `ContentManager.IsActive(v, ContentType.GAMEPLAY)`
- 5 callsites. Example: `UI/Options/OptionsMenu.lua:1059`

### IsUpgrade
- `ContentManager.IsUpgrade(v)`
- 1 callsite. Example: `UI/FrontEnd/PremiumContentMenu.lua:61`

### SetActive
- `ContentManager.SetActive(packages)`
- 1 callsite. Example: `UI/FrontEnd/PremiumContentMenu.lua:45`
