#!/usr/bin/env python3
"""Project checked catalog JSON from normative PTO-INSTRUCTION metadata."""

from __future__ import annotations

import argparse
import json
import sys
import tomllib
from pathlib import Path
from typing import Sequence

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from scripts.asl_units import AslUnit, load_units  # noqa: E402


CATALOG_PATHS = (
    Path("spec/catalog/scalar-forms.json"),
    Path("spec/catalog/command-forms.json"),
    Path("spec/catalog/tile-operations.json"),
    Path("spec/catalog/linx-vector-reservations.json"),
)

SURFACE_CATALOG = {
    "scalar": "scalar-forms",
    "block": "command-forms",
    "tile": "tile-operations",
}

PROJECTION_CATALOGS = frozenset(
    (*SURFACE_CATALOG.values(), "linx-vector-reservations")
)


def _render(value: dict[str, object]) -> bytes:
    return (json.dumps(value, indent=2, ensure_ascii=False) + "\n").encode()


def _projection_envelopes(units: Sequence[AslUnit]) -> dict[str, dict[str, object]]:
    envelopes: dict[str, dict[str, object]] = {}
    for unit in units:
        projection = unit.metadata.get("catalog_projection")
        if projection is None:
            continue
        if not isinstance(projection, dict):
            raise ValueError(
                f"{unit.source_path}: catalog_projection must be an object"
            )
        catalog = projection.get("catalog")
        if not isinstance(catalog, str) or catalog not in PROJECTION_CATALOGS:
            raise ValueError(
                f"{unit.source_path}: invalid projected catalog name {catalog!r}"
            )
        if catalog in envelopes:
            raise ValueError(f"duplicate catalog projection envelope: {catalog}")
        envelopes[catalog] = projection
    missing = sorted(PROJECTION_CATALOGS - set(envelopes))
    if missing:
        raise ValueError(f"missing catalog projection envelope: {', '.join(missing)}")
    return envelopes


def _indexed_records(units: Sequence[AslUnit]) -> dict[str, list[dict[str, object]]]:
    slots: dict[str, dict[int, tuple[dict[str, object], Path]]] = {
        catalog: {} for catalog in SURFACE_CATALOG.values()
    }
    for unit in units:
        indices = unit.metadata.get("catalog_indices")
        records = unit.metadata.get("catalog_records")
        if indices is None and records is None:
            continue
        if unit.surface not in SURFACE_CATALOG:
            raise ValueError(
                f"{unit.source_path}: catalog records are not valid on {unit.surface}"
            )
        if not isinstance(indices, list) or any(
            not isinstance(index, int) or index < 0 for index in indices
        ):
            raise ValueError(
                f"{unit.source_path}: catalog_indices must be nonnegative integers"
            )
        if not isinstance(records, list) or any(
            not isinstance(record, dict) for record in records
        ):
            raise ValueError(f"{unit.source_path}: catalog_records must be objects")
        if len(indices) != len(records):
            raise ValueError(
                f"{unit.source_path}: catalog_indices and catalog_records lengths differ"
            )
        catalog = SURFACE_CATALOG[unit.surface]
        for index, record in zip(indices, records, strict=True):
            existing = slots[catalog].get(index)
            if existing is not None:
                existing_record, existing_path = existing
                if existing_record != record:
                    raise ValueError(
                        f"conflicting catalog record for {catalog} slot {index}: "
                        f"{existing_path} and {unit.source_path}"
                    )
                raise ValueError(
                    f"duplicate catalog slot for {catalog} slot {index}: "
                    f"{existing_path} and {unit.source_path}"
                )
            slots[catalog][index] = (record, unit.source_path)

    ordered: dict[str, list[dict[str, object]]] = {}
    for catalog, indexed in slots.items():
        if not indexed:
            raise ValueError(f"missing catalog records: {catalog}")
        expected = set(range(max(indexed) + 1))
        missing = sorted(expected - set(indexed))
        if missing:
            rendered = ", ".join(str(index) for index in missing[:8])
            suffix = " ..." if len(missing) > 8 else ""
            raise ValueError(f"missing catalog slot for {catalog}: {rendered}{suffix}")
        ordered[catalog] = [indexed[index][0] for index in range(len(indexed))]
    return ordered


def _field_counts(forms: list[dict[str, object]]) -> tuple[int, int]:
    names: set[str] = set()
    pieces = 0
    for form in forms:
        fields = form.get("fields", [])
        if not isinstance(fields, list):
            raise ValueError(
                f"invalid fields in catalog form {form.get('form_id', '<unknown>')}"
            )
        for field in fields:
            if not isinstance(field, dict) or not isinstance(field.get("name"), str):
                raise ValueError(
                    f"invalid catalog field in form {form.get('form_id', '<unknown>')}"
                )
            names.add(field["name"])
            field_pieces = field.get("pieces", [])
            if not isinstance(field_pieces, list):
                raise ValueError(
                    f"invalid field pieces in form {form.get('form_id', '<unknown>')}"
                )
            pieces += len(field_pieces)
    return len(names), pieces


