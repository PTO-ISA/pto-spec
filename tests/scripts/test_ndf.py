from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

import scripts.ndf as ndf_module
from scripts.ndf import (
    check_repository,
    instruction_clause_id,
    parse_ndf_regions,
)


VALID_CLAUSE = """// NDF-BEGIN: PTO-TILE-CAPACITY
// ndf: kind=contract level=L1 layer=tile status=accepted
// Tile capacity is defined per selected PE.
// NDF-END: PTO-TILE-CAPACITY
"""
REPOSITORY_ROOT = Path(__file__).resolve().parents[2]


class NdfTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def write(self, relative: str, text: str) -> Path:
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        return path

    def test_parse_valid_clause(self) -> None:
        clauses = parse_ndf_regions(VALID_CLAUSE, Path("asl/architecture.asl"))

        self.assertEqual(len(clauses), 1)
        self.assertEqual(clauses[0].clause_id, "PTO-TILE-CAPACITY")
        self.assertEqual(clauses[0].level, "L1")
        self.assertEqual(clauses[0].body, "Tile capacity is defined per selected PE.")

    def test_rejects_duplicate_clause_ids(self) -> None:
        self.write("asl/architecture.asl", VALID_CLAUSE)
        self.write("asl/tile/state.asl", VALID_CLAUSE)

        self.assertIn(
            "duplicate NDF clause PTO-TILE-CAPACITY",
            check_repository(self.root),
        )

    def test_rejects_mismatched_end_id(self) -> None:
        self.write(
            "asl/architecture.asl",
            VALID_CLAUSE.replace(
                "NDF-END: PTO-TILE-CAPACITY",
                "NDF-END: PTO-OTHER",
            ),
        )

        self.assertTrue(
            any("mismatched NDF end PTO-OTHER" in error for error in check_repository(self.root))
        )

    def test_rejects_invalid_metadata(self) -> None:
        self.write(
            "asl/architecture.asl",
            VALID_CLAUSE.replace(
                "kind=contract level=L1 layer=tile status=accepted",
                "kind=contract level=L3 layer=unknown status=final",
            ),
        )

        errors = check_repository(self.root)
        self.assertTrue(any("kind contract requires level L1" in error for error in errors))
        self.assertTrue(any("unknown NDF layer unknown" in error for error in errors))
        self.assertTrue(any("unknown NDF status final" in error for error in errors))

    def test_rejects_unknown_cross_reference(self) -> None:
        self.write(
            "asl/architecture.asl",
            VALID_CLAUSE.replace(
                "selected PE.",
                "selected PE; see [[PTO-MISSING]].",
            ),
        )

        self.assertIn(
            "asl/architecture.asl: unknown NDF reference PTO-MISSING",
            check_repository(self.root),
        )

    def test_legacy_markdown_ndf_marker_is_rejected_with_legacy_tree(self) -> None:
        self.write(
            "docs/status/legacy/root/architecture.md",
            "## Contract {#PTO-TILE-CAPACITY}\n"
            "<!-- ndf: kind=contract level=L1 layer=tile status=accepted -->\n",
        )

        self.assertIn(
            "forbidden legacy specification path: docs/status/legacy/root/architecture.md",
            check_repository(self.root),
        )

    def test_rejects_legacy_archive_and_backup_paths(self) -> None:
        self.write("docs/legacy/old.md", "old\n")
        self.write("docs/archive/old.md", "old\n")
        self.write("asl/tile/state.asl.bak", "old\n")

        errors = check_repository(self.root)
        self.assertIn("forbidden legacy specification path: docs/legacy/old.md", errors)
        self.assertIn("forbidden legacy specification path: docs/archive/old.md", errors)
        self.assertIn("forbidden backup specification path: asl/tile/state.asl.bak", errors)

    def test_status_legacy_is_rejected(self) -> None:
        self.write("docs/status/legacy/old.md", "# Historical\n")

        self.assertIn(
            "forbidden legacy specification path: docs/status/legacy/old.md",
            check_repository(self.root),
        )

    def test_normative_asl_reference_into_status_legacy_is_rejected(self) -> None:
        self.write(
            "asl/architecture.asl",
            VALID_CLAUSE.replace(
                "selected PE.",
                "selected PE; see docs/status/legacy/old.md.",
            ),
        )
        self.write("docs/status/legacy/old.md", "# Historical\n")

        self.assertIn(
            "asl/architecture.asl: normative reference targets non-normative legacy material",
            check_repository(self.root),
        )

    def test_accepts_asl_owned_clause(self) -> None:
        self.write("asl/architecture.asl", VALID_CLAUSE)

        self.assertEqual(check_repository(self.root), [])

    def test_instruction_clause_id_is_stable_and_surface_scoped(self) -> None:
        self.assertEqual(instruction_clause_id("tile", "TLOAD"), "PTO-INST-TILE-TLOAD")
        self.assertEqual(
            instruction_clause_id("block", "BSTART.TLOAD"),
            "PTO-INST-BLOCK-BSTART-TLOAD",
        )

    def test_generic_architecture_contracts_replace_consumer_specific_anchor(self) -> None:
        identities = {
            clause.clause_id
            for path in sorted((REPOSITORY_ROOT / "asl").rglob("*.asl"))
            for clause in parse_ndf_regions(
                path.read_text(encoding="utf-8"),
                path.relative_to(REPOSITORY_ROOT),
            )
        }

        self.assertIn("PTO-ARCH-COMMIT-EVENT-CONFORMANCE-001", identities)
        self.assertIn("PTO-ARCH-STATE-CLOSURE-001", identities)
        self.assertNotIn("PTO-ARCH-SHARED-TILE-STATE-001", identities)

    def test_complete_state_catalog_has_exact_owner_member_partition(self) -> None:
        indexer = getattr(ndf_module, "state_index", None)
        self.assertTrue(callable(indexer), "scripts.ndf.state_index is missing")
        states = indexer(REPOSITORY_ROOT)
        expected_members = {
            "PTO-STATE-ARCH-GPR": ("_PEGPRs",),
            "PTO-STATE-ARCH-TEMPORARY-QUEUES": (
                "_TQueue",
                "_TQueueValid",
                "_UQueue",
                "_UQueueValid",
            ),
            "PTO-STATE-ARCH-GQM": (
                "_GQMQueueValid",
                "_GQMQueueAddress",
                "_GQMQueueCapacity",
                "_GQMQueueCount",
                "_GQMQueueHead",
                "_GQMQueueSuspended",
                "_GQMQueueCorrupt",
                "_GQMQueueEntries",
                "_GQMReleaseEpoch",
                "_LastGQMAcquireEpoch",
                "_GQMEventEpoch",
                "_LastGQMEventAddress",
            ),
            "PTO-STATE-ARCH-PROGRAM-CONTROL": (
                "_PC",
                "_BPC",
                "_BundleActive",
                "_BundleBodyActive",
                "_ReturnAddress",
                "_CommitArgument",
                "_PredicateRegisters",
            ),
            "PTO-STATE-ARCH-FAULT": ("_LastFault", "_FaultAddress"),
            "PTO-STATE-ARCH-MEMORY": (
                "_Memory",
                "_ReservationValid",
                "_ReservationAddress",
                "_ReservationSize",
                "_LastFencePredecessor",
                "_LastFenceSuccessor",
                "_MemoryEvents",
                "_MemoryEventCount",
                "_MemoryEventCaptureEnabled",
                "_CurrentMemoryAgent",
            ),
            "PTO-STATE-ARCH-MAINTENANCE": (
                "_DataCacheEpoch",
                "_InstructionCacheEpoch",
                "_BundleCacheEpoch",
                "_TLBEpoch",
                "_LastMaintenanceOperation",
                "_LastMaintenanceOperand",
                "_BundleHintEpoch",
                "_ArchitectureRequestEpoch",
                "_LastControlRequest",
                "_ControlRequestOperand",
            ),
            "PTO-STATE-ARCH-EXTENDED-SYSTEM-REGISTERS": (
                "_ExtendedSystemRegisters",
                "_CurrentACR",
            ),
            "PTO-STATE-ARCH-SYSTEM-REGISTERS": ("_SystemRegisters",),
            "PTO-STATE-ARCH-TRAP-CONTEXT": (
                "_ACRTrapAsynchronous",
                "_ACRTrapArgumentValid",
                "_ACRTrapCause",
                "_ACRTrapNumber",
                "_ACRTrapArgument0",
                "_TrapContexts",
            ),
            "PTO-STATE-TILE-LOCAL": ("_Tiles", "_TileAllocationMasks"),
            "PTO-STATE-TILE-FEATURE-MAP": ("_TileFeatureMapDescriptors",),
            "PTO-STATE-TILE-SHARED": ("_SharedTiles",),
            "PTO-STATE-BLOCK-CONTROL": (
                "_BARG",
                "_BundleCommitTargetSet",
                "_BundleConditionSet",
                "_SystemBlockTerminalPending",
                "_BundleSequentialPC",
                "_FrameStackReturnTarget",
                "_BundleArgument",
                "_BundleArgumentKind",
                "_BundleOperation",
                "_BundleDimensions",
                "_BundleDimensionPresent",
                "_BundleScalarBindings",
                "_BundleTileBindings",
                "_BundleSharedBindings",
                "_BundleRangeGroup",
                "_BundleZeroParticipationSeen",
                "_BundleControlAttributes",
                "_BundleDataAttributes",
                "_BundleDataAttributesPresent",
                "_BundleHint",
                "_BundleFixedPointAttributes",
                "_MemoryCopyTemplate",
                "_FrameTemplate",
                "_LocalGenerations",
                "_BundleExecutionDomainToken",
                "_TileDataLayoutCapabilities",
                "_FrameDepth",
                "_LastFrameBegin",
                "_LastFrameEnd",
                "_LastFrameSize",
                "_LastQueueLeft",
                "_LastQueueRight",
                "_LastQueueFlags",
                "_LastMemoryCommandAddress",
                "_LastMemoryCommandSize",
                "_LastCrossBlockACR",
                "_LastCrossBlockID",
                "_LastBundleHintPayload",
            ),
        }

        self.assertEqual(set(states), set(expected_members))
        self.assertEqual(
            {state_id: state.members for state_id, state in states.items()},
            expected_members,
        )
        self.assertEqual(states["PTO-STATE-ARCH-TEMPORARY-QUEUES"].scope, "bundle")
        all_members = [member for state in states.values() for member in state.members]
        self.assertEqual(len(all_members), len(set(all_members)))
        declared_members = {
            match.group(1)
            for path in sorted((REPOSITORY_ROOT / "asl").rglob("*.asl"))
            for line in path.read_text(encoding="utf-8").splitlines()
            if (match := ndf_module.ASL_VAR.match(line)) is not None
        }
        self.assertEqual(set(all_members), declared_members)

    def test_state_metadata_rejects_schema_owner_scope_and_member_drift(self) -> None:
        parser = getattr(ndf_module, "parse_state_records", None)
        self.assertTrue(callable(parser), "scripts.ndf.parse_state_records is missing")
        text = """// PTO-UNIT: {"id":"PTO-ARCH-OWNER","surface":"arch","classification":["test"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-BAD-SCOPE","classification":["arch","test"],"scope":"thread","owner":"PTO-ARCH-OWNER","members":["_Known"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-BAD-OWNER","classification":["arch","test"],"scope":"core","owner":"PTO-ARCH-OTHER","members":["_Known"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-BAD-MEMBER","classification":["arch","test"],"scope":"core","owner":"PTO-ARCH-OWNER","members":["_Missing"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-BAD-SCHEMA","classification":["arch","test"],"scope":"core","owner":"PTO-ARCH-OWNER","members":["_Known"],"depends_on":[],"description":"forbidden"}
var _Known : bits(32);
"""

        with self.assertRaises(ndf_module.NdfValidationError) as raised:
            parser(text, Path("asl/owner.asl"), "PTO-ARCH-OWNER")

        message = str(raised.exception)
        self.assertIn("unsupported PTO state scope thread", message)
        self.assertIn("does not match same-file unit PTO-ARCH-OWNER", message)
        self.assertIn("state member _Missing is not a same-file ASL var", message)
        self.assertIn("unknown PTO state metadata field description", message)

    def test_davincioo_ndf_manifests_and_instruction_identities_are_stable(self) -> None:
        self.assertEqual(
            (REPOSITORY_ROOT / "ndf.yaml").read_text(encoding="utf-8"),
            """format_version: "0.2"
project: pto-spec
roots:
  - asl/**/*.asl
id_prefixes:
  - PTO
domains:
  - architecture
  - scalar
  - block
  - tile
  - state
  - memory
  - concurrency
policies: {}
dependencies:
  ndf:
    path: tools/ndf
    graph: false
""",
        )
        self.assertEqual(
            (REPOSITORY_ROOT / "ndf.lock").read_text(encoding="utf-8"),
            """format_version: "0.1"
dependencies:
  ndf:
    uri: https://github.com/PTO-ISA/normative_language.git
    revision: ed356980ce7ecb2e8482902988d5012fb54058b3
    path: tools/ndf
""",
        )

        instruction_identities: set[str] = set()
        for path in sorted((REPOSITORY_ROOT / "asl").rglob("*.asl")):
            for line in path.read_text(encoding="utf-8").splitlines():
                if not line.startswith("// PTO-INSTRUCTION: "):
                    continue
                metadata = json.loads(line.removeprefix("// PTO-INSTRUCTION: "))
                instruction_identities.add(
                    instruction_clause_id(metadata["surface"], metadata["mnemonic"])
                )

        self.assertTrue(
            {
                "PTO-INST-TILE-GMOV",
                "PTO-INST-BLOCK-B-DATR",
                "PTO-INST-BLOCK-B-DIM",
                "PTO-INST-BLOCK-B-IOR",
                "PTO-INST-BLOCK-B-IOS",
                "PTO-INST-BLOCK-B-IOT",
                "PTO-INST-TILE-TLOAD",
                "PTO-INST-TILE-TSTORE",
                "PTO-INST-TILE-MGATHER",
                "PTO-INST-TILE-MSCATTER",
            }
            <= instruction_identities
        )


if __name__ == "__main__":
    unittest.main()
