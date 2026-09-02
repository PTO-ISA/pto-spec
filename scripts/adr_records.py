"""Parse and validate PTO architecture decision records."""

from __future__ import annotations

from collections.abc import Sequence
from dataclasses import dataclass
from datetime import date
import json
from pathlib import Path
import re
from urllib.parse import urlsplit


@dataclass(frozen=True)
class AdrAmendment:
    date: str
    baseline: str
    approvers: tuple[str, ...]
    issue: str
    affected_ndf: tuple[str, ...]
    affected_units: tuple[str, ...]


@dataclass(frozen=True)
class AdrRecord:
    adr_id: str
    title: str
    title_zh: str
    status: str
    authors: tuple[str, ...]
    approvers: tuple[str, ...]
    created: str
    accepted: str | None
    rejected: str | None
    superseded: str | None
    baseline: str
    target_releases: tuple[str, ...]
    affected_ndf: tuple[str, ...]
    affected_units: tuple[str, ...]
    resolves: tuple[str, ...]
    supersedes: tuple[str, ...]
    superseded_by: tuple[str, ...]
    implementation_issue: str | None
    release_impact: str
    release_boundary: bool
    interface_change: bool
    amendments: tuple[AdrAmendment, ...]
    legacy_ids: tuple[str, ...]
    path: Path


_FIELDS = {
    "id",
    "title",
    "title_zh",
    "status",
    "authors",
    "approvers",
    "created",
    "accepted",
    "rejected",
    "superseded",
    "baseline",
    "target_releases",
    "affected_ndf",
    "affected_units",
    "resolves",
    "supersedes",
    "superseded_by",
    "implementation_issue",
    "release_impact",
    "release_boundary",
    "interface_change",
    "amendments",
    "legacy_ids",
}
_OPTIONAL_FIELDS = {"release_boundary", "interface_change", "amendments"}
ADR_TYPE_ORDER = ("GOV", "STATE", "MEM", "BLOCK", "SCALAR", "TILE", "CUBE", "NUM")
_ADR_TYPE_INDEX = {adr_type: index for index, adr_type in enumerate(ADR_TYPE_ORDER)}
_ADR_ID = re.compile(rf"ADR-(?:{'|'.join(ADR_TYPE_ORDER)})-[0-9]{{4}}\Z")
_BASELINE = re.compile(r"[0-9a-f]{40}\Z")
_RELEASE = re.compile(r"(?:[0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)?|unassigned)\Z")
_NDF_ID = re.compile(r"PTO-[A-Z0-9]+(?:-[A-Z0-9]+)*\Z")
_AMENDMENT_FIELDS = {
    "date",
    "baseline",
    "approvers",
    "issue",
    "affected_ndf",
    "affected_units",
}
_LEGACY_ID = re.compile(
    r"(?:ADR-[0-9]{4}|PRD-[0-9]{3}|PDR-[0-9]{3}|PD-[0-9]{2}(?:-[A-Z0-9]+)?)\Z"
)
_URI_LABEL = r"[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?"
_URI_HOST = rf"{_URI_LABEL}(?:\.{_URI_LABEL})*"
_URI_PORT = (
    r"(?:[1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|"
    r"65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])"
)
_URI_PERCENT = r"%[0-9A-Fa-f]{2}"
_URI_PCHAR = rf"(?:[A-Za-z0-9._~!$&'()*+,;=:@-]|{_URI_PERCENT})"
_URI_QUERY_CHAR = rf"(?:{_URI_PCHAR}|[/?])"
_HTTPS_ISSUE_URI = re.compile(
    rf"https://{_URI_HOST}(?::{_URI_PORT})?"
    rf"(?:/{_URI_PCHAR}*)*"
    rf"(?:\?{_URI_QUERY_CHAR}*)?"
    rf"(?:#{_URI_QUERY_CHAR}*)?\Z"
)


def _frontmatter(text: str, path: Path) -> dict[str, object]:
    lines = text.splitlines()
    if len(lines) < 3 or lines[0] != "---":
        raise ValueError(f"{path}: missing JSON frontmatter")
    try:
        end = lines.index("---", 1)
    except ValueError as error:
        raise ValueError(f"{path}: unterminated JSON frontmatter") from error
    try:
        value = json.loads("\n".join(lines[1:end]))
    except json.JSONDecodeError as error:
        raise ValueError(f"{path}: invalid JSON frontmatter: {error}") from error
    if not isinstance(value, dict):
        raise ValueError(f"{path}: ADR frontmatter must be an object")
    return value


def _error(path: Path, message: str) -> ValueError:
    return ValueError(f"{path}: {message}")


