#!/usr/bin/env bash
set -euo pipefail

# Civ V Access Installer/Uninstaller (Bash implementation)
readonly SCRIPT_VERSION="1.0.0"
readonly REPO_OWNER="rashadnaqeeb"
readonly REPO_NAME="Civ-V-Access"
readonly GITHUB_API="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME"

# No colors for accessibility
readonly NC='\033[0m'

# Directories
readonly CACHE_DIR="$HOME/.cache/CivVAccess/zips"
readonly LOG_DIR="$HOME/.cache/CivVAccess"
readonly LOG_FILE="$LOG_DIR/installer.log"
mkdir -p "$CACHE_DIR" "$LOG_DIR"

# Global variables
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
declare -a ALL_ASSETS=()
declare -a REQUIRED_ASSETS=()
declare -a DOWNLOADED_ASSETS=()

# ----------------------------------------------------------------------
# Simple logging functions - no colors, no extra symbols
# ----------------------------------------------------------------------
log_info() {
    echo "INFO: $*" >&2
    echo "INFO: $*" >> "$LOG_FILE"
}
log_warn() {
    echo "WARNING: $*" >&2
    echo "WARNING: $*" >> "$LOG_FILE"
}
log_error() {
    echo "ERROR: $*" >&2
    echo "ERROR: $*" >> "$LOG_FILE"
}
log_success() {
    echo "SUCCESS: $*" >&2
    echo "SUCCESS: $*" >> "$LOG_FILE"
}
die() {
    log_error "$1"
    exit 1
}

# ----------------------------------------------------------------------
# Safe ZIP extraction using 7z (handles backslashes properly)
# ----------------------------------------------------------------------
extract_zip_safe() {
    local zip_file="$1"
    local target_dir="$2"
    
    mkdir -p "$target_dir"
    7z x "$zip_file" -o"$target_dir" -y -bd >/dev/null 2>&1 || {
        log_error "Failed to extract $zip_file with 7z"
        return 1
    }
}

# ----------------------------------------------------------------------
# Dependency check - requires 7z
# ----------------------------------------------------------------------
check_deps() {
    local missing=()
    
    # Check for 7z
    if ! command -v 7z &>/dev/null; then
        echo "ERROR: 7z (p7zip-full) is not installed." >&2
        echo "Please install it using your package manager:" >&2
        echo "  - Debian/Ubuntu: sudo apt install p7zip-full" >&2
        echo "  - Fedora:       sudo dnf install p7zip p7zip-plugins" >&2
        echo "  - Arch Linux:   sudo pacman -S p7zip" >&2
        echo "  - openSUSE:     sudo zypper install p7zip-full" >&2
        exit 1
    fi
    
    # Check other required tools
    for cmd in curl jq sha256sum grep sed; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        die "Missing required dependencies: ${missing[*]}. Please install them and re-run."
    fi
}

