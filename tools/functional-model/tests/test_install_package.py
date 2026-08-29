#!/usr/bin/env python3
"""Install, relocate, and exercise the exported functional-model package."""

from __future__ import annotations

import argparse
from pathlib import Path
import shutil
import subprocess
import tempfile


def run(command: list[str]) -> None:
    subprocess.run(command, check=True)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--cmake", required=True)
    parser.add_argument("--build-dir", type=Path, required=True)
    parser.add_argument("--consumer", type=Path, required=True)
    arguments = parser.parse_args()

    with tempfile.TemporaryDirectory(prefix="pto-asl-package-") as temporary:
        root = Path(temporary)
        first = root / "first-prefix"
        relocated = root / "relocated-prefix"
        consumer_build = root / "consumer-build"
        run([arguments.cmake, "--install", str(arguments.build_dir),
             "--prefix", str(first)])
        shutil.copytree(first, relocated)
        shutil.rmtree(first)

        cmake_files = list(relocated.rglob("*.cmake"))
        forbidden = (str(arguments.build_dir), str(arguments.consumer.parent.parent))
        for cmake_file in cmake_files:
            content = cmake_file.read_text(encoding="utf-8")
            for path in forbidden:
                if path in content:
                    raise RuntimeError(
                        f"installed package leaks absolute path {path}: {cmake_file}"
                    )

        run([arguments.cmake, "-S", str(arguments.consumer), "-B",
             str(consumer_build), f"-DCMAKE_PREFIX_PATH={relocated}"])
        run([arguments.cmake, "--build", str(consumer_build), "--parallel", "2"])
        run([str(consumer_build / "package_consumer_c")])
        run([str(consumer_build / "package_consumer_cpp")])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
