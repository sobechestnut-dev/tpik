# tpik - Technical Implementation Guide

## 🏗️ Architecture Overview

tpik is built as a modern Python application using the Textual framework for creating beautiful terminal user interfaces. This document provides technical details about the implementation, architecture decisions, and development considerations.

---

## 📦 Project Structure

```
tpik/
├── pyproject.toml              # Python package configuration
├── README.md                   # User documentation
├── CLAUDE.md                   # AI assistant guidance
├── install-tui.sh              # Automated installer script
├── uninstall-old.sh           # Legacy version removal
├── tpik/                       # Python package
│   ├── __init__.py            # Package initialization
│   ├── app.py                 # Main TUI application
│   └── simple_app.py          # Simplified version (future use)
├── scripts/                    # Legacy bash scripts
│   └── tpik.sh               # Original bash implementation
└── docs/                      # Documentation
    ├── readme.md              # User-friendly overview
    └── technical-implementation.md  # This file
```

---

## 🔧 Core Components

### 1. TmuxSession Class
**Purpose**: Data model representing a tmux session
**Location**: `tpik/app.py`

```python
class TmuxSession:
    def __init__(self, name: str, created: str, windows: int, 
                 attached: bool = False, window_preview: str = ""):
        self.name = name
        self.created = created  
        self.windows = windows
        self.attached = attached
        self.window_preview = window_preview
        self.is_favorite = False
```

**Key Properties**:
- `status_icon`: Returns "●" for attached, "○" for detached
- `favorite_icon`: Returns "★" for favorited, "☆" for regular

### 2. TmuxManager Class
**Purpose**: Handles all tmux operations and configuration management
**Location**: `tpik/app.py`

**Key Methods**:
- `is_tmux_available()`: Checks if tmux is installed
- `is_inside_tmux()`: Detects if running inside a tmux session
- `get_sessions()`: Retrieves and parses session data
- `attach_session()`: Safely attaches to sessions
- `create_session()`: Creates new sessions with validation
- `kill_session()`: Removes sessions with safety checks
- `load_favorites()` / `save_favorites()`: Persistent favorites management

**Error Handling**: All methods return `tuple[bool, str]` for success status and user messages.

### 3. TpikApp Class
**Purpose**: Main Textual application with modern UI
**Location**: `tpik/app.py`

**Key Features**:
- CSS-based styling with gradients and modern design
- Reactive attributes for state management
- Async event handling for smooth interactions
- ListView-based session display for performance

---

## 🎨 UI Framework: Textual

### CSS Styling System
tpik uses Textual's CSS system for modern styling:

```css
.app-header {
    background: linear-gradient(90deg, #0f4c75 0%, #3282b8 50%, #bbe1fa 100%);
    color: white;
    text-align: center;
    height: 5;
}

.primary-btn {
    background: $primary;
    color: white;
    border: none;
    text-style: bold;
}
```

### Widget Hierarchy
```
TpikApp
├── Static (Header with gradient)
├── Container (Main)
│   ├── Container (Search)
│   │   └── Input (Search box)
│   ├── Container (Sessions)
│   │   └── ListView (Session list)
│   └── Container (Controls)
│       └── Container (Buttons)
│           ├── Button (Attach)
│           ├── Button (New)
│           ├── Button (Kill)
│           ├── Button (Favorite)
│           ├── Button (Filter)
│           ├── Button (Refresh)
│           └── Button (Quit)
└── Static (Status Bar)
```

### Reactive Programming
Uses Textual's reactive system for state management:

```python
sessions: reactive[List[TmuxSession]] = reactive([])
filtered_sessions: reactive[List[TmuxSession]] = reactive([])
search_query: reactive[str] = reactive("")
show_favorites_only: reactive[bool] = reactive(False)
```

---

## 🔄 Session Management Logic

### Session Discovery
1. Execute `tmux list-sessions -F "#{session_name}|#{session_created}|..."`
2. Parse pipe-delimited output
3. Convert timestamps to readable format
4. Load favorites from `~/.config/tpik/favorites`
5. Create `TmuxSession` objects with all metadata

### Safe Attachment Logic
```python
def attach_session(self, session_name: str) -> tuple[bool, str]:
    if self.is_inside_tmux():
        # Use switch-client for session switching
        subprocess.run(["tmux", "switch-client", "-t", session_name])
    else:
        # Validate session exists first
        result = subprocess.run(["tmux", "has-session", "-t", session_name])
        if result.returncode == 0:
            # Store session name for wrapper script handling
            session_file = Path.home() / ".tpik_session"
            session_file.write_text(session_name)
```

### Favorites Persistence
- **Storage**: `~/.config/tpik/favorites` (one session name per line)
- **Loading**: Robust handling of empty files and missing directories
- **Saving**: Atomic writes with sorted output for consistency

---

## 🎯 Event Handling

### Keyboard Shortcuts
```python
async def on_key(self, event: events.Key) -> None:
    key = event.key
    if key == "enter":
        await self.action_attach()
    elif key == "n":
        await self.action_new_session()
    elif key == "delete":
        await self.action_kill_session()
    # ... more shortcuts
```

