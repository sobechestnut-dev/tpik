#!/bin/bash

# Enhanced TMUX Session Picker with advanced features
# Version 2.0 - Exponentially Enhanced

# Colors & Styling
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
RESET='\033[0m'

# Configuration
CONFIG_DIR="$HOME/.config/tpik"
FAVORITES_FILE="$CONFIG_DIR/favorites"
TEMPLATES_FILE="$CONFIG_DIR/templates"
HISTORY_FILE="$CONFIG_DIR/history"
MAX_HISTORY=50

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR" 2>/dev/null
touch "$FAVORITES_FILE" "$TEMPLATES_FILE" "$HISTORY_FILE" 2>/dev/null

# Helper functions
get_session_info() {
    local session="$1"
    local created windows attached
    
    # Get session details with better error handling
    if session_data=$(tmux list-sessions -F "#{session_name}:#{session_created}:#{session_windows}:#{session_attached}" 2>/dev/null | grep "^$session:"); then
        IFS=':' read -r _ created windows attached <<< "$session_data"
        
        # Format creation time
        if command -v date >/dev/null 2>&1; then
            created_time=$(date -d "@$created" "+%m/%d %H:%M" 2>/dev/null || echo "unknown")
        else
            created_time="unknown"
        fi
        
        # Get window list preview
        local window_preview=""
        if windows_info=$(tmux list-windows -t "$session" -F "#{window_index}:#{window_name}" 2>/dev/null); then
            window_preview=$(echo "$windows_info" | head -3 | cut -d: -f2 | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')
            if [ $(echo "$windows_info" | wc -l) -gt 3 ]; then
                window_preview="$window_preview..."
            fi
        fi
        
        echo "$created_time|$windows|$attached|$window_preview"
    else
        echo "unknown|0|0|"
    fi
}

is_favorite() {
    grep -q "^$1$" "$FAVORITES_FILE" 2>/dev/null
}

add_to_history() {
    local session="$1"
    # Remove existing entry and add to top
    grep -v "^$session$" "$HISTORY_FILE" 2>/dev/null > "$HISTORY_FILE.tmp" || true
    echo "$session" > "$HISTORY_FILE.new"
    head -n $((MAX_HISTORY-1)) "$HISTORY_FILE.tmp" 2>/dev/null >> "$HISTORY_FILE.new" || true
    mv "$HISTORY_FILE.new" "$HISTORY_FILE" 2>/dev/null
    rm -f "$HISTORY_FILE.tmp" 2>/dev/null
}

show_header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    TMUX SESSION PICKER v2.0                 ║"
    if [ -n "$INSIDE_TMUX" ]; then
        printf "║                 ${YELLOW}Inside session: %-10s${CYAN}               ║\n" "$CURRENT_SESSION"
    else
        echo "║                      Enhanced Edition                        ║"
    fi
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    
    # Show tmux mode info
    if [ -n "$INSIDE_TMUX" ]; then
        echo -e "${BLUE}${BOLD}TMUX Mode:${RESET} ${YELLOW}Running inside session '$CURRENT_SESSION'${RESET}"
        echo -e "${DIM}• Use [d] to detach & reopen picker • [w] to switch sessions • [Enter] to stay${RESET}"
        echo
    fi
}

