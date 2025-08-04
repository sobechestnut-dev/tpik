TMUX Picker Script - Technical Implementation Guide

� Overview

This Bash script is a terminal-based utility to visually select, create, or close active tmux sessions using a keyboard-driven menu. It’s designed for quick access, minimal typing, and enhanced usability from the command line.


---

� File Structure

Recommended location:

~/scripts/tmux-picker.sh

Permissions:

chmod +x ~/scripts/tmux-picker.sh

Alias configuration (e.g., in .bashrc or .basic):

alias tp='~/scripts/tmux-picker.sh'


---

⚙️ Dependencies

tmux: Terminal multiplexer

bash: POSIX-compliant shell (for associative arrays, string manipulation, ANSI color support)

ANSI color support in terminal



---

� Script Logic Breakdown

1. Header and Styling Setup

Defines ANSI escape codes for color formatting.

Clears screen and prints stylized ASCII header.


RED='\033[0;31m'
CYAN='\033[0;36m'
echo -e "${CYAN}${BOLD}"
echo "╔═══ ... ═══╗"
...


---

2. Check for tmux Installation

if ! command -v tmux &>/dev/null; then
    echo -e "${RED}Error: tmux not installed${RESET}"
    exit 1
fi


---

3. Get Active Sessions

Uses tmux list-sessions with format #S (session name only), parsed into an indexed array.

mapfile -t sessions < <(tmux list-sessions -F "#S" 2>/dev/null)


---

4. Display Menu Options

Enumerates all sessions with numeric selection and adds key options:

1, 2, 3, etc. to attach to a session

n to create a new session

c followed by number to close a session

q to quit


Example:

[1] dev
[2] logs
[n] New Session
[c] Close Session (press then session number)
[q] Quit


---

5. New Session Handling

If user presses n, prompt for session name and create new tmux session:

read -p "Enter new session name: " name
if [ -n "$name" ]; then
  tmux new-session -s "$name"
fi


---

6. Close Session Handling

If user presses c, prompt for session number to close:

read -p "Session number to close: " num
session_to_kill="${sessions[$((num-1))]}"
tmux kill-session -t "$session_to_kill"


---

7. Attach to Session

On number key press, validate index and attach:

tmux attach-session -t "${sessions[$index]}"


---

� Performance and UX Enhancements

Immediate visual feedback

Keyboard-friendly

Action hints with color and keybindings



---

� Future Extensions (Optional)

Feature	Tool/Dependency	Benefit

Fuzzy select	fzf	Search/filter session list
Arrow keys	select, read	Navigate list interactively
UI dialog	dialog, whiptail	Popup-based selection UI
Mouse support	dialog	Clickable tmux menu



---

� Troubleshooting

Problem	Solution

tmux not found error	Install tmux with sudo apt install tmux
Nothing happens after pressing key	Ensure Num Lock is on and terminal supports input
Script not found	Check file path and permissions



---

✍️ Author

Script & Documentation By: Nathaniel "Sobe" Chestnut
Designed for practical tmux workflows and visual accessibility.