### Button Events
```python
async def on_button_pressed(self, event: Button.Pressed) -> None:
    button_id = event.button.id
    if button_id == "attach":
        await self.action_attach()
    # ... handle other buttons
```

### Search Input
```python
async def on_input_changed(self, event: Input.Changed) -> None:
    if event.input.id == "search":
        self.search_query = event.value
        await self.update_filtered_sessions()
```

---

## 📁 Configuration Management

### Configuration Directory Structure
```
~/.config/tpik/
├── favorites          # Starred sessions (one per line)
├── templates          # Session templates (future feature)
└── history           # Usage history (future feature)
```

### File Format Examples

**favorites**:
```
development
main
background
monitoring
```

**Robust File Handling**:
```python
def load_favorites(self) -> set:
    try:
        if not self.favorites_file.exists():
            return set()
        content = self.favorites_file.read_text().strip()
        if not content:
            return set()
        return set(line.strip() for line in content.split("\n") if line.strip())
    except Exception:
        return set()  # Graceful degradation
```

---

## 🚀 Installation & Deployment

### Virtual Environment Strategy
- **Location**: `~/.local/share/tpik/`
- **Python**: Uses system Python 3.8+
- **Dependencies**: Isolated from system packages
- **Wrapper**: `~/.local/bin/tpik` script for easy execution

### Installation Script (`install-tui.sh`)
1. **Dependency Checks**: Validates Python 3.8+, tmux, python3-venv
2. **Environment Setup**: Creates clean virtual environment
3. **Package Installation**: Installs from GitHub with pip
4. **Integration**: Creates wrapper script and shell alias
5. **Configuration**: Sets up config directories

### Package Configuration (`pyproject.toml`)
```toml
[project]
name = "tpik"
version = "3.0.0"
dependencies = [
    "textual>=0.45.0",
    "rich>=13.0.0",
]

[project.scripts]
tpik = "tpik.app:main"
```

---

## 🔍 Error Handling Strategy

### Comprehensive Exception Management
```python
def tmux_operation(self) -> tuple[bool, str]:
    try:
        result = subprocess.run([...], capture_output=True, text=True, check=False)
        if result.returncode == 0:
            return True, "Success message"
        else:
            return False, f"Failed: {result.stderr.strip()}"
    except Exception as e:
        return False, f"Error: {str(e)}"
```

### User-Friendly Error Messages
- **No tmux**: "❌ Error: tmux is not installed or not available"
- **No sessions**: Shows helpful create session option
- **Network issues**: Graceful degradation with offline functionality
- **Permission errors**: Clear explanation and resolution steps

---

## 🎨 Rich Text Rendering

### Session Display Format
```python
display_text = Text()
display_text.append(f"{session.favorite_icon} ", style="yellow")
display_text.append(f"{session.status_icon} ", style=status_color)
display_text.append(f"{session.name}", style=name_style)
display_text.append(f" ({session.windows}w)", style="cyan")
display_text.append(f" - {session.created}", style="dim")
```

### Color Scheme
- **Green**: Attached sessions and success messages
- **Yellow**: Favorite stars and warnings
- **Cyan**: Metadata like window counts
- **Dim**: Timestamps and secondary information
- **Red**: Error messages and dangerous actions

---

## 🔧 Development Workflow

### Local Development Setup
```bash
git clone https://github.com/sobechestnut-dev/tpik.git
cd tpik
python3 -m venv venv
source venv/bin/activate
pip install -e .
python -m tpik.app
```

### Testing Strategy
- **Manual Testing**: Primary method using real tmux sessions
- **Edge Cases**: Empty session lists, permission errors, network issues
- **Integration**: Test inside/outside tmux scenarios
- **Platform Testing**: Linux and macOS compatibility

### Code Quality
- **Type Hints**: Full typing throughout for maintainability
- **Error Handling**: Defensive programming with graceful degradation
- **Documentation**: Comprehensive docstrings and comments
- **Modern Python**: Uses async/await, pathlib, and current best practices

---

## 🚀 Performance Considerations

### Efficient Session Loading
- **Batch Operations**: Single tmux command gets all session data
- **Lazy Loading**: Only load favorites when needed
- **Caching**: Reactive updates prevent unnecessary recomputation

### UI Responsiveness
- **Async Operations**: Non-blocking tmux calls with `@work` decorator
- **ListView**: Efficient rendering for large session lists
- **Debounced Search**: Smooth filtering without lag

### Memory Management
- **Minimal State**: Only store essential session data
- **Cleanup**: Proper resource cleanup on exit
- **Garbage Collection**: Let Python handle memory management

---

## 🔮 Future Enhancements

### Planned Features
- **Session Templates**: Save and reuse project setups
- **Usage History**: Track and suggest frequently used sessions
- **Themes**: Customizable color schemes and styling
- **Plugin System**: Extensible architecture for custom features

### Technical Improvements
- **Unit Tests**: Comprehensive test suite with mocking
- **Configuration File**: TOML-based settings management
- **Logging**: Structured logging for debugging
- **Packaging**: Distribution via PyPI for easier installation

---

This technical implementation provides a solid foundation for a modern, reliable, and beautiful tmux session manager that can evolve with user needs and maintain high code quality standards.