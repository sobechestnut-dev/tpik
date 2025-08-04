# Contributing to tpik

Thank you for your interest in contributing to tpik! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Issues
- Use the [GitHub Issues](https://github.com/sobechestnut-dev/tpik/issues) page
- Search existing issues before creating a new one
- Provide clear reproduction steps
- Include your environment details (OS, tmux version, shell)

### Suggesting Features
- Open an issue with the "enhancement" label
- Describe the use case and expected behavior
- Consider backward compatibility

### Code Contributions
1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 🧪 Testing

### Manual Testing
```bash
# Test basic functionality
./scripts/tpik.sh

# Test inside tmux session
tmux new-session -d -s test
tmux attach-session -t test
# Run tpik.sh inside session

# Test edge cases
# - No sessions available
# - Many sessions (10+)
# - Long session names
# - Special characters in names
```

### Configuration Testing
```bash
# Test with different configurations
mkdir -p ~/.config/tpik
echo "test-session" > ~/.config/tpik/favorites
echo "template1|/tmp|echo test" > ~/.config/tpik/templates
```

## 📋 Code Style

### Shell Script Guidelines
- Use bash-specific features appropriately
- Proper error handling with `set -e` where appropriate
- Consistent indentation (4 spaces)
- Clear variable names
- Comments for complex logic

### Color and Formatting
- Use existing color constants
- Maintain consistent visual style
- Test in different terminals
- Ensure accessibility (avoid color-only information)

### User Interface
- Keep hotkeys intuitive and memorable
- Maintain backward compatibility for existing hotkeys
- Clear, concise messages
- Helpful error messages with suggested actions

## 🏗️ Architecture

### File Structure
```
tpik/
├── scripts/
│   └── tpik.sh          # Main script
├── docs/
│   ├── readme.md        # Original user documentation
│   └── technical-implementation.md
├── README.md            # Primary documentation
├── CHANGELOG.md         # Version history
├── CONTRIBUTING.md      # This file
├── LICENSE             # MIT license
├── install.sh          # Installation script
└── CLAUDE.md           # AI assistant guidance
```

### Key Functions
- `show_header()` - Display management
- `get_session_info()` - Session data retrieval
- `is_favorite()` - Favorites management
- `add_to_history()` - History tracking
- Main loop - User interaction handling

### Configuration
- `~/.config/tpik/favorites` - Starred sessions
- `~/.config/tpik/history` - Recent sessions (auto-managed)
- `~/.config/tpik/templates` - Session templates

## 🔧 Development Setup

### Prerequisites
- tmux (3.0+)
- bash (4.0+)
- Standard Unix tools (grep, sed, cut, etc.)

### Local Development
```bash
git clone https://github.com/sobechestnut-dev/tpik.git
cd tpik
chmod +x scripts/tpik.sh

# Test your changes
./scripts/tpik.sh

# Test installation process
./install.sh
```

## 📝 Documentation

### README Updates
- Keep feature list current
- Update hotkey reference for any new keys
- Add examples for new features
- Maintain compatibility information

### Code Documentation
- Comment complex logic
- Document new functions
- Update help system for new features
- Maintain CHANGELOG.md

## 🚀 Release Process

### Version Numbering
- Major (X.0.0): Breaking changes or major rewrites
- Minor (X.Y.0): New features, backward compatible
- Patch (X.Y.Z): Bug fixes, small improvements

### Release Checklist
1. Update version numbers in relevant files
2. Update CHANGELOG.md
3. Test installation script
4. Test on different platforms if possible
5. Create GitHub release with release notes
6. Update any documentation references

## 💡 Ideas for Contributions

### Easy Contributions
- Documentation improvements
- Bug fixes
- Error message improvements
- Color scheme enhancements

### Medium Contributions
- New filtering options
- Additional template features
- Performance optimizations
- Cross-platform compatibility

### Advanced Contributions
- Integration with other tools
- Advanced tmux features
- Plugin system architecture
- Configuration file enhancements

## 📧 Questions?

- Open an issue for questions about contributing
- Check existing issues and discussions
- Be patient and respectful in all interactions

## 🙏 Recognition

Contributors will be recognized in:
- GitHub contributors list
- Release notes for significant contributions
- README acknowledgments section

Thank you for helping make tpik better! 🚀