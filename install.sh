#!/bin/bash

# tpik - Enhanced TMUX Session Picker
# Installation Script
# Author: Nathaniel "Sobe" Chestnut

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Configuration
INSTALL_DIR="$HOME/scripts"
SCRIPT_NAME="tpik.sh"
SCRIPT_URL="https://raw.githubusercontent.com/sobechestnut-dev/tpik/main/scripts/tpik.sh"
ALIAS_NAME="tp"

echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    tpik Installer v2.0                      ║"
echo "║              Enhanced TMUX Session Picker                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# Check dependencies
echo -e "${BOLD}Checking dependencies...${RESET}"

if ! command -v tmux &> /dev/null; then
    echo -e "${RED}❌ tmux is not installed${RESET}"
    echo -e "${YELLOW}Install tmux first:${RESET}"
    echo "  Ubuntu/Debian: sudo apt install tmux"
    echo "  macOS: brew install tmux"
    echo "  CentOS/RHEL: sudo yum install tmux"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo -e "${RED}❌ curl is not installed${RESET}"
    echo -e "${YELLOW}Install curl first:${RESET}"
    echo "  Ubuntu/Debian: sudo apt install curl"
    echo "  macOS: brew install curl"
    echo "  CentOS/RHEL: sudo yum install curl"
    exit 1
fi

echo -e "${GREEN}✅ Dependencies satisfied${RESET}"

# Create installation directory
echo -e "${BOLD}Setting up installation directory...${RESET}"
mkdir -p "$INSTALL_DIR"

# Download the script
echo -e "${BOLD}Downloading tpik script...${RESET}"
if curl -sSL "$SCRIPT_URL" -o "$INSTALL_DIR/$SCRIPT_NAME"; then
    echo -e "${GREEN}✅ Downloaded successfully${RESET}"
else
    echo -e "${RED}❌ Failed to download script${RESET}"
    echo "URL: $SCRIPT_URL"
    exit 1
fi

# Make executable
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
echo -e "${GREEN}✅ Made script executable${RESET}"

# Detect shell and config file
SHELL_CONFIG=""
CURRENT_SHELL=$(basename "$SHELL")

case "$CURRENT_SHELL" in
    bash)
        if [ -f "$HOME/.bashrc" ]; then
            SHELL_CONFIG="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            SHELL_CONFIG="$HOME/.bash_profile"
        fi
        ;;
    zsh)
        SHELL_CONFIG="$HOME/.zshrc"
        ;;
    fish)
        SHELL_CONFIG="$HOME/.config/fish/config.fish"
        ;;
    *)
        echo -e "${YELLOW}⚠️  Unknown shell: $CURRENT_SHELL${RESET}"
        ;;
esac

# Add alias
if [ -n "$SHELL_CONFIG" ] && [ -f "$SHELL_CONFIG" ]; then
    echo -e "${BOLD}Setting up alias...${RESET}"
    
    # Check if alias already exists
    if grep -q "alias $ALIAS_NAME=" "$SHELL_CONFIG" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Alias '$ALIAS_NAME' already exists in $SHELL_CONFIG${RESET}"
        echo -e "${YELLOW}   You may need to manually update it to: alias $ALIAS_NAME=\"$INSTALL_DIR/$SCRIPT_NAME\"${RESET}"
    else
        echo "alias $ALIAS_NAME=\"$INSTALL_DIR/$SCRIPT_NAME\"" >> "$SHELL_CONFIG"
        echo -e "${GREEN}✅ Added alias '$ALIAS_NAME' to $SHELL_CONFIG${RESET}"
    fi
else
    echo -e "${YELLOW}⚠️  Could not automatically add alias${RESET}"
    echo -e "${YELLOW}   Please manually add this line to your shell config:${RESET}"
    echo -e "${CYAN}   alias $ALIAS_NAME=\"$INSTALL_DIR/$SCRIPT_NAME\"${RESET}"
fi

# Create config directory
CONFIG_DIR="$HOME/.config/tpik"
mkdir -p "$CONFIG_DIR"
echo -e "${GREEN}✅ Created configuration directory: $CONFIG_DIR${RESET}"

# Installation complete
echo -e "\n${GREEN}${BOLD}🎉 Installation Complete!${RESET}"
echo -e "\n${BOLD}Usage:${RESET}"
echo -e "  ${CYAN}$ALIAS_NAME${RESET}                    # Launch tpik (after restarting shell)"
echo -e "  ${CYAN}$INSTALL_DIR/$SCRIPT_NAME${RESET}      # Direct execution"

echo -e "\n${BOLD}Next Steps:${RESET}"
echo -e "  1. ${YELLOW}Restart your terminal or run:${RESET} source $SHELL_CONFIG"
echo -e "  2. ${YELLOW}Run:${RESET} $ALIAS_NAME"
echo -e "  3. ${YELLOW}Press [h] for help and hotkey reference${RESET}"

echo -e "\n${BOLD}Features:${RESET}"
echo -e "  • Session favorites (⭐) and history tracking"
echo -e "  • Session templates for consistent project setups"
echo -e "  • Live search and filtering"
echo -e "  • Smart tmux integration (works inside sessions)"
echo -e "  • Rich visual interface with status indicators"

echo -e "\n${BOLD}Configuration:${RESET}"
echo -e "  • Config files: ${GRAY}$CONFIG_DIR/${RESET}"
echo -e "  • Favorites: ${GRAY}$CONFIG_DIR/favorites${RESET}"
echo -e "  • Templates: ${GRAY}$CONFIG_DIR/templates${RESET}"
echo -e "  • History: ${GRAY}$CONFIG_DIR/history${RESET}"

echo -e "\n${CYAN}${BOLD}Thanks for installing tpik! 🚀${RESET}"
echo -e "${DIM}GitHub: https://github.com/sobechestnut-dev/tpik${RESET}"