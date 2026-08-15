#!/usr/bin/env python3
"""Resolve and validate ASL-owned instruction and encoded-field contracts."""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Mapping, Sequence

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from scripts.asl_units import AslUnit, load_units  # noqa: E402


ENCODING_CLASSES = frozenset(
    {
        "standalone-encoded",
        "encoding-alias",
        "selector-encoded-block-operation",
        "unencoded-architectural-operation",
        "indirect-architectural-name",
    }
)
PLACEHOLDER_TEXT = re.compile(
    r"(?:encoded operand or control|this mnemonic|Execute the .* instruction contract)",
    re.IGNORECASE,
)

def _non_empty_string(value: object, *, label: str, source: Path) -> str:
    if not isinstance(value, str) or not value.strip():
        raise ValueError(f"{source}: {label} must be a non-empty string")
    return value.strip()


def _string_tuple(
    value: object,
    *,
    label: str,
    source: Path,
    allow_duplicates: bool = False,
) -> tuple[str, ...]:
    if not isinstance(value, list) or not value:
        raise ValueError(f"{source}: {label} must be a non-empty string array")
    result = tuple(
        _non_empty_string(item, label=f"{label} item", source=source) for item in value
    )
    if not allow_duplicates and len(set(result)) != len(result):
        raise ValueError(f"{source}: {label} contains duplicate entries")
    return result


@dataclass(frozen=True)
class FieldDomainContract:
    contract_id: str
    width: int
    role: str
    zero_meaning: str
    assigned: tuple[tuple[int, str], ...]
    reserved: tuple[int, ...]
    rejection: str
    source_path: Path

    @classmethod
    def from_metadata(
        cls, metadata: Mapping[str, object], source_path: Path
    ) -> "FieldDomainContract":
        contract_id = _non_empty_string(
            metadata.get("id"), label="field-domain id", source=source_path
        )
        width = metadata.get("width")
        if not isinstance(width, int) or isinstance(width, bool) or width <= 0:
            raise ValueError(f"{source_path}: {contract_id} width must be a positive integer")
        raw_assigned = metadata.get("assigned")
        if not isinstance(raw_assigned, list) or not raw_assigned:
            raise ValueError(f"{source_path}: {contract_id} assigned must be a non-empty array")
        assigned: list[tuple[int, str]] = []
        for index, row in enumerate(raw_assigned):
            if not isinstance(row, dict):
                raise ValueError(
                    f"{source_path}: {contract_id} assigned row {index} must be an object"
                )
            value = row.get("value")
            if not isinstance(value, int) or isinstance(value, bool):
                raise ValueError(
                    f"{source_path}: {contract_id} assigned row {index} value must be an integer"
                )
            meaning = _non_empty_string(
                row.get("meaning"),
                label=f"{contract_id} assigned row {index} meaning",
                source=source_path,
            )
            assigned.append((value, meaning))
        raw_reserved = metadata.get("reserved")
        if not isinstance(raw_reserved, list) or any(
            not isinstance(value, int) or isinstance(value, bool)
            for value in raw_reserved
        ):
            raise ValueError(f"{source_path}: {contract_id} reserved must be an integer array")
        return cls(
            contract_id=contract_id,
            width=width,
            role=_non_empty_string(
                metadata.get("role"), label=f"{contract_id} role", source=source_path
            ),
            zero_meaning=_non_empty_string(
                metadata.get("zero_meaning"),
                label=f"{contract_id} zero_meaning",
                source=source_path,
            ),
            assigned=tuple(assigned),
            reserved=tuple(raw_reserved),
            rejection=_non_empty_string(
                metadata.get("rejection"),
                label=f"{contract_id} rejection",
                source=source_path,
            ),
            source_path=source_path,
        )


@dataclass(frozen=True)
class EncodedFieldDisposition:
    """Total assigned/reserved disposition for one encoded field in one form."""

    form_id: str
    field_name: str
    width: int
    signedness: str
    role: str
    zero_meaning: str
    assigned_ranges: tuple[tuple[int, int], ...]
    other_owner_values: tuple[tuple[int, str], ...]
    reserved_ranges: tuple[tuple[int, int], ...]
    rejection: str


