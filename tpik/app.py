#!/usr/bin/env python3
"""
tpik - Enhanced TMUX Session Picker TUI Application

A beautiful, responsive terminal interface for managing tmux sessions.
"""

import subprocess
import sys
from pathlib import Path
from typing import List, Optional, Dict, Any
from datetime import datetime

from textual.app import App, ComposeResult
from textual.containers import Container, Horizontal, Vertical
from textual.widgets import (
    Header, Footer, DataTable, Static, Button, Input, Label,
    Pretty, ProgressBar, Select, Switch
)
from textual.reactive import reactive
from textual.message import Message
from textual.screen import Screen
from textual import events
from rich.console import Console
from rich.text import Text
from rich.panel import Panel
from rich.table import Table


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
        return " "
        
    @property
    def favorite_icon(self) -> str:
        """Get the favorite icon for this session."""
        return "⭐" if self.is_favorite else " "


class TmuxManager:
    """Handles all tmux operations and session management."""
    
    def __init__(self):
        self.config_dir = Path.home() / ".config" / "tpik"
        self.favorites_file = self.config_dir / "favorites"
        self.templates_file = self.config_dir / "templates"
        self.history_file = self.config_dir / "history"
        
        # Ensure config directory exists
        self.config_dir.mkdir(parents=True, exist_ok=True)
        
    def is_tmux_available(self) -> bool:
        """Check if tmux is installed and available."""
        try:
            subprocess.run(["tmux", "-V"], capture_output=True, check=True)
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            return False
            
    def is_inside_tmux(self) -> bool:
        """Check if we're currently inside a tmux session."""
        return "TMUX" in subprocess.os.environ
        
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
                if not line:
                    continue
                    
                parts = line.split("|")
                if len(parts) >= 4:
                    name, created_timestamp, windows, attached, window_preview = (
                        parts + [""])[:5]
                    
                    # Convert timestamp to readable format
                    try:
                        created_dt = datetime.fromtimestamp(int(created_timestamp))
                        created = created_dt.strftime("%m/%d %H:%M")
                    except (ValueError, TypeError):
                        created = "Unknown"
                        
                    session = TmuxSession(
                        name=name,
                        created=created, 
                        windows=int(windows),
                        attached=attached == "1",
                        window_preview=window_preview
                    )
                    session.is_favorite = name in favorites
                    sessions.append(session)
                    
            return sessions
            
        except subprocess.CalledProcessError:
            return []
            
    def attach_session(self, session_name: str) -> bool:
        """Attach to a tmux session."""
        try:
            if self.is_inside_tmux():
                # Switch to session if inside tmux
                subprocess.run(["tmux", "switch-client", "-t", session_name], check=True)
            else:
                # Attach to session from outside tmux
                subprocess.run(["tmux", "attach-session", "-t", session_name], check=True)
            return True
        except subprocess.CalledProcessError:
            return False
            
    def create_session(self, session_name: str, start_directory: Optional[str] = None) -> bool:
        """Create a new tmux session."""
        try:
            cmd = ["tmux", "new-session", "-d", "-s", session_name]
            if start_directory:
                cmd.extend(["-c", start_directory])
            subprocess.run(cmd, check=True)
            return True
        except subprocess.CalledProcessError:
            return False
            
    def kill_session(self, session_name: str) -> bool:
        """Kill a tmux session."""
        try:
            subprocess.run(["tmux", "kill-session", "-t", session_name], check=True)
            return True
        except subprocess.CalledProcessError:
            return False
            
    def load_favorites(self) -> set:
        """Load favorite sessions from config file."""
        if not self.favorites_file.exists():
            return set()
        try:
            return set(self.favorites_file.read_text().strip().split("\n"))
        except Exception:
            return set()
            
    def save_favorites(self, favorites: set) -> None:
        """Save favorite sessions to config file."""
        try:
            self.favorites_file.write_text("\n".join(sorted(favorites)) + "\n")
        except Exception:
            pass
            
    def toggle_favorite(self, session_name: str) -> bool:
        """Toggle favorite status of a session."""
        favorites = self.load_favorites()
        if session_name in favorites:
            favorites.remove(session_name)
            is_favorite = False
        else:
            favorites.add(session_name)
            is_favorite = True
        self.save_favorites(favorites)
        return is_favorite


