#!/usr/bin/env python3
"""
Simple tpik TUI for testing - minimal viable version
"""

import subprocess
import sys
from typing import List, Optional

from textual.app import App, ComposeResult
from textual.containers import Container, Vertical
from textual.widgets import Header, Footer, Static, Button, ListView, ListItem, Label
from textual.reactive import reactive
from textual import events


class TmuxSession:
    """Simple tmux session representation."""
    
    def __init__(self, name: str, attached: bool = False):
        self.name = name
        self.attached = attached
        
    def __str__(self) -> str:
        status = "●" if self.attached else " "
        return f"{status} {self.name}"


class SimpleTpikApp(App):
    """Simple tpik TUI application."""
    
    TITLE = "tpik - Simple TMUX Session Picker"
    
    def __init__(self):
        super().__init__()
        self.sessions: List[TmuxSession] = []
        
    def compose(self) -> ComposeResult:
        """Compose the main UI."""
        yield Header()
        
        with Container():
            yield Static("TMUX Sessions:", id="title")
            yield ListView(id="sessions")
            
            yield Button("Attach", id="attach", variant="primary")
            yield Button("Refresh", id="refresh")  
            yield Button("Quit", id="quit")
            
        yield Footer()
        
    async def on_mount(self) -> None:
        """Initialize the app."""
        await self.refresh_sessions()
        
    async def refresh_sessions(self) -> None:
        """Get tmux sessions."""
        try:
            result = subprocess.run(
                ["tmux", "list-sessions", "-F", "#{session_name}|#{session_attached}"],
                capture_output=True, text=True, check=True
            )
            
            self.sessions = []
            for line in result.stdout.strip().split("\n"):
                if line:
                    name, attached = line.split("|")
                    session = TmuxSession(name, attached == "1")
                    self.sessions.append(session)
                    
        except subprocess.CalledProcessError:
            self.sessions = []
            
        # Update the list view
        list_view = self.query_one("#sessions", ListView)
        list_view.clear()
        
        for session in self.sessions:
            list_view.append(ListItem(Label(str(session))))
            
    async def on_button_pressed(self, event: Button.Pressed) -> None:
        """Handle button presses."""
        if event.button.id == "refresh":
            await self.refresh_sessions()
        elif event.button.id == "quit":
            await self.action_quit()
        elif event.button.id == "attach":
            await self.attach_selected()
            
    async def attach_selected(self) -> None:
        """Attach to selected session."""
        list_view = self.query_one("#sessions", ListView)
        if list_view.index is not None and 0 <= list_view.index < len(self.sessions):
            session = self.sessions[list_view.index]
            
            try:
                subprocess.run(["tmux", "attach-session", "-t", session.name], check=True)
                await self.action_quit()
            except subprocess.CalledProcessError:
                pass  # Handle error
                
    async def on_key(self, event: events.Key) -> None:
        """Handle keyboard shortcuts."""
        if event.key == "q":
            await self.action_quit()
        elif event.key == "enter":
            await self.attach_selected()
        elif event.key == "r":
            await self.refresh_sessions()


def main() -> None:
    """Main entry point."""
    app = SimpleTpikApp()
    app.run()


if __name__ == "__main__":
    main()