# ----------------------------------------------------------------------
# Game directory detection
# ----------------------------------------------------------------------
detect_and_confirm_game_dir() {
    log_info "Detecting Civilization V installation..."
    local candidates=()
    if [[ -d "$HOME/.steam/steam/steamapps/common/Sid Meier's Civilization V" ]]; then
        candidates+=("$HOME/.steam/steam/steamapps/common/Sid Meier's Civilization V")
    fi
    if [[ -d "$HOME/.local/share/Steam/steamapps/common/Sid Meier's Civilization V" ]]; then
        candidates+=("$HOME/.local/share/Steam/steamapps/common/Sid Meier's Civilization V")
    fi
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
    if [[ -d "/opt/Civilization V" ]]; then
        candidates+=("/opt/Civilization V")
    fi
    if [[ -d "/usr/local/games/Civilization V" ]]; then
        candidates+=("/usr/local/games/Civilization V")
    fi
    if [[ -n "${CIV5_DIR:-}" ]] && [[ -d "$CIV5_DIR" ]]; then
        candidates+=("$CIV5_DIR")
    fi

    local unique=()
    for c in "${candidates[@]}"; do
        if [[ ! " ${unique[*]} " =~ " $c " ]]; then
            unique+=("$c")
        fi
    done

    local found_dir=""
    for dir in "${unique[@]}"; do
        if [[ -f "$dir/CivilizationV.exe" ]] || [[ -f "$dir/CivilizationV" ]]; then
            found_dir="$dir"
            break
        fi
    done

    if [[ -n "$found_dir" ]]; then
        echo "Detected game directory: $found_dir" >&2
        read -rp "Is this correct? (y/n): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            GAME_ROOT="$found_dir"
            log_success "Using game directory: $GAME_ROOT"
            return 0
        fi
    fi

    log_warn "Please enter the full path to your Civilization V game directory:"
    while true; do
        read -rp "> " user_dir
        if [[ -z "$user_dir" ]]; then
            echo "Path cannot be empty." >&2
            continue
        fi
        if [[ ! -d "$user_dir" ]]; then
            echo "Directory does not exist: $user_dir" >&2
            continue
        fi
        if [[ ! -f "$user_dir/CivilizationV.exe" ]] && [[ ! -f "$user_dir/CivilizationV" ]]; then
            echo "CivilizationV executable not found in $user_dir" >&2
            continue
        fi
        GAME_ROOT="$user_dir"
        log_success "Using game directory: $GAME_ROOT"
        return 0
    done
}

# ----------------------------------------------------------------------
# Check BNW
# ----------------------------------------------------------------------
check_bnw() {
    if [[ ! -d "$GAME_ROOT/Assets/DLC/Expansion2" ]]; then
        die "Brave New World (Expansion2) not found."
    fi
    if [[ ! -f "$GAME_ROOT/Assets/DLC/Expansion2/CvGameCore_Expansion2.dll" ]]; then
        die "Expansion2 engine DLL missing."
    fi
    EXPANSION2_DIR="$GAME_ROOT/Assets/DLC/Expansion2"
    ASSETS_DLC="$GAME_ROOT/Assets/DLC"
    MOD_DLC_DIR="$ASSETS_DLC/DLC_CivVAccess"
    BACKUP_DIR="$ASSETS_DLC/DLC_CivVAccess.backup"
    log_info "BNW expansion verified."
}

# ----------------------------------------------------------------------
# State/profile selection - simple text, no symbols
# ----------------------------------------------------------------------
select_state_profile() {
    echo "" >&2
    echo "Select mod variant:" >&2
    echo "  1) Vanilla (accessibility only)" >&2
    echo "  2) Vox Populi (full modpack with VP balance)" >&2
    echo "  3) Community Patch (CP only, no VP balance)" >&2
    echo "  4) LekMod" >&2
    read -rp "Enter choice [1-4]: " state_choice
    case "$state_choice" in
        1) SELECTED_STATE="vanilla" ;;
        2) SELECTED_STATE="voxpopuli" ;;
        3) SELECTED_STATE="communitypatch" ;;
        4) SELECTED_STATE="lekmod" ;;
        *) die "Invalid choice." ;;
    esac

    echo "" >&2
    echo "Select profile:" >&2
    echo "  1) Blind (full accessibility features)" >&2
    echo "  2) Sighted (multiplayer-compatible minimal)" >&2
    read -rp "Enter choice [1-2]: " profile_choice
    case "$profile_choice" in
        1) SELECTED_PROFILE="blind" ;;
        2) SELECTED_PROFILE="sighted" ;;
        *) die "Invalid choice." ;;
    esac
    log_info "Selected state: $SELECTED_STATE, profile: $SELECTED_PROFILE"
}

