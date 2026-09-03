#!/usr/bin/env python3
"""Validate and canonically serialize the PTO-SPEC stable release event."""

from __future__ import annotations

from datetime import datetime
import json
import re


SCHEMA_VERSION = "1"
REPOSITORY = "PTO-ISA/pto-spec"
REQUIRED_FIELDS = (
    "schema_version",
    "repository",
    "tag",
    "commit",
    "release_id",
    "release_url",
    "release_manifest_sha256",
    "model_closure_semantic_payload_sha256",
    "published_at",
)
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
    """Return deterministic violations of the stable release event v1 contract."""

    if not isinstance(payload, dict):
        return ["release event must be an object"]

    errors: list[str] = []
    actual_fields = set(payload)
    required_fields = set(REQUIRED_FIELDS)
    for field in sorted(required_fields - actual_fields):
        errors.append(f"release event is missing required field {field}")
    for field in sorted(actual_fields - required_fields):
        errors.append(f"release event has additional field {field}")

    if payload.get("schema_version") != SCHEMA_VERSION:
        errors.append(f"schema_version must be {SCHEMA_VERSION!r}")
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

    closure_hash = payload.get("model_closure_semantic_payload_sha256")
    if not isinstance(closure_hash, str) or SHA256.fullmatch(closure_hash) is None:
        errors.append(
            "model_closure_semantic_payload_sha256 must be 64 lowercase hexadecimal characters"
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
