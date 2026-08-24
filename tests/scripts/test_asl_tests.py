from __future__ import annotations

import hashlib
import io
import json
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from dataclasses import replace
from pathlib import Path
from subprocess import CompletedProcess, TimeoutExpired
from unittest.mock import patch

import scripts.asl_tests as asl_tests
from scripts.asl_tests import (
    AslTestPoint,
    execute_test_point,
    load_test_points,
    matrix,
    matrix_pages,
    matrix_main,
    run_main,
    validate_test_coverage,
)
from scripts.asl_units import AslUnit


KIND_TYPES = {
    "decode-positive": "decode",
    "decode-negative": "decode",
    "execution": "exec",
    "boundary": "bound",
    "fault": "fault",
    "atomicity": "atomic",
    "ordering": "order",
    "state-transition": "state",
    "static-invariant": "static",
}


def canonical_filename(
    *,
    group: str = "arch",
    kind: str = "state-transition",
    name: str = "registers",
    sequence: int = 1,
) -> str:
    return f"{group}-{KIND_TYPES[kind]}-{name}-{sequence:03d}.asl"


def unit(
    source: str = "asl/arch/state/registers.asl",
    *,
    unit_id: str = "PTO-ARCH-STATE-REGISTERS",
    surface: str = "arch",
    classification: tuple[str, ...] = ("state", "registers"),
    mnemonic: str | None = None,
) -> AslUnit:
    return AslUnit(
        unit_id=unit_id,
        surface=surface,
        classification=classification,
        depends_on=(),
        source_path=Path(source),
        mnemonic=mnemonic,
        line_count=10,
    )


def metadata(
    *,
    test_id: str = "PTO-AVS-ARCH-STATE-REGISTERS-001",
    source: str = "asl/arch/state/registers.asl",
    requirements: tuple[str, ...] = ("PTO-REQ-REGISTERS",),
    kind: str = "state-transition",
    summary: str = "register state remains independently testable",
    related_sources: tuple[str, ...] = (),
) -> str:
    payload = {
        "id": test_id,
        "source": source,
        "requirements": list(requirements),
        "kind": kind,
        "summary": summary,
        "pass_condition": "main returns zero",
        "related_sources": list(related_sources),
    }
    return json.dumps(payload, separators=(",", ":"))


def test_source(*, validation_entrypoint: str | None = None, **kwargs: object) -> str:
    validation_call = (
        f"    {validation_entrypoint}();\n" if validation_entrypoint is not None else ""
    )
    return (
        f"// PTO-TEST: {metadata(**kwargs)}\n"
        "func main() => integer\n"
        "begin\n"
        f"{validation_call}"
        "    return 0;\n"
        "end;\n"
    )


class AslTestsTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self.path = (
            self.root
            / "tests/asl/arch/state/registers/arch-state-registers-001.asl"
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
        self.assertEqual(
            point.display_name,
            "ARCH state/registers | state-transition | "
            "register state remains independently testable",
        )
        self.assertEqual(point.sha256, hashlib.sha256(body.encode()).hexdigest())
        self.assertEqual(point.path, self.path.relative_to(self.root))
        self.assertIsNone(point.validation_entrypoint)

    def test_binds_one_explicit_generated_validation_entrypoint(self) -> None:
        self.write(test_source(validation_entrypoint="ValidateKnown"))

        point = load_test_points(
            self.root,
            (unit(),),
            validation_resources={"ValidateKnown": "b" * 64},
        )[0]

        self.assertEqual(point.validation_entrypoint, "ValidateKnown")
        self.assertEqual(point.validation_sha256, "b" * 64)

    def test_rejects_unknown_or_multiple_generated_validation_entrypoints(
        self,
    ) -> None:
        self.write(test_source(validation_entrypoint="ValidateUnknown"))
        with self.assertRaisesRegex(
            ValueError, "unknown generated validation entrypoint ValidateUnknown"
        ):
            load_test_points(self.root, (unit(),), validation_resources={})

        self.write(
            test_source(validation_entrypoint="ValidateFirst").replace(
                "    return 0;", "    ValidateSecond();\n    return 0;"
            )
        )
        with self.assertRaisesRegex(
            ValueError, "multiple generated validation entrypoints"
        ):
            load_test_points(
                self.root,
                (unit(),),
                validation_resources={
                    "ValidateFirst": "a" * 64,
                    "ValidateSecond": "b" * 64,
                },
            )

    def test_instruction_test_display_name_is_derived_from_mnemonic(self) -> None:
        source = "asl/tile/tepl/TADD.asl"
        test_id = "PTO-AVS-TILE-TEPL-TADD-EXECUTION-001"
        path = self.root / "tests/asl/tile/tepl/TADD/tile-exec-tadd-register-state-001.asl"
        self.write(
            test_source(
                test_id=test_id,
                source=source,
                requirements=(),
                kind="execution",
            ),
            path=path,
        )
        owner = unit(
            source,
            unit_id="PTO-TILE-TEPL-TADD",
            surface="tile",
            classification=("tepl",),
            mnemonic="TADD",
        )

        point = load_test_points(self.root, (owner,))[0]

        self.assertEqual(
            point.display_name,
            "TADD | execution | register state remains independently testable",
        )

    def test_rejects_instruction_filename_without_mnemonic(self) -> None:
        source = "asl/tile/tepl/TADD.asl"
        path = self.root / "tests/asl/tile/tepl/TADD/tile-static-contract-001.asl"
        self.write(
            test_source(
                test_id="PTO-AVS-TILE-TEPL-TADD-STATIC-001",
                source=source,
                requirements=(),
                kind="static-invariant",
            ),
            path=path,
        )
        owner = unit(
            source,
            unit_id="PTO-TILE-TEPL-TADD",
            surface="tile",
            classification=("tepl",),
            mnemonic="TADD",
        )

        with self.assertRaisesRegex(ValueError, "must include mnemonic tadd"):
            load_test_points(self.root, (owner,))

    def test_rejects_duplicate_ids(self) -> None:
        self.write()
        duplicate = (
            self.root / "tests/asl/arch/other/arch-state-registers-001.asl"
        )
        self.write(test_source(), path=duplicate)

        with self.assertRaisesRegex(ValueError, "duplicate ASL test ID"):
            load_test_points(self.root, (unit(),))

    def test_rejects_path_mismatch(self) -> None:
        wrong = (
            self.root
            / "tests/asl/arch/state/wrong/arch-state-registers-001.asl"
        )
        self.write(path=wrong)

        with self.assertRaisesRegex(ValueError, "test path does not mirror source"):
            load_test_points(self.root, (unit(),))

    def test_accepts_structured_filename_with_independent_id(self) -> None:
        structured = (
            self.root
            / "tests/asl/arch/state/registers/arch-state-registers-001.asl"
        )
        self.write(path=structured)

        point = load_test_points(self.root, (unit(),))[0]

        self.assertEqual(point.test_id, "PTO-AVS-ARCH-STATE-REGISTERS-001")
        self.assertEqual(point.source, Path("asl/arch/state/registers.asl"))
        self.assertEqual(
            point.path,
            Path("tests/asl/arch/state/registers/arch-state-registers-001.asl"),
        )

    def test_rejects_historical_id_filename(self) -> None:
        historical = self.path.with_name("PTO-AVS-ARCH-STATE-REGISTERS-001.asl")
        self.write(path=historical)

        with self.assertRaisesRegex(ValueError, "canonical test filename"):
            load_test_points(self.root, (unit(),))

    def test_rejects_filename_with_wrong_group_or_kind_type(self) -> None:
        wrong_group = self.path.with_name("block-state-registers-001.asl")
        self.write(path=wrong_group)
        with self.assertRaisesRegex(ValueError, "group must be arch"):
            load_test_points(self.root, (unit(),))

        wrong_group.unlink()
        wrong_type = self.path.with_name("arch-exec-registers-001.asl")
        self.write(path=wrong_type)
        with self.assertRaisesRegex(ValueError, "type must be state"):
            load_test_points(self.root, (unit(),))

    def test_rejects_redundant_or_overlong_purpose_name(self) -> None:
        for token in ("test", "execution", "validate", "validation"):
            path = self.path.with_name(f"arch-state-{token}-001.asl")
            self.write(path=path)
            with self.assertRaisesRegex(ValueError, "forbidden purpose token"):
                load_test_points(self.root, (unit(),))
            path.unlink()

        overlong = self.path.with_name(
            "arch-state-" + "purpose-" * 8 + "001.asl"
        )
        self.write(path=overlong)
        with self.assertRaisesRegex(ValueError, "at most 68 characters"):
            load_test_points(self.root, (unit(),))

    def test_rejects_overlong_independent_test_point(self) -> None:
        body = test_source().replace(
            "func main() => integer\n",
            "// focused setup remains below the independent-test size limit\n" * 300
            + "func main() => integer\n",
        )
        self.write(body)

        with self.assertRaisesRegex(ValueError, "at most 300 lines"):
            load_test_points(self.root, (unit(),))

    def test_rejects_malformed_sequence(self) -> None:
        malformed = self.path.with_name("arch-state-registers-1.asl")
        self.write(path=malformed)

        with self.assertRaisesRegex(ValueError, "canonical test filename"):
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

    def test_rejects_migration_placeholder_summary(self) -> None:
        self.write(
            test_source(
                summary="migrated independent behavior point for TestRegisters"
            )
        )

        with self.assertRaisesRegex(ValueError, "summary must describe its purpose"):
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
        second = self.path.with_name("arch-state-registers-002.asl")
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

    def test_rejects_instruction_requirement_with_only_decode_or_static_coverage(
        self,
    ) -> None:
        requirement = "PTO-INST-ARCH-REGISTERS"
        decode = AslTestPoint(
            test_id="PTO-AVS-ARCH-STATE-REGISTERS-001",
            display_name="register decode",
            source=Path("asl/arch/state/registers.asl"),
            requirements=(requirement,),
            kind="decode-positive",
            summary="register decode is canonical",
            pass_condition="main returns zero",
            related_sources=(),
            path=Path("tests/asl/arch/state/registers/arch-decode-registers-001.asl"),
            sha256="0" * 64,
            validation_entrypoint=None,
            validation_sha256="0" * 64,
        )
        static = AslTestPoint(
            test_id="PTO-AVS-ARCH-STATE-REGISTERS-002",
            display_name="register contract",
            source=Path("asl/arch/state/registers.asl"),
            requirements=(requirement,),
            kind="static-invariant",
            summary="register contract is present",
            pass_condition="main returns zero",
            related_sources=(),
            path=Path("tests/asl/arch/state/registers/arch-static-registers-002.asl"),
            sha256="1" * 64,
            validation_entrypoint=None,
            validation_sha256="0" * 64,
        )

        self.assertIn(
            "executable instruction requirement has no semantic ASL test owner: "
            + requirement,
            validate_test_coverage(
                (decode, static),
                (unit(),),
                {requirement: True},
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
            {
                "id",
                "display_name",
                "path",
                "source",
                "requirements",
                "kind",
                "sha256",
                "validation_entrypoint",
                "validation_sha256",
            },
        )

    def test_matrix_page_is_compact_sorted_and_bound_to_exact_commit(self) -> None:
        self.write()
        first = load_test_points(self.root, (unit(),))[0]
        second_id = "PTO-AVS-ARCH-STATE-REGISTERS-002"
        second_path = self.path.with_name("arch-state-registers-002.asl")
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
        self.assertEqual(
            output.getvalue().strip(),
            json.dumps(payload, separators=(",", ":"), sort_keys=True),
        )

    def test_focused_matrix_skips_global_repository_discovery(self) -> None:
        self.write()
        point = load_test_points(self.root, (unit(),))[0]
        commit = "9" * 40
        completed = CompletedProcess(
            ["git", "rev-parse", "HEAD"], 0, stdout=commit + "\n", stderr=""
        )
        output = io.StringIO()

        with (
            patch(
                "scripts.asl_tests.load_focused_test_points",
                return_value=(point,),
            ) as focused,
            patch(
                "scripts.asl_tests._repository",
                side_effect=AssertionError("global discovery must not run"),
            ),
            patch("scripts.asl_tests.subprocess.run", return_value=completed),
            redirect_stdout(output),
        ):
            result = matrix_main(
                ["--root", str(self.root), "--id", point.test_id]
            )

        payload = json.loads(output.getvalue())
        self.assertEqual(result, 0)
        focused.assert_called_once_with(self.root.resolve(), [point.test_id])
        self.assertEqual(payload["commit"], commit)
        self.assertEqual(payload["test_count"], 1)
        self.assertEqual(payload["include"][0]["id"], point.test_id)

    def test_focused_matrix_defaults_to_one_complete_page(self) -> None:
        self.write()
        point = load_test_points(self.root, (unit(),))[0]
        points = tuple(
            replace(
                point,
                test_id=f"PTO-AVS-ARCH-STATE-REGISTERS-{index:03d}",
            )
            for index in range(1, 4)
        )
        commit = "8" * 40
        completed = CompletedProcess(
            ["git", "rev-parse", "HEAD"], 0, stdout=commit + "\n", stderr=""
        )
        output = io.StringIO()
        selected_ids = [item.test_id for item in points]

        with (
            patch(
                "scripts.asl_tests.load_focused_test_points",
                return_value=points,
            ),
            patch("scripts.asl_tests.subprocess.run", return_value=completed),
            redirect_stdout(output),
        ):
            arguments = ["--root", str(self.root)]
            for test_id in selected_ids:
                arguments.extend(("--id", test_id))
            result = matrix_main(arguments)

        payload = json.loads(output.getvalue())
        self.assertEqual(result, 0)
        self.assertEqual(payload["page_count"], 1)
        self.assertEqual(payload["test_count"], 3)
        self.assertEqual(
            [entry["id"] for entry in payload["include"]], selected_ids
        )

    def test_single_id_runner_uses_focused_discovery(self) -> None:
        self.write()
        point = load_test_points(self.root, (unit(),))[0]

        with (
            patch(
                "scripts.asl_tests.load_focused_test_points",
                return_value=(point,),
            ) as focused,
            patch(
                "scripts.asl_tests.load_validation_resources",
                side_effect=AssertionError("global validation index must not load"),
            ),
            patch(
                "scripts.asl_tests.execute_test_point",
                return_value=0,
            ) as execute,
        ):
            result = run_main(
                [
                    "--root",
                    str(self.root),
                    "--id",
                    point.test_id,
                    "--timeout-seconds",
                    "7",
                ]
            )

        self.assertEqual(result, 0)
        focused.assert_called_once_with(self.root.resolve(), [point.test_id])
        execute.assert_called_once_with(
            self.root.resolve(),
            point,
            timeout_seconds=7,
        )

    def test_selected_loader_ignores_unselected_invalid_test_body(self) -> None:
        self.write()
        invalid = self.path.with_name("arch-state-registers-002.asl")
        invalid.write_text(
            '// PTO-TEST: {"id":"PTO-AVS-ARCH-STATE-REGISTERS-002"}\n'
            "invalid body\n",
            encoding="utf-8",
        )

        points = load_test_points(
            self.root,
            (unit(),),
            selected_ids=frozenset({"PTO-AVS-ARCH-STATE-REGISTERS-001"}),
            validation_resources={},
        )

        self.assertEqual(
            [point.test_id for point in points],
            ["PTO-AVS-ARCH-STATE-REGISTERS-001"],
        )

    def test_selected_loader_lazily_hashes_only_required_validation(self) -> None:
        self.write(test_source(validation_entrypoint="ValidateKnown"))
        requested: list[str] = []

        points = load_test_points(
            self.root,
            (unit(),),
            selected_ids=frozenset({"PTO-AVS-ARCH-STATE-REGISTERS-001"}),
            validation_resources={},
            lazy_validation_resource=lambda name: (
                requested.append(name) or "c" * 64
            ),
        )

        self.assertEqual(requested, ["ValidateKnown"])
        self.assertEqual(points[0].validation_entrypoint, "ValidateKnown")
        self.assertEqual(points[0].validation_sha256, "c" * 64)

    def test_focused_ids_file_ignores_comments_and_rejects_duplicates(self) -> None:
        self.write()
        point = load_test_points(self.root, (unit(),))[0]
        ids_file = self.root / "ids.txt"
        ids_file.write_text(
            f"# focused rerun\n{point.test_id}\n{point.test_id}\n",
            encoding="utf-8",
        )
        output = io.StringIO()
        errors = io.StringIO()

        with (
            patch(
                "scripts.asl_tests.load_focused_test_points",
                side_effect=ValueError(
                    "focused ASL test selection contains duplicate IDs"
                ),
            ) as focused,
            redirect_stdout(output),
            redirect_stderr(errors),
        ):
            result = matrix_main(
                ["--root", str(self.root), "--ids-file", str(ids_file)]
            )

        self.assertEqual(result, 1)
        self.assertIn("duplicate IDs", errors.getvalue())
        focused.assert_called_once_with(
            self.root.resolve(), [point.test_id, point.test_id]
        )

    def test_all_pages_export_discovers_once_and_writes_complete_round_robin_pages(
        self,
    ) -> None:
        export_matrix_pages = getattr(asl_tests, "export_matrix_pages", None)
        self.assertIsNotNone(export_matrix_pages)

        for sequence in range(1, 4):
            test_id = f"PTO-AVS-ARCH-STATE-REGISTERS-{sequence:03d}"
            self.write(
                test_source(test_id=test_id),
                path=self.path.with_name(f"arch-state-registers-{sequence:03d}.asl"),
            )
        points = load_test_points(self.root, (unit(),))
        commit = "2" * 40
        completed = CompletedProcess(
            ["git", "rev-parse", "HEAD"], 0, stdout=commit + "\n", stderr=""
        )
        output_dir = self.root / "build/pages"

        with (
            patch(
                "scripts.asl_tests._repository",
                return_value=(
                    (unit(),),
                    tuple(reversed(points)),
                    {"PTO-REQ-REGISTERS": True},
                ),
            ) as discover,
            patch("scripts.asl_tests.subprocess.run", return_value=completed),
        ):
            index = export_matrix_pages(self.root, output_dir, page_size=2)

        self.assertEqual(discover.call_count, 1)
        self.assertEqual(index["commit"], commit)
        self.assertEqual(index["pages"], [0, 1])
        self.assertEqual(index["page_count"], 2)
        self.assertEqual(index["test_count"], 3)
        pages = [
            json.loads((output_dir / f"page-{page}.json").read_text())
            for page in index["pages"]
        ]
        self.assertEqual(
            [[entry["id"] for entry in page["include"]] for page in pages],
            [
                [
                    "PTO-AVS-ARCH-STATE-REGISTERS-001",
                    "PTO-AVS-ARCH-STATE-REGISTERS-003",
                ],
                ["PTO-AVS-ARCH-STATE-REGISTERS-002"],
            ],
        )
        self.assertEqual({page["commit"] for page in pages}, {commit})
        self.assertEqual({page["page_count"] for page in pages}, {2})
        self.assertEqual({page["test_count"] for page in pages}, {3})

    def test_page_count_caps_hosted_jobs_without_dropping_entries(self) -> None:
        entries = [{"id": f"test-{index}"} for index in range(11)]

        pages = matrix_pages(entries, "3" * 40, page_count=4)

        self.assertEqual(len(pages), 4)
        self.assertEqual(
            sorted(entry["id"] for page in pages for entry in page["include"]),
            sorted(entry["id"] for entry in entries),
        )
        self.assertTrue(all(page["page_count"] == 4 for page in pages))

    def test_page_size_and_count_are_mutually_exclusive(self) -> None:
        with self.assertRaisesRegex(ValueError, "mutually exclusive"):
            matrix_pages([{"id": "one"}], "4" * 40, 1, page_count=1)

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
            path = self.path.with_name(
                canonical_filename(kind=kind, sequence=index)
            )
            self.write(test_source(test_id=test_id, kind=kind), path=path)

        points = load_test_points(self.root, (unit(),))

        self.assertEqual({point.kind for point in points}, set(kinds))

    def test_point_dataclass_exposes_execution_metadata(self) -> None:
        fields = set(AslTestPoint.__dataclass_fields__)

        self.assertEqual(
            fields,
            {
                "test_id",
                "display_name",
                "source",
                "requirements",
                "kind",
                "summary",
                "pass_condition",
                "related_sources",
                "path",
                "sha256",
                "validation_entrypoint",
                "validation_sha256",
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
        self.assertEqual(payload["display_name"], point.display_name)
        self.assertEqual(payload["source"], point.source.as_posix())
        self.assertEqual(payload["kind"], point.kind)
        self.assertEqual(payload["log_excerpt"], "")
        self.assertTrue((result_path.parent / "aslref.log").is_file())
        self.assertTrue((result_path.parent / "validation.asl").is_file())

    def test_individual_execution_loads_only_the_bound_validation_shard(
        self,
    ) -> None:
        validation_text = (
            "// Generated validation shard. Do not edit.\n"
            "// Entrypoint: ValidateKnown\n\n"
            "func ValidateKnown()\nbegin\nend;\n"
        )
        self.write(test_source(validation_entrypoint="ValidateKnown"))
        point = load_test_points(
            self.root,
            (unit(),),
            validation_resources={
                "ValidateKnown": hashlib.sha256(validation_text.encode()).hexdigest()
            },
        )[0]
        calls: list[list[str]] = []

        def fake_run(command: list[str], **_: object) -> CompletedProcess[str]:
            calls.append(command)
            stdout = ""
            if "generate-asl-decoders" in command[1]:
                stdout = (
                    validation_text
                    if "validation-shard" in command
                    else "// generated decoder\n"
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
        validation_commands = [call for call in calls if "validation-shard" in call]
        self.assertEqual(len(validation_commands), 1)
        self.assertEqual(validation_commands[0][-1], "ValidateKnown")
        assembled = calls[3]
        self.assertEqual(
            assembled[-2],
            str(
                self.root / "build/asl-test-results" / point.test_id / "validation.asl"
            ),
        )
        self.assertEqual(
            (
                self.root / "build/asl-test-results" / point.test_id / "validation.asl"
            ).read_text(encoding="utf-8"),
            validation_text,
        )

    def test_prepared_execution_reuses_model_and_validation_without_regeneration(
        self,
    ) -> None:
        prepared_type = getattr(asl_tests, "PreparedAslInputs", None)
        self.assertIsNotNone(prepared_type)
        self.write()
        point = load_test_points(self.root, (unit(),))[0]
        shared = self.root / "build/asl-page-inputs"
        shared.mkdir(parents=True)
        model_path = shared / "pto-spec.asl"
        model_path.write_text("// prepared model\n", encoding="utf-8")
        validation_path = shared / "validation-none.asl"
        validation_path.write_text(
            asl_tests.EMPTY_VALIDATION_SHARD,
            encoding="utf-8",
        )
        prepared = prepared_type(
            model_path=model_path,
            validation_paths={None: validation_path},
        )
        calls: list[list[str]] = []

        def fake_run(command: list[str], **_: object) -> CompletedProcess[str]:
            calls.append(command)
            return CompletedProcess(command, 0, stdout="", stderr="")

        result = execute_test_point(
            self.root,
            point,
            timeout_seconds=7,
            run=fake_run,
            prepared=prepared,
        )

        self.assertEqual(result, 0)
        self.assertEqual(len(calls), 2)
        self.assertEqual(calls[0][0], str(self.root / "scripts/assemble-asl"))
        self.assertEqual(calls[0][-3], str(model_path))
        self.assertNotIn("generate-asl-decoders", " ".join(calls[0]))
        self.assertEqual(
            (
                self.root / "build/asl-test-results" / point.test_id / "validation.asl"
            ).read_text(encoding="utf-8"),
            asl_tests.EMPTY_VALIDATION_SHARD,
        )

    def test_failed_execution_records_bounded_log_excerpt(self) -> None:
        self.write()
        point = load_test_points(self.root, (unit(),))[0]
        invocation = 0

        def fake_run(command: list[str], **_: object) -> CompletedProcess[str]:
            nonlocal invocation
            invocation += 1
            stdout = "// generated decoder\n" if invocation == 1 else ""
            if invocation == 4:
                return CompletedProcess(
                    command, 1, stdout="x" * 9000 + "failure-tail", stderr=""
                )
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
        self.assertEqual(payload["status"], "failed")
        self.assertLessEqual(len(payload["log_excerpt"]), 8192)
        self.assertTrue(payload["log_excerpt"].endswith("failure-tail"))

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
