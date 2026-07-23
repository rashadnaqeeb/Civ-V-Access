#!/usr/bin/env bash
set -euo pipefail

# Civ V Access Installer/Uninstaller (Bash implementation)
# Fully mirrors the C# installer logic with enhanced user interaction.
# - Auto-detects game directory with user confirmation
# - Offers manual path entry if auto-detection fails or user rejects
# - Selects state (Vanilla, Vox Populi, Community Patch, LekMod) and profile (Blind/Sighted)
# - Fetches latest release from GitHub, downloads only required components
# - SHA-256 verification, caching, idempotent operations
# - Backup and restore of original files (engine, cinematics, lua51, Civ5Pkg)
# - Complete uninstall: removes all added files and restores originals

readonly SCRIPT_VERSION="1.0.0"
readonly REPO_OWNER="rashadnaqeeb"
readonly REPO_NAME="Civ-V-Access"
readonly GITHUB_API="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME"

# Colors for terminal output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Directories
readonly CACHE_DIR="$HOME/.cache/CivVAccess/zips"
readonly LOG_DIR="$HOME/.cache/CivVAccess"
readonly LOG_FILE="$LOG_DIR/installer.log"
mkdir -p "$CACHE_DIR" "$LOG_DIR"

# Global variables (will be set during execution)
GAME_ROOT=""
ASSETS_DLC=""
EXPANSION2_DIR=""
MOD_DLC_DIR=""
BACKUP_DIR=""
CIV5_DOCS_DIR="$HOME/Documents/My Games/Sid Meier's Civilization 5"
SELECTED_STATE=""
SELECTED_PROFILE=""
RELEASE_TAG=""
RELEASE_VERSION=""
declare -a ALL_ASSETS=()           # each: "name|url|size|digest"
declare -a REQUIRED_ASSETS=()      # each: "name|url|digest" (paths filled later)
declare -a DOWNLOADED_ASSETS=()    # each: "name|local_path"

# ----------------------------------------------------------------------
# Logging functions
# ----------------------------------------------------------------------
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
    echo "[INFO] $*" >> "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
    echo "[WARN] $*" >> "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
    echo "[ERROR] $*" >> "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
    echo "[SUCCESS] $*" >> "$LOG_FILE"
}

die() {
    log_error "$1"
    exit 1
}

# ----------------------------------------------------------------------
# Dependency check
# ----------------------------------------------------------------------
check_deps() {
    local missing=()
    for cmd in curl jq unzip sha256sum grep sed; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        die "Missing required dependencies: ${missing[*]}. Please install them and re-run."
    fi
}

