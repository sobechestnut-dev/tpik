# 🎯 tpik - Enhanced TMUX Session Picker

> A powerful, interactive tmux session manager with favorites, templates, search, and intelligent tmux integration.

![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Shell](https://img.shields.io/badge/shell-bash-orange.svg)

## ✨ Features

### 🚀 **Core Functionality**
- **Interactive session browser** with rich, color-coded display
- **One-key session switching** - press `1-9` to instantly attach/switch
- **Smart tmux integration** - detects when running inside tmux sessions
- **Session details** - creation time, window count, attachment status, window preview

### ⭐ **Power User Features**
- **Favorites system** - star your most-used sessions for quick access
- **Recent sessions** - automatic history tracking of your 50 most recent sessions
- **Session templates** - save and reuse project setups with custom directories and commands
- **Live search** - filter sessions by name in real-time
- **Advanced filtering** - toggle between all, favorites, or recent sessions

### 🎛️ **TMUX Integration**
- **Context-aware interface** - different menus when inside vs outside tmux
- **Session switching** - seamlessly switch between sessions without detaching
- **Detach & reopen** - `[d]` key detaches and reopens picker outside tmux
- **Native integration** - `[w]` key opens tmux's built-in session chooser

### 🎨 **User Experience**
- **Rich visual indicators**: ⭐ favorites, ● attached sessions
- **Comprehensive help system** - `[h]` for full hotkey reference
- **Quick help line** - always-visible command reference
- **Smart defaults** - Enter key for quick attach, context-sensitive quit behavior

## 📦 Installation

### Quick Install (Recommended)
```bash
curl -sSL https://raw.githubusercontent.com/sobechestnut-dev/tpik/main/install.sh | bash
```

### Manual Install
```bash
# Download the script
curl -sSL https://raw.githubusercontent.com/sobechestnut-dev/tpik/main/scripts/tpik.sh -o ~/scripts/tpik.sh

# Make it executable
chmod +x ~/scripts/tpik.sh

# Add alias to your shell config (~/.bashrc, ~/.zshrc, etc.)
echo 'alias tp="~/scripts/tpik.sh"' >> ~/.bashrc
source ~/.bashrc
```

### Git Clone
```bash
git clone https://github.com/sobechestnut-dev/tpik.git
cd tpik
chmod +x scripts/tpik.sh
# Create alias or symlink as preferred
```

## 🎮 Usage

### Basic Usage
```bash
tp          # Launch the picker
# or
tpik.sh     # Direct script execution
```

### Inside TMUX Sessions
When you run `tp` from within a tmux session, you get enhanced functionality:
- **Instant session switching** without detaching
- **`[d]` key** - detach and reopen picker
- **`[w]` key** - open native tmux session chooser
- **Context-aware help** and menu options

## ⌨️ Hotkeys Reference

### Navigation
| Key | Action | Description |
|-----|--------|-------------|
| `1-9` | Select session | Attach (outside tmux) or switch (inside tmux) |
| `Enter` | Quick action | Attach to first session / stay in current |
| `h` `?` | Help | Show comprehensive help screen |
| `q` | Quit | Exit picker / return to current session |

### Session Management
| Key | Action | Description |
|-----|--------|-------------|
| `n` | New session | Create session with custom directory |
| `c` | Close session | Kill selected session with confirmation |
| `R` | Rename | Rename session (preserves favorites) |
| `s` | Session details | View detailed session and window information |

### Filtering & Search
| Key | Action | Description |
|-----|--------|-------------|
| `f` | Favorites filter | Toggle showing only starred sessions |
| `r` | Recent filter | Toggle showing only recently used sessions |
| `/` | Search | Filter sessions by name |
| `x` | Clear filters | Remove all active filters |

### Power Features
| Key | Action | Description |
|-----|--------|-------------|
| `⭐` | Toggle favorite | Add/remove session from favorites |
| `t` | Templates | Create session from saved template |
| `d` | Detach & reopen | Detach from tmux and reopen picker (tmux mode) |
| `w` | Native chooser | Open tmux's built-in session chooser (tmux mode) |

## 📁 Configuration Files

tpik stores its configuration in `~/.config/tpik/`:

- **`favorites`** - List of starred session names
- **`history`** - Recent session history (auto-managed, max 50)
- **`templates`** - Session templates in format: `name|directory|command`

### Example Template Format
```
development|/home/user/code|nvim
logs|/var/log|tail -f /var/log/syslog
dotfiles|/home/user/.config|git status
```

## 🎯 Use Cases

### Daily Development Workflow
```bash
tp          # Launch picker
f           # Filter to favorites
1           # Jump to main development session
```

### Project Template Usage
```bash
tp          # Launch picker
t           # Create from template
1           # Select "development" template
# Creates session in ~/code with nvim running
```

### Session Management from Inside TMUX
```bash
# Inside any tmux session:
tp          # Launch picker (shows "Inside session: current")
d           # Detach and reopen picker outside tmux
# OR
2           # Instantly switch to session #2
# OR
w           # Open native tmux chooser for tree view
```

## 🔧 Advanced Features

### Session Status Indicators
- **⭐** - Favorited session (quick access with `f` filter)
- **●** - Currently attached session (green highlight)
- **Window preview** - Shows first 3 window names

### Smart Context Awareness
- **Outside tmux**: Full attach/create functionality
- **Inside tmux**: Session switching, detach options, native integration
- **Help system**: Context-sensitive help and quick reference

### Template System
Create reusable session configurations:
1. Press `t` to access templates
2. Press `n` to create new template
3. Specify name, directory, and optional startup command
4. Templates persist across sessions

## 📋 Requirements

- **tmux** - Terminal multiplexer (tested with tmux 3.0+)
- **bash** - Uses bash-specific features
- **ANSI color support** - Most modern terminals
- **date command** - For timestamp formatting (optional)

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup
```bash
git clone https://github.com/sobechestnut-dev/tpik.git
cd tpik
# Edit scripts/tpik.sh
# Test with: ./scripts/tpik.sh
```

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on the excellent foundation of [tmux](https://github.com/tmux/tmux)
- Inspired by the need for better session management workflows
- Thanks to the tmux community for feedback and ideas

---

**📞 Support**: Found a bug or have a feature request? [Open an issue](https://github.com/sobechestnut-dev/tpik/issues)

**⭐ Like this project?** Give it a star on GitHub!