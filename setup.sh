#!/usr/bin/env bash
#
# setup.sh - v8: Selective and scalable installer for the tool suite.
# Installs all or selected tools from the 'tools/' directory or root.

set -eo pipefail

# --- Configuration & Colors ---
# Handle case when script is piped from curl (BASH_SOURCE may be unbound)
if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ -f "${BASH_SOURCE[0]}" ]]; then
    SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
else
    # Fallback for piped execution - use current directory
    SCRIPT_DIR="${PWD:-$(pwd)}"
fi
BIN_DIR="/usr/local/bin"
MAN_DIR="/usr/share/man/man1"
TOOLS_DIR="$SCRIPT_DIR/tools"
MAN_PAGES_DIR="$SCRIPT_DIR/man"
# Support ipcheck in root directory as well
IPCHECK_SCRIPT="$SCRIPT_DIR/ipcheck"
# Flag to track if we downloaded ipcheck
DOWNLOADED_IPCHECK=false

# Using tput for better compatibility
if [[ -t 1 ]]; then
    GREEN=$(tput setaf 2)
    RED=$(tput setaf 1)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    NC=$(tput sgr0) # No Color
else
    GREEN="" RED="" YELLOW="" BLUE="" NC=""
fi

CONFIG_FILE_PATH_FOR_ROLLBACK=""
NON_INTERACTIVE=false  # Auto-install dependencies without prompting

# --- Helper Functions ---