# ----------------------------------------------------------------------
# Game directory detection with user confirmation
# ----------------------------------------------------------------------
detect_and_confirm_game_dir() {
    log_info "Detecting Civilization V installation..."

    # Build list of candidate directories
    local candidates=()

    # Steam default paths
    if [[ -d "$HOME/.steam/steam/steamapps/common/Sid Meier's Civilization V" ]]; then
        candidates+=("$HOME/.steam/steam/steamapps/common/Sid Meier's Civilization V")
    fi
    if [[ -d "$HOME/.local/share/Steam/steamapps/common/Sid Meier's Civilization V" ]]; then
        candidates+=("$HOME/.local/share/Steam/steamapps/common/Sid Meier's Civilization V")
    fi

    # Steam library folders via libraryfolders.vdf
    local vdf="$HOME/.steam/steam/steamapps/libraryfolders.vdf"
    if [[ -f "$vdf" ]]; then
        while IFS= read -r line; do
            if [[ "$line" =~ \"path\"[[:space:]]+\"([^\"]+)\" ]]; then
                local lib="${BASH_REMATCH[1]}"
                lib="${lib//\\//}"
                if [[ -d "$lib/steamapps/common/Sid Meier's Civilization V" ]]; then
                    candidates+=("$lib/steamapps/common/Sid Meier's Civilization V")
                fi
            fi
        done < "$vdf"
    fi

    # Common non-Steam locations
    if [[ -d "/opt/Civilization V" ]]; then
        candidates+=("/opt/Civilization V")
    fi
    if [[ -d "/usr/local/games/Civilization V" ]]; then
        candidates+=("/usr/local/games/Civilization V")
    fi

    # Environment variable
    if [[ -n "${CIV5_DIR:-}" ]] && [[ -d "$CIV5_DIR" ]]; then
        candidates+=("$CIV5_DIR")
    fi

    # Remove duplicates
    local unique=()
    for c in "${candidates[@]}"; do
        if [[ ! " ${unique[*]} " =~ " $c " ]]; then
            unique+=("$c")
        fi
    done

    # Find first valid candidate
    local found_dir=""
    for dir in "${unique[@]}"; do
        if [[ -f "$dir/CivilizationV.exe" ]] || [[ -f "$dir/CivilizationV" ]]; then
            found_dir="$dir"
            break
        fi
    done

    # If a candidate was found, ask user to confirm
    if [[ -n "$found_dir" ]]; then
        echo "Detected game directory: $found_dir"
        read -rp "Is this correct? (y/n): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            GAME_ROOT="$found_dir"
            log_success "Using game directory: $GAME_ROOT"
            return 0
        fi
    fi

    # Either no detection or user rejected it: ask for manual input
    log_warn "Please enter the full path to your Civilization V game directory:"
    while true; do
        read -rp "> " user_dir
        if [[ -z "$user_dir" ]]; then
            echo "Path cannot be empty. Try again."
            continue
        fi
        if [[ ! -d "$user_dir" ]]; then
            echo "Directory does not exist: $user_dir"
            continue
        fi
        if [[ ! -f "$user_dir/CivilizationV.exe" ]] && [[ ! -f "$user_dir/CivilizationV" ]]; then
            echo "CivilizationV executable not found in $user_dir"
            continue
        fi
        GAME_ROOT="$user_dir"
        log_success "Using game directory: $GAME_ROOT"
        return 0
    done
}

# ----------------------------------------------------------------------
# Check for Brave New World expansion
# ----------------------------------------------------------------------
check_bnw() {
    if [[ ! -d "$GAME_ROOT/Assets/DLC/Expansion2" ]]; then
        die "Brave New World (Expansion2) not found. This mod requires BNW."
    fi
    if [[ ! -f "$GAME_ROOT/Assets/DLC/Expansion2/CvGameCore_Expansion2.dll" ]]; then
        die "Expansion2 engine DLL missing. Please verify game files."
    fi
    EXPANSION2_DIR="$GAME_ROOT/Assets/DLC/Expansion2"
    ASSETS_DLC="$GAME_ROOT/Assets/DLC"
    MOD_DLC_DIR="$ASSETS_DLC/DLC_CivVAccess"
    BACKUP_DIR="$ASSETS_DLC/DLC_CivVAccess.backup"
    log_info "BNW expansion verified."
}

# ----------------------------------------------------------------------
# State and profile selection menus
# ----------------------------------------------------------------------
select_state_profile() {
    echo ""
    echo "Select mod variant:"
    echo "  1) Vanilla (accessibility only)"
    echo "  2) Vox Populi (full modpack with VP balance)"
    echo "  3) Community Patch (CP only, no VP balance)"
    echo "  4) LekMod"
    read -rp "Enter choice [1-4]: " state_choice
    case "$state_choice" in
        1) SELECTED_STATE="vanilla" ;;
        2) SELECTED_STATE="voxpopuli" ;;
        3) SELECTED_STATE="communitypatch" ;;
        4) SELECTED_STATE="lekmod" ;;
        *) die "Invalid choice." ;;
    esac

    echo ""
    echo "Select profile:"
    echo "  1) Blind (full accessibility features)"
    echo "  2) Sighted (multiplayer-compatible minimal)"
    read -rp "Enter choice [1-2]: " profile_choice
    case "$profile_choice" in
        1) SELECTED_PROFILE="blind" ;;
        2) SELECTED_PROFILE="sighted" ;;
        *) die "Invalid choice." ;;
    esac

    log_info "Selected state: $SELECTED_STATE, profile: $SELECTED_PROFILE"
}