@dataclass(frozen=True)
class ResolvedInstructionContract:
    encoding_class: str
    canonical_assembly: tuple[str, ...]
    field_domains: tuple[tuple[str, FieldDomainContract], ...]
    encoded_fields: tuple[EncodedFieldDisposition, ...]
    operands: tuple[dict[str, object], ...]
    defaults: tuple[str, ...]
    legality: tuple[str, ...]
    state_effects: tuple[str, ...]
    memory_effects: tuple[str, ...]
    ordering: tuple[str, ...]
    exceptions: tuple[str, ...]
    examples: tuple[str, ...]
    block_composition: tuple[str, ...]
    standalone_opcode: bool


def _compact_ranges(values: set[int]) -> tuple[tuple[int, int], ...]:
    if not values:
        return ()
    ordered = sorted(values)
    ranges: list[tuple[int, int]] = []
    start = previous = ordered[0]
    for value in ordered[1:]:
        if value == previous + 1:
            previous = value
            continue
        ranges.append((start, previous))
        start = previous = value
    ranges.append((start, previous))
    return tuple(ranges)


def _complement_ranges(
    values: set[int], maximum_value: int
) -> tuple[tuple[int, int], ...]:
    """Return compact ranges not present in a bounded, usually sparse set."""

    ranges: list[tuple[int, int]] = []
    next_value = 0
    for value in sorted(values):
        if next_value < value:
            ranges.append((next_value, value - 1))
        next_value = value + 1
    if next_value <= maximum_value:
        ranges.append((next_value, maximum_value))
    return tuple(ranges)


