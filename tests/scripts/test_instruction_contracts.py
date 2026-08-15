from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from scripts.asl_units import AslUnit, load_units
from scripts.instruction_contracts import (
    EncodedFieldDisposition,
    FieldDomainContract,
    ROOT,
    check_instruction_contracts,
    derive_encoded_field_dispositions,
    load_field_domains,
    resolve_instruction_contract,
    validate_domain,
)


def domain_metadata(
    *,
    width: int = 2,
    assigned: list[tuple[int, str]] | None = None,
    reserved: list[int] | None = None,
) -> dict[str, object]:
    return {
        "id": "PTO-FIELD-TEST",
        "width": width,
        "role": "test selector",
        "zero_meaning": "zero selects the first assigned meaning",
        "assigned": [
            {"value": value, "meaning": meaning}
            for value, meaning in (assigned or [(0, "FIRST"), (1, "SECOND")])
        ],
        "reserved": reserved if reserved is not None else [2, 3],
        "rejection": "reserved values reject before architectural effects",
    }


def instruction_metadata(**contract_overrides: object) -> dict[str, object]:
    contract: dict[str, object] = {
        "encoding_class": "standalone-encoded",
        "canonical_assembly": ["TEST rd, rs"],
        "field_contracts": {"Selector": {"ref": "PTO-FIELD-TEST"}},
        "operands": [
            {"field": "rd", "role": "destination"},
            {"field": "rs", "role": "source"},
        ],
        "defaults": ["none"],
        "legality": ["Selector must be assigned."],
        "state_effects": ["Write rd with the operation result."],
        "memory_effects": ["none"],
        "ordering": ["none"],
        "exceptions": ["Reserved Selector values raise Fault_IllegalInstruction before effects."],
        "examples": ["TEST a0, a1"],
        "block_composition": ["none"],
        "standalone_opcode": True,
    }
    contract.update(contract_overrides)
    return {
        "id": "PTO-INST-SCALAR-TEST",
        "surface": "scalar",
        "classification": ["alu", "test"],
        "depends_on": [],
        "mnemonic": "TEST",
        "contract": contract,
    }


def unit(metadata: dict[str, object], *, mnemonic: str | None = None) -> AslUnit:
    return AslUnit(
        unit_id=str(metadata["id"]),
        surface=str(metadata["surface"]),
        classification=tuple(metadata["classification"]),
        depends_on=tuple(metadata["depends_on"]),
        source_path=Path("asl/scalar/alu/test/TEST.asl"),
        mnemonic=mnemonic,
        line_count=1,
        metadata=metadata,
    )


