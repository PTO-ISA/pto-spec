"""Validate and expand the exact PTO architecture release selection."""

from __future__ import annotations

from dataclasses import dataclass
import hashlib
import json
from pathlib import Path
import re
import tomllib

from scripts.asl_units import load_units
from scripts.ndf import instruction_clause_id, parse_ndf_regions


SELECTION_PATH = Path("spec/release-selection.json")
SCHEMA_PATH = "spec/schemas/pto-release-selection.schema.json"
ADR_INDEX_PATH = Path("spec/evidence/adr-index.json")
READINESS_PATH = Path("spec/evidence/architecture-readiness.json")
MANIFEST_PATH = Path("spec/release-manifest.json")
STAGES = (
    "draft",
    "architecture-defined",
    "modeled",
    "executable",
    "validated",
    "released",
)
COMMIT = re.compile(r"[0-9a-f]{40}\Z")
ADR_ID = re.compile(r"ADR-[0-9]{4}\Z")
_LOAD_PREVIOUS = object()


@dataclass(frozen=True)
class ReleaseSelectionResult:
    architecture_version: str
    baseline_commit: str
    included_ndf_statuses: tuple[str, ...]
    excluded_draft_adrs: tuple[str, ...]
    required_readiness_floor: str
    selected_adr_ids: tuple[str, ...]
    selected_ndf_ids: tuple[str, ...]
    ndf_digests: tuple[tuple[str, str], ...]
    blockers: tuple[str, ...]
    selection_sha256: str


