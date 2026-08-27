"""Derive PTO architecture lifecycle stages from repository-owned facts."""

from __future__ import annotations

from collections import Counter
from collections.abc import Mapping, Sequence
from dataclasses import asdict, dataclass
import hashlib
import json
from pathlib import Path
from typing import Any

from scripts.adr_records import AdrRecord, load_adrs
from scripts.release_selection import _baseline_inputs


ACTIVE_STATUSES = frozenset({"draft", "accepted"})
STAGE_ORDER = (
    "draft",
    "architecture-defined",
    "modeled",
    "executable",
    "validated",
    "released",
)
INSTRUCTION_CONTRACT = Path("spec/evidence/instruction-contract-closure.json")
TRACEABILITY = Path("spec/evidence/release-traceability-readiness.json")


@dataclass(frozen=True)
class ReadinessRow:
    subject_id: str
    adr_ids: tuple[str, ...]
    ndf_ids: tuple[str, ...]
    unit_ids: tuple[str, ...]
    test_ids: tuple[str, ...]
    stage: str
    blockers: tuple[str, ...]
    validated_commit: str | None
    released_versions: tuple[str, ...]


def _validation_matches(
    validation: Mapping[str, object] | None, commit: str
) -> bool:
    return (
        validation is not None
        and validation.get("commit") == commit
        and validation.get("result") == "success"
    )


def derive_row(
    *,
    subject_id: str,
    adr_status: str,
    ndf_ids: Sequence[str],
    unit_ids: Sequence[str],
    test_ids: Sequence[str],
    missing_ndf: Sequence[str],
    missing_units: Sequence[str],
    missing_tests: Sequence[str],
    implementation_issue: str | None,
    validation: Mapping[str, object] | None,
    commit: str,
    released_versions: Sequence[str],
) -> ReadinessRow:
    """Derive one row without accepting hand-authored maturity metadata."""

    if adr_status not in ACTIVE_STATUSES:
        raise ValueError(f"{subject_id}: inactive ADR status {adr_status!r}")

    blockers: list[str] = []
    validated_commit: str | None = None
    published: tuple[str, ...] = ()
    if adr_status == "draft":
        stage = "draft"
        blockers.append("ADR is draft")
    else:
        blockers.extend(f"missing NDF {item}" for item in missing_ndf)
        blockers.extend(f"missing ASL unit {item}" for item in missing_units)
        if missing_ndf or missing_units:
            if implementation_issue is None:
                raise ValueError(
                    f"{subject_id}: accepted decision with missing model ownership "
                    "requires an implementation issue"
                )
            blockers.append(f"implementation issue: {implementation_issue}")
            stage = "architecture-defined"
        else:
            blockers.extend(f"missing AVS for {item}" for item in missing_tests)
            stage = "modeled" if missing_tests else "executable"
            if stage == "executable" and _validation_matches(validation, commit):
                stage = "validated"
                validated_commit = commit
                published = tuple(sorted(set(released_versions)))
                if published:
                    stage = "released"

    return ReadinessRow(
        subject_id=subject_id,
        adr_ids=(subject_id,),
        ndf_ids=tuple(sorted(ndf_ids)),
        unit_ids=tuple(sorted(unit_ids)),
        test_ids=tuple(sorted(test_ids)),
        stage=stage,
        blockers=tuple(blockers),
        validated_commit=validated_commit,
        released_versions=published,
    )


def _contract_sources(root: Path) -> set[str]:
    path = root / INSTRUCTION_CONTRACT
    document = json.loads(path.read_text(encoding="utf-8"))
    if document.get("schema") != "pto.instruction-contract-closure.v1":
        raise ValueError("instruction contract closure schema drift")
    if document.get("summary", {}).get("status") != "closed":
        raise ValueError("instruction contract closure is open")
    instructions = document.get("instructions")
    if not isinstance(instructions, list):
        raise ValueError("instruction contract inventory must be an array")
    return {
        row["source"]
        for row in instructions
        if isinstance(row, dict) and isinstance(row.get("source"), str)
    }


def _repository_facts(root: Path) -> dict[str, Any]:
    traceability = json.loads((root / TRACEABILITY).read_text(encoding="utf-8"))
    if traceability.get("schema") != "pto.release-traceability.v2":
        raise ValueError("release traceability schema drift")
    if traceability.get("summary", {}).get("status") != "closed":
        raise ValueError("release traceability is open")
    unit_rows = traceability.get("units")
    requirement_rows = traceability.get("requirements")
    test_rows = traceability.get("tests")
    if not all(isinstance(rows, list) for rows in (unit_rows, requirement_rows, test_rows)):
        raise ValueError("release traceability inventories must be arrays")
    units_by_id = {
        row["id"]: row
        for row in unit_rows
        if isinstance(row, dict) and isinstance(row.get("id"), str)
    }
    requirements = {
        row["id"]: row.get("executable") is True
        for row in requirement_rows
        if isinstance(row, dict) and isinstance(row.get("id"), str)
    }
    tests_by_requirement = {
        row["id"]: tuple(row.get("tests", ()))
        for row in requirement_rows
        if isinstance(row, dict) and isinstance(row.get("id"), str)
    }
    tests_by_source = {
        row["source"]: tuple(row.get("tests", ()))
        for row in unit_rows
        if isinstance(row, dict) and isinstance(row.get("source"), str)
    }
    if len(units_by_id) != len(unit_rows):
        raise ValueError("duplicate or malformed release-traceability unit IDs")
    if len(requirements) != len(requirement_rows):
        raise ValueError("duplicate or malformed release-traceability NDF IDs")
    return {
        "requirements": requirements,
        "units_by_id": units_by_id,
        "tests_by_source": tests_by_source,
        "tests_by_requirement": tests_by_requirement,
        "contract_sources": _contract_sources(root),
    }


