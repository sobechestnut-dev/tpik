#!/bin/bash

# tpik TUI Installer - Modern Python-based TMUX Session Picker
# Enhanced Terminal User Interface

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="$HOME/.local/bin"
VENV_DIR="$HOME/.local/share/tpik"
REPO_URL="https://github.com/sobechestnut-dev/tpik"

print_header() {
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    tpik TUI Installer v3.0                   ║"
    echo "║              Enhanced TMUX Session Picker                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "${BOLD}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

check_existing_installation() {
    print_step "Checking for existing installation..."
    
    local has_existing=false
    local existing_version=""
    
    # Check for existing virtual environment
    if [ -d "$VENV_DIR" ]; then
        has_existing=true
    fi
    
    # Check for existing wrapper script
    if [ -f "$INSTALL_DIR/tpik" ]; then
        has_existing=true
    fi
    
    # Check for existing command
    if command -v tpik &> /dev/null; then
        has_existing=true
        existing_version=$(tpik --version 2>/dev/null || echo "unknown")
    fi
    
    if [ "$has_existing" = true ]; then
        print_warning "Existing tpik installation detected"
        echo
        echo "Found existing installation at:"
        [ -d "$VENV_DIR" ] && echo "  • Virtual environment: $VENV_DIR"
        [ -f "$INSTALL_DIR/tpik" ] && echo "  • Wrapper script: $INSTALL_DIR/tpik"
        [ -n "$existing_version" ] && echo "  • Version: $existing_version"
        echo
        echo "What would you like to do?"
        echo "  1) Replace existing installation (recommended)"
        echo "  2) Cancel installation"
        echo "  3) Uninstall existing and exit"
        echo
        read -p "Enter your choice (1-3): " choice
        
        case $choice in
            1)
                print_step "Removing existing installation..."
                [ -d "$VENV_DIR" ] && rm -rf "$VENV_DIR"
                [ -f "$INSTALL_DIR/tpik" ] && rm -f "$INSTALL_DIR/tpik"
                print_success "Existing installation removed"
                ;;
            2)
                print_warning "Installation cancelled by user"
                exit 0
                ;;
            3)
                print_step "Uninstalling existing tpik..."
                [ -d "$VENV_DIR" ] && rm -rf "$VENV_DIR"
                [ -f "$INSTALL_DIR/tpik" ] && rm -f "$INSTALL_DIR/tpik"
                
                # Remove alias from shell configs
                for config_file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
                    if [ -f "$config_file" ] && grep -q "alias tp.*tpik" "$config_file"; then
                        cp "$config_file" "${config_file}.backup"
                        grep -v "alias tp.*tpik" "$config_file" > "${config_file}.tmp"
                        mv "${config_file}.tmp" "$config_file"
                        print_success "Removed alias from $config_file"
                    fi
                done
                
                print_success "tpik uninstalled successfully"
                echo "Please restart your terminal or run: source ~/.bashrc"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Installation cancelled."
                exit 1
                ;;
        esac
    else
        print_success "No existing installation found"
    fi
}

check_dependencies() {
    print_step "Checking dependencies..."
    
    # Check Python 3.8+
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required but not installed"
        exit 1
    fi
    
    python_version=$(python3 --version | cut -d' ' -f2)
    required_version="3.8.0"
    
    if ! python3 -c "import sys; exit(0 if sys.version_info >= (3,8) else 1)"; then
        print_error "Python 3.8+ is required (found $python_version)"
        exit 1
    fi
    
    # Check tmux
    if ! command -v tmux &> /dev/null; then
        print_error "tmux is required but not installed"
        echo "Please install tmux first:"
        echo "  Ubuntu/Debian: sudo apt install tmux"
        echo "  macOS: brew install tmux"
        exit 1
    fi
    
    # Check pip
    if ! python3 -m pip --version &> /dev/null; then
        print_error "pip is required but not available"
        exit 1
    fi
    
    # Check python3-venv
    if ! python3 -m venv --help &> /dev/null; then
        print_error "python3-venv is required but not available"
        echo "Please install python3-venv first:"
        echo "  Ubuntu/Debian: sudo apt install python3-venv"
        echo "  RHEL/CentOS: sudo yum install python3-venv"
        echo "  macOS: Should be included with Python 3"
        exit 1
    fi
    
    print_success "Dependencies satisfied"
}

create_venv() {
    print_step "Setting up Python virtual environment..."
    
    # Create directory if needed
    mkdir -p "$(dirname "$VENV_DIR")"
    python3 -m venv "$VENV_DIR"
    
    print_success "Virtual environment created"
}

install_package() {
    print_step "Installing tpik package..."
    
    # Activate virtual environment
    source "$VENV_DIR/bin/activate"
    
    # Upgrade pip
    python -m pip install --upgrade pip
    
    # Install from git repository
    python -m pip install "git+${REPO_URL}@main"
    
    print_success "Package installed successfully"
}