# ----------------------------------------------------------------------
# Fetch release
# ----------------------------------------------------------------------
fetch_release() {
    log_info "Fetching latest release from GitHub..."
    local release_json
    release_json=$(curl -s "$GITHUB_API/releases/latest") || die "Failed to fetch release."
    local tag
    tag=$(echo "$release_json" | jq -r '.tag_name')
    if [[ -z "$tag" || "$tag" == "null" ]]; then
        die "No release found."
    fi
    RELEASE_TAG="$tag"
    RELEASE_VERSION="${tag#v}"
    log_info "Latest release: $RELEASE_TAG"

    local assets_json
    assets_json=$(echo "$release_json" | jq -c '.assets[]')
    ALL_ASSETS=()
    while IFS= read -r asset; do
        local name url size digest
        name=$(echo "$asset" | jq -r '.name')
        url=$(echo "$asset" | jq -r '.browser_download_url')
        size=$(echo "$asset" | jq -r '.size')
        digest=$(echo "$asset" | jq -r '.digest // ""' | sed 's/^sha256://' | tr -d '\r\n')
        if [[ "$name" =~ ^([a-z0-9_-]+)-([0-9]+\.[0-9]+\.[0-9]+)\.zip$ ]]; then
            ALL_ASSETS+=("$name|$url|$size|$digest")
        fi
    done <<< "$assets_json"

    if [[ ${#ALL_ASSETS[@]} -eq 0 ]]; then
        die "No component assets found."
    fi
    log_info "Found ${#ALL_ASSETS[@]} component assets."
}

# ----------------------------------------------------------------------
# Compute required assets
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
        die "No assets match selected state/profile."
    fi
    log_info "Required assets: ${#REQUIRED_ASSETS[@]}"
}

# ----------------------------------------------------------------------
# Download asset with cache and checksum
# ----------------------------------------------------------------------
download_asset() {
    local name="$1" url="$2" expected_digest="$3"
    local cache_path="$CACHE_DIR/$name"

    if [[ -f "$cache_path" ]]; then
        log_info "Cache hit: $name"
        if [[ -n "$expected_digest" ]]; then
            local actual
            actual=$(sha256sum "$cache_path" | awk '{print $1}' | tr -d '\r\n')
            local expected_clean=$(echo "$expected_digest" | tr -d '\r\n')
            if [[ "$actual" != "$expected_clean" ]]; then
                log_warn "Checksum mismatch for cached $name. Re-downloading."
                rm -f "$cache_path"
            else
                log_info "Checksum verified for cached $name"
                echo "$cache_path"
                return 0
            fi
        else
            echo "$cache_path"
            return 0
        fi
    fi

    log_info "Downloading $name ..."
    curl -# -L "$url" -o "$cache_path" >&2 || { rm -f "$cache_path"; die "Failed to download $name"; }

    if [[ -n "$expected_digest" ]]; then
        local actual
        actual=$(sha256sum "$cache_path" | awk '{print $1}' | tr -d '\r\n')
        local expected_clean=$(echo "$expected_digest" | tr -d '\r\n')
        if [[ "$actual" != "$expected_clean" ]]; then
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
# Download all required
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
# Backup original files
# ----------------------------------------------------------------------
backup_files() {
    log_info "Backing up original files..."
    mkdir -p "$BACKUP_DIR"

    if [[ -f "$EXPANSION2_DIR/CvGameCore_Expansion2.dll" ]] && [[ ! -f "$BACKUP_DIR/CvGameCore_Expansion2.vanilla.dll" ]]; then
        cp "$EXPANSION2_DIR/CvGameCore_Expansion2.dll" "$BACKUP_DIR/CvGameCore_Expansion2.vanilla.dll"
        log_info "Backed up engine DLL"
    fi

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

    if [[ "$SELECTED_PROFILE" == "blind" ]]; then
        if [[ -f "$GAME_ROOT/lua51_Win32.dll" ]] && [[ ! -f "$GAME_ROOT/lua51_original.dll" ]]; then
            mv "$GAME_ROOT/lua51_Win32.dll" "$GAME_ROOT/lua51_original.dll"
            log_info "Renamed lua51_Win32.dll to lua51_original.dll"
        fi
    fi

    if [[ "$SELECTED_STATE" == "voxpopuli" ]]; then
        if [[ -f "$EXPANSION2_DIR/Expansion2.Civ5Pkg" ]] && [[ ! -f "$BACKUP_DIR/Expansion2.Civ5Pkg.stock" ]]; then
            if ! grep -q "MinorCivSounds_VoxPopuli" "$EXPANSION2_DIR/Expansion2.Civ5Pkg" 2>/dev/null; then
                cp "$EXPANSION2_DIR/Expansion2.Civ5Pkg" "$BACKUP_DIR/Expansion2.Civ5Pkg.stock"
                log_info "Backed up Expansion2.Civ5Pkg"
            fi
        fi
    fi
}

# ----------------------------------------------------------------------
# Install components using 7z (safe for backslashes)
# ----------------------------------------------------------------------
install_components() {
    log_info "Installing components..."

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

    # Engine
    if [[ -n "$engine_path" ]]; then
        log_info "Installing engine fork..."
        extract_zip_safe "$engine_path" "$EXPANSION2_DIR"
    fi

    # Cinematics
    if [[ -n "$cinematics_path" ]]; then
        log_info "Installing cinematics..."
        extract_zip_safe "$cinematics_path" "$EXPANSION2_DIR"
    fi

    # Runtime (proxy)
    if [[ -n "$runtime_path" ]]; then
        log_info "Installing runtime proxy files..."
        extract_zip_safe "$runtime_path" "$GAME_ROOT"
    fi

    # Core DLC
    if [[ -n "$core_path" ]]; then
        log_info "Installing core DLC..."
        rm -rf "$MOD_DLC_DIR"
        mkdir -p "$MOD_DLC_DIR"
        extract_zip_safe "$core_path" "$MOD_DLC_DIR"
    fi

    # Overlays
    if [[ -n "$vp_overlay" ]]; then
        log_info "Installing Vox Populi overlay..."
        extract_zip_safe "$vp_overlay" "$MOD_DLC_DIR"
    fi
    if [[ -n "$cp_overlay" ]]; then
        log_info "Installing Community Patch overlay..."
        extract_zip_safe "$cp_overlay" "$MOD_DLC_DIR"
    fi
    if [[ -n "$lek_overlay" ]]; then
        log_info "Installing LekMod overlay..."
        extract_zip_safe "$lek_overlay" "$MOD_DLC_DIR"
    fi

    # Modpack packages
    if [[ -n "$vp_modpack" ]]; then
        log_info "Installing VP modpack package..."
        rm -rf "$ASSETS_DLC/ZCivVAccessVP"
        mkdir -p "$ASSETS_DLC/ZCivVAccessVP"
        extract_zip_safe "$vp_modpack" "$ASSETS_DLC/ZCivVAccessVP"
    fi
    if [[ -n "$cp_modpack" ]]; then
        log_info "Installing CP modpack package..."
        rm -rf "$ASSETS_DLC/ZCivVAccessCP"
        mkdir -p "$ASSETS_DLC/ZCivVAccessCP"
        extract_zip_safe "$cp_modpack" "$ASSETS_DLC/ZCivVAccessCP"
    fi

    # VP runtime (substrate) - routed extraction
    if [[ -n "$vp_runtime" ]]; then
        log_info "Installing VP runtime substrate..."
        mkdir -p "$CIV5_DOCS_DIR"
        local tmp_extract
        tmp_extract=$(mktemp -d)
        extract_zip_safe "$vp_runtime" "$tmp_extract"
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
        extract_zip_safe "$lekmod_dlc" "$tmp_extract"
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
# Write manifest
# ----------------------------------------------------------------------
write_manifest() {
    log_info "Writing install manifest..."
    local manifest_path="$MOD_DLC_DIR/CivVAccess.install.json"
    mkdir -p "$MOD_DLC_DIR"

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
        components_json+=$'\n        "'"$key"'": { "version": "'"$RELEASE_VERSION"'", "sha256": "'"$sha"'" }'
    done

    local backups_json='{
        "engine_dll": "Assets/DLC/DLC_CivVAccess.backup/CvGameCore_Expansion2.vanilla.dll",
        "cinematics": "Assets/DLC/DLC_CivVAccess.backup/cinematics",
        "lua51": "lua51_original.dll"
    }'
    if [[ "$SELECTED_STATE" == "voxpopuli" ]]; then
        backups_json=$(echo "$backups_json" | jq '. + {"civ5pkg": "Assets/DLC/DLC_CivVAccess.backup/Expansion2.Civ5Pkg.stock"}')
    fi

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
# Install
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

    if [[ -d "$ASSETS_DLC/ZCivVAccessVP" ]]; then
        rm -rf "$ASSETS_DLC/ZCivVAccessVP"
        log_info "Removed VP modpack"
    fi
    if [[ -d "$ASSETS_DLC/ZCivVAccessCP" ]]; then
        rm -rf "$ASSETS_DLC/ZCivVAccessCP"
        log_info "Removed CP modpack"
    fi
    if [[ -d "$ASSETS_DLC/LEKMOD" ]]; then
        rm -rf "$ASSETS_DLC/LEKMOD"
        log_info "Removed LekMod DLC"
    fi
    if [[ -d "$GAME_ROOT/Assets/Maps/Lekmap" ]]; then
        rm -rf "$GAME_ROOT/Assets/Maps/Lekmap"
        log_info "Removed Lekmap"
    fi

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

    if [[ -d "$MOD_DLC_DIR" ]]; then
        rm -rf "$MOD_DLC_DIR"
        log_info "Removed mod DLC"
    fi

    if [[ -f "$BACKUP_DIR/CvGameCore_Expansion2.vanilla.dll" ]]; then
        cp "$BACKUP_DIR/CvGameCore_Expansion2.vanilla.dll" "$EXPANSION2_DIR/CvGameCore_Expansion2.dll"
        log_info "Restored engine DLL"
    fi

    if [[ -d "$BACKUP_DIR/cinematics" ]]; then
        for f in Civ5XP2_Opening_Movie_en_US.wmv Civ5XP2_Opening_Movie_de_DE.wma Civ5XP2_Opening_Movie_es_ES.wma Civ5XP2_Opening_Movie_fr_FR.wma Civ5XP2_Opening_Movie_it_IT.wma Civ5XP2_Opening_Movie_pl_PL.wma Civ5XP2_Opening_Movie_ru_RU.wma; do
            if [[ -f "$BACKUP_DIR/cinematics/$f" ]]; then
                cp "$BACKUP_DIR/cinematics/$f" "$EXPANSION2_DIR/$f"
                log_info "Restored $f"
            fi
        done
    fi

    if [[ -d "$BACKUP_DIR" ]]; then
        rm -rf "$BACKUP_DIR"
        log_info "Removed backup directory"
    fi

    clear_dlc_cache

    echo "" >&2
    read -rp "Remove downloaded zip cache? (y/N): " rm_cache
    if [[ "$rm_cache" =~ ^[Yy]$ ]]; then
        rm -rf "$CACHE_DIR"
        log_info "Removed download cache"
    fi

    log_success "Uninstall completed."
}

# ----------------------------------------------------------------------
# Main menu - simple and accessible
# ----------------------------------------------------------------------
main_menu() {
    echo "" >&2
    echo "Civ V Access Installer version $SCRIPT_VERSION" >&2
    echo "1) Install" >&2
    echo "2) Uninstall" >&2
    echo "3) Exit" >&2
    read -rp "Choose an option [1-3]: " choice
    case "$choice" in
        1) do_install ;;
        2) do_uninstall ;;
        3) exit 0 ;;
        *) echo "Invalid choice." >&2; main_menu ;;
    esac
}

# ----------------------------------------------------------------------
# Entry point
# ----------------------------------------------------------------------
main_menu
