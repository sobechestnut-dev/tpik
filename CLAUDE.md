# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

tpik is a modern Python TUI (Terminal User Interface) application for managing tmux sessions. It has been completely rewritten from the original bash script to use Python 3.8+ with the Textual framework for a beautiful, reliable terminal interface.

## Architecture

- **Python package structure**: Proper Python package with `pyproject.toml` configuration
- **Modern TUI framework**: Built using Textual for robust terminal interfaces
- **Rich text rendering**: Uses Rich library for beautiful terminal formatting
- **Virtual environment deployment**: Isolated installation with proper dependency management
- **Type-safe code**: Full type hints throughout for maintainability

## Key Components

### Main Application (`tpik/app.py`)
- `TpikApp`: Main Textual application class with modern CSS styling
- `TmuxManager`: Handles all tmux operations and configuration management
- `TmuxSession`: Data class representing tmux session metadata
- `SessionListView`: Custom ListView for displaying sessions with rich formatting

### Package Structure
```
tpik/
├── __init__.py          # Package initialization
├── app.py              # Main TUI application
└── simple_app.py       # Simplified version (if needed)

pyproject.toml          # Python package configuration
install-tui.sh          # Installation script with virtual environment setup
scripts/tpik.sh         # Legacy bash script (maintained for compatibility)
```

## Key Features

### Modern TUI Interface
- Gradient header with emoji indicators
- Rich text session display with colors and status icons
- Modern button styling with hover effects
- Responsive layout that adapts to terminal size
- Real-time search and filtering capabilities

### Robust Session Management
- Favorites system with persistent storage in `~/.config/tpik/favorites`
- Smart tmux integration (inside vs outside session detection)
- Safe session attachment without jumping issues
- Comprehensive error handling with user-friendly messages

## Installation and Usage

### Installation
The application is installed via the automated installer script:
```bash
curl -sSL https://raw.githubusercontent.com/sobechestnut-dev/tpik/main/install-tui.sh | bash
```

This creates:
- Virtual environment at `~/.local/share/tpik`
- Wrapper script at `~/.local/bin/tpik`
- Configuration directory at `~/.config/tpik`
- Shell alias `tp` for easy access

### Usage
```bash
tpik        # Launch TUI application
tp          # Same as tpik (alias)
```

## Dependencies

### Runtime Dependencies
- **Python 3.8+**: Modern Python with type hints and async support
- **tmux**: Terminal multiplexer for session management
- **textual**: TUI framework for building terminal applications
- **rich**: Library for rich text and beautiful formatting

### System Dependencies
- **python3-venv**: For creating isolated virtual environments
- **pip**: Python package installer (usually included)

## Build/Test Commands

### Development Setup
```bash
# Clone repository
git clone https://github.com/sobechestnut-dev/tpik.git
cd tpik

# Create development environment
python3 -m venv venv
source venv/bin/activate
pip install -e .

# Run application
python -m tpik.app
```

### Testing
Currently no formal test suite. Testing is done manually:
```bash
# Test basic functionality
python -m tpik.app

# Test tmux integration
tmux new-session -d -s test-session
python -m tpik.app
```

## Configuration

The application stores configuration in `~/.config/tpik/`:
- **`favorites`**: List of starred sessions (one per line)
- **`templates`**: Session templates for future use
- **`history`**: Usage history and statistics

## Documentation

- `README.md`: Complete user documentation with modern features
- `docs/readme.md`: Legacy documentation (may be outdated)
- `docs/technical-implementation.md`: Legacy technical docs (may be outdated)
- `CONTRIBUTING.md`: Contribution guidelines
- `CHANGELOG.md`: Version history and changes

## Important Notes for Claude Code

1. **This is now a Python project**, not a bash script
2. **Use `tpik/app.py`** as the main file to edit, not `scripts/tpik.sh`
3. **Test changes** by running `python -m tpik.app` from the project root
4. **Modern Python practices** are used throughout (type hints, async/await, etc.)
5. **Virtual environment** is required for deployment
6. **Textual framework** knowledge is helpful for UI modifications
7. **Rich library** is used for text formatting and styling

## Version History

- **v1.0**: Original bash script
- **v2.0**: Enhanced bash script with advanced features  
- **v3.0**: Complete rewrite in Python with modern TUI (current)