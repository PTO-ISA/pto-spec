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
    lower_executable_module,
    render_executable_module,
)
from pto_mir import ModelgenError, build_mir, render_mir  # noqa: E402
from runtime_gap import (  # noqa: E402
    ROOT_ENTRYPOINTS,
    build_runtime_gap,
    render_runtime_gap,
)


FIXTURES = ROOT / "tests/fixtures/functional-model-inventory"
MIR_SCHEMA = (ROOT / "spec/schemas/pto-mir-v1.schema.json").read_bytes()
EXECUTABLE_SCHEMA = (
    ROOT / "spec/schemas/pto-executable-mir-v1.schema.json"
).read_bytes()
CAPABILITY_PATH = MODELGEN / "runtime-capabilities-v1.json"
SCALAR_CATALOG = json.loads((ROOT / "spec/catalog/scalar-forms.json").read_bytes())
COMMAND_CATALOG = json.loads((ROOT / "spec/catalog/command-forms.json").read_bytes())


def fixture_image() -> tuple[dict[str, object], bytes, bytes]:
    typed = (FIXTURES / "runtime-gap-roots.serialized").read_bytes()
    ast_mli = (FIXTURES / "AST.mli").read_bytes()
    mir, _ = build_mir(typed, ast_mli, MIR_SCHEMA)
    mir_bytes = render_mir(mir)
    image = lower_executable_module(
        mir,
        mir_bytes=mir_bytes,
        schema_bytes=EXECUTABLE_SCHEMA,
        required_entrypoints=ROOT_ENTRYPOINTS,
    )
    image_bytes = render_executable_module(image)
    capability = json.loads(CAPABILITY_PATH.read_bytes())
    constructors = {row["name"] for row in image["tables"]["constructors"]}
    for category, names in capability["constructors"].items():
        capability["constructors"][category] = [
            name for name in names if name in constructors
        ]
    capability_bytes = (json.dumps(capability, sort_keys=True) + "\n").encode()
    return image, image_bytes, capability_bytes


def gap(
    image: dict[str, object], image_bytes: bytes, capability_bytes: bytes
) -> dict[str, object]:
    return build_runtime_gap(
        image,
        image_bytes=image_bytes,
        capability_bytes=capability_bytes,
        scalar_catalog=SCALAR_CATALOG,
        command_catalog=COMMAND_CATALOG,
    )


class FunctionalModelRuntimeGapTest(unittest.TestCase):
    def test_numeric_root_closure_is_deterministic(self) -> None:
        image, image_bytes, capabilities = fixture_image()
        first = gap(image, image_bytes, capabilities)
        second = gap(image, image_bytes, capabilities)
        self.assertEqual(render_runtime_gap(first), render_runtime_gap(second))
        roots = {row["name"]: row["function_id"] for row in first["roots"]}
        self.assertEqual(set(roots), set(ROOT_ENTRYPOINTS))
        self.assertEqual(
            roots["CompleteFunctionalModelHostRequest"],
            next(
                row["id"]
                for row in image["tables"]["functions"]
                if image["tables"]["strings"][row["name_symbol_id"]]["name"]
                == "CompleteFunctionalModelHostRequest"
            ),
        )

    def test_dangling_call_target_is_rejected(self) -> None:
        image, image_bytes, capabilities = fixture_image()
        image["tables"]["call_graph"][0]["callee_function_ids"] = [999]
        with self.assertRaisesRegex(ModelgenError, "unresolved target|dangling"):
            gap(image, image_bytes, capabilities)

    def test_dangling_body_node_is_rejected(self) -> None:
        image, image_bytes, capabilities = fixture_image()
        image["tables"]["functions"][0]["body_node"] = len(image["nodes"]) + 1
        with self.assertRaisesRegex(ModelgenError, "dangling executable node"):
            gap(image, image_bytes, capabilities)

    def test_unknown_declared_handler_is_rejected(self) -> None:
        image, image_bytes, capabilities = fixture_image()
        document = json.loads(capabilities)
        document["constructors"]["expressions"].append("E_Unknown")
        bad = (json.dumps(document, sort_keys=True) + "\n").encode()
        with self.assertRaisesRegex(ModelgenError, "unknown handlers"):
            gap(image, image_bytes, bad)


if __name__ == "__main__":
    unittest.main()