def adr_sort_key(adr_id: str) -> tuple[int, int]:
    """Return the canonical category/serial ordering for a validated ADR ID."""
    match = _ADR_ID.fullmatch(adr_id)
    if match is None:
        raise ValueError(f"invalid ADR id: {adr_id!r}")
    _, adr_type, serial = adr_id.split("-")
    return (_ADR_TYPE_INDEX[adr_type], int(serial))


def _string(
    metadata: dict[str, object],
    key: str,
    path: Path,
    pattern: re.Pattern[str] | None = None,
) -> str:
    value = metadata[key]
    if not isinstance(value, str) or not value:
        raise _error(path, f"{key} must be a nonempty string")
    if pattern is not None and pattern.fullmatch(value) is None:
        raise _error(path, f"invalid {key}: {value!r}")
    return value


def _optional_string(metadata: dict[str, object], key: str, path: Path) -> str | None:
    value = metadata[key]
    if value is not None and (not isinstance(value, str) or not value):
        raise _error(path, f"{key} must be a nonempty string or null")
    return value


def _date(value: str, key: str, path: Path) -> str:
    if re.fullmatch(r"[0-9]{4}-[0-9]{2}-[0-9]{2}", value) is None:
        raise _error(path, f"invalid {key} date: {value!r}")
    try:
        date.fromisoformat(value)
    except ValueError as error:
        raise _error(path, f"invalid {key} date: {value!r}") from error
    return value


def _optional_date(metadata: dict[str, object], key: str, path: Path) -> str | None:
    value = _optional_string(metadata, key, path)
    return None if value is None else _date(value, key, path)


def _absolute_uri(value: str, key: str, path: Path) -> str:
    """Validate the schema's narrow absolute HTTPS issue-URI contract.

    The shared schema/runtime grammar requires the literal lowercase
    ``https://`` scheme, a DNS/IPv4-style hostname without userinfo or IPv6, an
    optional numeric port from 1 through 65535, and ASCII RFC 3986 path, query,
    and fragment characters with valid percent escapes. Query and fragment
    delimiters may each occur once and in that order.
    """
    if _HTTPS_ISSUE_URI.fullmatch(value) is None:
        raise _error(path, f"invalid {key} URI: {value!r}")
    try:
        parsed = urlsplit(value)
        port = parsed.port
    except ValueError as error:
        raise _error(path, f"invalid {key} URI: {value!r}") from error
    if (
        parsed.scheme != "https"
        or parsed.hostname is None
        or parsed.username is not None
        or parsed.password is not None
        or (port is not None and not 1 <= port <= 65535)
    ):
        raise _error(path, f"invalid {key} URI: {value!r}")
    return value


def _strings(
    metadata: dict[str, object],
    key: str,
    path: Path,
    *,
    min_items: int = 0,
    pattern: re.Pattern[str] | None = None,
) -> tuple[str, ...]:
    value = metadata[key]
    if not isinstance(value, list):
        raise _error(path, f"{key} must be an array")
    if len(value) < min_items:
        raise _error(path, f"{key} must contain at least {min_items} item(s)")
    if any(not isinstance(item, str) or not item for item in value):
        raise _error(path, f"{key} items must be nonempty strings")
    strings = tuple(value)
    if len(set(strings)) != len(strings):
        raise _error(path, f"{key} items must be unique")
    if pattern is not None:
        for item in strings:
            if pattern.fullmatch(item) is None:
                raise _error(path, f"invalid {key} item: {item!r}")
    return strings


def _reject_downstream_identifiers(
    path: Path, field: str, identifiers: tuple[str, ...]
) -> None:
    downstream = next(
        (
            identifier
            for identifier in identifiers
            if identifier.startswith("PTO-MODEL-")
        ),
        None,
    )
    if downstream is not None:
        raise _error(
            path,
            f"{field} contains downstream ASL-Model identifier {downstream}; "
            "PTO-SPEC records only PTO-owned NDF and ASL identities",
        )


