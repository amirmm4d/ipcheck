# --- Menu Helper Functions ---
# Functions to create menus using dialog

# Show single-select menu using dialog
show_menu() {
    local title="$1"
    shift
    local menu_items=("$@")
    
    # Check if dialog is available
    if ! command -v dialog &>/dev/null; then
        echo ""
        return 1
    fi
    
    # Check if we have a terminal
    local has_terminal=false
    if [[ -t 1 ]] && [[ -t 0 ]]; then
        has_terminal=true
    elif [[ -c /dev/tty ]] && [[ -r /dev/tty ]] && [[ -w /dev/tty ]]; then
        has_terminal=true
    fi
    
    if [[ "$has_terminal" == "false" ]]; then
        echo ""
        return 1
    fi
    
    # Build dialog menu items (tag item description)
    local dialog_items=()
    local i=1
    for item in "${menu_items[@]}"; do
        dialog_items+=("$i" "$item")
        ((i++))
    done
    
    local choice
    # Use /dev/tty if available for better sudo compatibility
    if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
        choice=$(dialog --clear --stdout \
            --title "$title" \
            --menu "📌 Use ↑↓ arrows to navigate, ENTER to select\n   از فلش‌های بالا/پایین برای حرکت، Enter برای انتخاب\n\nSelect an option / انتخاب گزینه:" \
            15 70 10 \
            "${dialog_items[@]}" < /dev/tty 2>/dev/tty || echo "")
    else
        choice=$(dialog --clear --stdout \
            --title "$title" \
            --menu "📌 Use ↑↓ arrows to navigate, ENTER to select\n   از فلش‌های بالا/پایین برای حرکت، Enter برای انتخاب\n\nSelect an option / انتخاب گزینه:" \
            15 70 10 \
            "${dialog_items[@]}" 2>/dev/null || echo "")
    fi
    
    if [[ -n "$choice" ]] && [[ "$choice" =~ ^[0-9]+$ ]]; then
        # Return the selected item text
        local idx=$((choice-1))
        if [[ $idx -ge 0 ]] && [[ $idx -lt ${#menu_items[@]} ]]; then
            echo "${menu_items[$idx]}"
        fi
    fi
}

# Show multi-select menu using dialog (checklist)
show_multi_menu() {
    local title="$1"
    shift
    local menu_items=("$@")
    
    # Check if dialog is available
    if ! command -v dialog &>/dev/null; then
        echo ""
        return 1
    fi
    
    # Build dialog checklist items (tag item status description)
    # Skip section headers for dialog
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
        return 1
    fi
    
    # Check if we have a terminal
    local has_terminal=false
    if [[ -t 1 ]] && [[ -t 0 ]]; then
        has_terminal=true
    elif [[ -c /dev/tty ]] && [[ -r /dev/tty ]] && [[ -w /dev/tty ]]; then
        has_terminal=true
    fi
    
    if [[ "$has_terminal" == "false" ]]; then
        echo ""
        return 1
    fi
    
    local choices
    # Use /dev/tty if available for better sudo compatibility
    if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
        choices=$(dialog --clear --stdout \
            --title "$title" \
            --checklist "📌 Instructions / راهنما:\n   • Use ↑↓ arrows to navigate / از فلش‌ها استفاده کنید\n   • Press SPACE to select/deselect / Space برای انتخاب\n   • Press TAB to move between buttons / Tab برای جابجایی\n   • Press ENTER to confirm / Enter برای تأیید\n\nSelect options / انتخاب گزینه‌ها:" \
            25 75 15 \
            "${dialog_items[@]}" < /dev/tty 2>/dev/tty || echo "")
    else
        choices=$(dialog --clear --stdout \
            --title "$title" \
            --checklist "📌 Instructions / راهنما:\n   • Use ↑↓ arrows to navigate / از فلش‌ها استفاده کنید\n   • Press SPACE to select/deselect / Space برای انتخاب\n   • Press TAB to move between buttons / Tab برای جابجایی\n   • Press ENTER to confirm / Enter برای تأیید\n\nSelect options / انتخاب گزینه‌ها:" \
            25 75 15 \
            "${dialog_items[@]}" 2>/dev/null || echo "")
    fi
    
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

# Show input dialog for text input
show_input_dialog() {
    local title="$1"
    local prompt="$2"
    local default_value="${3:-}"
    
    # Check if dialog is available
    if ! command -v dialog &>/dev/null; then
        echo ""
        return 1
    fi
    
    # Check if we have a terminal
    local has_terminal=false
    if [[ -t 1 ]] && [[ -t 0 ]]; then
        has_terminal=true
    elif [[ -c /dev/tty ]] && [[ -r /dev/tty ]] && [[ -w /dev/tty ]]; then
        has_terminal=true
    fi
    
    if [[ "$has_terminal" == "false" ]]; then
        echo ""
        return 1
    fi
    
    local input
    if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
        input=$(dialog --clear --stdout \
            --title "$title" \
            --inputbox "$prompt" \
            10 60 \
            "$default_value" < /dev/tty 2>/dev/tty || echo "")
    else
        input=$(dialog --clear --stdout \
            --title "$title" \
            --inputbox "$prompt" \
            10 60 \
            "$default_value" 2>/dev/null || echo "")
    fi
    
    echo "$input"
}

# Show file selection dialog
show_file_dialog() {
    local title="$1"
    local start_dir="${2:-.}"
    
    # Check if dialog is available
    if ! command -v dialog &>/dev/null; then
        echo ""
        return 1
    fi
    
    # Check if we have a terminal
    local has_terminal=false
    if [[ -t 1 ]] && [[ -t 0 ]]; then
        has_terminal=true
    elif [[ -c /dev/tty ]] && [[ -r /dev/tty ]] && [[ -w /dev/tty ]]; then
        has_terminal=true
    fi
    
    if [[ "$has_terminal" == "false" ]]; then
        echo ""
        return 1
    fi
    
    local file_path
    if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
        file_path=$(dialog --clear --stdout \
            --title "$title" \
            --fselect "$start_dir" \
            20 70 < /dev/tty 2>/dev/tty || echo "")
    else
        file_path=$(dialog --clear --stdout \
            --title "$title" \
            --fselect "$start_dir" \
            20 70 2>/dev/null || echo "")
    fi
    
    echo "$file_path"
}