# ----------------------------------------------------------------------
# Fetch release info from GitHub
# ----------------------------------------------------------------------
fetch_release() {
    log_info "Fetching latest release from GitHub..."
    local release_json
    release_json=$(curl -s "$GITHUB_API/releases/latest") || die "Failed to fetch release info. Check network."
    local tag
    tag=$(echo "$release_json" | jq -r '.tag_name')
    if [[ -z "$tag" || "$tag" == "null" ]]; then
        die "No release found."
    fi
    RELEASE_TAG="$tag"
    RELEASE_VERSION="${tag#v}"
    log_info "Latest release: $RELEASE_TAG"

    # Parse assets
    local assets_json
    assets_json=$(echo "$release_json" | jq -c '.assets[]')
    ALL_ASSETS=()
    while IFS= read -r asset; do
        local name url size digest
        name=$(echo "$asset" | jq -r '.name')
        url=$(echo "$asset" | jq -r '.browser_download_url')
        size=$(echo "$asset" | jq -r '.size')
        digest=$(echo "$asset" | jq -r '.digest // ""')
        # Accept only zip files matching known component prefixes
        if [[ "$name" =~ ^([a-z0-9_-]+)-([0-9]+\.[0-9]+\.[0-9]+)\.zip$ ]]; then
            ALL_ASSETS+=("$name|$url|$size|$digest")
        fi
    done <<< "$assets_json"

    if [[ ${#ALL_ASSETS[@]} -eq 0 ]]; then
        die "No component assets found in release."
    fi
    log_info "Found ${#ALL_ASSETS[@]} component assets."
}

# ----------------------------------------------------------------------
# Compute required component list based on state/profile
# ----------------------------------------------------------------------
compute_required_assets() {
    local needed_prefixes=()
    case "$SELECTED_PROFILE" in
        blind)
            case "$SELECTED_STATE" in
                vanilla)     needed_prefixes=("core-blind" "runtime" "engine" "cinematics") ;;
                voxpopuli)   needed_prefixes=("core-blind" "runtime" "cinematics" "vp-overlay" "vp-modpack" "vp-runtime") ;;
                communitypatch) needed_prefixes=("core-blind" "runtime" "cinematics" "cp-overlay" "cp-modpack") ;;
                lekmod)      needed_prefixes=("core-blind" "runtime" "cinematics" "lekmod-overlay" "lekmod-dlc") ;;
            esac
            ;;
        sighted)
            case "$SELECTED_STATE" in
                vanilla)     needed_prefixes=("core-sighted" "engine") ;;
                voxpopuli)   needed_prefixes=("core-sighted" "vp-modpack" "vp-runtime") ;;
                communitypatch) needed_prefixes=("core-sighted" "cp-modpack") ;;
                lekmod)      needed_prefixes=("core-sighted" "lekmod-dlc") ;;
            esac
            ;;
    esac

    REQUIRED_ASSETS=()
    for entry in "${ALL_ASSETS[@]}"; do
        IFS='|' read -r name url size digest <<< "$entry"
        local prefix
        prefix=$(echo "$name" | sed -E 's/-[0-9]+\.[0-9]+\.[0-9]+\.zip$//')
        for req in "${needed_prefixes[@]}"; do
            if [[ "$prefix" == "$req" ]]; then
                REQUIRED_ASSETS+=("$name|$url|$digest")
                break
            fi
        done
    done

    if [[ ${#REQUIRED_ASSETS[@]} -eq 0 ]]; then
        die "No assets match the selected state/profile."
    fi
    log_info "Required assets: ${#REQUIRED_ASSETS[@]}"
}

# ----------------------------------------------------------------------
# Download an asset with caching and SHA-256 verification
# ----------------------------------------------------------------------
download_asset() {
    local name="$1"
    local url="$2"
    local expected_digest="$3"
    local cache_path="$CACHE_DIR/$name"

    # Check cache
    if [[ -f "$cache_path" ]]; then
        log_info "Cache hit: $name"
        if [[ -n "$expected_digest" ]]; then
            local actual
            actual=$(sha256sum "$cache_path" | awk '{print $1}')
            if [[ "$actual" != "$expected_digest" ]]; then
                log_warn "Checksum mismatch for cached $name. Re-downloading."
                rm -f "$cache_path"
            else
                log_info "Checksum verified for cached $name"
                echo "$cache_path"
                return 0
            fi
        else
            # No checksum, trust cache
            echo "$cache_path"
            return 0
        fi
    fi

    # Download
    log_info "Downloading $name ..."
    curl -# -L "$url" -o "$cache_path" || {
        rm -f "$cache_path"
        die "Failed to download $name"
    }

    # Verify if digest available
    if [[ -n "$expected_digest" ]]; then
        local actual
        actual=$(sha256sum "$cache_path" | awk '{print $1}')
        if [[ "$actual" != "$expected_digest" ]]; then
            rm -f "$cache_path"
            die "Checksum mismatch for $name. Expected $expected_digest, got $actual"
        fi
        log_info "Checksum verified for $name"
    else
        log_warn "No checksum for $name; skipping verification."
    fi

    echo "$cache_path"
}

# ----------------------------------------------------------------------
# Download all required assets
# ----------------------------------------------------------------------
download_required_assets() {
    log_info "Downloading required assets..."
    DOWNLOADED_ASSETS=()
    for entry in "${REQUIRED_ASSETS[@]}"; do
        IFS='|' read -r name url digest <<< "$entry"
        local path
        path=$(download_asset "$name" "$url" "$digest")
        DOWNLOADED_ASSETS+=("$name|$path")
    done
}

# ----------------------------------------------------------------------
# Backup original game files (idempotent)
# ----------------------------------------------------------------------
backup_files() {
    log_info "Backing up original files..."
    mkdir -p "$BACKUP_DIR"

    # Engine DLL
    if [[ -f "$EXPANSION2_DIR/CvGameCore_Expansion2.dll" ]]; then
        if [[ ! -f "$BACKUP_DIR/CvGameCore_Expansion2.vanilla.dll" ]]; then
            cp "$EXPANSION2_DIR/CvGameCore_Expansion2.dll" "$BACKUP_DIR/CvGameCore_Expansion2.vanilla.dll"
            log_info "Backed up engine DLL"
        fi
    fi

    # Cinematics (only if cinematics component is required)
    local need_cinematics=false
    for entry in "${REQUIRED_ASSETS[@]}"; do
        if [[ "$entry" =~ cinematics ]]; then
            need_cinematics=true
            break
        fi
    done
    if $need_cinematics; then
        mkdir -p "$BACKUP_DIR/cinematics"
        for f in Civ5XP2_Opening_Movie_en_US.wmv Civ5XP2_Opening_Movie_de_DE.wma Civ5XP2_Opening_Movie_es_ES.wma Civ5XP2_Opening_Movie_fr_FR.wma Civ5XP2_Opening_Movie_it_IT.wma Civ5XP2_Opening_Movie_pl_PL.wma Civ5XP2_Opening_Movie_ru_RU.wma; do
            if [[ -f "$EXPANSION2_DIR/$f" ]] && [[ ! -f "$BACKUP_DIR/cinematics/$f" ]]; then
                cp "$EXPANSION2_DIR/$f" "$BACKUP_DIR/cinematics/$f"
                log_info "Backed up $f"
            fi
        done
    fi

    # lua51 (for blind profile)
    if [[ "$SELECTED_PROFILE" == "blind" ]]; then
        if [[ -f "$GAME_ROOT/lua51_Win32.dll" ]] && [[ ! -f "$GAME_ROOT/lua51_original.dll" ]]; then
            mv "$GAME_ROOT/lua51_Win32.dll" "$GAME_ROOT/lua51_original.dll"
            log_info "Renamed lua51_Win32.dll -> lua51_original.dll"
        fi
    fi

    # Expansion2.Civ5Pkg (for Vox Populi)
    if [[ "$SELECTED_STATE" == "voxpopuli" ]]; then
        if [[ -f "$EXPANSION2_DIR/Expansion2.Civ5Pkg" ]] && [[ ! -f "$BACKUP_DIR/Expansion2.Civ5Pkg.stock" ]]; then
            # Only backup if it's not already the VP version
            if ! grep -q "MinorCivSounds_VoxPopuli" "$EXPANSION2_DIR/Expansion2.Civ5Pkg" 2>/dev/null; then
                cp "$EXPANSION2_DIR/Expansion2.Civ5Pkg" "$BACKUP_DIR/Expansion2.Civ5Pkg.stock"
                log_info "Backed up Expansion2.Civ5Pkg"
            fi
        fi
    fi
}

# ----------------------------------------------------------------------
# Extract and install components
# ----------------------------------------------------------------------
install_components() {
    log_info "Installing components..."

    # First, separate paths by component type
    local engine_path="" cinematics_path="" runtime_path="" core_path=""
    local vp_overlay="" cp_overlay="" lek_overlay="" vp_modpack="" cp_modpack="" vp_runtime="" lekmod_dlc=""

    for entry in "${DOWNLOADED_ASSETS[@]}"; do
        IFS='|' read -r name path <<< "$entry"
        local prefix
        prefix=$(echo "$name" | sed -E 's/-[0-9]+\.[0-9]+\.[0-9]+\.zip$//')
        case "$prefix" in
            engine)          engine_path="$path" ;;
            cinematics)      cinematics_path="$path" ;;
            runtime)         runtime_path="$path" ;;
            core-blind|core-sighted) core_path="$path" ;;
            vp-overlay)      vp_overlay="$path" ;;
            cp-overlay)      cp_overlay="$path" ;;
            lekmod-overlay)  lek_overlay="$path" ;;
            vp-modpack)      vp_modpack="$path" ;;
            cp-modpack)      cp_modpack="$path" ;;
            vp-runtime)      vp_runtime="$path" ;;
            lekmod-dlc)      lekmod_dlc="$path" ;;
        esac
    done

    # Apply in dependency order

    # Engine
    if [[ -n "$engine_path" ]]; then
        log_info "Installing engine fork..."
        unzip -q -o "$engine_path" -d "$EXPANSION2_DIR"
    fi

    # Cinematics
    if [[ -n "$cinematics_path" ]]; then
        log_info "Installing cinematics..."
        unzip -q -o "$cinematics_path" -d "$EXPANSION2_DIR"
    fi

    # Runtime (proxy + Tolk)
    if [[ -n "$runtime_path" ]]; then
        log_info "Installing runtime (proxy) files..."
        unzip -q -o "$runtime_path" -d "$GAME_ROOT"
    fi

    # Core DLC (nuke and recreate)
    if [[ -n "$core_path" ]]; then
        log_info "Installing core DLC..."
        rm -rf "$MOD_DLC_DIR"
        mkdir -p "$MOD_DLC_DIR"
        unzip -q -o "$core_path" -d "$MOD_DLC_DIR"
    fi

    # Overlays (extract over core)
    if [[ -n "$vp_overlay" ]]; then
        log_info "Installing Vox Populi overlay..."
        unzip -q -o "$vp_overlay" -d "$MOD_DLC_DIR"
    fi
    if [[ -n "$cp_overlay" ]]; then
        log_info "Installing Community Patch overlay..."
        unzip -q -o "$cp_overlay" -d "$MOD_DLC_DIR"
    fi
    if [[ -n "$lek_overlay" ]]; then
        log_info "Installing LekMod overlay..."
        unzip -q -o "$lek_overlay" -d "$MOD_DLC_DIR"
    fi

    # Modpack packages
    if [[ -n "$vp_modpack" ]]; then
        log_info "Installing VP modpack package..."
        rm -rf "$ASSETS_DLC/ZCivVAccessVP"
        mkdir -p "$ASSETS_DLC/ZCivVAccessVP"
        unzip -q -o "$vp_modpack" -d "$ASSETS_DLC/ZCivVAccessVP"
    fi
    if [[ -n "$cp_modpack" ]]; then
        log_info "Installing CP modpack package..."
        rm -rf "$ASSETS_DLC/ZCivVAccessCP"
        mkdir -p "$ASSETS_DLC/ZCivVAccessCP"
        unzip -q -o "$cp_modpack" -d "$ASSETS_DLC/ZCivVAccessCP"
    fi

    # VP runtime (substrate) - routed extraction
    if [[ -n "$vp_runtime" ]]; then
        log_info "Installing VP runtime (substrate)..."
        mkdir -p "$CIV5_DOCS_DIR"
        local tmp_extract
        tmp_extract=$(mktemp -d)
        unzip -q -o "$vp_runtime" -d "$tmp_extract"
        if [[ -d "$tmp_extract/game" ]]; then
            cp -r "$tmp_extract/game/." "$GAME_ROOT/"
        fi
        if [[ -d "$tmp_extract/docs" ]]; then
            cp -r "$tmp_extract/docs/." "$CIV5_DOCS_DIR/"
        fi
        rm -rf "$tmp_extract"
    fi

    # LekMod DLC - routed extraction
    if [[ -n "$lekmod_dlc" ]]; then
        log_info "Installing LekMod DLC..."
        rm -rf "$ASSETS_DLC/LEKMOD" "$GAME_ROOT/Assets/Maps/Lekmap"
        local tmp_extract
        tmp_extract=$(mktemp -d)
        unzip -q -o "$lekmod_dlc" -d "$tmp_extract"
        if [[ -d "$tmp_extract/dlc" ]]; then
            mkdir -p "$ASSETS_DLC/LEKMOD"
            cp -r "$tmp_extract/dlc/." "$ASSETS_DLC/LEKMOD/"
        fi
        if [[ -d "$tmp_extract/maps" ]]; then
            mkdir -p "$GAME_ROOT/Assets/Maps/Lekmap"
            cp -r "$tmp_extract/maps/." "$GAME_ROOT/Assets/Maps/Lekmap/"
        fi
        rm -rf "$tmp_extract"
    fi

    log_success "All components installed."
}

