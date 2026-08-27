from __future__ import annotations

import json
import unittest
from pathlib import Path

from scripts.adr_records import load_adrs
from scripts.asl_units import load_units
from scripts.ndf import instruction_clause_id, parse_ndf_regions
from scripts.release_selection import _baseline_inputs


ROOT = Path(__file__).resolve().parents[2]


class DecisionImplementationClosureTest(unittest.TestCase):
    def current_impacts(self) -> tuple[set[str], dict[str, str], set[str]]:
        units = load_units(ROOT / "asl")
        unit_ids = {unit.unit_id for unit in units}
        unit_by_source = {unit.source_path: unit.unit_id for unit in units}
        accepted_ndf: set[str] = set()
        ndf_owners: dict[str, str] = {}
        for path in sorted((ROOT / "asl").rglob("*.asl")):
            source = path.relative_to(ROOT)
            for clause in parse_ndf_regions(
                path.read_text(encoding="utf-8"), source
            ):
                ndf_owners[clause.clause_id] = unit_by_source[source]
                if clause.status == "accepted":
                    accepted_ndf.add(clause.clause_id)
        for unit in units:
            if unit.mnemonic is not None:
                clause_id = instruction_clause_id(unit.surface, unit.mnemonic)
                ndf_owners[clause_id] = unit.unit_id
        return unit_ids, ndf_owners, accepted_ndf

    def baseline_impacts(self) -> tuple[set[str], set[str]]:
        selection = json.loads((ROOT / "spec/release-selection.json").read_text())
        manifest, unit_rows = _baseline_inputs(ROOT, selection["baseline_commit"])
        expanded = manifest["release_selection"]["expanded_ndf"]
        return (
            {row["id"] for row in unit_rows},
            {row["id"] for row in expanded},
        )

    def test_accepted_decision_impacts_join_exact_current_owners(self) -> None:
        unit_ids, ndf_owners, _ = self.current_impacts()
        baseline_units, baseline_ndf = self.baseline_impacts()
        records = load_adrs(ROOT / "docs/status/decisions")
        errors: list[str] = []
        for record in records:
            if record.status != "accepted":
                continue
            for unit_id in record.affected_units:
                if unit_id not in unit_ids and not (
                    record.release_boundary and unit_id in baseline_units
                ):
                    errors.append(f"{record.adr_id}: unknown unit {unit_id}")
            for ndf_id in record.affected_ndf:
                owner = ndf_owners.get(ndf_id)
                if owner is None:
                    if not (record.release_boundary and ndf_id in baseline_ndf):
                        errors.append(f"{record.adr_id}: unknown NDF {ndf_id}")
                elif owner not in record.affected_units:
                    errors.append(
                        f"{record.adr_id}: {ndf_id} owner {owner} is not affected"
                    )
        self.assertEqual(errors, [])

    def test_every_accepted_ndf_clause_has_an_accepted_adr_owner(self) -> None:
        _, _, accepted_ndf = self.current_impacts()
        records = load_adrs(ROOT / "docs/status/decisions")
        owned_ndf = {
            ndf_id
            for record in records
            if record.status == "accepted"
            for ndf_id in record.affected_ndf
        }
        self.assertEqual(accepted_ndf - owned_ndf, set())


if __name__ == "__main__":
    unittest.main()
