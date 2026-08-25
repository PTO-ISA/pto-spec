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
class AdrRecord:
    adr_id: str
    title: str
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
    legacy_ids: tuple[str, ...]
    path: Path


_FIELDS = {
    "id",
    "title",
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
    "legacy_ids",
}
_ADR_ID = re.compile(r"ADR-[0-9]{4}\Z")
_BASELINE = re.compile(r"[0-9a-f]{40}\Z")
_RELEASE = re.compile(r"(?:[0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)?|unassigned)\Z")
_NDF_ID = re.compile(r"PTO-[A-Z0-9]+(?:-[A-Z0-9]+)*\Z")
_LEGACY_ID = re.compile(r"(?:PRD-[0-9]{3}|PDR-[0-9]{3}|PD-[0-9]{2}(?:-[A-Z0-9]+)?)\Z")
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


def _string(
    metadata: dict[str, object], key: str, path: Path, pattern: re.Pattern[str] | None = None
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


def parse_adr(path: Path) -> AdrRecord:
    metadata = _frontmatter(path.read_text(encoding="utf-8"), path)
    status = metadata.get("status")
    if status not in ("draft", "accepted", "rejected", "superseded"):
        raise ValueError(f"{path}: invalid status: {status!r}")
    missing = sorted(_FIELDS - metadata.keys())
    if missing:
        raise _error(path, f"missing required fields: {', '.join(missing)}")
    unknown = sorted(metadata.keys() - _FIELDS)
    if unknown:
        raise _error(path, f"unknown fields: {', '.join(unknown)}")

    adr_id = _string(metadata, "id", path, _ADR_ID)
    filename = re.fullmatch(r"([0-9]{4})-.+\.md", path.name)
    if filename is None or filename.group(1) != adr_id.removeprefix("ADR-"):
        raise _error(path, f"filename does not match {adr_id}")

    title = _string(metadata, "title", path)
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
    resolves = _strings(metadata, "resolves", path, pattern=_ADR_ID)
    supersedes = _strings(metadata, "supersedes", path, pattern=_ADR_ID)
    superseded_by = _strings(metadata, "superseded_by", path, pattern=_ADR_ID)
    implementation_issue = _optional_string(
        metadata, "implementation_issue", path
    )
    if implementation_issue is not None:
        implementation_issue = _absolute_uri(
            implementation_issue, "implementation_issue", path
        )
    release_impact = metadata["release_impact"]
    if release_impact not in ("required", "not-required"):
        raise _error(path, f"invalid release_impact: {release_impact!r}")
    legacy_ids = _strings(metadata, "legacy_ids", path, pattern=_LEGACY_ID)

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
    return tuple(parse_adr(path) for path in paths)


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

    for adr_id in sorted(by_id):
        if colors.get(adr_id, 0) == 0:
            visit(adr_id, [])

    return errors