# ----------------------------------------------------------------------
# Write install manifest (JSON)
# ----------------------------------------------------------------------
write_manifest() {
    log_info "Writing install manifest..."
    local manifest_path="$MOD_DLC_DIR/CivVAccess.install.json"
    mkdir -p "$MOD_DLC_DIR"

    # Build components object
    local components_json=""
    local first=true
    for entry in "${DOWNLOADED_ASSETS[@]}"; do
        IFS='|' read -r name path <<< "$entry"
        local prefix
        prefix=$(echo "$name" | sed -E 's/-[0-9]+\.[0-9]+\.[0-9]+\.zip$//')
        local key=""
        case "$prefix" in
            core-blind) key="core" ;;
            core-sighted) key="core_sighted" ;;
            engine) key="engine" ;;
            runtime) key="runtime" ;;
            cinematics) key="cinematics" ;;
            vp-overlay) key="vp_overlay" ;;
            cp-overlay) key="cp_overlay" ;;
            lekmod-overlay) key="lekmod_overlay" ;;
            vp-modpack) key="vp_modpack" ;;
            cp-modpack) key="cp_modpack" ;;
            vp-runtime) key="vp_runtime" ;;
            lekmod-dlc) key="lekmod_dlc" ;;
            *) continue ;;
        esac
        local sha=""
        if [[ -f "$path" ]]; then
            sha=$(sha256sum "$path" | awk '{print $1}')
        fi
        if $first; then
            first=false
        else
            components_json+=","
        fi
        components_json+=$'\n        "'"$key"$'"': { "version": "'"$RELEASE_VERSION"'", "sha256": "'"$sha"'" }'
    done

    # Backup entries (simplified)
    local backups_json='{
        "engine_dll": "Assets/DLC/DLC_CivVAccess.backup/CvGameCore_Expansion2.vanilla.dll",
        "cinematics": "Assets/DLC/DLC_CivVAccess.backup/cinematics",
        "lua51": "lua51_original.dll"
    }'
    if [[ "$SELECTED_STATE" == "voxpopuli" ]]; then
        backups_json=$(echo "$backups_json" | jq '. + {"civ5pkg": "Assets/DLC/DLC_CivVAccess.backup/Expansion2.Civ5Pkg.stock"}')
    fi

    # Write full JSON
    cat > "$manifest_path" <<EOF
{
    "schema_version": 1,
    "mod_version": "$RELEASE_VERSION",
    "profile": "$SELECTED_PROFILE",
    "variant": "$SELECTED_STATE",
    "installed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "components": {$components_json
    },
    "backups": $backups_json
}
EOF

    log_info "Manifest written to $manifest_path"
}

