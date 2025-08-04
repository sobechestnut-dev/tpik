# Changelog

All notable changes to tpik will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-01-XX

### 🎉 Initial Enhanced Release

This represents a complete rewrite and massive enhancement of the original simple tmux picker script.

### ✨ Added
- **Rich Interactive Interface**
  - Color-coded session display with status indicators
  - Session details: creation time, window count, attachment status
  - Window preview showing first 3 window names
  - Visual favorites (⭐) and attached session (●) indicators

- **Advanced Session Management**
  - Favorites system with persistent storage
  - Session history tracking (50 most recent)
  - Session templates for reusable project setups
  - Session renaming with favorite preservation
  - Detailed session information view

- **Powerful Filtering & Search**
  - Live search by session name
  - Filter by favorites only
  - Filter by recent sessions only
  - Clear all filters option

- **Smart TMUX Integration**
  - Context-aware interface (different when inside tmux)
  - Session switching without detaching
  - Detach and reopen functionality
  - Native tmux chooser integration
  - Intelligent quit behavior

- **Enhanced User Experience**
  - Comprehensive help system ([h] key)
  - Quick help reference line
  - Context-sensitive menus and options
  - Smart error handling and validation
  - Configuration persistence

- **Developer Features**
  - Configuration directory: `~/.config/tpik/`
  - Persistent favorites, history, and templates
  - Easy installation script
  - MIT license for open source use

### 🛠️ Technical Improvements
- Robust error handling and edge case management
- Better tmux server detection and management
- Optimized session data retrieval
- Cross-platform compatibility improvements
- Comprehensive documentation

### 📦 Distribution
- GitHub repository setup
- One-line curl installer
- Comprehensive README with examples
- MIT license for broad compatibility

---

## [1.0.0] - Original Version

### ✨ Features
- Basic tmux session listing
- Numbered session selection
- Simple new session creation
- Basic session termination
- Minimal color interface

The original version provided basic functionality for tmux session management with a simple numbered menu interface.