def derive_encoded_field_dispositions(
    unit: AslUnit,
    operands: tuple[dict[str, object], ...],
    *,
    zero_meanings: Mapping[str, str] | None = None,
) -> tuple[EncodedFieldDisposition, ...]:
    """Derive complete encoded-field domains from ASL-owned forms and constraints."""

    roles: dict[str, str] = {}
    for operand in operands:
        field_name = str(operand["field"])
        role = str(operand["role"])
        previous = roles.setdefault(field_name, role)
        if previous != role:
            raise ValueError(
                f"{unit.source_path}: encoded field {field_name} has conflicting roles"
            )
    zero_meanings = zero_meanings or {}
    raw_records = unit.metadata.get("catalog_records", [])
    if not isinstance(raw_records, list):
        raise ValueError(f"{unit.source_path}: catalog_records must be an array")
    dispositions: list[EncodedFieldDisposition] = []
    for record_index, record in enumerate(raw_records):
        if not isinstance(record, dict):
            raise ValueError(f"{unit.source_path}: catalog record must be an object")
        form_id = str(
            record.get(
                "form_id",
                record.get("name", f"{unit.mnemonic or unit.unit_id}#{record_index}"),
            )
        )
        raw_constraints = record.get("constraints", [])
        if not isinstance(raw_constraints, list):
            raise ValueError(f"{unit.source_path}: {form_id} constraints must be an array")
        constraints: dict[str, dict[str, object]] = {}
        for constraint in raw_constraints:
            if not isinstance(constraint, dict):
                raise ValueError(f"{unit.source_path}: {form_id} constraint must be an object")
            field_name = _non_empty_string(
                constraint.get("field"),
                label=f"{form_id} constraint field",
                source=unit.source_path,
            )
            if field_name in constraints:
                raise ValueError(
                    f"{unit.source_path}: {form_id} has multiple constraints for {field_name}"
                )
            constraints[field_name] = constraint
        raw_fields = record.get("fields", [])
        if not isinstance(raw_fields, list):
            raise ValueError(f"{unit.source_path}: {form_id} fields must be an array")
        raw_other_owners = record.get("excluded_value_owners", [])
        if not isinstance(raw_other_owners, list):
            raise ValueError(
                f"{unit.source_path}: {form_id} excluded_value_owners must be an array"
            )
        other_owners_by_field: dict[str, dict[int, str]] = {}
        for owner_row in raw_other_owners:
            if not isinstance(owner_row, dict):
                raise ValueError(
                    f"{unit.source_path}: {form_id} excluded value owner must be an object"
                )
            owner_field = _non_empty_string(
                owner_row.get("field"),
                label=f"{form_id} excluded value owner field",
                source=unit.source_path,
            )
            owner_value = owner_row.get("value")
            if not isinstance(owner_value, int) or isinstance(owner_value, bool):
                raise ValueError(
                    f"{unit.source_path}: {form_id} excluded owner value must be an integer"
                )
            owner_name = _non_empty_string(
                owner_row.get("owner"),
                label=f"{form_id} excluded value owner",
                source=unit.source_path,
            )
            owners = other_owners_by_field.setdefault(owner_field, {})
            if owner_value in owners:
                raise ValueError(
                    f"{unit.source_path}: {form_id} repeats excluded owner "
                    f"{owner_field}={owner_value}"
                )
            owners[owner_value] = owner_name
        field_names: set[str] = set()
        for field in raw_fields:
            if not isinstance(field, dict):
                raise ValueError(f"{unit.source_path}: {form_id} field must be an object")
            field_name = _non_empty_string(
                field.get("name"), label=f"{form_id} field name", source=unit.source_path
            )
            if field_name in field_names:
                raise ValueError(f"{unit.source_path}: {form_id} repeats field {field_name}")
            field_names.add(field_name)
            role = roles.get(field_name)
            if role is None:
                raise ValueError(
                    f"{unit.source_path}: encoded field {field_name} has no architectural role"
                )
            width = field.get("width")
            if not isinstance(width, int) or isinstance(width, bool) or width <= 0:
                raise ValueError(
                    f"{unit.source_path}: {form_id} field {field_name} width must be positive"
                )
            signedness = _non_empty_string(
                field.get("signedness"),
                label=f"{form_id} field {field_name} signedness",
                source=unit.source_path,
            )
            maximum_value = (1 << width) - 1
            constraint = constraints.get(field_name)
            other_owners = other_owners_by_field.get(field_name, {})
            if constraint is None:
                if other_owners:
                    raise ValueError(
                        f"{unit.source_path}: {form_id} {field_name} cannot assign "
                        "the complete domain and declare another owner"
                    )
                assigned_ranges = ((0, maximum_value),)
                reserved_ranges: tuple[tuple[int, int], ...] = ()
            else:
                operator = constraint.get("operator")
                if operator == "one-of":
                    raw_values = constraint.get("values")
                    if not isinstance(raw_values, list) or any(
                        not isinstance(value, int) or isinstance(value, bool)
                        for value in raw_values
                    ):
                        raise ValueError(
                            f"{unit.source_path}: {form_id} {field_name} one-of values must be integers"
                        )
                    assigned = set(raw_values)
                    out_of_width = sorted(
                        value
                        for value in assigned
                        if value < 0 or value > maximum_value
                    )
                    assigned_ranges = _compact_ranges(assigned)
                    reserved_ranges = _complement_ranges(
                        assigned | set(other_owners), maximum_value
                    )
                elif operator == "not-equal":
                    value = constraint.get("value")
                    if not isinstance(value, int) or isinstance(value, bool):
                        raise ValueError(
                            f"{unit.source_path}: {form_id} {field_name} not-equal value must be integer"
                        )
                    reserved = {value}
                    out_of_width = (
                        [value] if value < 0 or value > maximum_value else []
                    )
                    assigned_ranges = _complement_ranges(reserved, maximum_value)
                    reserved_ranges = _compact_ranges(
                        reserved - set(other_owners)
                    )
                else:
                    raise ValueError(
                        f"{unit.source_path}: {form_id} {field_name} has unsupported constraint {operator!r}"
                    )
                if out_of_width:
                    raise ValueError(
                        f"{unit.source_path}: {form_id} {field_name} values exceed bits({width}): {out_of_width}"
                    )
                invalid_owners = sorted(
                    value
                    for value in other_owners
                    if value < 0 or value > maximum_value
                )
                if invalid_owners:
                    raise ValueError(
                        f"{unit.source_path}: {form_id} {field_name} owner values "
                        f"exceed bits({width}): {invalid_owners}"
                    )
                assigned_owner_overlap = sorted(
                    value
                    for value in other_owners
                    if any(start <= value <= end for start, end in assigned_ranges)
                )
                if assigned_owner_overlap:
                    raise ValueError(
                        f"{unit.source_path}: {form_id} {field_name} owner values "
                        f"are assigned by this form: {assigned_owner_overlap}"
                    )
            dispositions.append(
                EncodedFieldDisposition(
                    form_id=form_id,
                    field_name=field_name,
                    width=width,
                    signedness=signedness,
                    role=role,
                    zero_meaning=zero_meanings.get(
                        field_name,
                        f"Encoded zero supplies numeric zero for the {role}.",
                    ),
                    assigned_ranges=assigned_ranges,
                    other_owner_values=tuple(sorted(other_owners.items())),
                    reserved_ranges=reserved_ranges,
                    rejection=(
                        "Reserved encodings raise Fault_IllegalInstruction before architectural effects."
                        if reserved_ranges
                        else "none"
                    ),
                )
            )
        unknown_constraints = sorted(set(constraints) - field_names)
        if unknown_constraints:
            raise ValueError(
                f"{unit.source_path}: {form_id} constraints reference absent fields {unknown_constraints}"
            )
        unknown_owner_fields = sorted(set(other_owners_by_field) - field_names)
        if unknown_owner_fields:
            raise ValueError(
                f"{unit.source_path}: {form_id} excluded owners reference absent fields "
                f"{unknown_owner_fields}"
            )
    return tuple(dispositions)


