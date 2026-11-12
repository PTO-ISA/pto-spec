"""Current accepted binary-form inventory, separate from publication identity."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path


EXPECTED_SCALAR_FORM_COUNT = 473
EXPECTED_SCOPED_SCALAR_FORM_COUNT = 705
EXPECTED_COMMAND_FORM_COUNT = 105
EXPECTED_CURRENT_FORM_COUNT = (
    EXPECTED_SCALAR_FORM_COUNT
    + EXPECTED_SCOPED_SCALAR_FORM_COUNT
    + EXPECTED_COMMAND_FORM_COUNT
)
EXPECTED_RELEASE_FORM_COUNT = EXPECTED_SCALAR_FORM_COUNT + EXPECTED_COMMAND_FORM_COUNT

# Keep this projection byte-compatible with the frozen publication identity.
RELEASE_PROJECTION_KEYS = (
    "form_id",
    "mnemonic",
    "asm",
    "length_bits",
    "encoding_kind",
    "encoding",
    "fields",
    "constraints",
)
EXPECTED_RELEASE_FINGERPRINT = (
    "b36951095971458987ae8de8c918279cfbbefc44a5618c855624bc4d3d03809d"
)

# The current-source identity binds each scoped form to its base handler,
# request scope, inner length, exact encoding and operand/constraint metadata.
CURRENT_SOURCE_PROJECTION_KEYS = (
    "form_id",
    "mnemonic",
    "asm",
    "length_bits",
    "encoding_kind",
    "encoding",
    "fields",
    "constraints",
    "operands",
    "base_form_id",
    "inner_length_bits",
    "scope",
    "scope_code",
    "semantic_handler",
    "semantic_family",
)
EXPECTED_CURRENT_SOURCE_FINGERPRINT = (
    "34a49d80f758af9ab3c40dc8139d32e2862f313a47dbe1506e17dade886df0ae"
)


def _read_json(root: Path, relative: str) -> dict:
    return json.loads((root / relative).read_text(encoding="utf-8"))


def _forms(catalog: dict, key: str, label: str, expected: int) -> list[dict]:
    forms = catalog.get(key)
    if not isinstance(forms, list) or len(forms) != expected:
        actual = len(forms) if isinstance(forms, list) else "missing"
        raise ValueError(f"{label} closure must contain exactly {expected} forms, got {actual}")
    return forms


def load_form_inventories(root: Path) -> tuple[list[dict], list[dict]]:
    """Return current accepted forms and the legacy release-boundary forms."""
    scalar = _read_json(root, "spec/catalog/scalar-forms.json")
    command = _read_json(root, "spec/catalog/command-forms.json")

    if scalar.get("form_count") != EXPECTED_SCALAR_FORM_COUNT:
        raise ValueError("legacy Scalar form_count disagrees with the frozen inventory")
    if scalar.get("scoped_form_count") != EXPECTED_SCOPED_SCALAR_FORM_COUNT:
        raise ValueError("scoped Scalar form_count disagrees with the current inventory")
    if command.get("form_count") != EXPECTED_COMMAND_FORM_COUNT:
        raise ValueError("command form_count disagrees with the frozen inventory")

    scalar_forms = _forms(
        scalar, "forms", "legacy Scalar", EXPECTED_SCALAR_FORM_COUNT
    )
    scoped_forms = _forms(
        scalar, "scoped_forms", "scoped Scalar", EXPECTED_SCOPED_SCALAR_FORM_COUNT
    )
    command_forms = _forms(
        command, "forms", "command", EXPECTED_COMMAND_FORM_COUNT
    )

    current_forms = [*scalar_forms, *scoped_forms, *command_forms]
    release_forms = [*scalar_forms, *command_forms]
    for label, forms in (("current", current_forms), ("release", release_forms)):
        ids = [row.get("form_id") for row in forms]
        if any(not isinstance(form_id, str) or not form_id for form_id in ids):
            raise ValueError(f"{label} form inventory contains a missing form_id")
        if len(ids) != len(set(ids)):
            raise ValueError(f"{label} form IDs are not globally unique")
    return current_forms, release_forms


def project_forms(forms: list[dict], keys: tuple[str, ...]) -> list[dict]:
    return [
        {key: row.get(key) for key in keys}
        for row in sorted(forms, key=lambda row: row["form_id"])
    ]


def fingerprint(forms: list[dict], keys: tuple[str, ...]) -> str:
    payload = json.dumps(
        project_forms(forms, keys), sort_keys=True, separators=(",", ":")
    ).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def check_current_source_binary(root: Path) -> tuple[int, str]:
    current_forms, _ = load_form_inventories(root)
    if len(current_forms) != EXPECTED_CURRENT_FORM_COUNT:
        raise ValueError(
            f"current accepted-form count drift: expected {EXPECTED_CURRENT_FORM_COUNT}, "
            f"got {len(current_forms)}"
        )
    actual = fingerprint(current_forms, CURRENT_SOURCE_PROJECTION_KEYS)
    if actual != EXPECTED_CURRENT_SOURCE_FINGERPRINT:
        raise ValueError(
            "current-source accepted-form fingerprint drift: expected "
            f"{EXPECTED_CURRENT_SOURCE_FINGERPRINT}, got {actual}"
        )
    return len(current_forms), actual


def check_release_binary(root: Path) -> tuple[int, str]:
    _, release_forms = load_form_inventories(root)
    if len(release_forms) != EXPECTED_RELEASE_FORM_COUNT:
        raise ValueError(
            f"published release form count drift: expected {EXPECTED_RELEASE_FORM_COUNT}, "
            f"got {len(release_forms)}"
        )
    actual = fingerprint(release_forms, RELEASE_PROJECTION_KEYS)
    if actual != EXPECTED_RELEASE_FINGERPRINT:
        raise ValueError(
            "published release encoding fingerprint drift: expected "
            f"{EXPECTED_RELEASE_FINGERPRINT}, got {actual}"
        )
    return len(release_forms), actual
