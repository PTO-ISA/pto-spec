import json
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

from scripts.adr_records import load_adrs, parse_adr, validate_adr_graph


ROOT = Path(__file__).resolve().parents[2]
CHECKER = ROOT / "scripts/check-adrs"
ADR_INDEX = ROOT / "scripts/generate-adr-index"
EXPECTED_PRDS = {f"PRD-{value:03d}" for value in range(1, 184)}


class AdrRecordTest(unittest.TestCase):
    def write_adr(self, root: Path, name: str, metadata: str, body: str) -> Path:
        root.mkdir(parents=True, exist_ok=True)
        path = root / name
        path.write_text(f"---\n{metadata}\n---\n{body}\n", encoding="utf-8")
        return path

    def metadata(self, **updates: object) -> dict[str, object]:
        metadata: dict[str, object] = {
            "id": "ADR-0075",
            "title": "Example",
            "status": "draft",
            "authors": ["architect"],
            "approvers": [],
            "created": "2026-08-21",
            "accepted": None,
            "rejected": None,
            "superseded": None,
            "baseline": "4be7d809e79af23401073edaf80d8cca82ccef95",
            "target_releases": ["unassigned"],
            "affected_ndf": [],
            "affected_units": [],
            "resolves": [],
            "supersedes": [],
            "superseded_by": [],
            "implementation_issue": None,
            "release_impact": "not-required",
            "legacy_ids": [],
        }
        metadata.update(updates)
        return metadata

    def write_metadata(
        self, root: Path, name: str = "0075-example.md", **updates: object
    ) -> Path:
        return self.write_adr(
            root,
            name,
            json.dumps(self.metadata(**updates)),
            "# ADR 0075: Example",
        )

    def parsed_record(
        self, root: Path, number: int, **updates: object
    ):
        adr_id = f"ADR-{number:04d}"
        path = self.write_metadata(
            root,
            name=f"{number:04d}-example.md",
            id=adr_id,
            **updates,
        )
        return parse_adr(path)

    def run_checker(self, root: Path) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [str(CHECKER), "--root", str(root)],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

    def initialize_repository(self, root: Path, *tracked: Path) -> str:
        subprocess.run(["git", "init", "-q", str(root)], check=True)
        subprocess.run(
            ["git", "config", "user.name", "ADR test"], cwd=root, check=True
        )
        subprocess.run(
            ["git", "config", "user.email", "adr@example.com"],
            cwd=root,
            check=True,
        )
        marker = root / "README.md"
        marker.write_text("baseline\n", encoding="utf-8")
        subprocess.run(
            ["git", "add", "README.md", *[str(path.relative_to(root)) for path in tracked]],
            cwd=root,
            check=True,
        )
        subprocess.run(
            ["git", "commit", "-q", "-m", "baseline"], cwd=root, check=True
        )
        return subprocess.check_output(
            ["git", "rev-parse", "HEAD"], cwd=root, text=True
        ).strip()

    def land_adr(self, root: Path, path: Path) -> None:
        subprocess.run(
            ["git", "add", str(path.relative_to(root))], cwd=root, check=True
        )
        subprocess.run(
            ["git", "commit", "-q", "-m", "land ADR"], cwd=root, check=True
        )

    def write_instruction(
        self,
        root: Path,
        *,
        unit_id: str = "PTO-SCALAR-EXAMPLE",
        mnemonic: str = "EXAMPLE",
    ) -> Path:
        path = root / "asl/scalar/example/EXAMPLE.asl"
        path.parent.mkdir(parents=True, exist_ok=True)
        metadata = {
            "id": unit_id,
            "surface": "scalar",
            "classification": ["example"],
            "depends_on": [],
            "mnemonic": mnemonic,
        }
        path.write_text(
            f"// PTO-INSTRUCTION: {json.dumps(metadata, separators=(',', ':'))}\n"
            "// NDF-BEGIN: PTO-EXAMPLE-CONTRACT\n"
            "// ndf: kind=contract level=L1 layer=scalar status=accepted\n"
            "// The example contract MUST remain explicit.\n"
            "// NDF-END: PTO-EXAMPLE-CONTRACT\n",
            encoding="utf-8",
        )
        return path

    def write_release_selection(self, root: Path, baseline: str) -> None:
        path = root / "spec/release-selection.json"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(
            json.dumps({"baseline_commit": baseline}) + "\n", encoding="utf-8"
        )

    def test_every_repository_adr_uses_frontmatter(self) -> None:
        records = load_adrs(ROOT / "docs/status/decisions")
        index = json.loads(
            (ROOT / "spec/evidence/adr-index.json").read_text(encoding="utf-8")
        )
        self.assertEqual(len(records), index["summary"]["record_count"])
        self.assertEqual(validate_adr_graph(records), [])

    def test_every_prd_has_exactly_one_adr_owner(self) -> None:
        records = load_adrs(ROOT / "docs/status/decisions")
        owners = {}
        for record in records:
            for legacy_id in record.legacy_ids:
                if legacy_id.startswith("PRD-"):
                    self.assertNotIn(legacy_id, owners)
                    owners[legacy_id] = record.adr_id
        self.assertEqual(set(owners), EXPECTED_PRDS)

    def test_active_semantics_contain_no_prd_reference(self) -> None:
        result = subprocess.run(
            [
                "git",
                "grep",
                "-nE",
                r"PRD-[0-9]{3}",
                "--",
                "asl/**",
                "spec/catalog/**",
                "spec/profile-hooks.json",
                "tests/asl/**",
            ],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(result.returncode, 1, result.stdout)

    def test_prd_ids_are_absent_from_adr_bodies(self) -> None:
        for path in sorted((ROOT / "docs/status/decisions").glob("*.md")):
            if path.name == "0000-template.md":
                continue
            body = path.read_text(encoding="utf-8").split("---", 2)[2]
            self.assertNotRegex(body, r"\bPRD-[0-9]{3}\b", path.name)

    def test_pd_ids_are_absent_from_adr_bodies(self) -> None:
        for path in sorted((ROOT / "docs/status/decisions").glob("*.md")):
            if path.name == "0000-template.md":
                continue
            body = path.read_text(encoding="utf-8").split("---", 2)[2]
            self.assertNotRegex(body, r"\bPD-[0-9]{2}\b", path.name)

    def test_adr_index_contains_complete_legacy_mapping(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "adr-index.json"
            open_output = Path(directory) / "open-index.md"
            result = subprocess.run(
                [
                    str(ADR_INDEX),
                    "--output",
                    str(output),
                    "--open-output",
                    str(open_output),
                ],
                cwd=ROOT,
                text=True,
                capture_output=True,
                check=False,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            index = json.loads(output.read_text(encoding="utf-8"))
            self.assertEqual(index["schema"], "pto.adr-index")
            self.assertEqual(
                index["summary"]["record_count"],
                len(load_adrs(ROOT / "docs/status/decisions")),
            )
            self.assertEqual(index["summary"]["legacy_id_count"], 198)
            self.assertEqual(
                len([key for key in index["legacy_map"] if key.startswith("PRD-")]),
                183,
            )
            self.assertEqual(index["legacy_map"]["PRD-001"], "ADR-0075")
            self.assertEqual(index["legacy_map"]["PRD-144"], "ADR-0078")
            self.assertEqual(index["legacy_map"]["PRD-145"], "ADR-0078")
            self.assertEqual(index["legacy_map"]["PRD-183"], "ADR-0085")
            self.assertEqual(
                {
                    row["id"]
                    for row in index["records"]
                    if row.get("release_boundary") is True
                },
                {"ADR-0099", "ADR-0102", "ADR-0108", "ADR-0110"}
            )
            self.assertTrue(
                all(
                    "release_boundary" not in row
                    or row["release_boundary"] is True
                    for row in index["records"]
                )
            )

    def test_adr_index_check_rejects_stale_output(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "adr-index.json"
            open_output = Path(directory) / "open-index.md"
            output.write_text("{}\n", encoding="utf-8")
            result = subprocess.run(
                [
                    str(ADR_INDEX),
                    "--check",
                    "--output",
                    str(output),
                    "--open-output",
                    str(open_output),
                ],
                cwd=ROOT,
                text=True,
                capture_output=True,
                check=False,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("out of date", result.stderr)

    def test_repository_scoped_impacts_match_preserved_decisions(self) -> None:
        records = {
            record.adr_id: record
            for record in load_adrs(ROOT / "docs/status/decisions")
        }
        pc = records["ADR-0021"]
        self.assertEqual(
            pc.affected_ndf,
            (
                "PTO-ADDTPC-PAGE-001",
                "PTO-BARG-CONTINUATION-001",
                "PTO-C-SETRET-DECISION-BINDING-001",
                "PTO-HL-ADDTPC-PAGE-001",
                "PTO-HL-SETRET-DECISION-BINDING-001",
                "PTO-SETRET-ADR-CONTRACT-001",
            ),
        )
        self.assertEqual(
            pc.affected_units,
            (
                "PTO-ARCH-STATE-PROGRAM-COUNTER",
                "PTO-BLOCK-MODEL-STATE-BARG",
                "PTO-SCALAR-ADDTPC",
                "PTO-SCALAR-C-SETRET",
                "PTO-SCALAR-HL-ADDTPC",
                "PTO-SCALAR-HL-SETRET",
                "PTO-SCALAR-SETRET",
            ),
        )
        classification = records["ADR-0048"]
        self.assertEqual(
            classification.affected_ndf,
            (
                "PTO-FMAX-DECISION-BINDING-001",
                "PTO-FMIN-DECISION-BINDING-001",
                "PTO-NUMERIC-FINITE-DECOMPOSITION-001",
                "PTO-NUMERIC-FORMAT-DESCRIPTOR-001",
                "PTO-TMAX-CONTRACT-001",
                "PTO-TMIN-CONTRACT-001",
            ),
        )
        self.assertEqual(
            classification.affected_units,
            (
                "PTO-ARCH-DATA-TYPES-FORMAT-BF16",
                "PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR",
                "PTO-ARCH-DATA-TYPES-FORMAT-E1M2X2",
                "PTO-ARCH-DATA-TYPES-FORMAT-E2M1X2",
                "PTO-ARCH-DATA-TYPES-FORMAT-E2M3",
                "PTO-ARCH-DATA-TYPES-FORMAT-E3M2",
                "PTO-ARCH-DATA-TYPES-FORMAT-E4M3",
                "PTO-ARCH-DATA-TYPES-FORMAT-E5M2",
                "PTO-ARCH-DATA-TYPES-FORMAT-E8M0",
                "PTO-ARCH-DATA-TYPES-FORMAT-FP16",
                "PTO-ARCH-DATA-TYPES-FORMAT-FP32",
                "PTO-ARCH-DATA-TYPES-FORMAT-FP64",
                "PTO-ARCH-DATA-TYPES-FORMAT-HF32",
                "PTO-ARCH-DATA-TYPES-FORMAT-HIF4X2",
                "PTO-ARCH-DATA-TYPES-FORMAT-HIF8",
                "PTO-ARCH-DATA-TYPES-FORMAT-TF32",
                "PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION",
                "PTO-ARCH-DATA-TYPES-NUMERIC-FORMATS",
                "PTO-SCALAR-FMAX",
                "PTO-SCALAR-FMIN",
                "PTO-SCALAR-MODEL-FSU-PROFILE",
                "PTO-TILE-MODEL-EXECUTION-COMPARISON",
                "PTO-TILE-MODEL-EXECUTION-FUSED-MULTIPLY-ADD",
                "PTO-TILE-MODEL-EXECUTION-UNARY",
                "PTO-TILE-MODEL-NUMERIC-FORMATS",
                "PTO-TILE-MODEL-ORDERING-SORTING",
                "PTO-TILE-TMAX",
                "PTO-TILE-TMIN",
            ),
        )

    def test_unknown_asl_impacts_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            baseline = self.initialize_repository(root)
            path = self.write_metadata(
                root / "docs/status/decisions",
                baseline=baseline,
                affected_ndf=["PTO-MISSING-NDF"],
                affected_units=["PTO-MISSING-UNIT"],
            )
            self.land_adr(root, path)

            result = self.run_checker(root)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("unknown current NDF PTO-MISSING-NDF", result.stderr)
            self.assertIn("unknown current ASL unit PTO-MISSING-UNIT", result.stderr)

    def test_current_instruction_contract_is_a_known_synthetic_ndf(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            instruction = self.write_instruction(root)
            baseline = self.initialize_repository(root, instruction)
            path = self.write_metadata(
                root / "docs/status/decisions",
                baseline=baseline,
                affected_ndf=["PTO-INST-SCALAR-EXAMPLE"],
                affected_units=["PTO-SCALAR-EXAMPLE"],
            )
            self.land_adr(root, path)

            result = self.run_checker(root)
            self.assertEqual(result.returncode, 0, result.stderr)

    def test_release_boundary_allows_retired_selected_baseline_impacts(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            instruction = self.write_instruction(root)
            baseline = self.initialize_repository(root, instruction)
            instruction.unlink()
            self.write_release_selection(root, baseline)
            path = self.write_metadata(
                root / "docs/status/decisions",
                baseline=baseline,
                release_boundary=True,
                affected_ndf=["PTO-EXAMPLE-CONTRACT"],
                affected_units=["PTO-SCALAR-EXAMPLE"],
            )
            self.land_adr(root, path)

            result = self.run_checker(root)
            self.assertEqual(result.returncode, 0, result.stderr)

    def test_non_boundary_record_rejects_retired_selected_baseline_impacts(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            instruction = self.write_instruction(root)
            baseline = self.initialize_repository(root, instruction)
            instruction.unlink()
            self.write_release_selection(root, baseline)
            path = self.write_metadata(
                root / "docs/status/decisions",
                baseline=baseline,
                affected_ndf=["PTO-EXAMPLE-CONTRACT"],
                affected_units=["PTO-SCALAR-EXAMPLE"],
            )
            self.land_adr(root, path)

            result = self.run_checker(root)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("unknown current NDF PTO-EXAMPLE-CONTRACT", result.stderr)
            self.assertIn(
                "unknown current ASL unit PTO-SCALAR-EXAMPLE", result.stderr
            )

    def test_release_boundary_rejects_impacts_absent_from_current_and_baseline(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            instruction = self.write_instruction(root)
            baseline = self.initialize_repository(root, instruction)
            self.write_release_selection(root, baseline)
            path = self.write_metadata(
                root / "docs/status/decisions",
                baseline=baseline,
                release_boundary=True,
                affected_ndf=["PTO-MISSING-NDF"],
                affected_units=["PTO-MISSING-UNIT"],
            )
            self.land_adr(root, path)

            result = self.run_checker(root)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn(
                "unknown current or selected-baseline NDF PTO-MISSING-NDF",
                result.stderr,
            )
            self.assertIn(
                "unknown current or selected-baseline ASL unit PTO-MISSING-UNIT",
                result.stderr,
            )

    def test_ndf_impact_requires_its_current_owning_unit(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            asl = root / "asl/arch"
            asl.mkdir(parents=True)
            (asl / "owner.asl").write_text(
                '// PTO-UNIT: {"id":"PTO-ARCH-OWNER","surface":"arch",'
                '"classification":["owner"],"depends_on":[]}\n'
                "// NDF-BEGIN: PTO-OWNER-CONTRACT\n"
                "// ndf: kind=contract level=L1 layer=architecture status=accepted\n"
                "// The owner contract MUST remain explicit.\n"
                "// NDF-END: PTO-OWNER-CONTRACT\n",
                encoding="utf-8",
            )
            (asl / "other.asl").write_text(
                '// PTO-UNIT: {"id":"PTO-ARCH-OTHER","surface":"arch",'
                '"classification":["other"],"depends_on":[]}\n',
                encoding="utf-8",
            )
            baseline = self.initialize_repository(
                root, asl / "owner.asl", asl / "other.asl"
            )
            path = self.write_metadata(
                root / "docs/status/decisions",
                baseline=baseline,
                affected_ndf=["PTO-OWNER-CONTRACT"],
                affected_units=["PTO-ARCH-OTHER"],
            )
            self.land_adr(root, path)

            result = self.run_checker(root)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn(
                "PTO-OWNER-CONTRACT is owned by PTO-ARCH-OWNER, "
                "which is absent from affected_units",
                result.stderr,
            )

    def test_baseline_must_equal_parent_of_first_landing_commit(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            baseline = self.initialize_repository(root)
            path = self.write_metadata(
                root / "docs/status/decisions", baseline="0" * 40
            )
            self.land_adr(root, path)

            result = self.run_checker(root)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn(
                "baseline 0000000000000000000000000000000000000000 "
                f"does not match first-landing parent {baseline}",
                result.stderr,
            )

    def test_missing_frontmatter_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "0075-example.md"
            path.write_text("# ADR 0075: Example\n", encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "JSON frontmatter"):
                parse_adr(path)

    def test_unknown_status_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = self.write_adr(
                Path(directory),
                "0075-example.md",
                '{"id":"ADR-0075","title":"Example","status":"done"}',
                "# ADR 0075: Example",
            )
            with self.assertRaisesRegex(ValueError, "status"):
                parse_adr(path)

    def test_non_scalar_enum_values_are_rejected_as_validation_errors(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            with self.assertRaisesRegex(ValueError, "status"):
                parse_adr(self.write_metadata(root, status=[]))
            with self.assertRaisesRegex(ValueError, "release_impact"):
                parse_adr(self.write_metadata(root, release_impact=[]))

    def test_complete_draft_is_parsed(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = self.write_metadata(Path(directory))
            record = parse_adr(path)
            self.assertEqual(record.adr_id, "ADR-0075")
            self.assertEqual(record.authors, ("architect",))
            self.assertEqual(record.target_releases, ("unassigned",))
            self.assertFalse(record.release_boundary)
            self.assertFalse(record.interface_change)
            self.assertEqual(record.path, path)

    def test_new_adr_number_requires_explicit_interface_change(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            with self.assertRaisesRegex(ValueError, "interface_change=true"):
                parse_adr(
                    self.write_metadata(
                        root,
                        name="0111-example.md",
                        id="ADR-0111",
                    )
                )
            record = parse_adr(
                self.write_metadata(
                    root,
                    name="0111-example.md",
                    id="ADR-0111",
                    interface_change=True,
                )
            )
            self.assertTrue(record.interface_change)

    def test_reserved_gap_number_cannot_be_reused(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(ValueError, "reserved historical ADR number"):
                parse_adr(
                    self.write_metadata(
                        Path(directory),
                        name="0104-example.md",
                        id="ADR-0104",
                    )
                )

    def test_interface_change_must_be_boolean(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(ValueError, "interface_change must be a boolean"):
                parse_adr(
                    self.write_metadata(
                        Path(directory),
                        interface_change="true",
                    )
                )

    def test_amendment_provenance_is_parsed(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            amendment = {
                "date": "2026-09-01",
                "baseline": "4be7d809e79af23401073edaf80d8cca82ccef95",
                "approvers": ["reviewer"],
                "issue": "https://example.com/issues/1",
                "affected_ndf": ["PTO-EXAMPLE-CONTRACT"],
                "affected_units": ["PTO-SCALAR-EXAMPLE"],
            }
            record = parse_adr(
                self.write_metadata(
                    Path(directory),
                    affected_ndf=["PTO-EXAMPLE-CONTRACT"],
                    affected_units=["PTO-SCALAR-EXAMPLE"],
                    amendments=[amendment],
                )
            )
            self.assertEqual(record.amendments[0].baseline, amendment["baseline"])

    def test_release_boundary_must_be_boolean(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.assertTrue(
                parse_adr(
                    self.write_metadata(root, release_boundary=True)
                ).release_boundary
            )
            with self.assertRaisesRegex(ValueError, "release_boundary must be a boolean"):
                parse_adr(self.write_metadata(root, release_boundary="true"))

    def test_filename_must_match_id(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = self.write_metadata(Path(directory), name="0076-example.md")
            with self.assertRaisesRegex(ValueError, "filename.*ADR-0075"):
                parse_adr(path)

    def test_accepted_adr_requires_approvers_and_date(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = self.write_metadata(
                Path(directory),
                status="accepted",
                affected_ndf=["PTO-INST-TILE-EXAMPLE"],
            )
            with self.assertRaisesRegex(ValueError, "accepted.*approvers"):
                parse_adr(path)

            path = self.write_metadata(
                Path(directory),
                status="accepted",
                approvers=["reviewer"],
                affected_ndf=["PTO-INST-TILE-EXAMPLE"],
            )
            with self.assertRaisesRegex(ValueError, "accepted.*date"):
                parse_adr(path)

    def test_accepted_adr_requires_affected_ndf(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = self.write_metadata(
                Path(directory),
                status="accepted",
                approvers=["reviewer"],
                accepted="2026-08-21",
            )
            with self.assertRaisesRegex(ValueError, "accepted.*affected_ndf"):
                parse_adr(path)

    def test_rejected_adr_requires_rejection_date(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = self.write_metadata(Path(directory), status="rejected")
            with self.assertRaisesRegex(ValueError, "rejected.*date"):
                parse_adr(path)

    def test_superseded_adr_requires_supersession_date(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = self.write_metadata(
                Path(directory),
                status="superseded",
                superseded_by=["ADR-0076"],
            )
            with self.assertRaisesRegex(ValueError, "superseded.*date"):
                parse_adr(path)

    def test_superseded_adr_requires_successor(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = self.write_metadata(
                Path(directory),
                status="superseded",
                superseded="2026-08-21",
            )
            with self.assertRaisesRegex(ValueError, "superseded_by"):
                parse_adr(path)

    def test_unknown_ndf_identifier_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = self.write_metadata(Path(directory), affected_ndf=["UNKNOWN-NDF"])
            with self.assertRaisesRegex(ValueError, "affected_ndf"):
                parse_adr(path)

    def test_downstream_asl_model_identifiers_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for field in ("affected_ndf", "affected_units"):
                with self.subTest(field=field):
                    path = self.write_metadata(
                        root,
                        **{field: ["PTO-MODEL-STEP-001"]},
                    )
                    with self.assertRaisesRegex(
                        ValueError,
                        "downstream ASL-Model identifier PTO-MODEL-STEP-001",
                    ):
                        parse_adr(path)

    def test_absolute_implementation_issue_uri_is_accepted(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = self.write_metadata(
                Path(directory),
                implementation_issue=(
                    "https://example.com/issues/75?label=architecture%20decision#status"
                ),
            )
            self.assertEqual(
                parse_adr(path).implementation_issue,
                "https://example.com/issues/75?label=architecture%20decision#status",
            )

    def test_implementation_issue_rejects_controls_and_bad_percent_escapes(self) -> None:
        invalid_uris = (
            "issues/75",
            "https://example.com/issues/\n75",
            "https://example.com/issues/%zz",
            "https://example.com/issues/%2",
        )
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for uri in invalid_uris:
                with self.subTest(uri=uri):
                    path = self.write_metadata(root, implementation_issue=uri)
                    with self.assertRaisesRegex(ValueError, "implementation_issue URI"):
                        parse_adr(path)

    def test_implementation_issue_rejects_invalid_https_components(self) -> None:
        invalid_uris = (
            "https://example.com:abc/issues/75",
            "https://example.com:65536/issues/75",
            "https:///issues/75",
            "https://user@@example.com/issues/75",
            "https://[2001:db8::1/issues/75",
            "https://example.com/issues/75#one#two",
        )
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for uri in invalid_uris:
                with self.subTest(uri=uri):
                    path = self.write_metadata(root, implementation_issue=uri)
                    with self.assertRaisesRegex(ValueError, "implementation_issue URI"):
                        parse_adr(path)

    def test_schema_uses_the_same_narrow_https_issue_contract(self) -> None:
        schema = json.loads(
            (ROOT / "spec/schemas/pto-adr.schema.json").read_text(encoding="utf-8")
        )
        pattern = schema["properties"]["implementation_issue"]["pattern"]
        valid_uri = "https://example.com/issues/75?label=architecture%20decision#status"
        invalid_uris = (
            "issues/75",
            "https://example.com/issues/\n75",
            "https://example.com/issues/%zz",
            "https://example.com/issues/%2",
            "https://example.com:abc/issues/75",
            "https://example.com:65536/issues/75",
            "https:///issues/75",
            "https://user@@example.com/issues/75",
            "https://[2001:db8::1/issues/75",
            "https://example.com/issues/75#one#two",
        )
        self.assertIsNotNone(re.fullmatch(pattern, valid_uri))
        for uri in invalid_uris:
            with self.subTest(uri=uri):
                self.assertIsNone(re.fullmatch(pattern, uri))

    def test_schema_defines_optional_boolean_release_boundary(self) -> None:
        schema = json.loads(
            (ROOT / "spec/schemas/pto-adr.schema.json").read_text(encoding="utf-8")
        )
        self.assertNotIn("release_boundary", schema["required"])
        self.assertEqual(
            schema["properties"]["release_boundary"],
            {
                "type": "boolean",
                "default": False,
                "description": (
                    "True only when the ADR records a release boundary and may retain "
                    "impacts that existed at the selected release baseline but are "
                    "retired from the current tree."
                ),
            },
        )

    def test_schema_defines_interface_change_and_rejects_model_namespace(self) -> None:
        schema = json.loads(
            (ROOT / "spec/schemas/pto-adr.schema.json").read_text(encoding="utf-8")
        )
        self.assertNotIn("interface_change", schema["required"])
        self.assertEqual(
            schema["properties"]["interface_change"]["type"],
            "boolean",
        )
        self.assertEqual(
            schema["properties"]["affected_ndf"]["items"]["not"]["pattern"],
            "^PTO-MODEL-",
        )
        self.assertEqual(
            schema["properties"]["affected_units"]["items"]["not"]["pattern"],
            "^PTO-MODEL-",
        )
        self.assertEqual(schema["properties"]["id"]["not"]["const"], "ADR-0104")
        self.assertTrue(
            any(
                row.get("then", {}).get("properties", {}).get("interface_change")
                == {"const": True}
                for row in schema["allOf"]
            )
        )

    def test_duplicate_adr_ids_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            first = self.parsed_record(root / "first", 75)
            second = self.parsed_record(root / "second", 75)
            self.assertTrue(
                any("duplicate ADR id ADR-0075" in error for error in validate_adr_graph([first, second]))
            )

    def test_unknown_adr_reference_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            record = self.parsed_record(Path(directory), 75, resolves=["ADR-9999"])
            self.assertTrue(
                any("unknown ADR reference ADR-9999" in error for error in validate_adr_graph([record]))
            )

    def test_future_adr_numbers_must_be_contiguous(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            record = self.parsed_record(root, 112, interface_change=True)
            self.assertTrue(
                any("contiguous from ADR-0111" in error for error in validate_adr_graph([record]))
            )

    def test_supersession_cycles_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            first = self.parsed_record(
                root / "first", 75, supersedes=["ADR-0076"], superseded_by=["ADR-0076"]
            )
            second = self.parsed_record(
                root / "second", 76, supersedes=["ADR-0075"], superseded_by=["ADR-0075"]
            )
            self.assertTrue(
                any("supersession cycle" in error for error in validate_adr_graph([first, second]))
            )

    def test_duplicate_legacy_ids_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            first = self.parsed_record(root / "first", 75, legacy_ids=["PRD-001"])
            second = self.parsed_record(root / "second", 76, legacy_ids=["PRD-001"])
            self.assertTrue(
                any("duplicate legacy id PRD-001" in error for error in validate_adr_graph([first, second]))
            )

    def test_supersession_must_be_reciprocal(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            first = self.parsed_record(root / "first", 75, supersedes=["ADR-0076"])
            second = self.parsed_record(root / "second", 76)
            self.assertTrue(
                any("not reciprocal" in error for error in validate_adr_graph([first, second]))
            )

    def test_reciprocal_supersession_is_valid(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            first = self.parsed_record(root / "first", 75, supersedes=["ADR-0076"])
            second = self.parsed_record(root / "second", 76, superseded_by=["ADR-0075"])
            self.assertEqual(validate_adr_graph([first, second]), [])

    def test_load_adrs_sorts_records_and_skips_template(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.parsed_record(root, 76)
            self.parsed_record(root, 75)
            (root / "0000-template.md").write_text("not an ADR", encoding="utf-8")
            self.assertEqual(
                tuple(record.adr_id for record in load_adrs(root)),
                ("ADR-0075", "ADR-0076"),
            )

    def test_load_adrs_recurses_in_deterministic_path_order(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.parsed_record(root / "z-last", 75)
            self.parsed_record(root / "a-first", 76)
            self.assertEqual(
                tuple(record.adr_id for record in load_adrs(root)),
                ("ADR-0076", "ADR-0075"),
            )

    def test_checker_prints_validated_record_count(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            decisions = root / "docs/status/decisions"
            self.parsed_record(decisions, 75)
            self.parsed_record(decisions, 76)
            result = self.run_checker(root)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, "ADR checks passed: 2 records\n")

    def test_checker_fails_closed_on_graph_errors(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            decisions = root / "docs/status/decisions"
            self.parsed_record(decisions, 75, resolves=["ADR-9999"])
            result = self.run_checker(root)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("unknown ADR reference ADR-9999", result.stderr)
            self.assertEqual(result.stdout, "")

    def test_checker_rejects_malformed_nested_adr(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            nested = root / "docs/status/decisions/topic"
            nested.mkdir(parents=True)
            (nested / "0075-example.md").write_text(
                "# ADR 0075: Missing metadata\n", encoding="utf-8"
            )
            result = self.run_checker(root)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("missing JSON frontmatter", result.stderr)
            self.assertEqual(result.stdout, "")

    def test_checker_rejects_graph_invalid_nested_adr(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            decisions = root / "docs/status/decisions"
            self.parsed_record(
                decisions / "topic", 75, resolves=["ADR-9999"]
            )
            result = self.run_checker(root)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("unknown ADR reference ADR-9999", result.stderr)
            self.assertEqual(result.stdout, "")

    def test_checker_rejects_each_missing_status_dependent_field(self) -> None:
        cases = (
            (
                "accepted approvers",
                {
                    "status": "accepted",
                    "accepted": "2026-08-21",
                    "affected_ndf": ["PTO-INST-TILE-EXAMPLE"],
                },
                "accepted ADR requires approvers",
            ),
            (
                "accepted date",
                {
                    "status": "accepted",
                    "approvers": ["reviewer"],
                    "affected_ndf": ["PTO-INST-TILE-EXAMPLE"],
                },
                "accepted ADR requires an acceptance date",
            ),
            (
                "accepted affected_ndf",
                {
                    "status": "accepted",
                    "approvers": ["reviewer"],
                    "accepted": "2026-08-21",
                },
                "accepted ADR requires affected_ndf",
            ),
            (
                "rejected date",
                {"status": "rejected"},
                "rejected ADR requires a rejection date",
            ),
            (
                "superseded date",
                {"status": "superseded", "superseded_by": ["ADR-0076"]},
                "superseded ADR requires a supersession date",
            ),
            (
                "superseded successor",
                {"status": "superseded", "superseded": "2026-08-21"},
                "superseded ADR requires superseded_by",
            ),
        )
        for name, updates, diagnostic in cases:
            with self.subTest(name=name), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                self.write_metadata(root / "docs/status/decisions", **updates)
                result = self.run_checker(root)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(diagnostic, result.stderr)
                self.assertEqual(result.stdout, "")

    def test_checker_rejects_invalid_https_components(self) -> None:
        invalid_uris = (
            "https://example.com:abc/issues/75",
            "https://example.com:65536/issues/75",
            "https:///issues/75",
            "https://user@@example.com/issues/75",
            "https://[2001:db8::1/issues/75",
            "https://example.com/issues/75#one#two",
        )
        for uri in invalid_uris:
            with self.subTest(uri=uri), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                self.write_metadata(
                    root / "docs/status/decisions", implementation_issue=uri
                )
                result = self.run_checker(root)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("invalid implementation_issue URI", result.stderr)
                self.assertEqual(result.stdout, "")


if __name__ == "__main__":
    unittest.main()