def validate_domain(domain: FieldDomainContract) -> list[str]:
    """Return every totality and uniqueness error for one encoded field domain."""

    errors: list[str] = []
    maximum = 1 << domain.width
    assigned_values = [value for value, _ in domain.assigned]
    assigned = set(assigned_values)
    reserved = set(domain.reserved)
    if len(assigned_values) != len(assigned):
        duplicates = sorted(
            value for value in assigned if assigned_values.count(value) > 1
        )
        errors.append(f"{domain.contract_id}: duplicate assigned values {duplicates}")
    if len(domain.reserved) != len(reserved):
        duplicates = sorted(
            value for value in reserved if domain.reserved.count(value) > 1
        )
        errors.append(f"{domain.contract_id}: duplicate reserved values {duplicates}")
    overlap = sorted(assigned & reserved)
    if overlap:
        errors.append(
            f"{domain.contract_id}: assigned and reserved values overlap: {overlap}"
        )
    out_of_width = sorted(
        value for value in assigned | reserved if value < 0 or value >= maximum
    )
    if out_of_width:
        errors.append(
            f"{domain.contract_id}: values exceed bits({domain.width}): {out_of_width}"
        )
    missing = sorted(set(range(maximum)) - assigned - reserved)
    if missing:
        errors.append(f"{domain.contract_id}: field domain is missing values {missing}")
    meanings = [meaning for _, meaning in domain.assigned]
    for meaning in sorted(set(meanings)):
        if meanings.count(meaning) > 1:
            errors.append(f"{domain.contract_id}: duplicate assigned meaning {meaning}")
    if 0 in assigned and not domain.zero_meaning:
        errors.append(f"{domain.contract_id}: assigned zero lacks zero meaning")
    return errors