# ----------------------------------------------------------------------
# Clear DLC cache
# ----------------------------------------------------------------------
clear_dlc_cache() {
    local cache_dir="$CIV5_DOCS_DIR/cache"
    if [[ -d "$cache_dir" ]]; then
        log_info "Clearing DLC cache..."
        rm -f "$cache_dir"/*
    fi
}

# ----------------------------------------------------------------------
# Main install orchestration
# ----------------------------------------------------------------------
do_install() {
    log_info "Starting installation..."
    check_deps
    detect_and_confirm_game_dir
    check_bnw
    select_state_profile
    fetch_release
    compute_required_assets
    download_required_assets
    backup_files
    install_components
    write_manifest
    clear_dlc_cache
    log_success "Installation completed successfully!"
}

# ----------------------------------------------------------------------
# Uninstall
# ----------------------------------------------------------------------
do_uninstall() {
    log_info "Starting uninstall..."
    check_deps
    detect_and_confirm_game_dir
    check_bnw

    log_info "Removing installed artifacts..."

    # Proxy (lua51, Tolk, etc.)
    if [[ -f "$GAME_ROOT/lua51_original.dll" ]]; then
        if [[ -f "$GAME_ROOT/lua51_Win32.dll" ]]; then
            rm -f "$GAME_ROOT/lua51_Win32.dll"
        fi
        mv "$GAME_ROOT/lua51_original.dll" "$GAME_ROOT/lua51_Win32.dll"
        log_info "Restored lua51_Win32.dll"
    fi
    for f in Tolk.dll SAAPI32.dll dolapi32.dll nvdaControllerClient32.dll BoyCtrl.dll boyctrl.ini ZDSRAPI.dll ZDSRAPI.ini; do
        if [[ -f "$GAME_ROOT/$f" ]]; then
            rm -f "$GAME_ROOT/$f"
            log_info "Removed $f"
        fi
    done
    if [[ -f "$GAME_ROOT/proxy_debug.log" ]]; then
        rm -f "$GAME_ROOT/proxy_debug.log"
    fi

    # Modpack packages
    if [[ -d "$ASSETS_DLC/ZCivVAccessVP" ]]; then
        rm -rf "$ASSETS_DLC/ZCivVAccessVP"
        log_info "Removed VP modpack"
    fi
    if [[ -d "$ASSETS_DLC/ZCivVAccessCP" ]]; then
        rm -rf "$ASSETS_DLC/ZCivVAccessCP"
        log_info "Removed CP modpack"
    fi

    # LekMod DLC
    if [[ -d "$ASSETS_DLC/LEKMOD" ]]; then
        rm -rf "$ASSETS_DLC/LEKMOD"
        log_info "Removed LekMod DLC"
    fi
    if [[ -d "$GAME_ROOT/Assets/Maps/Lekmap" ]]; then
        rm -rf "$GAME_ROOT/Assets/Maps/Lekmap"
        log_info "Removed Lekmap"
    fi

    # VP substrate
    if [[ -f "$EXPANSION2_DIR/Expansion2.Civ5Pkg" ]]; then
        if [[ -f "$BACKUP_DIR/Expansion2.Civ5Pkg.stock" ]]; then
            cp "$BACKUP_DIR/Expansion2.Civ5Pkg.stock" "$EXPANSION2_DIR/Expansion2.Civ5Pkg"
            log_info "Restored stock Expansion2.Civ5Pkg"
        else
            log_warn "No stock Civ5Pkg backup; leaving current."
        fi
    fi
    if [[ -d "$ASSETS_DLC/VPUI" ]]; then
        rm -rf "$ASSETS_DLC/VPUI"
        log_info "Removed VPUI"
    fi
    if [[ -f "$EXPANSION2_DIR/Sounds/XML/MinorCivSounds_VoxPopuli.xml" ]]; then
        rm -f "$EXPANSION2_DIR/Sounds/XML/MinorCivSounds_VoxPopuli.xml"
    fi
    if [[ -f "$CIV5_DOCS_DIR/Text/VPUI_tips_en_us.xml" ]]; then
        rm -f "$CIV5_DOCS_DIR/Text/VPUI_tips_en_us.xml"
    fi

    # Mod DLC and manifest
    if [[ -d "$MOD_DLC_DIR" ]]; then
        rm -rf "$MOD_DLC_DIR"
        log_info "Removed mod DLC"
    fi

    # Restore engine DLL
    if [[ -f "$BACKUP_DIR/CvGameCore_Expansion2.vanilla.dll" ]]; then
        cp "$BACKUP_DIR/CvGameCore_Expansion2.vanilla.dll" "$EXPANSION2_DIR/CvGameCore_Expansion2.dll"
        log_info "Restored engine DLL"
    fi

    # Restore cinematics
    if [[ -d "$BACKUP_DIR/cinematics" ]]; then
        for f in Civ5XP2_Opening_Movie_en_US.wmv Civ5XP2_Opening_Movie_de_DE.wma Civ5XP2_Opening_Movie_es_ES.wma Civ5XP2_Opening_Movie_fr_FR.wma Civ5XP2_Opening_Movie_it_IT.wma Civ5XP2_Opening_Movie_pl_PL.wma Civ5XP2_Opening_Movie_ru_RU.wma; do
            if [[ -f "$BACKUP_DIR/cinematics/$f" ]]; then
                cp "$BACKUP_DIR/cinematics/$f" "$EXPANSION2_DIR/$f"
                log_info "Restored $f"
            fi
        done
    fi

    # Remove backup dir
    if [[ -d "$BACKUP_DIR" ]]; then
        rm -rf "$BACKUP_DIR"
        log_info "Removed backup directory"
    fi

    # Clear cache
    clear_dlc_cache

    # Optionally clear download cache
    echo ""
    read -rp "Remove downloaded zip cache? (y/N): " rm_cache
    if [[ "$rm_cache" =~ ^[Yy]$ ]]; then
        rm -rf "$CACHE_DIR"
        log_info "Removed download cache"
    fi

    log_success "Uninstall completed."
}

# ----------------------------------------------------------------------
# Main menu
# ----------------------------------------------------------------------
main_menu() {
    echo ""
    echo "==================================="
    echo "   Civ V Access Installer v$SCRIPT_VERSION"
    echo "==================================="
    echo "1) Install"
    echo "2) Uninstall"
    echo "3) Exit"
    read -rp "Choose an option [1-3]: " choice
    case "$choice" in
        1) do_install ;;
        2) do_uninstall ;;
        3) exit 0 ;;
        *) echo "Invalid choice."; main_menu ;;
    esac
}

# ----------------------------------------------------------------------
# Entry point
# ----------------------------------------------------------------------
main_menu