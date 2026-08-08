from __future__ import annotations

import hashlib
import io
import json
import tempfile
import unittest
from contextlib import redirect_stdout
from pathlib import Path
from subprocess import CompletedProcess, TimeoutExpired
from unittest.mock import patch

from scripts.asl_tests import (
    AslTestPoint,
    execute_test_point,
    load_test_points,
    matrix,
    matrix_main,
    validate_test_coverage,
)
from scripts.asl_units import AslUnit


def unit(source: str = "asl/arch/state/registers.asl") -> AslUnit:
    return AslUnit(
        unit_id="PTO-ARCH-STATE-REGISTERS",
        surface="arch",
        classification=("state", "registers"),
        depends_on=(),
        source_path=Path(source),
        mnemonic=None,
        line_count=10,
    )


def metadata(
    *,
    test_id: str = "PTO-AVS-ARCH-STATE-REGISTERS-001",
    source: str = "asl/arch/state/registers.asl",
    requirements: tuple[str, ...] = ("PTO-REQ-REGISTERS",),
    kind: str = "state-transition",
    related_sources: tuple[str, ...] = (),
) -> str:
    payload = {
        "id": test_id,
        "source": source,
        "requirements": list(requirements),
        "kind": kind,
        "summary": "register state remains independently testable",
        "pass_condition": "main returns zero",
        "related_sources": list(related_sources),
    }
    return json.dumps(payload, separators=(",", ":"))


def test_source(**kwargs: object) -> str:
    return (
        f"// PTO-TEST: {metadata(**kwargs)}\n"
        "func main() => integer\n"
        "begin\n"
        "    return 0;\n"
        "end;\n"
    )


class AslTestsTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self.path = (
            self.root
            / "tests/asl/arch/state/registers/PTO-AVS-ARCH-STATE-REGISTERS-001.asl"
        )
        self.path.parent.mkdir(parents=True)

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def write(self, text: str | None = None, *, path: Path | None = None) -> Path:
        target = path or self.path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text or test_source(), encoding="utf-8")
        return target

    def test_loads_one_strictly_mirrored_test_point(self) -> None:
        body = test_source()
        self.write(body)

        point = load_test_points(self.root, (unit(),))[0]

        self.assertEqual(point.test_id, "PTO-AVS-ARCH-STATE-REGISTERS-001")
        self.assertEqual(point.source, Path("asl/arch/state/registers.asl"))
        self.assertEqual(point.kind, "state-transition")
        self.assertEqual(point.sha256, hashlib.sha256(body.encode()).hexdigest())
        self.assertEqual(point.path, self.path.relative_to(self.root))

    def test_rejects_duplicate_ids(self) -> None:
        self.write()
        duplicate = (
            self.root / "tests/asl/arch/other/PTO-AVS-ARCH-STATE-REGISTERS-001.asl"
        )
        self.write(test_source(), path=duplicate)

        with self.assertRaisesRegex(ValueError, "duplicate ASL test ID"):
            load_test_points(self.root, (unit(),))

    def test_rejects_path_mismatch(self) -> None:
        wrong = (
            self.root
            / "tests/asl/arch/state/wrong/PTO-AVS-ARCH-STATE-REGISTERS-001.asl"
        )
        self.write(path=wrong)

        with self.assertRaisesRegex(ValueError, "test path does not mirror source"):
            load_test_points(self.root, (unit(),))

    def test_rejects_absent_source_and_related_source(self) -> None:
        self.write(test_source(source="asl/arch/state/missing.asl"))

        with self.assertRaisesRegex(ValueError, "unknown ASL source"):
            load_test_points(self.root, (unit(),))

        self.write(test_source(related_sources=("asl/arch/state/missing.asl",)))
        with self.assertRaisesRegex(ValueError, "unknown related ASL source"):
            load_test_points(self.root, (unit(),))

    def test_rejects_unsupported_kind(self) -> None:
        self.write(test_source(kind="smoke"))

        with self.assertRaisesRegex(ValueError, "unsupported ASL test kind"):
            load_test_points(self.root, (unit(),))

    def test_rejects_zero_or_multiple_integer_main_declarations(self) -> None:
        self.write(
            f"// PTO-TEST: {metadata()}\n"
            "func helper() => integer\n"
            "begin\n"
            "    return 0;\n"
            "end;\n"
        )
        with self.assertRaisesRegex(ValueError, "exactly one integer main"):
            load_test_points(self.root, (unit(),))

        self.write(test_source() + test_source().split("\n", 1)[1])
        with self.assertRaisesRegex(ValueError, "exactly one integer main"):
            load_test_points(self.root, (unit(),))

    def test_rejects_cross_test_function_dependency(self) -> None:
        self.write(
            f"// PTO-TEST: {metadata()}\n"
            "func main() => integer\n"
            "begin\n"
            "    return ForeignHelper();\n"
            "end;\n"
        )
        second_id = "PTO-AVS-ARCH-STATE-REGISTERS-002"
        second = self.path.with_name(f"{second_id}.asl")
        self.write(
            f"// PTO-TEST: {metadata(test_id=second_id)}\n"
            "func ForeignHelper() => integer\n"
            "begin\n"
            "    return 0;\n"
            "end;\n"
            "func main() => integer\n"
            "begin\n"
            "    return ForeignHelper();\n"
            "end;\n",
            path=second,
        )

        with self.assertRaisesRegex(
            ValueError, "cross-test function dependency ForeignHelper"
        ):
            load_test_points(self.root, (unit(),))

    def test_rejects_missing_or_unknown_requirement_coverage(self) -> None:
        self.write()
        point = load_test_points(self.root, (unit(),))[0]

        self.assertIn(
            "unknown NDF requirement PTO-REQ-REGISTERS",
            validate_test_coverage((point,), (unit(),), {}),
        )
        self.assertIn(
            "executable NDF requirement has no ASL test owner: PTO-REQ-OTHER",
            validate_test_coverage(
                (point,),
                (unit(),),
                {"PTO-REQ-REGISTERS": True, "PTO-REQ-OTHER": True},
            ),
        )

    def test_rejects_missing_unit_coverage(self) -> None:
        errors = validate_test_coverage((), (unit(),), {})

        self.assertEqual(
            errors,
            ["ASL unit has no mirrored test owner: asl/arch/state/registers.asl"],
        )

    def test_hashes_and_matrix_are_deterministic_with_exact_fields(self) -> None:
        self.write()
        point = load_test_points(self.root, (unit(),))[0]

        first = matrix((point,))
        second = matrix((point,))

        self.assertEqual(first, second)
        self.assertEqual(
            set(first[0].keys()),
            {"id", "path", "source", "requirements", "kind", "sha256"},
        )

    def test_matrix_page_is_compact_sorted_and_bound_to_exact_commit(self) -> None:
        self.write()
        first = load_test_points(self.root, (unit(),))[0]
        second_id = "PTO-AVS-ARCH-STATE-REGISTERS-002"
        second_path = self.path.with_name(f"{second_id}.asl")
        self.write(test_source(test_id=second_id), path=second_path)
        points = load_test_points(self.root, (unit(),))
        commit = "1" * 40
        output = io.StringIO()
        completed = CompletedProcess(
            ["git", "rev-parse", "HEAD"], 0, stdout=commit + "\n", stderr=""
        )

        with (
            patch(
                "scripts.asl_tests._repository",
                return_value=(
                    (unit(),),
                    (points[1], first),
                    {"PTO-REQ-REGISTERS": True},
                ),
            ),
            patch("scripts.asl_tests.subprocess.run", return_value=completed),
            redirect_stdout(output),
        ):
            result = matrix_main(
                ["--root", str(self.root), "--page-size", "1", "--page", "0"]
            )

        payload = json.loads(output.getvalue())
        self.assertEqual(result, 0)
        self.assertEqual(payload["commit"], commit)
        self.assertEqual(payload["page_count"], 2)
        self.assertEqual(payload["test_count"], 2)
        self.assertEqual(payload["include"][0]["id"], first.test_id)
        self.assertNotIn(" ", output.getvalue().strip())

    def test_all_supported_kinds_are_accepted(self) -> None:
        kinds = (
            "decode-positive",
            "decode-negative",
            "execution",
            "boundary",
            "fault",
            "atomicity",
            "ordering",
            "state-transition",
            "static-invariant",
        )
        for index, kind in enumerate(kinds, start=1):
            test_id = f"PTO-AVS-ARCH-STATE-REGISTERS-{index:03d}"
            path = self.path.with_name(f"{test_id}.asl")
            self.write(test_source(test_id=test_id, kind=kind), path=path)

        points = load_test_points(self.root, (unit(),))

        self.assertEqual({point.kind for point in points}, set(kinds))

    def test_point_dataclass_exposes_execution_metadata(self) -> None:
        fields = set(AslTestPoint.__dataclass_fields__)

        self.assertEqual(
            fields,
            {
                "test_id",
                "source",
                "requirements",
                "kind",
                "summary",
                "pass_condition",
                "related_sources",
                "path",
                "sha256",
            },
        )

    def test_individual_execution_assembles_exactly_one_test_and_records_result(
        self,
    ) -> None:
        self.write()
        point = load_test_points(self.root, (unit(),))[0]
        calls: list[list[str]] = []

        def fake_run(command: list[str], **_: object) -> CompletedProcess[str]:
            calls.append(command)
            stdout = (
                "// generated decoder\n"
                if "generate-asl-decoders" in command[1]
                else ""
            )
            return CompletedProcess(command, 0, stdout=stdout, stderr="")

        with patch(
            "scripts.asl_tests.generate_source_order",
            return_value=("asl/arch/state/registers.asl",),
        ):
            result = execute_test_point(
                self.root, point, timeout_seconds=7, run=fake_run
            )

        self.assertEqual(result, 0)
        assembled = calls[2]
        self.assertEqual(assembled[-1], str(self.root / point.path))
        self.assertEqual(sum(str(self.root / point.path) in call for call in calls), 1)
        result_path = (
            self.root / "build/asl-test-results" / point.test_id / "result.json"
        )
        payload = json.loads(result_path.read_text(encoding="utf-8"))
        self.assertEqual(payload["status"], "passed")
        self.assertEqual(payload["returncode"], 0)
        self.assertTrue((result_path.parent / "aslref.log").is_file())

    def test_individual_execution_records_timeout_fail_closed(self) -> None:
        self.write()
        point = load_test_points(self.root, (unit(),))[0]
        invocation = 0

        def fake_run(command: list[str], **_: object) -> CompletedProcess[str]:
            nonlocal invocation
            invocation += 1
            if invocation == 4:
                raise TimeoutExpired(command, 7)
            stdout = "// generated decoder\n" if invocation == 1 else ""
            return CompletedProcess(command, 0, stdout=stdout, stderr="")

        with patch(
            "scripts.asl_tests.generate_source_order",
            return_value=("asl/arch/state/registers.asl",),
        ):
            result = execute_test_point(
                self.root, point, timeout_seconds=7, run=fake_run
            )

        self.assertEqual(result, 1)
        result_path = (
            self.root / "build/asl-test-results" / point.test_id / "result.json"
        )
        payload = json.loads(result_path.read_text(encoding="utf-8"))
        self.assertEqual(payload["status"], "timeout")
        self.assertIsNone(payload["returncode"])


if __name__ == "__main__":
    unittest.main()