def load_field_domains(units: Sequence[AslUnit]) -> dict[str, FieldDomainContract]:
    """Load every ASL-owned field domain and reject duplicate or partial domains."""

    domains: dict[str, FieldDomainContract] = {}
    for unit in units:
        raw_domains = unit.metadata.get("field_domains", [])
        if not isinstance(raw_domains, list):
            raise ValueError(f"{unit.source_path}: field_domains must be an array")
        for raw_domain in raw_domains:
            if not isinstance(raw_domain, dict):
                raise ValueError(f"{unit.source_path}: field domain must be an object")
            domain = FieldDomainContract.from_metadata(raw_domain, unit.source_path)
            if domain.contract_id in domains:
                previous = domains[domain.contract_id].source_path
                raise ValueError(
                    f"duplicate field domain {domain.contract_id}: {previous} and {unit.source_path}"
                )
            errors = validate_domain(domain)
            if errors:
                raise ValueError("; ".join(errors))
            domains[domain.contract_id] = domain
    return domains


def _contains_placeholder(value: object) -> bool:
    if isinstance(value, str):
        return bool(PLACEHOLDER_TEXT.search(value))
    if isinstance(value, dict):
        return any(_contains_placeholder(item) for item in value.values())
    if isinstance(value, (list, tuple)):
        return any(_contains_placeholder(item) for item in value)
    return False


def _operand_tuple(value: object, *, source: Path) -> tuple[dict[str, object], ...]:
    if not isinstance(value, list):
        raise ValueError(f"{source}: contract operands must be an object array")
    operands: list[dict[str, object]] = []
    for index, operand in enumerate(value):
        if not isinstance(operand, dict):
            raise ValueError(f"{source}: contract operand {index} must be an object")
        _non_empty_string(
            operand.get("field"), label=f"contract operand {index} field", source=source
        )
        _non_empty_string(
            operand.get("role"), label=f"contract operand {index} role", source=source
        )
        operands.append(dict(operand))
    return tuple(operands)