class InstructionContractTest(unittest.TestCase):
    def test_unconstrained_32_bit_field_assigns_the_complete_domain(self) -> None:
        metadata = instruction_metadata(
            field_contracts={},
            operands=[{"field": "imm", "role": "32-bit immediate value"}],
        )
        metadata["catalog_records"] = [
            {
                "form_id": "test_32",
                "fields": [
                    {"name": "imm", "width": 32, "signedness": "unsigned"}
                ],
                "constraints": [],
            }
        ]

        dispositions = derive_encoded_field_dispositions(
            unit(metadata, mnemonic="TEST"),
            tuple(metadata["contract"]["operands"]),
        )

        self.assertEqual(
            dispositions,
            (
                EncodedFieldDisposition(
                    form_id="test_32",
                    field_name="imm",
                    width=32,
                    signedness="unsigned",
                    role="32-bit immediate value",
                    zero_meaning="Encoded zero supplies numeric zero for the 32-bit immediate value.",
                    assigned_ranges=((0, (1 << 32) - 1),),
                    other_owner_values=(),
                    reserved_ranges=(),
                    rejection="none",
                ),
            ),
        )

    def test_one_of_constraint_reserves_the_complement(self) -> None:
        metadata = instruction_metadata(
            field_contracts={},
            operands=[{"field": "RegDst", "role": "absolute GPR destination"}],
        )
        metadata["catalog_records"] = [
            {
                "form_id": "test_gpr",
                "fields": [
                    {"name": "RegDst", "width": 5, "signedness": "encoding-defined"}
                ],
                "constraints": [
                    {
                        "field": "RegDst",
                        "operator": "one-of",
                        "values": list(range(24)),
                    }
                ],
            }
        ]

        disposition = derive_encoded_field_dispositions(
            unit(metadata, mnemonic="TEST"),
            tuple(metadata["contract"]["operands"]),
        )[0]

        self.assertEqual(disposition.assigned_ranges, ((0, 23),))
        self.assertEqual(disposition.reserved_ranges, ((24, 31),))
        self.assertIn("IllegalInstruction", disposition.rejection)

    def test_one_of_constraint_can_name_an_excluded_value_owner(self) -> None:
        metadata = instruction_metadata(
            field_contracts={},
            operands=[{"field": "BrType", "role": "block transfer selector"}],
        )
        metadata["catalog_records"] = [
            {
                "form_id": "compressed_start",
                "fields": [
                    {"name": "BrType", "width": 3, "signedness": "encoding-defined"}
                ],
                "constraints": [
                    {"field": "BrType", "operator": "one-of", "values": [1, 5, 7]}
                ],
                "excluded_value_owners": [
                    {"field": "BrType", "value": 0, "owner": "C.BSTOP"}
                ],
            }
        ]

        disposition = derive_encoded_field_dispositions(
            unit(metadata, mnemonic="TEST"),
            tuple(metadata["contract"]["operands"]),
        )[0]

        self.assertEqual(disposition.assigned_ranges, ((1, 1), (5, 5), (7, 7)))
        self.assertEqual(disposition.other_owner_values, ((0, "C.BSTOP"),))
        self.assertEqual(disposition.reserved_ranges, ((2, 4), (6, 6)))

    def test_not_equal_constraint_reserves_the_excluded_value(self) -> None:
        metadata = instruction_metadata(
            field_contracts={},
            operands=[{"field": "Mode", "role": "execution mode selector"}],
        )
        metadata["catalog_records"] = [
            {
                "form_id": "test_mode",
                "fields": [
                    {"name": "Mode", "width": 3, "signedness": "encoding-defined"}
                ],
                "constraints": [
                    {"field": "Mode", "operator": "not-equal", "value": 0}
                ],
            }
        ]

        disposition = derive_encoded_field_dispositions(
            unit(metadata, mnemonic="TEST"),
            tuple(metadata["contract"]["operands"]),
        )[0]

        self.assertEqual(disposition.assigned_ranges, ((1, 7),))
        self.assertEqual(disposition.reserved_ranges, ((0, 0),))

    def test_encoded_field_without_an_architectural_role_is_rejected(self) -> None:
        metadata = instruction_metadata(field_contracts={})
        metadata["catalog_records"] = [
            {
                "form_id": "test_missing_role",
                "fields": [
                    {"name": "Mode", "width": 2, "signedness": "encoding-defined"}
                ],
                "constraints": [],
            }
        ]

        with self.assertRaisesRegex(ValueError, "encoded field Mode has no architectural role"):
            derive_encoded_field_dispositions(
                unit(metadata, mnemonic="TEST"),
                tuple(metadata["contract"]["operands"]),
            )

    def test_no_operand_instruction_accepts_an_explicit_empty_operand_array(self) -> None:
        metadata = instruction_metadata(operands=[], field_contracts={})

        contract = resolve_instruction_contract(unit(metadata, mnemonic="TEST"), {})

        self.assertEqual(contract.operands, ())

    def test_five_bit_domain_requires_all_32_dispositions(self) -> None:
        metadata = domain_metadata(
            width=5,
            assigned=[(value, f"TYPE{value}") for value in range(25)],
            reserved=list(range(25, 31)),
        )
        domain = FieldDomainContract.from_metadata(metadata, Path("fixture.asl"))

        self.assertIn(
            "PTO-FIELD-TEST: field domain is missing values [31]",
            validate_domain(domain),
        )

    def test_domain_rejects_overlap_and_duplicate_meaning(self) -> None:
        metadata = domain_metadata(
            assigned=[(0, "FIRST"), (1, "FIRST")],
            reserved=[1, 2, 3],
        )
        domain = FieldDomainContract.from_metadata(metadata, Path("fixture.asl"))

        errors = validate_domain(domain)

        self.assertIn("PTO-FIELD-TEST: assigned and reserved values overlap: [1]", errors)
        self.assertIn("PTO-FIELD-TEST: duplicate assigned meaning FIRST", errors)

    def test_instruction_rejects_placeholder_role(self) -> None:
        metadata = instruction_metadata(
            operands=[{"field": "rd", "role": "encoded operand or control"}]
        )
        domains = {
            "PTO-FIELD-TEST": FieldDomainContract.from_metadata(
                domain_metadata(), Path("fixture.asl")
            )
        }

        with self.assertRaisesRegex(ValueError, "placeholder architectural text"):
            resolve_instruction_contract(unit(metadata, mnemonic="TEST"), domains)

    def test_selector_operation_requires_no_standalone_and_composition(self) -> None:
        metadata = instruction_metadata(
            encoding_class="selector-encoded-block-operation",
            standalone_opcode=True,
            block_composition=[],
        )
        domains = {
            "PTO-FIELD-TEST": FieldDomainContract.from_metadata(
                domain_metadata(), Path("fixture.asl")
            )
        }

        with self.assertRaisesRegex(ValueError, "must declare standalone_opcode=false"):
            resolve_instruction_contract(unit(metadata, mnemonic="TEST"), domains)

    def test_block_composition_preserves_repeated_binding_instructions(self) -> None:
        metadata = instruction_metadata(
            encoding_class="selector-encoded-block-operation",
            standalone_opcode=False,
            field_contracts={},
            block_composition=["BSTART.VEC TEST", "B.IOT", "B.IOT", "BSTOP"],
        )

        contract = resolve_instruction_contract(unit(metadata, mnemonic="TEST"), {})

        self.assertEqual(contract.block_composition.count("B.IOT"), 2)

    def test_instruction_rejects_unknown_field_domain(self) -> None:
        metadata = instruction_metadata(
            field_contracts={"Selector": {"ref": "PTO-FIELD-UNKNOWN"}}
        )

        with self.assertRaisesRegex(ValueError, "unknown field domain PTO-FIELD-UNKNOWN"):
            resolve_instruction_contract(unit(metadata, mnemonic="TEST"), {})

    def test_load_field_domains_reads_asl_unit_metadata(self) -> None:
        metadata = {
            "id": "PTO-ARCH-TEST-DOMAINS",
            "surface": "arch",
            "classification": ["overview", "test-domains"],
            "depends_on": [],
            "field_domains": [domain_metadata()],
        }
        domains = load_field_domains([unit(metadata)])

        self.assertEqual(tuple(domains), ("PTO-FIELD-TEST",))
        self.assertEqual(domains["PTO-FIELD-TEST"].width, 2)

    def test_check_supports_surface_and_staged_completeness(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = root / "asl/scalar/alu/test/TEST.asl"
            path.parent.mkdir(parents=True)
            metadata = instruction_metadata()
            metadata.update(
                {
                    "summary": "Test instruction.",
                    "assembly": ["TEST rd, rs"],
                    "block": [],
                    "catalog_records": [{"mnemonic": "TEST"}],
                    "catalog_indices": [0],
                }
            )
            path.write_text(
                "// PTO-INSTRUCTION: " + json.dumps(metadata, sort_keys=True) + "\n",
                encoding="utf-8",
            )
            domain_path = root / "asl/arch/overview/test-domains.asl"
            domain_path.parent.mkdir(parents=True)
            domain_path.write_text(
                "// PTO-UNIT: "
                + json.dumps(
                    {
                        "id": "PTO-ARCH-OVERVIEW-TEST-DOMAINS",
                        "surface": "arch",
                        "classification": ["overview", "test-domains"],
                        "depends_on": [],
                        "field_domains": [domain_metadata()],
                    },
                    sort_keys=True,
                )
                + "\n",
                encoding="utf-8",
            )

            self.assertEqual(check_instruction_contracts(root, surface="scalar"), [])
            self.assertEqual(len(load_units(root / "asl")), 2)

    def test_repository_gate_requires_global_contract_completeness(self) -> None:
        checker = (ROOT / "scripts/check-repository").read_text(encoding="utf-8")

        self.assertIn(
            "python3 scripts/instruction_contracts.py --check --require-complete",
            checker,
        )


if __name__ == "__main__":
    unittest.main()
