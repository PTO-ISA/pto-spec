"""Deterministic experimental functional-model descriptor v1."""

from __future__ import annotations

from dataclasses import dataclass
import hashlib
import json
from pathlib import Path
import re
import subprocess
from typing import Iterator


DESCRIPTOR_SCHEMA = "pto-functional-model-descriptor-v1"
DESCRIPTOR_SCHEMA_VERSION = 1
DESCRIPTOR_SCHEMA_ID = (
    "https://pto-isa.org/schemas/pto-functional-model-descriptor-v1.schema.json"
)
FUNCTIONAL_PROFILE_ID = "pto-functional-model-experimental-v1"
CHOICE_POLICY = "pto-v0-indexed-memory-logical-ascending-v1"
MODELGEN_ID = "pto-functional-model-modelgen"
MODELGEN_VERSION = 1
NUMERIC_MATURITY = 0
COMPATIBILITY_MODE = "exact-descriptor-sha256"
SNAPSHOT_SCHEMA = "pto-functional-model-snapshot-v1"
SNAPSHOT_SCHEMA_VERSION = 1
BUNDLE_TILE_SUMMARY_SCHEMA = "pto-bundle-tile-state-sha256-v1"
SHA256 = re.compile(r"[0-9a-f]{64}\Z")
GIT_ID = re.compile(r"[0-9a-f]{40}\Z")
FORBIDDEN_FIELD_NAMES = {"elf", "stack", "tls", "fd", "syscall", "exit", "runner"}


class DescriptorError(ValueError):
    """Descriptor input or output violates the v1 contract."""


@dataclass(frozen=True)
class DescriptorInputs:
    pto_mir: bytes
    executable_image: bytes
    mir_readiness: bytes
    executable_readiness: bytes
    release_manifest: bytes
    runtime_capabilities: bytes
    snapshot_contract: bytes
    pto_mir_schema: bytes
    executable_mir_schema: bytes
    descriptor_schema: bytes
    aslref_pin: bytes
    c_abi_header: bytes
    descriptor_module: bytes
    descriptor_generator: bytes


