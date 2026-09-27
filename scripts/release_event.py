#!/usr/bin/env python3
"""Validate and canonically serialize the PTO-SPEC stable release event."""

from __future__ import annotations

from datetime import datetime
import json
import re


REPOSITORY = "PTO-ISA/pto-spec"
COMMON_FIELDS = (
    "schema_version",
    "repository",
    "tag",
    "commit",
    "release_id",
    "release_url",
    "release_manifest_sha256",
    "published_at",
)
VERSION_DIGEST_FIELDS = {
    "1": "model_closure_semantic_payload_sha256",
    "2": "release_artifact_certification_sha256",
}
TAG = re.compile(
    r"v(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)"
    r"(?:\.(?:0|[1-9][0-9]*)){0,2}"
)
COMMIT = re.compile(r"[0-9a-f]{40}")
SHA256 = re.compile(r"[0-9a-f]{64}")
UTC_TIMESTAMP = re.compile(
    r"[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z"
)


def validate_release_event(payload: object) -> list[str]:
    """Return deterministic violations of the versioned stable release event."""

    if not isinstance(payload, dict):
        return ["release event must be an object"]

    errors: list[str] = []
    schema_version = payload.get("schema_version")
    digest_field = (
        VERSION_DIGEST_FIELDS.get(schema_version)
        if isinstance(schema_version, str)
        else None
    )
    if digest_field is None:
        errors.append("schema_version must be '1' or '2'")
        required_fields = set(COMMON_FIELDS)
    else:
        required_fields = {*COMMON_FIELDS, digest_field}
    actual_fields = set(payload)
    for field in sorted(required_fields - actual_fields):
        errors.append(f"release event is missing required field {field}")
    for field in sorted(actual_fields - required_fields):
        errors.append(f"release event has additional field {field}")

    if payload.get("repository") != REPOSITORY:
        errors.append(f"repository must be {REPOSITORY!r}")

    tag = payload.get("tag")
    if not isinstance(tag, str) or TAG.fullmatch(tag) is None:
        errors.append(
            "tag must match vMAJOR.MINOR, vMAJOR.MINOR.PATCH, or a four-part "
            "publication revision "
            "without leading zeroes"
        )

    commit = payload.get("commit")
    if not isinstance(commit, str) or COMMIT.fullmatch(commit) is None:
        errors.append("commit must be 40 lowercase hexadecimal characters")

    release_id = payload.get("release_id")
    if (
        not isinstance(release_id, int)
        or isinstance(release_id, bool)
        or release_id <= 0
    ):
        errors.append("release_id must be a positive integer")

    release_url = payload.get("release_url")
    expected_url = (
        f"https://github.com/{REPOSITORY}/releases/tag/{tag}"
        if isinstance(tag, str) and TAG.fullmatch(tag)
        else None
    )
    if not isinstance(release_url, str) or release_url != expected_url:
        errors.append("release_url must identify the matching PTO-SPEC GitHub release")

    manifest_hash = payload.get("release_manifest_sha256")
    if not isinstance(manifest_hash, str) or SHA256.fullmatch(manifest_hash) is None:
        errors.append(
            "release_manifest_sha256 must be 64 lowercase hexadecimal characters"
        )

    if digest_field is not None:
        evidence_hash = payload.get(digest_field)
        if not isinstance(evidence_hash, str) or SHA256.fullmatch(evidence_hash) is None:
            errors.append(
                f"{digest_field} must be 64 lowercase hexadecimal characters"
            )

    published_at = payload.get("published_at")
    if not isinstance(published_at, str) or UTC_TIMESTAMP.fullmatch(published_at) is None:
        errors.append("published_at must be a whole-second UTC timestamp ending in Z")
    else:
        try:
            datetime.strptime(published_at, "%Y-%m-%dT%H:%M:%SZ")
        except ValueError:
            errors.append("published_at must be a valid UTC timestamp")

    return errors


def canonical_release_event(payload: object) -> str:
    """Return compact, sorted JSON for one valid stable release event."""

    errors = validate_release_event(payload)
    if errors:
        raise ValueError("\n".join(errors))
    return json.dumps(payload, sort_keys=True, separators=(",", ":"))
