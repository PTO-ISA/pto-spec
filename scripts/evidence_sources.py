#!/usr/bin/env python3
"""Build deterministic source-hash rows for generated evidence."""

from __future__ import annotations

import hashlib
from pathlib import Path


def source_rows(root: Path, *patterns: str) -> list[dict[str, str]]:
    """Expand repository-relative files/globs into ordered, unique hash rows."""

    rows: list[dict[str, str]] = []
    seen: set[Path] = set()
    for pattern in patterns:
        matches = sorted(root.glob(pattern))
        if not matches:
            raise ValueError(f"source pattern has no matches: {pattern}")
        for path in matches:
            if not path.is_file():
                continue
            relative = path.relative_to(root)
            if relative in seen:
                raise ValueError(f"duplicate evidence source: {relative.as_posix()}")
            seen.add(relative)
            rows.append(
                {
                    "path": relative.as_posix(),
                    "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                }
            )
    return rows