def resolve_instruction_contract(
    unit: AslUnit,
    domains: Mapping[str, FieldDomainContract],
    *,
    require_complete: bool = True,
) -> ResolvedInstructionContract | None:
    """Resolve one instruction contract against the shared field-domain graph."""

    if unit.mnemonic is None:
        return None
    raw_contract = unit.metadata.get("contract")
    if raw_contract is None:
        if require_complete:
            raise ValueError(f"{unit.source_path}: instruction contract is missing")
        return None
    if not isinstance(raw_contract, dict):
        raise ValueError(f"{unit.source_path}: instruction contract must be an object")
    encoding_class = _non_empty_string(
        raw_contract.get("encoding_class"),
        label="contract encoding_class",
        source=unit.source_path,
    )
    if encoding_class not in ENCODING_CLASSES:
        raise ValueError(f"{unit.source_path}: unknown encoding class {encoding_class}")
    raw_field_contracts = raw_contract.get("field_contracts")
    if not isinstance(raw_field_contracts, dict):
        raise ValueError(f"{unit.source_path}: field_contracts must be an object")
    field_domains: list[tuple[str, FieldDomainContract]] = []
    for field_name, binding in raw_field_contracts.items():
        if not isinstance(field_name, str) or not field_name:
            raise ValueError(f"{unit.source_path}: field contract name must be non-empty")
        if not isinstance(binding, dict):
            raise ValueError(f"{unit.source_path}: field contract {field_name} must be an object")
        reference = _non_empty_string(
            binding.get("ref"),
            label=f"field contract {field_name} ref",
            source=unit.source_path,
        )
        domain = domains.get(reference)
        if domain is None:
            raise ValueError(f"{unit.source_path}: unknown field domain {reference}")
        field_domains.append((field_name, domain))
    standalone_opcode = raw_contract.get("standalone_opcode")
    if not isinstance(standalone_opcode, bool):
        raise ValueError(f"{unit.source_path}: standalone_opcode must be boolean")
    if encoding_class == "selector-encoded-block-operation" and standalone_opcode:
        raise ValueError(
            f"{unit.source_path}: selector operation must declare standalone_opcode=false"
        )
    block_composition = _string_tuple(
        raw_contract.get("block_composition"),
        label="contract block_composition",
        source=unit.source_path,
        allow_duplicates=True,
    )
    if encoding_class == "selector-encoded-block-operation":
        if block_composition == ("none",):
            raise ValueError(
                f"{unit.source_path}: selector operation is missing block composition"
            )
    operands = _operand_tuple(raw_contract.get("operands"), source=unit.source_path)
    raw_zero_meanings = raw_contract.get("field_zero_meanings", {})
    if not isinstance(raw_zero_meanings, dict) or any(
        not isinstance(field_name, str)
        or not field_name
        or not isinstance(meaning, str)
        or not meaning.strip()
        for field_name, meaning in raw_zero_meanings.items()
    ):
        raise ValueError(
            f"{unit.source_path}: field_zero_meanings must be a string-to-string object"
        )
    contract = ResolvedInstructionContract(
        encoding_class=encoding_class,
        canonical_assembly=_string_tuple(
            raw_contract.get("canonical_assembly"),
            label="contract canonical_assembly",
            source=unit.source_path,
        ),
        field_domains=tuple(field_domains),
        encoded_fields=derive_encoded_field_dispositions(
            unit,
            operands,
            zero_meanings={
                str(field_name): str(meaning).strip()
                for field_name, meaning in raw_zero_meanings.items()
            },
        ),
        operands=operands,
        defaults=_string_tuple(
            raw_contract.get("defaults"), label="contract defaults", source=unit.source_path
        ),
        legality=_string_tuple(
            raw_contract.get("legality"), label="contract legality", source=unit.source_path
        ),
        state_effects=_string_tuple(
            raw_contract.get("state_effects"),
            label="contract state_effects",
            source=unit.source_path,
        ),
        memory_effects=_string_tuple(
            raw_contract.get("memory_effects"),
            label="contract memory_effects",
            source=unit.source_path,
        ),
        ordering=_string_tuple(
            raw_contract.get("ordering"), label="contract ordering", source=unit.source_path
        ),
        exceptions=_string_tuple(
            raw_contract.get("exceptions"),
            label="contract exceptions",
            source=unit.source_path,
        ),
        examples=_string_tuple(
            raw_contract.get("examples"), label="contract examples", source=unit.source_path
        ),
        block_composition=block_composition,
        standalone_opcode=standalone_opcode,
    )
    if _contains_placeholder(raw_contract):
        raise ValueError(f"{unit.source_path}: placeholder architectural text is forbidden")
    return contract


def check_instruction_contracts(
    root: Path = ROOT,
    *,
    surface: str | None = None,
    require_complete: bool = False,
) -> list[str]:
    """Validate authored contracts, optionally requiring all selected instructions."""

    try:
        units = load_units(root / "asl")
        domains = load_field_domains(units)
    except ValueError as error:
        return [str(error)]
    errors: list[str] = []
    for unit in units:
        if unit.mnemonic is None or (surface is not None and unit.surface != surface):
            continue
        must_exist = require_complete
        try:
            resolve_instruction_contract(unit, domains, require_complete=must_exist)
        except ValueError as error:
            errors.append(str(error))
    return errors


def _summary(root: Path) -> dict[str, object]:
    units = load_units(root / "asl")
    domains = load_field_domains(units)
    authored = 0
    for unit in units:
        if unit.mnemonic is not None and unit.metadata.get("contract") is not None:
            authored += 1
    return {
        "field_domains": len(domains),
        "instruction_contracts": authored,
        "instruction_units": sum(unit.mnemonic is not None for unit in units),
    }


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument("--surface", choices=("arch", "block", "scalar", "tile"))
    parser.add_argument("--require-complete", action="store_true")
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--summary", action="store_true")
    args = parser.parse_args(argv)
    errors = check_instruction_contracts(
        args.root,
        surface=args.surface,
        require_complete=args.require_complete,
    )
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    if args.summary:
        print(json.dumps(_summary(args.root), indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