def _sha256(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest()


def _json(content: bytes, label: str) -> dict[str, object]:
    try:
        value = json.loads(content)
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise DescriptorError(f"{label} is not valid UTF-8 JSON: {error}") from error
    if not isinstance(value, dict):
        raise DescriptorError(f"{label} must contain a JSON object")
    return value


def _canonical_json(document: dict[str, object]) -> bytes:
    return (json.dumps(document, sort_keys=True, separators=(",", ":")) + "\n").encode(
        "utf-8"
    )


def _require_sha256(value: object, label: str) -> str:
    if not isinstance(value, str) or SHA256.fullmatch(value) is None:
        raise DescriptorError(f"{label} must be a lowercase SHA-256")
    return value


def _require_git_id(value: str, label: str) -> str:
    if GIT_ID.fullmatch(value) is None:
        raise DescriptorError(f"{label} must be a full lowercase Git object ID")
    return value


def _schema_contract(content: bytes) -> None:
    schema = _json(content, "descriptor schema")
    if schema.get("$id") != DESCRIPTOR_SCHEMA_ID:
        raise DescriptorError("descriptor schema $id mismatch")
    if schema.get("x-pto-schema-version") != DESCRIPTOR_SCHEMA_VERSION:
        raise DescriptorError("descriptor schema version mismatch")
    try:
        schema_name = schema["properties"]["schema"]["const"]  # type: ignore[index]
        schema_version = schema["properties"]["schema_version"]["const"]  # type: ignore[index]
    except (KeyError, TypeError) as error:
        raise DescriptorError("descriptor schema is missing root constants") from error
    if schema_name != DESCRIPTOR_SCHEMA or schema_version != DESCRIPTOR_SCHEMA_VERSION:
        raise DescriptorError("descriptor schema root contract mismatch")


def _parse_aslref_pin(content: bytes) -> str:
    try:
        pin = content.decode("ascii").strip()
    except UnicodeDecodeError as error:
        raise DescriptorError("ASLRef pin must be ASCII") from error
    return _require_git_id(pin, "ASLRef pin")


def _parse_c_abi_version(content: bytes) -> int:
    try:
        header = content.decode("utf-8")
    except UnicodeDecodeError as error:
        raise DescriptorError("C ABI header must be UTF-8") from error
    match = re.search(
        r"^#define PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION "
        r"UINT32_C\(0x([0-9A-Fa-f]{8})\)$",
        header,
        re.MULTILINE,
    )
    if match is None:
        raise DescriptorError("C ABI header lacks the exact experimental ABI macro")
    return int(match.group(1), 16)


def _binding_table(image: dict[str, object]) -> tuple[int, str]:
    try:
        bindings = image["tables"]["bindings"]  # type: ignore[index]
    except (KeyError, TypeError) as error:
        raise DescriptorError("executable image lacks a numeric binding table") from error
    if not isinstance(bindings, list):
        raise DescriptorError("executable numeric binding table must be a list")
    impdefs: list[dict[str, object]] = []
    for row in bindings:
        if not isinstance(row, dict):
            raise DescriptorError("numeric binding row must be an object")
        if row.get("kind") == "impdef":
            if set(row) != {"id", "kind", "name_symbol_id"}:
                raise DescriptorError("numeric impdef binding row is malformed")
            impdefs.append(row)
    identifiers = [row["id"] for row in impdefs]
    if identifiers != sorted(set(identifiers)):
        raise DescriptorError("numeric impdef binding IDs are not unique and sorted")
    canonical = json.dumps(impdefs, sort_keys=True, separators=(",", ":")).encode(
        "utf-8"
    )
    return len(impdefs), _sha256(canonical)


def _normalized_inputs(inputs: DescriptorInputs) -> dict[str, str]:
    return {
        "aslref_pin": _sha256(inputs.aslref_pin),
        "c_abi_header": _sha256(inputs.c_abi_header),
        "descriptor_generator": _sha256(inputs.descriptor_generator),
        "descriptor_module": _sha256(inputs.descriptor_module),
        "descriptor_schema": _sha256(inputs.descriptor_schema),
        "executable_image": _sha256(inputs.executable_image),
        "executable_mir_schema": _sha256(inputs.executable_mir_schema),
        "executable_readiness": _sha256(inputs.executable_readiness),
        "mir_readiness": _sha256(inputs.mir_readiness),
        "pto_mir": _sha256(inputs.pto_mir),
        "pto_mir_schema": _sha256(inputs.pto_mir_schema),
        "release_manifest": _sha256(inputs.release_manifest),
        "runtime_capabilities": _sha256(inputs.runtime_capabilities),
        "snapshot_contract": _sha256(inputs.snapshot_contract),
    }


def _forbidden_fields(value: object, path: str = "$") -> Iterator[str]:
    if isinstance(value, dict):
        for key, child in value.items():
            if key.lower() in FORBIDDEN_FIELD_NAMES:
                yield f"{path}.{key}"
            yield from _forbidden_fields(child, f"{path}.{key}")
    elif isinstance(value, list):
        for index, child in enumerate(value):
            yield from _forbidden_fields(child, f"{path}[{index}]")


def build_descriptor(
    *, source_commit: str, source_tree: str, inputs: DescriptorInputs
) -> dict[str, object]:
    _schema_contract(inputs.descriptor_schema)
    source_commit = _require_git_id(source_commit, "source commit")
    source_tree = _require_git_id(source_tree, "source tree")
    aslref_pin = _parse_aslref_pin(inputs.aslref_pin)
    c_abi_version = _parse_c_abi_version(inputs.c_abi_header)

    mir = _json(inputs.pto_mir, "PTO MIR")
    executable = _json(inputs.executable_image, "executable image")
    mir_readiness = _json(inputs.mir_readiness, "MIR readiness")
    executable_readiness = _json(
        inputs.executable_readiness, "executable MIR readiness"
    )
    release_manifest = _json(inputs.release_manifest, "release manifest")
    runtime_capabilities = _json(
        inputs.runtime_capabilities, "runtime capabilities"
    )
    snapshot_contract = _json(inputs.snapshot_contract, "snapshot contract")

    if mir.get("schema") != "pto-mir-v1":
        raise DescriptorError("PTO MIR schema mismatch")
    if executable.get("schema") != "pto-executable-mir-v1":
        raise DescriptorError("executable image schema mismatch")
    mir_hash = _sha256(inputs.pto_mir)
    executable_hash = _sha256(inputs.executable_image)
    if mir_readiness.get("mir", {}).get("sha256") != mir_hash:  # type: ignore[union-attr]
        raise DescriptorError("MIR readiness hash mismatch")
    if executable_readiness.get("model_image", {}).get("sha256") != executable_hash:  # type: ignore[union-attr]
        raise DescriptorError("executable readiness hash mismatch")
    if executable_readiness.get("input_mir", {}).get("sha256") != mir_hash:  # type: ignore[union-attr]
        raise DescriptorError("executable readiness input MIR hash mismatch")

    encoding_abi = release_manifest.get("encoding_abi")
    encoding_fingerprint = release_manifest.get("encoding_projection_sha256")
    if not isinstance(encoding_abi, str) or not encoding_abi:
        raise DescriptorError("release manifest lacks encoding ABI")
    encoding_fingerprint = _require_sha256(
        encoding_fingerprint, "encoding fingerprint"
    )
    if runtime_capabilities.get("schema") != (
        "pto-functional-model-runtime-capabilities-v1"
    ):
        raise DescriptorError("runtime capability schema mismatch")
    if (
        snapshot_contract.get("schema")
        != "pto-functional-model-snapshot-contract-v1"
        or snapshot_contract.get("snapshot_schema") != SNAPSHOT_SCHEMA
        or snapshot_contract.get("snapshot_schema_version")
        != SNAPSHOT_SCHEMA_VERSION
        or snapshot_contract.get("classification")
        != "non-architectural-model-abi"
        or (snapshot_contract.get("bundle_tile_summary") or {}).get("schema")
        != BUNDLE_TILE_SUMMARY_SCHEMA
    ):
        raise DescriptorError("snapshot contract identity mismatch")
    impdef_count, impdef_hash = _binding_table(executable)

    descriptor: dict[str, object] = {
        "schema": DESCRIPTOR_SCHEMA,
        "schema_version": DESCRIPTOR_SCHEMA_VERSION,
        "source": {"pto_commit": source_commit, "pto_tree": source_tree},
        "toolchain": {
            "aslref_pin": aslref_pin,
            "modelgen_id": MODELGEN_ID,
            "modelgen_version": MODELGEN_VERSION,
        },
        "architecture": {
            "encoding_abi": encoding_abi,
            "encoding_fingerprint_sha256": encoding_fingerprint,
            "functional_profile_id": FUNCTIONAL_PROFILE_ID,
            "choice_policy": CHOICE_POLICY,
        },
        "model": {
            "pto_mir_schema": mir["schema"],
            "pto_mir_sha256": mir_hash,
            "executable_image_schema": executable["schema"],
            "executable_image_sha256": executable_hash,
            "numeric_impdef_binding_count": impdef_count,
            "numeric_impdef_binding_table_sha256": impdef_hash,
            "numeric_maturity": NUMERIC_MATURITY,
        },
        "interfaces": {
            "experimental_c_abi_version": c_abi_version,
            "snapshot_schema": SNAPSHOT_SCHEMA,
            "snapshot_schema_version": SNAPSHOT_SCHEMA_VERSION,
            "bundle_tile_summary_schema": BUNDLE_TILE_SUMMARY_SCHEMA,
        },
        "normalized_input_hashes": _normalized_inputs(inputs),
        "compatibility": {"mode": COMPATIBILITY_MODE},
    }
    verify_descriptor(descriptor, inputs=inputs)
    return descriptor


def verify_descriptor(
    descriptor: dict[str, object], *, inputs: DescriptorInputs
) -> None:
    forbidden = list(_forbidden_fields(descriptor))
    if forbidden:
        raise DescriptorError(
            "descriptor contains forbidden runner/host fields: " + ", ".join(forbidden)
        )
    expected_root = {
        "schema",
        "schema_version",
        "source",
        "toolchain",
        "architecture",
        "model",
        "interfaces",
        "normalized_input_hashes",
        "compatibility",
    }
    if set(descriptor) != expected_root:
        raise DescriptorError("descriptor has missing or extra root fields")
    if (
        descriptor["schema"] != DESCRIPTOR_SCHEMA
        or descriptor["schema_version"] != DESCRIPTOR_SCHEMA_VERSION
    ):
        raise DescriptorError("descriptor schema mismatch")
    expected_fields = {
        "source": {"pto_commit", "pto_tree"},
        "toolchain": {"aslref_pin", "modelgen_id", "modelgen_version"},
        "architecture": {
            "encoding_abi",
            "encoding_fingerprint_sha256",
            "functional_profile_id",
            "choice_policy",
        },
        "model": {
            "pto_mir_schema",
            "pto_mir_sha256",
            "executable_image_schema",
            "executable_image_sha256",
            "numeric_impdef_binding_count",
            "numeric_impdef_binding_table_sha256",
            "numeric_maturity",
        },
        "interfaces": {
            "experimental_c_abi_version",
            "snapshot_schema",
            "snapshot_schema_version",
            "bundle_tile_summary_schema",
        },
        "compatibility": {"mode"},
    }
    for category, fields in expected_fields.items():
        value = descriptor[category]
        if not isinstance(value, dict) or set(value) != fields:
            raise DescriptorError(f"descriptor {category} fields mismatch")
    source = descriptor["source"]
    _require_git_id(str(source["pto_commit"]), "descriptor source commit")  # type: ignore[index]
    _require_git_id(str(source["pto_tree"]), "descriptor source tree")  # type: ignore[index]
    toolchain = descriptor["toolchain"]
    if toolchain["aslref_pin"] != _parse_aslref_pin(inputs.aslref_pin):  # type: ignore[index]
        raise DescriptorError("descriptor ASLRef pin mismatch")
    if (
        toolchain["modelgen_id"] != MODELGEN_ID  # type: ignore[index]
        or toolchain["modelgen_version"] != MODELGEN_VERSION  # type: ignore[index]
    ):
        raise DescriptorError("descriptor modelgen identity mismatch")
    release_manifest = _json(inputs.release_manifest, "release manifest")
    architecture = descriptor["architecture"]
    if architecture["encoding_abi"] != release_manifest.get("encoding_abi"):  # type: ignore[index]
        raise DescriptorError("descriptor encoding ABI mismatch")
    if architecture["encoding_fingerprint_sha256"] != release_manifest.get(  # type: ignore[index]
        "encoding_projection_sha256"
    ):
        raise DescriptorError("descriptor encoding fingerprint mismatch")
    if architecture["functional_profile_id"] != FUNCTIONAL_PROFILE_ID:  # type: ignore[index]
        raise DescriptorError("descriptor functional profile mismatch")
    if architecture["choice_policy"] != CHOICE_POLICY:  # type: ignore[index]
        raise DescriptorError("descriptor choice policy mismatch")
    model = descriptor["model"]
    if (
        model["pto_mir_schema"] != "pto-mir-v1"  # type: ignore[index]
        or model["executable_image_schema"] != "pto-executable-mir-v1"  # type: ignore[index]
    ):
        raise DescriptorError("descriptor model schema identity mismatch")
    if model["pto_mir_sha256"] != _sha256(inputs.pto_mir):  # type: ignore[index]
        raise DescriptorError("descriptor PTO MIR hash mismatch")
    if model["executable_image_sha256"] != _sha256(inputs.executable_image):  # type: ignore[index]
        raise DescriptorError("descriptor executable image hash mismatch")
    if model["numeric_maturity"] != NUMERIC_MATURITY:  # type: ignore[index]
        raise DescriptorError("descriptor numeric maturity mismatch")
    count, digest = _binding_table(_json(inputs.executable_image, "executable image"))
    if (
        model["numeric_impdef_binding_count"] != count  # type: ignore[index]
        or model["numeric_impdef_binding_table_sha256"] != digest  # type: ignore[index]
    ):
        raise DescriptorError("descriptor numeric impdef binding hash mismatch")
    interfaces = descriptor["interfaces"]
    if interfaces["experimental_c_abi_version"] != _parse_c_abi_version(  # type: ignore[index]
        inputs.c_abi_header
    ):
        raise DescriptorError("descriptor C ABI version mismatch")
    if (  # type: ignore[index]
        interfaces["snapshot_schema"] != SNAPSHOT_SCHEMA
        or interfaces["snapshot_schema_version"] != SNAPSHOT_SCHEMA_VERSION
        or interfaces["bundle_tile_summary_schema"]
        != BUNDLE_TILE_SUMMARY_SCHEMA
    ):
        raise DescriptorError("descriptor model interface identity mismatch")
    if descriptor["normalized_input_hashes"] != _normalized_inputs(inputs):
        raise DescriptorError("descriptor normalized input hash mismatch")
    if descriptor["compatibility"] != {"mode": COMPATIBILITY_MODE}:
        raise DescriptorError("descriptor compatibility mode mismatch")


def render_descriptor(descriptor: dict[str, object]) -> bytes:
    return _canonical_json(descriptor)


def descriptor_sha256(descriptor_bytes: bytes) -> str:
    return _sha256(descriptor_bytes)


def build_readiness(
    *,
    descriptor: dict[str, object],
    descriptor_bytes: bytes,
    descriptor_schema: bytes,
) -> dict[str, object]:
    source = descriptor["source"]
    return {
        "schema": "pto.functional-model-descriptor-readiness.v1",
        "status": "experimental",
        "publication": "not-public",
        "architecture_requirement": {
            "id": "PTO-REQ-FUNCTIONAL-PROFILE-IDENTITY-001",
            "status": "accepted",
            "disposition": "model descriptor remains non-architectural",
        },
        "source_identity_strategy": {
            "mode": "clean-producer-commit",
            "descriptor_source_commit": source["pto_commit"],  # type: ignore[index]
            "descriptor_source_tree": source["pto_tree"],  # type: ignore[index]
            "readiness_relation": (
                "downstream projection; readiness is not part of the bound source tree"
            ),
            "exact_release_rule": (
                "regenerate from an explicit immutable SOURCE_COMMIT/SOURCE_TREE "
                "and compare the exact descriptor SHA-256"
            ),
            "dirty_default": "fail-closed",
        },
        "descriptor": {
            "schema": DESCRIPTOR_SCHEMA,
            "sha256": descriptor_sha256(descriptor_bytes),
            "size_bytes": len(descriptor_bytes),
        },
        "descriptor_schema": {
            "id": DESCRIPTOR_SCHEMA_ID,
            "sha256": _sha256(descriptor_schema),
            "version": DESCRIPTOR_SCHEMA_VERSION,
        },
        "compatibility": {
            "mode": COMPATIBILITY_MODE,
            "descriptor_sha256": descriptor_sha256(descriptor_bytes),
        },
        "numeric_maturity": NUMERIC_MATURITY,
        "snapshot_schema": SNAPSHOT_SCHEMA,
        "validated": True,
    }


def render_readiness(readiness: dict[str, object]) -> str:
    return json.dumps(readiness, indent=2, sort_keys=True) + "\n"


def resolve_source_identity(
    root: Path,
    source_commit: str | None,
    source_tree: str | None,
) -> tuple[str, str]:
    if (source_commit is None) != (source_tree is None):
        raise DescriptorError("SOURCE_COMMIT and SOURCE_TREE must be supplied together")
    if source_commit is not None and source_tree is not None:
        return (
            _require_git_id(source_commit, "SOURCE_COMMIT"),
            _require_git_id(source_tree, "SOURCE_TREE"),
        )
    status = subprocess.check_output(
        ["git", "status", "--porcelain=v1", "--untracked-files=all"],
        cwd=root,
        text=True,
    )
    if status:
        raise DescriptorError(
            "dirty or uncommitted source tree; pass exact SOURCE_COMMIT and SOURCE_TREE"
        )
    commit = subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=root, text=True
    ).strip()
    tree = subprocess.check_output(
        ["git", "rev-parse", "HEAD^{tree}"], cwd=root, text=True
    ).strip()
    return _require_git_id(commit, "HEAD"), _require_git_id(tree, "HEAD tree")