show_help() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                      HOTKEYS & HELP                         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    
    echo -e "\n${BOLD}${UNDERLINE}Session Navigation:${RESET}"
    echo -e "  ${CYAN}[1-9]${RESET}     Attach to session by number"
    echo -e "  ${CYAN}[Enter]${RESET}   Attach to first session (if available)"
    
    echo -e "\n${BOLD}${UNDERLINE}Session Management:${RESET}"
    echo -e "  ${CYAN}[n]${RESET}       Create new session (with custom directory)"
    echo -e "  ${CYAN}[c]${RESET}       Close/kill session"
    echo -e "  ${CYAN}[R]${RESET}       Rename session"
    echo -e "  ${CYAN}[s]${RESET}       Show detailed session info & windows"
    
    echo -e "\n${BOLD}${UNDERLINE}Filtering & Search:${RESET}"
    echo -e "  ${CYAN}[f]${RESET}       Toggle favorites filter (⭐)"
    echo -e "  ${CYAN}[r]${RESET}       Toggle recent sessions filter"
    echo -e "  ${CYAN}[/]${RESET}       Search sessions by name"
    echo -e "  ${CYAN}[x]${RESET}       Clear all active filters"
    
    echo -e "\n${BOLD}${UNDERLINE}Favorites & Templates:${RESET}"
    echo -e "  ${CYAN}[⭐]${RESET}       Toggle session as favorite"
    echo -e "  ${CYAN}[t]${RESET}       Create session from template"
    
    echo -e "\n${BOLD}${UNDERLINE}Session Status Indicators:${RESET}"
    echo -e "  ${YELLOW}⭐${RESET}        Favorited session"
    echo -e "  ${GREEN}●${RESET}         Currently attached session"
    echo -e "  ${GRAY}window1, window2${RESET} Preview of session windows"
    
    echo -e "\n${BOLD}${UNDERLINE}TMUX Integration:${RESET}"
    echo -e "  ${CYAN}[d]${RESET}       Detach & reopen picker (when inside tmux)"
    echo -e "  ${CYAN}[w]${RESET}       Native tmux session switcher (when inside tmux)"
    echo -e "  ${CYAN}[1-9]${RESET}     Switch sessions (when inside tmux) or attach (outside)"
    
    echo -e "\n${BOLD}${UNDERLINE}Navigation:${RESET}"
    echo -e "  ${CYAN}[h] [?]${RESET}   Show this help screen"
    echo -e "  ${CYAN}[q]${RESET}       Quit picker (returns to session if inside tmux)"
    
    echo -e "\n${BOLD}${UNDERLINE}Configuration Files:${RESET}"
    echo -e "  ${GRAY}~/.config/tpik/favorites${RESET}  - Starred sessions"
    echo -e "  ${GRAY}~/.config/tpik/history${RESET}    - Recent session history"
    echo -e "  ${GRAY}~/.config/tpik/templates${RESET}  - Session templates"
    
    echo -e "\n${BOLD}${UNDERLINE}Pro Tips:${RESET}"
    echo -e "  • Use ${CYAN}[f]${RESET} to quickly access your most-used sessions"
    echo -e "  • Create templates with ${CYAN}[t]${RESET} for consistent project setups"
    echo -e "  • Search with ${CYAN}[/]${RESET} to find sessions in large lists"
    echo -e "  • Session history automatically tracks your 50 most recent sessions"
    
    echo -e "\n${DIM}Press any key to return to main menu...${RESET}"
    read -n1
}

show_quick_help() {
    echo -e "${DIM}Quick: [1-9] attach [n] new [c] close [f] favorites [/] search [h] help [q] quit${RESET}"
}

# Check if tmux is installed and running
if ! command -v tmux &>/dev/null; then
    echo -e "${RED}Error: tmux is not installed.${RESET}"
    echo -e "${YELLOW}Install with: sudo apt install tmux${RESET}"
    exit 1
fi

# Check if we're inside a tmux session
INSIDE_TMUX=""
CURRENT_SESSION=""
if [ -n "$TMUX" ]; then
    INSIDE_TMUX="true"
    CURRENT_SESSION=$(tmux display-message -p '#S' 2>/dev/null)
fi

# Check if tmux server is running, start if needed
if ! tmux info &>/dev/null; then
    echo -e "${YELLOW}Starting tmux server...${RESET}"
    tmux new-session -d -s "__tpik_temp__" 2>/dev/null || true
    tmux kill-session -t "__tpik_temp__" 2>/dev/null || true
fi

# Enhanced main loop with filtering and search
filter_mode=""
search_term=""

