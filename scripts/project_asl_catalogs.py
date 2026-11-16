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
from scripts.tile_taxonomy import derive_tile_catalog_record  # noqa: E402


CATALOG_PATHS = (
    Path("spec/catalog/scalar-forms.json"),
    Path("spec/catalog/command-forms.json"),
    Path("spec/catalog/tile-operations.json"),
    Path("spec/catalog/extension-encoding-reservations.json"),
    Path("spec/catalog/system-registers.json"),
)

SURFACE_CATALOG = {
    "scalar": "scalar-forms",
    "block": "command-forms",
    "tile": "tile-operations",
}

PROJECTION_CATALOGS = frozenset(
    (*SURFACE_CATALOG.values(), "extension-encoding-reservations", "system-registers")
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
            projected_record = dict(record)
            if unit.surface == "tile":
                try:
                    projected_record = derive_tile_catalog_record(
                        record,
                        classification=unit.classification[0],
                        engine=unit.metadata.get("engine"),
                    )
                except ValueError as error:
                    raise ValueError(f"{unit.source_path}: {error}") from error
            existing = slots[catalog].get(index)
            if existing is not None:
                existing_record, existing_path = existing
                if existing_record != projected_record:
                    raise ValueError(
                        f"conflicting catalog record for {catalog} slot {index}: "
                        f"{existing_path} and {unit.source_path}"
                    )
                raise ValueError(
                    f"duplicate catalog slot for {catalog} slot {index}: "
                    f"{existing_path} and {unit.source_path}"
                )
            slots[catalog][index] = (projected_record, unit.source_path)

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


_SCALAR_SHAREABILITY_CODES = {
    "Private": 0,
    "IntraCore": 1,
    "InterCore": 2,
}
_SCALAR_SHAREABILITY_SUFFIXES = {
    "Private": "private",
    "IntraCore": "intra",
    "InterCore": "inter",
}


def _scoped_scalar_forms(forms: list[dict[str, object]]) -> list[dict[str, object]]:
    """Derive the fixed 64-bit Scalar shareability envelope from source forms.

    The mnemonic metadata remains the authority for each inner operation.  This
    projection shifts its exact encoding and operand pieces into bits[63:16],
    fixes the r2 carrier/length fields, and records the original catalog row as
    the sole semantic binding.
    """

    scoped: list[dict[str, object]] = []
    for base_index, base in enumerate(forms):
        family = base.get("semantic_family")
        agu_action = base.get("agu", {}).get("action") if isinstance(base.get("agu"), dict) else None
        covered = (
            family == "AGU" and agu_action in {"Load", "LoadPair", "Store", "StorePair"}
        ) or (family == "AMO" and base.get("mnemonic") != "DMA")
        if not covered:
            continue

        inner_length = base.get("length_bits")
        if inner_length not in {16, 32, 48}:
            raise ValueError(
                f"covered Scalar form has unsupported length: {base.get('form_id')}"
            )
        source_encoding = base.get("encoding")
        if not isinstance(source_encoding, list) or not source_encoding:
            raise ValueError(f"covered Scalar form has no encoding: {base.get('form_id')}")
        source_mask = 0
        source_match = 0
        for part in source_encoding:
            if not isinstance(part, dict):
                raise ValueError(f"invalid encoding part in {base.get('form_id')}")
            part_index = part.get("index")
            part_width = part.get("width_bits")
            if not isinstance(part_index, int) or part_index not in {0, 1}:
                raise ValueError(f"invalid encoding index in {base.get('form_id')}")
            if part_width not in {16, 32, 48}:
                raise ValueError(f"invalid encoding width in {base.get('form_id')}")
            source_mask |= int(part["mask"], 16) << (part_index * 32)
            source_match |= int(part["match"], 16) << (part_index * 32)

        if source_mask >> inner_length or source_match >> inner_length:
            raise ValueError(
                f"inner encoding exceeds declared length in {base.get('form_id')}"
            )
        shifted_mask = source_mask << 16
        shifted_match = source_match << 16
        padding_mask = ((1 << (48 - inner_length)) - 1) << (16 + inner_length)
        length_code = {16: 0, 32: 1, 48: 2}[inner_length]
        fields: list[dict[str, object]] = [
            {
                "name": "Shareability",
                "pieces": [{"instruction_lsb": 8, "value_lsb": 0, "width": 2}],
                "signedness": "unsigned",
                "width": 2,
            },
            {
                "name": "InnerLength",
                "pieces": [{"instruction_lsb": 10, "value_lsb": 0, "width": 2}],
                "signedness": "unsigned",
                "width": 2,
            },
        ]
        for field in base.get("fields", []):
            shifted_field = dict(field)
            shifted_field["pieces"] = [
                {**piece, "instruction_lsb": piece["instruction_lsb"] + 16}
                for piece in field["pieces"]
            ]
            fields.append(shifted_field)

        scoped_mask = 0xF0FF | padding_mask | shifted_mask
        # Scope and inner-length values are fixed per generated form while the
        # carrier family mask remains 0xf0ff / 0x001f in the NDF owner.
        scoped_mask |= 0x0F00
        scoped_forms_for_base: list[dict[str, object]] = []
        for scope_name, scope_code in _SCALAR_SHAREABILITY_CODES.items():
            scoped_match = (
                0x001F
                | (scope_code << 8)
                | (length_code << 10)
                | shifted_match
            )
            encoding = [
                {
                    "index": index,
                    "mask": f"0x{(scoped_mask >> (index * 32)) & 0xFFFFFFFF:08x}",
                    "match": f"0x{(scoped_match >> (index * 32)) & 0xFFFFFFFF:08x}",
                    "width_bits": 32,
                }
                for index in (0, 1)
            ]
            shifted_constraints = [dict(item) for item in base.get("constraints", [])]
            asm = str(base.get("asm", base["mnemonic"].lower()))
            head, separator, tail = asm.partition(" ")
            scoped_asm = (
                f"{head}.{_SCALAR_SHAREABILITY_SUFFIXES[scope_name]}"
                f"{separator}{tail}"
            )
            scoped_fields = [
                dict(field)
                for field in fields
            ]
            form = {
                "base_form_id": base["form_id"],
                "base_form_index": base_index,
                "constraints": shifted_constraints,
                "encoding": encoding,
                "encoding_kind": "SCOPED64",
                "fields": scoped_fields,
                "form_id": f"{base['form_id']}_scoped_{_SCALAR_SHAREABILITY_SUFFIXES[scope_name]}",
                "inner_length_bits": inner_length,
                "length_bits": 64,
                "mnemonic": base["mnemonic"],
                "scope": scope_name,
                "scope_code": scope_code,
                "semantic_family": family,
                "semantic_group": base.get("semantic_group"),
                "semantic_handler": base["semantic_handler"],
                "semantic_summary": base.get("semantic_summary", base.get("summary", "")),
                "status": "accepted",
                "asm": scoped_asm,
                "assembly": [scoped_asm],
                "operands": [
                    {"field": "Shareability", "role": "effective GM shareability"},
                    {"field": "InnerLength", "role": "wrapped instruction length"},
                    *[dict(operand) for operand in base.get("operands", [])],
                ],
            }
            # Keep the generator's exact mask/match witness math reviewable.
            if len(encoding) != 2 or any(
                int(part["mask"], 16) & int(part["match"], 16)
                != int(part["match"], 16)
                for part in encoding
            ):
                raise ValueError(f"invalid scoped encoding projection for {form['form_id']}")
            scoped_forms_for_base.append(form)
        scoped.extend(scoped_forms_for_base)
    return scoped


def _encoding_alternatives(row: dict[str, object]) -> list[list[dict[str, object]]]:
    return [
        row["encoding"],
        *[
            variant["encoding"]
            for variant in row.get("encoding_variants", [])
            if isinstance(variant, dict)
        ],
    ]


def _forms_encoding_overlap(
    left: dict[str, object], right: dict[str, object]
) -> bool:
    if left.get("length_bits") != right.get("length_bits"):
        return False
    for left_encoding in _encoding_alternatives(left):
        for right_encoding in _encoding_alternatives(right):
            left_parts = {part["index"]: part for part in left_encoding}
            right_parts = {part["index"]: part for part in right_encoding}
            compatible = True
            for index in left_parts.keys() | right_parts.keys():
                left_part = left_parts.get(index)
                right_part = right_parts.get(index)
                left_mask = int(left_part["mask"], 16) if left_part else 0
                right_mask = int(right_part["mask"], 16) if right_part else 0
                left_match = int(left_part["match"], 16) if left_part else 0
                right_match = int(right_part["match"], 16) if right_part else 0
                if (left_match ^ right_match) & left_mask & right_mask:
                    compatible = False
                    break
            if compatible:
                return True
    return False


def project_catalogs(
    units: Sequence[AslUnit], release: str | None = None
) -> dict[Path, bytes]:
    """Return deterministic catalog projections keyed by repository-relative path."""

    envelopes = _projection_envelopes(units)
    records = _indexed_records(units)

    scalar_forms = records["scalar-forms"]
    scoped_scalar_forms = _scoped_scalar_forms(scalar_forms)
    command_forms = records["command-forms"]
    reservation_rows = envelopes["extension-encoding-reservations"].get(
        "reservations", []
    )
    for scoped_form in scoped_scalar_forms:
        for occupied in [*command_forms, *reservation_rows]:
            if _forms_encoding_overlap(scoped_form, occupied):
                raise ValueError(
                    "scoped Scalar encoding overlaps an allocated command or "
                    f"reservation: {scoped_form['form_id']} / "
                    f"{occupied.get('form_id', occupied.get('mnemonic', '<unknown>'))}"
                )
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
        "reviewed_encoding_overlaps": scalar_envelope["reviewed_encoding_overlaps"],
        "schema_version": scalar_envelope["schema_version"],
        "semantic_handler_count": _handler_count(scalar_forms),
        "scoped_form_count": len(scoped_scalar_forms),
        "scoped_forms": scoped_scalar_forms,
    }

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

    reservation_envelope = envelopes["extension-encoding-reservations"]
    reservations = reservation_envelope["reservations"]
    if not isinstance(reservations, list) or any(
        not isinstance(reservation, dict) for reservation in reservations
    ):
        raise ValueError("extension-encoding-reservations reservations must be objects")
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

    sysreg_envelope = envelopes["system-registers"]
    sysreg_registers = sysreg_envelope["registers"]
    sysreg_traps = sysreg_envelope["trap_numbers"]
    if not isinstance(sysreg_registers, list) or not isinstance(sysreg_traps, list):
        raise ValueError("system-registers registers/trap_numbers must be arrays")
    system_registers = {
        "system_register_address_bits": sysreg_envelope["system_register_address_bits"],
        "system_register_file_index_bits": sysreg_envelope["system_register_file_index_bits"],
        "isa": sysreg_envelope["isa"],
        "register_definition_count": len(sysreg_registers),
        "registers": sysreg_registers,
        "behavior_classes": sysreg_envelope["behavior_classes"],
        "schema_version": sysreg_envelope["schema_version"],
        "trap_count": len(sysreg_traps),
        "trap_numbers": sysreg_traps,
    }

    return {
        CATALOG_PATHS[0]: _render(scalar),
        CATALOG_PATHS[1]: _render(command),
        CATALOG_PATHS[2]: _render(tile),
        CATALOG_PATHS[3]: _render(vector_reservations),
        CATALOG_PATHS[4]: _render(system_registers),
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
