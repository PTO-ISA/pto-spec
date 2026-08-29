from __future__ import annotations

import copy
import hashlib
import json
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
MODELGEN = ROOT / "tools/functional-model/modelgen"

import sys

if str(MODELGEN) not in sys.path:
    sys.path.insert(0, str(MODELGEN))

from descriptor import (  # noqa: E402
    CHOICE_POLICY,
    COMPATIBILITY_MODE,
    DescriptorError,
    DescriptorInputs,
    build_descriptor,
    build_readiness,
    render_descriptor,
    resolve_source_identity,
    verify_descriptor,
)


COMMIT = "1" * 40
TREE = "2" * 40


def canonical(document: dict[str, object]) -> bytes:
    return (json.dumps(document, sort_keys=True, separators=(",", ":")) + "\n").encode()


def fixture_inputs() -> DescriptorInputs:
    mir = canonical({"schema": "pto-mir-v1"})
    executable = canonical(
        {
            "schema": "pto-executable-mir-v1",
            "tables": {
                "bindings": [
                    {"id": 7, "kind": "impdef", "name_symbol_id": 11},
                    {"id": 8, "kind": "primitive", "name_symbol_id": 12},
                ]
            },
        }
    )
    mir_readiness = canonical(
        {"mir": {"sha256": hashlib.sha256(mir).hexdigest()}}
    )
    executable_readiness = canonical(
        {
            "input_mir": {"sha256": hashlib.sha256(mir).hexdigest()},
            "model_image": {"sha256": hashlib.sha256(executable).hexdigest()},
        }
    )
    return DescriptorInputs(
        pto_mir=mir,
        executable_image=executable,
        mir_readiness=mir_readiness,
        executable_readiness=executable_readiness,
        release_manifest=canonical(
            {
                "encoding_abi": "pto-test-encoding-v1",
                "encoding_projection_sha256": "3" * 64,
            }
        ),
        runtime_capabilities=canonical(
            {"schema": "pto-functional-model-runtime-capabilities-v1"}
        ),
        pto_mir_schema=b"pto-mir-schema\n",
        executable_mir_schema=b"executable-mir-schema\n",
        descriptor_schema=(
            ROOT / "spec/schemas/pto-functional-model-descriptor-v1.schema.json"
        ).read_bytes(),
        aslref_pin=("4" * 40 + "\n").encode(),
        c_abi_header=(
            b"#define PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION "
            b"UINT32_C(0x00030001)\n"
        ),
        descriptor_module=b"descriptor-module\n",
        descriptor_generator=b"descriptor-generator\n",
    )