def _amendments(metadata: dict[str, object], path: Path) -> tuple[AdrAmendment, ...]:
    value = metadata.get("amendments", [])
    if not isinstance(value, list):
        raise _error(path, "amendments must be an array")
    amendments: list[AdrAmendment] = []
    identities: set[tuple[str, str, str]] = set()
    for index, item in enumerate(value):
        where = f"amendments[{index}]"
        if not isinstance(item, dict):
            raise _error(path, f"{where} must be an object")
        missing = sorted(_AMENDMENT_FIELDS - item.keys())
        unknown = sorted(item.keys() - _AMENDMENT_FIELDS)
        if missing or unknown:
            raise _error(
                path, f"{where} fields mismatch: missing={missing}, unknown={unknown}"
            )
        date_value = _date(_string(item, "date", path), f"{where}.date", path)
        baseline = _string(item, "baseline", path, _BASELINE)
        approvers = _strings(item, "approvers", path, min_items=1)
        issue = _absolute_uri(_string(item, "issue", path), f"{where}.issue", path)
        affected_ndf = _strings(
            item, "affected_ndf", path, min_items=1, pattern=_NDF_ID
        )
        affected_units = _strings(
            item, "affected_units", path, min_items=1, pattern=_NDF_ID
        )
        _reject_downstream_identifiers(path, f"{where}.affected_ndf", affected_ndf)
        _reject_downstream_identifiers(path, f"{where}.affected_units", affected_units)
        identity = (date_value, baseline, issue)
        if identity in identities:
            raise _error(path, f"duplicate amendment provenance: {identity}")
        identities.add(identity)
        amendments.append(
            AdrAmendment(
                date=date_value,
                baseline=baseline,
                approvers=approvers,
                issue=issue,
                affected_ndf=affected_ndf,
                affected_units=affected_units,
            )
        )
    return tuple(amendments)


def parse_adr(path: Path) -> AdrRecord:
    metadata = _frontmatter(path.read_text(encoding="utf-8"), path)
    status = metadata.get("status")
    if status not in ("draft", "accepted", "rejected", "superseded"):
        raise ValueError(f"{path}: invalid status: {status!r}")
    missing = sorted(_FIELDS - _OPTIONAL_FIELDS - metadata.keys())
    if missing:
        raise _error(path, f"missing required fields: {', '.join(missing)}")
    unknown = sorted(metadata.keys() - _FIELDS)
    if unknown:
        raise _error(path, f"unknown fields: {', '.join(unknown)}")

    adr_id = _string(metadata, "id", path, _ADR_ID)
    _, adr_type, serial = adr_id.split("-")
    filename = re.fullmatch(
        r"ADR-([A-Z]+)-([0-9]{4})-[a-z0-9]+(?:-[a-z0-9]+)*\.md", path.name
    )
    if filename is None or filename.groups() != (adr_type, serial):
        raise _error(path, f"filename does not match {adr_id}")

    title = _string(metadata, "title", path)
    title_zh = _string(metadata, "title_zh", path)
    authors = _strings(metadata, "authors", path, min_items=1)
    approvers = _strings(metadata, "approvers", path)
    created = _date(_string(metadata, "created", path), "created", path)
    accepted = _optional_date(metadata, "accepted", path)
    rejected = _optional_date(metadata, "rejected", path)
    superseded = _optional_date(metadata, "superseded", path)
    baseline = _string(metadata, "baseline", path, _BASELINE)
    target_releases = _strings(
        metadata, "target_releases", path, min_items=1, pattern=_RELEASE
    )
    affected_ndf = _strings(metadata, "affected_ndf", path, pattern=_NDF_ID)
    affected_units = _strings(metadata, "affected_units", path, pattern=_NDF_ID)
    for field, identifiers in (
        ("affected_ndf", affected_ndf),
        ("affected_units", affected_units),
    ):
        _reject_downstream_identifiers(path, field, identifiers)
    resolves = _strings(metadata, "resolves", path, pattern=_ADR_ID)
    supersedes = _strings(metadata, "supersedes", path, pattern=_ADR_ID)
    superseded_by = _strings(metadata, "superseded_by", path, pattern=_ADR_ID)
    implementation_issue = _optional_string(metadata, "implementation_issue", path)
    if implementation_issue is not None:
        implementation_issue = _absolute_uri(
            implementation_issue, "implementation_issue", path
        )
    release_impact = metadata["release_impact"]
    if release_impact not in ("required", "not-required"):
        raise _error(path, f"invalid release_impact: {release_impact!r}")
    release_boundary = metadata.get("release_boundary", False)
    if not isinstance(release_boundary, bool):
        raise _error(path, "release_boundary must be a boolean")
    interface_change = metadata.get("interface_change", False)
    if not isinstance(interface_change, bool):
        raise _error(path, "interface_change must be a boolean")
    legacy_ids = _strings(metadata, "legacy_ids", path, pattern=_LEGACY_ID)
    migrated_from_adr = any(re.fullmatch(r"ADR-[0-9]{4}", item) for item in legacy_ids)
    if not migrated_from_adr and not interface_change:
        raise _error(
            path,
            "new typed ADRs require interface_change=true; implementation and ASL "
            "bug fixes must update their existing decision owner",
        )
    amendments = _amendments(metadata, path)
    for amendment in amendments:
        if not set(amendment.affected_ndf).issubset(affected_ndf):
            raise _error(
                path, "amendment affected_ndf must be included in ADR affected_ndf"
            )
        if not set(amendment.affected_units).issubset(affected_units):
            raise _error(
                path, "amendment affected_units must be included in ADR affected_units"
            )
    if status == "accepted":
        if not approvers:
            raise _error(path, "accepted ADR requires approvers")
        if accepted is None:
            raise _error(path, "accepted ADR requires an acceptance date")
        if not affected_ndf:
            raise _error(path, "accepted ADR requires affected_ndf")
    elif status == "rejected" and rejected is None:
        raise _error(path, "rejected ADR requires a rejection date")
    elif status == "superseded":
        if superseded is None:
            raise _error(path, "superseded ADR requires a supersession date")
        if not superseded_by:
            raise _error(path, "superseded ADR requires superseded_by")

    return AdrRecord(
        adr_id=adr_id,
        title=title,
        title_zh=title_zh,
        status=status,
        authors=authors,
        approvers=approvers,
        created=created,
        accepted=accepted,
        rejected=rejected,
        superseded=superseded,
        baseline=baseline,
        target_releases=target_releases,
        affected_ndf=affected_ndf,
        affected_units=affected_units,
        resolves=resolves,
        supersedes=supersedes,
        superseded_by=superseded_by,
        implementation_issue=implementation_issue,
        release_impact=release_impact,
        release_boundary=release_boundary,
        interface_change=interface_change,
        amendments=amendments,
        legacy_ids=legacy_ids,
        path=path,
    )