while true; do
    show_header
    
    # Get all sessions with detailed info
    mapfile -t all_sessions < <(tmux list-sessions -F "#S" 2>/dev/null)
    declare -A session_details
    
    # Filter sessions based on current mode
    sessions=()
    case "$filter_mode" in
        "favorites")
            if [ -s "$FAVORITES_FILE" ]; then
                while IFS= read -r fav; do
                    for session in "${all_sessions[@]}"; do
                        if [ "$session" = "$fav" ]; then
                            sessions+=("$session")
                            break
                        fi
                    done
                done < "$FAVORITES_FILE"
            fi
            ;;
        "recent")
            if [ -s "$HISTORY_FILE" ]; then
                while IFS= read -r hist; do
                    for session in "${all_sessions[@]}"; do
                        if [ "$session" = "$hist" ]; then
                            sessions+=("$session")
                            break
                        fi
                    done
                done < "$HISTORY_FILE"
            fi
            ;;
        *)
            sessions=("${all_sessions[@]}")
            ;;
    esac
    
    # Apply search filter if active
    if [ -n "$search_term" ]; then
        filtered_sessions=()
        for session in "${sessions[@]}"; do
            if [[ "$session" == *"$search_term"* ]]; then
                filtered_sessions+=("$session")
            fi
        done
        sessions=("${filtered_sessions[@]}")
    fi
    
    # Get detailed info for filtered sessions
    for session in "${sessions[@]}"; do
        session_details["$session"]=$(get_session_info "$session")
    done
    
    # Display current filter status
    if [ -n "$filter_mode" ] || [ -n "$search_term" ]; then
        echo -e "${BLUE}${BOLD}Filter:${RESET}"
        [ -n "$filter_mode" ] && echo -e "  Mode: ${CYAN}$filter_mode${RESET}"
        [ -n "$search_term" ] && echo -e "  Search: ${CYAN}$search_term${RESET}"
        echo
    fi
    
    # Enhanced session display
    echo -e "${BOLD}Available tmux sessions (${#sessions[@]}/${#all_sessions[@]}):${RESET}"
    if [ ${#sessions[@]} -eq 0 ]; then
        if [ -n "$filter_mode" ] || [ -n "$search_term" ]; then
            echo -e "  ${YELLOW}(no sessions match current filter)${RESET}"
        else
            echo -e "  ${YELLOW}(no active sessions)${RESET}"
        fi
    else
        printf "${GRAY}%-4s %-20s %-8s %-5s %-6s %-s${RESET}\n" "[#]" "Session" "Created" "Win" "Att'd" "Windows"
        echo -e "${GRAY}────────────────────────────────────────────────────────────────${RESET}"
        
        for i in "${!sessions[@]}"; do
            local session="${sessions[$i]}"
            local info="${session_details[$session]}"
            IFS='|' read -r created windows attached window_preview <<< "$info"
            
            # Color coding based on status
            local session_color="$RESET"
            local status_indicator=""
            
            if is_favorite "$session"; then
                status_indicator="${YELLOW}⭐${RESET}"
            fi
            
            if [ "$attached" = "1" ]; then
                session_color="$GREEN"
                status_indicator="${status_indicator}${GREEN}●${RESET}"
            fi
            
            printf "${CYAN}[%2d]${RESET} ${session_color}%-18s${RESET} %s %-8s %-5s %-6s %s\n" \
                "$((i+1))" "$session" "$status_indicator" "$created" "$windows" "$attached" "${GRAY}$window_preview${RESET}"
        done
    fi
    
    # Enhanced options menu with tmux-aware help
    if [ -n "$INSIDE_TMUX" ]; then
        echo -e "\n${BOLD}TMUX Session Actions:${RESET}"
        echo -e "  ${CYAN}[1-9]${RESET} Switch to session    ${CYAN}[d]${RESET} Detach & reopen picker"
        echo -e "  ${CYAN}[w]${RESET}   Switch sessions      ${CYAN}[f]${RESET} Toggle favorites filter"
        echo -e "  ${CYAN}[n]${RESET}   New session         ${CYAN}[r]${RESET} Toggle recent filter"
        echo -e "  ${CYAN}[c]${RESET}   Close session       ${CYAN}[/]${RESET} Search sessions"
        echo -e "  ${CYAN}[s]${RESET}   Session details     ${CYAN}[x]${RESET} Clear filters"
        echo -e "  ${CYAN}[⭐]${RESET}   Toggle favorite     ${CYAN}[t]${RESET} Create from template"
        echo -e "  ${CYAN}[R]${RESET}   Rename session      ${CYAN}[h/?]${RESET} Help/Hotkeys"
        echo -e "  ${CYAN}[Enter]${RESET} Stay in current     ${CYAN}[q]${RESET} Quit to current session"
    else
        echo -e "\n${BOLD}Navigation & Actions:${RESET}"
        echo -e "  ${CYAN}[1-9]${RESET} Attach to session    ${CYAN}[f]${RESET} Toggle favorites filter"
        echo -e "  ${CYAN}[n]${RESET}   New session         ${CYAN}[r]${RESET} Toggle recent filter"
        echo -e "  ${CYAN}[c]${RESET}   Close session       ${CYAN}[/]${RESET} Search sessions"
        echo -e "  ${CYAN}[s]${RESET}   Session details     ${CYAN}[x]${RESET} Clear filters"
        echo -e "  ${CYAN}[⭐]${RESET}   Toggle favorite     ${CYAN}[t]${RESET} Create from template"
        echo -e "  ${CYAN}[R]${RESET}   Rename session      ${CYAN}[h/?]${RESET} Help/Hotkeys"
        echo -e "  ${CYAN}[Enter]${RESET} Quick attach (1st)  ${CYAN}[q]${RESET} Quit"
    fi
    
    # Quick help line
    echo
    if [ -n "$INSIDE_TMUX" ]; then
        echo -e "${DIM}Quick: [1-9] switch [d] detach&reopen [w] tmux-switch [n] new [q] back to session${RESET}"
    else
        show_quick_help
    fi
    
    read -n1 -p $'\nChoose an option: ' input
    echo

    case "$input" in
        [1-9])
            index=$((input - 1))
            if [ "$index" -ge 0 ] && [ "$index" -lt "${#sessions[@]}" ]; then
                selected="${sessions[$index]}"
                add_to_history "$selected"
                
                if [ -n "$INSIDE_TMUX" ]; then
                    # Switch sessions within tmux
                    if [ "$selected" = "$CURRENT_SESSION" ]; then
                        echo -e "${YELLOW}Already in session '$selected'.${RESET}"
                        sleep 1
                    else
                        echo -e "${GREEN}Switching to session '${selected}'...${RESET}"
                        sleep 0.3
                        tmux switch-client -t "$selected"
                        break
                    fi
                else
                    # Regular attach from outside tmux
                    echo -e "${GREEN}Attaching to session '${selected}'...${RESET}"
                    sleep 0.3
                    tmux attach-session -t "$selected"
                    break
                fi
            else
                echo -e "${RED}Invalid selection.${RESET}"
                sleep 1
            fi
            ;;
        "")
            # Enter key behavior changes based on context
            if [ -n "$INSIDE_TMUX" ]; then
                # Stay in current session
                echo -e "${CYAN}Staying in current session '$CURRENT_SESSION'.${RESET}"
                break
            else
                # Quick attach to first session
                if [ ${#sessions[@]} -gt 0 ]; then
                    selected="${sessions[0]}"
                    add_to_history "$selected"
                    echo -e "${GREEN}Quick attaching to '${selected}'...${RESET}"
                    sleep 0.3
                    tmux attach-session -t "$selected"
                    break
                else
                    echo -e "${YELLOW}No sessions available for quick attach.${RESET}"
                    sleep 1
                fi
            fi
            ;;
        d|D)
            # Detach and reopen picker (only works inside tmux)
            if [ -n "$INSIDE_TMUX" ]; then
                echo -e "${GREEN}Detaching and reopening picker...${RESET}"
                sleep 0.3
                # Detach from current session and restart the picker
                tmux detach-client
                # The script will restart outside tmux context
                exec "$0" "$@"
            else
                echo -e "${YELLOW}Detach only available when inside tmux.${RESET}"
                sleep 1
            fi
            ;;
        w|W)
            # Native tmux session switcher (only works inside tmux)
            if [ -n "$INSIDE_TMUX" ]; then
                echo -e "${GREEN}Opening tmux session switcher...${RESET}"
                sleep 0.3
                tmux choose-tree -s
                break
            else
                echo -e "${YELLOW}Tmux switcher only available when inside tmux.${RESET}"
                sleep 1
            fi
            ;;
        h|H|\?)
            show_help
            ;;
        n|N)
            echo -e "\n${BOLD}Create New Session:${RESET}"
            read -p "Enter session name: " new_session
            if [ -n "$new_session" ]; then
                read -p "Start in directory [$(pwd)]: " start_dir
                start_dir=${start_dir:-$(pwd)}
                
                if [ -d "$start_dir" ]; then
                    echo -e "${GREEN}Creating session '${new_session}' in $start_dir...${RESET}"
                    sleep 0.3
                    cd "$start_dir" && tmux new-session -s "$new_session"
                    break
                else
                    echo -e "${RED}Directory $start_dir does not exist.${RESET}"
                    sleep 1
                fi
            else
                echo -e "${RED}Session name cannot be empty.${RESET}"
                sleep 1
            fi
            ;;
        c|C)
            if [ ${#sessions[@]} -eq 0 ]; then
                echo -e "${YELLOW}No sessions to close.${RESET}"
                sleep 1
            else
                echo -e "\n${BOLD}Close Session:${RESET}"
                read -p "Enter session number to close: " killnum
                killindex=$((killnum - 1))
                if [[ "$killnum" =~ ^[0-9]+$ ]] && [ "$killindex" -ge 0 ] && [ "$killindex" -lt "${#sessions[@]}" ]; then
                    killname="${sessions[$killindex]}"
                    read -p "Close session '$killname'? (y/N): " confirm
                    if [[ "$confirm" =~ ^[Yy]$ ]]; then
                        tmux kill-session -t "$killname" 2>/dev/null
                        echo -e "${GREEN}Session '$killname' closed.${RESET}"
                        # Remove from favorites if it was favorited
                        grep -v "^$killname$" "$FAVORITES_FILE" 2>/dev/null > "$FAVORITES_FILE.tmp" || true
                        mv "$FAVORITES_FILE.tmp" "$FAVORITES_FILE" 2>/dev/null
                    else
                        echo -e "${YELLOW}Cancelled.${RESET}"
                    fi
                    sleep 1
                else
                    echo -e "${RED}Invalid session number.${RESET}"
                    sleep 1
                fi
            fi
            ;;
        s|S)
            if [ ${#sessions[@]} -eq 0 ]; then
                echo -e "${YELLOW}No sessions available.${RESET}"
                sleep 1
            else
                echo -e "\n${BOLD}Session Details:${RESET}"
                read -p "Enter session number for details: " detailnum
                detailindex=$((detailnum - 1))
                if [[ "$detailnum" =~ ^[0-9]+$ ]] && [ "$detailindex" -ge 0 ] && [ "$detailindex" -lt "${#sessions[@]}" ]; then
                    detail_session="${sessions[$detailindex]}"
                    echo -e "\n${CYAN}${BOLD}Session: $detail_session${RESET}"
                    echo -e "${GRAY}────────────────────────────${RESET}"
                    
                    # Show detailed session info
                    if session_info=$(tmux list-sessions -F "#{session_name}:#{session_created}:#{session_windows}:#{session_attached}:#{session_activity}" 2>/dev/null | grep "^$detail_session:"); then
                        IFS=':' read -r _ created windows attached activity <<< "$session_info"
                        
                        if command -v date >/dev/null 2>&1; then
                            created_full=$(date -d "@$created" 2>/dev/null || echo "unknown")
                            activity_full=$(date -d "@$activity" 2>/dev/null || echo "unknown")
                        else
                            created_full="unknown"
                            activity_full="unknown"
                        fi
                        
                        echo -e "Created: $created_full"
                        echo -e "Windows: $windows"
                        echo -e "Attached: $([ "$attached" = "1" ] && echo "Yes" || echo "No")"
                        echo -e "Activity: $activity_full"
                        
                        # Show windows
                        echo -e "\n${BOLD}Windows:${RESET}"
                        tmux list-windows -t "$detail_session" -F "  [#{window_index}] #{window_name} #{?window_active,(active),}" 2>/dev/null || echo "  (unable to get window info)"
                    fi
                    
                    echo -e "\nPress any key to continue..."
                    read -n1
                else
                    echo -e "${RED}Invalid session number.${RESET}"
                    sleep 1
                fi
            fi
            ;;
        ⭐)
            if [ ${#sessions[@]} -eq 0 ]; then
                echo -e "${YELLOW}No sessions available.${RESET}"
                sleep 1
            else
                echo -e "\n${BOLD}Toggle Favorite:${RESET}"
                read -p "Enter session number: " favnum
                favindex=$((favnum - 1))
                if [[ "$favnum" =~ ^[0-9]+$ ]] && [ "$favindex" -ge 0 ] && [ "$favindex" -lt "${#sessions[@]}" ]; then
                    fav_session="${sessions[$favindex]}"
                    if is_favorite "$fav_session"; then
                        grep -v "^$fav_session$" "$FAVORITES_FILE" > "$FAVORITES_FILE.tmp" 2>/dev/null || true
                        mv "$FAVORITES_FILE.tmp" "$FAVORITES_FILE"
                        echo -e "${YELLOW}Removed '$fav_session' from favorites.${RESET}"
                    else
                        echo "$fav_session" >> "$FAVORITES_FILE"
                        echo -e "${GREEN}Added '$fav_session' to favorites.${RESET}"
                    fi
                    sleep 1
                else
                    echo -e "${RED}Invalid session number.${RESET}"
                    sleep 1
                fi
            fi
            ;;
        R)
            if [ ${#sessions[@]} -eq 0 ]; then
                echo -e "${YELLOW}No sessions available.${RESET}"
                sleep 1
            else
                echo -e "\n${BOLD}Rename Session:${RESET}"
                read -p "Enter session number to rename: " renamenum
                renameindex=$((renamenum - 1))
                if [[ "$renamenum" =~ ^[0-9]+$ ]] && [ "$renameindex" -ge 0 ] && [ "$renameindex" -lt "${#sessions[@]}" ]; then
                    old_name="${sessions[$renameindex]}"
                    read -p "Enter new name for '$old_name': " new_name
                    if [ -n "$new_name" ] && [ "$new_name" != "$old_name" ]; then
                        if tmux rename-session -t "$old_name" "$new_name" 2>/dev/null; then
                            echo -e "${GREEN}Session renamed from '$old_name' to '$new_name'.${RESET}"
                            # Update favorites if needed
                            if is_favorite "$old_name"; then
                                grep -v "^$old_name$" "$FAVORITES_FILE" > "$FAVORITES_FILE.tmp" 2>/dev/null || true
                                echo "$new_name" >> "$FAVORITES_FILE.tmp"
                                mv "$FAVORITES_FILE.tmp" "$FAVORITES_FILE"
                            fi
                        else
                            echo -e "${RED}Failed to rename session. Name might already exist.${RESET}"
                        fi
                    else
                        echo -e "${YELLOW}Cancelled or invalid name.${RESET}"
                    fi
                    sleep 1
                else
                    echo -e "${RED}Invalid session number.${RESET}"
                    sleep 1
                fi
            fi
            ;;
        f|F)
            if [ "$filter_mode" = "favorites" ]; then
                filter_mode=""
                echo -e "${YELLOW}Favorites filter disabled.${RESET}"
            else
                filter_mode="favorites"
                echo -e "${GREEN}Showing only favorite sessions.${RESET}"
            fi
            sleep 0.5
            ;;
        r)
            if [ "$filter_mode" = "recent" ]; then
                filter_mode=""
                echo -e "${YELLOW}Recent filter disabled.${RESET}"
            else
                filter_mode="recent"
                echo -e "${GREEN}Showing recently used sessions.${RESET}"
            fi
            sleep 0.5
            ;;
        /)
            echo -e "\n${BOLD}Search Sessions:${RESET}"
            read -p "Enter search term (empty to clear): " new_search
            search_term="$new_search"
            if [ -n "$search_term" ]; then
                echo -e "${GREEN}Searching for sessions containing '$search_term'...${RESET}"
            else
                echo -e "${YELLOW}Search cleared.${RESET}"
            fi
            sleep 0.5
            ;;
        x|X)
            filter_mode=""
            search_term=""
            echo -e "${GREEN}All filters cleared.${RESET}"
            sleep 0.5
            ;;
        t|T)
            echo -e "\n${BOLD}Create from Template:${RESET}"
            if [ -s "$TEMPLATES_FILE" ]; then
                echo "Available templates:"
                cat -n "$TEMPLATES_FILE"
                read -p "Enter template number or 'n' for new template: " template_choice
                
                if [ "$template_choice" = "n" ] || [ "$template_choice" = "N" ]; then
                    read -p "Template name: " template_name
                    read -p "Base directory: " template_dir
                    read -p "Initial command (optional): " template_cmd
                    echo "$template_name|$template_dir|$template_cmd" >> "$TEMPLATES_FILE"
                    echo -e "${GREEN}Template saved.${RESET}"
                elif [[ "$template_choice" =~ ^[0-9]+$ ]]; then
                    template_line=$(sed -n "${template_choice}p" "$TEMPLATES_FILE" 2>/dev/null)
                    if [ -n "$template_line" ]; then
                        IFS='|' read -r tmpl_name tmpl_dir tmpl_cmd <<< "$template_line"
                        read -p "Session name [$tmpl_name]: " session_name
                        session_name=${session_name:-$tmpl_name}
                        
                        if [ -d "$tmpl_dir" ]; then
                            cd "$tmpl_dir"
                            if [ -n "$tmpl_cmd" ]; then
                                tmux new-session -d -s "$session_name" "$tmpl_cmd"
                                tmux attach-session -t "$session_name"
                            else
                                tmux new-session -s "$session_name"
                            fi
                            break
                        else
                            echo -e "${RED}Template directory $tmpl_dir does not exist.${RESET}"
                        fi
                    else
                        echo -e "${RED}Invalid template number.${RESET}"
                    fi
                fi
            else
                read -p "No templates found. Create one? (y/N): " create_template
                if [[ "$create_template" =~ ^[Yy]$ ]]; then
                    read -p "Template name: " template_name
                    read -p "Base directory: " template_dir
                    read -p "Initial command (optional): " template_cmd
                    echo "$template_name|$template_dir|$template_cmd" >> "$TEMPLATES_FILE"
                    echo -e "${GREEN}Template saved.${RESET}"
                fi
            fi
            sleep 1
            ;;
        q|Q)
            if [ -n "$INSIDE_TMUX" ]; then
                echo -e "${CYAN}Returning to session '$CURRENT_SESSION'...${RESET}"
                break
            else
                echo -e "${CYAN}Thanks for using Enhanced TMUX Picker!${RESET}"
                exit 0
            fi
            ;;
        *)
            echo -e "${RED}Invalid input. Please select a valid option.${RESET}"
            sleep 0.5
            ;;
    esac
done