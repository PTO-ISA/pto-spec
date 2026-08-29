#!/usr/bin/env python3
"""Negative and determinism checks for the G3a runtime-image emitter."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import subprocess
import sys
import tempfile


def emit(emitter: Path, image: Path, cases: Path, output: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [
            sys.executable,
            str(emitter),
            "--input",
            str(image),
            "--header",
            str(output / "image.h"),
            "--source",
            str(output / "image.cpp"),
            "--cases",
            str(cases),
            "--cases-header",
            str(output / "cases.h"),
        ],
        check=False,
        text=True,
        capture_output=True,
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--emitter", type=Path, required=True)
    parser.add_argument("--image", type=Path, required=True)
    parser.add_argument("--cases", type=Path, required=True)
    arguments = parser.parse_args()

    document = json.loads(arguments.image.read_bytes())
    with tempfile.TemporaryDirectory(prefix="pto-runtime-emitter-") as temporary:
        root = Path(temporary)
        first = root / "first"
        second = root / "second"
        first.mkdir()
        second.mkdir()
        assert emit(arguments.emitter, arguments.image, arguments.cases, first).returncode == 0
        assert emit(arguments.emitter, arguments.image, arguments.cases, second).returncode == 0
        for name in ("image.h", "image.cpp", "cases.h"):
            assert (first / name).read_bytes() == (second / name).read_bytes()

        tampered = dict(document)
        tampered["schema_version"] = 99
        tampered_path = root / "tampered.json"
        tampered_path.write_text(json.dumps(tampered), encoding="utf-8")
        assert emit(
            arguments.emitter, tampered_path, arguments.cases, root / "tampered"
        ).returncode != 0

        unsupported = json.loads(arguments.image.read_bytes())
        for row in unsupported["tables"]["constructors"]:
            if row["name"] == "S_Cond":
                row["name"] = "S_RuntimeUnsupported"
                break
        unsupported_path = root / "unsupported.json"
        unsupported_path.write_text(json.dumps(unsupported), encoding="utf-8")
        result = emit(
            arguments.emitter,
            unsupported_path,
            arguments.cases,
            root / "unsupported",
        )
        assert result.returncode != 0
        assert "unsupported reachable runtime statement" in result.stderr
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