class FunctionalModelDescriptorTest(unittest.TestCase):
    def descriptor(self) -> tuple[dict[str, object], DescriptorInputs]:
        inputs = fixture_inputs()
        return (
            build_descriptor(source_commit=COMMIT, source_tree=TREE, inputs=inputs),
            inputs,
        )

    def test_descriptor_is_canonical_deterministic_and_complete(self) -> None:
        descriptor, inputs = self.descriptor()
        first = render_descriptor(descriptor)
        second = render_descriptor(
            build_descriptor(source_commit=COMMIT, source_tree=TREE, inputs=inputs)
        )
        self.assertEqual(first, second)
        self.assertTrue(first.endswith(b"\n"))
        self.assertNotIn(b"\n ", first)
        self.assertEqual(descriptor["source"], {"pto_commit": COMMIT, "pto_tree": TREE})
        self.assertEqual(descriptor["architecture"]["choice_policy"], CHOICE_POLICY)
        self.assertEqual(descriptor["model"]["numeric_maturity"], 0)
        self.assertIsNone(descriptor["interfaces"]["snapshot_schema"])

    def test_readiness_uses_exact_descriptor_hash(self) -> None:
        descriptor, inputs = self.descriptor()
        content = render_descriptor(descriptor)
        readiness = build_readiness(
            descriptor=descriptor,
            descriptor_bytes=content,
            descriptor_schema=inputs.descriptor_schema,
        )
        expected = hashlib.sha256(content).hexdigest()
        self.assertEqual(readiness["compatibility"], {
            "mode": COMPATIBILITY_MODE,
            "descriptor_sha256": expected,
        })
        self.assertEqual(readiness["status"], "experimental")
        self.assertEqual(readiness["publication"], "not-public")
        self.assertEqual(readiness["architecture_requirement"]["status"], "open")

    def test_schema_mismatch_is_rejected(self) -> None:
        descriptor, inputs = self.descriptor()
        descriptor["schema_version"] = 2
        with self.assertRaisesRegex(DescriptorError, "schema mismatch"):
            verify_descriptor(descriptor, inputs=inputs)

    def test_missing_and_extra_fields_are_rejected(self) -> None:
        descriptor, inputs = self.descriptor()
        missing = copy.deepcopy(descriptor)
        del missing["model"]
        with self.assertRaisesRegex(DescriptorError, "missing or extra"):
            verify_descriptor(missing, inputs=inputs)
        extra = copy.deepcopy(descriptor)
        extra["unexpected"] = True
        with self.assertRaisesRegex(DescriptorError, "missing or extra"):
            verify_descriptor(extra, inputs=inputs)

    def test_forbidden_host_or_runner_field_is_rejected(self) -> None:
        descriptor, inputs = self.descriptor()
        descriptor["architecture"]["runner"] = "forbidden"
        with self.assertRaisesRegex(DescriptorError, "forbidden"):
            verify_descriptor(descriptor, inputs=inputs)

    def test_hash_tampering_is_rejected(self) -> None:
        descriptor, inputs = self.descriptor()
        descriptor["model"]["pto_mir_sha256"] = "0" * 64
        with self.assertRaisesRegex(DescriptorError, "PTO MIR hash mismatch"):
            verify_descriptor(descriptor, inputs=inputs)

    def test_input_readiness_hash_mismatch_is_rejected(self) -> None:
        inputs = fixture_inputs()
        bad = copy.copy(inputs)
        object.__setattr__(
            bad,
            "mir_readiness",
            canonical({"mir": {"sha256": "0" * 64}}),
        )
        with self.assertRaisesRegex(DescriptorError, "MIR readiness hash mismatch"):
            build_descriptor(source_commit=COMMIT, source_tree=TREE, inputs=bad)

    def test_descriptor_schema_contract_mismatch_is_rejected(self) -> None:
        inputs = fixture_inputs()
        schema = json.loads(inputs.descriptor_schema)
        schema["x-pto-schema-version"] = 2
        bad = copy.copy(inputs)
        object.__setattr__(bad, "descriptor_schema", canonical(schema))
        with self.assertRaisesRegex(DescriptorError, "schema version mismatch"):
            build_descriptor(source_commit=COMMIT, source_tree=TREE, inputs=bad)

    def test_source_identity_pair_is_required(self) -> None:
        with self.assertRaisesRegex(DescriptorError, "supplied together"):
            resolve_source_identity(ROOT, COMMIT, None)

    def test_dirty_default_source_identity_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            subprocess.run(["git", "init", "--quiet"], cwd=root, check=True)
            subprocess.run(["git", "config", "user.email", "test@example.com"], cwd=root, check=True)
            subprocess.run(["git", "config", "user.name", "Test"], cwd=root, check=True)
            tracked = root / "tracked"
            tracked.write_text("clean\n", encoding="utf-8")
            subprocess.run(["git", "add", "tracked"], cwd=root, check=True)
            subprocess.run(["git", "commit", "--quiet", "-m", "fixture"], cwd=root, check=True)
            tracked.write_text("dirty\n", encoding="utf-8")
            with self.assertRaisesRegex(DescriptorError, "dirty or uncommitted"):
                resolve_source_identity(root, None, None)


if __name__ == "__main__":
    unittest.main()
