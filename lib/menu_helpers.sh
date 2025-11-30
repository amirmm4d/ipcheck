# --- Menu Helper Functions ---
# Functions to create menus using different tools (fzf, dialog, whiptail, or fallback)

# Show menu using fzf
show_menu_fzf() {
    local title="$1"
    shift
    local menu_items=("$@")
    
    local selected
    selected=$(printf '%s\n' "${menu_items[@]}" | \
        fzf --height=10 --reverse --border \
        --header="$title" \
        --prompt="👉 Select > " \
        --pointer="▶" 2>/dev/null || echo "")
    
    echo "$selected"
}

# Show menu using dialog
show_menu_dialog() {
    local title="$1"
    shift
    local menu_items=("$@")
    
    # Build dialog menu items (tag item description)
    local dialog_items=()
    local i=1
    for item in "${menu_items[@]}"; do
        dialog_items+=("$i" "$item")
        ((i++))
    done
    
    local choice
    choice=$(dialog --clear --stdout \
        --title "$title" \
        --menu "Select an option:" \
        15 70 10 \
        "${dialog_items[@]}" 2>/dev/null || echo "")
    
    if [[ -n "$choice" ]] && [[ "$choice" =~ ^[0-9]+$ ]]; then
        # Return the selected item text
        local idx=$((choice-1))
        if [[ $idx -ge 0 ]] && [[ $idx -lt ${#menu_items[@]} ]]; then
            echo "${menu_items[$idx]}"
        fi
    fi
}

# Show menu using whiptail
show_menu_whiptail() {
    local title="$1"
    shift
    local menu_items=("$@")
    
    # Build whiptail menu items (tag item description)
    local whiptail_items=()
    local i=1
    for item in "${menu_items[@]}"; do
        whiptail_items+=("$i" "$item")
        ((i++))
    done
    
    local choice
    choice=$(whiptail --clear --stdout \
        --title "$title" \
        --menu "Select an option:" \
        15 70 10 \
        "${whiptail_items[@]}" 2>/dev/null || echo "")
    
    if [[ -n "$choice" ]] && [[ "$choice" =~ ^[0-9]+$ ]]; then
        # Return the selected item text
        local idx=$((choice-1))
        if [[ $idx -ge 0 ]] && [[ $idx -lt ${#menu_items[@]} ]]; then
            echo "${menu_items[$idx]}"
        fi
    fi
}

# Show multi-select menu using fzf
show_multi_menu_fzf() {
    local title="$1"
    shift
    local menu_items=("$@")
    
    local selected_items
    selected_items=$(printf '%s\n' "${menu_items[@]}" | \
        fzf --multi --height=20 --reverse --border \
        --header="$title (Space to select, Enter to confirm)" \
        --prompt="Options > " \
        --pointer="▶" \
        --marker="✓ " 2>/dev/null || echo "")
    
    echo "$selected_items"
}

# Show multi-select menu using dialog (checklist)
show_multi_menu_dialog() {
    local title="$1"
    shift
    local menu_items=("$@")
    
    # Build dialog checklist items (tag item status description)
    # Skip section headers for dialog (they don't work well)
    local dialog_items=()
    local item_indices=()  # Track original indices
    local i=0
    local dialog_index=1
    for item in "${menu_items[@]}"; do
        # Skip section headers
        if [[ ! "$item" =~ ^━━━ ]]; then
            dialog_items+=("$dialog_index" "$item" "off")
            item_indices+=("$i")
            ((dialog_index++))
        fi
        ((i++))
    done
    
    if [[ ${#dialog_items[@]} -eq 0 ]]; then
        echo ""
        return
    fi
    
    local choices
    choices=$(dialog --clear --stdout \
        --title "$title" \
        --checklist "Select options (Space to toggle, Tab to move, Enter to confirm):" \
        20 70 15 \
        "${dialog_items[@]}" 2>/dev/null || echo "")
    
    if [[ -n "$choices" ]]; then
        # Return selected items using original indices
        local selected_text=""
        for choice in $choices; do
            local orig_idx="${item_indices[$((choice-1))]}"
            selected_text+="${menu_items[$orig_idx]}"$'\n'
        done
        echo "$selected_text"
    fi
}

# Show multi-select menu using whiptail (checklist)
show_multi_menu_whiptail() {
    local title="$1"
    shift
    local menu_items=("$@")
    
    # Build whiptail checklist items (tag item status description)
    # Skip section headers for whiptail (they don't work well)
    local whiptail_items=()
    local item_indices=()  # Track original indices
    local i=0
    local whiptail_index=1
    for item in "${menu_items[@]}"; do
        # Skip section headers
        if [[ ! "$item" =~ ^━━━ ]]; then
            whiptail_items+=("$whiptail_index" "$item" "OFF")
            item_indices+=("$i")
            ((whiptail_index++))
        fi
        ((i++))
    done
    
    if [[ ${#whiptail_items[@]} -eq 0 ]]; then
        echo ""
        return
    fi
    
    local choices
    choices=$(whiptail --clear --stdout \
        --title "$title" \
        --checklist "Select options (Space to toggle, Tab to move, Enter to confirm):" \
        20 70 15 \
        "${whiptail_items[@]}" 2>/dev/null || echo "")
    
    if [[ -n "$choices" ]]; then
        # Return selected items using original indices
        local selected_text=""
        for choice in $choices; do
            local orig_idx="${item_indices[$((choice-1))]}"
            selected_text+="${menu_items[$orig_idx]}"$'\n'
        done
        echo "$selected_text"
    fi
}

# Universal menu function that auto-detects best tool
show_menu() {
    local title="$1"
    shift
    local menu_items=("$@")
    
    local tool
    tool=$(detect_menu_tool)
    
    case "$tool" in
        fzf)
            show_menu_fzf "$title" "${menu_items[@]}"
            ;;
        dialog)
            show_menu_dialog "$title" "${menu_items[@]}"
            ;;
        whiptail)
            show_menu_whiptail "$title" "${menu_items[@]}"
            ;;
        *)
            # Fallback: return first item or empty
            echo ""
            ;;
    esac
}

# Universal multi-select menu function
show_multi_menu() {
    local title="$1"
    shift
    local menu_items=("$@")
    
    local tool
    tool=$(detect_menu_tool)
    
    case "$tool" in
        fzf)
            show_multi_menu_fzf "$title" "${menu_items[@]}"
            ;;
        dialog)
            show_multi_menu_dialog "$title" "${menu_items[@]}"
            ;;
        whiptail)
            show_multi_menu_whiptail "$title" "${menu_items[@]}"
            ;;
        *)
            # Fallback: return empty
            echo ""
            ;;
    esac
}