# Triggered on any error during installation to clean up created files.
installation_rollback() {
    echo -e "\n${RED}❌ An error occurred during installation. Rolling back changes...${NC}"
    # This function should remove any files created by the do_install function
    # For simplicity, we assume we need to check for all possible tools
    if [ -d "$TOOLS_DIR" ]; then
        for tool_path in "$TOOLS_DIR"/*; do
            local tool_name
            tool_name=$(basename "$tool_path")
            rm -f "$BIN_DIR/$tool_name"
            rm -f "$MAN_DIR/$tool_name.1.gz"
        done
    fi
    if [[ -n "$CONFIG_FILE_PATH_FOR_ROLLBACK" ]]; then
        rm -f "$CONFIG_FILE_PATH_FOR_ROLLBACK"
    fi
    echo -e "${RED}↩️  Rollback complete. System is clean.${NC}"
    exit 1
}

# Checks for dependencies and offers to install them if missing.
check_dependencies() {
    echo -e "${BLUE}--- STEP 1: Checking Dependencies ---${NC}"
    local missing_deps=()
    local required_cmds=("curl" "jq")

    for cmd in "${required_cmds[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            echo -e "   ${YELLOW}⚠️  Dependency '$cmd' is missing.${NC}"
            missing_deps+=("$cmd")
        else
            echo -e "   ${GREEN}✅  Found '$cmd'.${NC}"
        fi
    done

    if [ ${#missing_deps[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ All dependencies are satisfied.${NC}"
        return 0
    fi

    # Auto-install if non-interactive mode or stdin is not a terminal
    local auto_install=false
    # Check if we're in non-interactive mode (piped input, CI, or -y flag)
    if [[ "$NON_INTERACTIVE" == "true" ]] || [[ ! -t 0 ]] || [[ -p /dev/stdin ]]; then
        auto_install=true
        echo -e "${BLUE}Auto-installing missing dependencies...${NC}"
    else
        # Try to read from user, but if it fails (non-interactive), auto-install
        if ! read -t 5 -p "Do you want to try to install missing dependencies automatically? (y/n) " -n 1 -r 2>/dev/null; then
            auto_install=true
            echo -e "\n${BLUE}Auto-installing missing dependencies (non-interactive mode detected)...${NC}"
        else
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                auto_install=true
            else
                echo -e "${RED}🛑 Installation aborted. Please install dependencies manually.${NC}"
                exit 1
            fi
        fi
    fi

    if [[ "$auto_install" != "true" ]]; then
        return 1
    fi

    # Detect OS and install dependencies
    local os_id=""
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        os_id="${ID:-}"
    fi

    echo -e "${BLUE}Detected OS: ${os_id:-unknown}${NC}"
    
    case "${os_id}" in
    ubuntu | debian | mint)
        echo -e "${BLUE}Installing ${missing_deps[*]} using apt-get...${NC}"
        apt-get update -qq && apt-get install -y "${missing_deps[@]}" || {
            echo -e "${RED}❌ Failed to install dependencies. Please install manually: ${missing_deps[*]}${NC}"
            exit 1
        }
        ;;
    fedora | centos | rhel)
        echo -e "${BLUE}Installing ${missing_deps[*]} using package manager...${NC}"
        if command -v dnf &>/dev/null; then
            dnf install -y "${missing_deps[@]}" || {
                echo -e "${RED}❌ Failed to install dependencies. Please install manually: ${missing_deps[*]}${NC}"
                exit 1
            }
        elif command -v yum &>/dev/null; then
            yum install -y "${missing_deps[@]}" || {
                echo -e "${RED}❌ Failed to install dependencies. Please install manually: ${missing_deps[*]}${NC}"
                exit 1
            }
        else
            echo -e "${RED}❌ No package manager found (dnf/yum). Please install manually: ${missing_deps[*]}${NC}"
            exit 1
        fi
        ;;
    arch)
        echo -e "${BLUE}Installing ${missing_deps[*]} using pacman...${NC}"
        pacman -Syu --noconfirm "${missing_deps[@]}" || {
            echo -e "${RED}❌ Failed to install dependencies. Please install manually: ${missing_deps[*]}${NC}"
            exit 1
        }
        ;;
    *)
        echo -e "${RED}❌ Unsupported OS (${os_id:-unknown}). Please install manually: ${missing_deps[*]}${NC}"
        echo -e "${YELLOW}You can install jq manually using your package manager.${NC}"
        exit 1
        ;;
    esac
    
    echo -e "${GREEN}✅ Dependencies installed successfully.${NC}"
}

# Interactively prompts the user for API keys.
prompt_and_save_keys() {
    echo -e "\n${BLUE}--- STEP 2: API Key Configuration ---${NC}"
    MISSING_KEYS_RESULT=()
    local all_keys_info=(
        "IPQS_KEY|https://www.ipqualityscore.com/"
        "ABUSEIPDB_KEY|https://www.abuseipdb.com/account"
        "RIPE_KEY|https://atlas.ripe.net/apply/"
        "HT_KEY|https://hosttracker.com/"
        "IPREGISTRY_KEY|https://ipregistry.co/ (optional)"
    )

    read -p "Do you want to configure API keys now? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        for key_info in "${all_keys_info[@]}"; do MISSING_KEYS_RESULT+=("$key_info"); done
        return
    fi

    local USER_HOME
    USER_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)
    local CONFIG_DIR="$USER_HOME/.config/ipcheck"
    CONFIG_FILE_PATH_FOR_ROLLBACK="$CONFIG_DIR/keys.conf"

    mkdir -p "$CONFIG_DIR"
    >"$CONFIG_FILE_PATH_FOR_ROLLBACK"

    for key_info in "${all_keys_info[@]}"; do
        local key_name="${key_info%|*}"
        read -p "Enter your ${YELLOW}${key_name}${NC} (optional, press Enter to skip): " key_value
        if [[ -z "$key_value" ]]; then
            MISSING_KEYS_RESULT+=("$key_info")
        else
            # Basic validation: non-empty and reasonable length
            if [[ ${#key_value} -lt 5 ]] || [[ ${#key_value} -gt 200 ]]; then
                echo -e "${YELLOW}Warning: Key length seems invalid. Skipping.${NC}"
                MISSING_KEYS_RESULT+=("$key_info")
            else
                echo "${key_name}=\"${key_value}\"" >>"$CONFIG_FILE_PATH_FOR_ROLLBACK"
            fi
        fi
    done

    if [[ -n "${SUDO_USER}" ]]; then chown -R "$SUDO_USER":"$(id -g -n "$SUDO_USER")" "$CONFIG_DIR"; fi
    # Set secure permissions on config file
    chmod 600 "$CONFIG_FILE_PATH_FOR_ROLLBACK"
}

# Shows a final warning if some API keys were not set.
show_post_install_warnings() {
    if [ ${#MISSING_KEYS_RESULT[@]} -eq 0 ]; then return; fi

    echo -e "\n${YELLOW}------------------------- ATTENTION -------------------------${NC}"
    echo -e "${YELLOW}Some API keys were not provided. Some tools may have limited functionality.${NC}"
    echo -e "Please edit the configuration file at: ${BLUE}$CONFIG_FILE_PATH_FOR_ROLLBACK${NC}"
    echo -e "\nYou are missing the following keys:"
    for key_info in "${MISSING_KEYS_RESULT[@]}"; do
        local key_name="${key_info%|*}"
        local key_url="${key_info#*|}"
        echo -e "  - ${RED}${key_name}${NC}: Get your key from ${BLUE}${key_url}${NC}"
    done
    echo -e "${YELLOW}-------------------------------------------------------------${NC}"
}

# --- Main Logic Functions ---

do_install() {
    local tools_to_install=("$@")
    if [ ${#tools_to_install[@]} -eq 0 ]; then
        echo -e "${BLUE}No specific tools requested. Preparing to install all available tools...${NC}"
        # Check for ipcheck in root
        if [[ -f "$IPCHECK_SCRIPT" ]] && [[ -x "$IPCHECK_SCRIPT" ]]; then
            tools_to_install+=("ipcheck")
        else
            # If ipcheck not found locally, download from GitHub
            echo -e "${YELLOW}ipcheck not found locally. Downloading from GitHub...${NC}"
            local temp_dir
            temp_dir=$(mktemp -d)
            trap "rm -rf '$temp_dir'" EXIT
            
            if curl -fsSL "https://raw.githubusercontent.com/amirmm4d/ipcheck/main/ipcheck" -o "$temp_dir/ipcheck" 2>/dev/null; then
                chmod +x "$temp_dir/ipcheck"
                IPCHECK_SCRIPT="$temp_dir/ipcheck"
                DOWNLOADED_IPCHECK=true
                tools_to_install+=("ipcheck")
                echo -e "${GREEN}✓ Downloaded ipcheck${NC}"
            else
                echo -e "${RED}Error: Failed to download ipcheck from GitHub.${NC}" >&2
                echo -e "${YELLOW}Please make sure you have internet connection and the repository is accessible.${NC}" >&2
                exit 1
            fi
        fi
        # Check for tools in tools/ directory
        if [ -d "$TOOLS_DIR" ]; then
            for tool_path in "$TOOLS_DIR"/*; do
                if [ -f "$tool_path" ] && [ -x "$tool_path" ]; then
                    tools_to_install+=("$(basename "$tool_path")")
                fi
            done
        fi
    fi

    if [ ${#tools_to_install[@]} -eq 0 ]; then
        echo -e "${RED}Error: No executable tools found.${NC}"
        exit 1
    fi

    echo -e "${GREEN}The following tools will be installed: ${YELLOW}${tools_to_install[*]}${NC}"

    trap 'installation_rollback' ERR
    check_dependencies
    prompt_and_save_keys

    echo -e "\n${BLUE}--- Installing Files ---${NC}"
    
    # Handle ipcheck in root directory
    if [[ " ${tools_to_install[*]} " =~ " ipcheck " ]] && [[ -f "$IPCHECK_SCRIPT" ]]; then
        echo -e "  ➡️  Installing script '${YELLOW}ipcheck${NC}'..."
        install -m 755 "$IPCHECK_SCRIPT" "$BIN_DIR/ipcheck"
        local man_page_path="$MAN_PAGES_DIR/ipcheck.1"
        if [ -f "$man_page_path" ]; then
            echo -e "  ➡️  Installing man page for '${YELLOW}ipcheck${NC}'..."
            install -Dm 644 "$man_page_path" "$MAN_DIR/ipcheck.1"
            gzip -f "$MAN_DIR/ipcheck.1"
        else
            # Try to download man page from GitHub if not found locally
            echo -e "  ➡️  Downloading man page for '${YELLOW}ipcheck${NC}' from GitHub..."
            local temp_man
            temp_man=$(mktemp)
            if curl -fsSL "https://raw.githubusercontent.com/amirmm4d/ipcheck/main/man/ipcheck.1" -o "$temp_man" 2>/dev/null; then
                install -Dm 644 "$temp_man" "$MAN_DIR/ipcheck.1"
                gzip -f "$MAN_DIR/ipcheck.1"
                rm -f "$temp_man"
                echo -e "${GREEN}✓ Man page installed${NC}"
            else
                echo -e "${YELLOW}⚠️  Could not download man page (optional)${NC}"
            fi
        fi
    fi
    
    # Handle tools in tools/ directory
    for tool_name in "${tools_to_install[@]}"; do
        # Skip ipcheck if already handled
        [[ "$tool_name" == "ipcheck" ]] && continue
        
        local tool_path="$TOOLS_DIR/$tool_name"
        if [ ! -f "$tool_path" ]; then
            echo -e "${YELLOW}Warning: Tool '$tool_name' not found. Skipping.${NC}"
            continue
        fi

        echo -e "  ➡️  Installing script '${YELLOW}$tool_name${NC}'..."
        install -m 755 "$tool_path" "$BIN_DIR/$tool_name"

        local man_page_path="$MAN_PAGES_DIR/$tool_name.1"
        if [ -f "$man_page_path" ]; then
            echo -e "  ➡️  Installing man page for '${YELLOW}$tool_name${NC}'..."
            install -Dm 644 "$man_page_path" "$MAN_DIR/$tool_name.1"
            gzip -f "$MAN_DIR/$tool_name.1"
        fi
    done

    echo -e "  🔄 Updating man page database..."
    mandb -q || true
    trap - ERR

    echo -e "\n${GREEN}🎉 Installation Complete! 🎉${NC}"
    show_post_install_warnings
    echo -e "\n${BLUE}================================================================${NC}"
    echo -e "${GREEN}This tool was developed with ❤️ by amirmm4d from Iran 🇮🇷${NC}"
    echo -e "${BLUE}================================================================${NC}"
}

do_uninstall() {
    local tools_to_uninstall=("$@")
    if [ ${#tools_to_uninstall[@]} -eq 0 ]; then
        # Include ipcheck from root
        if [[ -f "$IPCHECK_SCRIPT" ]]; then
            tools_to_uninstall+=("ipcheck")
        fi
        # Include tools from tools/ directory
        if [ -d "$TOOLS_DIR" ]; then
            for tool_path in "$TOOLS_DIR"/*; do
                if [ -f "$tool_path" ]; then tools_to_uninstall+=("$(basename "$tool_path")"); fi
            done
        fi
    fi

    echo -e "${RED}The following tools will be uninstalled: ${YELLOW}${tools_to_uninstall[*]}${NC}"
    read -p "Are you sure you want to continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Uninstall cancelled."
        exit 0
    fi

    for tool_name in "${tools_to_uninstall[@]}"; do
        echo -e "   - Removing '$BIN_DIR/$tool_name' and its man page."
        rm -f "$BIN_DIR/$tool_name"
        rm -f "$MAN_DIR/$tool_name.1.gz"
    done

    echo -e "🔄  Updating man page database..."
    mandb -q || true
    echo -e "${GREEN}✅ Uninstallation complete.${NC}"
    echo -e "Note: The configuration file was ${YELLOW}not${NC} removed to preserve your keys."
    echo -e "🗑️  Removing the installer script itself..."
    (sleep 1 && rm -f "$0") &
}

# --- Script Entry Point ---
main() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}❌ This script must be run as root. Please use 'sudo $0'${NC}"
        exit 1
    fi

    local action="install"
    local tools_arg=""

    # Argument parsing that handles `uninstall`, `--tools`, `-y`, `--yes` in any order
    local params=()
    while (("$#")); do
        case "$1" in
        uninstall)
            action="uninstall"
            shift
            ;;
        --tools)
            if [ -n "$2" ]; then
                tools_arg=$2
                shift 2
            else
                echo "${RED}Error: --tools flag requires an argument.${NC}" >&2
                exit 1
            fi
            ;;
        -y|--yes)
            NON_INTERACTIVE=true
            shift
            ;;
        -*) # unsupported flags
            echo "${RED}Error: Unsupported flag $1${NC}" >&2
            exit 1
            ;;
        *) # preserve positional arguments
            params+=("$1")
            shift
            ;;
        esac
    done
    # set positional arguments in their proper place
    eval set -- "${params[@]}"

    local -a tools_array
    if [[ -n "$tools_arg" ]]; then
        IFS=',' read -ra tools_array <<<"$tools_arg"
    fi

    if [[ "$action" == "install" ]]; then
        do_install "${tools_array[@]}"
    else
        do_uninstall "${tools_array[@]}"
    fi
}

main "$@"
