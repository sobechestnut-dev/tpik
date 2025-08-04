"""
tpik - Enhanced TMUX Session Picker with beautiful TUI interface

A modern, responsive terminal user interface for managing tmux sessions
with features like favorites, templates, search, and smart session handling.
"""

__version__ = "3.0.0"
__author__ = "sobechestnut-dev"
__email__ = "nathaniel.chestnut@gmail.com"

from .app import TpikApp

__all__ = ["TpikApp"]