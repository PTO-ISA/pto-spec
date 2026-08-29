from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
MODELGEN = ROOT / "tools/functional-model/modelgen"
if str(MODELGEN) not in sys.path:
    sys.path.insert(0, str(MODELGEN))

from pto_executable_mir import (  # noqa: E402
    ModelgenError,
    lower_executable_module,
    render_executable_module,
    verify_executable_module,
)
from pto_mir import build_mir, render_mir  # noqa: E402


FIXTURES = ROOT / "tests/fixtures/functional-model-inventory"
AST_MLI = (FIXTURES / "AST.mli").read_bytes()
MIR_SCHEMA = (ROOT / "spec/schemas/pto-mir-v1.schema.json").read_bytes()
EXECUTABLE_SCHEMA = (
    ROOT / "spec/schemas/pto-executable-mir-v1.schema.json"
).read_bytes()
ENTRYPOINT = ("DeterminePTOInstructionLength",)


def lower_fixture(name: str) -> dict[str, object]:
    serialized = (FIXTURES / name).read_bytes()
    mir, _ = build_mir(serialized, AST_MLI, MIR_SCHEMA)
    mir_bytes = render_mir(mir)
    return lower_executable_module(
        mir,
        mir_bytes=mir_bytes,
        schema_bytes=EXECUTABLE_SCHEMA,
        required_entrypoints=ENTRYPOINT,
    )


class ExecutableModelgenTest(unittest.TestCase):
    def test_determine_length_path_lowers_with_numeric_call_target(self) -> None:
        first = lower_fixture("determine-length.serialized")
        second = lower_fixture("determine-length.serialized")
        self.assertEqual(render_executable_module(first), render_executable_module(second))
        self.assertFalse(first["capabilities"]["execution_ready"])
        self.assertEqual(len(first["tables"]["entrypoints"]), 1)
        self.assertEqual(len(first["tables"]["call_sites"]), 1)
        call = first["tables"]["call_sites"][0]
        self.assertIsInstance(call["target_function_id"], int)
        self.assertNotIn("target_name", call)

    def test_unknown_binding_id_is_rejected(self) -> None:
        image = lower_fixture("determine-length.serialized")
        image["tables"]["externs"].append(
            {
                "id": 0,
                "kind": "primitive",
                "name_symbol_id": 0,
                "binding_id": len(image["tables"]["bindings"]) + 1,
                "declaration_function_id": 0,
                "implementation_function_id": None,
            }
        )
        image["tables"]["functions"][0]["extern_id"] = 0
        with self.assertRaisesRegex(ModelgenError, "unknown binding"):
            verify_executable_module(image, required_entrypoints=ENTRYPOINT)

    def test_dangling_reference_is_rejected(self) -> None:
        image = lower_fixture("determine-length.serialized")
        image["tables"]["functions"][0]["body_node"] = len(image["nodes"]) + 1
        with self.assertRaisesRegex(ModelgenError, "dangling executable node"):
            verify_executable_module(image, required_entrypoints=ENTRYPOINT)

    def test_duplicate_numeric_id_is_rejected(self) -> None:
        image = lower_fixture("determine-length.serialized")
        image["tables"]["functions"][1]["id"] = 0
        with self.assertRaisesRegex(ModelgenError, "function.*ID"):
            verify_executable_module(image, required_entrypoints=ENTRYPOINT)

    def test_schema_mismatch_is_rejected(self) -> None:
        image = lower_fixture("determine-length.serialized")
        image["schema_version"] = 2
        with self.assertRaisesRegex(ModelgenError, "schema mismatch"):
            verify_executable_module(image, required_entrypoints=ENTRYPOINT)

    def test_unresolved_impdef_implementation_is_rejected(self) -> None:
        with self.assertRaisesRegex(ModelgenError, "unresolved impdef implementation"):
            lower_fixture("unresolved-impdef.serialized")

    def test_unbounded_recursion_is_rejected(self) -> None:
        with self.assertRaisesRegex(ModelgenError, "unbounded recursion"):
            lower_fixture("unbounded-recursion.serialized")

    def test_verifier_rejects_missing_entrypoint(self) -> None:
        image = lower_fixture("determine-length.serialized")
        image["tables"]["entrypoints"].clear()
        with self.assertRaisesRegex(ModelgenError, "entrypoint closure"):
            verify_executable_module(image, required_entrypoints=ENTRYPOINT)

    def test_executable_schema_contract_mismatch_is_rejected(self) -> None:
        serialized = (FIXTURES / "determine-length.serialized").read_bytes()
        mir, _ = build_mir(serialized, AST_MLI, MIR_SCHEMA)
        schema = json.loads(EXECUTABLE_SCHEMA)
        schema["x-pto-schema-version"] = 2
        with self.assertRaisesRegex(ModelgenError, "schema version mismatch"):
            lower_executable_module(
                mir,
                mir_bytes=render_mir(mir),
                schema_bytes=json.dumps(schema).encode(),
                required_entrypoints=ENTRYPOINT,
            )


if __name__ == "__main__":
    unittest.main()
