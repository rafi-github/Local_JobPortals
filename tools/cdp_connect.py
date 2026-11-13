"""Shared Playwright CDP connect with bounded timeout + retries (avoids 180s hangs)."""
from __future__ import annotations

import os
import time
from typing import Any


def connect_over_cdp(
    chromium: Any,
    url: str,
    *,
    retries: int | None = None,
    timeout_ms: int | None = None,
) -> Any:
    retries = retries if retries is not None else int(os.environ.get("CDP_CONNECT_RETRIES", "3"))
    timeout_ms = timeout_ms if timeout_ms is not None else int(
        os.environ.get("CDP_CONNECT_TIMEOUT_MS", "25000")
    )
    last: Exception | None = None
    for attempt in range(max(1, retries)):
        try:
            return chromium.connect_over_cdp(url, timeout=timeout_ms)
        except Exception as exc:  # noqa: BLE001 — surface last Playwright error
            last = exc
            if attempt + 1 < retries:
                time.sleep(2 + attempt)
    assert last is not None
    raise last