def _tests_for_record(record: AdrRecord, facts: Mapping[str, Any]) -> tuple[
    tuple[str, ...], tuple[str, ...]
]:
    units_by_id = facts["units_by_id"]
    tests_by_source = facts["tests_by_source"]
    tests_by_requirement = facts["tests_by_requirement"]
    requirements = facts["requirements"]
    contract_sources = facts["contract_sources"]
    test_ids: set[str] = set()
    missing: list[str] = []

    for unit_id in record.affected_units:
        unit = units_by_id.get(unit_id)
        if unit is None:
            continue
        source = unit["source"]
        owned = tests_by_source.get(source, ())
        test_ids.update(owned)
        if not owned:
            missing.append(f"ASL unit {unit_id}")
        if unit.get("mnemonic") is not None and source not in contract_sources:
            missing.append(f"instruction contract {unit_id}")

    for ndf_id in record.affected_ndf:
        owned = tests_by_requirement.get(ndf_id, ())
        test_ids.update(owned)
        if requirements.get(ndf_id, False) and not owned:
            missing.append(f"NDF {ndf_id}")

    return tuple(sorted(test_ids)), tuple(sorted(set(missing)))


def derive_readiness(root: Path, commit: str) -> tuple[ReadinessRow, ...]:
    """Derive all active ADR rows for *root* without self-validating *commit*."""

    records = load_adrs(root / "docs/status/decisions")
    facts = _repository_facts(root)
    known_ndf = set(facts["requirements"])
    known_units = set(facts["units_by_id"])
    selection = json.loads((root / "spec/release-selection.json").read_text(encoding="utf-8"))
    baseline = selection.get("baseline_commit")
    if not isinstance(baseline, str):
        raise ValueError("release selection baseline_commit is invalid")
    baseline_manifest, baseline_unit_rows = _baseline_inputs(root, baseline)
    baseline_selection = baseline_manifest.get("release_selection")
    if not isinstance(baseline_selection, dict):
        raise ValueError("baseline manifest release selection is missing")
    baseline_expanded_ndf = baseline_selection.get("expanded_ndf")
    if not isinstance(baseline_expanded_ndf, list):
        raise ValueError("baseline manifest expanded NDF rows are invalid")
    baseline_ndf = {
        row.get("id")
        for row in baseline_expanded_ndf
        if isinstance(row, dict) and isinstance(row.get("id"), str)
    }
    baseline_units = {
        row.get("id")
        for row in baseline_unit_rows
        if isinstance(row.get("id"), str)
    }
    rows: list[ReadinessRow] = []
    for record in records:
        if record.status not in ACTIVE_STATUSES:
            continue
        permitted_ndf = known_ndf | baseline_ndf if record.release_boundary else known_ndf
        permitted_units = (
            known_units | baseline_units if record.release_boundary else known_units
        )
        missing_ndf = tuple(sorted(set(record.affected_ndf) - permitted_ndf))
        missing_units = tuple(sorted(set(record.affected_units) - permitted_units))
        test_ids, missing_tests = _tests_for_record(record, facts)
        rows.append(
            derive_row(
                subject_id=record.adr_id,
                adr_status=record.status,
                ndf_ids=record.affected_ndf,
                unit_ids=record.affected_units,
                test_ids=test_ids,
                missing_ndf=missing_ndf,
                missing_units=missing_units,
                missing_tests=missing_tests,
                implementation_issue=record.implementation_issue,
                validation=None,
                commit=commit,
                released_versions=(),
            )
        )
    return tuple(sorted(rows, key=lambda row: row.subject_id))


def _aggregate_digest(root: Path, paths: Sequence[Path]) -> str:
    digest = hashlib.sha256()
    for path in sorted(set(paths)):
        relative = path.relative_to(root).as_posix()
        digest.update(relative.encode("utf-8"))
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()


def _sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def build_document(root: Path, commit: str) -> dict[str, object]:
    rows = derive_readiness(root, commit)
    stage_counts = Counter(row.stage for row in rows)
    adr_paths = tuple((root / "docs/status/decisions").glob("*.md"))
    contract_path = root / INSTRUCTION_CONTRACT
    traceability_path = root / TRACEABILITY
    traceability = json.loads(traceability_path.read_text(encoding="utf-8"))
    return {
        "schema": "pto.architecture-readiness",
        "stage_order": list(STAGE_ORDER),
        "sources": {
            "adr_records": {
                "count": len(adr_paths) - int(
                    (root / "docs/status/decisions/0000-template.md").is_file()
                ),
                "sha256": _aggregate_digest(root, adr_paths),
            },
            "release_traceability": {
                "path": TRACEABILITY.as_posix(),
                "sha256": _sha256(traceability_path),
                "unit_count": traceability["summary"]["unit_count"],
                "test_count": traceability["summary"]["test_count"],
            },
            "instruction_contract": {
                "path": INSTRUCTION_CONTRACT.as_posix(),
                "sha256": _sha256(contract_path),
            },
        },
        "rows": [asdict(row) for row in rows],
        "summary": {
            "subject_count": len(rows),
            "stage_counts": {
                stage: stage_counts.get(stage, 0) for stage in STAGE_ORDER
            },
            "draft_count": stage_counts.get("draft", 0),
            "blocker_count": sum(len(row.blockers) for row in rows),
            "validated_count": sum(row.validated_commit is not None for row in rows),
            "released_count": stage_counts.get("released", 0),
            "status": "open"
            if stage_counts.get("draft", 0)
            or any(row.blockers for row in rows)
            else "closed",
        },
    }


def render_document(document: Mapping[str, object]) -> str:
    return json.dumps(document, indent=2, sort_keys=True) + "\n"
