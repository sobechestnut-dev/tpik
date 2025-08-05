#!/bin/bash

# tpik Manual Installer - Mobile-Friendly
# Simple commands for manual installation without curl piping

set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}"
echo "╔════════════════════════════════════════════╗"
echo "║         tpik Manual Installation           ║"
echo "║            Mobile-Friendly                 ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BOLD}Step 1: Install Dependencies${NC}"
echo -e "${YELLOW}Copy and paste these commands one by one:${NC}"
echo
echo -e "${CYAN}# Install Python virtual environment support${NC}"
echo "sudo apt install python3-venv"
echo
echo -e "${CYAN}# Install tmux if not already installed${NC}"
echo "sudo apt install tmux"
echo

echo -e "${BOLD}Step 2: Create Installation Directory${NC}"
echo -e "${CYAN}mkdir -p ~/.local/bin${NC}"
echo

echo -e "${BOLD}Step 3: Create Virtual Environment${NC}"
echo -e "${CYAN}python3 -m venv ~/.local/share/tpik${NC}"
echo

echo -e "${BOLD}Step 4: Activate Virtual Environment${NC}"
echo -e "${CYAN}source ~/.local/share/tpik/bin/activate${NC}"
echo

echo -e "${BOLD}Step 5: Install Dependencies${NC}"
echo -e "${CYAN}pip install textual rich${NC}"
echo

echo -e "${BOLD}Step 6: Clone Repository${NC}"
echo -e "${CYAN}cd /tmp${NC}"
echo -e "${CYAN}git clone https://github.com/sobechestnut-dev/tpik.git${NC}"
echo -e "${CYAN}cd tpik${NC}"
echo

echo -e "${BOLD}Step 7: Install tpik${NC}"
echo -e "${CYAN}pip install -e .${NC}"
echo

echo -e "${BOLD}Step 8: Create Wrapper Script${NC}"
echo -e "${CYAN}cat > ~/.local/bin/tpik << 'EOF'${NC}"
echo "#!/bin/bash"
echo 'exec "$HOME/.local/share/tpik/bin/python" -m tpik.app "$@"'
echo "EOF"
echo

echo -e "${BOLD}Step 9: Make Executable${NC}"
echo -e "${CYAN}chmod +x ~/.local/bin/tpik${NC}"
echo

echo -e "${BOLD}Step 10: Add to PATH and Create Alias${NC}"
echo -e "${CYAN}echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc${NC}"
echo -e "${CYAN}echo 'alias tp=\"tpik\"' >> ~/.bashrc${NC}"
echo

echo -e "${BOLD}Step 11: Reload Shell${NC}"
echo -e "${CYAN}source ~/.bashrc${NC}"
echo

echo -e "${BOLD}Step 12: Test Installation${NC}"
echo -e "${CYAN}tp${NC}"
echo

echo -e "${GREEN}${BOLD}Done!${NC}"
echo -e "You can now use ${CYAN}tp${NC} or ${CYAN}tpik${NC} to launch the TUI!"
echo

echo -e "${YELLOW}Note: If any step fails, you can run the automatic installer:${NC}"
echo -e "${CYAN}curl -sSL https://raw.githubusercontent.com/sobechestnut-dev/tpik/main/install-tui.sh | bash${NC}"