create_wrapper_script() {
    print_step "Creating wrapper script..."
    
    mkdir -p "$INSTALL_DIR"
    
    cat > "$INSTALL_DIR/tpik" << 'EOF'
#!/bin/bash
# tpik TUI wrapper script
exec "$HOME/.local/share/tpik/bin/python" -m tpik.app "$@"
EOF
    
    chmod +x "$INSTALL_DIR/tpik"
    
    print_success "Wrapper script created"
}

setup_alias() {
    print_step "Setting up aliases..."
    
    # Check which shell config file to use
    shell_config=""
    if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
        shell_config="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ] && [ -f "$HOME/.zshrc" ]; then
        shell_config="$HOME/.zshrc"
    elif [ -f "$HOME/.profile" ]; then
        shell_config="$HOME/.profile"
    fi
    
    if [ -n "$shell_config" ]; then
        # Add to PATH if not already there
        if ! grep -q "HOME/.local/bin" "$shell_config"; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_config"
        fi
        
        # Add alias if not already there
        if ! grep -q "alias tp=" "$shell_config"; then
            echo 'alias tp="tpik"' >> "$shell_config"
            print_success "Added alias 'tp' to $shell_config"
        else
            print_warning "Alias 'tp' already exists in $shell_config"
        fi
    else
        print_warning "Could not determine shell configuration file"
        echo "Please add the following to your shell configuration:"
        echo '  export PATH="$HOME/.local/bin:$PATH"'
        echo '  alias tp="tpik"'
    fi
}

create_config_dir() {
    print_step "Creating configuration directory..."
    
    config_dir="$HOME/.config/tpik"
    mkdir -p "$config_dir"
    
    # Create empty config files if they don't exist
    touch "$config_dir/favorites"
    touch "$config_dir/templates"
    touch "$config_dir/history"
    
    print_success "Configuration directory created: $config_dir"
}

test_installation() {
    print_step "Testing installation..."
    
    if "$INSTALL_DIR/tpik" --help &> /dev/null; then
        print_success "Installation test passed"
    else
        print_error "Installation test failed"
        return 1
    fi
}

print_completion_message() {
    echo
    print_success "🎉 Installation Complete!"
    echo
    echo -e "${BOLD}Usage:${NC}"
    echo -e "  ${CYAN}tpik${NC}                    # Launch tpik TUI"
    echo -e "  ${CYAN}tp${NC}                      # Same as tpik (alias)"
    echo
    echo -e "${BOLD}Next Steps:${NC}"
    echo -e "  1. ${YELLOW}Restart your terminal or run:${NC} source ~/.bashrc"
    echo -e "  2. ${YELLOW}Run:${NC} tp"
    echo -e "  3. ${YELLOW}Use keyboard shortcuts for navigation${NC}"
    echo
    echo -e "${BOLD}Features:${NC}"
    echo -e "  • Beautiful, responsive terminal interface"
    echo -e "  • Session favorites (⭐) and history tracking"
    echo -e "  • Live search and filtering"
    echo -e "  • Smart tmux integration (works inside sessions)"
    echo -e "  • Keyboard shortcuts and mouse support"
    echo
    echo -e "${BOLD}Keyboard Shortcuts:${NC}"
    echo -e "  • ${CYAN}Enter${NC}     Attach to selected session"
    echo -e "  • ${CYAN}n${NC}         Create new session"
    echo -e "  • ${CYAN}Del${NC}       Delete selected session"
    echo -e "  • ${CYAN}Space${NC}     Toggle favorite"
    echo -e "  • ${CYAN}f${NC}         Toggle favorites filter"
    echo -e "  • ${CYAN}F5${NC}        Refresh sessions"
    echo -e "  • ${CYAN}q${NC}         Quit"
    echo
    echo -e "${BOLD}Configuration:${NC}"
    echo -e "  • Config files: ${CYAN}$HOME/.config/tpik/${NC}"
    echo -e "  • Favorites: ${CYAN}$HOME/.config/tpik/favorites${NC}"
    echo -e "  • Templates: ${CYAN}$HOME/.config/tpik/templates${NC}"
    echo -e "  • History: ${CYAN}$HOME/.config/tpik/history${NC}"
    echo
    echo -e "${CYAN}${BOLD}Thanks for installing tpik! 🚀${NC}"
    echo -e "GitHub: ${BLUE}https://github.com/sobechestnut-dev/tpik${NC}"
}

main() {
    print_header
    check_existing_installation
    check_dependencies
    create_venv
    install_package
    create_wrapper_script
    setup_alias
    create_config_dir
    test_installation
    print_completion_message
}

main "$@"