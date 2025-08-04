# 🚀 tpik - Modern TMUX Session Manager

> A beautiful, modern Python TUI for managing tmux sessions with style and efficiency.

![Version](https://img.shields.io/badge/version-3.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Python](https://img.shields.io/badge/python-3.8+-orange.svg)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg)

## ✨ What's New in v3.0

🎨 **Complete Rewrite**: Migrated from bash to modern Python TUI using Textual framework  
🌈 **Beautiful Interface**: Gradient headers, modern styling, and emoji indicators  
⚡ **Rock Solid**: Fixed all runtime errors and session jumping issues  
🔧 **Professional**: Installation system with virtual environments and proper packaging  

---

## 🎯 Features

### 🖥️ **Modern Terminal Interface**
- **Beautiful TUI** built with Textual framework for stunning visuals
- **Gradient header** with modern styling and emoji indicators
- **Rich session display** with colors, status icons, and metadata
- **Responsive design** that works perfectly on all screen sizes
- **Mouse and keyboard support** for maximum accessibility

### ⭐ **Smart Session Management**
- **Favorites system** - star sessions for quick access with persistent storage
- **Live search** - filter sessions in real-time as you type
- **Status indicators** - see attached (●) vs detached (○) sessions at a glance
- **Session metadata** - creation time, window count, and current window info
- **Current session highlighting** - clearly shows which session you're in

### 🎛️ **Advanced TMUX Integration**
- **Smart context detection** - different behavior inside vs outside tmux
- **Session switching** - seamless switching without detaching when inside tmux  
- **Safe attachment** - proper handling to prevent session jumping issues
- **Error handling** - comprehensive error messages and recovery

### 🔍 **Powerful Filtering & Search**
- **Real-time search** - filter sessions as you type
- **Favorites filter** - toggle to show only starred sessions
- **Search highlighting** - visual feedback for active filters
- **Quick clear** - easily reset all filters

---

## 📦 Installation

### Automatic Installation (Recommended)
```bash
curl -sSL https://raw.githubusercontent.com/sobechestnut-dev/tpik/main/install-tui.sh | bash
```

This will:
- ✅ Check all dependencies (Python 3.8+, tmux, python3-venv)
- ✅ Create an isolated virtual environment
- ✅ Install tpik from GitHub with all dependencies
- ✅ Set up the `tpik` command and `tp` alias
- ✅ Create configuration directories

### Manual Installation
```bash
# Clone the repository
git clone https://github.com/sobechestnut-dev/tpik.git
cd tpik

# Create virtual environment
python3 -m venv ~/.local/share/tpik
source ~/.local/share/tpik/bin/activate

# Install dependencies
pip install textual rich

# Install tpik
pip install -e .

# Create wrapper script
mkdir -p ~/.local/bin
cat > ~/.local/bin/tpik << 'EOF'
#!/bin/bash
exec "$HOME/.local/share/tpik/bin/python" -m tpik.app "$@"
EOF
chmod +x ~/.local/bin/tpik

# Add to PATH and create alias
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
echo 'alias tp="tpik"' >> ~/.bashrc
source ~/.bashrc
```

---

## 🎮 Usage

### Launch tpik
```bash
tpik        # Launch the modern TUI
# or
tp          # Same as tpik (alias)
```

### Interface Overview
```
╭─────────────────────────────────────────────────────────────╮
│            🚀 TPIK - Enhanced TMUX Manager 🚀            │
│                   Modern Terminal Interface                  │
╰─────────────────────────────────────────────────────────────╯

┌─ Search ─────────────────────────────────────────────────────┐
│ 🔍 Search sessions...                                       │
└─────────────────────────────────────────────────────────────┘

┌─ Sessions ───────────────────────────────────────────────────┐
│ ★ ● main (3w) - 08/04 15:30 [nvim] [CURRENT]               │
│ ☆ ○ development (2w) - 08/04 14:20 [zsh]                   │
│ ⭐ ● background (1w) - 08/04 13:10 [htop]                  │
└─────────────────────────────────────────────────────────────┘

┌─ Controls ───────────────────────────────────────────────────┐
│ [🎯 Attach] [✨ New] [💀 Kill] [⭐ Favorite] [🔖 Filter] │
│                   [🔄 Refresh] [❌ Quit]                    │
└─────────────────────────────────────────────────────────────┘

🟢 Ready - Welcome to tpik!
```

### Keyboard Shortcuts
| Key | Action | Description |
|-----|--------|-------------|
| `Enter` | Attach | Attach to selected session |
| `N` | New Session | Create new session |
| `Del` | Kill Session | Delete selected session |
| `Space` | Toggle Favorite | Add/remove from favorites |
| `F` | Filter Favorites | Show only starred sessions |
| `F5` | Refresh | Reload session list |
| `Q` | Quit | Exit application |
| `🔍` | Search | Type to filter sessions |

---

## 🎨 Modern Design Features

### Visual Indicators
- **★** / **☆** - Favorite status (filled/empty star)
- **●** / **○** - Attachment status (filled/empty circle)  
- **🚀** - App header with gradient background
- **🟢** - Status indicators with emoji feedback
- **[CURRENT]** - Highlights your current session

### Color Coding
- **Green text** - Currently attached sessions
- **Yellow stars** - Favorite sessions  
- **Cyan numbers** - Window counts
- **Dim text** - Timestamps and metadata
- **Gradient buttons** - Modern button styling with hover effects

### Smart Features
- **Responsive layout** - Adapts to terminal size
- **Rich text rendering** - Beautiful typography and spacing
- **Context awareness** - Different behavior inside vs outside tmux
- **Error recovery** - Graceful handling of edge cases

---

## 📁 Configuration

tpik stores configuration in `~/.config/tpik/`:

- **`favorites`** - Your starred sessions (one per line)
- **`templates`** - Session templates for future use
- **`history`** - Usage history and statistics

### Example favorites file:
```
development
main
background
monitoring
```

---

## 🔧 Technical Details

### Requirements
- **Python 3.8+** - Modern Python with type hints
- **tmux** - Terminal multiplexer 
- **Textual** - Modern TUI framework
- **Rich** - Beautiful terminal formatting

### Architecture
- **Python package** - Proper packaging with `pyproject.toml`
- **Virtual environment** - Isolated dependencies
- **Modern TUI** - Built on Textual framework for reliability
- **Type hints** - Full typing for maintainability
- **Error handling** - Comprehensive exception management

### Platform Support
- ✅ **Linux** - Full support
- ✅ **macOS** - Full support  
- ✅ **WSL** - Works in Windows Subsystem for Linux
- ❌ **Windows** - Not supported (tmux requirement)

---

## 🆚 Migration from v2.0

If you're upgrading from the old bash version:

### Uninstall Old Version
```bash
# Remove old script
rm ~/scripts/tpik.sh

# Remove old alias from shell config
sed -i '/tp.*scripts\/tpik.sh/d' ~/.bashrc

# Reload shell
source ~/.bashrc
```

### Install New Version
```bash
curl -sSL https://raw.githubusercontent.com/sobechestnut-dev/tpik/main/install-tui.sh | bash
```

Your favorites will be preserved if stored in `~/.config/tpik/favorites`.

---

## 🐛 Troubleshooting

### Common Issues

**"tmux not available"**
```bash
# Ubuntu/Debian
sudo apt install tmux

# macOS
brew install tmux
```

**"python3-venv not available"**
```bash
# Ubuntu/Debian  
sudo apt install python3-venv

# Usually included on macOS
```

**"Command not found: tpik"**
```bash
# Add to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**"Import errors"**
```bash
# Reinstall in clean environment
rm -rf ~/.local/share/tpik
curl -sSL https://raw.githubusercontent.com/sobechestnut-dev/tpik/main/install-tui.sh | bash
```

---

## 🤝 Contributing

Contributions are welcome! This is a modern Python project using:

- **Textual** for the TUI framework
- **Rich** for text formatting  
- **Type hints** throughout
- **Modern Python** practices

### Development Setup
```bash
git clone https://github.com/sobechestnut-dev/tpik.git
cd tpik

# Create development environment
python3 -m venv venv
source venv/bin/activate
pip install -e .

# Run from source
python -m tpik.app
```

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## 🙏 Credits

- **Textual Framework** - For the amazing TUI capabilities
- **Rich Library** - For beautiful terminal formatting
- **TMUX** - The foundation this tool is built upon
- **Python Community** - For the excellent ecosystem

---

**🐛 Found a bug?** [Open an issue](https://github.com/sobechestnut-dev/tpik/issues)  
**💡 Feature request?** [Start a discussion](https://github.com/sobechestnut-dev/tpik/discussions)  
**⭐ Like this project?** Give it a star on GitHub!

---

*tpik v3.0 - Modern TMUX session management made beautiful* 🚀