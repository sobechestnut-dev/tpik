#!/usr/bin/env python3
"""
tpik - Enhanced TMUX Session Picker TUI Application

A beautiful, responsive terminal interface for managing tmux sessions.
Completely rewritten for reliability and modern aesthetics.
"""

import os
import subprocess
import sys
from pathlib import Path
from typing import List, Optional, Dict, Any
from datetime import datetime

from textual.app import App, ComposeResult
from textual.containers import Container, Horizontal, Vertical, Center
from textual.widgets import (
    Header, Footer, DataTable, Static, Button, Input, Label,
    Pretty, ProgressBar, Select, Switch, ListItem, ListView
)
from textual.reactive import reactive
from textual.message import Message
from textual.screen import Screen
from textual import events, work
from rich.console import Console
from rich.text import Text
from rich.panel import Panel
from rich.table import Table
from rich.align import Align


class TmuxSession:
    """Represents a tmux session with all its metadata."""
    
    def __init__(self, name: str, created: str, windows: int, 
                 attached: bool = False, window_preview: str = ""):
        self.name = name
        self.created = created
        self.windows = windows
        self.attached = attached
        self.window_preview = window_preview
        self.is_favorite = False
        
    def __str__(self) -> str:
        return self.name
        
    @property
    def status_icon(self) -> str:
        """Get the status icon for this session."""
        if self.attached:
            return "●"  # Green dot for attached
        return "○"  # Empty circle for detached
        
    @property
    def favorite_icon(self) -> str:
        """Get the favorite icon for this session."""
        return "★" if self.is_favorite else "☆"


