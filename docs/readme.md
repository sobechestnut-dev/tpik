# tpik - Modern TMUX Session Manager

## 🎯 Purpose

tpik is a modern Python TUI (Terminal User Interface) application that provides a beautiful, intuitive way to manage tmux sessions. It replaces the need to remember session names or type complex tmux commands with an elegant visual interface.

---

## 🚀 What It Does

1. **Displays sessions beautifully** - Rich visual interface with colors, icons, and metadata
2. **Smart session management** - Create, attach, kill, and manage sessions effortlessly  
3. **Favorites system** - Star your most-used sessions for quick access
4. **Real-time search** - Filter sessions as you type
5. **Context awareness** - Different behavior inside vs outside tmux sessions
6. **Professional interface** - Modern design with gradients, emojis, and smooth interactions

---

## 🎨 Visual Experience

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

### Visual Indicators
- **★** / **☆** - Favorite status (filled/empty star)
- **●** / **○** - Attachment status (filled/empty circle)  
- **🚀** - Modern app header with gradient background
- **🔍** - Search functionality with real-time filtering
- **[CURRENT]** - Highlights your current session
- **Emoji buttons** - Modern, intuitive control interface

---

## 📱 User Experience Flow

### 1. **Launch tpik**
```bash
tp          # Quick alias
# or
tpik        # Full command
```

### 2. **Beautiful Interface Loads**
- Gradient header with app branding
- Session list with rich formatting and colors
- Modern button controls with emoji indicators
- Status bar with helpful feedback

### 3. **Interact with Sessions**
- **Navigate** with arrow keys or mouse
- **Search** by typing in the search box
- **Star favorites** with Space key
- **Filter** to show only favorites
- **Attach** to sessions with Enter

### 4. **Smart Context Handling**
- **Outside tmux**: Full attachment capabilities
- **Inside tmux**: Smart session switching without detaching
- **Error handling**: Friendly messages and recovery options

---

## 🎛️ Core Features

### Session Management
- **List all sessions** with metadata (creation time, window count, status)
- **Attach to sessions** safely without jumping issues
- **Create new sessions** with auto-generated names
- **Kill sessions** with confirmation and safety checks
- **Real-time updates** when sessions change

### Favorites System
- **Star sessions** for quick access
- **Persistent storage** in `~/.config/tpik/favorites`
- **Filter toggle** to show only starred sessions
- **Visual indicators** with filled/empty stars

### Search & Filtering
- **Real-time search** as you type
- **Case-insensitive matching** on session names
- **Clear visual feedback** for active filters
- **Quick filter reset** functionality

### Smart TMUX Integration
- **Context detection** - knows if you're inside or outside tmux
- **Safe switching** - prevents session jumping and attachment issues
- **Error recovery** - handles edge cases gracefully
- **Status awareness** - shows current session clearly

---

## 🎨 Design Philosophy

### Modern & Beautiful
- **Gradient backgrounds** for visual appeal
- **Rich typography** with proper spacing and colors
- **Emoji indicators** for intuitive navigation
- **Responsive layout** that adapts to terminal size

### User-Friendly
- **Clear visual hierarchy** with proper information architecture
- **Helpful status messages** with emoji feedback
- **Keyboard shortcuts** clearly labeled on buttons
- **Mouse support** for point-and-click interaction

### Reliable & Professional
- **Comprehensive error handling** with user-friendly messages
- **Type-safe code** with full Python type annotations
- **Virtual environment isolation** for clean deployment
- **Proper configuration management** in `~/.config/tpik/`

---

## 🔧 Technical Foundation

### Built With Modern Tools
- **Python 3.8+** - Modern language with excellent libraries
- **Textual Framework** - Professional TUI development framework
- **Rich Library** - Beautiful terminal text formatting
- **Type Annotations** - Full typing for maintainability

### Professional Architecture
- **Package structure** with proper `pyproject.toml` configuration
- **Virtual environment** deployment for dependency isolation
- **Configuration management** with user config directories
- **Error handling** with comprehensive exception management

---

## 🎯 Perfect For

### Daily Development
- **Quick session switching** during development workflows
- **Project organization** with favorites and search
- **Clean interface** that doesn't distract from work

### System Administration
- **Multiple server sessions** easily managed
- **Long-running processes** organized and accessible
- **Quick troubleshooting** with instant session access

### Power Users
- **Keyboard-driven workflow** with full shortcut support
- **Mouse interaction** when preferred
- **Customizable** through configuration files
- **Extensible** Python codebase for modifications

---

This represents a complete evolution from simple bash scripts to a professional, modern terminal application that makes tmux session management a pleasure rather than a chore.