class SessionTable(DataTable):
    """Custom DataTable for displaying tmux sessions."""
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.cursor_type = "row"
        self.zebra_stripes = True
        
    def on_mount(self) -> None:
        """Set up the table columns."""
        self.add_columns(
            ("", "fav", 3),  # Favorite icon
            ("", "status", 3),  # Status icon  
            ("Session", "name", 20),
            ("Created", "created", 12),
            ("Win", "windows", 5),
            ("Window", "preview", 15),
        )


class TpikApp(App):
    """Main tpik TUI application."""
    
    CSS = """
    Screen {
        background: $surface;
    }
    
    .header {
        background: $primary;
        color: $text;
        text-align: center;
        height: 3;
        content-align: center middle;
    }
    
    .main-container {
        height: 1fr;
        padding: 1;
    }
    
    .session-table {
        height: 1fr;
        border: solid $accent;
        border-title-color: $accent;
        border-title-align: center;
    }
    
    .controls {
        height: auto;
        padding: 1 0;
        background: $panel;
    }
    
    .status-bar {
        height: 3;
        background: $surface-lighten-1;
        padding: 1;
    }
    
    Button {
        margin: 0 1;
        min-width: 12;
    }
    
    .search-container {
        height: auto;
        padding: 0 1;
    }
    
    Input {
        margin: 0 1;
    }
    
    .quick-actions {
        layout: horizontal;
        height: auto;
        align: center middle;
    }
    """
    
    TITLE = "tpik - TMUX Session Picker v3.0"
    SUB_TITLE = "Enhanced Terminal Interface"
    
    # Reactive attributes
    sessions: reactive[List[TmuxSession]] = reactive([])
    filtered_sessions: reactive[List[TmuxSession]] = reactive([])
    search_query: reactive[str] = reactive("")
    show_favorites_only: reactive[bool] = reactive(False)
    current_session: reactive[Optional[str]] = reactive(None)
    
    def __init__(self):
        super().__init__()
        self.tmux = TmuxManager()
        self.session_table: Optional[SessionTable] = None
        
    def compose(self) -> ComposeResult:
        """Compose the main UI."""
        
        # Header
        yield Static(
            "[bold cyan]╔══════════════════════════════════════════════════════════════╗\\n"
            "║                    TMUX SESSION PICKER v3.0                 ║\\n" 
            "║                      Enhanced Edition                        ║\\n"
            "╚══════════════════════════════════════════════════════════════╝[/]",
            classes="header"
        )
        
        # Main container
        with Container(classes="main-container"):
            # Search bar
            with Container(classes="search-container"):
                yield Input(placeholder="Search sessions...", id="search")
                
            # Session table
            self.session_table = SessionTable(id="sessions")
            self.session_table.border_title = "Sessions"
            yield self.session_table
            
            # Controls
            with Container(classes="controls"):
                with Horizontal(classes="quick-actions"):
                    yield Button("Attach [Enter]", id="attach", variant="primary")
                    yield Button("New [n]", id="new", variant="success") 
                    yield Button("Kill [Del]", id="kill", variant="error")
                    yield Button("⭐ Favorite", id="favorite", variant="warning")
                    yield Button("Favorites", id="filter-fav")
                    yield Button("Refresh [F5]", id="refresh")
                    yield Button("Quit [q]", id="quit")
                    
        # Status bar
        yield Static("Ready", id="status", classes="status-bar")
        
    async def on_mount(self) -> None:
        """Initialize the app when mounted."""
        # Check tmux availability
        if not self.tmux.is_tmux_available():
            await self.action_quit()
            print("Error: tmux is not installed or not available")
            return
            
        # Get current session if inside tmux
        self.current_session = self.tmux.get_current_session()
        
        # Load initial sessions
        await self.refresh_sessions()
        
    async def refresh_sessions(self) -> None:
        """Refresh the session list."""
        self.sessions = self.tmux.get_sessions()
        await self.update_filtered_sessions()
        
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
        await self.update_table()
        
    async def update_table(self) -> None:
        """Update the session table with current data."""
        if not self.session_table:
            return
            
        # Clear existing rows
        self.session_table.clear()
        
        # Add session rows
        for session in self.filtered_sessions:
            fav_icon = Text(session.favorite_icon, style="yellow")
            status_icon = Text(session.status_icon, style="green" if session.attached else "dim")
            name_style = "bold green" if session.attached else "default"
            
            self.session_table.add_row(
                fav_icon,
                status_icon, 
                Text(session.name, style=name_style),
                Text(session.created, style="dim"),
                Text(str(session.windows), style="cyan"),
                Text(session.window_preview, style="dim"),
            )
            
    def get_selected_session(self) -> Optional[TmuxSession]:
        """Get the currently selected session."""
        if not self.session_table or not self.filtered_sessions:
            return None
            
        cursor_row = self.session_table.cursor_row
        if 0 <= cursor_row < len(self.filtered_sessions):
            return self.filtered_sessions[cursor_row]
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
            await self.action_refresh()
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
            await self.action_refresh()
        elif key == "q":
            await self.action_quit()
        elif key == "space":
            await self.action_toggle_favorite()
            
    async def action_attach(self) -> None:
        """Attach to the selected session."""
        session = self.get_selected_session()
        if not session:
            await self.update_status("No session selected")
            return
            
        await self.update_status(f"Attaching to {session.name}...")
        success = self.tmux.attach_session(session.name)
        
        if success:
            # Exit the app since we're attaching
            await self.action_quit()
        else:
            await self.update_status(f"Failed to attach to {session.name}")
            
    async def action_new_session(self) -> None:
        """Create a new session."""
        # For now, use a simple naming scheme
        # TODO: Add a proper dialog for session creation
        session_name = f"new-session-{len(self.sessions) + 1}"
        
        await self.update_status(f"Creating session {session_name}...")
        success = self.tmux.create_session(session_name)
        
        if success:
            await self.update_status(f"Created session {session_name}")
            await self.refresh_sessions()
        else:
            await self.update_status(f"Failed to create session {session_name}")
            
    async def action_kill_session(self) -> None:
        """Kill the selected session."""
        session = self.get_selected_session()
        if not session:
            await self.update_status("No session selected")
            return
            
        # Don't kill current session
        if session.name == self.current_session:
            await self.update_status("Cannot kill current session")
            return
            
        await self.update_status(f"Killing session {session.name}...")
        success = self.tmux.kill_session(session.name)
        
        if success:
            await self.update_status(f"Killed session {session.name}")
            await self.refresh_sessions()
        else:
            await self.update_status(f"Failed to kill session {session.name}")
            
    async def action_toggle_favorite(self) -> None:
        """Toggle favorite status of selected session."""
        session = self.get_selected_session()
        if not session:
            await self.update_status("No session selected")
            return
            
        is_fav = self.tmux.toggle_favorite(session.name)
        session.is_favorite = is_fav
        
        status = "Added to" if is_fav else "Removed from"
        await self.update_status(f"{status} favorites: {session.name}")
        await self.update_table()
        
    async def action_toggle_favorites_filter(self) -> None:
        """Toggle the favorites filter."""
        self.show_favorites_only = not self.show_favorites_only
        filter_text = "on" if self.show_favorites_only else "off"
        await self.update_status(f"Favorites filter: {filter_text}")
        await self.update_filtered_sessions()
        
    async def action_refresh(self) -> None:
        """Refresh the session list."""
        await self.update_status("Refreshing sessions...")
        await self.refresh_sessions()
        await self.update_status("Sessions refreshed")
        
    async def update_status(self, message: str) -> None:
        """Update the status bar."""
        status_bar = self.query_one("#status", Static)
        status_bar.update(message)


def main() -> None:
    """Main entry point for the tpik application."""
    app = TpikApp()
    app.run()


if __name__ == "__main__":
    main()