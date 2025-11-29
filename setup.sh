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

# Helper function to expand ~ and ./ in paths correctly
expand_user_path() {
    local path="$1"
    local USER_HOME
    USER_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)
    
    # Replace ~ with actual user home directory (not root's home)
    if [[ "$path" == ~/* ]] || [[ "$path" == "~" ]]; then
        path="${path/#\~/$USER_HOME}"
    fi
    
    # Replace ./ with current working directory (where script is running)
    if [[ "$path" == ./* ]]; then
        local current_dir
        current_dir=$(pwd)
        path="${path/#\./$current_dir}"
    elif [[ "$path" == . ]]; then
        path=$(pwd)
    fi
    
    # Resolve absolute path
    if [[ "$path" != /* ]]; then
        # Relative path - make it absolute from current directory
        local dir_part file_part
        dir_part=$(dirname "$path")
        file_part=$(basename "$path")
        if [[ "$dir_part" == "." ]]; then
            dir_part=$(pwd)
        else
            dir_part=$(cd "$dir_part" 2>/dev/null && pwd) || dir_part="$(pwd)/$dir_part"
        fi
        path="$dir_part/$file_part"
    else
        # Absolute path - resolve it
        local dir_part file_part
        dir_part=$(dirname "$path")
        file_part=$(basename "$path")
        dir_part=$(cd "$dir_part" 2>/dev/null && pwd) || dir_part="$dir_part"
        path="$dir_part/$file_part"
    fi
    
    echo "$path"
}

# Interactively prompts the user for API keys.
prompt_and_save_keys() {
    echo -e "\n${BLUE}--- STEP 2: API Key Configuration ---${NC}"
    MISSING_KEYS_RESULT=()
    
    # Define all API keys with their descriptions and URLs
    local all_keys_info=(
        "IPQS_KEY|IPQualityScore API Key|https://www.ipqualityscore.com/documentation/account/api-key|Required for IP reputation checks"
        "ABUSEIPDB_KEY|AbuseIPDB API Key|https://www.abuseipdb.com/account/api|Required for abuse database checks"
        "RIPE_KEY|RIPE Atlas API Key|https://atlas.ripe.net/apply/|Required for RIPE Atlas probe checks"
        "HT_KEY|HostTracker API Key|https://hosttracker.com/|Optional - for HostTracker checks"
        "IPREGISTRY_KEY|ipregistry.io API Key|https://ipregistry.co/|Optional - free tier available for enhanced scoring"
    )

    # Ask user for config file path
    local USER_HOME
    USER_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)
    local default_config_dir="$USER_HOME/.config/ipcheck"
    local default_config_file="$default_config_dir/keys.conf"
    
    echo -e "${YELLOW}Where would you like to save the API keys configuration file?${NC}"
    echo -e "Default: ${BLUE}$default_config_file${NC}"
    
    local custom_path=""
    # Try to read from terminal if we're not in non-interactive mode
    if [[ "$NON_INTERACTIVE" != "true" ]]; then
        echo -ne "${YELLOW}Enter custom path (or press Enter for default): ${NC}"
        # Force read from /dev/tty to ensure we get user input
        if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
            exec 3< /dev/tty
            read -r custom_path <&3
            exec 3<&-
        elif [[ -t 0 ]]; then
            read -r custom_path
        else
            # Fallback: try stdin anyway
            read -r custom_path || custom_path=""
        fi
        # Trim whitespace
        custom_path=$(echo "$custom_path" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    else
        echo -e "${BLUE}Using default path (non-interactive mode)${NC}"
    fi
    
    local CONFIG_FILE_PATH
    if [[ -z "$custom_path" ]]; then
        CONFIG_FILE_PATH="$default_config_file"
        else
            # Expand ~ and ./ correctly, then resolve path
            CONFIG_FILE_PATH=$(expand_user_path "$custom_path")
            # If it's a directory, append keys.conf (remove trailing slash first)
            if [[ -d "$CONFIG_FILE_PATH" ]]; then
                CONFIG_FILE_PATH="${CONFIG_FILE_PATH%/}/keys.conf"
            fi
        fi
    
    CONFIG_FILE_PATH_FOR_ROLLBACK="$CONFIG_FILE_PATH"
    local CONFIG_DIR
    CONFIG_DIR=$(dirname "$CONFIG_FILE_PATH")
    
    # Create directory if it doesn't exist
    mkdir -p "$CONFIG_DIR"
    
    # Create config file with header and documentation
    {
        echo "# IPCheck API Keys Configuration File"
        echo "# Generated on: $(date)"
        echo "#"
        echo "# This file contains API keys for various IP intelligence services."
        echo "# Each key is optional, but some features require specific keys."
        echo "#"
        echo "# IMPORTANT: Keep this file secure! It contains sensitive API keys."
        echo "# File permissions are automatically set to 600 (read/write for owner only)."
        echo "#"
        echo ""
        echo "# =========================================="
        echo "# API Keys Configuration"
        echo "# =========================================="
        echo ""
        
        # Add documentation for each API key
        for key_info in "${all_keys_info[@]}"; do
            local key_name="${key_info%%|*}"
            local key_desc="${key_info#*|}"
            key_desc="${key_desc%%|*}"
            local rest_info="${key_info#*|}"
            rest_info="${rest_info#*|}"  # Remove key_desc
            local key_url="${rest_info%%|*}"  # Get URL (before the last |)
            local key_required="${key_info##*|}"  # Get text after last |
            
            echo "# --- $key_name ---"
            echo "# Description: $key_desc"
            echo "# Website: $key_url"
            echo "# Get your API key from: $key_url"
            if [[ -n "$key_required" ]] && [[ "$key_required" != "$key_url" ]]; then
                echo "# Status: $key_required"
            fi
            echo "#"
            echo "# $key_name=\"your_api_key_here\""
            echo ""
        done
        
        echo "# =========================================="
        echo "# End of Documentation"
        echo "# =========================================="
        echo ""
        echo "# Uncomment and fill in your API keys below:"
        echo ""
        
    } > "$CONFIG_FILE_PATH"
    
    # Ask user if they want to configure keys now
    if [[ "$NON_INTERACTIVE" != "true" ]] && [[ -t 0 ]]; then
    read -p "Do you want to configure API keys now? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Configuration file created at: ${BLUE}$CONFIG_FILE_PATH${NC}"
            echo -e "${YELLOW}You can edit it later to add your API keys.${NC}"
            for key_info in "${all_keys_info[@]}"; do MISSING_KEYS_RESULT+=("$key_info"); done
            if [[ -n "${SUDO_USER}" ]]; then chown -R "$SUDO_USER":"$(id -g -n "$SUDO_USER")" "$CONFIG_DIR"; fi
            chmod 600 "$CONFIG_FILE_PATH"
            return
        fi
    else
        echo -e "${YELLOW}Non-interactive mode: Configuration file created with documentation.${NC}"
        echo -e "${YELLOW}Please edit the file manually at: ${BLUE}$CONFIG_FILE_PATH${NC}"
        for key_info in "${all_keys_info[@]}"; do MISSING_KEYS_RESULT+=("$key_info"); done
        if [[ -n "${SUDO_USER}" ]]; then chown -R "$SUDO_USER":"$(id -g -n "$SUDO_USER")" "$CONFIG_DIR"; fi
        chmod 600 "$CONFIG_FILE_PATH"
        return
    fi

    # Interactive key configuration
    echo -e "${BLUE}Enter your API keys (press Enter to skip optional keys):${NC}"
    echo ""

    for key_info in "${all_keys_info[@]}"; do
        local key_name="${key_info%%|*}"
        local key_desc="${key_info#*|}"
        key_desc="${key_desc%%|*}"
        local key_url="${key_info##*|}"
        local key_url_clean="${key_url%% *}"
        
        echo -e "${YELLOW}$key_name${NC} - $key_desc"
        echo -e "  Get it from: ${BLUE}$key_url_clean${NC}"
        read -p "  Enter your API key (or press Enter to skip): " key_value
        
        if [[ -z "$key_value" ]]; then
            MISSING_KEYS_RESULT+=("$key_info")
            echo "# $key_name=\"\"" >> "$CONFIG_FILE_PATH"
        else
            # Basic validation: non-empty and reasonable length
            if [[ ${#key_value} -lt 5 ]] || [[ ${#key_value} -gt 200 ]]; then
                echo -e "${YELLOW}  Warning: Key length seems invalid. Skipping.${NC}"
                MISSING_KEYS_RESULT+=("$key_info")
                echo "# $key_name=\"\"" >> "$CONFIG_FILE_PATH"
            else
                echo "$key_name=\"$key_value\"" >> "$CONFIG_FILE_PATH"
                echo -e "${GREEN}  ✓ Key saved${NC}"
            fi
        fi
        echo ""
    done

    if [[ -n "${SUDO_USER}" ]]; then chown -R "$SUDO_USER":"$(id -g -n "$SUDO_USER")" "$CONFIG_DIR"; fi
    # Set secure permissions on config file
    chmod 600 "$CONFIG_FILE_PATH"
    
    echo -e "${GREEN}✅ Configuration file created at: ${BLUE}$CONFIG_FILE_PATH${NC}"
}

# Shows a final warning if some API keys were not set.
show_post_install_warnings() {
    if [ ${#MISSING_KEYS_RESULT[@]} -eq 0 ]; then 
        echo -e "\n${GREEN}✅ All API keys are configured. Ready to use!${NC}"
        return
    fi

    echo -e "\n${YELLOW}------------------------- ATTENTION -------------------------${NC}"
    echo -e "${YELLOW}Some API keys were not provided. Some tools may have limited functionality.${NC}"
    
    # Use the config file path that was already set during installation, or ask user
    local USER_HOME
    USER_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)
    local default_config_file="$USER_HOME/.config/ipcheck/keys.conf"
    
    local config_to_check=""
    local check_existing=false
    
    # If CONFIG_FILE_PATH_FOR_ROLLBACK is set, use it (from prompt_and_save_keys)
    if [[ -n "$CONFIG_FILE_PATH_FOR_ROLLBACK" ]] && [[ -f "$CONFIG_FILE_PATH_FOR_ROLLBACK" ]]; then
        config_to_check="$CONFIG_FILE_PATH_FOR_ROLLBACK"
        check_existing=true
        echo -e "\n${BLUE}Checking the configuration file that was just created: ${config_to_check}${NC}"
    else
        # Ask user if they want to check an existing config file
        if [[ "$NON_INTERACTIVE" != "true" ]]; then
            echo -e "\n${BLUE}Do you want to check an existing configuration file?${NC}"
            echo -e "Default: ${BLUE}$default_config_file${NC}"
            echo -ne "${YELLOW}Enter custom path (or press Enter for default, 'skip' to skip): ${NC}"
            
            # Force read from /dev/tty to ensure we get user input
            local custom_check_path=""
            if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
                exec 3< /dev/tty
                read -r custom_check_path <&3
                exec 3<&-
            elif [[ -t 0 ]]; then
                read -r custom_check_path
            else
                # Fallback: try stdin anyway
                read -r custom_check_path || custom_check_path=""
            fi
            
            # Trim whitespace
            custom_check_path=$(echo "$custom_check_path" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            
            if [[ -z "$custom_check_path" ]] || [[ "$custom_check_path" == "" ]]; then
                config_to_check="$default_config_file"
                check_existing=true
                echo -e "${GREEN}✓ Using default path: ${config_to_check}${NC}"
            elif [[ "$custom_check_path" == "skip" ]] || [[ "$custom_check_path" == "Skip" ]] || [[ "$custom_check_path" == "SKIP" ]]; then
                check_existing=false
                echo -e "${YELLOW}⊘ Skipping config file check.${NC}"
            else
                # Expand ~ and ./ correctly, then resolve path
                config_to_check=$(expand_user_path "$custom_check_path")
                # If it's a directory, append keys.conf (remove trailing slash first)
                if [[ -d "$config_to_check" ]]; then
                    config_to_check="${config_to_check%/}/keys.conf"
                fi
                check_existing=true
                echo -e "${BLUE}✓ Using custom path: ${config_to_check}${NC}"
            fi
        else
            # Non-interactive mode, use default
            echo -e "${BLUE}Non-interactive mode: Using default path${NC}"
            config_to_check="$default_config_file"
            check_existing=true
        fi
    fi
    
    # Check the config file if requested
    if [[ "$check_existing" == "true" ]] && [[ -f "$config_to_check" ]]; then
            echo -e "${BLUE}Checking configuration file: ${config_to_check}${NC}"
            
            # Source the config file to check for keys
            local found_keys=0
            local missing_keys_list=()
            
            # Read and parse the config file
            if [[ -r "$config_to_check" ]]; then
                # Check each missing key by reading from file
                for key_info in "${MISSING_KEYS_RESULT[@]}"; do
                    local key_name="${key_info%%|*}"
                    # Extract key value from config file (ignore comments and empty lines)
                    local key_line
                    key_line=$(grep -E "^[[:space:]]*${key_name}[[:space:]]*=" "$config_to_check" 2>/dev/null | head -1)
                    
                    if [[ -n "$key_line" ]]; then
                        # Extract value (remove key name, =, quotes, and whitespace)
                        local key_value
                        key_value=$(echo "$key_line" | sed -E "s/^[[:space:]]*${key_name}[[:space:]]*=[[:space:]]*//" | sed -E 's/^["'\''](.*)["'\'']$/\1/' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                        
                        # Check if key value is valid (not empty, not just quotes, reasonable length)
                        if [[ -n "$key_value" ]] && [[ "$key_value" != "" ]] && [[ ${#key_value} -ge 5 ]] && [[ ${#key_value} -le 200 ]]; then
                            ((found_keys++))
                        else
                            missing_keys_list+=("$key_info")
                        fi
                    else
                        missing_keys_list+=("$key_info")
                    fi
                done
                
                if [[ $found_keys -eq ${#MISSING_KEYS_RESULT[@]} ]]; then
                    echo -e "${GREEN}✅ All API keys found in configuration file!${NC}"
                    echo -e "${GREEN}✅ Configuration is complete and ready to use!${NC}"
                    MISSING_KEYS_RESULT=()  # Clear missing keys
                    return
                elif [[ $found_keys -gt 0 ]]; then
                    echo -e "${YELLOW}Found $found_keys out of ${#MISSING_KEYS_RESULT[@]} API keys in configuration file.${NC}"
                    MISSING_KEYS_RESULT=("${missing_keys_list[@]}")  # Update missing keys list
                else
                    echo -e "${YELLOW}No API keys found in configuration file.${NC}"
                fi
            else
                echo -e "${RED}Error: Cannot read configuration file: ${config_to_check}${NC}"
            fi
        elif [[ "$check_existing" == "true" ]]; then
            echo -e "${YELLOW}Configuration file not found: ${config_to_check}${NC}"
        fi
    
    # Show missing keys
    if [ ${#MISSING_KEYS_RESULT[@]} -gt 0 ]; then
        echo -e "\n${YELLOW}You are missing the following keys:${NC}"
    for key_info in "${MISSING_KEYS_RESULT[@]}"; do
            local key_name="${key_info%%|*}"
            local key_desc="${key_info#*|}"
            key_desc="${key_desc%%|*}"
            local key_url="${key_info##*|}"
            local key_url_clean="${key_url%% *}"  # Remove any trailing text
            
            echo -e "  - ${RED}${key_name}${NC} (${key_desc})"
            echo -e "    Get your key from: ${BLUE}${key_url_clean}${NC}"
        done
        echo -e "\nPlease edit the configuration file at: ${BLUE}${CONFIG_FILE_PATH_FOR_ROLLBACK:-$default_config_file}${NC}"
    fi
    
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
