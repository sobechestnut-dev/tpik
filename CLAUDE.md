# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a single-file Bash utility called "tmux picker" that provides an interactive menu for managing tmux sessions. The main script is `scripts/tpik.sh`.

## Architecture

- **Single script architecture**: All functionality is contained in `scripts/tpik.sh`
- **Interactive menu-driven interface**: Uses `read -n1` for single-key navigation
- **Color-coded terminal output**: ANSI escape codes for visual feedback
- **Session management**: List, attach, create, and close tmux sessions

## Key Components

### Main Script (`scripts/tpik.sh`)
- Interactive loop with session listing and menu options
- Color definitions using ANSI escape codes
- Session operations: attach (`tmux attach-session`), create (`tmux new-session`), kill (`tmux kill-session`)
- Input validation and error handling

## Usage and Installation

The script is designed to be placed in `~/scripts/` and aliased as `tp` in shell configuration:
```bash
chmod +x ~/scripts/tmux-picker.sh
alias tp='~/scripts/tmux-picker.sh'
```

## Dependencies

- `tmux`: Required for all session operations
- `bash`: Uses bash-specific features like `mapfile` and associative arrays
- Terminal with ANSI color support

## No Build/Test Commands

This is a standalone Bash script with no build system, package manager, or test framework. The script can be executed directly once made executable.

## Documentation

- `docs/readme.md`: User-friendly overview and step-by-step flow
- `docs/technical-implementation.md`: Detailed technical documentation with code examples and troubleshooting