def load_adrs(root: Path) -> tuple[AdrRecord, ...]:
    if not root.is_dir():
        raise ValueError(f"{root}: ADR directory does not exist")
    paths = sorted(
        path
        for path in root.rglob("*.md")
        if path.is_file() and path.suffix == ".md" and path.name != "0000-template.md"
    )
    return tuple(
        sorted(
            (parse_adr(path) for path in paths),
            key=lambda row: adr_sort_key(row.adr_id),
        )
    )


def validate_adr_graph(records: Sequence[AdrRecord]) -> list[str]:
    errors: list[str] = []
    by_id: dict[str, AdrRecord] = {}
    for record in records:
        previous = by_id.get(record.adr_id)
        if previous is not None:
            errors.append(
                f"duplicate ADR id {record.adr_id}: {previous.path} and {record.path}"
            )
        else:
            by_id[record.adr_id] = record

    for adr_type in ADR_TYPE_ORDER:
        serials = sorted(
            int(adr_id.rsplit("-", 1)[1])
            for adr_id in by_id
            if adr_id.startswith(f"ADR-{adr_type}-")
        )
        if serials:
            expected = list(range(1, serials[-1] + 1))
            if serials != expected:
                errors.append(
                    f"{adr_type} ADR serials must be contiguous from 0001; "
                    f"found {serials}"
                )

    legacy_owner: dict[str, AdrRecord] = {}
    for record in records:
        for legacy_id in record.legacy_ids:
            previous = legacy_owner.get(legacy_id)
            if previous is not None:
                errors.append(
                    f"duplicate legacy id {legacy_id}: "
                    f"{previous.adr_id} and {record.adr_id}"
                )
            else:
                legacy_owner[legacy_id] = record

    for record in records:
        for relation, references in (
            ("resolves", record.resolves),
            ("supersedes", record.supersedes),
            ("superseded_by", record.superseded_by),
        ):
            for reference in references:
                if reference not in by_id:
                    errors.append(
                        f"{record.adr_id} {relation} unknown ADR reference {reference}"
                    )

        for replaced_id in record.supersedes:
            replaced = by_id.get(replaced_id)
            if replaced is not None and record.adr_id not in replaced.superseded_by:
                errors.append(
                    f"{record.adr_id} supersedes {replaced_id}, but the relationship "
                    "is not reciprocal"
                )
        for replacement_id in record.superseded_by:
            replacement = by_id.get(replacement_id)
            if replacement is not None and record.adr_id not in replacement.supersedes:
                errors.append(
                    f"{record.adr_id} is superseded_by {replacement_id}, but the "
                    "relationship is not reciprocal"
                )

    colors: dict[str, int] = {}

    def visit(adr_id: str, stack: list[str]) -> None:
        color = colors.get(adr_id, 0)
        if color == 1:
            cycle_start = stack.index(adr_id)
            cycle = stack[cycle_start:] + [adr_id]
            errors.append(f"supersession cycle: {' -> '.join(cycle)}")
            return
        if color == 2:
            return
        colors[adr_id] = 1
        stack.append(adr_id)
        for replaced_id in by_id[adr_id].supersedes:
            if replaced_id in by_id:
                visit(replaced_id, stack)
        stack.pop()
        colors[adr_id] = 2

    for adr_id in sorted(by_id, key=adr_sort_key):
        if colors.get(adr_id, 0) == 0:
            visit(adr_id, [])

    return errors
