# TMUX Session Picker Script - Semi-Technical Reader

## 🎯 Purpose

This script provides a user-friendly way to view and attach to active `tmux` sessions using a numbered menu. It’s designed for quick access without remembering session names or typing long commands.

---

## 👍 What It Does

1. Checks if `tmux` is installed.
2. Lists all active `tmux` sessions.
3. Presents them in a numbered, color-coded menu.
4. Lets you press a single number key to join a session.
5. Offers to create a new session if none exist.

---

## 📝 Script Flow (Step by Step)

### 1. **Check for tmux**
```bash
command -v tmux