def _canonical_sha256(value: object) -> str:
    payload = json.dumps(value, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def _unique_rows(rows: tuple[dict[str, object], ...], field: str, label: str):
    by_id: dict[str, dict[str, object]] = {}
    for row in rows:
        value = row.get(field)
        if not isinstance(value, str) or not value:
            raise ValueError(f"{label} contains a malformed identity")
        if value in by_id:
            raise ValueError(f"duplicate {label} {value}")
        by_id[value] = row
    return by_id


def _strings(value: object, field: str) -> tuple[str, ...]:
    if not isinstance(value, list) or any(
        not isinstance(item, str) or not item for item in value
    ):
        raise ValueError(f"release selection {field} must be an array of strings")
    items = tuple(value)
    if len(items) != len(set(items)):
        raise ValueError(f"release selection {field} contains duplicates")
    return items


def validate_selection(
    selection: dict[str, object],
    *,
    architecture_version: str,
    adr_records: tuple[dict[str, object], ...],
    readiness_rows: tuple[dict[str, object], ...],
    ndf_rows: tuple[dict[str, object], ...],
    previous_manifest: dict[str, object] | None,
) -> ReleaseSelectionResult:
    expected_fields = {
        "$schema",
        "architecture_version",
        "baseline_commit",
        "included_ndf_statuses",
        "excluded_draft_adrs",
        "required_readiness_floor",
    }
    if set(selection) != expected_fields:
        raise ValueError("release selection fields drift")
    if selection.get("$schema") != SCHEMA_PATH:
        raise ValueError("release selection schema path drift")
    if selection.get("architecture_version") != architecture_version:
        raise ValueError("release selection architecture version mismatch")
    baseline = selection.get("baseline_commit")
    if not isinstance(baseline, str) or COMMIT.fullmatch(baseline) is None:
        raise ValueError("release selection baseline_commit is invalid")
    included_statuses = _strings(
        selection.get("included_ndf_statuses"), "included_ndf_statuses"
    )
    if included_statuses != ("accepted",):
        raise ValueError("release selection must include every accepted NDF")
    excluded = _strings(
        selection.get("excluded_draft_adrs"), "excluded_draft_adrs"
    )
    if tuple(sorted(excluded)) != excluded:
        raise ValueError("release selection draft exclusion must be sorted")
    floor = selection.get("required_readiness_floor")
    if floor not in STAGES or floor in {"draft", "architecture-defined", "modeled"}:
        raise ValueError("release selection readiness floor must be executable or later")

    adrs = _unique_rows(adr_records, "id", "ADR")
    readiness = _unique_rows(readiness_rows, "subject_id", "readiness subject")
    ndf = _unique_rows(ndf_rows, "id", "NDF")
    unknown_excluded = sorted(set(excluded) - set(adrs))
    if unknown_excluded:
        raise ValueError(f"draft exclusion contains unknown ADR {unknown_excluded[0]}")
    accepted_excluded = sorted(
        adr_id for adr_id in excluded if adrs[adr_id].get("status") != "draft"
    )
    if accepted_excluded:
        raise ValueError(f"draft exclusion contains accepted ADR {accepted_excluded[0]}")
    drafts = tuple(sorted(
        adr_id for adr_id, row in adrs.items() if row.get("status") == "draft"
    ))
    if excluded != drafts:
        raise ValueError("release selection draft exclusion is incomplete")

    current_selected_ndf = tuple(sorted(
        ndf_id for ndf_id, row in ndf.items() if row.get("status") in included_statuses
    ))
    if not current_selected_ndf:
        raise ValueError("release selection contains no accepted NDF clauses")
    current_selected_ndf_set = set(current_selected_ndf)
    current_selected_adrs = tuple(sorted(
        adr_id
        for adr_id, row in adrs.items()
        if row.get("status") == "accepted"
        and current_selected_ndf_set.intersection(row.get("affected_ndf", ()))
    ))
    current_digests = tuple(
        (ndf_id, str(ndf[ndf_id]["sha256"])) for ndf_id in current_selected_ndf
    )
    if any(
        re.fullmatch(r"[0-9a-f]{64}", digest) is None
        for _, digest in current_digests
    ):
        raise ValueError("selected NDF digest is invalid")
    selected_ndf = current_selected_ndf
    selected_adrs = current_selected_adrs
    digests = current_digests
    blockers: list[str] = []
    if previous_manifest is not None and previous_manifest.get("release") == architecture_version:
        previous_selection = previous_manifest.get("release_selection")
        if isinstance(previous_selection, dict):
            previous_rows = previous_selection.get("expanded_ndf", ())
            previous_digests = {
                row.get("id"): row.get("sha256")
                for row in previous_rows
                if isinstance(row, dict)
                and isinstance(row.get("id"), str)
                and isinstance(row.get("sha256"), str)
            }
            selected_ndf = tuple(sorted(previous_digests))
            digests = tuple((ndf_id, previous_digests[ndf_id]) for ndf_id in selected_ndf)
            previous_adrs = previous_selection.get("selected_adr_ids")
            if isinstance(previous_adrs, list) and all(
                isinstance(adr_id, str) for adr_id in previous_adrs
            ):
                selected_adrs = tuple(previous_adrs)
            current_digest_map = dict(current_digests)
            if set(previous_digests) != set(current_digest_map):
                blockers.append(
                    "published selected NDF set changed; a new release identity "
                    "and accepted compatibility ADR are required"
                )
            changed = sorted(
                ndf_id
                for ndf_id, digest in previous_digests.items()
                if current_digest_map.get(ndf_id) != digest
            )
            if changed:
                blockers.append(
                    f"published NDF {changed[0]} changed; a new release identity "
                    "and accepted compatibility ADR are required"
                )
    floor_index = STAGES.index(floor)
    for adr_id, record in adrs.items():
        if record.get("status") != "accepted":
            continue
        row = readiness.get(adr_id)
        if row is None:
            raise ValueError(f"accepted ADR {adr_id} has no readiness subject")
        stage = row.get("stage")
        if stage not in STAGES:
            raise ValueError(f"readiness subject {adr_id} has an invalid stage")
        if architecture_version in record.get("target_releases", ()):
            if adr_id not in selected_adrs or STAGES.index(stage) < floor_index:
                raise ValueError(
                    f"target release ADR {adr_id} is below required readiness floor"
                )

    return ReleaseSelectionResult(
        architecture_version=architecture_version,
        baseline_commit=baseline,
        included_ndf_statuses=included_statuses,
        excluded_draft_adrs=excluded,
        required_readiness_floor=str(floor),
        selected_adr_ids=selected_adrs,
        selected_ndf_ids=selected_ndf,
        ndf_digests=digests,
        blockers=tuple(blockers),
        selection_sha256=_canonical_sha256(selection),
    )


def _ndf_rows(root: Path) -> tuple[dict[str, object], ...]:
    rows: list[dict[str, object]] = []
    for unit in load_units(root / "asl"):
        path = root / unit.source_path
        text = path.read_text(encoding="utf-8")
        for clause in parse_ndf_regions(text, unit.source_path):
            rows.append(
                {
                    "id": clause.clause_id,
                    "status": clause.status,
                    "sha256": _canonical_sha256(
                        {
                            "id": clause.clause_id,
                            "status": clause.status,
                            "source": clause.source.as_posix(),
                            "body": clause.body,
                        }
                    ),
                }
            )
        if unit.mnemonic is not None:
            clause_id = instruction_clause_id(unit.surface, unit.mnemonic)
            rows.append(
                {
                    "id": clause_id,
                    "status": "accepted",
                    "sha256": _canonical_sha256(
                        {
                            "id": clause_id,
                            "status": "accepted",
                            "source": unit.source_path.as_posix(),
                            "source_sha256": hashlib.sha256(
                                text.encode("utf-8")
                            ).hexdigest(),
                        }
                    ),
                }
            )
    _unique_rows(tuple(rows), "id", "NDF")
    return tuple(sorted(rows, key=lambda row: str(row["id"])))


def evaluate_release_selection(
    root: Path,
    *,
    previous_manifest: dict[str, object] | None | object = _LOAD_PREVIOUS,
) -> ReleaseSelectionResult:
    selection = json.loads((root / SELECTION_PATH).read_text(encoding="utf-8"))
    metadata = tomllib.loads((root / "specification.toml").read_text(encoding="utf-8"))
    architecture_version = metadata["release"]["architecture_version"]
    adr_index = json.loads((root / ADR_INDEX_PATH).read_text(encoding="utf-8"))
    readiness = json.loads((root / READINESS_PATH).read_text(encoding="utf-8"))
    if adr_index.get("schema") != "pto.adr-index":
        raise ValueError("ADR index schema drift")
    if readiness.get("schema") != "pto.architecture-readiness":
        raise ValueError("architecture readiness schema drift")
    if previous_manifest is _LOAD_PREVIOUS:
        manifest_path = root / MANIFEST_PATH
        previous_manifest = (
            json.loads(manifest_path.read_text(encoding="utf-8"))
            if manifest_path.is_file()
            else None
        )
    return validate_selection(
        selection,
        architecture_version=architecture_version,
        adr_records=tuple(adr_index["records"]),
        readiness_rows=tuple(readiness["rows"]),
        ndf_rows=_ndf_rows(root),
        previous_manifest=previous_manifest,
    )


def manifest_selection(result: ReleaseSelectionResult) -> dict[str, object]:
    return {
        "architecture_version": result.architecture_version,
        "baseline_commit": result.baseline_commit,
        "policy_sha256": result.selection_sha256,
        "included_ndf_statuses": list(result.included_ndf_statuses),
        "excluded_draft_adrs": list(result.excluded_draft_adrs),
        "required_readiness_floor": result.required_readiness_floor,
        "selected_adr_ids": list(result.selected_adr_ids),
        "expanded_ndf": [
            {"id": ndf_id, "sha256": digest}
            for ndf_id, digest in result.ndf_digests
        ],
        "blockers": list(result.blockers),
    }
