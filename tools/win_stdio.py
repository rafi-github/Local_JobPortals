"""UTF-8 stdout/stderr for Windows consoles that default to cp1252.

pythoncore (and other Windows CPython) uses the ANSI code page when Git Bash
launches it without a console. print() of a non-ASCII status character then
raises UnicodeEncodeError and aborts the portal before apply.
"""
from __future__ import annotations

import sys


def configure_windows_stdio() -> None:
    """Reconfigure stdout/stderr to utf-8 with errors=replace. No-op off Windows."""
    if sys.platform != "win32":
        return
    for stream in (sys.stdout, sys.stderr):
        if stream is None or not hasattr(stream, "reconfigure"):
            continue
        try:
            stream.reconfigure(encoding="utf-8", errors="replace")
        except Exception:
            pass
