#!/usr/bin/env python3
"""Validate source-free manual review records for PTO formal definitions.

The audit records only which architectural subjects were read and the formal
definition outcome.  It deliberately carries no external repository, page,
commit, blob, or generated-artifact provenance: PTO ASL is the source.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Sequence

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from scripts.asl_units import APPROVED_SURFACES, AslUnit, load_units  # noqa: E402


REQUIRED_REVIEWED_FIELDS = (
    "assembly",
    "encoding",
    "defaults",
    "operation",
    "state",
    "memory",
    "ordering",
    "faults",
    "reserved",
)
ALLOWED_OUTCOMES = frozenset(
    {"FORMAL-COMPLETE", "FORMAL-INCOMPLETE", "AMBIGUOUS", "RESERVED"}
)
REVIEW_KEYS = frozenset({"review_method", "outcome", "reviewed_fields"})
RESERVATION_CATALOG = "extension-encoding-reservations"


def format_summary(summary: dict[str, int]) -> str:
    """Report formal implementation closure without redefining audit coverage."""

    return (
        "formal implementation closure: "
        f"{summary['reviewed']} complete, {summary['missing']} incomplete; "
        "reservation closure: "
        f"{summary['reservation_reviewed']} complete, "
        f"{summary['reservation_missing']} incomplete"
    )


def _string(record: dict[str, object], name: str, owner: str, errors: list[str]) -> str | None:
    value = record.get(name)
    if not isinstance(value, str) or not value:
        errors.append(f"{owner}: {name} must be a non-empty string")
        return None
    return value


def validate_review(unit: AslUnit, review: object) -> list[str]:
    """Validate one source-free formal-definition review record."""

    owner = unit.source_path.as_posix()
    errors: list[str] = []
    if not isinstance(review, dict):
        return [f"{owner}: manual_semantic_review must be an object"]
    keys = set(review)
    if keys != REVIEW_KEYS:
        missing = ", ".join(sorted(REVIEW_KEYS - keys)) or "none"
        unknown = ", ".join(sorted(keys - REVIEW_KEYS)) or "none"
        errors.append(
            f"{owner}: formal review keys mismatch; missing [{missing}], unknown [{unknown}]"
        )
    method = _string(review, "review_method", owner, errors)
    if method is not None and method != "formal-definition-read":
        errors.append(f"{owner}: review_method must be formal-definition-read")
    outcome = _string(review, "outcome", owner, errors)
    if outcome is not None and outcome not in ALLOWED_OUTCOMES:
        errors.append(f"{owner}: unknown review outcome {outcome}")
    fields = review.get("reviewed_fields")
    if not isinstance(fields, list) or tuple(fields) != REQUIRED_REVIEWED_FIELDS:
        errors.append(
            f"{owner}: reviewed_fields must acknowledge exactly "
            + ", ".join(REQUIRED_REVIEWED_FIELDS)
        )
    return errors


def audit_repository(
    root: Path,
    *,
    allow_incomplete: bool,
    surface: str | None = None,
) -> tuple[list[str], dict[str, int]]:
    """Audit PTO formal-review inventory and return errors plus counts."""

    units = load_units(root / "asl")
    selected = tuple(
        unit
        for unit in units
        if unit.mnemonic is not None and (surface is None or unit.surface == surface)
    )
    errors: list[str] = []
    reviewed = 0
    missing = 0
    for unit in selected:
        review = unit.manual_semantic_review
        if review is None:
            missing += 1
            if not allow_incomplete:
                errors.append(f"{unit.source_path}: missing formal semantic review")
            continue
        errors.extend(validate_review(unit, review))
        outcome = review.get("outcome") if isinstance(review, dict) else None
        if outcome == "FORMAL-COMPLETE":
            reviewed += 1
        else:
            missing += 1
            if not allow_incomplete and outcome in {"FORMAL-INCOMPLETE", "AMBIGUOUS"}:
                errors.append(
                    f"{unit.source_path}: formal semantic review outcome {outcome} "
                    "does not close implementation"
                )
        if outcome == "RESERVED":
            errors.append(
                f"{unit.source_path}: accepted mnemonic review cannot use RESERVED outcome"
            )

    reservation_reviewed = 0
    reservation_missing = 0
    reservation_units = tuple(
        unit
        for unit in units
        if (surface is None or unit.surface == surface)
        and isinstance(unit.metadata.get("catalog_projection"), dict)
        and unit.metadata["catalog_projection"].get("catalog") == RESERVATION_CATALOG
    )
    for unit in reservation_units:
        projection = unit.metadata["catalog_projection"]
        reservations = projection.get("reservations", [])
        declared = unit.metadata.get("manual_reservation_reviews", [])
        owner = unit.source_path.as_posix()
        if not isinstance(reservations, list) or any(
            not isinstance(item, dict) or not isinstance(item.get("mnemonic"), str)
            for item in reservations
        ):
            errors.append(f"{owner}: invalid extension reservation projection")
            continue
        if not isinstance(declared, list) or any(not isinstance(item, dict) for item in declared):
            errors.append(f"{owner}: manual_reservation_reviews must be an array")
            declared = []
        by_mnemonic: dict[str, object] = {}
        for item in declared:
            mnemonic = item.get("mnemonic")
            if not isinstance(mnemonic, str) or not mnemonic:
                errors.append(f"{owner}: reservation review mnemonic must be a string")
                continue
            if mnemonic in by_mnemonic:
                errors.append(f"{owner}: duplicate reservation review for {mnemonic}")
                continue
            by_mnemonic[mnemonic] = item.get("review")
        expected = {str(item["mnemonic"]) for item in reservations}
        for unknown in sorted(set(by_mnemonic) - expected):
            errors.append(f"{owner}: unknown reservation review {unknown}")
        for mnemonic in sorted(expected):
            review = by_mnemonic.get(mnemonic)
            if review is None:
                reservation_missing += 1
                if not allow_incomplete:
                    errors.append(f"{owner}: missing formal reservation review for {mnemonic}")
                continue
            reservation_reviewed += 1
            synthetic = AslUnit(
                unit_id=f"{unit.unit_id}-{mnemonic}",
                surface=unit.surface,
                classification=unit.classification,
                depends_on=(),
                source_path=unit.source_path,
                mnemonic=mnemonic,
                line_count=unit.line_count,
                manual_semantic_review=review,
            )
            errors.extend(validate_review(synthetic, review))
            if isinstance(review, dict) and review.get("outcome") != "RESERVED":
                errors.append(
                    f"{owner}: reservation review {mnemonic} must use RESERVED outcome"
                )
    return errors, {
        "reviewed": reviewed,
        "missing": missing,
        "reservation_reviewed": reservation_reviewed,
        "reservation_missing": reservation_missing,
    }


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument("--allow-incomplete", action="store_true")
    parser.add_argument("--surface", choices=APPROVED_SURFACES)
    arguments = parser.parse_args(argv)
    try:
        errors, summary = audit_repository(
            arguments.root.resolve(),
            allow_incomplete=arguments.allow_incomplete,
            surface=arguments.surface,
        )
    except (OSError, ValueError) as error:
        errors = [str(error)]
        summary = {
            "reviewed": 0,
            "missing": 0,
            "reservation_reviewed": 0,
            "reservation_missing": 0,
        }
    for error in errors:
        print(f"error: {error}", file=sys.stderr)
    print(format_summary(summary))
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
