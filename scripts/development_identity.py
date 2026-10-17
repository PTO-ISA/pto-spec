"""Current-source encoding identity, explicitly independent of publication."""

from collections import Counter
import hashlib
import importlib.machinery
import importlib.util
import json
from pathlib import Path
import tomllib

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = Path("spec/development-manifest.json")
CATALOGS = {
    "scalar_forms": "spec/catalog/scalar-forms.json",
    "command_forms": "spec/catalog/command-forms.json",
    "tile_operations": "spec/catalog/tile-operations.json",
    "reservations": "spec/catalog/extension-encoding-reservations.json",
    "system_registers": "spec/catalog/system-registers.json",
}


def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(",", ":")).encode()).hexdigest()


def generator(root):
    loader = importlib.machinery.SourceFileLoader("pto_release_identity", str(root / "scripts/generate-release-manifest"))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


def build(root=ROOT):
    metadata = tomllib.loads((root / "specification.toml").read_text())
    catalogs = {name: json.loads((root / path).read_text()) for name, path in CATALOGS.items()}
    counts = {name: len(catalogs[name]["forms"]) for name in ("scalar_forms", "command_forms")}
    for name, count in counts.items():
        if count != metadata["architecture"][name] or count != catalogs[name]["form_count"]:
            raise ValueError(f"current source inventory disagrees: {name}")
    tiles = catalogs["tile_operations"]
    if len(tiles["operations"]) != metadata["architecture"]["pto_operations"]:
        raise ValueError("current source Tile inventory disagrees")
    release = generator(root)
    projection = release.encoding_projection(
        tiles, form_counts=counts,
        command_family_counts=dict(Counter(row["semantic_family"] for row in catalogs["command_forms"]["forms"])),
    )
    sources = {
        path.relative_to(root).as_posix(): hashlib.sha256(path.read_bytes()).hexdigest()
        for path in sorted((root / "asl").rglob("*.asl"))
    }
    return {
        "schema": "pto.development-manifest.v1",
        "status": "development-not-published",
        "publication": None,
        "identity": {
            "release": metadata["release"]["architecture_version"],
            "encoding_abi": metadata["release"]["encoding_abi"],
            "encoding_projection_sha256": digest(projection),
        },
        "catalog_counts": {**counts, "tile_operations": len(tiles["operations"]),
                           "reservations": len(catalogs["reservations"]["reservations"])},
        "catalogs": {name: {"path": path, "sha256": hashlib.sha256((root / path).read_bytes()).hexdigest()}
                     for name, path in CATALOGS.items()},
        "normative_sources_sha256": digest(sources),
        "normative_source_count": len(sources),
    }


def main():
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    expected = json.dumps(build(), indent=2, sort_keys=True) + "\n"
    if args.check:
        if not (ROOT / OUTPUT).exists() or (ROOT / OUTPUT).read_text() != expected:
            raise SystemExit("stale development identity; run scripts/development_identity.py")
    else:
        (ROOT / OUTPUT).write_text(expected)
    print("OK: current-source development identity; no publication authority")


if __name__ == "__main__":
    main()