class TmuxManager:
    """Handles all tmux operations and session management."""
    
    def __init__(self):
        self.config_dir = Path.home() / ".config" / "tpik"
        self.favorites_file = self.config_dir / "favorites"
        self.templates_file = self.config_dir / "templates"
        self.history_file = self.config_dir / "history"
        
        # Ensure config directory exists
        self.config_dir.mkdir(parents=True, exist_ok=True)
        
        # Create empty files if they don't exist
        for file_path in [self.favorites_file, self.templates_file, self.history_file]:
            if not file_path.exists():
                file_path.write_text("")
        
    def is_tmux_available(self) -> bool:
        """Check if tmux is installed and available."""
        try:
            result = subprocess.run(["tmux", "-V"], capture_output=True, check=True)
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            return False
            
    def is_inside_tmux(self) -> bool:
        """Check if we're currently inside a tmux session."""
        return "TMUX" in os.environ
        
    def get_current_session(self) -> Optional[str]:
        """Get the name of the current tmux session if inside one."""
        if not self.is_inside_tmux():
            return None
        try:
            result = subprocess.run(
                ["tmux", "display-message", "-p", "#{session_name}"],
                capture_output=True, text=True, check=True
            )
            return result.stdout.strip()
        except subprocess.CalledProcessError:
            return None
            
    def get_sessions(self) -> List[TmuxSession]:
        """Get all available tmux sessions."""
        try:
            # Get session list with detailed info
            result = subprocess.run(
                ["tmux", "list-sessions", "-F", 
                 "#{session_name}|#{session_created}|#{session_windows}|#{session_attached}|#{window_name}"],
                capture_output=True, text=True, check=True
            )
            
            sessions = []
            favorites = self.load_favorites()
            
            for line in result.stdout.strip().split("\n"):
                if not line.strip():
                    continue
                    
                parts = line.split("|")
                if len(parts) >= 4:
                    name, created_timestamp, windows, attached = parts[:4]
                    window_preview = parts[4] if len(parts) > 4 else ""
                    
                    # Convert timestamp to readable format
                    try:
                        created_dt = datetime.fromtimestamp(int(created_timestamp))
                        created = created_dt.strftime("%m/%d %H:%M")
                    except (ValueError, TypeError):
                        created = "Unknown"
                        
                    session = TmuxSession(
                        name=name,
                        created=created, 
                        windows=int(windows) if windows.isdigit() else 0,
                        attached=attached == "1",
                        window_preview=window_preview
                    )
                    session.is_favorite = name in favorites
                    sessions.append(session)
                    
            return sessions
            
        except subprocess.CalledProcessError:
            return []
            
    def attach_session(self, session_name: str) -> tuple[bool, str]:
        """Attach to a tmux session. Returns (success, message)."""
        try:
            if self.is_inside_tmux():
                # Switch to session if inside tmux
                result = subprocess.run(
                    ["tmux", "switch-client", "-t", session_name], 
                    capture_output=True, text=True, check=False
                )
                if result.returncode == 0:
                    return True, f"Switched to session '{session_name}'"
                else:
                    return False, f"Failed to switch: {result.stderr.strip()}"
            else:
                # For attaching from outside tmux, we need to handle this differently
                # We'll use a different approach to avoid jumping issues
                result = subprocess.run(
                    ["tmux", "has-session", "-t", session_name],
                    capture_output=True, check=False
                )
                if result.returncode == 0:
                    # Session exists, now we need to prepare for attachment
                    # The app will exit and let the wrapper script handle attachment
                    return True, f"Preparing to attach to '{session_name}'"
                else:
                    return False, f"Session '{session_name}' does not exist"
        except Exception as e:
            return False, f"Error: {str(e)}"
            
    def create_session(self, session_name: str, start_directory: Optional[str] = None) -> tuple[bool, str]:
        """Create a new tmux session. Returns (success, message)."""
        try:
            # Check if session already exists
            result = subprocess.run(
                ["tmux", "has-session", "-t", session_name],
                capture_output=True, check=False
            )
            if result.returncode == 0:
                return False, f"Session '{session_name}' already exists"
            
            cmd = ["tmux", "new-session", "-d", "-s", session_name]
            if start_directory and os.path.exists(start_directory):
                cmd.extend(["-c", start_directory])
                
            result = subprocess.run(cmd, capture_output=True, text=True, check=False)
            if result.returncode == 0:
                return True, f"Created session '{session_name}'"
            else:
                return False, f"Failed to create session: {result.stderr.strip()}"
        except Exception as e:
            return False, f"Error: {str(e)}"
            
    def kill_session(self, session_name: str) -> tuple[bool, str]:
        """Kill a tmux session. Returns (success, message)."""
        try:
            result = subprocess.run(
                ["tmux", "kill-session", "-t", session_name], 
                capture_output=True, text=True, check=False
            )
            if result.returncode == 0:
                return True, f"Killed session '{session_name}'"
            else:
                return False, f"Failed to kill session: {result.stderr.strip()}"
        except Exception as e:
            return False, f"Error: {str(e)}"
            
    def load_favorites(self) -> set:
        """Load favorite sessions from config file."""
        try:
            if not self.favorites_file.exists():
                return set()
            content = self.favorites_file.read_text().strip()
            if not content:
                return set()
            return set(line.strip() for line in content.split("\n") if line.strip())
        except Exception:
            return set()
            
    def save_favorites(self, favorites: set) -> None:
        """Save favorite sessions to config file."""
        try:
            content = "\n".join(sorted(favorites))
            self.favorites_file.write_text(content + "\n" if content else "")
        except Exception:
            pass
            
    def toggle_favorite(self, session_name: str) -> bool:
        """Toggle favorite status of a session."""
        favorites = self.load_favorites()
        if session_name in favorites:
            favorites.discard(session_name)
            is_favorite = False
        else:
            favorites.add(session_name)
            is_favorite = True
        self.save_favorites(favorites)
        return is_favorite


class SessionListView(ListView):
    """Custom ListView for displaying tmux sessions with modern styling."""
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)