def _constraint_count(forms: list[dict[str, object]]) -> int:
    return sum(len(form.get("constraints", [])) for form in forms)


def _handler_count(forms: list[dict[str, object]]) -> int:
    return len({form["semantic_handler"] for form in forms})


def project_catalogs(
    units: Sequence[AslUnit], release: str | None = None
) -> dict[Path, bytes]:
    """Return deterministic catalog projections keyed by repository-relative path."""

    envelopes = _projection_envelopes(units)
    records = _indexed_records(units)

    scalar_forms = records["scalar-forms"]
    scalar_envelope = envelopes["scalar-forms"]
    family_constraints = scalar_envelope.get("family_constraints", [])
    if not isinstance(family_constraints, list):
        raise ValueError("scalar family_constraints must be an array")
    scalar_fields, scalar_pieces = _field_counts(scalar_forms)
    scalar = {
        "family_constraint_application_count": sum(
            len(constraint.get("applies_to", []))
            for constraint in family_constraints
            if isinstance(constraint, dict)
        ),
        "family_constraint_count": len(family_constraints),
        "family_constraints": family_constraints,
        "form_constraint_count": _constraint_count(scalar_forms),
        "form_count": len(scalar_forms),
        "forms": scalar_forms,
        "isa": scalar_envelope["isa"],
        "operand_field_count": scalar_fields,
        "operand_piece_count": scalar_pieces,
        "schema_version": scalar_envelope["schema_version"],
        "semantic_handler_count": _handler_count(scalar_forms),
    }

    command_forms = records["command-forms"]
    command_envelope = envelopes["command-forms"]
    command_fields, command_pieces = _field_counts(command_forms)
    command = {
        "form_count": len(command_forms),
        "form_constraint_count": _constraint_count(command_forms),
        "forms": command_forms,
        "isa": command_envelope["isa"],
        "operand_field_count": command_fields,
        "operand_piece_count": command_pieces,
        "reviewed_encoding_overlaps": command_envelope["reviewed_encoding_overlaps"],
        "schema_version": command_envelope["schema_version"],
        "semantic_handler_count": _handler_count(command_forms),
        "surface": command_envelope["surface"],
    }

    tile_operations = records["tile-operations"]
    tile_envelope = envelopes["tile-operations"]
    tile = {
        "isa": tile_envelope["isa"],
        "operation_count": len(tile_operations),
        "rejected_review_only_codes": tile_envelope["rejected_review_only_codes"],
        "operations": tile_operations,
        "reserved": tile_envelope["reserved"],
        "schema_version": tile_envelope["schema_version"],
        "deleted_names": tile_envelope["deleted_names"],
        "rejected_names": tile_envelope["rejected_names"],
    }

    reservation_envelope = envelopes["linx-vector-reservations"]
    reservations = reservation_envelope["reservations"]
    if not isinstance(reservations, list) or any(
        not isinstance(reservation, dict) for reservation in reservations
    ):
        raise ValueError("linx-vector-reservations reservations must be objects")
    if release is None:
        specification = tomllib.loads(
            (ROOT / "specification.toml").read_text(encoding="utf-8")
        )
        release = specification["release"]["architecture_version"]
    vector_reservations = {
        "isa": reservation_envelope["isa"],
        "release": release,
        "reservation_count": len(reservations),
        "reservations": reservations,
        "schema_version": reservation_envelope["schema_version"],
    }

    return {
        CATALOG_PATHS[0]: _render(scalar),
        CATALOG_PATHS[1]: _render(command),
        CATALOG_PATHS[2]: _render(tile),
        CATALOG_PATHS[3]: _render(vector_reservations),
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=ROOT)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--write", action="store_true")
    mode.add_argument("--check", action="store_true")
    arguments = parser.parse_args(argv)
    try:
        specification_path = arguments.root / "specification.toml"
        release = None
        if specification_path.exists():
            specification = tomllib.loads(
                specification_path.read_text(encoding="utf-8")
            )
            release = specification["release"]["architecture_version"]
        projected = project_catalogs(
            load_units(arguments.root / "asl"),
            release,
        )
    except (OSError, ValueError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    stale: list[Path] = []
    for path, content in projected.items():
        target = arguments.root / path
        if arguments.write:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(content)
        elif not target.exists() or target.read_bytes() != content:
            stale.append(path)
    if stale:
        print(
            "error: stale projected catalogs: "
            + ", ".join(path.as_posix() for path in stale),
            file=sys.stderr,
        )
        return 1
    action = "wrote" if arguments.write else "catalog projections are current:"
    print(f"{action} {', '.join(path.as_posix() for path in CATALOG_PATHS)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