class TpikApp(App):
    """Main tpik TUI application with modern, sleek design."""
    
    CSS = """
    Screen {
        background: $surface;
        color: $text;
    }
    
    .app-header {
        background: $primary;
        color: white;
        text-align: center;
        height: 5;
        content-align: center middle;
        border: none;
    }
    
    .main-container {
        height: 1fr;
        padding: 1 2;
        background: $surface;
    }
    
    .search-container {
        height: 3;
        padding: 0 1;
        margin: 1 0;
    }
    
    .search-input {
        border: solid $primary;
        background: $surface-lighten-1;
        color: $text;
        border-title-color: $primary;
        border-title-style: bold;
    }
    
    .session-container {
        height: 1fr;
        border: solid $accent;
        border-title-color: $accent;
        border-title-style: bold;
        background: $surface-lighten-1;
        margin: 1 0;
    }
    
    .session-list {
        background: transparent;
        color: $text;
        scrollbar-background: $surface-darken-1;
        scrollbar-color: $accent;
        scrollbar-color-hover: $primary;
    }
    
    .session-list > .session-list--option {
        padding: 1 2;
        color: $text;
        background: transparent;
    }
    
    .session-list > .session-list--option-highlighted {
        background: $primary;
        color: white;
        text-style: bold;
    }
    
    .controls-container {
        height: auto;
        padding: 1;
        background: $surface-darken-1;
        border: solid $accent;
        border-title-color: $accent;
        border-title-style: bold;
    }
    
    .control-buttons {
        layout: horizontal;
        height: auto;
        align: center middle;
        width: 100%;
    }
    
    .primary-btn {
        margin: 0 1;
        min-width: 12;
        background: $primary;
        color: white;
        border: none;
        text-style: bold;
    }
    
    .primary-btn:hover {
        background: $primary-lighten-1;
        text-style: bold;
    }
    
    .success-btn {
        margin: 0 1;
        min-width: 12;
        background: $success;
        color: white;
        border: none;
        text-style: bold;
    }
    
    .success-btn:hover {
        background: $success-lighten-1;
        text-style: bold;
    }
    
    .warning-btn {
        margin: 0 1;
        min-width: 12;
        background: $warning;
        color: black;
        border: none;
        text-style: bold;
    }
    
    .warning-btn:hover {
        background: $warning-lighten-1;
        text-style: bold;
    }
    
    .error-btn {
        margin: 0 1;
        min-width: 12;
        background: $error;
        color: white;
        border: none;
        text-style: bold;
    }
    
    .error-btn:hover {
        background: $error-lighten-1;
        text-style: bold;
    }
    
    .secondary-btn {
        margin: 0 1;
        min-width: 12;
        background: $surface-lighten-2;
        color: $text;
        border: solid $accent;
        text-style: bold;
    }
    
    .secondary-btn:hover {
        background: $surface-lighten-3;
        text-style: bold;
    }
    
    .status-bar {
        height: 3;
        background: $surface-darken-1;
        color: $text;
        padding: 1 2;
        border: solid $accent;
        text-style: italic;
    }
    """
    
    TITLE = "tpik - Enhanced TMUX Session Manager"
    SUB_TITLE = "Modern Terminal Interface v3.0"
    
    # Reactive attributes
    sessions: reactive[List[TmuxSession]] = reactive([])
    filtered_sessions: reactive[List[TmuxSession]] = reactive([])
    search_query: reactive[str] = reactive("")
    show_favorites_only: reactive[bool] = reactive(False)
    current_session: reactive[Optional[str]] = reactive(None)
    selected_session_name: reactive[Optional[str]] = reactive(None)
    
    def __init__(self):
        super().__init__()
        self.tmux = TmuxManager()
        self.session_list: Optional[ListView] = None
        
    def compose(self) -> ComposeResult:
        """Compose the modern UI."""
        
        # Modern header with gradient
        yield Static(
            Align.center(
                "[bold white]╭─────────────────────────────────────────────────────────────╮\n"
                "│            🚀 TPIK - Enhanced TMUX Manager 🚀            │\n"
                "│                   Modern Terminal Interface                  │\n"
                "╰─────────────────────────────────────────────────────────────╯[/]"
            ),
            classes="app-header"
        )
        
        # Main container
        with Container(classes="main-container"):
            # Search bar with modern styling
            with Container(classes="search-container"):
                search_input = Input(
                    placeholder="🔍 Search sessions...", 
                    id="search",
                    classes="search-input"
                )
                search_input.border_title = "Search"
                yield search_input
                
            # Session list container with modern styling
            with Container(classes="session-container"):
                self.session_list = ListView(id="sessions", classes="session-list")
                container = Container(self.session_list)
                container.border_title = "Sessions"
                yield container
                
            # Modern control buttons
            with Container(classes="controls-container"):
                controls_container = Container(classes="control-buttons")
                controls_container.border_title = "Controls"
                with controls_container:
                    yield Button("🎯 Attach [Enter]", id="attach", classes="primary-btn")
                    yield Button("✨ New [N]", id="new", classes="success-btn") 
                    yield Button("💀 Kill [Del]", id="kill", classes="error-btn")
                    yield Button("⭐ Favorite [Space]", id="favorite", classes="warning-btn")
                    yield Button("🔖 Filter Favs [F]", id="filter-fav", classes="secondary-btn")
                    yield Button("🔄 Refresh [F5]", id="refresh", classes="secondary-btn")
                    yield Button("❌ Quit [Q]", id="quit", classes="secondary-btn")
                    
        # Modern status bar
        yield Static("🟢 Ready - Welcome to tpik!", id="status", classes="status-bar")
        
    async def on_mount(self) -> None:
        """Initialize the app when mounted."""
        # Check tmux availability
        if not self.tmux.is_tmux_available():
            await self.update_status("❌ Error: tmux is not installed or not available")
            await self.action_quit()
            return
            
        # Get current session if inside tmux
        self.current_session = self.tmux.get_current_session()
        if self.current_session:
            await self.update_status(f"📍 Inside session: {self.current_session}")
        
        # Load initial sessions
        self.refresh_sessions()
        
    @work(exclusive=True)
    async def refresh_sessions(self) -> None:
        """Refresh the session list."""
        await self.update_status("🔄 Refreshing sessions...")
        self.sessions = self.tmux.get_sessions()
        await self.update_filtered_sessions()
        await self.update_status(f"✅ Found {len(self.sessions)} sessions")
        
    async def update_filtered_sessions(self) -> None:
        """Update filtered sessions based on search and filters."""
        filtered = self.sessions.copy()
        
        # Apply favorites filter
        if self.show_favorites_only:
            filtered = [s for s in filtered if s.is_favorite]
            
        # Apply search filter
        if self.search_query:
            query = self.search_query.lower()
            filtered = [s for s in filtered if query in s.name.lower()]
            
        self.filtered_sessions = filtered
        await self.update_session_list()
        
    async def update_session_list(self) -> None:
        """Update the session list with current data."""
        if not self.session_list:
            return
            
        # Clear existing items
        self.session_list.clear()
        
        # Add session items with rich formatting
        for session in self.filtered_sessions:
            # Create rich display text
            status_color = "green" if session.attached else "cyan"
            name_style = "bold green" if session.attached else "white"
            
            display_text = Text()
            display_text.append(f"{session.favorite_icon} ", style="yellow")
            display_text.append(f"{session.status_icon} ", style=status_color)
            display_text.append(f"{session.name}", style=name_style)
            display_text.append(f" ({session.windows}w)", style="cyan")
            display_text.append(f" - {session.created}", style="dim")
            
            if session.window_preview:
                display_text.append(f" [{session.window_preview}]", style="dim")
            
            if session.name == self.current_session:
                display_text.append(" [CURRENT]", style="bold magenta")
                
            list_item = ListItem(display_text)
            list_item.data = session.name  # Store session name for reference
            self.session_list.append(list_item)
            
    def get_selected_session(self) -> Optional[TmuxSession]:
        """Get the currently selected session."""
        if not self.session_list or not self.filtered_sessions:
            return None
            
        try:
            highlighted = self.session_list.highlighted_child
            if highlighted and hasattr(highlighted, 'data'):
                session_name = highlighted.data
                return next((s for s in self.filtered_sessions if s.name == session_name), None)
        except:
            pass
        return None
        
    async def on_button_pressed(self, event: Button.Pressed) -> None:
        """Handle button press events."""
        button_id = event.button.id
        
        if button_id == "attach":
            await self.action_attach()
        elif button_id == "new":
            await self.action_new_session()
        elif button_id == "kill":
            await self.action_kill_session()
        elif button_id == "favorite":
            await self.action_toggle_favorite()
        elif button_id == "filter-fav":
            await self.action_toggle_favorites_filter()
        elif button_id == "refresh":
            self.refresh_sessions()
        elif button_id == "quit":
            await self.action_quit()
            
    async def on_input_changed(self, event: Input.Changed) -> None:
        """Handle search input changes."""
        if event.input.id == "search":
            self.search_query = event.value
            await self.update_filtered_sessions()
            
    async def on_key(self, event: events.Key) -> None:
        """Handle keyboard shortcuts."""
        key = event.key
        
        if key == "enter":
            await self.action_attach()
        elif key == "n":
            await self.action_new_session()
        elif key == "delete":
            await self.action_kill_session()
        elif key == "f":
            await self.action_toggle_favorites_filter()
        elif key == "f5":
            self.refresh_sessions()
        elif key == "q":
            await self.action_quit()
        elif key == "space":
            await self.action_toggle_favorite()
            
    async def action_attach(self) -> None:
        """Attach to the selected session."""
        session = self.get_selected_session()
        if not session:
            await self.update_status("⚠️ No session selected")
            return
            
        await self.update_status(f"🎯 Attaching to {session.name}...")
        success, message = self.tmux.attach_session(session.name)
        
        if success:
            if self.tmux.is_inside_tmux():
                await self.update_status(f"✅ {message}")
                # Don't quit when switching inside tmux
                self.refresh_sessions()
            else:
                # Store the session name for the wrapper script
                session_file = Path.home() / ".tpik_session"
                session_file.write_text(session.name)
                await self.update_status(f"✅ {message}")
                await self.action_quit()
        else:
            await self.update_status(f"❌ {message}")
            
    async def action_new_session(self) -> None:
        """Create a new session."""
        session_name = f"session-{len(self.sessions) + 1:03d}"
        
        await self.update_status(f"✨ Creating session {session_name}...")
        success, message = self.tmux.create_session(session_name)
        
        if success:
            await self.update_status(f"✅ {message}")
            self.refresh_sessions()
        else:
            await self.update_status(f"❌ {message}")
            
    async def action_kill_session(self) -> None:
        """Kill the selected session."""
        session = self.get_selected_session()
        if not session:
            await self.update_status("⚠️ No session selected")
            return
            
        # Don't kill current session
        if session.name == self.current_session:
            await self.update_status("🚫 Cannot kill current session")
            return
            
        await self.update_status(f"💀 Killing session {session.name}...")
        success, message = self.tmux.kill_session(session.name)
        
        if success:
            await self.update_status(f"✅ {message}")
            self.refresh_sessions()
        else:
            await self.update_status(f"❌ {message}")
            
    async def action_toggle_favorite(self) -> None:
        """Toggle favorite status of selected session."""
        session = self.get_selected_session()
        if not session:
            await self.update_status("⚠️ No session selected")
            return
            
        is_fav = self.tmux.toggle_favorite(session.name)
        session.is_favorite = is_fav
        
        status = "Added to" if is_fav else "Removed from"
        icon = "⭐" if is_fav else "☆"
        await self.update_status(f"{icon} {status} favorites: {session.name}")
        await self.update_session_list()
        
    async def action_toggle_favorites_filter(self) -> None:
        """Toggle the favorites filter."""
        self.show_favorites_only = not self.show_favorites_only
        filter_text = "ON" if self.show_favorites_only else "OFF"
        icon = "🔖" if self.show_favorites_only else "📋"
        await self.update_status(f"{icon} Favorites filter: {filter_text}")
        await self.update_filtered_sessions()
        
    async def update_status(self, message: str) -> None:
        """Update the status bar."""
        try:
            status_bar = self.query_one("#status", Static)
            status_bar.update(message)
        except:
            pass  # Ignore if status bar not found


def main() -> None:
    """Main entry point for the tpik application."""
    app = TpikApp()
    app.run()


if __name__ == "__main__":
    main()